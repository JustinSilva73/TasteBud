const express = require('express');
const axios = require('axios');
const router = express.Router();

const YELP_API_KEY = 'lGDedEU4j67hTkD58rj9kgeL1uKLRtqtX-LZkVZF3aBTJmNVMZfGUasXj7HXaxthZDG3StXwCbAKyjwgv3Huh85tAgnj_60On557Jqvj14HfV53qGMkbhROBCC8oZXYx';
const getYelpRestaurantDetails = async (latitude, longitude, restaurantName) => {
    const options = {
        method: 'GET',
        url: `https://api.yelp.com/v3/businesses/search?latitude=${encodeURIComponent(latitude)}&longitude=${encodeURIComponent(longitude)}&term=${encodeURIComponent('restaurant ' + restaurantName)}&categories=&open_now=true&sort_by=distance&limit=1`,
        headers: {
            accept: 'application/json',
            Authorization: `Bearer ${YELP_API_KEY}`
        }
    };

    try {
        const response = await axios.request(options);

        // Log rate-limit headers
        const rateLimit = response.headers["ratelimit-limit"];
        const rateRemaining = response.headers["ratelimit-remaining"];
        const rateReset = response.headers["ratelimit-reset"];

        console.log(`Rate Limit: ${rateLimit}`);
        console.log(`Rate Remaining: ${rateRemaining}`);
        console.log(`Rate Reset: ${rateReset} (time in seconds until reset)`);

        // Check if businesses array is present and has at least one item
        if (response.data.businesses && response.data.businesses.length > 0) {
            const business = response.data.businesses[0];
            return {
                imageUrl: business.image_url,
                categories: business.categories.map(category => category.title)
            };
        } else {
            // Handle the case where no businesses are found
            console.log('No businesses found for the given query.');
            return null;
        }
    } catch (error) {
        if (error.response) {
            console.error('Yelp API Error Response:', error.response.data);
        } else {
            console.error('Error fetching from Yelp API:', error.message);
        }
        // Additionally, if you want to inspect error response headers
        if (error.response && error.response.headers) {
            const rateLimit = error.response.headers["ratelimit-limit"];
            const rateRemaining = error.response.headers["ratelimit-remaining"];
            const rateReset = error.response.headers["ratelimit-reset"];
            
            console.log(`(Error) Rate Limit: ${rateLimit}`);
            console.log(`(Error) Rate Remaining: ${rateRemaining}`);
            console.log(`(Error) Rate Reset: ${rateReset} (time in seconds until reset)`);
        }

        console.error('Error fetching from Yelp API:', error);
        throw new Error('Failed to fetch data from Yelp API.');
    }
};


/*
router.get('/restaurantDetails', async (req, res) => {
    const { address } = req.query;

    const options = {
        method: 'GET',
        url: `https://api.yelp.com/v3/businesses/search?location=${address}&term=restaurant&categories=&open_now=true&sort_by=distance&limit=1`,
        headers: {
            accept: 'application/json',
            Authorization: 'Bearer lGDedEU4j67hTkD58rj9kgeL1uKLRtqtX-LZkVZF3aBTJmNVMZfGUasXj7HXaxthZDG3StXwCbAKyjwgv3Huh85tAgnj_60On557Jqvj14HfV53qGMkbhROBCC8oZXYx'
        }
    };

    try {
        const response = await axios.request(options);
        
        const restaurantDetails = {
            imageUrl: response.data.image_url,
            price: response.data.price,
            categories: response.data.categories.map(category => category.title)
        };

        res.json(restaurantDetails);
    } catch (error) {
        console.error('Error fetching from Yelp API:', error);
        res.status(500).json({ error: 'Failed to fetch data from Yelp API.' });
    }
});
*/

module.exports = getYelpRestaurantDetails;
