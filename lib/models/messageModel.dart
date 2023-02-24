class Message {
  final String message;
  final String sender;
  final DateTime dateSent;

  Message({
    required this.message,
    required this.sender,
    required this.dateSent,
  });

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      sender: message['sender'],
      dateSent: DateTime.now(),
      // DateTime.fromMillisecondsSinceEpoch(message['dateSent'] * 1000),
    );
  }
}
