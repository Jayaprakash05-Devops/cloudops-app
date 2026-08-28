#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  CloudOps Command Center Setup${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

# Check Docker Compose
echo -e "${YELLOW}Checking Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is installed${NC}"

# Stop any existing containers
echo ""
echo -e "${YELLOW}Cleaning up old containers...${NC}"
docker-compose down -v 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete${NC}"

# Build and start services
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Building and Starting Services${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}This may take a few minutes...${NC}"
echo ""

if docker-compose up -d --build; then
    echo ""
    echo -e "${GREEN}✓ All services started successfully!${NC}"
else
    echo ""
    echo -e "${RED}✗ Failed to start services${NC}"
    exit 1
fi

# Wait for services to be healthy
echo ""
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 10

# Check service health
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Service Health Check${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

check_service() {
    local name=$1
    local port=$2
    if curl -sf http://localhost:${port}/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name (http://localhost:${port})"
        return 0
    else
        echo -e "${RED}✗${NC} $name (http://localhost:${port})"
        return 1
    fi
}

check_service "Cost Optimizer      " 8001
check_service "K8s Manager         " 8002
check_service "Incident Manager    " 8003
check_service "Automation Service  " 8004
check_service "ChatOps Bot         " 8005
check_service "Metrics Collector   " 8006

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Quick Start${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}CloudOps Command Center is running!${NC}"
echo ""
echo -e "${YELLOW}📊 API Documentation:${NC}"
echo "   Cost Optimizer:      http://localhost:8001/docs"
echo "   K8s Manager:         http://localhost:8002/docs"
echo "   Incident Manager:    http://localhost:8003/docs"
echo "   Automation Service:  http://localhost:8004/docs"
echo "   ChatOps Bot:         http://localhost:8005/docs"
echo "   Metrics Collector:   http://localhost:8006/docs"
echo ""
echo -e "${YELLOW}🔍 Test the services:${NC}"
echo "   ./test-services.sh"
echo ""
echo -e "${YELLOW}📝 View logs:${NC}"
echo "   docker-compose logs -f [service-name]"
echo ""
echo -e "${YELLOW}🛑 Stop all services:${NC}"
echo "   docker-compose down"
echo ""
echo -e "${GREEN}Happy learning! 🚀${NC}"
