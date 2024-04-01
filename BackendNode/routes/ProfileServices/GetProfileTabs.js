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

            const detailsPromises = results.map(async (restaurant) => {
                return await fetchAllRestaurantDetails(restaurant, yelpLogic, GOOGLE_MAPS_API_KEY);
            });

            let fetchedDetails = await Promise.all(detailsPromises);
            // Combine all details into one array, removing any nulls
            let combinedDetails = fetchedDetails.flat().filter(detail => detail !== null);

            console.log("Combined results for recent visited restaurants:", combinedDetails);
            res.json(combinedDetails);
        });
    } catch (error) {
        console.error('Error: ', error.message);
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

            // Map over results to fetch enriched details for each restaurant
            const enrichedDetailsPromises = results.map(result => 
                getEnrichedRestaurantDetails(result.yelpID, yelpLogic)
                .catch(error => {
                    console.error('Error fetching details for Yelp ID', result.yelpID, ':', error);
                    // Optionally handle individual failures, e.g., by returning a special error object
                    return { error: 'Failed to fetch details', yelpID: result.yelpID };
                })
            );

            // Wait for all promises to resolve
            Promise.all(enrichedDetailsPromises)
                .then(enrichedDetailsArray => {
                    // Filter out any potential failures if you wish to exclude them from the final response
                    const successfulDetails = enrichedDetailsArray.filter(detail => !detail.error);
                    res.json(successfulDetails);
                })
                .catch(error => {
                    // This catch block is for catching any unexpected errors in handling promises
                    console.error('Unexpected error processing restaurant details:', error);
                    res.status(500).json({ error: 'Failed to process restaurant details.' });
                });
        });
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: error.message });
    }
});



async function getEnrichedRestaurantDetails(yelpID, yelpLogic) {
    try {
        console.log('Fetching enriched details for Yelp ID:', yelpID);
        const yelpResponse = await yelpLogic.getYelpRestaurantFromID(yelpID);

        // Check if yelpResponse is null or doesn't contain the expected properties
        if (!yelpResponse || typeof yelpResponse.latitude === 'undefined' || typeof yelpResponse.longitude === 'undefined') {
            console.error(`Invalid Yelp response for Yelp ID: ${yelpID}`);
            // Return a placeholder or error object indicating the issue
            return { error: `Invalid Yelp response for Yelp ID: ${yelpID}`, yelpID: yelpID };
        }

        // Now that yelpResponse has been validated, proceed with the Google API call
        const { latitude, longitude } = yelpResponse;
        const googleResponse = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=24140&type=restaurant&opennow=true&key=${process.env.GOOGLE_MAPS_API_KEY}`);

        if (googleResponse.data.status !== "OK") {
            throw new Error(`Failed to fetch places: ${googleResponse.data.error_message}`);
        }

        const places = googleResponse.data.results;
        const enrichedDetails = places.map(place => {
            // Construct and return each place's details
            return {
                business_name: place.name,
                address: place.vicinity,
                lat: place.geometry.location.lat,
                lng: place.geometry.location.lng,
                rating: place.rating,
                price_level: place.price_level === 0 || place.price_level === undefined ? 1 : place.price_level,
                icon: place.icon,
                opening_hours: place.opening_hours ? place.opening_hours.open_now : null,
                // You can add more details here if needed
            };
        });

        return enrichedDetails;
    } catch (error) {
        console.error('Error in getEnrichedRestaurantDetails:', error);
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
