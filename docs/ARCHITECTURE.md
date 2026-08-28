# Architecture Documentation

## System Architecture

### High-Level Overview

Synapse is a distributed microservices platform designed to monitor service health, collect metrics, and manage alerts in cloud environments.

### Component Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        Frontend Layer                         │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  React Dashboard (Port 3000)                           │  │
│  │  - Service overview                                    │  │
│  │  - Metrics visualization                               │  │
│  │  - Alert management                                    │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
                             │
                    HTTP REST API
                             │
┌──────────────────────────────────────────────────────────────┐
│                      Backend Services                         │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ Service Registry│  │  Health Checker │                   │
│  │   (Port 8001)   │  │   (Port 8002)   │                   │
│  │                 │  │                 │                   │
│  │ - Registration  │  │ - HTTP Checks   │                   │
│  │ - Discovery     │  │ - Status Track  │                   │
│  │ - Catalog       │  │ - Pub/Sub       │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │Metrics Collector│  │  Alert Manager  │                   │
│  │   (Port 8003)   │  │   (Port 8004)   │                   │
│  │                 │  │                 │                   │
│  │ - Time-Series   │  │ - Rule Engine   │                   │
│  │ - Aggregation   │  │ - Notifications │                   │
│  │ - Statistics    │  │ - Incidents     │                   │
│  └─────────────────┘  └─────────────────┘                   │
└──────────────────────────────────────────────────────────────┘
                             │
                    Redis Protocol
                             │
┌──────────────────────────────────────────────────────────────┐
│                       Data Layer                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Redis (Port 6379)                                     │  │
│  │  - Service metadata                                    │  │
│  │  - Health check results                                │  │
│  │  - Metrics time-series                                 │  │
│  │  - Alert rules and states                              │  │
│  │  - Pub/Sub for real-time updates                       │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Service Registration Flow
```
Client → Service Registry → Redis
  ↓
Health Checker (discovers new service)
  ↓
Starts monitoring
```

### 2. Health Check Flow
```
Health Checker (every N seconds)
  ↓
GET service.url/health
  ↓
Store result in Redis
  ↓
Update Service Registry status
  ↓
Publish to Redis Pub/Sub
```

### 3. Metrics Collection Flow
```
Metrics Collector (periodic)
  ↓
Read health check results from Redis
  ↓
Calculate metrics (response_time, error_rate)
  ↓
Store in time-series format
  ↓
Generate aggregations (P95, P99, avg)
```

### 4. Alert Evaluation Flow
```
Alert Manager (every 15s)
  ↓
Fetch alert rules
  ↓
Query metrics from Redis
  ↓
Evaluate conditions
  ↓
Fire/Resolve alerts
  ↓
Send notifications
```

## API Design

### Service Registry API

```
POST /register
  Register a new service

GET /services
  List all registered services

GET /services/{service_id}
  Get service details

PUT /services/{service_id}/status
  Update service health status

DELETE /services/{service_id}
  Deregister a service
```

### Health Checker API

```
GET /health
  Service health endpoint

POST /check/{service_id}
  Manually trigger health check

GET /results/{service_id}
  Get health check history

GET /stats/{service_id}
  Get health statistics
```

### Metrics Collector API

```
POST /metrics
  Record a custom metric

GET /metrics/{service_id}/{metric_type}
  Get time-series metrics

GET /metrics/{service_id}/summary
  Get aggregated metrics

GET /services
  List services with metrics
```

### Alert Manager API

```
POST /rules
  Create alert rule

GET /rules
  List all rules

GET /rules/{rule_id}
  Get specific rule

PUT /rules/{rule_id}
  Update rule

DELETE /rules/{rule_id}
  Delete rule

GET /alerts/{service_id}
  Get alerts for service

POST /alerts/{alert_id}/acknowledge
  Acknowledge alert
```

## Data Models

### Service Registration
```json
{
  "service_id": "string",
  "service_name": "string",
  "service_url": "string",
  "health_check_endpoint": "string",
  "check_interval": "integer",
  "registered_at": "datetime",
  "last_seen": "datetime",
  "status": "healthy|degraded|down|unknown",
  "metadata": {}
}
```

### Health Check Result
```json
{
  "service_id": "string",
  "service_name": "string",
  "status": "healthy|degraded|down",
  "response_time": "float",
  "status_code": "integer",
  "checked_at": "datetime",
  "error": "string|null"
}
```

### Metric Point
```json
{
  "service_id": "string",
  "service_name": "string",
  "metric_type": "string",
  "value": "float",
  "timestamp": "datetime",
  "labels": {}
}
```

### Alert Rule
```json
{
  "rule_id": "string",
  "service_id": "string",
  "metric_type": "string",
  "condition": "gt|lt|eq",
  "threshold": "float",
  "duration": "integer",
  "severity": "warning|critical",
  "enabled": "boolean",
  "notification_channels": ["array"]
}
```

## Scalability Considerations

### Current Architecture (Single Node)
- All services run on one machine
- Redis as single point of failure
- Limited by Redis memory

### Future Scalability (Distributed)

1. **Horizontal Scaling**
   - Multiple instances of each service
   - Load balancer in front
   - Service mesh for communication

2. **Data Layer**
   - Redis Cluster for high availability
   - PostgreSQL for persistent storage
   - Time-series database (InfluxDB, TimescaleDB)

3. **Message Queue**
   - RabbitMQ or Kafka for reliable messaging
   - Decouple services

4. **Caching**
   - Redis for hot data
   - CDN for frontend assets

## Security Considerations

### Current State
- No authentication
- No encryption
- Trust model assumes internal network

### Production Requirements

1. **Authentication & Authorization**
   - JWT tokens for API access
   - Role-based access control (RBAC)
   - Service-to-service authentication

2. **Encryption**
   - HTTPS/TLS for all communication
   - Encrypted Redis connections
   - Secrets management (Vault, AWS Secrets Manager)

3. **Network Security**
   - Service mesh with mTLS
   - Network policies
   - Rate limiting
   - DDoS protection

4. **Audit Logging**
   - All API calls logged
   - Change tracking
   - Compliance reporting

## Monitoring the Monitor

Even monitoring systems need monitoring:

1. **Self-Health Checks**
   - Each service has `/health` endpoint
   - Can register themselves in the registry

2. **Metrics**
   - Service response times
   - Queue depths
   - Redis memory usage

3. **Alerts**
   - Alert on monitoring service failures
   - Dead man's switch alerts

## Deployment Strategies

### Development
```bash
docker-compose up -d
```

### Staging/Production

1. **Container Orchestration**
   - Kubernetes with Helm charts
   - Auto-scaling based on load
   - Rolling updates

2. **Infrastructure as Code**
   - Terraform for cloud resources
   - GitOps for deployment

3. **CI/CD Pipeline**
   ```
   Code → GitHub → CI (Tests) → Build Images → Deploy to K8s
   ```

## Performance Characteristics

### Latency
- API endpoints: <50ms (p95)
- Health checks: 5-10s intervals
- Metrics collection: 30s intervals
- Alert evaluation: 15s intervals

### Throughput
- Can monitor 100+ services
- 1000+ health checks per minute
- 10,000+ metrics points per minute

### Storage
- 1 service × 30 day history ≈ 86,400 data points
- 100 services × 30 days ≈ 8.6M data points
- With Redis: ~1-2GB memory

## Technology Choices

### Why FastAPI?
- Async/await support for high performance
- Automatic OpenAPI documentation
- Type hints and validation with Pydantic
- Modern Python (3.11+)

### Why Redis?
- Fast in-memory storage
- Pub/Sub for real-time updates
- Time-series data with lists
- Atomic operations

### Why React?
- Component-based architecture
- Large ecosystem
- Easy to learn
- Good for real-time dashboards

### Why Docker?
- Consistent environments
- Easy deployment
- Isolation
- Portable
