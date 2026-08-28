# Metrics Collector Helm Chart

Metrics Collection Service - Cross-service metrics, analytics, dashboards.

## Installation

```bash
helm install metrics-collector ./metrics-collector
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8006` |
