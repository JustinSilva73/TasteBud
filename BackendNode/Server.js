const express = require('express');
const app = express();
const PORT = 3006;
const cors = require('cors');
const cookieSession = require("cookie-session");

app.use(cors()); 
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(
    cookieSession({
      name: "bezkoder-session",
      keys: ["COOKIE_SECRET"], 
      httpOnly: true,
    })
);

const googleMapsRoutes = require('./routes/Google/GoogleMapsLogic');
const googleMapsRoutesTest = require('./routes/Google/TEST_GoogleMapsLogic');
const prioRoute = require('./routes/Priority/DeterminePrio');
const auth = require('./routes/Auth/Auth');

const surveyRoute = require('./routes/Survey/survey');

app.use('/googleAPI', googleMapsRoutes);

app.use('/TESTgoogleAPI', googleMapsRoutesTest);

app.use('/priority',prioRoute);

app.use('/auth',auth);

app.use('/survey',surveyRoute);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server started on http://0.0.0.0:3000');
});
