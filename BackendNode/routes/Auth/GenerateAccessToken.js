const jwt = require("jsonwebtoken")

function generateAccessToken(user) {
    console.log(user)
    return jwt.sign(user, "jwt_secret", { expiresIn: "15m" })
}

module.exports = generateAccessToken