const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

const messages = [];

io.on('connection', (socket) => {
  const username = socket.handshake.query.username
  socket.on('message', (data) => {
    
    const message = {
        message : data.message,
        sender : data.sender,
        sentAt : Date.now(),
    }
    messages.push(message)
    io.emit('message', message)
    console.log("MEssage Sent succesfully...");
  })

});

server.listen(3000, () => {
  console.log('listening on *:3000'); 
});