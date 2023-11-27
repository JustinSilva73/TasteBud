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



router.get('/test', async (req, res) => {
    if ( req.query.username && req.query.email && req.query.password) {
        console.log('Request received');
        db.connect(function (err) {
            db.query(`INSERT INTO user ( username, email, password) VALUES ( '${req.query.username}' , '${req.query.email}', '${req.query.password}' )`, function (err, result, fields) {
                if (err) {
                    console.log(err);
                    res.send(err);
                }
                if (result) {
                    res.header("Access-Control-Allow-Origin", "*");
                    res.send("success");
                    console.log("success");
                }
                if (fields) console.log(fields);
            });
        });
    } else {
        console.log('Missing a parameter');
    }
});
module.exports = router;