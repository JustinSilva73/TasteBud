const express = require('express');
//const mysql = require('mysql');
const app = express();
const PORT = 3006;
const cors = require('cors');
app.use(cors()); 
app.use(express.json());
/*
const connection = mysql.createConnection({
    host: 'tastebud.c711eegjx4h3.us-east-2.rds.amazonaws.com',
    user: 'admin',
    password: 'tastebudAWS',
    database: '', 
    port: PORT
});

connection.connect(function(err) {
    if (err) throw err
    console.log('You are now connected...')
  })
*/
const googleMapsRoutes = require('./routes/Google/GoogleMapsLogic');
const googleMapsRoutesTest = require('./routes/Google/TEST_GoogleMapsLogic');
const prioRoute = require('./routes/Priority/DeterminePrio');

app.use('/googleAPI', googleMapsRoutes);

app.use('/TESTgoogleAPI', googleMapsRoutesTest);

app.use('/priority',prioRoute);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server started on http://0.0.0.0:3000');
});

  
