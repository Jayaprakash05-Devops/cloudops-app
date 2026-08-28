import React, { useState, useEffect } from 'react'
import api from '../services/api'

function ChatOps() {
  const [commands, setCommands] = useState([])
  const [history, setHistory] = useState([])
  const [inputCommand, setInputCommand] = useState('')
  const [output, setOutput] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [commandsRes, historyRes] = await Promise.all([
        api.chatops.get('/commands'),
        api.chatops.get('/commands/history?limit=10')
      ])
      setCommands(commandsRes.data.commands)
      setHistory(historyRes.data)
      setLoading(false)
    } catch (error) {
      console.error('Failed to load ChatOps data:', error)
      setLoading(false)
    }
  }

  const handleExecuteCommand = async (e) => {
    e.preventDefault()
    if (!inputCommand.trim()) return

    try {
      const response = await api.chatops.post('/commands/execute', null, {
        params: {
          command: inputCommand,
          user: 'dashboard-user',
          channel: 'dashboard'
        }
      })
      setOutput(response.data.response)
      setInputCommand('')
      loadData()
    } catch (error) {
      setOutput('Error executing command')
    }
  }

  if (loading) return <div className="loading">Loading ChatOps...</div>

  return (
    <div className="page-container">
      <div className="page-header">
        <h1 className="page-title"><span>💬</span> ChatOps</h1>
        <p className="page-subtitle">Control your infrastructure through chat commands</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
        <div className="card">
          <div className="card-header">
            <h2 className="card-title">⚡ Execute Command</h2>
          </div>
          <div className="card-content">
            <form onSubmit={handleExecuteCommand}>
              <div style={{ marginBottom: '15px' }}>
                <label style={{ display: 'block', marginBottom: '8px', fontWeight: 600 }}>
                  Enter Command
                </label>
                <input
                  type="text"
                  value={inputCommand}
                  onChange={(e) => setInputCommand(e.target.value)}
                  placeholder="/status, /cost, /k8s pods, etc."
                  style={{
                    width: '100%',
                    padding: '12px',
                    borderRadius: '8px',
                    border: '2px solid #e2e8f0',
                    fontSize: '1rem',
                    fontFamily: 'monospace'
                  }}
                />
              </div>
              <button type="submit" className="btn btn-primary" style={{ width: '100%' }}>
                Execute Command
              </button>
            </form>

            {output && (
              <div style={{
                marginTop: '20px',
                padding: '15px',
                background: '#1e293b',
                color: '#f1f5f9',
                borderRadius: '8px',
                fontFamily: 'monospace',
                fontSize: '0.9rem',
                whiteSpace: 'pre-wrap',
                maxHeight: '300px',
                overflowY: 'auto'
              }}>
                {output}
              </div>
            )}
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <h2 className="card-title">📋 Available Commands</h2>
          </div>
          <div className="card-content">
            <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
              {commands.map((cmd, idx) => (
                <div
                  key={idx}
                  onClick={() => setInputCommand(cmd.command)}
                  style={{
                    padding: '12px',
                    background: '#f8fafc',
                    borderRadius: '8px',
                    marginBottom: '8px',
                    cursor: 'pointer',
                    transition: 'all 0.2s'
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.background = '#e2e8f0'}
                  onMouseLeave={(e) => e.currentTarget.style.background = '#f8fafc'}
                >
                  <div style={{ fontWeight: 600, fontFamily: 'monospace', color: '#667eea', marginBottom: '4px' }}>
                    {cmd.command}
                  </div>
                  <div style={{ fontSize: '0.85rem', color: '#64748b' }}>
                    {cmd.description}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">📜 Command History</h2>
          <button className="btn btn-secondary" onClick={loadData}>Refresh</button>
        </div>
        <div className="card-content">
          <table className="table">
            <thead>
              <tr>
                <th>Command ID</th>
                <th>Command</th>
                <th>User</th>
                <th>Channel</th>
                <th>Status</th>
                <th>Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {history.map(cmd => (
                <tr key={cmd.command_id}>
                  <td style={{ fontFamily: 'monospace', fontSize: '0.85rem' }}>{cmd.command_id}</td>
                  <td style={{ fontFamily: 'monospace', fontWeight: 600, color: '#667eea' }}>{cmd.command}</td>
                  <td>{cmd.user}</td>
                  <td>{cmd.channel}</td>
                  <td>
                    <span className="badge badge-success">{cmd.status}</span>
                  </td>
                  <td style={{ fontSize: '0.85rem' }}>
                    {new Date(cmd.timestamp).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card">
        <div className="card-header">
          <h2 className="card-title">🔗 Platform Integrations</h2>
        </div>
        <div className="card-content">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '15px' }}>
            <div style={{ padding: '20px', background: '#5865f2', color: 'white', borderRadius: '12px', textAlign: 'center' }}>
              <div style={{ fontSize: '2rem', marginBottom: '8px' }}>💬</div>
              <div style={{ fontWeight: 600, marginBottom: '4px' }}>Discord</div>
              <div style={{ fontSize: '0.85rem' }}>Connected</div>
            </div>
            <div style={{ padding: '20px', background: '#e01e5a', color: 'white', borderRadius: '12px', textAlign: 'center' }}>
              <div style={{ fontSize: '2rem', marginBottom: '8px' }}>📱</div>
              <div style={{ fontWeight: 600, marginBottom: '4px' }}>Slack</div>
              <div style={{ fontSize: '0.85rem' }}>Ready to Connect</div>
            </div>
            <div style={{ padding: '20px', background: '#5558af', color: 'white', borderRadius: '12px', textAlign: 'center' }}>
              <div style={{ fontSize: '2rem', marginBottom: '8px' }}>💼</div>
              <div style={{ fontWeight: 600, marginBottom: '4px' }}>MS Teams</div>
              <div style={{ fontSize: '0.85rem' }}>Not Configured</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ChatOps
