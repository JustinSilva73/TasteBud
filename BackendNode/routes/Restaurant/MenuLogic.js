const express = require('express');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

function getRestaurantMenu(yelpID) {
  return new Promise((resolve, reject) => {
    const db = openConnection();
    db.query('SELECT * FROM MenuItems WHERE yelpID = ?', [yelpID], (error, results) => {
      closeConnection(db);
      if (error) {
        console.error('Error executing query: ' + error);
        reject(error);
      } else {
        resolve(results);
      }
    });
  });
}

router.get('/getMenu', async (req, res) => {
  const yelpID = req.query.yelpID;
  try {
    const menu = await getRestaurantMenu(yelpID);
    res.json(menu);
  } catch (error) {
    res.status(500).json({ error: 'Database query error' });
  }
});

module.exports = router;
