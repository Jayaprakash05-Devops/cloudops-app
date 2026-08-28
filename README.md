# CloudOps Command Center ☁️🚀

**A unified DevOps/SRE platform for Cloud Operations, Kubernetes Management, Cost Optimization, and Incident Response**

## 🎯 What is CloudOps Command Center?

CloudOps Command Center is a comprehensive microservices platform that combines:

1. **☁️ Cloud Cost Optimization** - Analyze spending, get recommendations, track budgets
2. **🤖 DevOps Automation** - CI/CD pipelines, infrastructure provisioning, deployments
3. **☸️ Kubernetes Management** - Cluster monitoring, pod management, resource optimization
4. **🚨 Incident Management** - Incident tracking, on-call schedules, auto-remediation, SLA tracking
5. **💬 ChatOps Interface** - Control everything via chat commands (Discord/Slack)
6. **📊 Metrics & Analytics** - Unified metrics collection and visualization

## 🏗️ Architecture

### Backend Services (7 microservices)

1. **Cost Optimizer Service** (Port 8001)
   - Cloud spending analysis (AWS, GCP, Azure)
   - Cost recommendations and forecasting
   - Budget tracking and anomaly detection
   - Savings calculator

2. **Kubernetes Manager Service** (Port 8002)
   - Cluster health monitoring
   - Pod/Deployment/Service management
   - Resource optimization suggestions
   - Helm chart deployments
   - Auto-scaling recommendations

3. **Incident Manager Service** (Port 8003)
   - Incident creation and tracking
   - On-call schedule management
   - Auto-remediation workflows
   - Post-mortem generator
   - SLA compliance tracking

4. **Automation Service** (Port 8004)
   - CI/CD pipeline orchestration
   - Infrastructure as Code provisioning
   - Automated deployments (blue-green, canary)
   - Runbook execution
   - Scheduled task management

5. **ChatOps Bot Service** (Port 8005)
   - Discord/Slack bot integration
   - Natural language commands
   - Interactive workflows
   - Real-time notifications
   - Command & control interface

6. **Metrics Collector Service** (Port 8006)
   - Cross-service metrics aggregation
   - Time-series data storage
   - Performance analytics
   - Custom dashboard support

7. **Auth Service** (Port 8007) 🔐 **NEW!**
   - JWT token-based authentication
   - User management (add, edit, delete users)
   - Role-based access control (Admin/User)
   - Password hashing and security
   - Session management

### Frontend
- **Unified Dashboard** (Port 3000)
  - 🔐 **Login Page** - Secure authentication required
  - Real-time monitoring
  - Interactive charts
  - Cost analytics
  - K8s cluster view
  - Incident timeline
  - Automation controls
  - 👥 **User Management** (Admin only)

### Databases
- **Redis** - User storage, caching, and real-time data

## 🚀 Quick Start

```bash
# Start all services
docker-compose up -d

# Access the dashboard
open http://localhost:3000

# Login with default credentials
# Username: admin
# Password: admin123
```

> ⚠️ **Important**: Change the default admin password after first login!

## 📊 Features

### 🔐 Authentication & Security (NEW!)
- JWT token-based authentication
- Secure login page with modern UI
- User management dashboard (Admin only)
- Role-based access control (Admin/User)
- Password hashing (SHA256)
- Protected routes - all pages require login
- 24-hour token expiration
- Session management

### Cost Optimization
- Multi-cloud cost analysis (AWS, GCP, Azure)
- Rightsizing recommendations
- Unused resource detection
- Budget alerts and forecasting
- Cost anomaly detection
- Savings tracking

### Kubernetes Management
- Real-time cluster metrics
- Pod logs and events
- Resource quotas and limits
- Deployment strategies
- Horizontal Pod Autoscaler config
- Helm release management

### Incident Management
- Incident lifecycle tracking
- Severity-based routing
- On-call rotation management
- Auto-remediation playbooks
- Post-mortem templates
- SLA dashboard
- MTTR/MTTD metrics

### DevOps Automation
- GitHub Actions integration
- GitLab CI/CD support
- Terraform/CloudFormation execution
- Blue-green deployments
- Canary releases
- Rollback automation
- Approval workflows

### ChatOps
- `/cost` - Get cost analysis
- `/k8s` - Kubernetes operations
- `/incident` - Create/manage incidents
- `/deploy` - Trigger deployments
- `/status` - System status
- Natural language queries

### Metrics & Analytics
- Response time tracking
- Error rate monitoring
- Cost trends
- Resource utilization
- SLA compliance
- Custom dashboards

## 🎓 Learning Objectives

### DevOps/SRE Concepts
- Multi-cloud operations
- Kubernetes orchestration
- FinOps and cost optimization
- Incident response workflows
- CI/CD automation
- ChatOps patterns
- Observability and monitoring

### Technologies
- **Backend**: Python 3.11+, FastAPI
- **Frontend**: React 18, TypeScript
- **Databases**: PostgreSQL, Redis
- **Containerization**: Docker, Docker Compose
- **API Design**: REST, WebSocket
- **Authentication**: JWT (ready to add)
- **Monitoring**: Prometheus-compatible metrics

## 📚 API Documentation

Once running, access interactive API docs:
- Cost Optimizer: http://localhost:8001/docs
- K8s Manager: http://localhost:8002/docs
- Incident Manager: http://localhost:8003/docs
- Automation Service: http://localhost:8004/docs
- ChatOps Bot: http://localhost:8005/docs
- Metrics Collector: http://localhost:8006/docs

## 🔧 Development

### Local Setup

```bash
# Backend services (each in separate terminal)
cd services/cost-optimizer
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py

# Frontend
cd frontend
npm install
npm start
```

### Project Structure

```
cloudops-command-center/
├── services/
│   ├── cost-optimizer/         # Cloud cost analysis
│   ├── k8s-manager/           # Kubernetes operations
│   ├── incident-manager/      # Incident tracking
│   ├── automation-service/    # CI/CD automation
│   ├── chatops-bot/          # Chat interface
│   └── metrics-collector/    # Metrics aggregation
├── frontend/                  # React dashboard
├── docker-compose.yml        # Container orchestration
└── docs/                     # Documentation
```

## 🎯 Use Cases

### 1. Cost Optimization
- Identify unused EC2 instances
- Right-size over-provisioned resources
- Track spending trends
- Set budget alerts
- Compare cloud provider costs

### 2. Kubernetes Operations
- Monitor cluster health
- Scale deployments
- View pod logs
- Optimize resource requests/limits
- Deploy with Helm

### 3. Incident Response
- Create incidents from alerts
- Track MTTR metrics
- Execute runbooks
- Manage on-call schedules
- Generate post-mortems

### 4. Automation
- Deploy applications
- Provision infrastructure
- Run database migrations
- Execute maintenance tasks
- Schedule jobs

### 5. ChatOps
- Check system status via Slack
- Deploy from chat
- Create incidents via Discord
- Get cost reports in chat
- Approve deployments interactively

## 🔒 Security Features

- CORS enabled for frontend
- Input validation with Pydantic
- SQL injection protection
- Rate limiting (ready)
- JWT authentication (ready)
- RBAC (ready)
- Audit logging
- Secrets management

## 📈 Monitoring

The platform monitors itself:
- Service health checks
- Response time metrics
- Error rates
- Resource utilization
- Cost tracking
- SLA compliance

## 🌟 Advanced Features

### Cost Optimizer
- ML-based anomaly detection
- Forecasting algorithms
- Multi-currency support
- Custom tagging strategies
- Reserved instance recommendations

### K8s Manager
- Multi-cluster support
- GitOps integration
- Policy enforcement
- Security scanning
- Backup/restore

### Incident Manager
- Integration with PagerDuty/OpsGenie
- Automated escalation
- Incident correlation
- Blameless post-mortems
- SLO/SLI tracking

### Automation
- Approval gates
- Rollback strategies
- Dependency management
- Parallel execution
- Workflow templates

## 🚦 Getting Started Guide

1. **Start the platform**: `docker-compose up -d`
2. **Access dashboard**: http://localhost:3000
3. **Explore features**:
   - View mock cloud costs
   - Check K8s cluster status
   - Create test incident
   - Trigger mock deployment
   - View metrics

## 🤝 Contributing

This is a learning platform. Extend it with:
- Real cloud API integrations
- Additional cloud providers
- More automation workflows
- ML/AI predictions
- Custom dashboards
- Additional ChatOps platforms

## 📖 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [ChatOps Commands](docs/CHATOPS.md)
- [Security Guide](SECURITY_GUIDE.md)

## 🎓 Learning Resources

- [Cost Optimization Best Practices](docs/COST_OPTIMIZATION.md)
- [Kubernetes Operations](docs/K8S_OPERATIONS.md)
- [Incident Management](docs/INCIDENT_MANAGEMENT.md)
- [DevOps Automation](docs/AUTOMATION.md)

## 📊 Metrics & KPIs

Track important SRE metrics:
- **MTTR** (Mean Time To Recovery)
- **MTTD** (Mean Time To Detection)
- **Change Failure Rate**
- **Deployment Frequency**
- **SLA Compliance**
- **Cost Savings**

## 📚 Documentation

Complete documentation is available in the [`docs/`](docs/) directory:

### Quick Start Guides
- **[QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[AUTHENTICATION_QUICKSTART.md](docs/AUTHENTICATION_QUICKSTART.md)** - Authentication quick start
- **[GETTING_STARTED.md](docs/GETTING_STARTED.md)** - Detailed getting started guide

### Authentication & Security
- **[AUTHENTICATION_GUIDE.md](docs/AUTHENTICATION_GUIDE.md)** - Complete authentication guide (60+ sections)
- **[SECURITY_GUIDE.md](docs/SECURITY_GUIDE.md)** - Security best practices
- **[SECURITY_TOOLS_REFERENCE.md](docs/SECURITY_TOOLS_REFERENCE.md)** - All security tools used (34 tools)
- **[SECURITY_IMPLEMENTATION.md](docs/SECURITY_IMPLEMENTATION.md)** - Security implementation details

### Architecture & Development
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Platform architecture
- **[PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Project structure overview
- **[DASHBOARD_GUIDE.md](docs/DASHBOARD_GUIDE.md)** - Frontend dashboard guide
- **[LEARNING_GUIDE.md](docs/LEARNING_GUIDE.md)** - DevOps/SRE learning path

### CI/CD & Workflows
- **[GITHUB_ACTIONS_GUIDE.md](docs/GITHUB_ACTIONS_GUIDE.md)** - GitHub Actions setup
- **[WORKFLOWS_SUMMARY.md](docs/WORKFLOWS_SUMMARY.md)** - All workflows summary
- **[CICD.md](docs/CICD.md)** - CI/CD pipeline overview
- **[CICD_SETUP_GUIDE.md](docs/CICD_SETUP_GUIDE.md)** - CI/CD setup guide
- **[SRE_GOLDEN_PATH.md](docs/SRE_GOLDEN_PATH.md)** - SRE golden path

### Deployment
- **[HELM_DEPLOYMENT_GUIDE.md](docs/HELM_DEPLOYMENT_GUIDE.md)** - Kubernetes deployment with Helm
- **[HELM_SUMMARY.md](docs/HELM_SUMMARY.md)** - Helm chart overview

### Integration
- **[INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md)** - Complete integration guide
- **[QUICK_INTEGRATION_EXAMPLES.md](docs/QUICK_INTEGRATION_EXAMPLES.md)** - Quick integration examples
- **[README_INTEGRATION.md](docs/README_INTEGRATION.md)** - Integration overview
- **[INTEGRATION_SUMMARY.md](docs/INTEGRATION_SUMMARY.md)** - Integration checklist

### Summaries & Updates
- **[COMPLETE_PLATFORM_SUMMARY.md](docs/COMPLETE_PLATFORM_SUMMARY.md)** - Complete platform overview
- **[PLATFORM_UPDATE_SUMMARY.md](docs/PLATFORM_UPDATE_SUMMARY.md)** - Authentication update summary
- **[UPDATE_COMPLETE.md](docs/UPDATE_COMPLETE.md)** - Latest update checklist
- **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Implementation summary

### Total: 26 Documentation Files

All documentation is written in markdown and includes:
- Step-by-step guides
- Code examples
- API references
- Architecture diagrams
- Best practices
- Troubleshooting tips


## 🎯 Roadmap

- [ ] Real AWS/GCP/Azure integration
- [ ] Real Kubernetes cluster connection
- [ ] PagerDuty/OpsGenie integration
- [ ] GitHub Actions webhooks
- [ ] Terraform Cloud integration
- [ ] Advanced ML predictions
- [ ] Mobile app
- [ ] Multi-tenancy

## 🏆 Why This Platform?

**Real-world applicability**: Every feature addresses actual DevOps/SRE needs

**Portfolio-ready**: Demonstrates modern cloud-native architecture

**Production patterns**: Uses industry-standard practices

**Learning platform**: Covers breadth of DevOps/SRE topics

**Extensible**: Easy to add real integrations

---

**Built with ❤️ for DevOps/SRE learning**

Ready to optimize your cloud operations! 🚀☁️
