import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_appliaction/Provider/homeScreen.provider.dart';
import 'package:socket_appliaction/models/messageModel.dart';
import 'package:socket_appliaction/nameScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Making a variable as a resource to connecr with backend;
  late IO.Socket _socket;

  // text editing cntroller for sending the message
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final homescreenprovider =
        Provider.of<HomeScreenProvider>(context, listen: false);

    homescreenprovider.messages;

    _socket = IO.io(
        "http://10.0.2.2:3000",
        // If you're running the server locally and using the Android emulator,
        //then your server endpoint should be 10.0.2.2:8000
        //instead of localhost:8000

        IO.OptionBuilder().setTransports(['websocket']).setQuery(
            {'username': widget.username.toString()}).build());
    _connectSocket(); // Initializing in start of the app
  }

  // Function to connect, disconnect and showinf errors when occured;
  _connectSocket() {
    print("START");
    _socket.onConnect((data) => print("Connection established"));
    _socket.onConnectError((data) => print("Connect ERROR : $data"));
    _socket.onDisconnect((data) => print("Socket.IO server Disconnected"));
    _socket.on('message', (data) {
      print("DATE SENT : ${data}");
      Provider.of<HomeScreenProvider>(context, listen: false)
          .addNewMessage(Message.fromJson(data));
    });
    print("END");
  }

  sendMessage() {
    _socket.emit('message', {
      'message': _messageController.text.trim(),
      'sender': widget.username,
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final homescreenprovider =
        Provider.of<HomeScreenProvider>(context, listen: false);
    print("MESSAGES --- " + homescreenprovider.messages.toString());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 10, 50, 230),
        automaticallyImplyLeading: true,
        leading: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return NameScreen();
                },
              ), (route) => false);
            },
            child: Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
              color: Colors.grey,
              height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Consumer<HomeScreenProvider>(
                    builder: (context, homeScreenProviderModel, child) {
                      return Container(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: homeScreenProviderModel.messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                homeScreenProviderModel.messages[index];
                            return Wrap(
                              alignment:
                                  message.senderUserName == widget.username
                                      ? WrapAlignment.start
                                      : WrapAlignment.end,
                              children: [
                                MessageSection(
                                  index: index,
                                  messageText:
                                      homeScreenProviderModel.messages.isEmpty
                                          ? "NO Messages yet"
                                          : message.message.toString(),
                                  messageTime: message.dateSent
                                      .toString()
                                      .substring(11, 16),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            final message =
                                homeScreenProviderModel.messages[index];
                            return SizedBox(height: 10);
                          },
                        ),
                      );
                    },
                  ),
                  MessageInputSection(
                    controller: _messageController,
                    ontapFunction: () {
                      if (_messageController.text.trim().isNotEmpty) {
                        setState(() {
                          sendMessage();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Enter message")),
                        );
                      }
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class MessageInputSection extends StatefulWidget {
  final controller;
  final ontapFunction;
  const MessageInputSection(
      {super.key, required this.controller, required this.ontapFunction});

  @override
  State<MessageInputSection> createState() => _MessageInputSectionState();
}

class _MessageInputSectionState extends State<MessageInputSection> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter message",
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: widget.ontapFunction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                color: Color.fromARGB(255, 10, 50, 230),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageSection extends StatelessWidget {
  final index;
  final messageText;
  final messageTime;
  const MessageSection(
      {super.key,
      required this.index,
      required this.messageText,
      required this.messageTime});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        child: Container(
            // margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            color: Colors.transparent,
            // alignment: ((index) % 2) == 0
            //     ? Alignment.centerRight
            //     : Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  messageText.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                SizedBox(height: 05),
                Text(
                  messageTime.toString(),
                  style: TextStyle(color: Colors.black, fontSize: 08),
                ),
              ],
            )));
  }
}
