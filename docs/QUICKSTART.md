# CloudOps Command Center - Quick Start Guide 🚀

## 🎯 What You Built

A comprehensive **DevOps/SRE learning platform** with 7 microservices simulating real-world cloud operations!

## Services Running

1. **Cost Optimizer** (8001) - Cloud cost analysis & optimization
2. **K8s Manager** (8002) - Kubernetes cluster management
3. **Incident Manager** (8003) - Incident tracking & response
4. **Automation Service** (8004) - CI/CD & infrastructure automation
5. **ChatOps Bot** (8005) - Chat-based operations
6. **Metrics Collector** (8006) - Cross-service analytics
7. **Auth Service** (8007) 🔐 **NEW!** - Authentication & user management

## 🔐 First: Login Required!

**Access Dashboard:** http://localhost:3000

**Default Credentials:**
- Username: `admin`
- Password: `admin123`

> ⚠️ Change this password immediately after first login!

## 🚀 Quick Test

```bash
# Test all services
./test-services.sh

# Or test individually:
curl http://localhost:8001/costs/summary | jq
curl http://localhost:8002/clusters | jq
curl http://localhost:8003/incidents/stats/summary | jq
curl http://localhost:8004/pipelines | jq
curl http://localhost:8005/commands | jq
curl http://localhost:8006/metrics/summary | jq
```

## 📖 Interactive API Docs

- Cost Optimizer: http://localhost:8001/docs
- K8s Manager: http://localhost:8002/docs
- Incident Manager: http://localhost:8003/docs
- Automation: http://localhost:8004/docs
- ChatOps: http://localhost:8005/docs
- Metrics: http://localhost:8006/docs
- Auth Service: http://localhost:8007/docs 🔐

## 🎓 Learning Paths

### 1. Cost Optimization (FinOps)
```bash
curl http://localhost:8001/costs/summary | jq
curl http://localhost:8001/recommendations | jq
curl http://localhost:8001/budget/alerts | jq
curl http://localhost:8001/forecast | jq
```

### 2. Kubernetes Operations
```bash
curl http://localhost:8002/clusters | jq
curl http://localhost:8002/pods | jq
curl http://localhost:8002/recommendations | jq
curl -X POST "http://localhost:8002/deployments/default/frontend/scale?replicas=5"
```

### 3. Incident Management
```bash
curl http://localhost:8003/incidents | jq
curl http://localhost:8003/oncall | jq
curl http://localhost:8003/sla/compliance | jq
curl -X POST "http://localhost:8003/incidents?title=API%20Down&severity=critical&service=api" | jq
```

### 4. CI/CD Automation
```bash
curl http://localhost:8004/pipelines | jq
curl http://localhost:8004/deployments/stats/summary | jq
curl -X POST "http://localhost:8004/pipelines/trigger?pipeline_name=backend&environment=staging" | jq
```

### 5. ChatOps Commands
```bash
curl -X POST http://localhost:8005/commands/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "/status", "user": "you", "channel": "ops"}' | jq
```

### 6. Metrics & Analytics
```bash
curl http://localhost:8006/dashboards | jq
curl http://localhost:8006/analytics/trends | jq
curl http://localhost:8006/metrics/compare | jq
```

### 7. Authentication & User Management 🔐
```bash
# Login
curl -X POST http://localhost:8007/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq

# Get current user (requires token)
TOKEN="your-jwt-token-here"
curl http://localhost:8007/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq

# List all users (admin only)
curl http://localhost:8007/users \
  -H "Authorization: Bearer $TOKEN" | jq

# Create new user (admin only)
curl -X POST http://localhost:8007/auth/register \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "user@example.com",
    "password": "password123",
    "full_name": "New User",
    "role": "user"
  }' | jq
```

## 🛠️ Common Commands

```bash
# Start
docker-compose up -d

# Logs
docker-compose logs -f [service-name]

# Restart
docker-compose restart [service-name]

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

## ✨ Next Steps

1. Explore all endpoints in Swagger UI docs
2. Add security pipeline (already configured!)
3. Build React dashboard frontend
4. Add PostgreSQL for persistence
5. Connect to real cloud APIs
6. Integrate with real K8s clusters

## 🎉 What You Learned

✅ Microservices architecture
✅ FastAPI backend development
✅ Docker containerization
✅ RESTful API design
✅ DevOps/SRE patterns
✅ Cost optimization strategies
✅ Kubernetes operations
✅ Incident management workflows
✅ CI/CD automation
✅ Observability and metrics

**Start exploring!** Open http://localhost:8001/docs and dive in! 🚀
