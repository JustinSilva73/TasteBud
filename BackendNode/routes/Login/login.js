const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const mysql = require('mysql'); // Use the appropriate database library (e.g., 'mysql', 'mongodb', etc.)

// Create a database connection
const db = mysql.createConnection({
  host: 'tastebud.c711eegjx4h3.us-east-2.rds.amazonaws.com', 
  user: 'admin',
  password: 'ShowcaseTwenty23',
  database: 'tastebud',
  port:3306
});

db.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.message);
  } else {
    console.log('Connected to the database');
  }
});



router.get('/', (req, res) => {
   
        // get deckId from the parameters of the request
        const email = req.query.email;
        const password = req.query.password;
        
        console.log("email is: ", email);
        
        const sql = `SELECT * FROM user WHERE email =? and password =?`;

        // pass in the SQL query and the userId, and run a function that with error or results as params
        db.query(sql, [email,password], (error, results) => {
            if (error) {
                console.error('Error executing query: ' + error);
                res.status(500).json({ error: 'Database query error' });
              } else {
                res.json(results);
              }
        });
});

module.exports = router;