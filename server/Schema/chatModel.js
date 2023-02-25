const mongoose = require("../database");
 
// create an schema
var chatSchema = new mongoose.Schema({
            message:String,
            sender:String,
            sentAt:Number
        });
 
var chatModel=mongoose.model('chats',chatSchema);
 
module.exports = mongoose.model("chats", chatModel);