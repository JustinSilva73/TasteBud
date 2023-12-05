const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const generateAccessToken = require("./GenerateAccessToken")
const { openConnection, closeConnection } = require('../DatabaseLogic'); // Ensure you have these functions defined in DatabaseUtils.js

async function insertCuisineWeights(db, column) {
    return new Promise((resolve, reject) => {
        const insertQuery = `INSERT INTO CuisineWeights (${column}) VALUES (50)`;
        db.query(insertQuery, (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
}

async function insertDistanceWeights(db) {
    return new Promise((resolve, reject) => {
        const insertQuery = `INSERT INTO DistanceWeight (near_weight, middle_weight, far_weight) VALUES (50, 50, 50)`;
        db.query(insertQuery, [near_weight, middle_weight, far_weight], (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
}

async function insertPriceWeights(db) {
    return new Promise((resolve, reject) => {
        const insertQuery = `INSERT INTO PriceWeights (one_weight, two_weight, three_weight, four_weight) VALUES (50, 50, 50, 50)`;
        db.query(insertQuery, [one_weight, two_weight, three_weight, four_weight], (err, result) => {
            if (err) {
                reject(err);
            } else {
                resolve(result);
            }
        });
    });
}


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

            const query = `INSERT INTO Users (username, email, user_password) VALUES (?, ?, ?)`;
            db.query(query, [username, email, hashedPassword], (err, result) => {
                closeConnection(db);

                if (err) {
                    console.log(err);
                    res.status(500).json({ error: 'Database query error' });
                    return;
                }

        } catch (err) {
            closeConnection(db);
            console.error('Error hashing password:', err);
            res.status(500).json({ error: 'Error hashing password' });
        }

        try {
            await insertDistanceWeights(db);

            await insertPriceWeights(db);

            await Promise.all([
                insertCuisineWeights(db, 'american_weight'),
                insertCuisineWeights(db, 'italian_weight'),
                insertCuisineWeights(db, 'chinese_weight'),
                insertCuisineWeights(db, 'japanese_weight'),
                insertCuisineWeights(db, 'mexican_weight'),
                insertCuisineWeights(db, 'indian_weight'),
                insertCuisineWeights(db, 'mediterranean_weight'),
                insertCuisineWeights(db, 'thai_weight'),
                insertCuisineWeights(db, 'british_weight'),
                insertCuisineWeights(db, 'spanish_weight')
                ]);
                console.log("Success", result);
                closeConnection(db);
                res.json({ success: true, message: "Account created successfully" });
        } catch (error) {
                closeConnection(db);
                console.error('Error inserting default values:', error);
                res.status(500).json({ error: 'Error inserting default values' });
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
      const usernameSql = "SELECT * FROM Users WHERE username = ?";
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
          const emailSql = "SELECT * FROM Users WHERE email = ?";
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
      const emailSql = "SELECT * FROM Users WHERE email = ?";
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

    const sqlSearch = "SELECT * FROM Users WHERE username = ?";
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
        const hashedPassword = result[0].user_password;
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