#!/bin/bash
# Interactive script to push custom builds to GitHub
# Usage: ./push-to-github.sh [github-username] [repo-name]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Linphone SDK Custom Builds - GitHub Push${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Get GitHub username
if [ -z "$1" ]; then
    echo -e "${YELLOW}Enter your GitHub username:${NC}"
    read -r GITHUB_USER
else
    GITHUB_USER="$1"
fi

# Get repository name
if [ -z "$2" ]; then
    echo -e "${YELLOW}Enter repository name [default: linphone-sdk]:${NC}"
    read -r REPO_NAME
    REPO_NAME=${REPO_NAME:-linphone-sdk}
else
    REPO_NAME="$2"
fi

# Get version tag
echo -e "${YELLOW}Enter version tag [default: v5.4.86-custom-1]:${NC}"
read -r VERSION_TAG
VERSION_TAG=${VERSION_TAG:-v5.4.86-custom-1}

echo ""
echo -e "${GREEN}Configuration:${NC}"
echo "  GitHub User: $GITHUB_USER"
echo "  Repository: $REPO_NAME"
echo "  Remote URL: https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "  Version Tag: $VERSION_TAG"
echo ""

# Validate setup first
echo -e "${BLUE}=== Running Pre-Push Validation ===${NC}"
if [ -f "$SCRIPT_DIR/validate-setup.sh" ]; then
    bash "$SCRIPT_DIR/validate-setup.sh"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Validation failed. Please fix errors before pushing.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ Validation script not found, skipping validation${NC}"
fi
echo ""

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    EXISTING_REMOTE=$(git remote get-url origin)
    echo -e "${YELLOW}⚠ Remote 'origin' already exists: $EXISTING_REMOTE${NC}"
    echo -e "${YELLOW}Do you want to replace it? (y/N):${NC}"
    read -r REPLACE
    if [[ "$REPLACE" =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo -e "${GREEN}✓${NC} Removed existing remote"
    else
        echo -e "${RED}Aborted. Please remove existing remote manually or use a different name.${NC}"
        exit 1
    fi
fi

# Add remote
echo -e "${BLUE}=== Adding GitHub Remote ===${NC}"
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo -e "${GREEN}✓${NC} Added remote: origin -> https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo ""

# Show what will be pushed
echo -e "${BLUE}=== Commits to be Pushed ===${NC}"
git log --oneline -n 5
echo ""

# Confirm push
echo -e "${YELLOW}Ready to push to GitHub. Continue? (y/N):${NC}"
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Push cancelled.${NC}"
    git remote remove origin
    exit 1
fi

# Push branch
echo -e "${BLUE}=== Pushing Branch ===${NC}"
echo "Pushing custom-desktop-builds branch..."
if git push -u origin custom-desktop-builds; then
    echo -e "${GREEN}✓${NC} Successfully pushed branch"
else
    echo -e "${RED}✗${NC} Failed to push branch"
    echo ""
    echo "Common issues:"
    echo "1. Repository doesn't exist - Create it at: https://github.com/new"
    echo "2. Authentication failed - Set up GitHub authentication (SSH or token)"
    echo "3. Permission denied - Check repository access permissions"
    exit 1
fi
echo ""

# Create and push tag
echo -e "${BLUE}=== Creating Version Tag ===${NC}"
if git tag -a "$VERSION_TAG" -m "Custom build v5.4.86 with VFS export fix"; then
    echo -e "${GREEN}✓${NC} Created tag: $VERSION_TAG"
    
    echo "Pushing tag..."
    if git push origin "$VERSION_TAG"; then
        echo -e "${GREEN}✓${NC} Successfully pushed tag"
    else
        echo -e "${YELLOW}⚠${NC} Failed to push tag (branch was pushed successfully)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Tag may already exist or failed to create"
fi
echo ""

# Success message
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✅ Successfully Pushed to GitHub!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Repository: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "Branch: custom-desktop-builds"
echo "Tag: $VERSION_TAG"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Go to: https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo "2. Monitor the CI/CD build progress (~3-4 hours)"
echo "3. Once complete, check releases at:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME/releases"
echo ""
echo -e "${BLUE}To update Flutter project:${NC}"
echo "cd '/Users/aliter-maulik/Desktop/Aliter Projects/linphone_flutter'"
echo "# Edit scripts/update-linphone-sdk.sh - replace 'your-github-username' with '$GITHUB_USER'"
echo "./scripts/update-linphone-sdk.sh $VERSION_TAG"
echo ""
