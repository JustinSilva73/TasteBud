const express = require('express');
const axios = require('axios');
const router = express.Router();

const GOOGLE_MAPS_API_KEY = 'AIzaSyBU_QERfJ4gRBq7o0dTNel-bbNUu9uyirc';

router.get('/restaurants', async (req, res) => {    
    const { latitude, longitude } = req.query;
    try {
        const response = await axios.get(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=24140&type=restaurant&opennow=true&key=${GOOGLE_MAPS_API_KEY}`);
        if (response.data.status === "OK") {
            res.json(response.data.results);
            console.log("Success");
        } else {
            res.status(500).json({ error: `Failed to fetch places: ${response.data.error_message}` });
        }
    } catch (error) {
        console.error('Error fetching from Google Maps API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Google Maps API.' });
    }
    
});

module.exports = router;
