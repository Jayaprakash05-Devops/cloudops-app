import React, { useState, useEffect } from 'react'
import api from '../services/api'

function AutomationService() {
  const [pipelines, setPipelines] = useState([])
  const [deployments, setDeployments] = useState([])
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [pipelinesRes, deploymentsRes, statsRes] = await Promise.all([
        api.automation.get('/pipelines?limit=10'),
        api.automation.get('/deployments'),
        api.automation.get('/deployments/stats/summary')
      ])
      setPipelines(pipelinesRes.data)
      setDeployments(deploymentsRes.data)
      setStats(statsRes.data)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load automation data:', error)
      setLoading(false)
    }
  }

  const handleTriggerPipeline = async () => {
    const pipelineName = prompt('Enter pipeline name:', 'backend-api')
    const environment = prompt('Enter environment:', 'staging')
    if (pipelineName && environment) {
      try {
        await api.automation.post(`/pipelines/trigger?pipeline_name=${pipelineName}&environment=${environment}`)
        alert(`Pipeline ${pipelineName} triggered for ${environment}`)
        loadData()
      } catch (error) {
        alert('Failed to trigger pipeline')
      }
    }
  }

  if (loading) return <div className="loading">Loading automation data...</div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>🤖</span> Automation Service</h1>
        <p className="page-subtitle">CI/CD pipelines and deployment automation</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card" style={{ '--card-color': '#8b5cf6', '--card-color-dark': '#7c3aed' }}>
          <div className="stat-icon">📦</div>
          <div className="stat-label">Deployments This Week</div>
          <div className="stat-value">{stats?.this_week}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#10b981', '--card-color-dark': '#059669' }}>
          <div className="stat-icon">✅</div>
          <div className="stat-label">Success Rate</div>
          <div className="stat-value">{stats?.success_rate}%</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#06b6d4', '--card-color-dark': '#0891b2' }}>
          <div className="stat-icon">⏱️</div>
          <div className="stat-label">Avg Duration</div>
          <div className="stat-value">{stats?.avg_duration_minutes}m</div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🚀 CI/CD Pipelines</h2>
          <button className="btn btn-success" onClick={handleTriggerPipeline}>+ Trigger Pipeline</button>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Pipeline ID</th>
                <th>Name</th>
                <th>Environment</th>
                <th>Status</th>
                <th>Triggered By</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              {pipelines.map(pipeline => (
                <tr key={pipeline.pipeline_id}>
                  <td style={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>{pipeline.pipeline_id}</td>
                  <td style={{ fontWeight: 600 }}>{pipeline.name}</td>
                  <td>{pipeline.environment}</td>
                  <td>
                    <span className={`badge ${
                      pipeline.status === 'success' ? 'badge-success' :
                      pipeline.status === 'failed' ? 'badge-danger' :
                      pipeline.status === 'running' ? 'badge-info' :
                      'badge-warning'
                    }`}>
                      {pipeline.status}
                    </span>
                  </td>
                  <td style={{ fontSize: '0.85rem' }}>{pipeline.triggered_by}</td>
                  <td>{pipeline.duration || 'In progress...'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🎯 Deployments</h2>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Application</th>
                <th>Version</th>
                <th>Environment</th>
                <th>Strategy</th>
                <th>Progress</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {deployments.map(deployment => (
                <tr key={deployment.deployment_id}>
                  <td style={{ fontWeight: 600 }}>{deployment.application}</td>
                  <td style={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>{deployment.version}</td>
                  <td>{deployment.environment}</td>
                  <td>{deployment.strategy}</td>
                  <td>
                    <div style={{ width: '100px', height: '8px', background: '#e2e8f0', borderRadius: '4px', overflow: 'hidden' }}>
                      <div style={{ width: `${deployment.progress}%`, height: '100%', background: '#10b981', transition: 'width 0.3s' }}></div>
                    </div>
                    <span style={{ fontSize: '0.85rem', marginLeft: '8px' }}>{deployment.progress}%</span>
                  </td>
                  <td>
                    <span className={`badge ${
                      deployment.status === 'completed' ? 'badge-success' :
                      deployment.status === 'failed' ? 'badge-danger' :
                      'badge-info'
                    }`}>
                      {deployment.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📊 Deployment Statistics</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
            {stats?.by_environment && Object.entries(stats.by_environment).map(([env, data]) => (
              <div key={env} style={{ padding: '15px', background: '#f8fafc', borderRadius: '8px' }}>
                <div style={{ fontWeight: 600, marginBottom: '8px', textTransform: 'capitalize' }}>{env}</div>
                <div style={{ fontSize: '0.9rem', color: '#64748b' }}>
                  Deployments: {data.count}<br />
                  Success Rate: {data.success_rate}%
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

export default AutomationService
