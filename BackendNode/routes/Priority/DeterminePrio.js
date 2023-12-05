const express = require('express');
const axios = require('axios');
const router = express.Router();

const cuisineValues = {
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

  const priceLevelValues = {
    1: 90,  
    2: 60, 
    3: 30, 
    4: 10   
};

  const distanceValues = {
    1: 70,  
    5: 100, 
    10: 40, 
    15: 10  
};
//const setPriority = async (restaurants, email) => {
router.post('/restaurantPrio', async (req, res) => {

    try {
        const restaurants = req.body.restaurants;
        const email = req.body.email;

        if (!restaurants || !email) {
            return res.status(400).json({ error: 'Restaurants and email are required' });
        }

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
    let cuisinePriority = cuisineValues[restaurant.categories_of_cuisine] ?? 0;
    let ratingPriority = (restaurant.rating * 20);  

    let distancePriority = 0;  
    if (restaurant.distance !== null) {
        if (restaurant.distance <= 1) {
            distancePriority = distanceValues[1];
        } else if (restaurant.distance <= 5) {
            distancePriority = distanceValues[5];
        } else if (restaurant.distance <= 10) {
            distancePriority = distanceValues[10];
        } else if (restaurant.distance <= 15) {
            distancePriority = distanceValues[15];
        }
    }

    let pricePriority = priceLevelValues[restaurant.price_level] ?? 0;

    console.log("Cusine: ", cuisinePriority);
    console.log("Rating: ", ratingPriority);
    console.log("Distance: ", distancePriority);
    console.log("Price: ", pricePriority);

    return cuisinePriority + ratingPriority + distancePriority + pricePriority;
}

module.exports = router;
