const express = require('express');
const app = express();
const port = 3306; // Default port for MySQL traffic
const bodyParser = require('body-parser');
const mysql = require('mysql'); // Use the appropriate database library (e.g., 'mysql', 'mongodb', etc.)

// Create a database connection
const db = mysql.createConnection({
  host: 'tastebud.c711eegjx4h3.us-east-2.rds.amazonaws.com',
  user: 'admin',
  password: 'restaurantInfo',
  database: 'tastebud',
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.message);
  } else {
    console.log('Connected to the database');
  }
});

app.use(bodyParser.json());

// Define API endpoints for interacting with the database
app.get('/getData', (req, res) => {
  // Test query for grabbing user data
  db.query('SELECT * FROM Restaurants', (error, results) => {
    if (error) {
      console.error('Error executing query: ' + error);
      res.status(500).json({ error: 'Database query error' });
    } else {
      res.json(results);
    }
  });
});

// Add more routes for database operations here

app.listen(port, () => {
  console.log('Server is running on port ${port}');
});
