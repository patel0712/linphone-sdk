#!/bin/bash
set -euo pipefail

# Linux Automated Build Script for Linphone SDK

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🐧 Building Linphone SDK for Linux${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_TYPE="${BUILD_TYPE:-Release}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"

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

# Build Linux
echo -e "${GREEN}Building for x86_64...${NC}"
./prepare.py linux-x86_64 \
    --enable-shared-libraries \
    --disable-static-libraries \
    --build-type="$BUILD_TYPE"

make -j"$PARALLEL_JOBS"

# Validate
SO_PATH="linphone-sdk-build/linux-x86_64/lib/liblinphone.so"
if nm -D "$SO_PATH" | grep -q sqlite3_bctbx_vfs_register; then
    echo -e "${GREEN}✅ VFS symbol exported${NC}"
else
    echo -e "${RED}❌ VFS symbol NOT found${NC}"
    exit 1
fi

# Distribute
mkdir -p dist/linux/lib
cp -r linphone-sdk-build/linux-x86_64/lib/* dist/linux/lib/
cp -r linphone-sdk-build/linux-x86_64/include dist/linux/

echo -e "${GREEN}✅ Linux build complete: dist/linux/${NC}"
