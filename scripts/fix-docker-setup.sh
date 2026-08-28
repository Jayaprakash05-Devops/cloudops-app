#!/bin/bash

# Docker connectivity troubleshooting script

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Docker Connectivity Troubleshooting${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Test Docker connectivity
echo -e "${YELLOW}Testing Docker Hub connectivity...${NC}"

# Test basic connectivity
if ping -c 3 hub.docker.com > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Can reach hub.docker.com"
else
    echo -e "${RED}✗${NC} Cannot reach hub.docker.com"
    echo -e "${YELLOW}This might be a network/firewall issue${NC}"
fi

# Test Docker daemon
echo ""
echo -e "${YELLOW}Checking Docker daemon...${NC}"
if docker ps > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is not running"
    exit 1
fi

# Check current images
echo ""
echo -e "${YELLOW}Checking for existing images...${NC}"
if docker images | grep -q "python.*3.11"; then
    echo -e "${GREEN}✓${NC} Python 3.11 image found locally"
else
    echo -e "${YELLOW}⚠${NC} Python 3.11 image not found, will need to pull"
fi

if docker images | grep -q "node.*18"; then
    echo -e "${GREEN}✓${NC} Node 18 image found locally"
else
    echo -e "${YELLOW}⚠${NC} Node 18 image not found, will need to pull"
fi

# Try to pull images with timeout
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Attempting to Pull Base Images${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

pull_image() {
    local image=$1
    echo -e "${YELLOW}Pulling $image...${NC}"
    if timeout 120 docker pull $image; then
        echo -e "${GREEN}✓${NC} Successfully pulled $image"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to pull $image"
        return 1
    fi
}

# Pull images one by one
pull_image "python:3.11-slim"
pull_image "node:18-alpine"
pull_image "nginx:alpine"
pull_image "redis:7-alpine"

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

if docker images | grep -q "python.*3.11" && docker images | grep -q "node.*18"; then
    echo -e "${GREEN}✓ All base images are ready${NC}"
    echo ""
    echo -e "${YELLOW}Now try running:${NC}"
    echo "  docker-compose up -d --build"
else
    echo -e "${RED}⚠ Some images failed to pull${NC}"
    echo ""
    echo -e "${YELLOW}Possible solutions:${NC}"
    echo "1. Check your internet connection"
    echo "2. Check if you're behind a proxy/firewall"
    echo "3. Try using a VPN if Docker Hub is blocked"
    echo "4. Configure Docker to use a mirror"
    echo "5. Try again later (Docker Hub might be down)"
    echo ""
    echo -e "${YELLOW}To configure Docker mirror (if in China):${NC}"
    echo "  # Edit /etc/docker/daemon.json"
    echo "  {"
    echo "    \"registry-mirrors\": [\"https://mirror.gcr.io\"]"
    echo "  }"
    echo "  # Then restart Docker"
fi
