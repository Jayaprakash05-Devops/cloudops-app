# 🚀 How to Integrate CloudOps with Real Data

## ⚡ Quick Start: 15-Minute AWS Integration

The **easiest and most valuable** integration is AWS costs. Here's how:

### Step 1: Get AWS Credentials (5 minutes)

```bash
# Create IAM user
aws iam create-user --user-name cloudops-cost-reader

# Attach Cost Explorer policy
aws iam attach-user-policy \
  --user-name cloudops-cost-reader \
  --policy-arn arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess

# Create access keys
aws iam create-access-key --user-name cloudops-cost-reader
# Save the Access Key ID and Secret Access Key!
```

### Step 2: Configure Service (5 minutes)

```bash
cd services/cost-optimizer

# Install boto3
pip install boto3
echo "boto3==1.34.0" >> requirements.txt

# Set environment variables
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_REGION="us-east-1"

# Add to .env file
cat >> ../../.env << 'ENVEOF'
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
ENVEOF
```

### Step 3: Test Integration (5 minutes)

```bash
# Test the example script
python aws_integration_example.py

# You should see:
# === Monthly Cost ===
# {'total_cost': 1234.56, 'currency': 'USD', ...}
#
# === Top 5 Services ===
# Amazon EC2: $456.78 (37.0%)
# Amazon S3: $234.12 (19.0%)
# ...
```

### Step 4: Update docker-compose.yml

```yaml
services:
  cost-optimizer:
    environment:
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
```

### Step 5: Restart Service

```bash
docker-compose restart cost-optimizer

# Test the new endpoint
curl http://localhost:8001/costs/aws/real | jq
```

**🎉 Done! You now have real AWS cost data!**

---

## 📊 All Available Integrations

### 1. Cloud Cost Tracking ☁️
**Services:** AWS, GCP, Azure  
**Time:** 15-30 minutes each  
**Value:** ⭐⭐⭐⭐⭐ (Highest!)

- Real cloud spending
- Cost trends
- Service breakdowns
- Forecasting

**Guide:** `INTEGRATION_GUIDE.md` Section 1

---

### 2. Kubernetes Clusters ☸️
**Services:** EKS, GKE, AKS, Docker Desktop  
**Time:** 20 minutes  
**Value:** ⭐⭐⭐⭐

- Real cluster data
- Live pod status
- Actual deployments
- Scale operations

**Guide:** `INTEGRATION_GUIDE.md` Section 2

---

### 3. CI/CD Pipelines 🚀
**Services:** GitHub Actions, GitLab CI, Jenkins  
**Time:** 15 minutes  
**Value:** ⭐⭐⭐⭐

- Real pipeline runs
- Build status
- Deployment history
- Trigger workflows

**Guide:** `INTEGRATION_GUIDE.md` Section 3

---

### 4. Incident Management 🚨
**Services:** PagerDuty, OpsGenie  
**Time:** 30 minutes  
**Value:** ⭐⭐⭐

- Real incidents
- On-call schedules
- Create/update incidents
- SLA tracking

**Guide:** `INTEGRATION_GUIDE.md` Section 4

---

### 5. ChatOps 💬
**Services:** Slack, Discord, MS Teams  
**Time:** 30 minutes  
**Value:** ⭐⭐⭐

- Slash commands
- Notifications
- Interactive workflows
- Real-time updates

**Guide:** `INTEGRATION_GUIDE.md` Section 5

---

### 6. Monitoring 📊
**Services:** Prometheus, Grafana  
**Time:** 30 minutes  
**Value:** ⭐⭐⭐

- Real metrics
- Performance data
- Alerts
- Custom queries

**Guide:** `INTEGRATION_GUIDE.md` Section 6

---

## 🗂️ Documentation Files

### **INTEGRATION_GUIDE.md** (📖 Complete Guide)
**What's in it:**
- Step-by-step integration for all services
- Code examples for each integration
- Security best practices
- Environment variables
- Testing procedures
- Troubleshooting

**When to use:** When you want detailed, comprehensive integration instructions

---

### **QUICK_INTEGRATION_EXAMPLES.md** (⚡ Quick Wins)
**What's in it:**
- 30-minute quick start guides
- AWS (15 min)
- GitHub (10 min)
- Kubernetes (5 min)
- Copy-paste code examples
- Testing commands

**When to use:** When you want to integrate something FAST

---

### **aws_integration_example.py** (💻 Working Code)
**What's in it:**
- Complete, working AWS integration
- Monthly costs
- Service breakdown
- Daily trends
- Forecasting
- Ready to use!

**When to use:** When you want to copy-paste and run

---

### **INTEGRATION_SUMMARY.md** (📋 Overview)
**What's in it:**
- Integration priority order
- Required packages
- Environment variables
- Checklists
- Common issues

**When to use:** Quick reference and planning

---

## 🎯 Recommended Order

### **Phase 1: Read-Only (Week 1)**
Start with these - safest, highest value:

1. ✅ **AWS Costs** (15 min) - See real spending
2. ✅ **GitHub Actions** (15 min) - See real pipelines
3. ✅ **Kubernetes** (20 min) - See real clusters

**Risk:** Low (read-only)  
**Value:** High  
**Time:** 1 hour total

---

### **Phase 2: Read-Only Cloud (Week 2)**
Add more cloud providers:

4. ☁️ **GCP Costs** (20 min) - If using GCP
5. ☁️ **Azure Costs** (20 min) - If using Azure
6. 📊 **Prometheus** (30 min) - Real metrics

**Risk:** Low (read-only)  
**Value:** Medium-High  
**Time:** 1-2 hours

---

### **Phase 3: Write Operations (Week 3)**
Add operations that make changes:

7. 🚀 **Trigger GitHub Workflows** (15 min)
8. 🔄 **Scale K8s Deployments** (15 min)
9. 🚨 **Create PagerDuty Incidents** (30 min)

**Risk:** Medium (can make changes)  
**Value:** High  
**Time:** 1 hour

---

### **Phase 4: ChatOps (Week 4)**
Add chat integrations:

10. 💬 **Slack Bot** (30 min)
11. 💬 **Discord Bot** (30 min)
12. 📊 **Webhooks** (20 min)

**Risk:** Low  
**Value:** Medium  
**Time:** 1-2 hours

---

## 🔐 Security Checklist

Before integrating:

- [ ] Create dedicated service accounts (not your personal account)
- [ ] Use minimum required permissions (principle of least privilege)
- [ ] Store credentials in environment variables (not in code)
- [ ] Add .env to .gitignore (don't commit secrets!)
- [ ] Use secrets management (AWS Secrets Manager, HashiCorp Vault)
- [ ] Enable audit logging (CloudTrail, etc.)
- [ ] Rotate credentials every 90 days
- [ ] Use HTTPS for all API calls
- [ ] Validate API responses
- [ ] Handle errors gracefully (don't expose secrets in errors)

---

## 🧪 Testing Your Integration

### 1. Test Credentials Locally

```bash
# AWS
aws sts get-caller-identity

# GitHub
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Kubernetes
kubectl get nodes

# PagerDuty
curl -H "Authorization: Token token=$PAGERDUTY_API_KEY" \
  https://api.pagerduty.com/users
```

### 2. Test Python Code

```bash
cd services/cost-optimizer
python aws_integration_example.py
```

### 3. Test Service Endpoint

```bash
# Start service
docker-compose up -d cost-optimizer

# Test endpoint
curl http://localhost:8001/costs/aws/real | jq
```

### 4. Check Dashboard

```bash
# Open dashboard
open http://localhost:3000

# Navigate to Cost Optimizer page
# Should see real AWS data!
```

---

## 💰 Integration Costs

### AWS Cost Explorer
- First API call: FREE
- Additional calls: $0.01 per request
- Expected: $0.30 - $3.00/month

### GitHub API
- Authenticated: 5,000 requests/hour
- Cost: FREE

### Kubernetes API
- Your own cluster: FREE
- Cost: $0.00

### Other Services
- Most APIs: FREE for basic usage
- Premium features: Check provider pricing

**Total:** $0.30 - $10/month (depending on usage)

---

## 🚨 Common Issues

### "AWS Access Denied"
```bash
# Check permissions
aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-01-31 --granularity MONTHLY --metrics UnblendedCost

# Solution: Attach AWSBillingReadOnlyAccess policy
```

### "Kubernetes Connection Refused"
```bash
# Check cluster
kubectl cluster-info

# Check context
kubectl config current-context

# Solution: Ensure cluster is running
```

### "GitHub Rate Limit"
```bash
# Check limit
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit

# Solution: You have 5,000 requests/hour when authenticated
```

---

## 📞 Support

### Documentation
- **INTEGRATION_GUIDE.md** - Complete guide
- **QUICK_INTEGRATION_EXAMPLES.md** - Quick wins
- **INTEGRATION_SUMMARY.md** - Overview

### Example Code
- **aws_integration_example.py** - Working AWS code

### API Documentation
- AWS: https://boto3.amazonaws.com/v1/documentation/api/latest/
- Kubernetes: https://github.com/kubernetes-client/python
- GitHub: https://docs.github.com/en/rest
- PagerDuty: https://developer.pagerduty.com/api-reference/
- Slack: https://api.slack.com/

---

## 🎉 Quick Win: Start Here!

**Most teams start with AWS costs because:**
1. ⚡ Fastest to integrate (15 minutes)
2. 💰 Highest immediate value (see real spending)
3. 🔒 Safest (read-only, no changes)
4. 📊 Most impactful (cost visibility for leadership)

**Try it now:**
```bash
# Follow Step 1-5 above
# In 15 minutes, you'll have real AWS costs in your dashboard!
```

---

🚀 **Ready to integrate? Start with the 15-minute AWS guide above!**
