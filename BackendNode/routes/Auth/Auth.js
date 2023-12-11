const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const generateAccessToken = require("./GenerateAccessToken")
const { openConnection, closeConnection } = require('../DatabaseLogic'); // Ensure you have these functions defined in DatabaseUtils.js
async function insertCuisineWeights(db, userId) {
  return new Promise((resolve, reject) => {
      // Include all cuisine columns in one insert statement
      const insertQuery = `INSERT INTO CuisineWeights (user_id, american_weight, italian_weight, chinese_weight, japanese_weight, mexican_weight, indian_weight, mediterranean_weight, thai_weight, british_weight, spanish_weight) VALUES (?, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50)`;
      db.query(insertQuery, [userId], (err, result) => {
          if (err) {
              reject(err);
          } else {
              resolve(result);
          }
      });
  });
}





async function insertDistanceWeights(db, userId) {
  return new Promise((resolve, reject) => {
      const insertQuery = `INSERT INTO DistanceWeight (user_id, near_weight, middle_weight, far_weight) VALUES (?, 50, 50, 50)`;
      db.query(insertQuery, [userId], (err, result) => {
          if (err) {
              reject(err);
          } else {
              resolve(result);
          }
      });
  });
}



async function insertPriceWeights(db, userId) {
  return new Promise((resolve, reject) => {
      const insertQuery = `INSERT INTO PriceWeights (user_id, one_weight, two_weight, three_weight, four_weight) VALUES (?, 50, 50, 50, 50)`;
      db.query(insertQuery, [userId], (err, result) => {
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
          const hashedPassword = await bcrypt.hash(password, 10);

          // Insert user into the database
          const query = `INSERT INTO Users (username, email, user_password) VALUES (?, ?, ?)`;
          const insertResult = await new Promise((resolve, reject) => {
              db.query(query, [username, email, hashedPassword], (err, result) => {
                  if (err) {
                      reject(err);
                  } else {
                      resolve(result);
                  }
              });
          });

          if (insertResult && insertResult.insertId) {
              const userId = insertResult.insertId;
              console.log(`User inserted with ID: ${userId}`);

              // Now pass this userId to your functions
              await insertDistanceWeights(db, userId);
              await insertPriceWeights(db, userId);
              await insertCuisineWeights(db, userId),

                console.log("Success");
                closeConnection(db);
                return res.json({ success: true, message: "Account created successfully" });
            } else {
                throw new Error('User ID not returned from insert operation');
            }
        } catch (error) {
            closeConnection(db);
            console.error('Error:', error);
            return res.status(500).json({ error: 'Error in processing request' });
        }
    } else {
        console.log('Missing a parameter');
        return res.status(400).json({ error: 'Missing a parameter' });
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