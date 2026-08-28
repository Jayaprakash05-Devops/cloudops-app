#!/bin/bash

# Script to enable security-enhanced workflows

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Enable Security-Enhanced Workflows${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

echo -e "${YELLOW}This script will update your service workflows to use security-enhanced pipelines.${NC}"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo -e "${BLUE}Updating service workflows...${NC}"

# Update service-registry workflow
cat > .github/workflows/service-registry.yml << 'EOF'
name: Service Registry CI/CD (Security-Enhanced)

on:
  push:
    branches: [main, develop]
    paths:
      - 'services/service-registry/**'
      - '.github/workflows/service-registry.yml'
      - '.github/workflows/security-enhanced-backend-ci.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'services/service-registry/**'
  workflow_dispatch:

jobs:
  security-enhanced-ci:
    uses: ./.github/workflows/security-enhanced-backend-ci.yml
    with:
      service-name: service-registry
      service-path: services/service-registry
      port: '8001'
      python-version: '3.11'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
      SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
EOF

echo -e "${GREEN}✓${NC} Updated service-registry.yml"

# Update health-checker workflow
cat > .github/workflows/health-checker.yml << 'EOF'
name: Health Checker CI/CD (Security-Enhanced)

on:
  push:
    branches: [main, develop]
    paths:
      - 'services/health-checker/**'
      - '.github/workflows/health-checker.yml'
      - '.github/workflows/security-enhanced-backend-ci.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'services/health-checker/**'
  workflow_dispatch:

jobs:
  security-enhanced-ci:
    uses: ./.github/workflows/security-enhanced-backend-ci.yml
    with:
      service-name: health-checker
      service-path: services/health-checker
      port: '8002'
      python-version: '3.11'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
      SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
EOF

echo -e "${GREEN}✓${NC} Updated health-checker.yml"

# Update metrics-collector workflow
cat > .github/workflows/metrics-collector.yml << 'EOF'
name: Metrics Collector CI/CD (Security-Enhanced)

on:
  push:
    branches: [main, develop]
    paths:
      - 'services/metrics-collector/**'
      - '.github/workflows/metrics-collector.yml'
      - '.github/workflows/security-enhanced-backend-ci.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'services/metrics-collector/**'
  workflow_dispatch:

jobs:
  security-enhanced-ci:
    uses: ./.github/workflows/security-enhanced-backend-ci.yml
    with:
      service-name: metrics-collector
      service-path: services/metrics-collector
      port: '8003'
      python-version: '3.11'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
      SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
EOF

echo -e "${GREEN}✓${NC} Updated metrics-collector.yml"

# Update alert-manager workflow
cat > .github/workflows/alert-manager.yml << 'EOF'
name: Alert Manager CI/CD (Security-Enhanced)

on:
  push:
    branches: [main, develop]
    paths:
      - 'services/alert-manager/**'
      - '.github/workflows/alert-manager.yml'
      - '.github/workflows/security-enhanced-backend-ci.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'services/alert-manager/**'
  workflow_dispatch:

jobs:
  security-enhanced-ci:
    uses: ./.github/workflows/security-enhanced-backend-ci.yml
    with:
      service-name: alert-manager
      service-path: services/alert-manager
      port: '8004'
      python-version: '3.11'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
      SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
      SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
EOF

echo -e "${GREEN}✓${NC} Updated alert-manager.yml"

# Update frontend workflow
cat > .github/workflows/frontend.yml << 'EOF'
name: Frontend CI/CD (Security-Enhanced)

on:
  push:
    branches: [main, develop]
    paths:
      - 'frontend/**'
      - '.github/workflows/frontend.yml'
      - '.github/workflows/security-enhanced-frontend-ci.yml'
  pull_request:
    branches: [main, develop]
    paths:
      - 'frontend/**'
  workflow_dispatch:

jobs:
  security-enhanced-ci:
    uses: ./.github/workflows/security-enhanced-frontend-ci.yml
    with:
      node-version: '18'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
      SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
      SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
EOF

echo -e "${GREEN}✓${NC} Updated frontend.yml"

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✓ All workflows updated!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the updated workflow files"
echo "2. Install pre-commit hooks: make pre-commit-install"
echo "3. Commit and push the changes"
echo "4. Watch the security-enhanced pipeline run!"
echo ""
echo -e "${BLUE}Optional secrets to add (Settings → Secrets):${NC}"
echo "  • SNYK_TOKEN - For Snyk dependency scanning"
echo "  • SONAR_TOKEN - For SonarQube analysis"
echo ""
echo -e "${GREEN}Security features now enabled! 🔒${NC}"
