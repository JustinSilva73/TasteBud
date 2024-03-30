const express = require('express');
const axios = require('axios');
const router = express.Router();
const { google } = require('googleapis');
const places = google.places({ version: 'v3', auth: 'YOUR_API_KEY' });
const { openConnection, closeConnection } = require('../DatabaseLogic');

require('dotenv').config();

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


router.get('/recentVisited', async (req, res) => {
    const { email } = req.query;
    const user_id = await getUserID(email);
    const db = openConnection();
    const query = 'SELECT * FROM RecentRestaurants WHERE user_id = ?';

    db.query(query, [user_id], async (error, results) => {
        closeConnection(db);
        if (error) {
            console.error('Error executing query: ' + error);
            res.status(500).json({ error: 'Database query error' });
        } else {
            // Assuming results contain restaurant names and possibly addresses
            const restaurant = results[0]; // Example: using the first result
            const searchResponse = await places.textSearch({
                query: `${restaurant.name} ${restaurant.address}`,
                type: 'restaurant'
            });

            // Assuming we find a match and take the first result
            const placeId = searchResponse.data.results[0].place_id;
            
            const detailsResponse = await places.placeDetails({
                place_id: placeId,
                fields: ['name', 'rating', 'formatted_phone_number', 'geometry']
            });

            // Now you have details from Google Places API
            res.json(detailsResponse.data.result);
        }
    });
});




