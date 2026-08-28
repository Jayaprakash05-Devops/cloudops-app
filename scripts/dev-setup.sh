#!/bin/bash

echo "🛠️  Setting up Synapse for local development"

# Setup Python services
echo "📦 Setting up Python virtual environments..."

services=("service-registry" "health-checker" "metrics-collector" "alert-manager")

for service in "${services[@]}"; do
    echo "Setting up $service..."
    cd "services/$service"
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate
    cd ../..
done

# Setup frontend
echo "📦 Setting up frontend..."
cd frontend
npm install
cd ..

# Setup Redis
echo "🔧 Starting Redis with Docker..."
docker run -d --name synapse-redis -p 6379:6379 redis:7-alpine

echo ""
echo "✅ Development setup complete!"
echo ""
echo "To run services individually:"
echo ""
echo "Redis:"
echo "  docker start synapse-redis"
echo ""
echo "Backend services:"
echo "  cd services/service-registry && source venv/bin/activate && python main.py"
echo "  cd services/health-checker && source venv/bin/activate && python main.py"
echo "  cd services/metrics-collector && source venv/bin/activate && python main.py"
echo "  cd services/alert-manager && source venv/bin/activate && python main.py"
echo ""
echo "Frontend:"
echo "  cd frontend && npm start"
