# Linphone SDK Custom Builds - Automation Guide

**Repository:** Custom Linphone SDK builds for Windows, macOS, and Linux  
**Version:** 5.4.86-custom  
**Purpose:** Automated builds with VFS export fix for all desktop platforms  

---

## 🚀 Quick Start

### Automated Build (CI/CD)

1. **Push to trigger CI/CD:**
   ```bash
   git push origin custom-desktop-builds
   ```

2. **Or create a release:**
   ```bash
   git tag v5.4.86-custom-1
   git push origin v5.4.86-custom-1
   ```

3. **Download artifacts from GitHub Actions**

### Manual Build

```bash
# macOS
./build-scripts/build-macos.sh

# Linux
./build-scripts/build-linux.sh

# Windows
.\build-scripts\build-windows.ps1
```

---

## 📁 Directory Structure

```
linphone-sdk/
├── .github/workflows/
│   └── build-all-platforms.yml    # CI/CD automation
├── patches/
│   └── cross-platform-vfs-export.patch  # VFS fix
├── build-scripts/
│   ├── build-macos.sh             # macOS build
│   ├── build-linux.sh             # Linux build
│   └── build-windows.ps1          # Windows build
└── dist/                          # Build outputs
    ├── macos/
    ├── linux/
    └── windows/
```

---

## 🔧 CI/CD Workflow

**Triggers:**
- Push to `custom-desktop-builds` branch
- New tag `v*`
- Manual workflow dispatch

**Jobs:**
1. **build-macos** - Builds universal framework (arm64 + x86_64)
2. **build-linux** - Builds shared libraries (x86_64)
3. **build-windows** - Builds DLLs (x64)
4. **validation** - Validates all builds and creates report

**Artifacts:** Uploaded to GitHub Actions (30 days retention)  
**Releases:** Automatically created for tags

---

## 🔄 Update Process

### When new Linphone version is released:

```bash
# Fetch latest
git fetch origin

# Create update branch
git checkout -b update-5.5.0

# Merge new version
git merge origin/5.5.0

# Re-apply patches
git apply patches/cross-platform-vfs-export.patch

# Or cherry-pick your commits
git cherry-pick <commit-hash>

# Test builds
./build-scripts/build-macos.sh

# Tag and push
git tag v5.5.0-custom-1
git push origin update-5.5.0
git push origin v5.5.0-custom-1
```

---

## 📊 Build Validation

Each build automatically validates:
- ✅ VFS symbol export (nm/dumpbin)
- ✅ Framework/library structure
- ✅ Size and completeness
- ✅ Error codes and exit status

---

## 🎯 Integration with Flutter Project

See `UPDATE_FLUTTER_PROJECT.md` for integration instructions.

---

## 📝 Version History

| Tag | Date | SDK Version | Notes |
|-----|------|-------------|-------|
| v5.4.86-custom-1 | 2026-02-17 | 5.4.86 | Initial automation setup |

---

**Maintained by:** Linphone Flutter Desktop Team  
**Last Updated:** 2026-02-17
