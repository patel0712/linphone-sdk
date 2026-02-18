#!/bin/bash
# Quick start guide - runs user through entire setup process

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}║  Linphone SDK Custom Builds - Quick Start Guide           ║${NC}"
echo -e "${CYAN}║  Automated Cross-Platform Build System                    ║${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Validation
echo -e "${BLUE}[Step 1/4] Validating Setup${NC}"
echo "Running pre-flight checks..."
echo ""

if [ -f "$SCRIPT_DIR/validate-setup.sh" ]; then
    bash "$SCRIPT_DIR/validate-setup.sh"
    VALIDATION_STATUS=$?
else
    echo -e "${RED}✗ Validation script not found${NC}"
    VALIDATION_STATUS=1
fi

echo ""
if [ $VALIDATION_STATUS -ne 0 ]; then
    echo -e "${RED}Setup validation failed. Please fix errors before continuing.${NC}"
    exit 1
fi

echo -e "${YELLOW}Press Enter to continue to GitHub setup...${NC}"
read -r

clear

# Step 2: GitHub Repository Creation
echo -e "${BLUE}[Step 2/4] GitHub Repository Setup${NC}"
echo ""
echo "You need to create a GitHub repository to host your custom builds."
echo ""
echo -e "${GREEN}Option 1: Create via Web Interface (Recommended)${NC}"
echo "  1. Go to: https://github.com/new"
echo "  2. Repository name: linphone-sdk"
echo "  3. Description: Custom Linphone SDK builds with VFS export fix"
echo "  4. Public or Private: Your choice"
echo "  5. DO NOT initialize with README, .gitignore, or license"
echo "  6. Click 'Create repository'"
echo ""
echo -e "${GREEN}Option 2: Create via GitHub CLI${NC}"
echo "  If you have 'gh' installed:"
echo "  $ gh repo create linphone-sdk --public --description \"Custom Linphone SDK builds\""
echo ""
echo -e "${YELLOW}Have you created the GitHub repository? (y/N):${NC}"
read -r REPO_CREATED

if [[ ! "$REPO_CREATED" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Please create the repository first, then run this script again.${NC}"
    echo "You can also proceed manually with:"
    echo "  $ ./scripts/push-to-github.sh"
    exit 0
fi

echo ""
echo -e "${YELLOW}Press Enter to continue to push setup...${NC}"
read -r

clear

# Step 3: Push to GitHub
echo -e "${BLUE}[Step 3/4] Pushing to GitHub${NC}"
echo ""

if [ -f "$SCRIPT_DIR/push-to-github.sh" ]; then
    bash "$SCRIPT_DIR/push-to-github.sh"
    PUSH_STATUS=$?
else
    echo -e "${RED}✗ Push script not found${NC}"
    PUSH_STATUS=1
fi

if [ $PUSH_STATUS -ne 0 ]; then
    echo ""
    echo -e "${RED}Push failed. Please check errors above.${NC}"
    echo ""
    echo "Common issues:"
    echo "- Authentication: Set up SSH keys or GitHub token"
    echo "- Repository doesn't exist: Create it at https://github.com/new"
    echo "- Permission denied: Check repository access"
    exit 1
fi

echo ""
echo -e "${YELLOW}Press Enter to see final instructions...${NC}"
read -r

clear

# Step 4: Next Steps
echo -e "${BLUE}[Step 4/4] What's Next${NC}"
echo ""
echo -e "${GREEN}✅ Your automation is now active!${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  Immediate Actions${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "1. Monitor CI/CD builds:"
echo "   Check GitHub Actions for build progress"
echo "   Estimated time: 3-4 hours for all platforms"
echo ""
echo "2. Wait for builds to complete:"
echo "   • macOS: ~60-90 min"
echo "   • Linux: ~45-60 min"
echo "   • Windows: ~90-120 min"
echo ""
echo "3. Check releases:"
echo "   Once builds complete, SDKs will be available as GitHub releases"
echo ""

# Get GitHub username from git remote
GITHUB_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ $GITHUB_URL =~ github.com[:/]([^/]+)/([^/]+) ]]; then
    GITHUB_USER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]%.git}"
    
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  Useful Links${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo "Repository:"
    echo "  https://github.com/$GITHUB_USER/$REPO_NAME"
    echo ""
    echo "Actions (CI/CD):"
    echo "  https://github.com/$GITHUB_USER/$REPO_NAME/actions"
    echo ""
    echo "Releases (SDKs):"
    echo "  https://github.com/$GITHUB_USER/$REPO_NAME/releases"
    echo ""
fi

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  Flutter Project Integration${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "After builds complete, update your Flutter project:"
echo ""
echo "cd '/Users/aliter-maulik/Desktop/Aliter Projects/linphone_flutter'"
echo ""

if [ -n "$GITHUB_USER" ]; then
    echo "# Edit scripts/update-linphone-sdk.sh:"
    echo "# Replace 'your-github-username' with '$GITHUB_USER'"
    echo ""
fi

echo "# Run the integration script:"
echo "./scripts/update-linphone-sdk.sh v5.4.86-custom-1"
echo ""
echo "# This will:"
echo "  - Download SDKs from GitHub releases"
echo "  - Extract and install them"
echo "  - Update CMake configuration"
echo "  - Create backups of old SDKs"
echo ""

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  Testing${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "Test on each platform:"
echo "  macOS:   flutter run -d macos"
echo "  Linux:   flutter run -d linux"
echo "  Windows: flutter run -d windows"
echo ""
echo "The VFS error should be resolved on all platforms!"
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete! Your automation is running on GitHub.    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
