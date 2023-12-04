// registration.js
const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const mysql = require('mysql'); // Use the appropriate database library (e.g., 'mysql', 'mongodb', etc.)
const { openConnection, closeConnection } = require('../DatabaseLogic'); // Ensure you have these functions defined in DatabaseUtils.js


router.post('/pushAccount', (req, res) => {
  const { username, email, password } = req.body;
  
  if (username && email && password) {
      console.log('Request received');
      
      const db = openConnection();
      if (!db) {
          return res.status(500).json({ error: 'Failed to connect to the database' });
      }

      const query = `INSERT INTO user (username, email, password) VALUES (?, ?, ?)`;
      db.query(query, [username, email, password], (err, result) => {
          closeConnection(db);

          if (err) {
              console.log(err);
              res.status(500).json({ error: 'Database query error' });
              return;
          }
          
          console.log("Success", result);
          res.json({ success: true, message: "Account created successfully" });
      });
  } else {
      console.log('Missing a parameter');
      res.status(400).json({ error: 'Missing a parameter' });
  }
});

router.get('/checkUserDetails', (req, res) => {
  const { username, email } = req.query;

  let result = {
    usernameExists: false,
    emailExists: false
  };

  const db = openConnection();
  if (!db) {
    return res.status(500).json({ error: 'Failed to connect to the database' });
  }

  // Check for username
  if (username) {
    const usernameSql = "SELECT * FROM user WHERE username = ?";
    db.query(usernameSql, [username], (err, rows) => {
      if (err) {
        console.error('Database query error:', err);
        closeConnection(db);
        return res.status(500).json({ error: "Database query error" });
      }

      if (rows.length > 0) {
        result.usernameExists = true;
      }

      // Check for email, but only if it's provided
      if (email) {
        const emailSql = "SELECT * FROM user WHERE email = ?";
        db.query(emailSql, [email], (err, rows) => {
          closeConnection(db);

          if (err) {
            console.error('Database query error:', err);
            return res.status(500).json({ error: "Database query error" });
          }

          if (rows.length > 0) {
            result.emailExists = true;
          }

          res.json(result);
        });
      } else {
        closeConnection(db);
        res.json(result);
      }
    });
  } else if (email) {
    // Only email was provided
    const emailSql = "SELECT * FROM user WHERE email = ?";
    db.query(emailSql, [email], (err, rows) => {
      closeConnection(db);

      if (err) {
        console.error('Database query error:', err);
        return res.status(500).json({ error: "Database query error" });
      }

      if (rows.length > 0) {
        result.emailExists = true;
      }

      res.json(result);
    });
  } else {
    // Neither username nor email was provided
    closeConnection(db);
    res.status(400).json({ error: "Username or email is required" });
  }
});



module.exports = router;