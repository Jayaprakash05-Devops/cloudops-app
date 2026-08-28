# CI/CD Documentation

## Overview

Synapse uses GitHub Actions for continuous integration and deployment, following SRE best practices with reusable workflows.

## Workflow Architecture

```
Individual Service Workflows (Callers)
          ↓
Reusable Workflows (Templates)
          ↓
Jobs: Lint → Test → Build → Scan → Deploy
```

## Reusable Workflows

### Backend Services (`reusable-backend-ci.yml`)

**Purpose**: Standardized CI/CD for Python/FastAPI services

**Inputs**:
- `service-name`: Service identifier
- `service-path`: Path to service directory
- `port`: Service port for health checks
- `python-version`: Python version (default: 3.11)
- `registry`: Container registry (default: ghcr.io)

**Secrets**:
- `REGISTRY_USERNAME`: Container registry username
- `REGISTRY_TOKEN`: Container registry token
- `SLACK_WEBHOOK`: Slack webhook for notifications

**Jobs**:
1. **lint-and-test**
   - Black code formatting check
   - Flake8 linting
   - Pylint static analysis
   - Bandit security scanning
   - Safety dependency vulnerability scan
   - Upload security reports

2. **build-and-push**
   - Docker multi-arch build with BuildKit
   - Push to container registry
   - Trivy container security scan
   - Upload SARIF to GitHub Security
   - Test container health

3. **notify**
   - Send Slack notification with results

### Frontend (`reusable-frontend-ci.yml`)

**Purpose**: Standardized CI/CD for React applications

**Inputs**:
- `node-version`: Node.js version (default: 18)
- `registry`: Container registry (default: ghcr.io)

**Jobs**:
1. **lint-and-test**
   - ESLint code quality checks
   - Jest unit tests with coverage
   - Production build
   - Bundle size analysis

2. **security-scan**
   - npm audit for vulnerabilities
   - Upload audit reports

3. **build-and-push**
   - Multi-stage Docker build
   - Push optimized nginx image
   - Trivy security scan
   - Test container health

4. **lighthouse**
   - Lighthouse CI performance testing
   - Web vitals tracking

## Service Workflows

### Triggers

All service workflows trigger on:
- **Push** to `main` or `develop` branches (when service files change)
- **Pull Request** to `main` or `develop` (when service files change)
- **Manual** dispatch via GitHub UI

### Path Filtering

Each workflow only runs when relevant files change:
```yaml
paths:
  - 'services/service-name/**'
  - '.github/workflows/service-name.yml'
  - '.github/workflows/reusable-backend-ci.yml'
```

### Example: Service Registry Workflow

```yaml
name: Service Registry CI/CD

on:
  push:
    branches: [main, develop]
    paths:
      - 'services/service-registry/**'
  pull_request:
    branches: [main, develop]
  workflow_dispatch:

jobs:
  ci-cd:
    uses: ./.github/workflows/reusable-backend-ci.yml
    with:
      service-name: service-registry
      service-path: services/service-registry
      port: '8001'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_TOKEN: ${{ secrets.REGISTRY_TOKEN }}
```

## Integration Tests

### Workflow: `integration-tests.yml`

**Purpose**: End-to-end testing of all services together

**Triggers**:
- Push to main/develop
- Pull requests
- Manual dispatch
- **Scheduled**: Daily at 2 AM UTC

**Test Scenarios**:
1. Start all services with Docker Compose
2. Wait for health checks to pass
3. Test service registration flow
4. Verify health monitoring
5. Check metrics collection
6. Test alert rules creation
7. Validate API documentation endpoints

**Performance Tests**:
- k6 load testing
- Response time thresholds (p95 < 500ms)
- Error rate thresholds (< 10%)
- Sustained load simulation

## Container Registry

### GitHub Container Registry (ghcr.io)

**Authentication**:
```yaml
- name: Log in to Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

**Image Naming**:
```
ghcr.io/<owner>/synapse-<service-name>:<tag>
```

**Tags Strategy**:
- `latest` - Latest build from main branch
- `<branch>-<sha>` - Branch name + commit SHA
- `v1.2.3` - Semantic version tags
- `main`, `develop` - Branch tags

## Security Scanning

### Trivy Container Scanning

Scans for:
- OS vulnerabilities
- Application dependencies
- Misconfigurations
- Secrets in images

**Configuration**:
```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ghcr.io/owner/synapse-service:sha
    format: 'sarif'
    severity: 'CRITICAL,HIGH'
```

### Bandit Security Scanning (Python)

Static analysis for common security issues:
- SQL injection
- Command injection
- Hardcoded secrets
- Weak cryptography

### npm Audit (Frontend)

Checks for known vulnerabilities in npm packages.

## Secrets Management

### Required Secrets

**Optional** (for full functionality):
- `REGISTRY_USERNAME` - Container registry username (uses github.actor if not set)
- `REGISTRY_TOKEN` - Container registry token (uses GITHUB_TOKEN if not set)
- `SLACK_WEBHOOK` - Slack webhook URL for notifications

**Automatic**:
- `GITHUB_TOKEN` - Auto-provided by GitHub Actions

### Setting Secrets

```bash
# Organization level
Settings → Secrets and variables → Actions → New organization secret

# Repository level
Settings → Secrets and variables → Actions → New repository secret
```

## Branch Protection

### Recommended Rules

**Main Branch**:
- ✅ Require pull request reviews (1+ approvals)
- ✅ Require status checks to pass
  - All service CI/CD workflows
  - Integration tests
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ✅ Require signed commits
- ✅ Include administrators

**Develop Branch**:
- ✅ Require status checks to pass
- ⚠️ Allow force pushes (for rebasing)

## Deployment Strategies

### Current: Docker Compose

**Environment**: Local/Development
```bash
docker-compose up -d
```

### Future: Kubernetes

**Planned Deployment Flow**:
```
Git Push → CI Build → Image Push → ArgoCD/Flux → K8s Deploy
```

**Deployment Types**:
1. **Rolling Update**: Gradual replacement of old pods
2. **Blue-Green**: Switch between two environments
3. **Canary**: Gradual traffic shift to new version

## Monitoring CI/CD

### Key Metrics

**DORA Metrics**:
- **Deployment Frequency**: How often we deploy
- **Lead Time for Changes**: Commit to production time
- **Time to Restore**: Recovery time after failure
- **Change Failure Rate**: % of deployments causing failure

**CI/CD Health**:
- Build success rate
- Average build time
- Test coverage percentage
- Security vulnerability count
- Artifact size

### GitHub Insights

View metrics at:
- Actions → Workflow runs
- Insights → Actions
- Security → Code scanning alerts

## Troubleshooting

### Build Failures

**Python Linting Errors**:
```bash
# Fix locally
black services/service-name/main.py
flake8 services/service-name/main.py
```

**Container Build Fails**:
```bash
# Test build locally
cd services/service-name
docker build -t test .
```

**Health Check Fails**:
```bash
# Test service locally
docker run -p 8001:8001 test
curl http://localhost:8001/health
```

### Workflow Not Triggering

Check:
1. Path filters match changed files
2. Branch name matches trigger configuration
3. Workflow file is in `.github/workflows/`
4. YAML syntax is valid

### Permission Errors

Ensure workflow has correct permissions:
```yaml
permissions:
  contents: read
  packages: write
  security-events: write
```

## Best Practices

### ✅ Do

- Keep workflows DRY using reusable workflows
- Use path filters to avoid unnecessary runs
- Cache dependencies for faster builds
- Run expensive tests (integration, e2e) less frequently
- Set appropriate timeouts
- Upload artifacts for debugging
- Use continue-on-error for non-blocking checks

### ❌ Don't

- Store secrets in code or environment variables
- Run all tests on every commit
- Build without caching
- Push images on pull requests
- Deploy from feature branches
- Skip security scans

## Maintenance

### Regular Tasks

**Weekly**:
- Review failed workflows
- Check build times
- Monitor cache hit rates

**Monthly**:
- Update GitHub Actions versions
- Review security scan results
- Optimize workflow performance

**Quarterly**:
- Review and update CI/CD documentation
- Evaluate new GitHub Actions features
- Assess DORA metrics trends

## Local Testing

### Test Docker Builds

```bash
# Build specific service
cd services/service-registry
docker build -t synapse-service-registry:test .

# Test multi-stage frontend build
cd frontend
docker build -t synapse-frontend:test .
```

### Test Scripts

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Test integration locally
./scripts/test-services.sh
```

### Validate Workflows

```bash
# Install act (GitHub Actions local runner)
brew install act  # macOS
# or
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act -W .github/workflows/service-registry.yml
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Trivy Scanner](https://github.com/aquasecurity/trivy)
- [Reusable Workflows Guide](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
