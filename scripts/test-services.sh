#!/bin/bash

echo "🧪 Testing Synapse Services"

BASE_URL="http://localhost:8001"

# Test 1: Register a test service
echo "📝 Test 1: Registering a test service..."
response=$(curl -s -X POST "$BASE_URL/register" \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "test-api",
    "service_url": "http://example.com",
    "health_check_endpoint": "/health",
    "check_interval": 30
  }')

echo "Response: $response"
service_id=$(echo $response | grep -o '"service_id":"[^"]*"' | cut -d'"' -f4)
echo "✅ Service registered with ID: $service_id"

# Test 2: List all services
echo ""
echo "📋 Test 2: Listing all services..."
curl -s "$BASE_URL/services" | python3 -m json.tool

# Test 3: Get specific service
echo ""
echo "🔍 Test 3: Getting service details..."
curl -s "$BASE_URL/services/$service_id" | python3 -m json.tool

# Test 4: Create an alert rule
echo ""
echo "🚨 Test 4: Creating an alert rule..."
curl -s -X POST "http://localhost:8004/rules" \
  -H "Content-Type: application/json" \
  -d "{
    \"service_id\": \"$service_id\",
    \"metric_type\": \"response_time\",
    \"condition\": \"gt\",
    \"threshold\": 1.0,
    \"severity\": \"warning\",
    \"notification_channels\": [\"console\"]
  }" | python3 -m json.tool

# Test 5: List alert rules
echo ""
echo "📋 Test 5: Listing alert rules..."
curl -s "http://localhost:8004/rules" | python3 -m json.tool

# Test 6: Health check of all services
echo ""
echo "💚 Test 6: Health check of all services..."
services=("8001:Service Registry" "8002:Health Checker" "8003:Metrics Collector" "8004:Alert Manager")

for service in "${services[@]}"; do
    IFS=':' read -r port name <<< "$service"
    health=$(curl -s "http://localhost:$port/health")
    echo "$name: $health"
done

echo ""
echo "✨ Testing complete!"
echo ""
echo "To clean up the test service, run:"
echo "curl -X DELETE \"$BASE_URL/services/$service_id\""
