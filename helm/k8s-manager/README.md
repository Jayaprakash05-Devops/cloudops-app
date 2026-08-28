# K8s Manager Helm Chart

Kubernetes Management Service - Cluster monitoring, pod management, resource optimization.

## Installation

```bash
helm install k8s-manager ./k8s-manager
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8002` |
| `rbac.create` | Create RBAC resources | `true` |
