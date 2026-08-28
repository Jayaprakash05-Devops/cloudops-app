import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { LineChart, Line, BarChart, Bar, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import api from '../services/api'

const COLORS = ['#667eea', '#764ba2', '#f59e0b', '#10b981', '#ef4444', '#06b6d4']

function Dashboard() {
  const [loading, setLoading] = useState(true)
  const [data, setData] = useState({
    costs: null,
    incidents: null,
    clusters: null,
    pipelines: null,
    metrics: null
  })

  useEffect(() => {
    loadDashboardData()
  }, [])

  const loadDashboardData = async () => {
    try {
      const [costs, incidents, clusters, pipelines, metrics] = await Promise.all([
        api.costOptimizer.get('/costs/summary'),
        api.incidentManager.get('/incidents/stats/summary'),
        api.k8sManager.get('/clusters'),
        api.automation.get('/pipelines?limit=5'),
        api.metrics.get('/metrics/summary')
      ])

      setData({
        costs: costs.data,
        incidents: incidents.data,
        clusters: clusters.data,
        pipelines: pipelines.data,
        metrics: metrics.data
      })
      setLoading(false)
    } catch (error) {
      console.error('Failed to load dashboard data:', error)
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="loading">Loading dashboard...</div>
  }

  const costByProvider = data.costs?.by_provider
    ? Object.entries(data.costs.by_provider).map(([name, data]) => ({
        name,
        value: data.monthly
      }))
    : []

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title">
          <span>📊</span>
          CloudOps Command Center
        </h1>
        <p className="page-subtitle">
          Real-time monitoring and management for your cloud infrastructure
        </p>
      </div>

      <div className="stats-grid">
        <Link to="/cost-optimizer" style={{ textDecoration: 'none' }}>
          <div className="stat-card" style={{ '--card-color': '#10b981', '--card-color-dark': '#059669' }}>
            <div className="stat-icon">💰</div>
            <div className="stat-label">Daily Cloud Spend</div>
            <div className="stat-value">${data.costs?.total_daily_cost?.toLocaleString() || '0'}</div>
            <div className="stat-change">Across {data.costs?.total_resources || 0} resources</div>
          </div>
        </Link>

        <Link to="/kubernetes" style={{ textDecoration: 'none' }}>
          <div className="stat-card" style={{ '--card-color': '#06b6d4', '--card-color-dark': '#0891b2' }}>
            <div className="stat-icon">☸️</div>
            <div className="stat-label">K8s Clusters</div>
            <div className="stat-value">{data.clusters?.length || 0}</div>
            <div className="stat-change">All clusters healthy</div>
          </div>
        </Link>

        <Link to="/incidents" style={{ textDecoration: 'none' }}>
          <div className="stat-card" style={{ '--card-color': '#ef4444', '--card-color-dark': '#dc2626' }}>
            <div className="stat-icon">🚨</div>
            <div className="stat-label">Open Incidents</div>
            <div className="stat-value">{data.incidents?.open_incidents || 0}</div>
            <div className="stat-change">MTTR: {data.incidents?.mttr_hours?.toFixed(1) || 0}h</div>
          </div>
        </Link>

        <Link to="/automation" style={{ textDecoration: 'none' }}>
          <div className="stat-card" style={{ '--card-color': '#8b5cf6', '--card-color-dark': '#7c3aed' }}>
            <div className="stat-icon">🤖</div>
            <div className="stat-label">Active Pipelines</div>
            <div className="stat-value">{data.pipelines?.filter(p => p.status === 'running').length || 0}</div>
            <div className="stat-change">{data.pipelines?.length || 0} total today</div>
          </div>
        </Link>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(500px, 1fr))', gap: '24px' }}>
        <div className="card">
          <div className="card-header">
            <h2 className="card-title">💰 Cost by Cloud Provider</h2>
            <Link to="/cost-optimizer">View Details →</Link>
          </div>
          <div className="card-content">
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={costByProvider}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={(entry) => `${entry.name}: $${entry.value.toLocaleString()}`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {costByProvider.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <h2 className="card-title">🚨 Incidents by Severity</h2>
            <Link to="/incidents">View All →</Link>
          </div>
          <div className="card-content">
            {data.incidents?.by_severity && (
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={Object.entries(data.incidents.by_severity).map(([name, count]) => ({ name, count }))}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="count" fill="#ef4444" />
                </BarChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📊 Platform Health Overview</h2>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Service</th>
                <th>Status</th>
                <th>Response Time</th>
                <th>Uptime</th>
                <th>Requests</th>
              </tr>
            </thead>
            <tbody>
              {data.metrics?.services && Object.entries(data.metrics.services).map(([name, service]) => (
                <tr key={name}>
                  <td style={{ fontWeight: 600 }}>{name}</td>
                  <td><span className="badge badge-success">Healthy</span></td>
                  <td>{service.response_time_ms}ms</td>
                  <td>{service.uptime_percent}%</td>
                  <td>{service.request_count.toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🎯 Quick Actions</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
            <Link to="/cost-optimizer" className="btn btn-primary">View Cost Analysis</Link>
            <Link to="/kubernetes" className="btn btn-primary">Manage Clusters</Link>
            <Link to="/incidents" className="btn btn-primary">Create Incident</Link>
            <Link to="/automation" className="btn btn-primary">Deploy Application</Link>
            <Link to="/chatops" className="btn btn-primary">Open ChatOps</Link>
            <Link to="/guide" className="btn btn-secondary">📚 View User Guide</Link>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Dashboard
