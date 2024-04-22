/*
const express = require('express');
const router = express.Router();
const { openConnection, closeConnection } = require('../DatabaseLogic');

import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3";

const client = new S3Client({});

const grabImage = async () => {
  const command = new GetObjectCommand({
    Bucket: process.env.AWS_BUCKET,
    Key: process.env.AWS_BUCKETKEY,
  });

  try {
    const response = await client.send(command);
    const str = await response.Body.transformToString();
    console.log(str);
    return str; // You might want to return the string if you're calling this function externally
  } catch (err) {
    console.error(err);
    throw err; // Rethrow the error if you're not handling it here
  }
};

router.get('/grabImage', async (req, res) => {
    const { email } = req.query;
    const db = openConnection();
    const query = 'SELECT profilePicLink FROM Users WHERE email = ?';
    db.query(query, [email], async (error, results) => {
        closeConnection(db);
        if (error) {
            console.error('Error executing query: ' + error);
            res.status(500).json({ error: 'Database query error' });
            return;
        }

        if (results.length === 0) {
            return res.status(404).json({ message: 'No user found with that email.' });
        }

        const profilePicLink = results[0].profilePicLink;
        try {
            const image = await grabImage();
            res.json({ profilePicLink, image });
        } catch (error) {
            console.error('Error:', error.message);
            res.status(500).json({ error: error.message });
        }
    });
});

module.exports = router;
*/