const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3001; // Default to 3001, can be overridden by env var

// Database connection pool configuration
const pool = new Pool({
  user: process.env.DB_USERNAME,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: 5432, // Default PostgreSQL port
  max: 10, // Max number of clients in the pool
  idleTimeoutMillis: 30000, // How long a client is allowed to remain idle before being closed
  connectionTimeoutMillis: 2000, // How long to wait for a connection from the pool
});

// Log any errors from the connection pool
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  // This would typically trigger an alert in a production environment
});

// Middleware to parse JSON request bodies
app.use(express.json());

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({ message: 'Backend is running and healthy!' });
});

// Health check endpoint for Load Balancer and monitoring
app.get('/health', async (req, res) => {
  try {
    // Attempt to connect to the database
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'OK', database: 'connected' });
  } catch (error) {
    console.error('Health check failed: Database connection error', error);
    res.status(500).json({ status: 'ERROR', database: 'disconnected', error: error.message });
  }
});

// Example API endpoint (optional)
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS current_time'); // Example query
    res.status(200).json({ users: [], currentTime: result.rows[0].current_time });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Backend server listening on port ${port}`);
});