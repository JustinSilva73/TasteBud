const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic'); // Ensure you have these functions defined in DatabaseUtils.js


router.post('/survey/', async (req, res) => {
    const { email, price, distance, cuisine } = req.body;

        if (email && price && distance && cuisine) {
            console.log('Request received');

        let db = openConnection();
        if (!db) {
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }

        try {

            const query_cuisine = `SELECT u.user_id,
                american_weight,
                italian_weight,
                chinese_weight,
                japanese_weight,
                mexican_weight,
                indian_weight,
                mediterranean_weight,
                thai_weight
                
     from Users as u
              join tastebud.CuisineWeights CW on u.user_id = CW.user_id
              
     WHERE email =?`;




            let score = 20;
            db.query(query_cuisine, [email], (err, result) => {

let res=result[0]
                if (err) {
                    console.log(err);
                    res.status(500).json({ error: 'Database query error' });
                    return;
                }

                console.log("Success", res);
                Object.keys(res).forEach((key) => {
                    console.log('key', key)
                    console.log('cuisine', cuisine)
                    if (key != "user_id") {

                        if (cuisine.includes(key)) {
                            console.log('update')
                            res[key] = res[key]+score
                        }
                        else { res[key]= res[key] - score }
                    }


                }); console.log('result ', res)
                const update_cuisine = `UPDATE CuisineWeights
                set american_weight=?,
                    italian_weight=?,
                    chinese_weight=?,
                    japanese_weight=?,
                    mexican_weight=?,
                    indian_weight=?,
                    mediterranean_weight=?,
                    thai_weight=?
                WHERE user_id=?`
                try {
                    db.query(update_cuisine, [res["american_weight"], res["italian_weight"], res["chinese_weight"], res["japanese_weight"], res["mexican_weight"], res["indian_weight"], res["mediterranean_weight"], res["thai_weight"], res["user_id"]]
                        , (err, result) => {
                            if (err) {
                                console.log(err);
                                res.status(500).json({ error: 'Database query error' });
                                return;
                            }
                            console.log("Success", result);
                        });
                } catch (err) {
                }
            });
        } catch (err) {

        }
        try {

            const query_distance = `SELECT u.user_id,
            near_weight,
            far_weight,
            middle_weight
                
     from Users as u
              join tastebud.DistanceWeight CW on u.user_id = CW.user_id
              
     WHERE email =?`;
            let score = 20;
            db.query(query_distance, [email], (err, result) => {
                res=result[0]
                if (err) {
                    console.log(err);
                    res.status(500).json({ error: 'Database query error' });
                    return;
                }

                console.log("Success", result);
                Object.keys(res).forEach((key) => {
                    console.log('key', key)
                    console.log('cuisine', cuisine)
                    if (key != "user_id") {

                        if (distance.includes(key)) {
                            console.log('update')
                            res[key] = res[key]+score
                        }
                        else { res[key]= res[key] - score }
                    }}); 
                const update_distance = `UPDATE DistanceWeight
        set near_weight=?,
        far_weight=?,
        middle_weight=?

        WHERE user_id=?`
                try {

                    let score = 20;


                    db.query(update_distance, [res["near_weight"], res["far_weight"], res["middle_weight"], res["user_id"]]

                        , (err, result) => {
                            closeConnection(db);

                            if (err) {
                                console.log(err);
                                res.status(500).json({ error: 'Database query error' });
                                return;
                            }

                            console.log("Success", result);
                        });
                } catch (err) {
                    closeConnection(db);
                    console.error('Error hashing password:', err);
                    res.status(500).json({ error: 'Error hashing password' });
                }

            });
        } catch (err) {
            closeConnection(db);
            console.error('Error hashing password:', err);
            res.status(500).json({ error: 'Error hashing password' });
        }
        try {

            const query_price = `SELECT u.user_id,
            one_weight,
            two_weight,
            three_weight,
            four_weight
                
     from Users as u
              join tastebud.PriceWeights CW on u.user_id = CW.user_id
              
     WHERE email =?`;


     
            let score = 20;


            db.query(query_price, [email], (err, result) => {

                res=result[0]
                if (err) {
                    console.log(err);
                    res.status(500).json({ error: 'Database query error' });
                    return;
                }

                console.log("Success", result);
                Object.keys(res).forEach((key) => {
                    console.log('key', key)
                    console.log('cuisine', cuisine)
                    if (key != "user_id") {

                        if (price.includes(key)) {
                            console.log('update')
                            res[key] = res[key]+score
                        }
                        else { res[key]= res[key] - score }
                    }}); 
                const update_price = `UPDATE PriceWeights
                set one_weight=?,
                two_weight=?,
                three_weight=?,
                four_weight=?
        
                WHERE user_id=?`

                try {

                    let score = 20;


                    db.query(update_price, [res["one_weight"], res["two_weight"], res["three_weight"], res["four_weight"], res["user_id"]]

                        , (err, result) => {


                            if (err) {
                                console.log(err);
                                res.status(500).json({ error: 'Database query error' });
                                return;
                            }

                            console.log("Success", result);
                        });
                } catch (err) {
                    closeConnection(db);
                    console.error('Error hashing password:', err);
                    res.status(500).json({ error: 'Error hashing password' });
                }
            });
        } catch (err) {
            closeConnection(db);
            console.error('Error hashing password:', err);
            res.status(500).json({ error: 'Error hashing password' });
        }

        res.json({ success: true, message: "Update points successfully" });
    } else {
        console.log('Missing a parameter');
        res.status(400).json({ error: 'Missing a parameter' });
    }
});

module.exports = router;