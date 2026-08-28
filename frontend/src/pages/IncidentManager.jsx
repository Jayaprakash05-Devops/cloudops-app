import React, { useState, useEffect } from 'react'
import api from '../services/api'

function IncidentManager() {
  const [incidents, setIncidents] = useState([])
  const [stats, setStats] = useState(null)
  const [oncall, setOncall] = useState([])
  const [loading, setLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [incidentsRes, statsRes, oncallRes] = await Promise.all([
        api.incidentManager.get('/incidents'),
        api.incidentManager.get('/incidents/stats/summary'),
        api.incidentManager.get('/oncall')
      ])
      setIncidents(incidentsRes.data)
      setStats(statsRes.data)
      setOncall(oncallRes.data)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load incident data:', error)
      setLoading(false)
    }
  }

  const handleCreateIncident = async (e) => {
    e.preventDefault()
    const formData = new FormData(e.target)
    try {
      await api.incidentManager.post('/incidents', null, {
        params: {
          title: formData.get('title'),
          description: formData.get('description'),
          severity: formData.get('severity'),
          service: formData.get('service')
        }
      })
      alert('Incident created successfully!')
      setShowCreateForm(false)
      loadData()
    } catch (error) {
      alert('Failed to create incident')
    }
  }

  if (loading) return <div className="loading">Loading incident data...</div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>🚨</span> Incident Manager</h1>
        <p className="page-subtitle">Track and manage incidents across your platform</p>
      </div>

      <div className="stats-grid">
        <div className="stat-card" style={{ '--card-color': '#ef4444', '--card-color-dark': '#dc2626' }}>
          <div className="stat-icon">📋</div>
          <div className="stat-label">Open Incidents</div>
          <div className="stat-value">{stats?.open_incidents}</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#f59e0b', '--card-color-dark': '#d97706' }}>
          <div className="stat-icon">⏱️</div>
          <div className="stat-label">MTTR (Mean Time To Recovery)</div>
          <div className="stat-value">{stats?.mttr_hours?.toFixed(1)}h</div>
        </div>
        <div className="stat-card" style={{ '--card-color': '#8b5cf6', '--card-color-dark': '#7c3aed' }}>
          <div className="stat-icon">🎯</div>
          <div className="stat-label">MTTD (Mean Time To Detect)</div>
          <div className="stat-value">{stats?.mttd_minutes?.toFixed(0)}m</div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">👤 On-Call Schedule</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '15px' }}>
            {oncall.map(schedule => (
              <div key={schedule.schedule_id} style={{ padding: '15px', background: '#f8fafc', borderRadius: '8px' }}>
                <div style={{ fontWeight: 600, marginBottom: '8px' }}>{schedule.team}</div>
                <div style={{ fontSize: '0.9rem', color: '#64748b' }}>
                  Primary: {schedule.current_oncall}<br />
                  Backup: {schedule.backup}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🚨 Active Incidents</h2>
          <button className="btn btn-success" onClick={() => setShowCreateForm(!showCreateForm)}>
            {showCreateForm ? 'Cancel' : '+ Create Incident'}
          </button>
        </div>
        <div className="card-content">
          {showCreateForm && (
            <form onSubmit={handleCreateIncident} style={{ marginBottom: '20px', padding: '20px', background: '#f8fafc', borderRadius: '8px' }}>
              <div style={{ marginBottom: '15px' }}>
                <label style={{ display: 'block', marginBottom: '5px', fontWeight: 600 }}>Title</label>
                <input name="title" required style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #cbd5e1' }} />
              </div>
              <div style={{ marginBottom: '15px' }}>
                <label style={{ display: 'block', marginBottom: '5px', fontWeight: 600 }}>Description</label>
                <textarea name="description" required style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #cbd5e1', minHeight: '80px' }} />
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: 600 }}>Severity</label>
                  <select name="severity" required style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #cbd5e1' }}>
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
                <div>
                  <label style={{ display: 'block', marginBottom: '5px', fontWeight: 600 }}>Service</label>
                  <input name="service" required style={{ width: '100%', padding: '8px', borderRadius: '4px', border: '1px solid #cbd5e1' }} />
                </div>
              </div>
              <button type="submit" className="btn btn-success">Create Incident</button>
            </form>
          )}

          <table className="table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Title</th>
                <th>Service</th>
                <th>Severity</th>
                <th>Status</th>
                <th>Assigned To</th>
              </tr>
            </thead>
            <tbody>
              {incidents.map(incident => (
                <tr key={incident.incident_id}>
                  <td style={{ fontFamily: 'monospace', fontWeight: 600 }}>{incident.incident_id}</td>
                  <td>{incident.title}</td>
                  <td>{incident.service}</td>
                  <td>
                    <span className={`badge ${
                      incident.severity === 'critical' ? 'badge-danger' :
                      incident.severity === 'high' ? 'badge-warning' :
                      'badge-info'
                    }`}>
                      {incident.severity}
                    </span>
                  </td>
                  <td>
                    <span className={`badge ${
                      incident.status === 'resolved' ? 'badge-success' : 'badge-warning'
                    }`}>
                      {incident.status}
                    </span>
                  </td>
                  <td style={{ fontSize: '0.85rem' }}>{incident.assigned_to}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default IncidentManager
