import 'package:vocal_chat_bot/models/chat_message.dart';
import 'package:vocal_chat_bot/pages/chatbot.dart';

import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  ChatMessage chatMessage;
  ChatBubble({Key? key, required this.chatMessage}) : super(key: key);
  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: widget.chatMessage.type == MessageType.Receiver
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        //this will determine if the message should be displayed left or right
        children: [
          // Image(
          //   alignment: Alignment.topRight,
          //   image: widget.chatMessage.type == MessageType.Receiver
          //       ? AssetImage('assets/images/chat.png')
          //       : AssetImage("null"),
          //   width: 30,
          //   height: 30,
          // ),

          Icon(
            widget.chatMessage.type == MessageType.Receiver
                ? Icons.message_rounded
                : null,
            color: Colors.black,
          ),
          Flexible(
            //Wrapping the container with flexible widget
            child: Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: (widget.chatMessage.type == MessageType.Receiver
                      ? Colors.grey[400]
                      : Colors.red[900]),
                  borderRadius: (widget.chatMessage.type == MessageType.Receiver
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(1.0),
                          topRight: Radius.elliptical(25, 25),
                          bottomLeft: Radius.elliptical(25, 25),
                          bottomRight: Radius.elliptical(25, 25))
                      : const BorderRadius.only(
                          topRight: Radius.circular(1.0),
                          topLeft: Radius.elliptical(25, 25),
                          bottomLeft: Radius.elliptical(25, 25),
                          bottomRight: Radius.elliptical(25, 25))),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: (widget.chatMessage.type == MessageType.Receiver
                  //         ? Color(0XFFB0BEC5)
                  //         : Color(0xFFD50000)),
                  //     offset: Offset(5, 5),
                  //     blurRadius: 10,
                  //   ),
                  // ],
                ),
                // borderRadius: BorderRadius.all(Radius.circular(19.0))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                        //We only want to wrap the text message with flexible widget
                        child: Container(
                            child: Text(widget.chatMessage.message,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: widget.chatMessage.type ==
                                            MessageType.Receiver
                                        ? Colors.black
                                        : Colors.white)))),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        widget.chatMessage.time,
                        style: TextStyle(
                            fontSize: 10.0,
                            color:
                                widget.chatMessage.type == MessageType.Receiver
                                    ? Colors.grey[700]
                                    : Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 15,
                        )),
                  ],
                )),
          )
        ]);
  }
}
