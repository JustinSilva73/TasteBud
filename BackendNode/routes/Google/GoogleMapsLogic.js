const express = require('express');
const axios = require('axios');
const router = express.Router();
const getYelpRestaurantDetails = require('../Yelp/YelpLogic');

const GOOGLE_MAPS_API_KEY = 'AIzaSyBU_QERfJ4gRBq7o0dTNel-bbNUu9uyirc';

router.get('/restaurants', async (req, res) => {
    const { latitude, longitude } = req.query; 
    const limit = req.query.limit || 25; 

    try {
        const googleResponse = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=24140&type=restaurant&opennow=true&key=${GOOGLE_MAPS_API_KEY}&limit=${limit}`);
        
        if (googleResponse.data.status !== "OK") {
            return res.status(500).json({ error: `Failed to fetch places: ${googleResponse.data.error_message}` });
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
                console.log('Yelp Details:', yelpDetails);
                                
                const yelpCuisines = yelpDetails.categories && yelpDetails.categories.length > 0 ? yelpDetails.categories[0] : '';
                console.log('Yelp Categories', yelpCuisines);
                basicDetails.categories_of_cuisine = yelpCuisines;
                basicDetails.image_url = yelpDetails.imageUrl;
                console.log('ImageURL:', basicDetails.image_url);
                filteredPlaces.push(basicDetails);

            } catch (error) {
                console.error('Error fetching from Yelp API:', error);
                filteredPlaces.push(basicDetails);
            }
        }        
        res.json(filteredPlaces);  

    } catch (error) {
        console.error('Error fetching from Google Maps API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Google Maps API.' });
    }   
});

module.exports = router;
