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
const googleMapsRoutes = require('./routes/Google/GoogleMapsLogic');
const googleMapsRoutesTest = require('./routes/Google/TEST_GoogleMapsLogic');

app.use('/googleAPI', googleMapsRoutes);

app.use('/TESTgoogleAPI', googleMapsRoutesTest);

app.get('/data', (req, res) => {
    res.json({ message: 'Hello from Node.js backend!' });
});

app.listen(3000, '0.0.0.0', () => {
    console.log('Server started on http://0.0.0.0:3000');
});

  
