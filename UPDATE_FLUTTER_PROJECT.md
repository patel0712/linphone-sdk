# Integrating Custom Linphone SDK with Flutter Project

**This guide automates SDK integration to minimize manual steps and errors.**

---

## 🎯 Automated Integration

### Option 1: Download from GitHub Releases (Recommended)

Update your Flutter project's CMake to auto-download from releases:

**File: `third/linphone_config.cmake`**

```cmake
set(LINPHONE_SDK_CUSTOM_VERSION "5.4.86-custom-1" CACHE STRING "Custom SDK version")
set(LINPHONE_SDK_REPO "your-github-username/linphone-sdk" CACHE STRING "Custom SDK repository")
set(USE_CUSTOM_SDK TRUE CACHE BOOL "Use custom-built SDK")

if(USE_CUSTOM_SDK)
    message(STATUS "Using custom Linphone SDK ${LINPHONE_SDK_CUSTOM_VERSION}")
    
    # Download URL
    if(APPLE)
        set(SDK_URL "https://github.com/${LINPHONE_SDK_REPO}/releases/download/v${LINPHONE_SDK_CUSTOM_VERSION}/linphone-sdk-macos-${LINPHONE_SDK_CUSTOM_VERSION}.tar.gz")
        set(SDK_EXTRACT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third/linphone/macos")
    elseif(UNIX)
        set(SDK_URL "https://github.com/${LINPHONE_SDK_REPO}/releases/download/v${LINPHONE_SDK_CUSTOM_VERSION}/linphone-sdk-linux-${LINPHONE_SDK_CUSTOM_VERSION}.tar.gz")
        set(SDK_EXTRACT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third/linphone/linux")
    elseif(WIN32)
        set(SDK_URL "https://github.com/${LINPHONE_SDK_REPO}/releases/download/v${LINPHONE_SDK_CUSTOM_VERSION}/linphone-sdk-windows-${LINPHONE_SDK_CUSTOM_VERSION}.zip")
        set(SDK_EXTRACT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third/linphone/windows")
    endif()
    
    # Download if not exists
    if(NOT EXISTS "${SDK_EXTRACT_DIR}")
        message(STATUS "Downloading custom SDK from ${SDK_URL}")
        file(DOWNLOAD "${SDK_URL}" "${CMAKE_CURRENT_BINARY_DIR}/linphone-sdk.tar.gz"
             SHOW_PROGRESS
             STATUS download_status)
        
        list(GET download_status 0 status_code)
        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "Failed to download SDK")
        endif()
        
        # Extract
        file(ARCHIVE_EXTRACT INPUT "${CMAKE_CURRENT_BINARY_DIR}/linphone-sdk.tar.gz"
             DESTINATION "${CMAKE_CURRENT_SOURCE_DIR}/third/linphone/")
    endif()
endif()
```

### Option 2: CI/CD Artifact Integration

**File: `.github/workflows/flutter-build.yml`** (add to your Flutter project)

```yaml
name: Build Flutter App with Custom SDK

on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [macos-latest, ubuntu-latest, windows-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download custom Linphone SDK
        uses: dawidd6/action-download-artifact@v3
        with:
          workflow: build-all-platforms.yml
          repo: your-username/linphone-sdk
          branch: custom-desktop-builds
          name: linphone-sdk-${{ runner.os == 'macOS' && 'macos' || runner.os == 'Linux' && 'linux' || 'windows' }}-5.4.86-custom
          path: third/linphone/${{ runner.os == 'macOS' && 'macos' || runner.os == 'Linux' && 'linux' || 'windows' }}
      
      - uses: subosito/flutter-action@v2
      
      - name: Build Flutter app
        run: flutter build ${{ runner.os == 'macOS' && 'macos' || runner.os == 'Linux' && 'linux' || 'windows' }}
```

---

## 📦 Manual Integration

### Step 1: Download SDK Builds

From GitHub Actions artifacts or releases:

```bash
# Download all three platforms
cd ~/Downloads
# Get linphone-sdk-macos-5.4.86-custom-1.tar.gz
# Get linphone-sdk-linux-5.4.86-custom-1.tar.gz  
# Get linphone-sdk-windows-5.4.86-custom-1.zip
```

### Step 2: Copy to Flutter Project

```bash
cd "/Users/aliter-maulik/Desktop/Aliter Projects/linphone_flutter"

# Backup existing
mv third/linphone third/linphone.backup.$(date +%Y%m%d)

# Extract custom builds
mkdir -p third/linphone/{macos,linux,windows}

tar -xzf ~/Downloads/linphone-sdk-macos-5.4.86-custom-1.tar.gz -C third/linphone/
tar -xzf ~/Downloads/linphone-sdk-linux-5.4.86-custom-1.tar.gz -C third/linphone/
unzip ~/Downloads/linphone-sdk-windows-5.4.86-custom-1.zip -d third/linphone/
```

### Step 3: Update Configuration

Update `third/linphone_config.cmake`:

```cmake
set(LINPHONE_SDK_DEFAULT_VERSION "5.4.86-custom-1" CACHE STRING "Custom Linphone SDK version")
set(USE_CUSTOM_LINPHONE_SDK TRUE CACHE BOOL "Use custom-built SDK")
```

### Step 4: Clean and Rebuild

```bash
flutter clean
rm -rf build/ macos/Pods/
flutter pub get
cd macos && pod install && cd ..
flutter build macos
```

---

## 🔄 Automated Update Script

Create this script in your Flutter project:

**File: `scripts/update-linphone-sdk.sh`**

```bash
#!/bin/bash
set -e

VERSION="${1:-5.4.86-custom-1}"
REPO="${2:-your-username/linphone-sdk}"

echo "Updating to Linphone SDK $VERSION from $REPO"

# Download from GitHub releases
for PLATFORM in macos linux windows; do
    EXT="${PLATFORM/windows/zip}"
    EXT="${EXT/macos/tar.gz}"
    EXT="${EXT/linux/tar.gz}"
    
    URL="https://github.com/$REPO/releases/download/v$VERSION/linphone-sdk-$PLATFORM-$VERSION.$EXT"
    
    echo "Downloading $PLATFORM..."
    curl -L "$URL" -o "/tmp/linphone-$PLATFORM.$EXT"
    
    # Extract
    rm -rf "third/linphone/$PLATFORM"
    mkdir -p "third/linphone/$PLATFORM"
    
    if [ "$EXT" = "zip" ]; then
        unzip "/tmp/linphone-$PLATFORM.$EXT" -d "third/linphone/"
    else
        tar -xzf "/tmp/linphone-$PLATFORM.$EXT" -C "third/linphone/"
    fi
done

# Update config
sed -i.bak "s/LINPHONE_SDK_DEFAULT_VERSION \".*\"/LINPHONE_SDK_DEFAULT_VERSION \"$VERSION\"/" third/linphone_config.cmake

echo "✅ SDK updated to $VERSION"
echo "Run: flutter clean && flutter build [platform]"
```

**Usage:**

```bash
chmod +x scripts/update-linphone-sdk.sh
./scripts/update-linphone-sdk.sh 5.4.86-custom-1 your-username/linphone-sdk
```

---

## ✅ Validation

After integration, test each platform:

```bash
# macOS
flutter run -d macos --verbose | grep -i vfs

# Should NOT see: "no such vfs: sqlite3bctbx_vfs"
# Should see: "sqlite3_bctbx_vfs_register(1) => 0"

# Linux
flutter run -d linux --verbose

# Windows
flutter run -d windows --verbose
```

---

## 🐛 Troubleshooting

### SDK not found

**Problem:** CMake can't find the SDK

**Fix:**
```bash
# Verify structure
ls -R third/linphone/

# Should see:
# third/linphone/macos/Frameworks/linphone.framework/
# third/linphone/linux/lib/liblinphone.so
# third/linphone/windows/bin/linphone.dll
```

### VFS still failing

**Problem:** Still getting VFS errors

**Fix:**
```bash
# Verify symbol export
nm -gU third/linphone/macos/Frameworks/linphone.framework/linphone | grep vfs

# Should output: ... T _sqlite3_bctbx_vfs_register
```

### Build cache issues

**Fix:**
```bash
flutter clean
rm -rf build/ .dart_tool/
rm -rf macos/Pods/ macos/.symlinks
flutter pub get
```

---

## 📊 Version Tracking

Create `.linphone-sdk-version` file:

```
VERSION=5.4.86-custom-1
BUILD_DATE=2026-02-17
PLATFORMS=macos,linux,windows
VFS_FIX=true
SOURCE_REPO=your-username/linphone-sdk
SOURCE_TAG=v5.4.86-custom-1
```

---

**Last Updated:** 2026-02-17  
**Automation Level:** 🟢 High - Minimal manual intervention required
