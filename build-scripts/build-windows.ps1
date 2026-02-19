# Windows Automated Build Script for Linphone SDK
# PowerShell script

$ErrorActionPreference = "Stop"

Write-Host "🪟 Building Linphone SDK for Windows" -ForegroundColor Green

$SDK_ROOT = Split-Path -Parent $PSScriptRoot
$BUILD_TYPE = if ($env:BUILD_TYPE) { $env:BUILD_TYPE } else { "Release" }

Set-Location $SDK_ROOT

# Initialize submodules
if (-not (Test-Path "bctoolbox\CMakeLists.txt")) {
    Write-Host "Initializing submodules..." -ForegroundColor Yellow
    git submodule update --init --recursive
}

# Apply patches  
Write-Host "Applying VFS export patch..." -ForegroundColor Yellow
if (Test-Path "patches\cross-platform-vfs-export.patch") {
    git apply --check patches\cross-platform-vfs-export.patch 2>$null
    if ($LASTEXITCODE -eq 0) {
        git apply patches\cross-platform-vfs-export.patch
    } else {
        Write-Host "Patch already applied"
    }
}

# Build Windows
Write-Host "Building for x64..." -ForegroundColor Green
python prepare.py windows-x64 `
    --enable-shared-libraries `
    --disable-static-libraries `
    --build-type=$BUILD_TYPE

cmake --build . --config $BUILD_TYPE --parallel

# Validate
$DLL_PATH = "linphone-sdk-build\windows-x64\bin\linphone.dll"
$exports = dumpbin /EXPORTS $DLL_PATH | Select-String "sqlite3_bctbx_vfs_register"
if ($exports) {
    Write-Host "✅ VFS symbol exported" -ForegroundColor Green
} else {
    Write-Host "❌ VFS symbol NOT found" -ForegroundColor Red
    exit 1
}

# Distribute
New-Item -ItemType Directory -Force -Path dist\windows\bin | Out-Null
Copy-Item -Recurse linphone-sdk-build\windows-x64\bin\* dist\windows\bin\
Copy-Item -Recurse linphone-sdk-build\windows-x64\include dist\windows\

Write-Host "✅ Windows build complete: dist\windows\" -ForegroundColor Green
