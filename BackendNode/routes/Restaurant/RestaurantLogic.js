const express = require('express');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

async function findUserIdByEmail(email) {
    return new Promise((resolve, reject) => {
        const db = openConnection();
        if (!db) {
            reject('Failed to connect to the database');
            return;
        }

        const findUserIdQuery = `SELECT user_id FROM Users WHERE email = ?`;
        db.query(findUserIdQuery, [email], (err, results) => {
            closeConnection(db);
            if (err) {
                reject(err);
                return;
            }

            if (results.length === 0) {
                reject('User not found');
                return;
            }

            const user_id = results[0].user_id;
            resolve(user_id);
        });
    });
}

router.post('/like', async (req, res) => {
    const { email, restaurant_name, yelp_id, likedVal, restaurant_address } = req.body;
    console.log("liked:", likedVal)
    try {
        const user_id = await findUserIdByEmail(email);
        const db = openConnection();
        if (!db) {
            console.log('Failed to connect to the database');
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }
        console.log('user_id:', user_id);
        let l = likedVal ? likedVal : null;
        let query = `CALL like_restaurant(?, ?, ?, ?, ?);`;

        db.query(query, [user_id, restaurant_name, yelp_id, l, restaurant_address], (err, results) => {
            if (err) {
                console.log('Error:', err);
                res.status(500).json({ error: err });
                closeConnection(db);
                return;
            } else {
                console.log('Results:', results);
                res.json(results[0][0] || 'Success'); // Adjust based on your expected result structure
            }
        });

    } catch (error) {
        console.log('Error:', error);
        return res.status(500).json({ error: 'Failed to process your request' });
    }
});

router.get('/status', (req, res) => {
    console.log('Received request for /status');

    const { yelpID, email } = req.query;
    console.log(`Query parameters received - yelpID: ${yelpID}, email: ${email}`);

    if (!yelpID || !email) {
        console.log('Missing yelpID or email in the request');
        return res.status(400).json({ error: 'Missing yelpID or email' });
    }

    findUserIdByEmail(email)
        .then((userID) => {
            console.log(`Found userID: ${userID} for email: ${email}`);
            const db = openConnection();

            if (!db) {
                console.log('Failed to connect to the database');
                return res.status(500).json({ error: 'Failed to connect to the database' });
            }

            const query = `SELECT liked FROM UserRestaurants WHERE userID = ? AND yelpID = ?`;
            console.log(`Executing query: ${query} with userID: ${userID} and yelpID: ${yelpID}`);

            db.query(query, [userID, yelpID], (err, results) => {
                closeConnection(db);
                if (err) {
                    console.log(`Query error: ${err.message}`);
                    return res.status(500).json({ error: err.message });
                }

                if (results.length === 0) {
                    console.log('No matching records found for given userID and yelpID');
                    return res.json({ liked: null });
                }

                const liked = results[0].liked;
                console.log(`Query successful. Liked status: ${liked}`);
                res.json({ liked });
            });
        })
        .catch((err) => {
            console.log(`Error finding userID by email: ${err.message}`);
            res.status(500).json({ error: err.message });
        });
});

module.exports = router;
