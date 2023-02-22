class Message {
  final String message;
  final String senderUserName;
  final DateTime dateSent;

  Message({
    required this.message,
    required this.senderUserName,
    required this.dateSent,
  });

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      senderUserName: message['senderUserName'],
      dateSent: DateTime.now(),
      // DateTime.fromMillisecondsSinceEpoch(message['dateSent'] * 1000),
    );
  }
}
