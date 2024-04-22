/*
const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const { openConnection, closeConnection } = require('../DatabaseLogic');
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

const getUserID = async (email) => {
  return new Promise((resolve, reject) => {
      const query = `SELECT user_id FROM Users WHERE email = ?`;
      let db = openConnection();
      db.query(query, [email], (err, results) => {
          closeConnection(db); // Make sure to close connection in both cases
          if (err) {
              reject(err);
          } else {
              if (results.length > 0) {
                  resolve(results[0].user_id);
              } else {
                  reject(new Error('No user found with that email.'));
              }
          }
      });
  });
};
// Create an S3 client
const s3Client = new S3Client({});
router.post('/profile-pic', async (req, res) => {

  try {
    // Extract the profile picture link and image data from the request body
    const {imageData, email} = req.body;

    // Ensure both profilePicLink and imageData are provided
    if (!imageData) {
      return res.status(400).json({ error: 'Profile picture link and image data are required' });
    }

    // Open a connection to the database
    const connection = openConnection();

    // Execute the SQL query to insert the profilePicLink into the Users table
    const query = 'INSERT INTO Users (profilePicLink) VALUES (?) where email = ?';
    connection.query(query, [profilePicLink, email], async (error, results) => {
      if (error) {
        console.error('Error inserting profile picture link:', error);
        closeConnection(connection);
        return res.status(500).json({ error: 'Internal server error' });
      }

      // Upload the image data to S3
      const uploadParams = {
        Bucket: process.env.AWS_BUCKET,
        Key: `${results.insertId}.jpg`,
        Body: Buffer.from(imageData, 'base64'),
        ContentType: 'image/jpeg'
      };

      try {
        await s3Client.send(new PutObjectCommand(uploadParams));
      } catch (s3Error) {
        console.error('Error uploading image to S3:', s3Error);
        closeConnection(connection);
        return res.status(500).json({ error: 'Internal server error' });
      }
      closeConnection(connection);

      return res.status(200).json({ success: true, message: 'Profile picture link and image uploaded successfully' });
    });
  } catch (error) {
    console.error('Error processing request:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
*/