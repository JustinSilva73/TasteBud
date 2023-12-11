const bcrypt = require("bcrypt");
const express = require('express');
const mysql = require("mysql");
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

router.post('/survey/', async (req, res) => {
    const { email, price, distance, cuisine } = req.body;

    if (!(email && price && distance && cuisine)) {
        return res.status(400).json({ error: 'Missing one or more parameters' });
    }

    let db = openConnection();
    if (!db) {
        return res.status(500).json({ error: 'Failed to connect to the database' });
    }

    try {
        // Query to get user's current weights
        const queryWeights = `SELECT u.user_id,
            CW.american_weight, CW.italian_weight, CW.chinese_weight, CW.japanese_weight, CW.mexican_weight, CW.indian_weight, CW.mediterranean_weight, CW.thai_weight,
            DW.near_weight, DW.middle_weight, DW.far_weight,
            PW.one_weight, PW.two_weight, PW.three_weight, PW.four_weight
            FROM Users as u
            LEFT JOIN tastebud.CuisineWeights CW ON u.user_id = CW.user_id
            LEFT JOIN tastebud.DistanceWeight DW ON u.user_id = DW.user_id
            LEFT JOIN tastebud.PriceWeights PW ON u.user_id = PW.user_id
            WHERE u.email = ?`;

        db.query(queryWeights, [email], (err, results) => {
            if (err) {
                console.log(err);
                closeConnection(db);
                return res.status(500).json({ error: 'Database query error' });
            }

            if (results.length === 0) {
                closeConnection(db);
                return res.status(404).json({ error: 'User not found' });
            }

            let currentUserWeights = results[0];

            // Update cuisine weights
            cuisine.forEach(item => {
                const key = Object.keys(item)[0];
                currentUserWeights[key] += item[key];
            });

            // Update distance weights
            distance.forEach(item => {
                const key = Object.keys(item)[0];
                currentUserWeights[key] += item[key];
            });

            // Update price weights
            price.forEach(item => {
                const key = Object.keys(item)[0];
                currentUserWeights[key] += item[key];
            });

            // Prepare update queries
            const updateCuisineQuery = `UPDATE CuisineWeights SET ? WHERE user_id = ?`;
            const updateDistanceQuery = `UPDATE DistanceWeight SET ? WHERE user_id = ?`;
            const updatePriceQuery = `UPDATE PriceWeights SET ? WHERE user_id = ?`;

            // Extract relevant parts for each update
            const cuisineUpdate = {
                american_weight: currentUserWeights.american_weight,
                italian_weight: currentUserWeights.italian_weight,
                chinese_weight: currentUserWeights.chinese_weight,
                japanese_weight: currentUserWeights.japanese_weight,
                mexican_weight: currentUserWeights.mexican_weight,
                indian_weight: currentUserWeights.indian_weight,
                mediterranean_weight: currentUserWeights.mediterranean_weight,
                thai_weight: currentUserWeights.thai_weight,
            };

            const distanceUpdate = {
                near_weight: currentUserWeights.near_weight,
                middle_weight: currentUserWeights.middle_weight,
                far_weight: currentUserWeights.far_weight,
            };

            const priceUpdate = {
                one_weight: currentUserWeights.one_weight,
                two_weight: currentUserWeights.two_weight,
                three_weight: currentUserWeights.three_weight,
                four_weight: currentUserWeights.four_weight,
            };

            // Perform updates
            db.query(updateCuisineQuery, [cuisineUpdate, currentUserWeights.user_id], updateErrorHandler);
            db.query(updateDistanceQuery, [distanceUpdate, currentUserWeights.user_id], updateErrorHandler);
            db.query(updatePriceQuery, [priceUpdate, currentUserWeights.user_id], updateErrorHandler);

            function updateErrorHandler(err, result) {
                if (err) {
                    console.log(err);
                    closeConnection(db);
                    return res.status(500).json({ error: 'Database update error' });
                }
            }

            // Close the connection and respond
            closeConnection(db);
            res.json({ success: true, message: 'Weights updated successfully' });
        });
    } catch (err) {
        closeConnection(db);
        console.error('Error:', err);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
