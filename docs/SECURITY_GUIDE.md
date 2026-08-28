# Security Best Practices Guide

This guide covers the comprehensive security measures implemented in Synapse following the security-first approach.

## 🔒 Security-First Pipeline

Our CI/CD pipeline implements security at every stage:

```
┌──────────────────────┐
│  1. Checkout          │
│  - Secure repository  │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  2. Validate          │
│  - Commit checks      │
│  - File validation    │
│  - Secrets detection  │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  3. Dependencies      │
│  - Install            │
│  - Dependency audit   │
│  - Lock-file check    │
│  - SBOM generation    │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  4. Code Quality      │
│  - Formatter          │
│  - Linter             │
│  - Static analysis    │
│  - Complexity check   │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  5. Security Scan     │
│  - SAST               │
│  - SCA                │
│  - Secret scanning    │
│  - IaC scanning       │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  6. Build             │
│  - Compile            │
│  - Package            │
│  - Docker image       │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  7. Container Scan    │
│  - Image scanning     │
│  - Vulnerability check│
│  - SBOM generation    │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  8. Test              │
│  - Unit tests         │
│  - Coverage check     │
│  - Health validation  │
└──────────────────────┘
```

## Security Tools Matrix

### Python Backend Services

| Stage | Tool | Purpose | Severity |
|-------|------|---------|----------|
| Validate | TruffleHog | Secret detection | Critical |
| Validate | GitLeaks | Credential scanning | Critical |
| Dependencies | Safety | Vulnerability scanning | High |
| Dependencies | pip-audit | CVE detection | High |
| Dependencies | CycloneDX | SBOM generation | Medium |
| Code Quality | Black | Code formatting | Low |
| Code Quality | Flake8 | Linting | Medium |
| Code Quality | Pylint | Static analysis | Medium |
| Code Quality | mypy | Type checking | Low |
| Code Quality | Radon | Complexity analysis | Low |
| Security | Bandit | SAST for Python | High |
| Security | Semgrep | SAST multi-language | High |
| Security | Checkov | IaC security | Medium |
| Container | Trivy | Container scanning | Critical |

### Frontend (JavaScript/React)

| Stage | Tool | Purpose | Severity |
|-------|------|---------|----------|
| Validate | TruffleHog | Secret detection | Critical |
| Validate | GitLeaks | Credential scanning | Critical |
| Dependencies | npm audit | Vulnerability scanning | High |
| Dependencies | Snyk | Dependency security | High |
| Dependencies | RetireJS | Outdated libraries | Medium |
| Dependencies | license-checker | License compliance | Low |
| Code Quality | ESLint | Linting | Medium |
| Code Quality | Prettier | Formatting | Low |
| Code Quality | complexity-report | Complexity | Low |
| Code Quality | jscpd | Duplication | Low |
| Security | Semgrep | SAST | High |
| Security | ESLint Security | Security patterns | High |
| Security | OWASP Dep-Check | Vulnerability DB | High |
| Container | Trivy | Container scanning | Critical |
| Performance | Lighthouse CI | Performance/A11y | Medium |

## 🛡️ Security Stages Explained

### Stage 1: Checkout
Standard secure checkout from version control.

### Stage 2: Validate

#### Commit Message Validation
Ensures conventional commit format:
```
type(scope): description

Examples:
feat(auth): add JWT authentication
fix(api): resolve CORS issue
sec(deps): update vulnerable package
```

#### File Validation
- Checks for large files (>10MB blocked)
- Detects binary files in wrong locations
- Validates file extensions

#### Secret Detection
**Tools**: TruffleHog, GitLeaks

Detects:
- API keys and tokens
- Passwords and credentials
- Private keys
- Database connection strings
- AWS/GCP/Azure credentials

**Example findings**:
```
❌ AWS_SECRET_KEY=AKIAIOSFODNN7EXAMPLE
❌ password="admin123"
❌ private_key = "-----BEGIN RSA PRIVATE KEY-----"
```

### Stage 3: Dependencies

#### Dependency Installation
```bash
# Python
pip install -r requirements.txt

# JavaScript
npm ci  # Uses lock file for reproducible builds
```

#### Version Pinning Check
Ensures all dependencies have exact versions:
```
✓ fastapi==0.104.1
✗ fastapi>=0.100.0
```

#### Vulnerability Scanning

**Python - Safety**:
```bash
safety check --json
```
Checks against PyUp safety database.

**Python - pip-audit**:
```bash
pip-audit --desc
```
Cross-references with OSV, PyPI Advisory Database.

**JavaScript - npm audit**:
```bash
npm audit --json
```
Checks npm registry for known vulnerabilities.

**JavaScript - Snyk**:
```bash
snyk test
```
Commercial-grade vulnerability database.

**JavaScript - RetireJS**:
```bash
retire --js --node
```
Detects outdated JavaScript libraries.

#### SBOM Generation
Creates Software Bill of Materials in CycloneDX format:
```bash
# Python
cyclonedx-py -r -i requirements.txt -o sbom.json

# JavaScript
cyclonedx-npm --output-file sbom.json
```

**Why SBOM?**
- Supply chain security
- License compliance
- Vulnerability tracking
- Audit trails

### Stage 4: Code Quality

#### Python

**Black** - Code formatting:
```bash
black --check main.py
```

**isort** - Import sorting:
```bash
isort --check-only main.py
```

**Flake8** - Linting:
```bash
flake8 main.py --max-line-length=120 --max-complexity=10
```

**Pylint** - Static analysis:
```bash
pylint main.py --reports=y --score=y
```

**mypy** - Type checking:
```bash
mypy main.py --strict
```

**Radon** - Complexity metrics:
```bash
# Cyclomatic Complexity
radon cc main.py -a -s

# Maintainability Index
radon mi main.py -s

# Raw metrics (LOC, comments, etc.)
radon raw main.py -s
```

#### JavaScript

**ESLint** - Linting:
```bash
eslint src/ --format json
```

**Prettier** - Formatting:
```bash
prettier --check "src/**/*.js"
```

**Complexity** - Cyclomatic complexity:
```bash
cr src/**/*.js
```

**jscpd** - Copy-paste detection:
```bash
jscpd src/
```

### Stage 5: Security Scanning

#### SAST (Static Application Security Testing)

**Bandit** (Python):
```bash
bandit -r main.py -f json
```

Detects:
- SQL injection vectors
- Command injection
- Hardcoded passwords
- Weak cryptography
- Unsafe YAML loading
- XXE vulnerabilities

**Semgrep** (Multi-language):
```bash
semgrep --config=auto src/
```

Detects:
- OWASP Top 10 issues
- Security anti-patterns
- CWE violations
- Custom security rules

**ESLint Security** (JavaScript):
```bash
eslint --plugin security src/
```

Detects:
- eval() usage
- Unsafe RegEx
- Insecure randomness
- XSS vectors

#### SCA (Software Composition Analysis)
Done in Stage 3 (Dependencies)

#### IaC Security

**Checkov** (Dockerfile, docker-compose):
```bash
checkov -f Dockerfile
```

Checks:
- Root user usage
- Exposed ports
- HEALTHCHECK presence
- USER instruction
- COPY --chown
- Latest tag usage

### Stage 6: Build

#### Python Services
```bash
# Dependencies installed
pip install -r requirements.txt

# Application packaged in Docker
docker build -t service:tag .
```

#### Frontend
```bash
# Install dependencies
npm ci

# Run tests with coverage
npm test -- --coverage

# Build optimized production bundle
npm run build
```

**Bundle Size Check**:
- Warns if build >5MB
- Analyzes largest files
- Tracks size over time

### Stage 7: Container Scanning

**Trivy** - Comprehensive scanner:
```bash
# Filesystem scan
trivy fs --severity CRITICAL,HIGH,MEDIUM .

# Image scan
trivy image --severity CRITICAL,HIGH service:tag
```

Detects:
- OS vulnerabilities (Alpine, Debian, etc.)
- Application dependencies (Python, Node)
- Config issues
- Exposed secrets

**Output formats**:
- SARIF → GitHub Security
- JSON → Reports
- Table → Human readable

**SBOM for containers**:
```bash
trivy image --format cyclonedx service:tag
```

### Stage 8: Testing

#### Unit Tests
```bash
# Python
pytest --cov --cov-report=xml

# JavaScript
npm test -- --coverage
```

#### Coverage Enforcement
Typical thresholds:
- Statements: 80%
- Branches: 75%
- Functions: 80%
- Lines: 80%

#### Health Validation
```bash
# Start container
docker run -d -p 8001:8001 service:tag

# Test health endpoint
curl -f http://localhost:8001/health

# Verify returns 200 OK
```

## 🔐 Pre-commit Hooks

Local security checks before every commit:

### Setup
```bash
pip install pre-commit
pre-commit install
```

### What Gets Checked
- ✅ Secret detection (detect-secrets, gitleaks)
- ✅ Large file detection (>10MB)
- ✅ Merge conflict markers
- ✅ Private key detection
- ✅ YAML/JSON syntax
- ✅ Python formatting (Black)
- ✅ Python linting (Flake8)
- ✅ Python security (Bandit)
- ✅ Import sorting (isort)
- ✅ Type hints (mypy)
- ✅ Dockerfile linting (hadolint)
- ✅ Commit message format

### Example Session
```bash
$ git commit -m "feat: add new feature"

Detect secrets.......................................................Passed
Check for added large files.........................................Passed
Check for merge conflicts............................................Passed
Check yaml..........................................................Passed
Black...............................................................Passed
Flake8..............................................................Passed
Bandit..............................................................Passed
```

## 🚨 Security Alerts

### GitHub Security Features

#### 1. Code Scanning (SARIF)
All security tools report to GitHub Security:
- Bandit results
- Semgrep findings
- Trivy vulnerabilities

**View**: Repository → Security → Code scanning

#### 2. Dependabot Alerts
Automatic alerts for:
- Python package vulnerabilities
- npm package vulnerabilities
- Docker base image CVEs

**View**: Repository → Security → Dependabot alerts

#### 3. Secret Scanning
GitHub automatically scans for:
- API keys
- OAuth tokens
- Private keys

**View**: Repository → Security → Secret scanning

### Severity Levels

| Level | Response Time | Action |
|-------|---------------|--------|
| Critical | Immediate | Block deployment, hotfix |
| High | 24 hours | Fix before next release |
| Medium | 1 week | Plan fix in sprint |
| Low | Next cycle | Fix when convenient |

## 📊 Security Reports

### Artifacts Generated

Each CI/CD run produces:

**Dependency Reports**:
- `safety-report.json` - Python vulnerabilities
- `pip-audit-report.json` - Python CVEs
- `npm-audit-report.json` - JavaScript vulnerabilities
- `snyk-report.json` - Commercial scan results
- `sbom.json` - Software Bill of Materials

**Code Quality Reports**:
- `flake8-report.json` - Linting issues
- `pylint-report.json` - Static analysis
- `eslint-report.json` - JavaScript linting
- `radon-*.json` - Complexity metrics

**Security Reports**:
- `bandit-report.json` - Python security issues
- `bandit.sarif` - SARIF format for GitHub
- `semgrep-report.json` - Multi-language security
- `checkov-dockerfile.json` - IaC security
- `trivy-image-report.json` - Container vulnerabilities

**Reports retained for 90 days**

### Viewing Reports

1. **GitHub Actions UI**:
   - Go to Actions → Select workflow run
   - Scroll to Artifacts section
   - Download reports

2. **GitHub Security Tab**:
   - Auto-uploaded SARIF reports
   - Integrated with code view
   - Track over time

3. **Local Development**:
   ```bash
   make security-scan  # Run all scans locally
   ```

## 🔧 Local Security Testing

### Run Full Security Suite
```bash
# Backend service
cd services/service-registry
make security-scan

# Frontend
cd frontend
npm audit
npm run lint
```

### Individual Scans

**Secret Detection**:
```bash
pip install detect-secrets
detect-secrets scan --baseline .secrets.baseline
```

**Dependency Scan**:
```bash
pip install safety pip-audit
safety check
pip-audit
```

**Code Security**:
```bash
pip install bandit
bandit -r main.py
```

**Container Scan**:
```bash
docker build -t test .
trivy image test
```

## 🎯 Security Checklist

### Before Committing
- [ ] No hardcoded secrets
- [ ] Dependencies updated
- [ ] Pre-commit hooks pass
- [ ] Tests pass locally
- [ ] No large files added

### Before Pull Request
- [ ] Branch rebased on main
- [ ] All CI checks pass
- [ ] Security scans clean
- [ ] Documentation updated
- [ ] Conventional commit messages

### Before Deployment
- [ ] Code reviewed (2+ approvals)
- [ ] Security team approval (for sensitive changes)
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Rollback plan documented

## 🚀 Security Best Practices

### Development

1. **Never commit secrets**
   ```bash
   # Wrong
   API_KEY = "abc123"

   # Right
   API_KEY = os.getenv("API_KEY")
   ```

2. **Validate all inputs**
   ```python
   from pydantic import BaseModel, validator

   class UserInput(BaseModel):
       email: EmailStr
       age: int

       @validator('age')
       def age_valid(cls, v):
           if v < 0 or v > 150:
               raise ValueError('Invalid age')
           return v
   ```

3. **Use parameterized queries**
   ```python
   # Wrong - SQL injection risk
   query = f"SELECT * FROM users WHERE id = {user_id}"

   # Right
   query = "SELECT * FROM users WHERE id = %s"
   cursor.execute(query, (user_id,))
   ```

### Docker

1. **Never run as root**
   ```dockerfile
   # Create and use non-root user
   RUN useradd -m -u 1000 appuser
   USER appuser
   ```

2. **Use specific versions**
   ```dockerfile
   # Wrong
   FROM python:latest

   # Right
   FROM python:3.11-slim
   ```

3. **Multi-stage builds**
   ```dockerfile
   FROM node:18 AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci
   COPY . .
   RUN npm run build

   FROM nginx:alpine
   COPY --from=builder /app/build /usr/share/nginx/html
   ```

### Dependencies

1. **Pin exact versions**
   ```txt
   # Wrong
   fastapi>=0.100.0

   # Right
   fastapi==0.104.1
   ```

2. **Regular updates**
   ```bash
   # Check for updates
   pip list --outdated
   npm outdated

   # Update with care
   pip install --upgrade package==version
   npm update
   ```

3. **Review Dependabot PRs**
   - Check changelog
   - Run tests
   - Merge promptly

## 📚 Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Secure Software Development Framework](https://csrc.nist.gov/Projects/ssdf)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Python Security Best Practices](https://python.readthedocs.io/en/stable/library/security.html)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

---

**Remember**: Security is not a one-time task, it's an ongoing practice! 🔒
