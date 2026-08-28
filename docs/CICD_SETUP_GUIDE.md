# CI/CD Setup Guide

This guide helps you configure GitHub Actions CI/CD for Synapse.

## What's Already Done ✅

The following CI/CD components are already configured in your repository:

### 1. Individual Dockerfiles
- ✅ `services/service-registry/Dockerfile`
- ✅ `services/health-checker/Dockerfile`
- ✅ `services/metrics-collector/Dockerfile`
- ✅ `services/alert-manager/Dockerfile`
- ✅ `frontend/Dockerfile`

Each with:
- Non-root user execution
- Health checks
- Security labels
- Optimized layer caching

### 2. Reusable Workflows
- ✅ `.github/workflows/reusable-backend-ci.yml` - Backend pipeline
- ✅ `.github/workflows/reusable-frontend-ci.yml` - Frontend pipeline

### 3. Service Workflows
- ✅ `.github/workflows/service-registry.yml`
- ✅ `.github/workflows/health-checker.yml`
- ✅ `.github/workflows/metrics-collector.yml`
- ✅ `.github/workflows/alert-manager.yml`
- ✅ `.github/workflows/frontend.yml`
- ✅ `.github/workflows/integration-tests.yml`

### 4. Configuration Files
- ✅ `.github/dependabot.yml` - Automated dependency updates
- ✅ `.github/CODEOWNERS` - Code ownership rules
- ✅ `.dockerignore` files - Build optimization
- ✅ `Makefile` - Common operations
- ✅ `frontend/nginx.conf` - Production nginx config

### 5. Documentation
- ✅ `SRE_GOLDEN_PATH.md` - SRE best practices
- ✅ `CICD.md` - CI/CD documentation
- ✅ `GETTING_STARTED.md` - Comprehensive guide

## Setup Steps

### Step 1: Push to GitHub

If you haven't already:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Initial commit
git commit -m "Initial commit with SRE golden path"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/Synapse.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 2: Enable GitHub Actions

1. Go to your GitHub repository
2. Click **Settings** → **Actions** → **General**
3. Under "Actions permissions", select:
   - ✅ **Allow all actions and reusable workflows**
4. Under "Workflow permissions", select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**
5. Click **Save**

### Step 3: Configure Container Registry

GitHub Container Registry (ghcr.io) is automatically available.

**No additional setup needed!** The workflows use `GITHUB_TOKEN` automatically.

To view your images:
1. Go to your GitHub profile
2. Click **Packages**
3. You'll see `synapse-*` packages after first build

### Step 4: Configure Secrets (Optional)

For enhanced functionality, add these secrets:

#### Slack Notifications (Optional)

1. Create a Slack webhook:
   - Go to https://api.slack.com/apps
   - Create a new app → Incoming Webhooks
   - Activate and create webhook URL

2. Add to GitHub:
   - Settings → Secrets and variables → Actions
   - Click **New repository secret**
   - Name: `SLACK_WEBHOOK`
   - Value: Your webhook URL

#### Alternative Container Registry (Optional)

If using Docker Hub or another registry:

1. Settings → Secrets and variables → Actions
2. Add secrets:
   - `REGISTRY_USERNAME`: Your username
   - `REGISTRY_TOKEN`: Your access token

3. Update workflows to use custom registry:
   ```yaml
   with:
     registry: 'docker.io'  # or other registry
   ```

### Step 5: Configure Branch Protection (Recommended)

1. Go to Settings → Branches
2. Click **Add rule**
3. Branch name pattern: `main`
4. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1+)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
5. Select status checks:
   - ✅ ci-cd (from each service workflow)
   - ✅ integration-tests
6. Save changes

### Step 6: Test the Pipelines

#### Method 1: Make a Change

```bash
# Create a branch
git checkout -b test-ci

# Make a small change
echo "# Testing CI/CD" >> services/service-registry/README.md
git add .
git commit -m "test: verify CI/CD pipeline"

# Push and create PR
git push -u origin test-ci
```

Then:
1. Go to GitHub → Pull Requests
2. Create a pull request
3. Watch CI/CD run automatically
4. All checks should pass ✅

#### Method 2: Manual Trigger

1. Go to Actions tab
2. Select a workflow (e.g., "Service Registry CI/CD")
3. Click "Run workflow"
4. Select branch and run

### Step 7: Enable Dependabot

Dependabot is automatically enabled with the config file.

To verify:
1. Go to Settings → Code security and analysis
2. Ensure **Dependabot alerts** is enabled
3. Ensure **Dependabot security updates** is enabled

You'll start receiving PRs for dependency updates every Monday.

### Step 8: Configure Code Scanning (Optional but Recommended)

1. Go to Settings → Code security and analysis
2. Click **Set up** next to "Code scanning"
3. Select **Trivy** or **CodeQL**
4. Results will appear in Security → Code scanning

## Workflow Triggers

### Automatic Triggers

**On Push to main/develop**:
- Only when service files change
- All relevant service workflows run
- Integration tests run

**On Pull Request**:
- All checks run
- Results visible in PR
- Must pass before merge

**Daily at 2 AM UTC**:
- Integration tests run
- Performance tests run
- Results emailed if failed

### Manual Triggers

1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow"

## Monitoring CI/CD

### View Workflow Runs

1. Go to **Actions** tab
2. See all workflow runs
3. Click on a run to see details
4. View logs for each job

### View Build Status

Add badges to README:

```markdown
![Service Registry](https://github.com/USERNAME/Synapse/actions/workflows/service-registry.yml/badge.svg)
![Health Checker](https://github.com/USERNAME/Synapse/actions/workflows/health-checker.yml/badge.svg)
![Metrics Collector](https://github.com/USERNAME/Synapse/actions/workflows/metrics-collector.yml/badge.svg)
![Alert Manager](https://github.com/USERNAME/Synapse/actions/workflows/alert-manager.yml/badge.svg)
![Frontend](https://github.com/USERNAME/Synapse/actions/workflows/frontend.yml/badge.svg)
```

### View Container Images

1. Go to your profile → Packages
2. See all published images
3. Click on image for details
4. View versions and security scans

### View Security Alerts

1. Go to Security tab
2. Click **Code scanning alerts**
3. View Trivy scan results
4. Click on alerts for details

## Troubleshooting

### Workflow Not Running

**Check**:
- Is GitHub Actions enabled?
- Does branch match trigger pattern?
- Do changed files match path filters?
- Is YAML syntax valid?

**Solution**:
```bash
# Test YAML locally
yamllint .github/workflows/

# Manual trigger
# Go to Actions → Select workflow → Run workflow
```

### Build Failures

**Linting Errors**:
```bash
# Fix locally
make format-python
make lint-python
```

**Security Scan Failures**:
```bash
# Check locally
make security-scan

# Update dependencies
pip install --upgrade package-name
```

**Container Build Failures**:
```bash
# Test locally
cd services/service-name
docker build -t test .
```

### Permission Errors

**Error**: "Resource not accessible by integration"

**Solution**:
1. Settings → Actions → General
2. Workflow permissions → Read and write
3. Save

### Rate Limiting

**Error**: "API rate limit exceeded"

**Solution**:
- Use `GITHUB_TOKEN` (automatic, higher limits)
- Or create a Personal Access Token with higher limits

## Best Practices

### Commits

```bash
# Use conventional commits
feat: add new feature
fix: resolve bug
docs: update documentation
test: add tests
ci: update CI/CD
chore: maintenance tasks
```

### Pull Requests

1. Create from feature branch
2. Write clear description
3. Ensure all checks pass
4. Request review
5. Address feedback
6. Merge when approved

### Secrets

- ❌ Never commit secrets
- ✅ Use GitHub Secrets
- ✅ Use environment variables
- ✅ Rotate regularly

### Branches

```
main      → Production
develop   → Staging
feature/* → Development
hotfix/*  → Emergency fixes
```

## Advanced Configuration

### Custom Registry

Edit workflows to use Docker Hub:

```yaml
with:
  registry: 'docker.io'
```

Add secrets:
- `REGISTRY_USERNAME`: Docker Hub username
- `REGISTRY_TOKEN`: Docker Hub access token

### Deployment to Kubernetes

Add to workflows:

```yaml
- name: Deploy to K8s
  run: |
    kubectl set image deployment/service-registry \
      service-registry=${{ steps.meta.outputs.tags }}
```

### Slack Notifications

Add `SLACK_WEBHOOK` secret, workflows automatically use it.

### Custom Tests

Add to workflow:

```yaml
- name: Run custom tests
  run: |
    pytest tests/ --cov --cov-report=xml
```

## Maintenance

### Weekly

- [ ] Review failed workflows
- [ ] Check build times
- [ ] Monitor cache hit rates

### Monthly

- [ ] Update GitHub Actions versions
- [ ] Review security scan results
- [ ] Merge Dependabot PRs
- [ ] Update documentation

### Quarterly

- [ ] Review DORA metrics
- [ ] Optimize workflow performance
- [ ] Update CI/CD strategy
- [ ] Team retrospective

## Checklist

Setup checklist for a new fork:

- [ ] Push code to GitHub
- [ ] Enable GitHub Actions
- [ ] Configure workflow permissions
- [ ] Set up branch protection (main)
- [ ] Enable Dependabot
- [ ] Enable code scanning
- [ ] Add `SLACK_WEBHOOK` secret (optional)
- [ ] Test workflows with a PR
- [ ] Add status badges to README
- [ ] Configure notifications
- [ ] Document custom changes

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)
- [Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)

## Getting Help

If you encounter issues:

1. Check workflow logs in Actions tab
2. Review this guide
3. Read [CICD.md](CICD.md) for details
4. Check [GitHub Actions documentation](https://docs.github.com/en/actions)
5. Create an issue with:
   - Error message
   - Workflow run link
   - Steps to reproduce

---

**Ready to go!** Your CI/CD pipelines are configured and ready to use. 🚀
