import React, { useState } from 'react'

function UserGuide() {
  const [activeSection, setActiveSection] = useState('overview')

  const sections = {
    overview: {
      title: '📚 Platform Overview',
      content: (
        <>
          <h2>Welcome to CloudOps Command Center!</h2>
          <p>CloudOps Command Center is a comprehensive DevOps/SRE learning platform that simulates real-world cloud operations, Kubernetes management, incident response, and automation workflows.</p>
          
          <h3>🎯 What You Can Learn</h3>
          <ul>
            <li><strong>Cloud Cost Optimization (FinOps)</strong> - Multi-cloud cost tracking and optimization strategies</li>
            <li><strong>Kubernetes Operations</strong> - Container orchestration and cluster management</li>
            <li><strong>Incident Management (SRE)</strong> - Incident response workflows and on-call management</li>
            <li><strong>CI/CD Automation</strong> - Pipeline orchestration and deployment strategies</li>
            <li><strong>ChatOps</strong> - Operations through chat interfaces</li>
            <li><strong>Observability</strong> - Metrics collection and system monitoring</li>
          </ul>

          <h3>🏗️ Architecture</h3>
          <p>The platform consists of 6 microservices:</p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px', marginTop: '15px' }}>
            {[
              { name: 'Cost Optimizer', port: '8001', icon: '💰' },
              { name: 'K8s Manager', port: '8002', icon: '☸️' },
              { name: 'Incident Manager', port: '8003', icon: '🚨' },
              { name: 'Automation Service', port: '8004', icon: '🤖' },
              { name: 'ChatOps Bot', port: '8005', icon: '💬' },
              { name: 'Metrics Collector', port: '8006', icon: '📊' }
            ].map(service => (
              <div key={service.port} style={{ padding: '15px', background: '#f8fafc', borderRadius: '8px', textAlign: 'center' }}>
                <div style={{ fontSize: '2rem' }}>{service.icon}</div>
                <div style={{ fontWeight: 600, margin: '8px 0' }}>{service.name}</div>
                <div style={{ fontSize: '0.85rem', color: '#64748b' }}>Port {service.port}</div>
              </div>
            ))}
          </div>
        </>
      )
    },
    cost: {
      title: '💰 Cost Optimizer Guide',
      content: (
        <>
          <h2>Cost Optimizer - Cloud Cost Management</h2>
          <p>Track and optimize spending across AWS, GCP, and Azure.</p>

          <h3>Key Features</h3>
          <ul>
            <li><strong>Cost Summary</strong> - View daily and monthly costs across all cloud providers</li>
            <li><strong>Cost Trends</strong> - Analyze spending patterns over time with interactive charts</li>
            <li><strong>Recommendations</strong> - Get actionable optimization suggestions (unused resources, right-sizing)</li>
            <li><strong>Budget Alerts</strong> - Monitor spending against budgets and get alerts when thresholds are exceeded</li>
            <li><strong>Forecasting</strong> - Predict future costs based on historical trends</li>
          </ul>

          <h3>How to Use</h3>
          <ol>
            <li><strong>View Cost Summary</strong> - Navigate to Cost Optimizer to see current spending breakdown</li>
            <li><strong>Analyze Trends</strong> - Use the trend chart to identify spending patterns</li>
            <li><strong>Review Recommendations</strong> - Check the recommendations section for cost-saving opportunities</li>
            <li><strong>Check Budget Alerts</strong> - Monitor alerts for any budget overruns</li>
          </ol>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /costs/summary - Get cost summary<br />
            GET /costs/details - Get detailed cost breakdown<br />
            GET /costs/trends?days=30 - Get cost trends<br />
            GET /recommendations - Get optimization recommendations<br />
            GET /budget/alerts - Get budget alerts<br />
            GET /forecast?days=30 - Get cost forecast
          </div>

          <h3>Example Use Case</h3>
          <p><strong>Scenario:</strong> Your monthly cloud bill is too high. Here's how to investigate:</p>
          <ol>
            <li>Check <strong>Cost Summary</strong> to identify which provider is most expensive</li>
            <li>Review <strong>Recommendations</strong> for unused or idle resources</li>
            <li>Analyze <strong>Trends</strong> to see if spending is increasing</li>
            <li>Check <strong>Budget Alerts</strong> to see if you're over budget</li>
            <li>Use <strong>Forecast</strong> to predict next month's spending</li>
          </ol>
        </>
      )
    },
    kubernetes: {
      title: '☸️ Kubernetes Manager Guide',
      content: (
        <>
          <h2>Kubernetes Manager - Container Orchestration</h2>
          <p>Manage Kubernetes clusters, pods, and deployments.</p>

          <h3>Key Features</h3>
          <ul>
            <li><strong>Multi-Cluster Management</strong> - Monitor multiple K8s clusters (AWS EKS, GCP GKE, Azure AKS)</li>
            <li><strong>Pod Operations</strong> - View pod status, logs, and resource usage</li>
            <li><strong>Deployment Management</strong> - Scale and manage deployments</li>
            <li><strong>Node Monitoring</strong> - Check node health and resource allocation</li>
            <li><strong>Optimization Recommendations</strong> - Get suggestions for resource optimization</li>
          </ul>

          <h3>How to Use</h3>
          <ol>
            <li><strong>View Clusters</strong> - See all available clusters with their health status</li>
            <li><strong>Check Pods</strong> - Monitor running, pending, and failed pods</li>
            <li><strong>Scale Deployments</strong> - Use the "Scale" buttons to adjust replica counts</li>
            <li><strong>View Logs</strong> - Access pod logs for debugging</li>
          </ol>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /clusters - List all clusters<br />
            GET /clusters/&#123;id&#125;/health - Get cluster health<br />
            GET /pods?namespace=default - List pods<br />
            GET /pods/&#123;namespace&#125;/&#123;pod&#125;/logs - Get pod logs<br />
            GET /deployments - List deployments<br />
            POST /deployments/&#123;ns&#125;/&#123;name&#125;/scale?replicas=5 - Scale deployment<br />
            GET /recommendations - Get optimization recommendations
          </div>

          <h3>Common Operations</h3>
          <h4>Scaling a Deployment</h4>
          <ol>
            <li>Navigate to Kubernetes Manager</li>
            <li>Click "Scale Frontend" or "Scale Backend"</li>
            <li>Enter desired replica count</li>
            <li>Confirm and monitor the scaling operation</li>
          </ol>

          <h4>Troubleshooting a Failed Pod</h4>
          <ol>
            <li>Find the failed pod in the Pods table</li>
            <li>Note the pod name and namespace</li>
            <li>Use API: GET /pods/&#123;namespace&#125;/&#123;pod&#125; for details</li>
            <li>Check logs with: GET /pods/&#123;namespace&#125;/&#123;pod&#125;/logs</li>
          </ol>
        </>
      )
    },
    incidents: {
      title: '🚨 Incident Manager Guide',
      content: (
        <>
          <h2>Incident Manager - SRE Operations</h2>
          <p>Track incidents, manage on-call schedules, and maintain SLA compliance.</p>

          <h3>Key Features</h3>
          <ul>
            <li><strong>Incident Tracking</strong> - Create and manage incidents with severity levels</li>
            <li><strong>On-Call Management</strong> - View and page on-call engineers</li>
            <li><strong>SLA Monitoring</strong> - Track uptime and compliance</li>
            <li><strong>Post-Mortems</strong> - Document incident learnings</li>
            <li><strong>Runbooks</strong> - Execute automated remediation workflows</li>
            <li><strong>MTTR/MTTD Tracking</strong> - Monitor key SRE metrics</li>
          </ul>

          <h3>Incident Severity Levels</h3>
          <ul>
            <li><strong>Critical</strong> - Complete service outage or data loss</li>
            <li><strong>High</strong> - Major degradation affecting many users</li>
            <li><strong>Medium</strong> - Partial degradation affecting some users</li>
            <li><strong>Low</strong> - Minor issues with workarounds available</li>
          </ul>

          <h3>How to Create an Incident</h3>
          <ol>
            <li>Navigate to Incident Manager</li>
            <li>Click "+ Create Incident"</li>
            <li>Fill in the form:
              <ul>
                <li>Title: Brief description of the issue</li>
                <li>Description: Detailed information</li>
                <li>Severity: Critical/High/Medium/Low</li>
                <li>Service: Affected service name</li>
              </ul>
            </li>
            <li>Submit and the incident will be created</li>
          </ol>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /incidents - List all incidents<br />
            GET /incidents/stats/summary - Get incident statistics<br />
            POST /incidents - Create new incident<br />
            GET /oncall - Get on-call schedule<br />
            POST /oncall/page - Page on-call engineer<br />
            GET /sla/compliance - Get SLA metrics<br />
            GET /postmortems - Get post-mortem reports<br />
            POST /runbooks/&#123;id&#125;/execute - Execute runbook
          </div>

          <h3>SRE Best Practices</h3>
          <ul>
            <li><strong>Respond Quickly</strong> - Acknowledge incidents within SLA timeframes</li>
            <li><strong>Communicate</strong> - Keep stakeholders informed of status</li>
            <li><strong>Document</strong> - Create detailed post-mortems for learning</li>
            <li><strong>Automate</strong> - Use runbooks for common remediation tasks</li>
            <li><strong>Monitor Metrics</strong> - Track MTTR, MTTD, and SLA compliance</li>
          </ul>
        </>
      )
    },
    automation: {
      title: '🤖 Automation Service Guide',
      content: (
        <>
          <h2>Automation Service - CI/CD & Infrastructure</h2>
          <p>Orchestrate pipelines, manage deployments, and automate infrastructure.</p>

          <h3>Key Features</h3>
          <ul>
            <li><strong>CI/CD Pipelines</strong> - Trigger and monitor build/test/deploy pipelines</li>
            <li><strong>Deployment Strategies</strong> - Rolling, Blue-Green, and Canary deployments</li>
            <li><strong>Scheduled Jobs</strong> - Automate recurring tasks</li>
            <li><strong>Infrastructure Provisioning</strong> - Deploy resources as code</li>
            <li><strong>Approval Workflows</strong> - Gate production deployments</li>
          </ul>

          <h3>Deployment Strategies</h3>
          <h4>Rolling Deployment</h4>
          <p>Gradually replace old instances with new ones. Safe and simple, but slower.</p>

          <h4>Blue-Green Deployment</h4>
          <p>Run two identical environments. Switch traffic instantly. Easy rollback but doubles resource cost.</p>

          <h4>Canary Deployment</h4>
          <p>Release to small percentage of users first. Lowest risk but more complex.</p>

          <h3>How to Trigger a Pipeline</h3>
          <ol>
            <li>Navigate to Automation Service</li>
            <li>Click "+ Trigger Pipeline"</li>
            <li>Enter:
              <ul>
                <li>Pipeline name (e.g., "backend-api")</li>
                <li>Environment (staging/production)</li>
              </ul>
            </li>
            <li>Monitor pipeline progress in the table</li>
          </ol>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /pipelines - List pipeline runs<br />
            POST /pipelines/trigger - Trigger new pipeline<br />
            GET /deployments - List deployments<br />
            POST /deployments/create - Create deployment<br />
            POST /deployments/&#123;id&#125;/rollback - Rollback deployment<br />
            GET /jobs - List scheduled jobs<br />
            POST /jobs/&#123;id&#125;/trigger - Manually trigger job<br />
            GET /approvals/pending - Get pending approvals
          </div>

          <h3>Best Practices</h3>
          <ul>
            <li><strong>Test First</strong> - Always deploy to staging before production</li>
            <li><strong>Automate Tests</strong> - Run automated tests in pipelines</li>
            <li><strong>Use Feature Flags</strong> - Decouple deployment from feature release</li>
            <li><strong>Monitor Deployments</strong> - Watch metrics during and after deployment</li>
            <li><strong>Plan Rollbacks</strong> - Know how to quickly revert if needed</li>
          </ul>
        </>
      )
    },
    chatops: {
      title: '💬 ChatOps Guide',
      content: (
        <>
          <h2>ChatOps - Operations Through Chat</h2>
          <p>Control your infrastructure using chat commands.</p>

          <h3>Available Commands</h3>
          <div style={{ background: '#f8fafc', padding: '20px', borderRadius: '8px', marginTop: '15px' }}>
            <h4>/status</h4>
            <p>Get overall system status</p>

            <h4>/cost</h4>
            <p>View current cloud costs</p>

            <h4>/k8s pods</h4>
            <p>List Kubernetes pods</p>

            <h4>/k8s scale</h4>
            <p>Scale a deployment</p>

            <h4>/incident create</h4>
            <p>Create a new incident</p>

            <h4>/incident list</h4>
            <p>List open incidents</p>

            <h4>/deploy</h4>
            <p>Trigger a deployment</p>

            <h4>/approve</h4>
            <p>Approve pending deployment</p>

            <h4>/oncall</h4>
            <p>Check who's on-call</p>

            <h4>/help</h4>
            <p>Show all available commands</p>
          </div>

          <h3>How to Use</h3>
          <ol>
            <li>Navigate to ChatOps page</li>
            <li>Click on a command from the "Available Commands" list, or type one manually</li>
            <li>Click "Execute Command"</li>
            <li>View the response in the output area</li>
          </ol>

          <h3>Platform Integrations</h3>
          <ul>
            <li><strong>Discord</strong> - Connected and ready</li>
            <li><strong>Slack</strong> - Ready to connect</li>
            <li><strong>Microsoft Teams</strong> - Not yet configured</li>
          </ul>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /commands - List available commands<br />
            POST /commands/execute - Execute a command<br />
            GET /commands/history - Get command history<br />
            POST /notifications/send - Send notification<br />
            GET /integrations - Get platform integrations<br />
            GET /stats - Get bot usage statistics
          </div>
        </>
      )
    },
    metrics: {
      title: '📊 Metrics & Analytics Guide',
      content: (
        <>
          <h2>Metrics Collector - Observability</h2>
          <p>Monitor system performance and analyze trends.</p>

          <h3>Key Metrics</h3>
          <ul>
            <li><strong>Response Time</strong> - How quickly services respond to requests</li>
            <li><strong>Request Count</strong> - Total number of requests per service</li>
            <li><strong>Error Rate</strong> - Percentage of failed requests</li>
            <li><strong>Uptime</strong> - Service availability percentage</li>
          </ul>

          <h3>Available Dashboards</h3>
          <ol>
            <li><strong>Platform Overview</strong> - High-level view of all services</li>
            <li><strong>Cost Analytics</strong> - Cloud cost metrics and trends</li>
            <li><strong>Kubernetes Health</strong> - K8s cluster metrics</li>
          </ol>

          <h3>Trend Analysis</h3>
          <p>The platform tracks trends in key metrics:</p>
          <ul>
            <li>📉 <strong>Improving</strong> - Metric is getting better (e.g., response time decreasing)</li>
            <li>📈 <strong>Increasing</strong> - Metric is growing (e.g., request volume up)</li>
            <li>➡️ <strong>Stable</strong> - Metric unchanged</li>
          </ul>

          <h3>API Endpoints</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem' }}>
            GET /metrics/summary - Get all service metrics<br />
            GET /metrics/current - Get current metrics<br />
            GET /metrics/&#123;service&#125;/&#123;type&#125; - Get specific metric<br />
            GET /metrics/compare - Compare across services<br />
            GET /dashboards - List dashboards<br />
            GET /analytics/trends - Get trend analysis<br />
            GET /analytics/correlations - Get metric correlations<br />
            POST /analytics/query - Execute custom query
          </div>

          <h3>How to Monitor System Health</h3>
          <ol>
            <li>Check the <strong>Service Health</strong> table for overall status</li>
            <li>Review <strong>Performance Trends</strong> for any degradation</li>
            <li>Use <strong>Request Volume</strong> chart to identify busy services</li>
            <li>Investigate services with high error rates or response times</li>
          </ol>
        </>
      )
    },
    api: {
      title: '🔌 API Reference',
      content: (
        <>
          <h2>API Documentation</h2>
          <p>All services provide RESTful APIs with OpenAPI (Swagger) documentation.</p>

          <h3>Interactive API Docs</h3>
          <p>Visit these URLs to explore and test APIs interactively:</p>
          <ul>
            <li><a href="http://localhost:8001/docs" target="_blank" rel="noopener noreferrer">Cost Optimizer API</a> (Port 8001)</li>
            <li><a href="http://localhost:8002/docs" target="_blank" rel="noopener noreferrer">K8s Manager API</a> (Port 8002)</li>
            <li><a href="http://localhost:8003/docs" target="_blank" rel="noopener noreferrer">Incident Manager API</a> (Port 8003)</li>
            <li><a href="http://localhost:8004/docs" target="_blank" rel="noopener noreferrer">Automation Service API</a> (Port 8004)</li>
            <li><a href="http://localhost:8005/docs" target="_blank" rel="noopener noreferrer">ChatOps Bot API</a> (Port 8005)</li>
            <li><a href="http://localhost:8006/docs" target="_blank" rel="noopener noreferrer">Metrics Collector API</a> (Port 8006)</li>
          </ul>

          <h3>Example API Calls</h3>
          <div style={{ background: '#1e293b', color: '#f1f5f9', padding: '15px', borderRadius: '8px', fontFamily: 'monospace', fontSize: '0.9rem', marginTop: '15px' }}>
            # Get cost summary<br />
            curl http://localhost:8001/costs/summary<br />
            <br />
            # List Kubernetes clusters<br />
            curl http://localhost:8002/clusters<br />
            <br />
            # Create incident<br />
            curl -X POST "http://localhost:8003/incidents?title=API%20Down&severity=high&service=api"<br />
            <br />
            # Trigger pipeline<br />
            curl -X POST "http://localhost:8004/pipelines/trigger?pipeline_name=backend&environment=staging"<br />
            <br />
            # Execute ChatOps command<br />
            curl -X POST http://localhost:8005/commands/execute \<br />
            &nbsp;&nbsp;-H "Content-Type: application/json" \<br />
            &nbsp;&nbsp;-d '&#123;"command":"/status","user":"you","channel":"ops"&#125;'<br />
            <br />
            # Get metrics summary<br />
            curl http://localhost:8006/metrics/summary
          </div>
        </>
      )
    },
    troubleshooting: {
      title: '🔧 Troubleshooting',
      content: (
        <>
          <h2>Common Issues & Solutions</h2>

          <h3>Services Not Loading</h3>
          <p><strong>Problem:</strong> Dashboard shows "Loading..." forever or errors</p>
          <p><strong>Solution:</strong></p>
          <ol>
            <li>Check if backend services are running: <code>docker-compose ps</code></li>
            <li>Restart services: <code>docker-compose restart</code></li>
            <li>Check logs: <code>docker-compose logs -f [service-name]</code></li>
          </ol>

          <h3>API Connection Errors</h3>
          <p><strong>Problem:</strong> CORS errors or connection refused</p>
          <p><strong>Solution:</strong></p>
          <ol>
            <li>Verify services are healthy: <code>curl http://localhost:8001/health</code></li>
            <li>Check that all services are on correct ports</li>
            <li>Ensure no firewall blocking localhost connections</li>
          </ol>

          <h3>Docker Issues</h3>
          <p><strong>Problem:</strong> Services fail to start</p>
          <p><strong>Solution:</strong></p>
          <ol>
            <li>Check Docker is running: <code>docker ps</code></li>
            <li>Rebuild images: <code>docker-compose up -d --build</code></li>
            <li>Clean and restart: <code>docker-compose down -v && docker-compose up -d --build</code></li>
          </ol>

          <h3>Port Already in Use</h3>
          <p><strong>Problem:</strong> "Port is already allocated" error</p>
          <p><strong>Solution:</strong></p>
          <ol>
            <li>Check what's using the port: <code>lsof -i :8001</code></li>
            <li>Stop the conflicting process or change ports in docker-compose.yml</li>
          </ol>

          <h3>Getting Help</h3>
          <ul>
            <li>Check <code>docker-compose logs</code> for error messages</li>
            <li>Review README.md for setup instructions</li>
            <li>Check service health endpoints: <code>http://localhost:800X/health</code></li>
            <li>Run test script: <code>./test-services.sh</code></li>
          </ul>
        </>
      )
    }
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>📚</span> User Guide</h1>
        <p className="page-subtitle">Complete documentation for CloudOps Command Center</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '250px 1fr', gap: '30px' }}>
        <div className="card" style={{ height: 'fit-content', position: 'sticky', top: '30px' }}>
          <div className="card-header">
            <h3 className="card-title">Contents</h3>
          </div>
          <div className="card-content">
            <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {Object.entries(sections).map(([key, section]) => (
                <button
                  key={key}
                  onClick={() => setActiveSection(key)}
                  className={activeSection === key ? 'btn btn-primary' : 'btn btn-secondary'}
                  style={{ width: '100%', textAlign: 'left', padding: '10px 15px', fontSize: '0.9rem' }}
                >
                  {section.title}
                </button>
              ))}
            </nav>
          </div>
        </div>

        <div className="card">
          <div className="card-content" style={{ fontSize: '1rem', lineHeight: '1.6' }}>
            {sections[activeSection].content}
          </div>
        </div>
      </div>
    </div>
  )
}

export default UserGuide
