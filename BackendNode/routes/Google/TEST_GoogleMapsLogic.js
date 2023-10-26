const express = require('express');
const axios = require('axios');
const router = express.Router();
const getYelpRestaurantDetails = require('../Yelp/YelpLogic');

const GOOGLE_MAPS_API_KEY = 'AIzaSyBU_QERfJ4gRBq7o0dTNel-bbNUu9uyirc';

const getRestaurantDetails = async (latitude, longitude) => {
    const googleResponse = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=24140&type=restaurant&opennow=true&key=${GOOGLE_MAPS_API_KEY}`);
    
    if (googleResponse.data.status !== "OK") {
        throw new Error(`Failed to fetch places from Google: ${googleResponse.data.error_message}`);
    }

    const places = googleResponse.data.results;
    const filteredPlaces = [];

    for (let place of places) {
        const basicDetails = {
            business_name: place.name,
            address: place.vicinity,
            lat: place.geometry.location.lat,
            lng: place.geometry.location.lng,
            rating: place.rating,
            price_level: place.price_level,
            icon: place.icon,
            opening_hours: place.opening_hours ? place.opening_hours.open_now : null
        };

        try {
            const yelpDetails = await getYelpRestaurantDetails(place.vicinity);
            basicDetails.categories_of_cuisine = yelpDetails.categories && yelpDetails.categories.length > 0 ? yelpDetails.categories[0] : '';
            basicDetails.image_url = yelpDetails.imageUrl;
        } catch (error) {
            console.error('Error fetching from Yelp API:', error);
        }

        filteredPlaces.push(basicDetails);
    }

    return filteredPlaces;
};

router.get('/testRestaurant', async (req, res) => {
    const { latitude, longitude } = req.query;
    try {
        const results = await getRestaurantDetails(latitude, longitude, 1);
        res.json(results);
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ error: `Failed to fetch data: ${error.message}` });
    }
});

module.exports = router;
