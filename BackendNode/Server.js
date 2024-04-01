// require('dotenv').config();
const express = require('express');
const app = express();
const PORT = 3006;
const cors = require('cors');
require('dotenv').config({ path: '/.env' });

app.use(cors()); 
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


const googleMapsRoutes = require('./routes/Google/GoogleMapsLogic');
const googleMapsRoutesTest = require('./routes/Google/TGoogleMapsLogic');
const prioRoute = require('./routes/Priority/DeterminePrio');
const auth = require('./routes/Auth/Auth');
const survey = require('./routes/Survey/survey');

const userInfo = require('./routes/UserInfo/UserFavorites');   
const userRestaurant = require('./routes/Restaurant/RestaurantLogic');
const menu = require('./routes/Restaurant/MenuLogic');
const profile = require('./routes/ProfileServices/GetProfileTabs');

app.use('/googleAPI', googleMapsRoutes);
app.use('/TESTgoogleAPI', googleMapsRoutesTest);
app.use('/priority',prioRoute);
app.use('/auth',auth);
app.use('/survey',survey);
app.use('/userInfo',userInfo);
app.use('/restaurant', userRestaurant)
app.use('/menu', menu);
app.use('/profile', profile);

app.use('/routing', directions);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', () => {
    console.log(process.env);
    console.log('Server started on http://0.0.0.0:3000');
});
