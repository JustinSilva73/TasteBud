const express = require('express');
const axios = require('axios');
const router = express.Router();

const YELP_API_KEY = 'lGDedEU4j67hTkD58rj9kgeL1uKLRtqtX-LZkVZF3aBTJmNVMZfGUasXj7HXaxthZDG3StXwCbAKyjwgv3Huh85tAgnj_60On557Jqvj14HfV53qGMkbhROBCC8oZXYx';

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


module.exports = router;
