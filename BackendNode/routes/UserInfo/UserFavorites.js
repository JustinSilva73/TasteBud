const express = require('express');
const axios = require('axios');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');
const googleMapsLogic = require('../Google/GoogleMapsLogic');
const yelpLogic = require('../Yelp/YelpLogic');

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

const getDistanceFromLatLonInKm = (lat1, lon1, lat2, lon2) => {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1); 
    var a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
      Math.sin(dLon/2) * Math.sin(dLon/2)
      ; 
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
    var d = R * c; // Distance in km
    return d;
  }
  
  function deg2rad(deg) {
    return deg * (Math.PI/180)
  }

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

router.post('/pos', async (req, res) => {
    const email = req.body.email;
    const latitude = req.body.latitude;
    const longitude = req.body.longitude;

    try {
        const user_id = await getUserID(email);
        const places = await googleMapsLogic.searchNearByRestaurants(latitude, longitude, 10);

        let closestRestaurant;
        let min = null;
        for (let place of places) {
            const dist = getDistanceFromLatLonInKm(place.lat, place.lng, latitude, longitude);
            if (min == null || dist < min){
                closestRestaurant = place;
                min = dist
            }
        }
        
        if (closestRestaurant) {
        let yelpRes;
        try {
            //UNCOMMENT BELOW TO GET YELP DETAILS WORKING
            yelpRes = await yelpLogic.getYelpRestaurantDetails(closestRestaurant.lat, closestRestaurant.lng, closestRestaurant.business_name);
            console.log("YelpDetails: ", yelpRes);
        } catch (error) {
            console.error('Error fetching from Yelp API:', error);
        }

        // const yelpRes = await yelpLogic.getYelpRestaurantFromPosition(latitude, longitude);
        const db = openConnection();
        if (!db) {
            console.log('Failed to connect to the database');
            return res.status(500).json({ error: 'Failed to connect to the database' });
        }
        console.log('user_id:', user_id);
        if (yelpRes) {
            console.log('recent restaurant', yelpRes.yelpID, yelpRes.categories, yelpRes.address)
            const queryRecentRes = `INSERT INTO tastebud.RecentRestaurants (userID, restaurantName, yelpID, restaurantAddress)
                                    VALUES (?, ?, ?, ?)`
            db.query(queryRecentRes, [user_id, yelpRes.name, yelpRes.yelpID,  yelpRes.address], (err, results) => {
                if (err) {
                    console.log('Error:', err);
                    res.status(500).json({ error: err });
                    closeConnection(db);
                    return;
                }
            });

            let american = yelpRes.categories.indexOf('American (New)') != -1 || yelpRes.categories.indexOf('American (Traditional)') != -1 ? 1 : 0;
            let italian = yelpRes.categories.indexOf('Italian') != -1 ? 1 : 0;
            let chinese = yelpRes.categories.indexOf('Chinese') != -1 ? 1 : 0;
            let japanese = yelpRes.categories.indexOf('Japanese') != -1 ? 1 : 0;
            let mexican = yelpRes.categories.indexOf('Mexican') != -1 ? 1 : 0;
            let indian = yelpRes.categories.indexOf('Indian') != -1 ? 1 : 0;
            let mediterranean = yelpRes.categories.indexOf('Mediterranean') != -1 ? 1 : 0;
            let thai = yelpRes.categories.indexOf('Thai') != -1 ? 1 : 0;
            const query = `UPDATE tastebud.CuisineWeights 
                               SET  american_weight = american_weight + ${american}, 
                                    italian_weight = italian_weight + ${italian}, 
                                    chinese_weight = chinese_weight + ${chinese}, 
                                    japanese_weight = japanese_weight + ${japanese}, 
                                    mexican_weight = mexican_weight + ${mexican},
                                    indian_weight = indian_weight + ${indian}, 
                                    mediterranean_weight = mediterranean_weight + ${mediterranean},
                                    thai_weight = thai_weight + ${thai} 
                               WHERE user_id = ?`;

            db.query(query, [user_id], (err, results) => {
                if (err) {
                    console.log('Error:', err);
                    res.status(500).json({ error: err });
                    closeConnection(db);
                    return;
                } else {
                    res.json('Success'); // Adjust based on your expected result structure
                }
            });
        }
    }
    else {
        console.log('No restaurant found in the area.')
        res.json('Success');
    }

    } catch (error) {
        console.log('Error:', error);
        return res.status(500).json({ error: 'Failed to process your request' });
    }
});

module.exports = router;

