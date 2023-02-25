const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);
const {MongoClient} = require('mongodb');
const uri = "mongodb+srv://tejasg4646:tejasg4646@cluster0.ohfvvvh.mongodb.net/?retryWrites=true&w=majority";
const client = new MongoClient(uri);



const messages = [];

async function main() {
  const uri = "mongodb+srv://tejasg4646:tejasg4646@cluster0.ohfvvvh.mongodb.net/?retryWrites=true&w=majority";
const client = new MongoClient(uri);
  try {
    await client.connect();
    console.log("Database Connected");
    // await listDatabases(client);
  
  } catch (e) {
    console.error(e);
  }  finally {
    await client.close();
}
}

main().catch(console.error);





async function listDatabases(client){
  databasesList = await client.db().admin().listDatabases();

  console.log("Databases:");
  databasesList.databases.forEach(db => console.log(` - ${db.name}`));
};


io.on('connection', (socket) =>  {
  const username = socket.handshake.query.username
  socket.on('message', (data) =>  {
    const message = {
        message : data.message,
        sender : data.sender,
        sentAt : Date.now(),
    }
    
    const result =  client.db("Data").collection("chats").insertOne(message);

    messages.push(message)
    io.emit('message', message)
    console.log("MEssage Sent succesfully...");
  })

});


async function getAllMessages() {

}

// const routes = require('./Routers/chatRouter');
// app.use('/', routes);

server.listen(3000, () => {
  console.log('listening on *:3000'); 
});