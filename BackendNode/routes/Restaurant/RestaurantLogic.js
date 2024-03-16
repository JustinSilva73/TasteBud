const express = require('express');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');


router.post('/like', (req, res) => {
    const { user_id, restaurant_name, yelp_id, liked} = req.body;

    if (user_id && restaurant_name && yelp_id) {
        const db = openConnection();
        if (!db) {
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }
        let l = null
        if(liked) l = liked
        let query = `CALL like_restaurant(${user_id},'${restaurant_name}','${yelp_id}',${l});`;
        db.query(query, [user_id, restaurant_name, yelp_id, liked], (err, results) => {
            if (err) {
                res.status(500).json({ error: err });
                closeConnection(db);
                return
            } else {
                res.json(results[0][0])
            }
        });

    } else {
        console.log('Missing a parameter');
        res.status(400).json({ error: 'Missing a parameter' });
    }
});

module.exports = router;
