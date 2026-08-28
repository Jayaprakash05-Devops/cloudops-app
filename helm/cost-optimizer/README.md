# Cost Optimizer Helm Chart

Cloud Cost Optimization Service - Analyze spending, get recommendations, track budgets.

## Installation

```bash
helm install cost-optimizer ./cost-optimizer
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8001` |
| `redis.enabled` | Deploy Redis with chart | `true` |

## Access

```bash
kubectl port-forward svc/cost-optimizer 8001:8001
curl http://localhost:8001/health
```
