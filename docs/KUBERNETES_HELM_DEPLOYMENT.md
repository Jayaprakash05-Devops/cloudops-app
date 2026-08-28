# 🚀 CloudOps Kubernetes Deployment with Helm

Complete guide for deploying CloudOps Command Center to Kubernetes using Helm charts.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Deployment Options](#deployment-options)
4. [Step-by-Step Deployment](#step-by-step-deployment)
5. [Configuration](#configuration)
6. [Verification](#verification)
7. [Scaling](#scaling)
8. [Updates & Rollbacks](#updates--rollbacks)
9. [Troubleshooting](#troubleshooting)
10. [Production Best Practices](#production-best-practices)

---

## Prerequisites

### Required Tools

1. **Kubernetes Cluster** (v1.24+)
   - Minikube (local development)
   - Kind (local development)
   - EKS, GKE, AKS (cloud production)

2. **kubectl** (v1.24+)
   ```bash
   kubectl version --client
   ```

3. **Helm** (v3.10+)
   ```bash
   helm version
   ```

4. **Docker** (for building images)
   ```bash
   docker --version
   ```

### Installing Tools

#### Install kubectl

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

#### Install Helm

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

#### Setup Local Kubernetes (Optional)

**Option 1: Minikube**
```bash
# Install
brew install minikube  # macOS
# OR
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start cluster
minikube start --cpus=4 --memory=8192 --driver=docker

# Enable metrics-server (for HPA)
minikube addons enable metrics-server

# Enable ingress
minikube addons enable ingress
```

**Option 2: Kind**
```bash
# Install
brew install kind  # macOS
# OR
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 3000
EOF
```

---

## Quick Start

### 1. Clone Repository

```bash
cd /path/to/cloudops
cd helm/
```

### 2. Quick Deploy (All Services)

```bash
# Deploy all services with monolithic chart
helm install cloudops ./cloudops

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cloudops --timeout=300s

# Check status
kubectl get all
```

### 3. Access Services

```bash
# Port forward frontend
kubectl port-forward svc/cloudops-frontend 3000:3000

# Open browser
open http://localhost:3000

# Login with default credentials
# Username: admin
# Password: admin123
```

---

## Deployment Options

### Option 1: Monolithic Deployment (All Services)

Deploy all 8 services together:

```bash
helm install cloudops ./cloudops

# Or with production values
helm install cloudops ./cloudops \
  --values ./cloudops/values-production.yaml

# Or with development values
helm install cloudops ./cloudops \
  --values ./cloudops/values-development.yaml
```

**Use when:**
- Getting started
- Development environment
- Small deployments
- Simplified management

### Option 2: Independent Microservices

Deploy services individually:

```bash
# 1. Deploy shared Redis
helm install cloudops-redis ./redis

# 2. Deploy backend services
helm install cost-optimizer ./cost-optimizer \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install k8s-manager ./k8s-manager \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install incident-manager ./incident-manager \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install automation-service ./automation-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install chatops-bot ./chatops-bot \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

helm install metrics-collector ./metrics-collector \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

# 3. Deploy auth service with secure JWT key
JWT_KEY=$(openssl rand -base64 32)
helm install auth-service ./auth-service \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master \
  --set jwtSecretKey="${JWT_KEY}"

# 4. Deploy frontend
helm install frontend ./frontend
```

**Use when:**
- Production environment
- Need to scale services independently
- Deploy only specific services
- True microservice architecture

### Option 3: Namespace Isolation

Deploy services across multiple namespaces:

```bash
# Create namespaces
kubectl create namespace cloudops-core
kubectl create namespace cloudops-backend
kubectl create namespace cloudops-frontend

# Deploy core services
helm install cloudops-redis ./redis -n cloudops-core
helm install auth-service ./auth-service -n cloudops-core \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master

# Deploy backend services
helm install cost-optimizer ./cost-optimizer -n cloudops-backend \
  --set redis.enabled=false \
  --set env[0].value=cloudops-redis-master.cloudops-core.svc.cluster.local

# Deploy frontend
helm install frontend ./frontend -n cloudops-frontend
```

---

## Step-by-Step Deployment

### Step 1: Prepare Environment

```bash
# Verify cluster connection
kubectl cluster-info
kubectl get nodes

# Create namespace
kubectl create namespace cloudops

# Set default namespace (optional)
kubectl config set-context --current --namespace=cloudops
```

### Step 2: Build Docker Images (if needed)

```bash
cd /path/to/cloudops

# Build all images
docker-compose build

# Tag images for your registry
docker tag cloudops/cost-optimizer:latest your-registry/cost-optimizer:1.0.0
docker tag cloudops/k8s-manager:latest your-registry/k8s-manager:1.0.0
docker tag cloudops/incident-manager:latest your-registry/incident-manager:1.0.0
docker tag cloudops/automation-service:latest your-registry/automation-service:1.0.0
docker tag cloudops/chatops-bot:latest your-registry/chatops-bot:1.0.0
docker tag cloudops/metrics-collector:latest your-registry/metrics-collector:1.0.0
docker tag cloudops/auth-service:latest your-registry/auth-service:1.0.0
docker tag cloudops/frontend:latest your-registry/frontend:1.0.0

# Push to registry
docker push your-registry/cost-optimizer:1.0.0
docker push your-registry/k8s-manager:1.0.0
docker push your-registry/incident-manager:1.0.0
docker push your-registry/automation-service:1.0.0
docker push your-registry/chatops-bot:1.0.0
docker push your-registry/metrics-collector:1.0.0
docker push your-registry/auth-service:1.0.0
docker push your-registry/frontend:1.0.0
```

**For Minikube/Kind (local development):**
```bash
# Use local images with Minikube
eval $(minikube docker-env)
docker-compose build

# OR use Kind
kind load docker-image cloudops/cost-optimizer:latest
kind load docker-image cloudops/auth-service:latest
kind load docker-image cloudops/frontend:latest
# ... load other images
```

### Step 3: Create Configuration

Create custom values file:

```bash
cat > my-values.yaml << 'EOF'
# Global configuration
global:
  imageRegistry: "your-registry"

# Cost Optimizer
costOptimizer:
  enabled: true
  replicaCount: 3
  image:
    repository: your-registry/cost-optimizer
    tag: "1.0.0"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

# Auth Service
authService:
  enabled: true
  replicaCount: 3
  jwtSecretKey: "CHANGE-THIS-TO-SECURE-KEY"
  image:
    repository: your-registry/auth-service
    tag: "1.0.0"

# Frontend
frontend:
  enabled: true
  replicaCount: 5
  image:
    repository: your-registry/frontend
    tag: "1.0.0"
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

# Redis
redis:
  enabled: true
  auth:
    enabled: false
  master:
    persistence:
      enabled: true
      size: 20Gi
EOF
```

### Step 4: Deploy with Helm

```bash
# Deploy with custom values
helm install cloudops ./cloudops \
  --namespace cloudops \
  --create-namespace \
  --values my-values.yaml

# Or upgrade if already installed
helm upgrade cloudops ./cloudops \
  --namespace cloudops \
  --values my-values.yaml
```

### Step 5: Wait for Deployment

```bash
# Watch deployment progress
kubectl get pods -w

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod --all --timeout=600s

# Check deployment status
kubectl get deployments
kubectl get hpa
kubectl get pdb
```

---

## Configuration

### Common Configuration Options

#### Resources

```yaml
# In values.yaml or my-values.yaml
costOptimizer:
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 1000m
      memory: 1Gi
```

#### Auto-Scaling

```yaml
costOptimizer:
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 20
    targetCPUUtilizationPercentage: 60
    targetMemoryUtilizationPercentage: 75
```

#### Pod Disruption Budget

```yaml
costOptimizer:
  podDisruptionBudget:
    enabled: true
    minAvailable: 2
    # OR
    # maxUnavailable: 1
```

#### Ingress with TLS

```yaml
frontend:
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
    hosts:
      - host: cloudops.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: cloudops-tls
        hosts:
          - cloudops.yourdomain.com
```

#### Environment Variables

```yaml
costOptimizer:
  env:
    - name: REDIS_HOST
      value: "cloudops-redis-master"
    - name: REDIS_PORT
      value: "6379"
    - name: LOG_LEVEL
      value: "INFO"
  
  # Environment from secrets
  envFrom:
    - secretRef:
        name: aws-credentials
    - configMapRef:
        name: app-config
```

#### Image Pull Secrets

```bash
# Create secret for private registry
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@example.com

# Use in values.yaml
imagePullSecrets:
  - name: regcred
```

---

## Verification

### Check Deployment Status

```bash
# List all resources
kubectl get all

# Check pods
kubectl get pods
kubectl get pods -o wide

# Check services
kubectl get svc

# Check deployments
kubectl get deployments

# Check HPA
kubectl get hpa

# Check PDB
kubectl get pdb

# Check ingress
kubectl get ingress
```

### Check Pod Health

```bash
# Describe pod
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# View logs for all pods of a service
kubectl logs -l app.kubernetes.io/name=cost-optimizer

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh
```

### Test Services

```bash
# Port forward to services
kubectl port-forward svc/cloudops-cost-optimizer 8001:8001
kubectl port-forward svc/cloudops-auth-service 8007:8007
kubectl port-forward svc/cloudops-frontend 3000:3000

# Test endpoints
curl http://localhost:8001/health
curl http://localhost:8007/health
open http://localhost:3000
```

### Check Helm Status

```bash
# List releases
helm list

# Get release status
helm status cloudops

# Get release values
helm get values cloudops

# Get release manifest
helm get manifest cloudops

# Get release history
helm history cloudops
```

---

## Scaling

### Manual Scaling

```bash
# Scale via kubectl
kubectl scale deployment cloudops-cost-optimizer --replicas=5

# Scale via helm upgrade
helm upgrade cloudops ./cloudops \
  --reuse-values \
  --set costOptimizer.replicaCount=5
```

### Auto-Scaling (HPA)

HPA is enabled by default. Monitor auto-scaling:

```bash
# View HPA status
kubectl get hpa

# Describe HPA
kubectl describe hpa cloudops-cost-optimizer

# Watch HPA in real-time
kubectl get hpa -w

# Generate load to test auto-scaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Then inside the pod:
while true; do wget -q -O- http://cloudops-cost-optimizer:8001/health; done
```

### Verify Metrics Server

```bash
# Check if metrics-server is running
kubectl get deployment metrics-server -n kube-system

# View pod metrics
kubectl top pods

# View node metrics
kubectl top nodes
```

---

## Updates & Rollbacks

### Update Deployment

```bash
# Update to new version
helm upgrade cloudops ./cloudops \
  --set costOptimizer.image.tag=1.1.0

# Update with new values file
helm upgrade cloudops ./cloudops \
  --values my-values.yaml

# Upgrade and reuse existing values
helm upgrade cloudops ./cloudops \
  --reuse-values \
  --set costOptimizer.replicaCount=5

# Upgrade with timeout
helm upgrade cloudops ./cloudops \
  --timeout 10m \
  --wait
```

### Rollback

```bash
# View release history
helm history cloudops

# Rollback to previous version
helm rollback cloudops

# Rollback to specific revision
helm rollback cloudops 3

# Rollback with timeout
helm rollback cloudops --timeout 5m --wait
```

### Rolling Updates

```bash
# Force rolling update
kubectl rollout restart deployment cloudops-cost-optimizer

# View rollout status
kubectl rollout status deployment cloudops-cost-optimizer

# View rollout history
kubectl rollout history deployment cloudops-cost-optimizer

# Undo rollout
kubectl rollout undo deployment cloudops-cost-optimizer

# Undo to specific revision
kubectl rollout undo deployment cloudops-cost-optimizer --to-revision=2
```

---

## Troubleshooting

### Common Issues

#### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check previous logs (if pod restarted)
kubectl logs <pod-name> --previous

# Common causes:
# - Image pull errors
# - Insufficient resources
# - Failed health checks
# - Configuration errors
```

#### Image Pull Errors

```bash
# Check image pull policy
kubectl describe pod <pod-name> | grep -A 5 "Image"

# Verify image exists
docker pull your-registry/cost-optimizer:1.0.0

# Check image pull secrets
kubectl get secrets
kubectl describe secret regcred

# For local development (Minikube)
eval $(minikube docker-env)
docker images
```

#### Service Not Accessible

```bash
# Check service
kubectl get svc
kubectl describe svc <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# Test from within cluster
kubectl run test-pod --rm -it --image=curlimages/curl -- sh
# Then: curl http://service-name:port/health

# Check network policies
kubectl get networkpolicies
```

#### HPA Not Working

```bash
# Check metrics-server
kubectl get deployment metrics-server -n kube-system

# Check pod metrics
kubectl top pods

# If metrics not available:
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For Minikube
minikube addons enable metrics-server

# Check HPA events
kubectl describe hpa <hpa-name>
```

#### Redis Connection Issues

```bash
# Check Redis pod
kubectl get pods -l app.kubernetes.io/name=redis

# Check Redis service
kubectl get svc -l app.kubernetes.io/name=redis

# Test Redis connection
kubectl run redis-test --rm -it --image=redis:7-alpine -- redis-cli -h cloudops-redis-master ping

# Check Redis logs
kubectl logs -l app.kubernetes.io/name=redis
```

#### Ingress Not Working

```bash
# Check ingress
kubectl get ingress
kubectl describe ingress <ingress-name>

# Check ingress controller
kubectl get pods -n ingress-nginx

# For Minikube
minikube addons enable ingress

# Check ingress logs
kubectl logs -n ingress-nginx <ingress-controller-pod>

# Get Minikube IP
minikube ip

# Add to /etc/hosts
echo "$(minikube ip) cloudops.local" | sudo tee -a /etc/hosts
```

### Debug Commands

```bash
# Get all events
kubectl get events --sort-by='.lastTimestamp'

# Get events for specific namespace
kubectl get events -n cloudops --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods
kubectl top nodes

# Check cluster info
kubectl cluster-info
kubectl cluster-info dump

# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Run diagnostic pod
kubectl run debug --rm -it --image=nicolaka/netshoot -- /bin/bash
```

---

## Production Best Practices

### 1. Resource Management

```yaml
# Set appropriate resource limits
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### 2. High Availability

```yaml
# Multiple replicas
replicaCount: 3

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 2

# Pod anti-affinity
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - cost-optimizer
        topologyKey: kubernetes.io/hostname
```

### 3. Security

```yaml
# Security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true

# Network policies
networkPolicy:
  enabled: true

# Use secrets for sensitive data
envFrom:
  - secretRef:
      name: app-secrets
```

### 4. Monitoring & Observability

```yaml
# Enable service monitor for Prometheus
serviceMonitor:
  enabled: true
  interval: 30s

# Pod annotations for metrics
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8001"
  prometheus.io/path: "/metrics"
```

### 5. Backup & Disaster Recovery

```bash
# Backup Helm values
helm get values cloudops > cloudops-backup-values.yaml

# Backup all manifests
helm get manifest cloudops > cloudops-backup-manifests.yaml

# Backup PVCs
kubectl get pvc -o yaml > pvcs-backup.yaml

# Export all resources
kubectl get all -o yaml > all-resources-backup.yaml
```

### 6. Use Namespaces

```bash
# Separate environments
kubectl create namespace cloudops-dev
kubectl create namespace cloudops-staging
kubectl create namespace cloudops-prod

# Deploy to specific namespace
helm install cloudops ./cloudops -n cloudops-prod
```

### 7. Version Control

```yaml
# Tag images with version
image:
  repository: your-registry/cost-optimizer
  tag: "v1.2.3"  # Not "latest"

# Track Helm chart versions
helm list --all-namespaces
```

### 8. Ingress & TLS

```yaml
# Use ingress with TLS
frontend:
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    tls:
      - secretName: cloudops-tls
        hosts:
          - cloudops.yourdomain.com
```

### 9. Resource Quotas

```yaml
# Set namespace resource quotas
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cloudops-quota
spec:
  hard:
    requests.cpu: "20"
    requests.memory: 40Gi
    limits.cpu: "40"
    limits.memory: 80Gi
    persistentvolumeclaims: "10"
```

### 10. Health Checks

```yaml
# Configure proper health checks
livenessProbe:
  httpGet:
    path: /health
    port: 8001
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health
    port: 8001
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

---

## Cleanup

### Uninstall Release

```bash
# Uninstall specific release
helm uninstall cloudops

# Uninstall with namespace cleanup
helm uninstall cloudops
kubectl delete namespace cloudops

# Uninstall and keep history
helm uninstall cloudops --keep-history
```

### Delete Resources

```bash
# Delete all resources in namespace
kubectl delete all --all -n cloudops

# Delete PVCs
kubectl delete pvc --all -n cloudops

# Delete secrets
kubectl delete secrets --all -n cloudops

# Delete namespace
kubectl delete namespace cloudops
```

---

## Quick Reference

### Helm Commands

```bash
# Install
helm install <release> <chart>

# Upgrade
helm upgrade <release> <chart>

# Rollback
helm rollback <release>

# Uninstall
helm uninstall <release>

# List releases
helm list

# Get status
helm status <release>

# Get values
helm get values <release>
```

### Kubectl Commands

```bash
# Get resources
kubectl get pods|svc|deploy|hpa|pdb|ingress

# Describe resource
kubectl describe <resource> <name>

# View logs
kubectl logs <pod-name>

# Execute in pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward
kubectl port-forward svc/<service-name> <local-port>:<service-port>

# Scale
kubectl scale deployment <name> --replicas=<count>
```

---

## Next Steps

1. **Deploy to Development**: Test with `values-development.yaml`
2. **Deploy to Staging**: Test with production-like config
3. **Deploy to Production**: Use `values-production.yaml`
4. **Setup Monitoring**: Integrate Prometheus/Grafana
5. **Setup CI/CD**: Automate deployments
6. **Setup Backups**: Regular backup strategy
7. **Setup Alerts**: Monitor critical metrics

---

## Additional Resources

- **Helm Documentation**: https://helm.sh/docs/
- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **CloudOps Helm Charts**: `../helm/README.md`
- **Deployment Examples**: `../helm/DEPLOYMENT_EXAMPLES.md`
- **Troubleshooting Guide**: `../helm/STATUS_FINAL.md`

---

**🎉 Your CloudOps platform is ready for Kubernetes deployment!**

Choose the deployment option that fits your needs and follow the step-by-step guide above.
