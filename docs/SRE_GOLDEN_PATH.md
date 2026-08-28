# SRE Golden Path

This document outlines the SRE practices and golden path implemented in Synapse.

## What is the Golden Path?

The "Golden Path" is a standardized, well-supported way of building and operating services that follows SRE best practices. It reduces cognitive load, increases consistency, and improves reliability across all services.

## Our Golden Path Components

### 1. Standardized Service Structure

All backend services follow the same structure:
```
services/<service-name>/
├── Dockerfile          # Individual, optimized Dockerfile
├── main.py             # FastAPI application
├── requirements.txt    # Python dependencies
└── tests/             # Unit and integration tests
```

### 2. Containerization Best Practices

#### Multi-stage Builds (Frontend)
- Build stage for compilation
- Production stage with minimal runtime
- Reduced image size and attack surface

#### Security Hardening
- Non-root user execution
- Minimal base images (alpine, slim)
- Security labels and metadata
- Health checks built-in

#### Image Optimization
- Layer caching optimization
- Dependencies installed before code copy
- .dockerignore to exclude unnecessary files
- Proper cleanup of package managers

### 3. CI/CD Pipeline (GitHub Actions)

#### Reusable Workflows
We use **workflow composition** to avoid duplication:
- `reusable-backend-ci.yml` - Shared backend pipeline
- `reusable-frontend-ci.yml` - Shared frontend pipeline
- Individual service workflows call reusable ones with parameters

#### Pipeline Stages

**Backend Services:**
1. **Lint & Test**
   - Code formatting (Black)
   - Linting (Flake8)
   - Static analysis (Pylint)
   - Security scanning (Bandit)
   - Dependency vulnerabilities (Safety)
   - Unit tests (pytest with coverage)

2. **Build & Push**
   - Docker image build with BuildKit
   - Multi-architecture support ready
   - Tag management (semver, SHA, branch)
   - Push to GitHub Container Registry
   - Build caching for faster builds

3. **Security Scanning**
   - Container scanning (Trivy)
   - SARIF upload to GitHub Security
   - Critical/High vulnerability detection

4. **Health Testing**
   - Container health check validation
   - API endpoint testing
   - Log collection

5. **Notification**
   - Slack notifications (optional)
   - Build status reporting

**Frontend:**
1. **Lint, Test & Build**
   - ESLint for code quality
   - Unit tests with coverage
   - Production build
   - Bundle size analysis

2. **Security Scan**
   - npm audit for vulnerabilities
   - Dependency scanning

3. **Build & Push**
   - Multi-stage Docker build
   - Optimized nginx production image
   - Container scanning

4. **Performance**
   - Lighthouse CI for performance metrics
   - Web vitals tracking

### 4. Observability from Day One

#### Logging
- Structured JSON logs (ready to add)
- Log levels (DEBUG, INFO, WARNING, ERROR)
- Request ID tracking
- stdout/stderr capture by Docker

#### Metrics
- Built-in `/health` endpoints
- Response time tracking
- Error rate monitoring
- Custom metrics via Metrics Collector service

#### Tracing
- Ready for OpenTelemetry integration
- Request correlation IDs

#### Monitoring
- Health checks at multiple levels:
  - Container health checks
  - Kubernetes liveness/readiness probes (ready)
  - Application-level health endpoints

### 5. Testing Strategy

#### Pyramid Approach
```
        ╱╲
       ╱E2E╲        <- Integration tests (daily)
      ╱──────╲
     ╱ Contract ╲   <- API contract tests
    ╱────────────╲
   ╱     Unit      ╲ <- Unit tests (on every commit)
  ╱────────────────╲
```

**Test Types:**
- **Unit Tests**: Fast, isolated, extensive coverage
- **Integration Tests**: Service interactions, daily runs
- **Performance Tests**: Load testing with k6
- **Security Tests**: Automated scanning in CI

### 6. Security Best Practices

#### Container Security
- ✅ Non-root user execution
- ✅ Minimal base images
- ✅ No secrets in images
- ✅ Security scanning in CI
- ✅ Signed images (ready)
- ✅ Vulnerability scanning (Trivy)

#### Code Security
- ✅ Static analysis (Bandit)
- ✅ Dependency scanning (Safety, npm audit)
- ✅ SARIF integration with GitHub Security
- ✅ Automated security updates (Dependabot)

#### API Security (Ready to Add)
- [ ] JWT authentication
- [ ] Rate limiting
- [ ] CORS configuration
- [ ] API keys for service-to-service
- [ ] HTTPS/TLS everywhere

### 7. Deployment Practices

#### GitOps
- Infrastructure as Code (Docker Compose, ready for K8s)
- Version control for all configs
- Automated deployments from main branch
- Branch protection rules

#### Release Strategy
- **Semantic Versioning**: major.minor.patch
- **Trunk-based Development**: Short-lived branches
- **Progressive Rollouts**: Ready for canary/blue-green
- **Rollback Capability**: Tagged images for quick revert

#### Environments
```
develop branch  → Dev environment
main branch     → Staging → Production
tags (v*)       → Production releases
```

### 8. Service Level Objectives (SLOs)

#### Availability SLOs
- **Service Registry**: 99.9% uptime
- **Health Checker**: 99.9% uptime
- **Metrics Collector**: 99.5% uptime
- **Alert Manager**: 99.9% uptime
- **Frontend**: 99.9% uptime

#### Performance SLOs
- **API Latency**: p95 < 100ms, p99 < 500ms
- **Health Check**: Complete in < 5 seconds
- **Metrics Collection**: < 60 second delay
- **Alert Evaluation**: < 30 second delay

#### Error Budget
- 99.9% = ~43 minutes downtime/month
- 99.5% = ~3.6 hours downtime/month

### 9. Incident Response

#### On-Call Rotation (Ready)
- Integration with PagerDuty/OpsGenie
- Alert routing via Alert Manager
- Runbooks for common issues

#### Incident Process
1. **Detection**: Automated alerts
2. **Response**: On-call engineer paged
3. **Investigation**: Logs, metrics, traces
4. **Mitigation**: Rollback or hotfix
5. **Resolution**: Root cause analysis
6. **Learning**: Postmortem document

### 10. Documentation Standards

#### Service Documentation
- README.md in each service
- API documentation (OpenAPI/Swagger)
- Architecture decision records (ADRs)
- Runbooks for operations

#### Code Documentation
- Docstrings for complex functions
- Inline comments for non-obvious logic
- Architecture diagrams
- API contract specifications

## Golden Path Checklist

When creating a new service, ensure:

- [ ] Follows standard directory structure
- [ ] Has individual Dockerfile with security best practices
- [ ] Includes health check endpoint
- [ ] Has unit tests (>80% coverage goal)
- [ ] Has integration tests
- [ ] Implements structured logging
- [ ] Exposes Prometheus metrics (or equivalent)
- [ ] Has CI/CD workflow configured
- [ ] Container security scanning enabled
- [ ] Documentation complete (README, API docs)
- [ ] Monitoring alerts configured
- [ ] Load testing performed
- [ ] Security review completed
- [ ] Runbook created

## Continuous Improvement

### Regular Reviews
- **Weekly**: CI/CD metrics, build times, test flakiness
- **Monthly**: Security scan results, dependency updates
- **Quarterly**: SLO review, incident retrospectives, golden path improvements

### Metrics We Track
- Build success rate
- Build time
- Deployment frequency
- Lead time for changes
- Time to recovery
- Change failure rate
- Test coverage
- Security vulnerabilities

### Automation Goals
- Zero-touch deployments
- Automated rollbacks on failure
- Self-healing services
- Automated capacity scaling
- Automated security patching

## Tools in the Golden Path

### Development
- Python 3.11+ with type hints
- FastAPI for APIs
- React for frontends
- Docker for containerization

### CI/CD
- GitHub Actions for pipelines
- GitHub Container Registry for images
- GitHub Security for vulnerability management

### Testing
- pytest for Python
- Jest for JavaScript
- k6 for load testing
- Trivy for security scanning

### Observability (Current + Planned)
- Synapse built-in monitoring
- Prometheus (planned)
- Grafana (planned)
- Loki (planned)
- Jaeger/Tempo (planned)

### Infrastructure
- Docker Compose (local/dev)
- Kubernetes (production, planned)
- Terraform (IaC, planned)
- Helm (K8s package manager, planned)

## Migration to Golden Path

### For Existing Services
1. Add Dockerfile following template
2. Add GitHub Actions workflow
3. Implement health check endpoint
4. Add unit tests
5. Configure monitoring
6. Create runbook
7. Security audit and fixes

### For New Services
1. Copy template from existing service
2. Customize for specific needs
3. Follow golden path checklist
4. Review with team
5. Deploy to dev environment
6. Run through all CI/CD stages
7. Deploy to production

## Benefits of Our Golden Path

✅ **Consistency**: All services look and behave similarly
✅ **Reliability**: Built-in best practices reduce outages
✅ **Security**: Automated scanning and hardening
✅ **Speed**: Reusable workflows accelerate development
✅ **Observability**: Monitoring from day one
✅ **Quality**: Automated testing catches issues early
✅ **Compliance**: Security and audit requirements met
✅ **Developer Experience**: Less cognitive load, more focus on features

## References

- [Google SRE Book](https://sre.google/books/)
- [The Phoenix Project](https://itrevolution.com/the-phoenix-project/)
- [Accelerate](https://itrevolution.com/accelerate-book/)
- [DORA Metrics](https://www.devops-research.com/research.html)
- [12 Factor App](https://12factor.net/)

---

**Remember**: The golden path is not restrictive—it's a starting point. Deviate when necessary, but document why.
