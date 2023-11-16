const express = require('express');
const bcrypt = require('bcrypt');
const axios = require('axios');
const router = express.Router;

const password = 'testPassword';
const saltRounds = 10;

const hashPassword = async (password, saltRounds) => {
    try {
        const salt = await bcrypt.genSalt(saltRounds) //generate salt for password
        return await bcrypt.hash(password, salt)
    }
    catch(error) {
        console.log("Error: ", error)
    }
}

router.post('/hashPassword', async (req, res) => {
    const {password} = req.body;
    if (!password) {
        return res.status(400).json({error: 'No password was provided.'})
    }

    try {
        const hashedPassword = await hashPassword(password, saltRounds);
        return res.status(200).json({hashedPassword});
    }
    catch (error) {
        return res.status(500).json({error: 'Password hashing failed.'});
    }
});

module.exports = router;
