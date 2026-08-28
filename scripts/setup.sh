#!/bin/bash

echo "🚀 Setting up Synapse - Cloud Service Health Monitor"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Build and start services
echo "📦 Building and starting services..."
docker-compose up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
services=("service-registry:8001" "health-checker:8002" "metrics-collector:8003" "alert-manager:8004")

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -s "http://localhost:$port/health" > /dev/null; then
        echo "✅ $name is healthy"
    else
        echo "⚠️  $name is not responding yet"
    fi
done

echo ""
echo "✨ Synapse is running!"
echo ""
echo "📊 Access the dashboard: http://localhost:3000"
echo "📚 API Documentation:"
echo "   - Service Registry: http://localhost:8001/docs"
echo "   - Health Checker: http://localhost:8002/docs"
echo "   - Metrics Collector: http://localhost:8003/docs"
echo "   - Alert Manager: http://localhost:8004/docs"
echo ""
echo "🛑 To stop all services: docker-compose down"
