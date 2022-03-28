// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vocal_chat_bot/components/chat_bubble.dart';
import 'package:vocal_chat_bot/components/chat_detail_page.appbar.dart';
import 'package:vocal_chat_bot/components/voice_buble.dart';
import 'package:vocal_chat_bot/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flag/flag.dart';
import 'package:vocal_chat_bot/models/vocal_message.dart';


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
  List<ChatMessage> chatMessage = [];
    List<VocalMessage> vocalMessage = [];
  String _resultText = '';
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _currentLocaleId = "fr_CA";
  List<LocaleName> _localeNames = [];
  final TextEditingController _queryController = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    _localeNames = await _speechToText.locales();


    setState(() {});
  }


  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _currentLocaleId,
    );
       print(' and here '+_currentLocaleId);
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      if (_speechToText.isNotListening) {
        _getResponse(result.recognizedWords);
           _resultText = result.recognizedWords;
      }
   
    });
  }

  @override
  Widget build(BuildContext context) {
     return WillPopScope(
      onWillPop: () async{
          if(isDialOpen.value){
            isDialOpen.value = false;
            return false;
          }else{
            return true;
          }
      },
    child: Scaffold(
      appBar: const ChatDetailPageAppBar(),
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Visibility(
              child: Text(_resultText),
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: false,
            ),
          ),
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
                initialItemCount: vocalMessage.length,
                itemBuilder: (BuildContext context, int index,
                    Animation<double> animation) {
                  // return _buildItem(_data[index], animation, index);
                  return VoiceBubble(
                    vocalMessage: vocalMessage[index],
                  );
                }),
          ),
        
           Align(
            alignment: const FractionalOffset(1, 0.91),

      child:SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          backgroundColor: Colors.red.shade900,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: true,
          children: [
            SpeedDialChild(
              child: Flag.fromCode(
                FlagsCode.FR,
                height: 30,
                width: 30,
            
              ),
              label: 'Francais',
              backgroundColor: const Color.fromARGB(255, 207, 47, 47),
              onTap: (){
                setState(() {
                    _currentLocaleId = "fr_CA";
                  });
                   print('here '+_currentLocaleId);
              }
            ),
            SpeedDialChild(
              child: Flag.fromCode(
                FlagsCode.TN,
                height: 30,
                width: 30,
              ),
              label: 'Arabe',
                onTap: (){
                  setState(() {
                    _currentLocaleId = "ar_SA";
                  });
                     print('here '+_currentLocaleId);
                }
            ),
            SpeedDialChild(
              child: Flag.fromCode(
                FlagsCode.US,
                height: 30,
                width: 30,
              ),
              label: 'Anglais',
                onTap: (){
                  setState(() {
                    _currentLocaleId = "en_US";
                  });
                  print('here '+_currentLocaleId);
                }
            ),
          ],
        ),
           ),
            
          
          
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 16, bottom: 5),
              height: 50,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
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
                    icon: Icon(_speechToText.isNotListening
                        ? Icons.mic_off
                        : Icons.mic),
                    color: Colors.red.shade900,
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 70,
                      height: 70,
                      child: IconButton(
                          onPressed: () {
                            _getResponse(_queryController.text);
                          },
                          color: Colors.red.shade900,
                          icon: const Icon(Icons.send)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
     );
  }
Future<void> speak(message) async{
  print("je suis la "+_currentLocaleId);
  switch (_currentLocaleId) {
    case 'ar_SA':
      await flutterTts.setLanguage("ar");
      break;
       case 'fr_CA':
      await flutterTts.setLanguage("fr_CA");
      break;
       case 'en_US':
      await flutterTts.setLanguage("en_US");
      break;
    default:
     await flutterTts.setLanguage("fr_CA");
  }
   await flutterTts.speak(message);
}
  Future<void> _getResponse(txt) async {
      _insertSingleItem(txt, MessageType.Sender, DateFormat("HH:mm").format(DateTime.now()));
      try {
        var dataForm = {
          "message": txt,
        };
        var response = await Dio().post(
          "http://192.168.1.2:5050/predict",
          options: Options(
            headers: {
              Headers.contentTypeHeader: 'application/json',
              Headers.acceptHeader: 'application/json'
            },
          ),
          data: dataForm,
        );

        setState(() async {
          await speak(response.data);
          _insertSingleItem(response.data, MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
        });
      } catch (e) {
        // ignore: avoid_print
        print("Failed -> $e");
      } finally {
      
        _queryController.clear();
      }
  
  }

  void _insertSingleItem(String message, MessageType type, String time) {
    vocalMessage.add(VocalMessage(message: message, type: type, time: time));
    _listKey.currentState!.insertItem(vocalMessage.length - 1,
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