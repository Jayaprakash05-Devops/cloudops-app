# ⚡ Quick Integration Examples

## 🚀 30-Minute Quick Wins

### 1. AWS Cost Integration (15 minutes)

**Step 1: Get AWS Credentials**
```bash
# Option 1: Use AWS CLI configure
aws configure

# Option 2: Create IAM user via console
# Go to IAM → Users → Add user → Attach CostExplorerReadOnly policy
```

**Step 2: Install boto3**
```bash
cd services/cost-optimizer
pip install boto3
echo "boto3==1.34.0" >> requirements.txt
```

**Step 3: Add AWS code**
```python
# Add to main.py
import boto3
from datetime import datetime, timedelta

ce_client = boto3.client('ce', region_name='us-east-1')

@app.get("/costs/aws/real")
async def get_real_aws_costs():
    end = datetime.now().date()
    start = end - timedelta(days=30)
    
    response = ce_client.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost']
    )
    
    total = 0
    for result in response['ResultsByTime']:
        total += float(result['Total']['UnblendedCost']['Amount'])
    
    return {
        "total_cost": round(total, 2),
        "period_days": 30,
        "source": "AWS Cost Explorer"
    }
```

**Step 4: Test**
```bash
python main.py &
curl http://localhost:8001/costs/aws/real
```

**Done!** ✅ You now have real AWS cost data

---

### 2. GitHub Actions Integration (10 minutes)

**Step 1: Create GitHub Token**
```bash
# Go to: https://github.com/settings/tokens
# Click: Generate new token (classic)
# Select scopes: repo, workflow
# Copy token
```

**Step 2: Test API**
```bash
export GITHUB_TOKEN="ghp_your_token"
export GITHUB_REPO="username/repository"

# Get workflow runs
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/runs?per_page=5"
```

**Step 3: Add to automation service**
```python
# Add to main.py
import requests
import os

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITHUB_REPO = os.getenv('GITHUB_REPO')

@app.get("/pipelines/github")
async def get_github_pipelines():
    if not GITHUB_TOKEN:
        return {"error": "GitHub token not configured"}
    
    url = f"https://api.github.com/repos/{GITHUB_REPO}/actions/runs"
    headers = {"Authorization": f"token {GITHUB_TOKEN}"}
    
    response = requests.get(url, headers=headers, params={"per_page": 10})
    runs = response.json()['workflow_runs']
    
    return [{
        "id": run['id'],
        "name": run['name'],
        "status": run['status'],
        "conclusion": run['conclusion'],
        "created_at": run['created_at']
    } for run in runs]
```

**Step 4: Update docker-compose.yml**
```yaml
automation-service:
  environment:
    - GITHUB_TOKEN=${GITHUB_TOKEN}
    - GITHUB_REPO=${GITHUB_REPO}
```

**Done!** ✅ You now see real GitHub Actions pipelines

---

### 3. Local Kubernetes Integration (5 minutes)

**Prerequisites:** Docker Desktop with Kubernetes enabled

**Step 1: Install kubernetes library**
```bash
cd services/k8s-manager
pip install kubernetes
echo "kubernetes==28.1.0" >> requirements.txt
```

**Step 2: Add K8s code**
```python
# Add to main.py
from kubernetes import client, config

try:
    config.load_kube_config()
    v1 = client.CoreV1Api()
    k8s_enabled = True
except:
    k8s_enabled = False

@app.get("/clusters/real")
async def get_real_clusters():
    if not k8s_enabled:
        return {"error": "Kubernetes not configured"}
    
    nodes = v1.list_node()
    pods = v1.list_pod_for_all_namespaces()
    
    return {
        "cluster_name": "local-docker-desktop",
        "nodes": len(nodes.items),
        "pods": len(pods.items),
        "status": "Connected",
        "source": "Real Kubernetes API"
    }

@app.get("/pods/real")
async def get_real_pods():
    if not k8s_enabled:
        return {"error": "Kubernetes not configured"}
    
    pods = v1.list_pod_for_all_namespaces(limit=20)
    
    return [{
        "name": pod.metadata.name,
        "namespace": pod.metadata.namespace,
        "status": pod.status.phase,
        "node": pod.spec.node_name
    } for pod in pods.items]
```

**Step 3: Test**
```bash
# Check kubectl works
kubectl get nodes

# Start service
python main.py &
curl http://localhost:8002/clusters/real
curl http://localhost:8002/pods/real
```

**Done!** ✅ You now see real Kubernetes data

---

## 🔄 Feature Flag Pattern

### Gradual Migration Strategy

```python
# services/cost-optimizer/main.py
import os

USE_REAL_AWS = os.getenv('USE_REAL_AWS', 'false').lower() == 'true'
USE_REAL_GCP = os.getenv('USE_REAL_GCP', 'false').lower() == 'true'

@app.get("/costs/summary")
async def get_cost_summary():
    costs = []
    
    # AWS
    if USE_REAL_AWS and aws_client:
        try:
            aws_costs = await get_real_aws_costs()
            costs.append(aws_costs)
        except Exception as e:
            logger.error(f"AWS error: {e}")
            costs.append(generate_mock_aws_costs())
    else:
        costs.append(generate_mock_aws_costs())
    
    # GCP
    if USE_REAL_GCP and gcp_client:
        try:
            gcp_costs = await get_real_gcp_costs()
            costs.append(gcp_costs)
        except Exception as e:
            logger.error(f"GCP error: {e}")
            costs.append(generate_mock_gcp_costs())
    else:
        costs.append(generate_mock_gcp_costs())
    
    return aggregate_costs(costs)
```

### Enable via Environment Variables

```bash
# .env
USE_REAL_AWS=true
USE_REAL_GCP=false
USE_REAL_K8S=true
USE_REAL_GITHUB=true
```

---

## 📊 Integration Priority

### Phase 1: Read-Only (Week 1)
1. ✅ **AWS Costs** - Most valuable, easiest
2. ✅ **GitHub Actions** - See real pipelines
3. ✅ **Local K8s** - If using Docker Desktop

### Phase 2: Read-Only Cloud (Week 2)
4. ☁️ **GCP Costs** - If using GCP
5. ☁️ **Azure Costs** - If using Azure
6. ☸️ **EKS/GKE/AKS** - Real cloud K8s

### Phase 3: Write Operations (Week 3)
7. 🚀 **Trigger Workflows** - GitHub Actions dispatch
8. 🔄 **Scale Deployments** - K8s scaling
9. 🚨 **Create Incidents** - PagerDuty

### Phase 4: ChatOps (Week 4)
10. 💬 **Slack Bot** - Slash commands
11. 💬 **Discord Bot** - If using Discord
12. 📊 **Webhooks** - Real-time notifications

---

## 🧪 Testing Each Integration

### AWS
```bash
# Test credentials
aws sts get-caller-identity

# Test Cost Explorer API
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost
```

### GitHub
```bash
# Test API access
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# Test workflow runs
curl -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/runs"
```

### Kubernetes
```bash
# Test kubectl
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

### PagerDuty
```bash
# Test API
curl -H "Authorization: Token token=$PAGERDUTY_API_KEY" \
  -H "Accept: application/vnd.pagerduty+json;version=2" \
  https://api.pagerduty.com/incidents
```

---

## 🚨 Common Issues

### Issue 1: AWS Credentials Not Working
```bash
# Check credentials
aws sts get-caller-identity

# Check permissions
aws ce describe-cost-category-definition --cost-category-arn test 2>&1 | grep -i permission
```

### Issue 2: Kubernetes Connection Refused
```bash
# Check cluster is running
kubectl cluster-info

# Check kubeconfig
echo $KUBECONFIG
cat ~/.kube/config

# Test connection
kubectl get nodes
```

### Issue 3: GitHub API Rate Limit
```bash
# Check rate limit
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# Solution: Use authenticated requests (already doing this)
```

---

## 📦 Required Python Packages

```bash
# services/cost-optimizer/requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.0
redis==5.0.1
boto3==1.34.0  # AWS
google-cloud-billing==1.11.0  # GCP
azure-mgmt-costmanagement==4.0.1  # Azure

# services/k8s-manager/requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.0
redis==5.0.1
kubernetes==28.1.0  # Kubernetes

# services/automation-service/requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.0
redis==5.0.1
requests==2.31.0  # GitHub API

# services/incident-manager/requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.0
redis==5.0.1
pdpyras==5.1.0  # PagerDuty

# services/chatops-bot/requirements.txt
fastapi==0.109.0
uvicorn==0.27.0
pydantic==2.5.0
redis==5.0.1
slack-sdk==3.26.0  # Slack
discord.py==2.3.2  # Discord
```

---

## 🎯 Success Criteria

After each integration:

✅ **Verification Steps:**
1. Service starts without errors
2. Health endpoint returns 200
3. New endpoint returns real data
4. Logs show successful API calls
5. No sensitive data in logs
6. Graceful fallback to mock data on error

✅ **Example Test:**
```bash
# Start service
docker-compose up -d cost-optimizer

# Check health
curl http://localhost:8001/health

# Test real integration
curl http://localhost:8001/costs/aws/real

# Check logs
docker-compose logs cost-optimizer | grep -i aws
```

---

## 🔐 Security Checklist

- [ ] API keys in environment variables (not code)
- [ ] Credentials in .env (gitignored)
- [ ] Use IAM roles when possible
- [ ] Minimum required permissions
- [ ] Rotate keys every 90 days
- [ ] Enable CloudTrail/audit logging
- [ ] Use secrets management (AWS Secrets Manager, etc.)
- [ ] HTTPS for all API calls
- [ ] Validate API responses
- [ ] Handle errors gracefully

---

🎉 **Start with AWS costs - it's the quickest win!**

Most teams see immediate value from real cost data.
