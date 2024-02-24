const express = require('express');
const axios = require('axios');
const router = express.Router();

const getYelpRestaurantDetails = require('../Yelp/YelpLogic');

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

router.get('/restaurants', async (req, res) => {
    const { latitude, longitude } = req.query; 
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

    try {
        const googleResponse = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=24140&type=restaurant&opennow=true&key=${GOOGLE_MAPS_API_KEY}`);
        
        if (googleResponse.data.status !== "OK") {
            return res.status(500).json({ error: `Failed to fetch places: ${googleResponse.data.error_message}` });
        }
        
        const places = googleResponse.data.results;
        const filteredPlaces = [];

        for (let place of places) {
            console.log("Checking vicinity value:", place.vicinity);
            const basicDetails = {
                business_name: place.name,
                address: place.vicinity,
                lat: place.geometry.location.lat,
                lng: place.geometry.location.lng,
                rating: place.rating,
                price_level: place.price_level === 0 || place.price_level === undefined ? 1 : place.price_level,
                icon: place.icon,   
                opening_hours: place.opening_hours ? place.opening_hours.open_now : null
            };
            

            let yelpDetails;
            try {
                //UNCOMMENT BELOW TO GET YELP DETAILS WORKING
                yelpDetails = await getYelpRestaurantDetails(place.geometry.location.lat, place.geometry.location.lng, place.name);
                console.log("YelpDetails: ", yelpDetails);
            } catch (error) {
                console.error('Error fetching from Yelp API:', error);
            }

            // Assign values based on yelpDetails or use random values if yelpDetails is undefined
            basicDetails.categories_of_cuisine = yelpDetails && yelpDetails.categories && yelpDetails.categories.length > 0
                ? yelpDetails.categories[0]
                : getRandomItem(defaultYelpDetails.categories);

            basicDetails.image_url = yelpDetails && yelpDetails.imageUrl
                ? yelpDetails.imageUrl
                : getRandomItem(defaultYelpDetails.imageUrls);
            
            basicDetails.url = yelpDetails && yelpDetails.url
                ? yelpDetails.url
                : "https://www.yelp.com"
            
            console.log("Assigned URL:", basicDetails.url); // Log the assigned URL for debugging

            filteredPlaces.push(basicDetails);
        } 
        res.json(filteredPlaces); 
    } catch (error) {
        console.error('Error fetching from Google Maps API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Google Maps API.' });
    }   
});



module.exports = router;
