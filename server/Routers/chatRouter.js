var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var chatModel = require('../Schema/chatModel');

// Get All CHATS

router.get('/getAllChats', function (req, res, next) {

    res.send("Get all the chats");
    // chatModel.find((err, chats) => {
    //     if(!err) {
    //         res.send(chats);
    //     } else {
    //         console.log('Failed to retrieve List '+ err);
    //     }
    // })

})

module.exports = router;