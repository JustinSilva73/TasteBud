const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const generateAccessToken = require("./GenerateAccessToken")
const { openConnection, closeConnection } = require('../DatabaseLogic'); // Ensure you have these functions defined in DatabaseUtils.js


router.post('/pushAccount', async (req, res) => {
    const { username, email, password } = req.body;
    
    if (username && email && password) {
        console.log('Request received');
        
        const db = openConnection();
        if (!db) {
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }

        try {
            // Hash the password
            const hashedPassword = await bcrypt.hash(password, 10); // 10 is the number of salt rounds

            const query = `INSERT INTO users (username, email, password) VALUES (?, ?, ?)`;
            db.query(query, [username, email, hashedPassword], (err, result) => {
                closeConnection(db);

                if (err) {
                    console.log(err);
                    res.status(500).json({ error: 'Database query error' });
                    return;
                }
                
                console.log("Success", result);
                res.json({ success: true, message: "Account created successfully" });
            });
        } catch (err) {
            closeConnection(db);
            console.error('Error hashing password:', err);
            res.status(500).json({ error: 'Error hashing password' });
        }
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
      const usernameSql = "SELECT * FROM users WHERE username = ?";
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
          const emailSql = "SELECT * FROM users WHERE email = ?";
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
      const emailSql = "SELECT * FROM users WHERE email = ?";
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
  

  router.post("/login", (req, res) => {
    const { username, password } = req.body;

    console.log(`Login attempt for username: ${username}`);

    if (!username || !password) {
        console.log('Username or password not provided');
        return res.status(400).json({ error: 'Username and password are required' });
    }

    const db = openConnection();
    if (!db) {
        console.log('Failed to connect to the database');
        return res.status(500).json({ error: 'Failed to connect to the database' });
    }

    console.log(`Provided password for ${username}: ${password}`); // Log the provided password (remove this in production)

    const sqlSearch = "SELECT * FROM users WHERE username = ?";
    db.query(mysql.format(sqlSearch, [username]), async (err, result) => {
        if (err) {
            console.error('Database query error:', err);
            closeConnection(db);
            return res.status(500).json({ error: "Database query error" });
        }

        if (result.length === 0) {
            console.log(`User not found for username: ${username}`);
            closeConnection(db);
            return res.status(404).json({ error: "User does not exist" });
        }

        const user = result[0];
        const hashedPassword = result[0].password;
        console.log(`Stored hashed password for ${username}: ${hashedPassword}`); // Log the hashed password (remove this in production)

        try {
            if (await bcrypt.compare(password, hashedPassword)) {
                const token = generateAccessToken({ user: username });
                closeConnection(db);
                return res.json({ success: true, email: user.email, accessToken: token });
            } else {
                console.log(`Password mismatch for user: ${username}`);
                closeConnection(db);
                return res.status(401).json({ error: "Password incorrect" });
            }
        } catch (bcryptError) {
            console.error('Bcrypt error:', bcryptError);
            closeConnection(db);
            return res.status(500).json({ error: "Error in password comparison" });
        }
    });
});




module.exports = router;