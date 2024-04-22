// profileRoutes.js
const express = require('express');
const router = express.Router();

// Import individual routes from the same directory
const getProfileTabs = require('./GetProfileTabs');
//const grabImage = require('./GrabImage');
//const insertPictureLinkLogic = require('./InsertPictureLinkLogic');

// Use them on the router
router.use('/tabs', getProfileTabs);
//router.use('/image', grabImage);
//router.use('/picturelink', insertPictureLinkLogic);

// Export the router
module.exports = router;
