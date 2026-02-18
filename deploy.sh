#!/bin/bash
# Complete automation orchestrator - runs entire deployment process
# This is your one-click deployment script!

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}║  🚀 AUTOMATED DEPLOYMENT STARTING                          ║${NC}"
echo -e "${CYAN}║  Linphone SDK Custom Builds - Full Automation             ║${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This script is optimized for macOS but will attempt to run..."
fi

echo -e "${BLUE}Phase 1: Pre-flight Validation${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
./scripts/validate-setup.sh
echo ""

echo -e "${BLUE}Phase 2: GitHub Deployment${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "This will guide you through pushing to GitHub..."
echo ""
./scripts/push-to-github.sh
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ DEPLOYMENT COMPLETE                                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "CI/CD is now building your custom SDKs on GitHub."
echo "Check progress at: GitHub Actions page"
echo ""
echo "Run ./scripts/quick-start.sh anytime for guidance!"
echo ""
