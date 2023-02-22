import 'package:flutter/material.dart';

import '../models/messageModel.dart';

class HomeScreenProvider extends ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => _messages;

  addNewMessage(Message message) {
    _messages.add(message);
    print("ADDED INTO MESSAGES");
    notifyListeners();
  }
}
