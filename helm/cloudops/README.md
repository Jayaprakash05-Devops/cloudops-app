# CloudOps Command Center Helm Chart

Production-ready Helm chart for deploying CloudOps Command Center to Kubernetes with high availability, auto-scaling, and pod disruption budgets.

## Features

✅ **High Availability**
- Pod Disruption Budgets (PDB) for all services
- Multiple replicas per service
- Anti-affinity rules support

✅ **Auto-Scaling**
- Horizontal Pod Autoscaler (HPA) for all services
- CPU and memory-based scaling
- Smart scale-up/scale-down policies

✅ **Security**
- Non-root containers
- Read-only root filesystem
- Security contexts
- Network policies
- RBAC for K8s Manager

✅ **Observability**
- Prometheus metrics (optional)
- Liveness and readiness probes
- Service monitors

✅ **Production-Ready**
- Resource limits and requests
- ConfigMaps for configuration
- Secrets management support
- Ingress with TLS

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support (for Redis persistence)
- Metrics Server (for HPA)

## Installing the Chart

### Quick Start

```bash
# Add Bitnami repo (for Redis dependency)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install with default values
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --create-namespace
```

### With Custom Values

```bash
# Create custom values file
cat > my-values.yaml << YAML
frontend:
  ingress:
    enabled: true
    hosts:
      - host: cloudops.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: cloudops-tls
        hosts:
          - cloudops.yourdomain.com

costOptimizer:
  envFrom:
    - secretRef:
        name: aws-credentials

k8sManager:
  rbac:
    create: true
YAML

# Install with custom values
helm install cloudops ./helm/cloudops \
  --namespace cloudops \
  --create-namespace \
  --values my-values.yaml
```

## Configuration

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker registry | `""` |
| `global.imagePullSecrets` | Global image pull secrets | `[]` |

### Service Configuration

Each service supports the following parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `<service>.enabled` | Enable/disable service | `true` |
| `<service>.replicaCount` | Number of replicas | `2-3` |
| `<service>.image.repository` | Image repository | `cloudops/<service>` |
| `<service>.image.tag` | Image tag | `1.0.0` |
| `<service>.resources.limits.cpu` | CPU limit | `500m-1000m` |
| `<service>.resources.limits.memory` | Memory limit | `512Mi-1Gi` |

### Horizontal Pod Autoscaler (HPA)

All services include HPA configuration:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `<service>.autoscaling.enabled` | Enable HPA | `true` |
| `<service>.autoscaling.minReplicas` | Minimum replicas | `2` |
| `<service>.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `<service>.autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `70` |
| `<service>.autoscaling.targetMemoryUtilizationPercentage` | Target Memory % | `80` |

### Pod Disruption Budget (PDB)

All services include PDB configuration:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `<service>.podDisruptionBudget.enabled` | Enable PDB | `true` |
| `<service>.podDisruptionBudget.minAvailable` | Min available pods | `1` |
| `<service>.podDisruptionBudget.maxUnavailable` | Max unavailable pods | `nil` |

### Examples

#### Custom Resource Limits

```yaml
costOptimizer:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi
```

#### HPA Configuration

```yaml
automationService:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 60
    targetMemoryUtilizationPercentage: 75
```

#### Adding Secrets

```yaml
costOptimizer:
  envFrom:
    - secretRef:
        name: aws-credentials

incidentManager:
  envFrom:
    - secretRef:
        name: pagerduty-api-key
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade cloudops ./helm/cloudops \
  --namespace cloudops \
  --values my-values.yaml

# Force recreate pods
helm upgrade cloudops ./helm/cloudops \
  --namespace cloudops \
  --force
```

## Uninstalling

```bash
helm uninstall cloudops --namespace cloudops
```

## Service-Specific Configuration

### Cost Optimizer

```yaml
costOptimizer:
  envFrom:
    - secretRef:
        name: aws-credentials  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
    - secretRef:
        name: gcp-credentials  # GOOGLE_APPLICATION_CREDENTIALS
```

### K8s Manager

```yaml
k8sManager:
  serviceAccount:
    create: true
  rbac:
    create: true
    rules:
      - apiGroups: [""]
        resources: ["pods", "services", "nodes"]
        verbs: ["get", "list", "watch"]
      - apiGroups: ["apps"]
        resources: ["deployments"]
        verbs: ["get", "list", "watch", "patch"]
```

### Incident Manager

```yaml
incidentManager:
  envFrom:
    - secretRef:
        name: pagerduty-credentials  # PAGERDUTY_API_KEY
```

### Automation Service

```yaml
automationService:
  envFrom:
    - secretRef:
        name: github-credentials  # GITHUB_TOKEN, GITHUB_REPO
```

### ChatOps Bot

```yaml
chatopsBot:
  envFrom:
    - secretRef:
        name: slack-credentials  # SLACK_BOT_TOKEN
```

### Frontend

```yaml
frontend:
  replicaCount: 3
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: cloudops.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: cloudops-tls
        hosts:
          - cloudops.example.com
```

## Creating Secrets

### AWS Credentials

```bash
kubectl create secret generic aws-credentials \
  --namespace cloudops \
  --from-literal=AWS_ACCESS_KEY_ID=your_key \
  --from-literal=AWS_SECRET_ACCESS_KEY=your_secret
```

### GitHub Token

```bash
kubectl create secret generic github-credentials \
  --namespace cloudops \
  --from-literal=GITHUB_TOKEN=ghp_your_token \
  --from-literal=GITHUB_REPO=username/repo
```

### PagerDuty API Key

```bash
kubectl create secret generic pagerduty-credentials \
  --namespace cloudops \
  --from-literal=PAGERDUTY_API_KEY=your_api_key
```

### Slack Bot Token

```bash
kubectl create secret generic slack-credentials \
  --namespace cloudops \
  --from-literal=SLACK_BOT_TOKEN=xoxb-your-token
```

## Monitoring

### View HPA Status

```bash
kubectl get hpa -n cloudops
```

### View PDB Status

```bash
kubectl get pdb -n cloudops
```

### View Pod Status

```bash
kubectl get pods -n cloudops -l app.kubernetes.io/instance=cloudops
```

### Check Auto-Scaling Events

```bash
kubectl describe hpa -n cloudops
```

## Troubleshooting

### Pods Not Scaling

1. Check metrics server is installed:
```bash
kubectl get deployment metrics-server -n kube-system
```

2. Check HPA status:
```bash
kubectl describe hpa cloudops-cost-optimizer -n cloudops
```

3. Check pod resource usage:
```bash
kubectl top pods -n cloudops
```

### PDB Blocking Evictions

```bash
# Check PDB status
kubectl get pdb -n cloudops

# Check which PDB is blocking
kubectl describe pdb -n cloudops
```

### Services Not Starting

```bash
# Check pod logs
kubectl logs -n cloudops -l app.kubernetes.io/component=cost-optimizer

# Check events
kubectl get events -n cloudops --sort-by='.lastTimestamp'
```

## Production Checklist

- [ ] Configure ingress with TLS
- [ ] Create secrets for all integrations (AWS, GitHub, etc.)
- [ ] Enable Prometheus ServiceMonitor
- [ ] Configure resource limits appropriately
- [ ] Set up persistent storage for Redis
- [ ] Enable network policies
- [ ] Configure node affinity/anti-affinity
- [ ] Set up backup strategy for Redis data
- [ ] Configure alerts for HPA and PDB
- [ ] Test rolling updates
- [ ] Test pod disruption scenarios

## Advanced Configuration

### Node Affinity

```yaml
costOptimizer:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-type
            operator: In
            values:
            - compute-optimized
```

### Pod Anti-Affinity

```yaml
costOptimizer:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app.kubernetes.io/component
              operator: In
              values:
              - cost-optimizer
          topologyKey: kubernetes.io/hostname
```

### Tolerations

```yaml
k8sManager:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "cloudops"
    effect: "NoSchedule"
```

## License

Copyright © 2024 CloudOps Team
