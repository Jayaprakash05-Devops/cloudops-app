import React, { useState, useEffect } from 'react'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import api from '../services/api'

function Metrics() {
  const [summary, setSummary] = useState(null)
  const [dashboards, setDashboards] = useState([])
  const [trends, setTrends] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [summaryRes, dashboardsRes, trendsRes] = await Promise.all([
        api.metrics.get('/metrics/summary'),
        api.metrics.get('/dashboards'),
        api.metrics.get('/analytics/trends?days=7')
      ])
      setSummary(summaryRes.data)
      setDashboards(dashboardsRes.data)
      setTrends(trendsRes.data)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load metrics:', error)
      setLoading(false)
    }
  }

  if (loading) return <div className="loading">Loading metrics...</div>

  const requestData = summary?.services
    ? Object.entries(summary.services).map(([name, data]) => ({
        name,
        requests: data.request_count
      }))
    : []

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>📈</span> Metrics & Analytics</h1>
        <p className="page-subtitle">Monitor performance and track system health</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card" style={{ '--card-color': '#667eea', '--card-color-dark': '#764ba2' }}>
          <div className="stat-icon">📊</div>
          <div className="stat-label">Total Requests Today</div>
          <div className="stat-value">{summary?.total_requests_today?.toLocaleString()}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#10b981', '--card-color-dark': '#059669' }}>
          <div className="stat-icon">⚡</div>
          <div className="stat-label">Avg Response Time</div>
          <div className="stat-value">{summary?.avg_response_time_ms}ms</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#ef4444', '--card-color-dark': '#dc2626' }}>
          <div className="stat-icon">❌</div>
          <div className="stat-label">Total Errors Today</div>
          <div className="stat-value">{summary?.total_errors_today}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#f59e0b', '--card-color-dark': '#d97706' }}>
          <div className="stat-icon">🎯</div>
          <div className="stat-label">Platform Health</div>
          <div className="stat-value">{summary?.platform_health}</div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📊 Request Volume by Service</h2>
        </div>
        <div className="card-content">
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={requestData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="requests" fill="#667eea" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📈 Performance Trends</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '20px' }}>
            {trends?.trends && Object.entries(trends.trends).map(([metric, data]) => (
              <div key={metric} style={{ padding: '20px', background: '#f8fafc', borderRadius: '12px' }}>
                <div style={{ fontWeight: 600, marginBottom: '12px', textTransform: 'capitalize' }}>
                  {metric.replace(/_/g, ' ')}
                </div>
                <div style={{ fontSize: '1.5rem', fontWeight: 700, marginBottom: '8px', color: data.trend === 'improving' ? '#10b981' : data.trend === 'increasing' ? '#f59e0b' : '#64748b' }}>
                  {data.trend === 'improving' ? '📉' : data.trend === 'increasing' ? '📈' : '➡️'} {data.change_percent > 0 ? '+' : ''}{data.change_percent}%
                </div>
                <div style={{ fontSize: '0.9rem', color: '#64748b' }}>
                  Current: {data.current_avg.toLocaleString()}<br />
                  Previous: {data.previous_avg.toLocaleString()}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📋 Available Dashboards</h2>
          <button className="btn btn-secondary" onClick={loadData}>Refresh</button>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
            {dashboards.map(dashboard => (
              <div key={dashboard.dashboard_id} style={{ padding: '20px', border: '2px solid #e2e8f0', borderRadius: '12px', cursor: 'pointer', transition: 'all 0.3s' }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.borderColor = '#667eea'
                  e.currentTarget.style.boxShadow = '0 4px 12px rgba(102, 126, 234, 0.15)'
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.borderColor = '#e2e8f0'
                  e.currentTarget.style.boxShadow = 'none'
                }}
              >
                <div style={{ fontWeight: 600, fontSize: '1.1rem', marginBottom: '8px' }}>
                  {dashboard.name}
                </div>
                <div style={{ fontSize: '0.9rem', color: '#64748b', marginBottom: '12px' }}>
                  {dashboard.description}
                </div>
                <div style={{ fontSize: '0.85rem', color: '#94a3b8' }}>
                  {dashboard.widgets.length} widgets
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🎯 Service Health</h2>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Service</th>
                <th>Status</th>
                <th>Response Time</th>
                <th>Requests</th>
                <th>Error Rate</th>
                <th>Uptime</th>
              </tr>
            </thead>
            <tbody>
              {summary?.services && Object.entries(summary.services).map(([name, service]) => (
                <tr key={name}>
                  <td style={{ fontWeight: 600 }}>{name}</td>
                  <td><span className="badge badge-success">{service.status}</span></td>
                  <td>{service.response_time_ms}ms</td>
                  <td>{service.request_count.toLocaleString()}</td>
                  <td>{service.error_rate}%</td>
                  <td>{service.uptime_percent}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default Metrics
