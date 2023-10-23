const express = require('express');
const app = express();
const PORT = 3000;
const cors = require('cors');
app.use(cors()); 
/*
const connection = mysql.createConnection({
    host: '',
    user: '',
    password: '',
    database: '', 
    port: PORT
});
*/
const googleMapsRoutes = require('./routes/GoogleMapsLogic');
const yelpRoutes = require('./routes/YelpLogic');

app.use('/googleAPI', googleMapsRoutes);
app.use('/yelpAPI', yelpRoutes);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', function() {
    console.log('Listening on port 3000...');
  });
  
