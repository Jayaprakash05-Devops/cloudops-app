# Frontend Helm Chart

Frontend Dashboard - React-based web interface.

## Installation

```bash
helm install frontend ./frontend
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `3` |
| `service.port` | Service port | `3000` |
| `ingress.enabled` | Enable ingress | `true` |
