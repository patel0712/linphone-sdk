#!/bin/bash
# Validation script to verify automation setup before pushing to GitHub
# Checks all files, permissions, and configurations

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "🔍 Validating Linphone SDK Automation Setup..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((ERRORS++))
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Found directory: $1"
        return 0
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        ((ERRORS++))
        return 1
    fi
}

# Function to check file is executable
check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} Executable: $1"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Not executable: $1 (fixing...)"
        chmod +x "$1"
        ((WARNINGS++))
        return 1
    fi
}

echo "=== Checking Git Status ==="
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Git repository initialized"
    
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$BRANCH" = "custom-desktop-builds" ]; then
        echo -e "${GREEN}✓${NC} On correct branch: custom-desktop-builds"
    else
        echo -e "${YELLOW}⚠${NC} Current branch: $BRANCH (expected: custom-desktop-builds)"
        ((WARNINGS++))
    fi
    
    if git diff-index --quiet HEAD --; then
        echo -e "${GREEN}✓${NC} Working tree clean (all changes committed)"
    else
        echo -e "${YELLOW}⚠${NC} Uncommitted changes detected"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} Not a git repository"
    ((ERRORS++))
fi
echo ""

echo "=== Checking Build Scripts ==="
check_dir "build-scripts"
check_file "build-scripts/build-macos.sh"
check_executable "build-scripts/build-macos.sh"
check_file "build-scripts/build-linux.sh"
check_executable "build-scripts/build-linux.sh"
check_file "build-scripts/build-windows.ps1"
echo ""

echo "=== Checking Patches ==="
check_dir "patches"
check_file "patches/cross-platform-vfs-export.patch"
echo ""

echo "=== Checking GitHub Actions Workflows ==="
check_dir ".github"
check_dir ".github/workflows"
check_file ".github/workflows/build-all-platforms.yml"

# Validate workflow syntax
if command -v yq &> /dev/null; then
    if yq eval '.jobs' .github/workflows/build-all-platforms.yml > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Workflow YAML syntax valid"
    else
        echo -e "${RED}✗${NC} Workflow YAML syntax invalid"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} yq not installed, skipping YAML validation"
    ((WARNINGS++))
fi
echo ""

echo "=== Checking Documentation ==="
check_file "README_CUSTOM_BUILDS.md"
check_file "UPDATE_FLUTTER_PROJECT.md"
echo ""

echo "=== Checking Patch Content ==="
if grep -q "sqlite3_bctbx_vfs_register" "patches/cross-platform-vfs-export.patch"; then
    echo -e "${GREEN}✓${NC} Patch contains VFS function exports"
else
    echo -e "${RED}✗${NC} Patch missing VFS function exports"
    ((ERRORS++))
fi

if grep -q "visibility" "patches/cross-platform-vfs-export.patch"; then
    echo -e "${GREEN}✓${NC} Patch contains visibility attributes"
else
    echo -e "${YELLOW}⚠${NC} Patch may be missing visibility attributes"
    ((WARNINGS++))
fi
echo ""

echo "=== Checking Workflow Jobs ==="
if grep -q "build-macos:" ".github/workflows/build-all-platforms.yml"; then
    echo -e "${GREEN}✓${NC} macOS build job defined"
else
    echo -e "${RED}✗${NC} macOS build job missing"
    ((ERRORS++))
fi

if grep -q "build-linux:" ".github/workflows/build-all-platforms.yml"; then
    echo -e "${GREEN}✓${NC} Linux build job defined"
else
    echo -e "${RED}✗${NC} Linux build job missing"
    ((ERRORS++))
fi

if grep -q "build-windows:" ".github/workflows/build-all-platforms.yml"; then
    echo -e "${GREEN}✓${NC} Windows build job defined"
else
    echo -e "${RED}✗${NC} Windows build job missing"
    ((ERRORS++))
fi
echo ""

echo "=== Summary ==="
echo -e "Total checks: $((ERRORS + WARNINGS)) issues found"
echo -e "${RED}Errors: $ERRORS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Setup validation passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Create GitHub repository: https://github.com/new"
    echo "2. Run: ./scripts/push-to-github.sh <your-github-username>"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Setup validation failed. Please fix errors above.${NC}"
    exit 1
fi
