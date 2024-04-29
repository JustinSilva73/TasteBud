const express = require('express');
const axios = require('axios');
require('dotenv').config(); // Make sure to call this early to load your environment variables
const { openConnection, closeConnection } = require('../DatabaseLogic');
const yelpLogic = require('../Yelp/YelpLogic');
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;
const router = express.Router();
const defaultYelpDetails = {
    imageUrls: [
        "https://plus.unsplash.com/premium_photo-1679435445402-fd6940d68535?auto=format&fit=crop&q=80&w=1887&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "https://plus.unsplash.com/premium_photo-1683121324272-90f4b4084ac9?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8YW1lcmljYW4lMjBmb29kfGVufDB8fDB8fHww",
        "https://images.unsplash.com/photo-1631561411148-1d397c56f35e?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGl0YWxpYW4lMjBmb29kfGVufDB8fDB8fHww",
        "https://plus.unsplash.com/premium_photo-1668202961193-4c5a66a2d68d?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8QmFyJTIwZm9vZHxlbnwwfHwwfHx8MA%3D%3D",
        "https://images.unsplash.com/photo-1617196035154-1e7e6e28b0db?auto=format&fit=crop&q=60&w=500&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8amFwYW5lc2UlMjBmb29kfGVufDB8fDB8fHww",
    ],
    categories: ["American", "Italian", "Chinese", "Mexican", "Indian", "Japanese", "Mediterranean"]
};

// Helper function to get a random item from an array
const getRandomItem = (items) => {
    return items[Math.floor(Math.random() * items.length)];
};
// Helper function to get user ID
const getUserID = async (email) => {
    return new Promise((resolve, reject) => {
        const query = `SELECT user_id FROM Users WHERE email = ?`;
        let db = openConnection();
        db.query(query, [email], (err, results) => {
            closeConnection(db); // Make sure to close connection in both cases
            if (err) {
                reject(err);
            } else {
                if (results.length > 0) {
                    resolve(results[0].user_id);
                } else {
                    reject(new Error('No user found with that email.'));
                }
            }
        });
    });
};

router.get('/recentVisited', async (req, res) => {
    const { email } = req.query;
    console.log("Fetching recent visited restaurants for email:", email);
    try {
        const user_id = await getUserID(email);
        console.log("Found user ID for the email:", user_id);
        const db = openConnection();
        const query = 'SELECT * FROM RecentRestaurants WHERE userID = ?';

        db.query(query, [user_id], async (error, results) => {
            closeConnection(db);
            if (error) {
                console.error('Error executing query: ' + error);
                res.status(500).json({ error: 'Database query error' });
                return;
            }

            if (results.length === 0) {
                return res.status(404).json({ message: 'No recently visited restaurants found.' });
            }

            let successfulDetails = [];
            for (let result of results) {
                try {
                    const detail = await getMoreRestaurantDetails(result.yelpID, yelpLogic);
                    if (detail !== null) {
                        successfulDetails.push(detail);
                    }
                } catch (error) {
                        console.error('Error fetching details for Yelp ID', result.yelpID, ':', detail.error);
                }
            }

            console.log("Combined results for recent visited restaurants:", successfulDetails);
            res.json(successfulDetails);
        });
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: error.message });
    }
});



router.get('/likedRestaurants', async (req, res) => {
    const { email } = req.query;
    console.log("Fetching liked restaurants for email:", email);
    try {
        const user_id = await getUserID(email);
        console.log("Found user ID for the email:", user_id);
        const db = openConnection();
        const query = 'SELECT * FROM UserRestaurants WHERE userID = ? AND liked = 1';

        db.query(query, [user_id], async (error, results) => {
            closeConnection(db);
            if (error) {
                console.error('Error executing query:', error);
                return res.status(500).json({ error: 'Database query error' });
            }

            if (results.length === 0) {
                return res.status(404).json({ message: 'No liked restaurants found.' });
            }

            let successfulDetails = [];
            for (let result of results) {
                try {
                    const detail = await getMoreRestaurantDetails(result.yelpID, yelpLogic);
                    if (!detail.error) {
                        successfulDetails.push(detail);
                    } else {
                        // Log or handle individual restaurant fetch errors
                        console.error('Error fetching details for Yelp ID', result.yelpID, ':', detail.error);
                    }
                } catch (error) {
                    console.error('Error fetching details for Yelp ID', result.yelpID, ':', error);
                    // Optionally handle individual promise rejections, e.g., by logging or adding an error object to successfulDetails
                }
            }

            console.log("Combined results for liked restaurants:", successfulDetails);
            res.json(successfulDetails);
        });
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: error.message });
    }
});

async function getMoreRestaurantDetails(yelpID, yelpLogic) {
    try {
        console.log('Fetching more details for Yelp ID:', yelpID);
        const yelpResponse = await yelpLogic.getYelpRestaurantFromID(yelpID);

        if (!yelpResponse || typeof yelpResponse.lat === 'undefined' || typeof yelpResponse.lng === 'undefined') {
            console.error('yelpResponse is undefined or null, or missing lat/lng properties for Yelp ID:', yelpID);
            return null; // Or return an error object if that fits your use case better
        }

        const googleResponse = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${yelpResponse.lat},${yelpResponse.lng}&rankby=distance&type=restaurant&name=${encodeURIComponent(yelpResponse.name)}&key=${GOOGLE_MAPS_API_KEY}`);

        if (googleResponse.data.status !== "OK") {
            console.error('Failed to fetch places. Response:', googleResponse.data);
            throw new Error(`Failed to fetch places. Status: ${googleResponse.data.status}, Error message: ${googleResponse.data.error_message || 'No error message provided'}.`);
        }

        // Assuming you are interested in the closest result, use the first result directly
        const place = googleResponse.data.results[0];
        if (!place) {
            console.error('No places found for the given criteria');
            return null;
        }

        // Directly create the moreDetails object without mapping
        const moreDetails = {
            business_name: place.name,
            address: place.vicinity,
            lat: place.geometry.location.lat,
            lng: place.geometry.location.lng,
            rating: place.rating,
            price_level: place.price_level || 1, // Assume price_level 1 if undefined
            icon: place.icon,
            opening_hours: place.opening_hours ? place.opening_hours.open_now : false,
            categories_of_cuisine: yelpResponse.categories[0],
            image_url: yelpResponse.imageUrl,
            url: yelpResponse.url,
            yelpID: yelpResponse.yelpID
        };

        return moreDetails;
    } catch (error) {
        console.error('Error in getMoreRestaurantDetails:', error);
        // Properly log the caught error
        throw error; // Rethrow the error to handle it in the calling function
    }
}


router.get('/username', async (req, res) => {
    const { email } = req.query;
    try {
        const db = openConnection();
        const query = 'SELECT username FROM Users WHERE email = ?';

        db.query(query, [email], (error, results) => {
            closeConnection(db);
            if (error) {
                console.error('Error executing query: ' + error);
                res.status(500).json({ error: 'Database query error' });
            } else {
                console.log("Username result from /username endpoint for email:", email, results[0].username);
                res.json(results[0].username);
            }
        });
    } catch (error) {
        console.error('Error: ', error.message);
        res.status(500).json({ error: error.message });
    }
});


module.exports = router;
