import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocal_chat_bot/pages/chatbot.dart';
 class VocalMessage{
  String message;
  MessageType type;
  String time;
  VocalMessage({required this.message, required this.type, required this.time});
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