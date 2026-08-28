# Getting Started with Synapse

Welcome! This guide will help you get Synapse running and explain the SRE golden path practices implemented.

## Prerequisites

- **Docker**: 20.10+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose**: 2.0+ ([Install Compose](https://docs.docker.com/compose/install/))
- **Git**: For version control
- **Make** (optional): For convenience commands

## Quick Start (5 Minutes)

### Option 1: Using Make (Recommended)

```bash
# Clone the repository
git clone <your-repo-url>
cd Synapse

# Quick start - builds and starts everything
make quick-start
```

### Option 2: Using Scripts

```bash
# Setup and start all services
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Option 3: Manual Docker Compose

```bash
# Build and start services
docker-compose up -d

# Check health
docker-compose ps
```

## Accessing the Application

Once started, access:

- **📊 Dashboard**: http://localhost:3000
- **📚 Service Registry API**: http://localhost:8001/docs
- **💚 Health Checker API**: http://localhost:8002/docs
- **📈 Metrics Collector API**: http://localhost:8003/docs
- **🚨 Alert Manager API**: http://localhost:8004/docs

## First Steps

### 1. Register Your First Service

**Via UI:**
1. Go to http://localhost:3000/services
2. Click "Register Service"
3. Fill in the form
4. Watch it appear on the dashboard

**Via API:**
```bash
curl -X POST http://localhost:8001/register \
  -H "Content-Type: application/json" \
  -d '{
    "service_name": "my-api",
    "service_url": "http://httpbin.org",
    "health_check_endpoint": "/status/200",
    "check_interval": 30
  }'
```

### 2. View Metrics

Go to http://localhost:3000/metrics and select your service to see:
- Response time graph
- Uptime percentage
- P95/P99 percentiles

### 3. Create Alerts

Go to http://localhost:3000/alerts and create a rule to get notified when:
- Response time exceeds threshold
- Error rate increases
- Service goes down

## Project Structure

```
Synapse/
├── services/              # Backend microservices (Python)
│   ├── service-registry/
│   ├── health-checker/
│   ├── metrics-collector/
│   └── alert-manager/
├── frontend/              # React dashboard
├── .github/
│   └── workflows/         # CI/CD pipelines
├── scripts/               # Utility scripts
└── docs/                  # Documentation
```

## SRE Golden Path Features

### ✅ What's Implemented

1. **Individual Dockerfiles** for each service
2. **Reusable GitHub Actions workflows** for CI/CD
3. **Security scanning** (Trivy, Bandit, npm audit)
4. **Health checks** at container and application level
5. **Automated testing** (unit, integration, performance)
6. **Dependency management** (Dependabot)
7. **Code quality** (linting, formatting)
8. **Observability** (metrics, health endpoints)
9. **Documentation** (comprehensive guides)
10. **Container security** (non-root users, minimal images)

### 📋 CI/CD Pipeline

Every service has:
- **Linting**: Code quality checks
- **Security scanning**: Vulnerability detection
- **Testing**: Automated tests
- **Container building**: Multi-arch images
- **Container scanning**: Trivy security scan
- **Health validation**: Endpoint testing
- **Notifications**: Slack alerts (optional)

### 🔒 Security Best Practices

- ✅ Non-root container execution
- ✅ Minimal base images (python-slim, alpine)
- ✅ No secrets in images
- ✅ Automated security scanning
- ✅ Dependency vulnerability checks
- ✅ SARIF integration with GitHub Security

## Common Commands

### Using Make

```bash
make help              # Show all available commands
make up                # Start services
make down              # Stop services
make logs              # View logs
make health-check      # Check service health
make test              # Run integration tests
make clean             # Remove everything
```

### Using Docker Compose

```bash
docker-compose up -d           # Start in background
docker-compose down            # Stop services
docker-compose ps              # List services
docker-compose logs -f         # Follow logs
docker-compose restart         # Restart all
```

### Using Scripts

```bash
./scripts/setup.sh             # Setup and start
./scripts/test-services.sh     # Run tests
./scripts/dev-setup.sh         # Local development setup
```

## Development Workflow

### Local Development

1. **Start dependencies**:
   ```bash
   docker run -d --name redis -p 6379:6379 redis:7-alpine
   ```

2. **Setup Python environment** (per service):
   ```bash
   cd services/service-registry
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   python main.py
   ```

3. **Run frontend**:
   ```bash
   cd frontend
   npm install
   npm start
   ```

### Making Changes

1. **Create a branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes**

3. **Test locally**:
   ```bash
   make test
   make lint-python
   make security-scan
   ```

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: add my feature"
   git push origin feature/my-feature
   ```

5. **Create Pull Request**:
   - CI/CD runs automatically
   - All checks must pass
   - Request review

### CI/CD Workflow

```
Push to GitHub
    ↓
Trigger GitHub Actions
    ↓
Lint & Test → Build Image → Security Scan → Health Check
    ↓
✅ Pass → Merge to main → Deploy
❌ Fail → Fix issues → Push again
```

## Understanding the Architecture

### Service Communication

```
Frontend (React)
    ↓ HTTP REST
Service Registry ← Health Checker → Metrics Collector → Alert Manager
    ↓                   ↓                   ↓                 ↓
         Redis (Pub/Sub, Data Storage, Caching)
```

### Data Flow

1. **Registration**: Service registers with Service Registry
2. **Discovery**: Health Checker discovers new service
3. **Monitoring**: Health Checker performs periodic checks
4. **Collection**: Metrics Collector aggregates data
5. **Alerting**: Alert Manager evaluates rules and sends notifications

## Troubleshooting

### Services won't start

```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs service-registry

# Restart services
make restart
```

### Port conflicts

```bash
# Check what's using a port
lsof -i :8001

# Kill process
kill -9 <PID>
```

### Redis connection errors

```bash
# Check Redis
docker ps | grep redis

# Test Redis
docker exec synapse-redis redis-cli ping
```

### Build failures

```bash
# Clean and rebuild
make clean
make build
```

## Learning Path

### Day 1: Basics
- ✅ Get it running
- ✅ Register a service
- ✅ View metrics and alerts
- ✅ Explore the dashboard

### Day 2: Architecture
- 📖 Read [ARCHITECTURE.md](ARCHITECTURE.md)
- 📖 Read [LEARNING_GUIDE.md](LEARNING_GUIDE.md)
- 🔧 Explore API documentation
- 🔍 Inspect service code

### Day 3: DevOps/SRE
- 📖 Read [SRE_GOLDEN_PATH.md](SRE_GOLDEN_PATH.md)
- 📖 Read [CICD.md](CICD.md)
- 🔄 Examine GitHub Actions workflows
- 🔒 Review security practices

### Day 4: Hands-on
- 💻 Follow exercises in LEARNING_GUIDE.md
- 🛠️ Make a small change
- 🧪 Add a test
- 📦 Build and run locally

### Day 5: Advanced
- 🚀 Add a new feature
- 🔧 Extend a service
- 📊 Add custom metrics
- 🔔 Configure alerts

## Best Practices

### When Adding Features

1. **Start with tests**: Write failing tests first
2. **Implement minimally**: Just enough to pass tests
3. **Refactor**: Clean up code
4. **Document**: Update relevant docs
5. **Test thoroughly**: Unit + integration tests
6. **Security check**: Run security scans
7. **Create PR**: Let CI/CD validate

### Code Quality

- **Format**: `make format-python` before committing
- **Lint**: Fix all linting errors
- **Type hints**: Use Python type hints
- **Docstrings**: Document complex functions
- **Comments**: Explain *why*, not *what*

### Security

- **Never commit secrets**: Use environment variables
- **Scan dependencies**: `make security-scan`
- **Keep updated**: Let Dependabot create PRs
- **Review carefully**: Check security scan results

## Getting Help

### Documentation

- [README.md](README.md) - Project overview
- [QUICKSTART.md](QUICKSTART.md) - 5-minute setup
- [LEARNING_GUIDE.md](LEARNING_GUIDE.md) - In-depth concepts
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- [SRE_GOLDEN_PATH.md](SRE_GOLDEN_PATH.md) - SRE practices
- [CICD.md](CICD.md) - CI/CD details
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - File organization

### Commands

```bash
make help              # Show all available commands
docker-compose ps      # Check service status
docker-compose logs -f # Watch logs
```

### Debugging

1. Check service logs
2. Test health endpoints
3. Verify Redis connectivity
4. Review error messages
5. Check port availability

## What's Next?

### Immediate
- ✅ Get familiar with the dashboard
- ✅ Register test services
- ✅ Create alert rules
- ✅ View metrics

### Short-term
- 📚 Read all documentation
- 🎓 Complete learning exercises
- 🛠️ Make small changes
- 🧪 Write tests

### Long-term
- 🚀 Add new features
- 🏗️ Deploy to cloud
- 🔄 Set up CI/CD for your fork
- 🎨 Customize for your use case

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Create a Pull Request

## Resources

- [Google SRE Book](https://sre.google/books/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Ready to dive in?** Start with `make quick-start` and explore! 🚀
