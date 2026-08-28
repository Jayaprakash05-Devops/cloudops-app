#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  CloudOps Command Center Test Suite${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

test_endpoint() {
    local service=$1
    local port=$2
    local endpoint=$3
    local description=$4

    echo -e "${YELLOW}Testing: ${description}${NC}"
    response=$(curl -s -w "\n%{http_code}" http://localhost:${port}${endpoint})
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ ${service} - ${description} [200]${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}✗ ${service} - ${description} [${http_code}]${NC}"
    fi
    echo ""
}

# Cost Optimizer Service
echo -e "${BLUE}=== Cost Optimizer Service (Port 8001) ===${NC}"
test_endpoint "Cost Optimizer" 8001 "/" "Service Info"
test_endpoint "Cost Optimizer" 8001 "/costs/summary" "Cost Summary"
test_endpoint "Cost Optimizer" 8001 "/recommendations/summary" "Recommendations"
test_endpoint "Cost Optimizer" 8001 "/budget/alerts" "Budget Alerts"

# K8s Manager Service
echo -e "${BLUE}=== K8s Manager Service (Port 8002) ===${NC}"
test_endpoint "K8s Manager" 8002 "/" "Service Info"
test_endpoint "K8s Manager" 8002 "/clusters" "Clusters"
test_endpoint "K8s Manager" 8002 "/namespaces" "Namespaces"
test_endpoint "K8s Manager" 8002 "/recommendations" "K8s Recommendations"

# Incident Manager Service
echo -e "${BLUE}=== Incident Manager Service (Port 8003) ===${NC}"
test_endpoint "Incident Manager" 8003 "/" "Service Info"
test_endpoint "Incident Manager" 8003 "/incidents/stats/summary" "Incident Stats"
test_endpoint "Incident Manager" 8003 "/oncall" "On-Call Schedule"
test_endpoint "Incident Manager" 8003 "/sla/compliance" "SLA Compliance"

# Automation Service
echo -e "${BLUE}=== Automation Service (Port 8004) ===${NC}"
test_endpoint "Automation Service" 8004 "/" "Service Info"
test_endpoint "Automation Service" 8004 "/pipelines" "Pipelines"
test_endpoint "Automation Service" 8004 "/deployments/stats/summary" "Deployment Stats"
test_endpoint "Automation Service" 8004 "/jobs" "Scheduled Jobs"

# ChatOps Bot Service
echo -e "${BLUE}=== ChatOps Bot Service (Port 8005) ===${NC}"
test_endpoint "ChatOps Bot" 8005 "/" "Service Info"
test_endpoint "ChatOps Bot" 8005 "/commands" "Available Commands"
test_endpoint "ChatOps Bot" 8005 "/integrations" "Integrations"
test_endpoint "ChatOps Bot" 8005 "/stats" "Bot Stats"

# Metrics Collector Service
echo -e "${BLUE}=== Metrics Collector Service (Port 8006) ===${NC}"
test_endpoint "Metrics Collector" 8006 "/" "Service Info"
test_endpoint "Metrics Collector" 8006 "/metrics/summary" "Metrics Summary"
test_endpoint "Metrics Collector" 8006 "/analytics/trends" "Trends"
test_endpoint "Metrics Collector" 8006 "/dashboards" "Dashboards"

# Auth Service
echo -e "${BLUE}=== Auth Service (Port 8007) ===${NC}"
test_endpoint "Auth Service" 8007 "/health" "Health Check"
echo -e "${YELLOW}Testing: User Login${NC}"
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:8007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Auth Service - User Login [200]${NC}"
    echo "$body" | jq '.' 2>/dev/null || echo "$body"
else
    echo -e "${RED}✗ Auth Service - User Login [${http_code}]${NC}"
fi
echo ""

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✓ Test suite completed!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${YELLOW}Explore the interactive API docs at:${NC}"
echo "  http://localhost:8001/docs (Cost Optimizer)"
echo "  http://localhost:8002/docs (K8s Manager)"
echo "  http://localhost:8003/docs (Incident Manager)"
echo "  http://localhost:8004/docs (Automation)"
echo "  http://localhost:8005/docs (ChatOps Bot)"
echo "  http://localhost:8006/docs (Metrics Collector)"
echo "  http://localhost:8007/docs (Auth Service)"
echo ""
echo -e "${YELLOW}Default Admin Credentials:${NC}"
echo "  Username: admin"
echo "  Password: admin123"
