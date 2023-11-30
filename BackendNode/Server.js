const express = require('express');
//const mysql = require('mysql');
const app = express();
const PORT = 3000;
const cors = require('cors');
app.use(cors()); 
app.use(express.json());


const googleMapsRoutes = require('./routes/Google/GoogleMapsLogic');
const googleMapsRoutesTest = require('./routes/Google/TEST_GoogleMapsLogic');
const prioRoute = require('./routes/Priority/DeterminePrio');
const loginRoute = require('./routes/Login/login');
const registrationRoute = require('./routes/Registration/registration');

app.use('/googleAPI', googleMapsRoutes);

app.use('/TESTgoogleAPI', googleMapsRoutesTest);

app.use('/priority',prioRoute);

app.use('/login', loginRoute);

app.use('/registration', registrationRoute);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server started on http://0.0.0.0:3000');
});

  
