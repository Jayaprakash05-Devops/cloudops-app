# 🔌 Integration Guide - Connect to Real Systems

## Overview

This guide shows you how to replace mock data with real integrations for:
- ☁️ **AWS Cost Explorer** - Real cloud costs
- ☸️ **Kubernetes** - Real clusters
- 🚀 **CI/CD** - GitHub Actions, GitLab CI, Jenkins
- 🚨 **Incident Management** - PagerDuty, OpsGenie
- 💬 **ChatOps** - Slack, Discord
- 📊 **Monitoring** - Prometheus, Grafana

---

## 1️⃣ AWS Cost Integration

### Prerequisites
- AWS Account with Cost Explorer enabled
- IAM user with Cost Explorer permissions
- AWS CLI installed

### Step 1: Create IAM User

```bash
# Create IAM policy for Cost Explorer
cat > cost-explorer-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "ce:GetCostForecast",
        "ce:GetDimensionValues",
        "ce:GetReservationUtilization",
        "ce:GetSavingsPlansUtilization"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the policy
aws iam create-policy \
  --policy-name CostExplorerReadOnly \
  --policy-document file://cost-explorer-policy.json

# Create IAM user
aws iam create-user --user-name cloudops-cost-reader

# Attach policy
aws iam attach-user-policy \
  --user-name cloudops-cost-reader \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/CostExplorerReadOnly

# Create access keys
aws iam create-access-key --user-name cloudops-cost-reader
```

### Step 2: Update Cost Optimizer Service

Create `services/cost-optimizer/aws_client.py`:

```python
import boto3
from datetime import datetime, timedelta
from typing import Dict, List

class AWSCostClient:
    def __init__(self, access_key: str, secret_key: str, region: str = 'us-east-1'):
        self.client = boto3.client(
            'ce',
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region
        )
    
    def get_cost_and_usage(self, start_date: str, end_date: str) -> Dict:
        """Get AWS cost and usage data"""
        response = self.client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost', 'UsageQuantity'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'}
            ]
        )
        return response
    
    def get_cost_forecast(self, start_date: str, end_date: str) -> Dict:
        """Get cost forecast"""
        response = self.client.get_cost_forecast(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Metric='UNBLENDED_COST',
            Granularity='MONTHLY'
        )
        return response
    
    def get_services_cost(self) -> List[Dict]:
        """Get cost breakdown by service"""
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        response = self.get_cost_and_usage(
            start_date.strftime('%Y-%m-%d'),
            end_date.strftime('%Y-%m-%d')
        )
        
        costs = []
        for result in response['ResultsByTime']:
            date = result['TimePeriod']['Start']
            for group in result['Groups']:
                service = group['Keys'][0]
                cost = float(group['Metrics']['UnblendedCost']['Amount'])
                costs.append({
                    'date': date,
                    'service': service,
                    'cost': round(cost, 2)
                })
        
        return costs
```

### Step 3: Update main.py

```python
from aws_client import AWSCostClient
import os

# Initialize AWS client
aws_client = None
if os.getenv('AWS_ACCESS_KEY_ID') and os.getenv('AWS_SECRET_ACCESS_KEY'):
    aws_client = AWSCostClient(
        access_key=os.getenv('AWS_ACCESS_KEY_ID'),
        secret_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
        region=os.getenv('AWS_REGION', 'us-east-1')
    )

@app.get("/costs/summary")
async def get_cost_summary():
    """Get cost summary from AWS"""
    if aws_client:
        # Get real AWS data
        services_cost = aws_client.get_services_cost()
        
        # Process and return
        total_cost = sum(item['cost'] for item in services_cost)
        return {
            "total_daily_cost": round(total_cost, 2),
            "total_monthly_cost": round(total_cost * 30, 2),
            "services": services_cost,
            "source": "AWS Cost Explorer"
        }
    else:
        # Fall back to mock data
        return generate_mock_costs()
```

### Step 4: Update Environment Variables

```bash
# .env file
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1
```

### Step 5: Update requirements.txt

```txt
boto3==1.34.0
```

### Step 6: Update Dockerfile

```dockerfile
# Install AWS SDK
RUN pip install --no-cache-dir boto3
```

---

## 2️⃣ Real Kubernetes Integration

### Step 1: Install Kubernetes Python Client

```bash
pip install kubernetes
```

### Step 2: Create K8s Client

Create `services/k8s-manager/k8s_client.py`:

```python
from kubernetes import client, config
from typing import List, Dict
import os

class K8sClient:
    def __init__(self, kubeconfig_path: str = None):
        """Initialize Kubernetes client"""
        if kubeconfig_path:
            config.load_kube_config(config_file=kubeconfig_path)
        elif os.getenv('KUBERNETES_SERVICE_HOST'):
            # Running inside cluster
            config.load_incluster_config()
        else:
            # Use default kubeconfig
            config.load_kube_config()
        
        self.v1 = client.CoreV1Api()
        self.apps_v1 = client.AppsV1Api()
    
    def get_clusters(self) -> List[Dict]:
        """Get cluster information"""
        version_api = client.VersionApi()
        version = version_api.get_code()
        
        nodes = self.v1.list_node()
        pods = self.v1.list_pod_for_all_namespaces()
        
        return [{
            "cluster_id": "current-cluster",
            "name": os.getenv('CLUSTER_NAME', 'default-cluster'),
            "version": version.git_version,
            "nodes": len(nodes.items),
            "pods": len(pods.items),
            "status": "Healthy",
            "provider": os.getenv('CLUSTER_PROVIDER', 'Unknown')
        }]
    
    def get_pods(self, namespace: str = "default") -> List[Dict]:
        """Get pods in namespace"""
        pods = self.v1.list_namespaced_pod(namespace)
        
        result = []
        for pod in pods.items:
            result.append({
                "name": pod.metadata.name,
                "namespace": pod.metadata.namespace,
                "status": pod.status.phase,
                "node": pod.spec.node_name,
                "cpu_usage": "N/A",  # Need metrics-server
                "memory_usage": "N/A",
                "restarts": sum(c.restart_count for c in pod.status.container_statuses or []),
                "age": str(datetime.now() - pod.metadata.creation_timestamp)
            })
        
        return result
    
    def get_deployments(self, namespace: str = "default") -> List[Dict]:
        """Get deployments"""
        deployments = self.apps_v1.list_namespaced_deployment(namespace)
        
        result = []
        for dep in deployments.items:
            result.append({
                "name": dep.metadata.name,
                "namespace": dep.metadata.namespace,
                "replicas": dep.spec.replicas,
                "available": dep.status.available_replicas or 0,
                "ready": dep.status.ready_replicas or 0,
                "up_to_date": dep.status.updated_replicas or 0,
                "age": str(datetime.now() - dep.metadata.creation_timestamp)
            })
        
        return result
    
    def scale_deployment(self, name: str, namespace: str, replicas: int) -> Dict:
        """Scale a deployment"""
        # Get current deployment
        deployment = self.apps_v1.read_namespaced_deployment(name, namespace)
        
        # Update replicas
        deployment.spec.replicas = replicas
        
        # Patch deployment
        self.apps_v1.patch_namespaced_deployment(name, namespace, deployment)
        
        return {
            "name": name,
            "namespace": namespace,
            "replicas": replicas,
            "status": "scaling"
        }
```

### Step 3: Update main.py

```python
from k8s_client import K8sClient
import os

# Initialize K8s client
k8s_client = None
if os.getenv('KUBECONFIG') or os.getenv('KUBERNETES_SERVICE_HOST'):
    try:
        k8s_client = K8sClient(kubeconfig_path=os.getenv('KUBECONFIG'))
    except Exception as e:
        print(f"Failed to initialize K8s client: {e}")

@app.get("/clusters")
async def get_clusters():
    if k8s_client:
        return k8s_client.get_clusters()
    else:
        return generate_mock_clusters()

@app.get("/pods")
async def get_pods(namespace: str = "default"):
    if k8s_client:
        return k8s_client.get_pods(namespace)
    else:
        return generate_mock_pods(namespace)

@app.post("/deployments/{namespace}/{name}/scale")
async def scale_deployment(namespace: str, name: str, replicas: int):
    if k8s_client:
        return k8s_client.scale_deployment(name, namespace, replicas)
    else:
        return {"message": "Mock: scaled", "replicas": replicas}
```

### Step 4: Setup Kubeconfig

```bash
# Option 1: Local kubeconfig
export KUBECONFIG=~/.kube/config

# Option 2: Copy kubeconfig to container
docker run -v ~/.kube:/root/.kube \
  -e KUBECONFIG=/root/.kube/config \
  cloudops-k8s-manager

# Option 3: Service Account (in-cluster)
# No configuration needed - auto-detected
```

---

## 3️⃣ GitHub Actions Integration

### Step 1: Create GitHub Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with scopes:
   - `repo` (full control)
   - `workflow` (update workflows)
3. Copy the token

### Step 2: Update Automation Service

Create `services/automation-service/github_client.py`:

```python
import requests
from typing import List, Dict

class GitHubClient:
    def __init__(self, token: str, repo: str):
        self.token = token
        self.repo = repo  # format: "owner/repo"
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"token {token}",
            "Accept": "application/vnd.github.v3+json"
        }
    
    def get_workflow_runs(self, limit: int = 10) -> List[Dict]:
        """Get recent workflow runs"""
        url = f"{self.base_url}/repos/{self.repo}/actions/runs"
        params = {"per_page": limit}
        
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        
        runs = []
        for run in response.json()['workflow_runs']:
            runs.append({
                "pipeline_id": str(run['id']),
                "name": run['name'],
                "status": run['status'],
                "conclusion": run['conclusion'],
                "environment": run.get('environment', 'N/A'),
                "started_at": run['created_at'],
                "duration": None,  # Calculate if completed
                "triggered_by": run['triggering_actor']['login'],
                "commit": run['head_sha'][:7]
            })
        
        return runs
    
    def trigger_workflow(self, workflow_id: str, ref: str = "main", inputs: Dict = None) -> Dict:
        """Trigger a workflow dispatch"""
        url = f"{self.base_url}/repos/{self.repo}/actions/workflows/{workflow_id}/dispatches"
        data = {
            "ref": ref,
            "inputs": inputs or {}
        }
        
        response = requests.post(url, headers=self.headers, json=data)
        response.raise_for_status()
        
        return {
            "workflow_id": workflow_id,
            "ref": ref,
            "status": "triggered"
        }
    
    def get_deployments(self) -> List[Dict]:
        """Get deployments"""
        url = f"{self.base_url}/repos/{self.repo}/deployments"
        
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        
        deployments = []
        for dep in response.json():
            deployments.append({
                "deployment_id": str(dep['id']),
                "environment": dep['environment'],
                "ref": dep['ref'],
                "created_at": dep['created_at']
            })
        
        return deployments
```

### Step 3: Update main.py

```python
from github_client import GitHubClient
import os

# Initialize GitHub client
github_client = None
if os.getenv('GITHUB_TOKEN') and os.getenv('GITHUB_REPO'):
    github_client = GitHubClient(
        token=os.getenv('GITHUB_TOKEN'),
        repo=os.getenv('GITHUB_REPO')
    )

@app.get("/pipelines")
async def get_pipelines(limit: int = 10):
    if github_client:
        return github_client.get_workflow_runs(limit)
    else:
        return generate_mock_pipelines()
```

### Step 4: Environment Variables

```bash
GITHUB_TOKEN=ghp_your_token_here
GITHUB_REPO=username/repository
```

---

## 4️⃣ PagerDuty Integration

### Step 1: Get API Key

1. Go to PagerDuty → Integrations → API Access Keys
2. Create new API key
3. Copy the key

### Step 2: Create PagerDuty Client

Create `services/incident-manager/pagerduty_client.py`:

```python
import requests
from typing import List, Dict

class PagerDutyClient:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.pagerduty.com"
        self.headers = {
            "Authorization": f"Token token={api_key}",
            "Accept": "application/vnd.pagerduty+json;version=2",
            "Content-Type": "application/json"
        }
    
    def get_incidents(self, status: str = None) -> List[Dict]:
        """Get incidents"""
        url = f"{self.base_url}/incidents"
        params = {}
        if status:
            params['statuses[]'] = status
        
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        
        incidents = []
        for inc in response.json()['incidents']:
            incidents.append({
                "incident_id": inc['id'],
                "title": inc['title'],
                "description": inc['description'],
                "status": inc['status'],
                "urgency": inc['urgency'],
                "service": inc['service']['summary'],
                "created_at": inc['created_at'],
                "assigned_to": inc.get('assignments', [{}])[0].get('assignee', {}).get('summary', 'Unassigned')
            })
        
        return incidents
    
    def create_incident(self, title: str, service_id: str, urgency: str = "high") -> Dict:
        """Create an incident"""
        url = f"{self.base_url}/incidents"
        data = {
            "incident": {
                "type": "incident",
                "title": title,
                "service": {
                    "id": service_id,
                    "type": "service_reference"
                },
                "urgency": urgency
            }
        }
        
        response = requests.post(url, headers=self.headers, json=data)
        response.raise_for_status()
        
        inc = response.json()['incident']
        return {
            "incident_id": inc['id'],
            "title": inc['title'],
            "status": inc['status']
        }
    
    def get_oncall(self) -> List[Dict]:
        """Get on-call schedules"""
        url = f"{self.base_url}/oncalls"
        
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        
        oncalls = []
        for oc in response.json()['oncalls']:
            oncalls.append({
                "schedule_id": oc['schedule']['id'],
                "team": oc['schedule']['summary'],
                "current_oncall": oc['user']['summary'],
                "start": oc['start'],
                "end": oc['end']
            })
        
        return oncalls
```

---

## 5️⃣ Slack Integration

### Step 1: Create Slack App

1. Go to https://api.slack.com/apps
2. Create New App → From scratch
3. Add Bot Token Scopes:
   - `chat:write`
   - `commands`
   - `channels:read`
4. Install to Workspace
5. Copy Bot User OAuth Token

### Step 2: Create Slack Client

Create `services/chatops-bot/slack_client.py`:

```python
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

class SlackClient:
    def __init__(self, token: str):
        self.client = WebClient(token=token)
    
    def send_message(self, channel: str, message: str):
        """Send message to channel"""
        try:
            response = self.client.chat_postMessage(
                channel=channel,
                text=message
            )
            return {"status": "sent", "ts": response['ts']}
        except SlackApiError as e:
            return {"status": "error", "error": str(e)}
    
    def get_channels(self):
        """List channels"""
        try:
            response = self.client.conversations_list()
            channels = []
            for channel in response['channels']:
                channels.append({
                    "id": channel['id'],
                    "name": channel['name']
                })
            return channels
        except SlackApiError as e:
            return []
```

### Step 3: Setup Slash Commands

In Slack App settings:
1. Go to Slash Commands
2. Create New Command:
   - Command: `/cloudops`
   - Request URL: `https://your-domain.com/slack/commands`
   - Description: Execute CloudOps commands

---

## 6️⃣ Prometheus Integration

### Step 1: Update Metrics Collector

Create `services/metrics-collector/prometheus_client.py`:

```python
import requests
from typing import Dict, List
from datetime import datetime, timedelta

class PrometheusClient:
    def __init__(self, url: str):
        self.url = url.rstrip('/')
    
    def query(self, query: str) -> Dict:
        """Execute PromQL query"""
        url = f"{self.url}/api/v1/query"
        params = {"query": query}
        
        response = requests.get(url, params=params)
        response.raise_for_status()
        
        return response.json()
    
    def query_range(self, query: str, start: datetime, end: datetime, step: str = "15m") -> Dict:
        """Execute range query"""
        url = f"{self.url}/api/v1/query_range"
        params = {
            "query": query,
            "start": start.timestamp(),
            "end": end.timestamp(),
            "step": step
        }
        
        response = requests.get(url, params=params)
        response.raise_for_status()
        
        return response.json()
    
    def get_service_metrics(self, service: str) -> Dict:
        """Get metrics for a service"""
        # Request rate
        rate_query = f'rate(http_requests_total{{service="{service}"}}[5m])'
        rate_result = self.query(rate_query)
        
        # Error rate
        error_query = f'rate(http_requests_total{{service="{service}",status=~"5.."}}[5m])'
        error_result = self.query(error_query)
        
        # Response time
        latency_query = f'histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{{service="{service}"}}[5m]))'
        latency_result = self.query(latency_query)
        
        return {
            "service": service,
            "request_rate": rate_result,
            "error_rate": error_result,
            "latency_p99": latency_result
        }
```

---

## 7️⃣ Environment Configuration

### Complete .env file

```bash
# AWS Configuration
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=us-east-1

# GCP Configuration
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
GCP_PROJECT_ID=your-project-id

# Azure Configuration
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_CLIENT_ID=your-client-id
AZURE_CLIENT_SECRET=your-client-secret
AZURE_TENANT_ID=your-tenant-id

# Kubernetes
KUBECONFIG=/path/to/kubeconfig
CLUSTER_NAME=production-cluster
CLUSTER_PROVIDER=AWS EKS

# GitHub
GITHUB_TOKEN=ghp_your_token
GITHUB_REPO=username/repository

# PagerDuty
PAGERDUTY_API_KEY=your-api-key
PAGERDUTY_SERVICE_ID=your-service-id

# Slack
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-signing-secret

# Discord
DISCORD_BOT_TOKEN=your-bot-token
DISCORD_GUILD_ID=your-guild-id

# Prometheus
PROMETHEUS_URL=http://prometheus:9090

# Grafana
GRAFANA_URL=http://grafana:3000
GRAFANA_API_KEY=your-api-key

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=cloudops
POSTGRES_USER=cloudops
POSTGRES_PASSWORD=your-password
```

### Update docker-compose.yml

```yaml
services:
  cost-optimizer:
    build:
      context: ./services/cost-optimizer
    environment:
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - AWS_REGION=${AWS_REGION}
      - REDIS_HOST=redis
    env_file:
      - .env
```

---

## 8️⃣ Security Best Practices

### 1. Use AWS Secrets Manager

```python
import boto3

def get_secret(secret_name):
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

# Usage
api_key = get_secret('cloudops/pagerduty/api-key')
```

### 2. Use Kubernetes Secrets

```bash
# Create secret
kubectl create secret generic cloudops-secrets \
  --from-literal=aws-access-key=YOUR_KEY \
  --from-literal=aws-secret-key=YOUR_SECRET

# Use in deployment
env:
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: cloudops-secrets
        key: aws-access-key
```

### 3. Use GitHub Secrets

```yaml
# In GitHub Actions
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

---

## 9️⃣ Testing Integrations

### Test AWS Connection

```bash
python -c "
from aws_client import AWSCostClient
import os

client = AWSCostClient(
    os.getenv('AWS_ACCESS_KEY_ID'),
    os.getenv('AWS_SECRET_ACCESS_KEY')
)
print(client.get_services_cost())
"
```

### Test Kubernetes Connection

```bash
python -c "
from k8s_client import K8sClient

client = K8sClient()
print(client.get_clusters())
"
```

### Test GitHub Connection

```bash
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/username/repo/actions/runs
```

---

## 🔟 Migration Strategy

### Phase 1: Parallel Running (Week 1-2)
- Keep mock data as fallback
- Add real integrations alongside
- Compare results

### Phase 2: Gradual Switch (Week 3-4)
- Use real data when available
- Fall back to mock on errors
- Monitor and debug

### Phase 3: Full Migration (Week 5+)
- Switch to real data by default
- Remove mock data generators
- Handle errors gracefully

### Example Code Pattern

```python
@app.get("/costs/summary")
async def get_cost_summary():
    try:
        if aws_client and not os.getenv('USE_MOCK_DATA'):
            # Try real data first
            return await get_real_aws_costs()
    except Exception as e:
        logger.error(f"Failed to fetch AWS data: {e}")
    
    # Fall back to mock
    return generate_mock_costs()
```

---

## 📚 Additional Resources

### AWS SDK Documentation
- https://boto3.amazonaws.com/v1/documentation/api/latest/index.html

### Kubernetes Python Client
- https://github.com/kubernetes-client/python

### GitHub API
- https://docs.github.com/en/rest

### PagerDuty API
- https://developer.pagerduty.com/api-reference/

### Slack API
- https://api.slack.com/

---

## ✅ Quick Start Checklist

- [ ] AWS IAM user created with Cost Explorer permissions
- [ ] Kubernetes kubeconfig configured
- [ ] GitHub personal access token generated
- [ ] PagerDuty API key obtained
- [ ] Slack bot created and installed
- [ ] Environment variables configured
- [ ] Dependencies installed (`boto3`, `kubernetes`, `slack-sdk`)
- [ ] Integration code added to services
- [ ] Tests written and passing
- [ ] Error handling implemented
- [ ] Secrets management configured
- [ ] Documentation updated

---

🎉 **You're ready to integrate with real systems!**

Start with one integration at a time and test thoroughly.
