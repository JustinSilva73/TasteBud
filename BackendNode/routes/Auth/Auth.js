const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const generateAccessToken = require("./GenerateAccessToken")

const db = mysql.createPool({
    host: 'tastebud.c711eegjx4h3.us-east-2.rds.amazonaws.com',
    user: 'admin',
    password: 'ShowcaseTwenty23',
    database: 'tastebud',
    port: 3306
});

router.post("/createUser", async (req, res) => {
    const username = req.body.username;
    const email = req.body.email;
    const hashedPassword = await bcrypt.hash(req.body.password, 10);

    db.getConnection(async (err, connection) => {
        if (err) throw (err)
        const sqlSearch = "SELECT * FROM user WHERE username = ? "
        const search_query = mysql.format(sqlSearch, [username])
        const sqlSearch2 = "SELECT * FROM user WHERE email = ?"
        const search_query2 = mysql.format(sqlSearch2, [email])
        const sqlInsert = "INSERT INTO user VALUES (0,?,?,?)"
        const insert_query = mysql.format(sqlInsert, [ email, hashedPassword, username])
        await connection.query(search_query, async (err, result) => {
            if (err) throw (err)
            if (result.length != 0) {
                connection.release()
                console.log("Username already exists")
                res.status(409)
                res.send("Username already exists")
            }
            else {
                await connection.query(search_query2, async (err, result2) => {
                    if (err) throw (err)
                    if (result2.length != 0) {
                        connection.release()
                        console.log("Email already exists")
                        res.status(409)
                    res.send("Email already exists")
                    }
                    else {
                        await connection.query(insert_query, (err, result) => {
                            connection.release()
                            if (err) throw (err)
                            res.sendStatus(201)
                        })
                    }
                })
            }
        })
    })
})

router.post("/login", (req, res) => {
    const username = req.body.username
    const password = req.body.password
    db.getConnection(async (err, connection) => {
        if (err) throw (err)
        const sqlSearch = "Select * from user where username = ?"
        const search_query = mysql.format(sqlSearch, [username])
        await connection.query(search_query, async (err, result) => {
            connection.release()

            if (err) throw (err)
            if (result.length == 0) {
                console.log("User does not exist")
                res.sendStatus(404)
            }
            else {
                const hashedPassword = result[0].password
                if (await bcrypt.compare(password, hashedPassword)) {
                    const token = generateAccessToken({ user: username })
                    res.json({ accessToken: token })
                } else {
                    res.send("Password incorrect")
                }
            }
        })
    })
})

module.exports = router;