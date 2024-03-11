const express = require('express');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');


router.post('/initUserRestaurant', (req, res) => {
    const { user_id, restaurant_name, yelp_link } = req.body;

    if (user_id && restaurant_name && yelp_link) {
        console.log('Request received');

        const db = openConnection();
        if (!db) {
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }
        let query = `SELECT userRestaurantID, liked FROM UserRestaurants WHERE userID = ? AND restaurantName = ? AND yelpLink = ?`;
        db.query(query, [user_id, restaurant_name, yelp_link], (err, results) => {
            if (err) {
                res.status(500).json({ error: err });
                closeConnection(db);
                return
            } else {
                if (results.length > 0) {
                    res.json({ user_restaurant_id: results[0].userRestaurantID, liked: results[0].liked });
                } else {
                    query = `INSERT INTO UserRestaurants (userID, restaurantName, yelpLink) VALUES (?, ?, ?)`;
                    db.query(query, [user_id, restaurant_name, yelp_link], (err, result) => {
                        closeConnection(db);
                        if (err) {
                            console.log(err);
                            res.status(500).json({ error: 'Database query error' });
                            return;
                        }
                        let resultObj = JSON.parse(JSON.stringify(result))
                        res.json({ user_restaurant_id: resultObj.insertId, liked: null });
                    });
                }
            }
        });

    } else {
        console.log('Missing a parameter');
        res.status(400).json({ error: 'Missing a parameter' });
    }
});

router.post('/like', (req, res) => {
    const { user_restaurant_id, liked } = req.body;

    if (user_restaurant_id && liked != null) {
        console.log('Request received');

        const db = openConnection();
        if (!db) {
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }
        let query = `UPDATE UserRestaurants SET liked = ? WHERE userRestaurantID = ?`;
        db.query(query, [liked, user_restaurant_id], (err, results) => {
            closeConnection(db);
            if (err) {
                res.status(500).json({ error: err });
            } else {
                res.status(200).json({ user_restaurant_id: user_restaurant_id, liked: liked });
            }
        });

    } else {
        console.log('Missing a parameter');
        res.status(400).json({ error: 'Missing a parameter' });
    }
});

module.exports = router;
