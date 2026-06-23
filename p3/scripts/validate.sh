#!/bin/bash

# Quick validation of the Part 3 structure

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        ERRORS=$((ERRORS+1))
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (executable)"
    else
        echo -e "${YELLOW}!${NC} $1 (not executable)"
    fi
}

echo "Validating Part 3 structure..."
echo ""

echo "Scripts:"
check_executable "scripts/setup.sh"
check_executable "scripts/cluster.sh"
check_executable "scripts/configure.sh"

echo ""
echo "Configuration files:"
check_file "confs/application.yaml"

echo ""
echo "Application manifests:"
check_file "app/deployment.yaml"
check_file "app/service.yaml"

echo ""
echo "Documentation:"
check_file "README.md"
check_file "DEFENSE.md"

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required files present!${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS file(s) missing!${NC}"
    exit 1
fi
