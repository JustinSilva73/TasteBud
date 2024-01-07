const express = require('express');
const router = express.Router();
const port = 3306; // Default port for MySQL traffic
const bodyParser = require('body-parser');
const mysql = require('mysql'); // Use the appropriate database library (e.g., 'mysql', 'mongodb', etc.)

// Create a database connection
const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: 'tastebud',
};

function openConnection() {
  const connection = mysql.createConnection(dbConfig);
  connection.connect(err => {
    if (err) {
      console.error('Error connecting to the database:', err);
      return null;
    }
    console.log('Database connection established');
  });
  return connection;
}

function closeConnection(connection) {
  if (connection) {
    connection.end(err => {
      if (err) {
        console.error('Error closing the database connection:', err);
      } else {
        console.log('Database connection closed');
      }
    });
  }
}

router.use(bodyParser.json());

// Define API endpoints for interacting with the database
router.get('/getData', (req, res) => {
  db = openConnection();
  db.query('SELECT * FROM Restaurants', (error, results) => {
    if (error) {
      console.error('Error executing query: ' + error);
      res.status(500).json({ error: 'Database query error' });
    } else {
      res.json(results);
    }
  });
  closeConnection(db);
});

module.exports = { openConnection, closeConnection };
