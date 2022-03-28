import 'package:vocal_chat_bot/pages/chatbot.dart';

class ChatMessage {
  String message;
  MessageType type;
  String time;
  bool text =true ;
  ChatMessage({required this.message, required this.type, required this.time,required this.text});
  String get getMsg {
    return message;
  }

  MessageType get getType {
    return type;
  }

  String get getTime {
    return time;
  }
  
}
