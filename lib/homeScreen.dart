import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:socket_appliaction/Provider/homeScreen.provider.dart';
import 'package:socket_appliaction/models/messageModel.dart';
import 'package:socket_appliaction/nameScreen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Making a variable as a resource to connecr with backend;
  late IO.Socket _socket;

  var _fileUrl;

  // Future chooseFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   _fileUrl = result?.files.single.path;
  // }

  // text editing cntroller for sending the message
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();

    final homescreenprovider =
        Provider.of<HomeScreenProvider>(context, listen: false);

    homescreenprovider.messages;

    _socket = IO.io(
        "http://10.0.2.2:3000", // FOR MOBILE APPS THIS iP SHOULD USE
        // "http://127.0.0.1:3000", // FOR WEB THIS IP ADDRESS SHOULD USE AND

//      If you're running the server locally and using the Android emulator,
//      then your server endpoint should be 10.0.2.2:8000
//      instead of localhost:8000
        IO.OptionBuilder().setTransports(['websocket']).setQuery(
            {'username': widget.username.toString()}).build());
    _connectSocket(); // Initializing in start of the app
  }

//   Future<void> _deriveKey() async {
// //1. Alice's public key
//     Map<String, dynamic> publicjwk = json.decode(
//         '{"kty": "EC", "crv": "P-256", "x": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "y": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}');
//     EcdhPublicKey ecdhPublicKey =
//         await EcdhPublicKey.importJsonWebKey(publicjwk, EllipticCurve.p256);
// //2. Bob's private key
//     Map<String, dynamic> privatejwk = json.decode(
//         '{"kty": "EC", "crv": "P-256", "x": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "y": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "d": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}');
//     EcdhPrivateKey ecdhPrivateKey =
//         await EcdhPrivateKey.importJsonWebKey(privatejwk, EllipticCurve.p256);
// //3. Generating cryptokey called deriveBits
//     Uint8List derivedBits = await ecdhPrivateKey.deriveBits(256, ecdhPublicKey);
//     print("CRYPTOKEY   ---   " + derivedBits.toString());
//   }
  // Function to connect, disconnect and showinf errors when occured;

  _connectSocket() {
    print("START");
    _socket.onConnect((data) => print("Connection established"));
    _socket.onConnectError((data) => print("Connect ERROR : $data"));
    _socket.onDisconnect((data) => print("Socket.IO server Disconnected"));
    _socket.on('message', (data) {
      print("MESSAGE DATA : ${data}");
      Provider.of<HomeScreenProvider>(context, listen: false)
          .addNewMessage(Message.fromJson(data));
    });
    print("END");
  }

  final _key = '';
  String encryptedText = '';
  // late PlatformStringCryptor cryptor;
  // Future<String> encrypt(String messageText) async {
  //   print("BEFORE ENCRYPTED ---   " + messageText.toString());
  //   cryptor = PlatformStringCryptor();
  //   // final salt = await cryptor.generateSalt();
  //   // print("SALT   ----   " + salt.toString());
  //   final key = await cryptor.generateKeyFromPassword(widget.username, "salt");
  //   final encrypted = await cryptor.encrypt(messageText, key);
  //   setState(() {
  //     final _key = key;
  //     encryptedText = encrypted;
  //   });
  //   print("ENCRYPTED ---   " + encryptedText.toString());
  //   return encrypted;
  // }

  sendMessage() async {
    // final encryptedMessage = await encrypt(_messageController.text.trim());
    _socket.emit('message', {
      'message': _messageController.text.toString(),
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
                              alignment: message.sender == widget.username
                                  ? WrapAlignment.end
                                  : WrapAlignment.start,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width / 1.3,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Attachment(),
                InkWell(
                  onTap: widget.ontapFunction,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 50,
                      color: Color.fromARGB(255, 10, 50, 230),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
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
            color: Colors.transparent,
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

class Attachment extends StatelessWidget {
  const Attachment({super.key});

  @override
  Widget build(BuildContext context) {
    // Future chooseFile() async {
    //   FilePickerResult? result = await FilePicker.platform.pickFiles();
    //   _fileUrl = result?.files.single.path;
    // }

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        alignment: Alignment.center,
        child: Icon(Icons.attachment),
      ),
    );
  }
}
