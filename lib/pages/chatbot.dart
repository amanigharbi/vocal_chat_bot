// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
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
import 'package:cupertino_icons/cupertino_icons.dart';

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
  String? NomRec;
  String? PrenomRec;
  String? cinRec;
  String? EmailRec;
  String? AdrRec;
  String? DescRec;
String? type;

 

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
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
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
                    return VoiceBubble(
                      vocalMessage: vocalMessage[index],
                    );
                  }),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.only(right: 2, bottom: 5),
                height: 50,
                width: 100,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(_speechToText.isNotListening
                          ? Icons.mic_off
                          : Icons.mic),
                      color: Colors.red.shade900,
                      onPressed: _speechToText.isNotListening
                          ? _startListening
                          : _stopListening,
                    ),
                    SpeedDial(
                      icon: CupertinoIcons.globe,
                      iconTheme: IconThemeData(color: Colors.red.shade900),
                      // label: Text('langue'),
                      openCloseDial: isDialOpen,
                      backgroundColor: Colors.white,
                      overlayColor: Colors.grey,
                      overlayOpacity: 0.5,
                      spacing: 15,
                      spaceBetweenChildren: 15,
                      closeManually: false,
                      children: [
                        SpeedDialChild(
                            child: Flag.fromCode(
                              FlagsCode.FR,
                              height: 30,
                              width: 30,
                            ),
                            label: 'Francais',
                            backgroundColor:
                                const Color.fromARGB(255, 207, 47, 47),
                            onTap: () {
                              setState(() {
                                _currentLocaleId = "fr_CA";
                                speak("Salut comment puis-je vous aider?");
                              });
                            }),
                        SpeedDialChild(
                            child: Flag.fromCode(
                              FlagsCode.TN,
                              height: 30,
                              width: 30,
                            ),
                            label: 'Arabe',
                            onTap: () {
                              setState(() {
                                _currentLocaleId = "ar_SA";
                                speak("مرحبا كيف يمكنني مساعدتك؟");
                              });
                            }),
                        SpeedDialChild(
                            child: Flag.fromCode(
                              FlagsCode.US,
                              height: 30,
                              width: 30,
                            ),
                            label: 'Anglais',
                            onTap: () {
                              setState(() {
                                _currentLocaleId = "en_US";
                                speak("Hello how can i help you?");
                              });
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                height: 50,
                width: 270,
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
                        onPressed: () {
                          _getResponse(_queryController.text);
                        },
                        color: Colors.red.shade900,
                        icon: const Icon(Icons.send)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<FlutterTts> speak(message) async {
    switch (_currentLocaleId) {
      case 'ar_SA':
        await flutterTts.setLanguage("ar");
        break;
      case 'fr_CA':
        await flutterTts.setLanguage("fr-FR");
        for (int i = 0; i < message.length; i++) {
          message = message.replaceAll('`', ' ');
        }
        break;
      case 'en_US':
        await flutterTts.setLanguage("en-US");
        break;
      default:
        await flutterTts.setLanguage("fr-FR");
    }

    await flutterTts.speak(message);

    return flutterTts;
  }

  int v = 0;
  Future<void> _getResponse(txt) async {
    _insertSingleItem(
        txt, MessageType.Sender, DateFormat("HH:mm").format(DateTime.now()));
    if (txt.toString().contains("réclamation") ||
        txt.toString().contains("شكاية") ||
        txt.toString().contains("reclamation")) {
      switch (_currentLocaleId) {
        case 'ar_SA':
          speak("مرحبا في فضاء الشكايات من فضلك ارسل لي اسم العائلة ");
          _insertSingleItem(
              "مرحبا في فضاء الشكايات من فضلك ارسل لي اسم العائلة ",
              MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));

          break;
        case 'fr_CA':
          speak(
              "Bonjour dans l espace de réclamation merci d envoyer votre nom");
          _insertSingleItem(
              "Bonjour dans l espace de réclamation merci d envoyer votre nom",
              MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
          v = 1;
          break;
        case 'en_US':
          speak("Hello! please send me your first name ");
          _insertSingleItem("Hello! please send me your first name",
              MessageType.Receiver, DateFormat("HH:mm").format(DateTime.now()));

          break;
      }

      print("teeeeeeeeeeeeext " + txt);
      txt = "";
      print("teeeeeeeeeeeeext2 " + txt);
      print("vvvv " + v.toString());
    }
    switch (v) {
      case 0:
        print("ok");
        try {
          var dataForm = {
            "message": txt,
          };
          var response = await Dio().post(
            "http://192.168.1.7:5050/predict",
            options: Options(
              headers: {
                Headers.contentTypeHeader: 'application/json',
                Headers.acceptHeader: 'application/json'
              },
            ),
            data: dataForm,
          );
          print("aaaaaa " + response.toString());

          setState(() async {
            await flutterTts.getLanguages;

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
        break;
      case 1:
        if (txt.toString().isNotEmpty) {
          NomRec = txt;
          print("la je suis " + txt);
          NomRec = txt;
          if (NomRec is String && NomRec.toString().trim().length>=4) {
            speak("Monsieur Madame $NomRec s il vous envoyer moi votre prénom");
            _insertSingleItem(
                "Monsieur Madame $NomRec s il vous envoyer moi votre prénom",
                MessageType.Receiver,
                DateFormat("HH:mm").format(DateTime.now()));
            v = 2;
          }
        }
        break;
      case 2:
        print("la je suis prenom " + txt);
        PrenomRec = txt;
        if (PrenomRec is String && PrenomRec.toString().trim().length>3) {
          speak("Monsieur Madame $NomRec $PrenomRec  envoyer moi votre cin");
          _insertSingleItem(
              "Monsieur Madame $NomRec $PrenomRec  envoyer moi votre cin",
              MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
          v = 3;
        }
        break;
      case 3:
        print("la je suis cin " + txt);
        cinRec = txt;
        if ((cinRec.toString().length > 8)) {
          speak("Génial maintenant c quoi votre adresse");
          _insertSingleItem("Génial maintenant c quoi votre adresse",
              MessageType.Receiver, DateFormat("HH:mm").format(DateTime.now()));
          v = 4;
        }
        break;
      case 4:
        print("la je suis adresse " + txt);
        AdrRec = txt;
        if (AdrRec is String && NomRec.toString().trim().length>4) {
          speak("Génial maintenant c quoi votre email");
          _insertSingleItem("Génial maintenant c quoi votre email",
              MessageType.Receiver, DateFormat("HH:mm").format(DateTime.now()));
          v = 5;
        }
        break;
      case 5:
        print("la je suis email " + txt);
        EmailRec = txt;
        if (RegExp(r'\S+@\S+\.\S+').hasMatch(EmailRec.toString())) {
           speak("Choisir un type parmi cette liste dire 1 si la réclamation de type administration 2 si de type construction anarchique 3 si de type éclairage publique 4 si de type énergie 5 si de type espace verts 6 mobilité 7 santé et hiégiéne et 8 si c est une autre type");
          _insertSingleItem("Choisir un type parmi cette liste dire 1 si la réclamation de type administration 2 si de type construction anarchique 3 si de type éclairage publique 4 si de type énergie 5 si de type espace verts 6 mobilité 7 santé et hiégiéne et 8 si c est un autre type", MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
        
          v = 6;
        } else {
          speak("email non valide");
          _insertSingleItem("email non valide", MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
        }
        break;
          case 6:
        print("la je suis type " + txt);
        
        if (txt.toString().contains('1')) {
          type = "administration";
        }
        else  if (txt.toString().contains('2')) {
          type = "construction anarchiques";
        }
         else  if (txt.toString().contains('3')) {
          type = "Eclairage publique";
        }
         else  if (txt.toString().contains('4')) {
          type = "Energie";
        }
         else  if (txt.toString().contains('5')) {
          type = "Espaces Verts";
        }
         else  if (txt.toString().contains('6')) {
          type = "Mobilité";
        }
         else  if (txt.toString().contains('7')) {
          type = "Santé et Higiéne";
        }
         else  if (txt.toString().contains('8')) {
          type = "Autres Réclamations ";
        }
          speak("Merci de m envoyer une petite description de votre réclamation");
          _insertSingleItem("Merci de m envoyer une petite description de votre réclamation", MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
          v = 7;
         
        break;
          case 7:
        print("la je suis description " + txt);
        DescRec = txt;
        if (DescRec is String && DescRec.toString().trim().length>10){
        speak("Demande enregistré");
          _insertSingleItem("Demande enregistré", MessageType.Receiver,
              DateFormat("HH:mm").format(DateTime.now()));
          print("nom " +
              NomRec.toString() +
              " prenom " +
              PrenomRec.toString() +
              " cin " +
              cinRec.toString() +
              " email " +
              EmailRec.toString() +
              " adr " +
              AdrRec.toString()+
              " type " +
              type.toString()
              + " description "+ DescRec.toString()); 
          
          v = 8;
        }
        break;
      case 8:
        print("demande enregisté");
        print("nom " +
            NomRec.toString() +
            " prenom " +
            PrenomRec.toString() +
            " cin " +
            cinRec.toString() +
            // " email " +
            // EmailRec.toString() +
            " adr " +
            AdrRec.toString());
        break;
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
