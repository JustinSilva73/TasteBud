const express = require('express');
const router = express.Router();
const port = 3306; // Default port for MySQL traffic
const bodyParser = require('body-parser');
const mysql = require('mysql');

// Create a database connection
const db = mysql.createConnection({
  host: 'tastebud.c711eegjx4h3.us-east-2.rds.amazonaws.com',
  user: 'admin',
  password: 'ShowcaseTwenty23',
  database: 'tastebud',
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.message);
  } else {
    console.log('Connected to the database');
  }
});

router.use(bodyParser.json());

// Define API endpoints for interacting with the database
router.get('/getData', (req, res) => {
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

// Insert data into the database
const insertData = (data, table) => {
  db.query('INSERT INTO ${table} SET ?', data, (error, results) => {
    if (error) {
      console.error(error);
    } else {
      console.log('Data inserted:', results);
    }
  });
};
router.listen(port) => {
  console.log('Server is running on port ${port}');
});
