import React, { useState, useEffect } from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import api from '../services/api'

function CostOptimizer() {
  const [summary, setSummary] = useState(null)
  const [recommendations, setRecommendations] = useState([])
  const [trends, setTrends] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [summaryRes, recsRes, trendsRes] = await Promise.all([
        api.costOptimizer.get('/costs/summary'),
        api.costOptimizer.get('/recommendations/summary'),
        api.costOptimizer.get('/costs/trends?days=7')
      ])

      setSummary(summaryRes.data)
      setRecommendations(recsRes.data)
      setTrends(trendsRes.data.trends)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load cost data:', error)
      setLoading(false)
    }
  }

  if (loading) return <div className="loading">Loading cost data...</div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>💰</span> Cost Optimizer</h1>
        <p className="page-subtitle">Multi-cloud cost analysis and optimization recommendations</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card" style={{ '--card-color': '#10b981', '--card-color-dark': '#059669' }}>
          <div className="stat-icon">💵</div>
          <div className="stat-label">Daily Cost</div>
          <div className="stat-value">${summary?.total_daily_cost?.toLocaleString()}</div>
        </div>

        <div className="stat-card" style={{ '--card-color': '#f59e0b', '--card-color-dark': '#d97706' }}>
          <div className="stat-icon">📅</div>
          <div className="stat-label">Monthly Cost</div>
          <div className="stat-value">${summary?.total_monthly_cost?.toLocaleString()}</div>
        </div>

        <div className="stat-card" style={{ '--card-color': '#8b5cf6', '--card-color-dark': '#7c3aed' }}>
          <div className="stat-icon">💡</div>
          <div className="stat-label">Potential Savings</div>
          <div className="stat-value">${recommendations?.potential_monthly_savings?.toLocaleString()}</div>
        </div>

        <div className="stat-card" style={{ '--card-color': '#06b6d4', '--card-color-dark': '#0891b2' }}>
          <div className="stat-icon">🎯</div>
          <div className="stat-label">Recommendations</div>
          <div className="stat-value">{recommendations?.total_recommendations}</div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📈 Cost Trends (Last 7 Days)</h2>
        </div>
        <div className="card-content">
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={trends}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="cost" stroke="#667eea" strokeWidth={2} name="Total Cost" />
              <Line type="monotone" dataKey="aws" stroke="#ff9900" strokeWidth={2} name="AWS" />
              <Line type="monotone" dataKey="gcp" stroke="#4285f4" strokeWidth={2} name="GCP" />
              <Line type="monotone" dataKey="azure" stroke="#008ad7" strokeWidth={2} name="Azure" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">☁️ Cost by Provider</h2>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Provider</th>
                <th>Daily Cost</th>
                <th>Monthly Cost</th>
                <th>Resources</th>
              </tr>
            </thead>
            <tbody>
              {summary?.by_provider && Object.entries(summary.by_provider).map(([provider, data]) => (
                <tr key={provider}>
                  <td style={{ fontWeight: 600 }}>{provider}</td>
                  <td>${data.daily?.toLocaleString()}</td>
                  <td>${data.monthly?.toLocaleString()}</td>
                  <td>{data.resources}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">💡 Optimization Recommendations</h2>
        </div>
        <div className="card-content">
          <div style={{ marginBottom: '20px' }}>
            <strong>Priority Breakdown:</strong>
            {recommendations?.by_priority && (
              <div style={{ display: 'flex', gap: '20px', marginTop: '10px' }}>
                <div>
                  <span className="badge badge-danger">High</span>
                  <span style={{ marginLeft: '8px' }}>
                    {recommendations.by_priority.high.count} items
                    (${recommendations.by_priority.high.savings.toLocaleString()} savings)
                  </span>
                </div>
                <div>
                  <span className="badge badge-warning">Medium</span>
                  <span style={{ marginLeft: '8px' }}>
                    {recommendations.by_priority.medium.count} items
                    (${recommendations.by_priority.medium.savings.toLocaleString()} savings)
                  </span>
                </div>
              </div>
            )}
          </div>
          <button className="btn btn-primary" onClick={loadData}>Refresh Recommendations</button>
        </div>
      </div>
    </div>
  )
}

export default CostOptimizer
