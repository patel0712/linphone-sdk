#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🚀 AUTOMATED DEPLOYMENT STARTING${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}Phase 1: Pre-flight Validation${NC}"
bash scripts/validate-setup.sh
echo ""

echo -e "${BLUE}Phase 2: GitHub Deployment${NC}"
bash scripts/push-to-github.sh
echo ""

echo -e "${GREEN}✅ DEPLOYMENT COMPLETE${NC}"
echo "CI/CD is now building your custom SDKs."
echo ""
