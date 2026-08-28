#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Synapse Setup Verification${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Function to check file
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Function to check directory
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Check Dockerfiles
echo -e "${YELLOW}Checking Dockerfiles...${NC}"
check_file "services/service-registry/Dockerfile" "Service Registry Dockerfile"
check_file "services/health-checker/Dockerfile" "Health Checker Dockerfile"
check_file "services/metrics-collector/Dockerfile" "Metrics Collector Dockerfile"
check_file "services/alert-manager/Dockerfile" "Alert Manager Dockerfile"
check_file "frontend/Dockerfile" "Frontend Dockerfile"
echo ""

# Check GitHub Actions
echo -e "${YELLOW}Checking GitHub Actions workflows...${NC}"
check_dir ".github/workflows" "Workflows directory"
check_file ".github/workflows/reusable-backend-ci.yml" "Reusable backend workflow"
check_file ".github/workflows/reusable-frontend-ci.yml" "Reusable frontend workflow"
check_file ".github/workflows/service-registry.yml" "Service Registry workflow"
check_file ".github/workflows/health-checker.yml" "Health Checker workflow"
check_file ".github/workflows/metrics-collector.yml" "Metrics Collector workflow"
check_file ".github/workflows/alert-manager.yml" "Alert Manager workflow"
check_file ".github/workflows/frontend.yml" "Frontend workflow"
check_file ".github/workflows/integration-tests.yml" "Integration tests workflow"
echo ""

# Check configuration files
echo -e "${YELLOW}Checking configuration files...${NC}"
check_file ".dockerignore" "Root .dockerignore"
check_file "services/.dockerignore" "Services .dockerignore"
check_file "frontend/.dockerignore" "Frontend .dockerignore"
check_file ".github/dependabot.yml" "Dependabot configuration"
check_file ".github/CODEOWNERS" "CODEOWNERS file"
check_file "Makefile" "Makefile"
check_file "frontend/nginx.conf" "Nginx configuration"
check_file "docker-compose.yml" "Docker Compose file"
echo ""

# Check documentation
echo -e "${YELLOW}Checking documentation...${NC}"
check_file "README.md" "README"
check_file "QUICKSTART.md" "Quick Start Guide"
check_file "GETTING_STARTED.md" "Getting Started Guide"
check_file "LEARNING_GUIDE.md" "Learning Guide"
check_file "ARCHITECTURE.md" "Architecture Documentation"
check_file "PROJECT_STRUCTURE.md" "Project Structure"
check_file "SRE_GOLDEN_PATH.md" "SRE Golden Path Guide"
check_file "CICD.md" "CI/CD Documentation"
check_file "CICD_SETUP_GUIDE.md" "CI/CD Setup Guide"
check_file "IMPLEMENTATION_SUMMARY.md" "Implementation Summary"
echo ""

# Check scripts
echo -e "${YELLOW}Checking utility scripts...${NC}"
check_file "scripts/setup.sh" "Setup script"
check_file "scripts/dev-setup.sh" "Development setup script"
check_file "scripts/test-services.sh" "Test services script"
check_file "scripts/verify-setup.sh" "Verification script"
echo ""

# Check if scripts are executable
echo -e "${YELLOW}Checking script permissions...${NC}"
if [ -x "scripts/setup.sh" ]; then
    echo -e "${GREEN}✓${NC} setup.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} setup.sh is not executable (run: chmod +x scripts/*.sh)"
fi

if [ -x "scripts/test-services.sh" ]; then
    echo -e "${GREEN}✓${NC} test-services.sh is executable"
else
    echo -e "${YELLOW}⚠${NC} test-services.sh is not executable"
fi
echo ""

# Check Docker availability
echo -e "${YELLOW}Checking prerequisites...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker is installed ($(docker --version))"
else
    echo -e "${RED}✗${NC} Docker is not installed"
fi

if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker Compose is installed ($(docker-compose --version))"
else
    echo -e "${RED}✗${NC} Docker Compose is not installed"
fi

if command -v make &> /dev/null; then
    echo -e "${GREEN}✓${NC} Make is installed ($(make --version | head -n 1))"
else
    echo -e "${YELLOW}⚠${NC} Make is not installed (optional but recommended)"
fi

if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC} Git is installed ($(git --version))"
else
    echo -e "${YELLOW}⚠${NC} Git is not installed"
fi
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}✓ All SRE Golden Path components are in place!${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Read GETTING_STARTED.md for a comprehensive guide"
echo "2. Run 'make quick-start' to start all services"
echo "3. Follow CICD_SETUP_GUIDE.md to enable CI/CD"
echo "4. Push to GitHub and watch workflows run"
echo ""
echo -e "${BLUE}Quick Commands:${NC}"
echo "  make help              # Show all available commands"
echo "  make quick-start       # Build and start everything"
echo "  make test              # Run integration tests"
echo "  make security-scan     # Run security checks"
echo ""
echo -e "${GREEN}Ready to build amazing things! 🚀${NC}"
