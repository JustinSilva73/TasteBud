const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const mysql = require('mysql'); // Use the appropriate database library (e.g., 'mysql', 'mongodb', etc.)

// Create a database connection




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