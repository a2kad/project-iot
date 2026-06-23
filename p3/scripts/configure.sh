#!/bin/bash

# IoT Project Part 3 - Configuration Script
# Configures the GitHub repository URL before deployment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_MANIFEST="$SCRIPT_DIR/confs/application.yaml"

# Verify manifest exists
if [ ! -f "$APP_MANIFEST" ]; then
    log_error "Application manifest not found: $APP_MANIFEST"
    exit 1
fi

# GitHub login (pre-configured for this project)
GITHUB_LOGIN="a2kad"
log_info "Configuring with GitHub login: $GITHUB_LOGIN"

# Update the application manifest with the GitHub login
REPO_URL="https://github.com/$GITHUB_LOGIN/project-iot.git"

# Use sed to update the repoURL (if needed - usually already configured)
if grep -q "<LOGIN>" "$APP_MANIFEST"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|https://github.com/<LOGIN>-iot/project.git|$REPO_URL|g" "$APP_MANIFEST"
    else
        # Linux
        sed -i "s|https://github.com/<LOGIN>-iot/project.git|$REPO_URL|g" "$APP_MANIFEST"
    fi
    log_info "Updated application.yaml with repository: $REPO_URL"
else
    log_info "Repository URL already configured: $REPO_URL"
fi

# Display the current configuration
echo ""
log_info "Current configuration:"
echo ""
grep -A 5 "source:" "$APP_MANIFEST"

echo ""
log_info "GitHub repository is configured as:"
echo "   https://github.com/rureshet-iot/project"
echo ""
log_info "Next steps:"
echo "1. Ensure GitHub repository exists with manifests in p3/app/"
echo "2. Run the setup:"
echo "   bash p3/scripts/setup.sh"
echo ""
