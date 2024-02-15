const express = require('express');
const axios = require('axios');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

const getUserWeights = async (email) => {
    return new Promise((resolve, reject) => {
        const queryWeights = `SELECT
            CW.american_weight, CW.italian_weight, CW.chinese_weight, CW.japanese_weight, CW.mexican_weight, CW.indian_weight, CW.mediterranean_weight, CW.thai_weight,
            DW.near_weight, DW.middle_weight, DW.far_weight,
            PW.one_weight, PW.two_weight, PW.three_weight, PW.four_weight
            FROM Users as u
            LEFT JOIN tastebud.CuisineWeights CW ON u.user_id = CW.user_id
            LEFT JOIN tastebud.DistanceWeight DW ON u.user_id = DW.user_id
            LEFT JOIN tastebud.PriceWeights PW ON u.user_id = PW.user_id
            WHERE u.email = ?`;
        let db = openConnection();  
        db.query(queryWeights, [email], (err, results) => {
            if (err) {
                reject(err);
            } else {
                resolve(results[0]);
            }
        });
        closeConnection(db);
    });
};
const updateCuisineValues = (userWeights) => {
    return {
        "American": userWeights.american_weight,
        "Italian": userWeights.italian_weight,
        "Chinese": userWeights.chinese_weight,
        "Japanese": userWeights.japanese_weight,
        "Mexican": userWeights.mexican_weight,
        "Indian": userWeights.indian_weight,
        "Mediterranean": userWeights.mediterranean_weight,
        "Thai": userWeights.thai_weight,
    };
};
const updatePriceLevelValues = (userWeights) => {
    return {
        1: userWeights.one_weight,
        2: userWeights.two_weight,
        3: userWeights.three_weight,
        4: userWeights.four_weight,
    };
};

// Function to update distance values based on user weights
const updateDistanceValues = (userWeights) => {
    return {
        1: userWeights.near_weight,
        5: userWeights.middle_weight,
        10: userWeights.far_weight,
    };
};

let cuisineValues = {
    "American": 40,
    "Italian": 90,
    "Chinese": 70,
    "Japanese": 20,
    "Mexican": 60,
    "Indian": 30,
    "Mediterranean": 50,
    "Thai": 10,
    "British": 80,
    "Spanish": 100
  };
let priceLevelValues = {
    1: 90,  
    2: 60, 
    3: 30, 
    4: 10   
};

let distanceValues = {
    1: 70,  
    5: 100, 
    10: 40, 
};

//const setPriority = async (restaurants, email) => {
router.post('/restaurantPrio', async (req, res) => {
    try {
        const restaurants = req.body.restaurants;
        const email = req.body.email;

        if (!restaurants || !email) {
            return res.status(400).json({ error: 'Restaurants and email are required' });
        }
        const userWeights = await getUserWeights(email);

        // Update values based on user weights
        cuisineValues = updateCuisineValues(userWeights);
        priceLevelValues = updatePriceLevelValues(userWeights);
        distanceValues = updateDistanceValues(userWeights);

        // Calculate priority for each restaurant
        const updatedRestaurants = restaurants.map(restaurant => {
            const totalPoints = computePriority(restaurant);
            return { ...restaurant, totalPoints };
        });
        console.log("Before sorting:");
        restaurants.forEach(restaurant => {
            console.log(restaurant.business_name, "-", restaurant.totalPoints);
        });
        
        updatedRestaurants.sort((a, b) => b.totalPoints - a.totalPoints);
        console.log("After sorting:");
        updatedRestaurants.forEach(restaurant => {
            console.log(restaurant.business_name, "-", restaurant.totalPoints);
        });

        console.log("Successful pull from prio");
        res.json(updatedRestaurants);
    } catch (error) {
        console.error("Error in /restaurantPrio:", error);
        res.status(500).send("Internal Server Error");
    }
});
    

  
  const computePriority = (restaurant) => {
    console.log(`Processing Restaurant: ${restaurant.business_name}`);
    console.log(`Cuisine: ${restaurant.categories_of_cuisine}, Rating: ${restaurant.rating}, Distance: ${restaurant.distance}, Price Level: ${restaurant.price_level}`);

    let cuisinePriority = cuisineValues[restaurant.categories_of_cuisine] ?? 0;
    let ratingPriority = (restaurant.rating * 20);  

    let distancePriority = 0;  
    if (restaurant.distance !== null && restaurant.distance !== undefined) {
        if (restaurant.distance <= 1) {
            distancePriority = distanceValues[1];
        } else if (restaurant.distance <= 5) {
            distancePriority = distanceValues[5];
        } else {
            distancePriority = distanceValues[10];
        }
    } else {
        distancePriority = 0; // Default to 0 if distance is null or undefined
    }

    let pricePriority = priceLevelValues[restaurant.price_level] ?? 0;

    console.log(`Restaurant: ${restaurant.business_name}`);
    console.log(`Cuisine Priority: ${cuisinePriority}, Rating Priority: ${ratingPriority}, Distance Priority: ${distancePriority}, Price Priority: ${pricePriority}`);
    
    return cuisinePriority + ratingPriority + distancePriority + pricePriority;
}

module.exports = router;
