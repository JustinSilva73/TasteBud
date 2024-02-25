const express = require('express');
const axios = require('axios');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

const getTopCuisines = async (user_id) => {
    return new Promise((resolve, reject) => {
        // Query to get the user's cuisine weights
        const queryCuisines = `SELECT american_weight, italian_weight, chinese_weight, 
                                       japanese_weight, mexican_weight, indian_weight, 
                                       mediterranean_weight, thai_weight 
                               FROM tastebud.CuisineWeights 
                               WHERE user_id = ?`;
        let db = openConnection();
        db.query(queryCuisines, [user_id], (err, results) => {
            if (err) {
                reject(err);
                closeConnection(db);
            } else {
                if (results.length > 0) {
                    // We have the user's cuisine weights, now let's find the top 4
                    const weights = results[0];
                    const sortedWeights = Object.keys(weights)
                        .map(cuisine => ({ cuisine: cuisine.replace('_weight', ''), weight: weights[cuisine] }))
                        .sort((a, b) => b.weight - a.weight)
                        .slice(0, 4)
                        .map(item => item.cuisine.charAt(0).toUpperCase() + item.cuisine.slice(1).toLowerCase());

                    resolve(sortedWeights);
                } else {
                    reject(new Error('No cuisine weights found for the user.'));
                }
                closeConnection(db);
            }
        });
    });
};

const getUserID = async (email) => {
    return new Promise((resolve, reject) => {
        const query = `SELECT user_id FROM Users WHERE email = ?`;
        let db = openConnection();
        db.query(query, [email], (err, results) => {
            if (err) {
                reject(err);
                closeConnection(db);
            } else {
                if (results.length > 0) {
                    resolve(results[0].user_id);
                } else {
                    reject(new Error('No user found with that email.'));
                }
                closeConnection(db);
            }
        });
    });
};


router.get('/top_cuisines/:user_id', async (req, res) => {
    try {
        const userId = req.params.user_id;
        let cuisineNames = await getTopCuisines(userId);
        res.json(cuisineNames);
    } catch (error) {
        console.error(error);
        res.status(500).send('Server error: ' + error.message);
    }
});

router.get('/user_id/:email', async (req, res) => {
    try {
        const email = req.params.email;
        let userId = await getUserID(email);
        res.json(userId);
    } catch (error) {
        console.error(error);
        res.status(500).send('Server error: ' + error.message);
    }
});


module.exports = router;
