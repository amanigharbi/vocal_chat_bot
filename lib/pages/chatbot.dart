// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocal_chat_bot/components/chat_bubble.dart';
import 'package:vocal_chat_bot/components/chat_detail_page.appbar.dart';
import 'package:vocal_chat_bot/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:speech_recognition/speech_recognition.dart';
import 'package:intl/intl.dart';


enum MessageType {
  // ignore: constant_identifier_names
  Sender,
  // ignore: constant_identifier_names
  Receiver,
}

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({Key? key}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  // ignore: unnecessary_new
  final ScrollController _listScrollController = new ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String _currentLocale ="en-US";

  String url = '';
  String question = '';
  List<ChatMessage> chatMessage = [];
  String mess ='';
final FlutterTts flutterTts = FlutterTts();
  // static const String BOT_URL =
  //     "http://192.168.1.116:5000/chatbot"; // replace with server address
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }
   void initSpeechRecognizer() async {
    
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );
      
    _speechRecognition.setRecognitionResultHandler(
       (String speech) => setState(() =>_queryController.text=speech),
     
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening= false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  _speechRecognition.setCurrentLocaleHandler(
(String locale) => setState(() => _currentLocale = locale));
       
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatDetailPageAppBar(),
      body: Stack(
        children: <Widget>[
          Container(
            // ignore: prefer_const_constructors
            decoration: BoxDecoration(
              // ignore: prefer_const_constructors
              image: DecorationImage(
                image: const AssetImage('assets/images/chat.gif'),
                fit: BoxFit.contain,
              ),
            ),
            height: 580,
            // color: Colors.grey.shade300,
            child: AnimatedList(
                controller: _listScrollController,
                shrinkWrap: true,
                // key to call remove and insert from anywhere
                key: _listKey,
                initialItemCount: chatMessage.length,
                itemBuilder: (BuildContext context, int index,
                    Animation<double> animation) {
                  // return _buildItem(_data[index], animation, index);
                  return ChatBubble(
                    chatMessage: chatMessage[index],
                  );
                }),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.only(
              //     topRight: Radius.circular(10.0),
              //     bottomRight: Radius.circular(10.0),
              //   ),
              // color: Colors.white
              // ),
              padding: const EdgeInsets.only(left: 16, bottom: 5),
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  // SizedBox(
                  //   width: 16,
                  // ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.message),
                          hintText: "Ecrire votre mesage...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none),
                      controller: _queryController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (msg) {
                        _getResponse(msg);
                      },
                    ),
                  ),
                  
                   IconButton(
                            icon: new Icon(Icons.mic), 
                             color: Colors.red.shade900,
                            onPressed: () { 
                                if (_isAvailable && !_isListening) {
                    _speechRecognition
                        .listen(locale:_currentLocale)
                        
                        .then(
                          (result) => setState(() => _isListening = result));
                  }
                    _getResponse(_queryController.text);
                    print("hhh "+mess);
                   },
                  
                     
                             ),
               
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 70,
                      height: 70,
                    
                      // padding: EdgeInsets.only(right: 30, bottom: 0.1),
                      // child: FloatingActionButton(
                      //   onPressed: () {
                      //     this._getResponse();
                      //   },
                      child: IconButton(
                         onPressed: () {
                            //this._getResponse();
                          },
                          color: Colors.red.shade900,
                          icon: new Icon(Icons.send)),
                      // backgroundColor: Colors.red.shade900,
                      // elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getResponse(txt) async {
    if (_queryController.text.isNotEmpty) {
      var dt = DateTime.now();
      _insertSingleItem(_queryController.text, MessageType.Sender,
          DateFormat("HH:mm").format(DateTime.now()));
      // var client = _getClient();
      try {
        // ignore: unused_local_variable
      var dataForm = {
                             "message": txt,
                           };
var response = await Dio().post(
                            "http://192.168.1.3:5050/predict",
                            options: Options(
                              headers: {
                                Headers.contentTypeHeader: 'application/json',
                                Headers.acceptHeader: 'application/json'
                               },
                             ),
                             data: dataForm,
                           
                          );

        setState(() async {
          // data = await fetchdata(url);
      //  await flutterTts.setLanguage("ar");
         await flutterTts.speak(response.data);
          _insertSingleItem(response.data, MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
                 print(await flutterTts.getLanguages);
        });
      } catch (e) {
        // ignore: avoid_print
        print("Failed -> $e");
      } finally {
        // client.close();
        _queryController.clear();
      }
    }
  }

  void _insertSingleItem(String message, MessageType type, String time) {
    chatMessage.add(ChatMessage(message: message, type: type, time: time));
    _listKey.currentState!.insertItem(chatMessage.length - 1,
        duration: const Duration(milliseconds: 200));
    Timer(const Duration(milliseconds: 220), () {
      _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
}
