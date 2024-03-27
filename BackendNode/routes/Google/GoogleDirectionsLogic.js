const express = require('express');
const axios = require('axios');
const router = express.Router();
require('dotenv').config();

const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

// Extract Latitude and Longitude Points Function
const extractLatLngPoints = (data) => {
    const points = [];
    console.log('Extracting LatLng points...');

    if (data.routes && data.routes.length > 0) {
        data.routes.forEach((route, routeIndex) => {
            console.log(`Processing route ${routeIndex + 1}/${data.routes.length}`);
            route.legs.forEach((leg, legIndex) => {
                console.log(`Processing leg ${legIndex + 1}/${route.legs.length}`);
                leg.steps.forEach((step, stepIndex) => {
                    // Extract start_location of each step
                    points.push({
                        lat: step.start_location.lat,
                        lng: step.start_location.lng
                    });

                    console.log(`Step ${stepIndex + 1}/${leg.steps.length} start_location:`, step.start_location);

                    // Extract end_location of each step
                    points.push({
                        lat: step.end_location.lat,
                        lng: step.end_location.lng
                    });

                    console.log(`Step ${stepIndex + 1}/${leg.steps.length} end_location:`, step.end_location);
                });
            });
        });
    } else {
        console.log('No routes found in the response data.');
    }

    return points;
};

// Directions Endpoint
router.get('/directions', async (req, res) => {
    const { originLat, originLng, destinationLat, destinationLng } = req.query;
    console.log('Received request for directions:', { originLat, originLng, destinationLat, destinationLng });

    try {
        const response = await axios.get(`https://maps.googleapis.com/maps/api/directions/json`, {
            params: {
                origin: `${originLat},${originLng}`,
                destination: `${destinationLat},${destinationLng}`,
                key: GOOGLE_MAPS_API_KEY
            }
        });

        console.log('Google Maps API response status:', response.data.status);

        if (response.data.status !== "OK") {
            console.error('Failed to get directions:', response.data.error_message);
            return res.status(500).json({ error: `Failed to get directions: ${response.data.error_message}` });
        }

        // Extract the latitude and longitude points from the response data
        const latLngPoints = extractLatLngPoints(response.data);

        // Log the extracted points
        console.log('Extracted points:', latLngPoints);

        // Return the extracted points
        res.json({ points: latLngPoints });
    } catch (error) {
        console.error('Error fetching directions from Google Maps API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Google Maps API.' });
    }
});

module.exports = router;
