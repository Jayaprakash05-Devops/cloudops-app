# Incident Manager Helm Chart

Incident Management Service - Track incidents, manage on-call, SLA compliance.

## Installation

```bash
helm install incident-manager ./incident-manager
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `service.port` | Service port | `8003` |
