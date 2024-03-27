const express = require('express');
const axios = require('axios');
const router = express.Router();
require('dotenv').config();

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

// Extract Latitude and Longitude Points Function
const extractLatLngPoints = (data) => {
    const points = [];

    if (data.routes && data.routes.length > 0) {
        data.routes.forEach(route => {
            route.legs.forEach(leg => {
                leg.steps.forEach(step => {
                    // Extract start_location of each step
                    points.push({
                        lat: step.start_location.lat,
                        lng: step.start_location.lng
                    });

                    // Extract end_location of each step
                    points.push({
                        lat: step.end_location.lat,
                        lng: step.end_location.lng
                    });
                });
            });
        });
    }

    return points;
};

// Directions Endpoint
router.get('/directions', async (req, res) => {
    const { originLat, originLng, destinationLat, destinationLng } = req.query;

    try {
        const response = await axios.get(`https://maps.googleapis.com/maps/api/directions/json`, {
            params: {
                origin: `${originLat},${originLng}`,
                destination: `${destinationLat},${destinationLng}`,
                key: GOOGLE_MAPS_API_KEY
            }
        });

        if (response.data.status !== "OK") {
            return res.status(500).json({ error: `Failed to get directions: ${response.data.error_message}` });
        }

        // Extract the latitude and longitude points from the response data
        const latLngPoints = extractLatLngPoints(response.data);

        // Return the extracted points
        res.json({ points: latLngPoints });
    } catch (error) {
        console.error('Error fetching directions from Google Maps API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Google Maps API.' });
    }
});

module.exports = router;
