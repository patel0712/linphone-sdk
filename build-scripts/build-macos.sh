#!/bin/bash
set -euo pipefail

# macOS Automated Build Script for Linphone SDK
# This script builds a universal (arm64 + x86_64) framework

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🍎 Building Linphone SDK for macOS${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_TYPE="${BUILD_TYPE:-Release}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(sysctl -n hw.ncpu)}"

cd "$SDK_ROOT"

# Initialize submodules
if [ ! -f "bctoolbox/CMakeLists.txt" ]; then
    echo -e "${YELLOW}Initializing submodules...${NC}"
    git submodule update --init --recursive
fi

# Apply patches
echo -e "${YELLOW}Applying VFS export patch...${NC}"
if [ -f "patches/cross-platform-vfs-export.patch" ]; then
    git apply --check patches/cross-platform-vfs-export.patch 2>/dev/null && \
        git apply patches/cross-platform-vfs-export.patch || \
        echo "Patch already applied"
fi

# Build universal
echo -e "${GREEN}Building universal framework...${NC}"
./prepare.py macos-universal \
    --enable-shared-libraries \
    --disable-static-libraries \
    --build-type="$BUILD_TYPE"

make -j"$PARALLEL_JOBS"

# Validate
FRAMEWORK_PATH="linphone-sdk-build/macos-universal/Frameworks/linphone.framework/linphone"
if nm -gU "$FRAMEWORK_PATH" | grep -q sqlite3_bctbx_vfs_register; then
    echo -e "${GREEN}✅ VFS symbol exported${NC}"
else
    echo -e "${RED}❌ VFS symbol NOT found${NC}"
    exit 1
fi

# Distribute
mkdir -p dist/macos
cp -r linphone-sdk-build/macos-universal/Frameworks/* dist/macos/

echo -e "${GREEN}✅ macOS build complete: dist/macos/${NC}"
