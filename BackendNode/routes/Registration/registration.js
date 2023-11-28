const bcrypt = require("bcrypt");
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

// db.connect((err) => {
//   if (err) {
//     console.error('Database connection failed: ' + err.message);
//   } else {
//     console.log('Connected to the database');
//   }
// });


// router.get('/test', async (req, res) => {
//     if ( req.query.username && req.query.email && req.query.password) {
//         console.log('Request received');
//         db.connect(function (err) {
//             db.query(`INSERT INTO user ( username, email, password) VALUES ( '${req.query.username}' , '${req.query.email}', '${req.query.password}' )`, function (err, result, fields){ 
//                 if (err) {
//                     console.log(err);
//                     res.send(err);
//                 }
//                 if (result) {
//                     res.header("Access-Control-Allow-Origin", "*");
//                     res.send("success");
//                     console.log("success");
//                 }
//                 if (fields) console.log(fields);
//             });
//         });
//     } else {
//         console.log('Missing a parameter');
//     }
// });

router.get('/createUser', async (req, res) => {
    if ( req.query.username && req.query.email && req.query.password) {
        console.log('Request received');
        const email = req.body.email;
        const username = req.body.username;
        const hashedPassword = await bcrypt.hash(req.body.password, 10);
        db.connect(async function (err) {
            const sqlSearch = "SELECT email, username FROM user WHERE  email =? or username =?"
            const search_query = mysql.format(sqlSearch, [email, username])
            const sqlInsert = "INSERT INTO user(username, email, password) VALUES (?,?,?)"
            const insert_query = mysql.format(sqlInsert, [username, email, hashedPassword])
            await db.query(search_query, async function (err, result) {
                if (err) throw (err)
                if (result.length != 0) {
                
                    console.log("Username or email already exists")
                    res.sendStatus(409)
                }
                else { 
                    await db.query(insert_query, (err, result) => {
                       
                        if (err) throw (err)
                        res.sendStatus(201)
                    })
                }
            });
        });
    } else {
        console.log('Missing a parameter');
    }
});

module.exports = router;