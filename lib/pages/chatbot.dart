// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
import 'package:vocal_chat_bot/pages/mysql.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'mobile.dart' if (dart.library.html) 'web.dart';

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
  String cinRec ="";
  String? EmailRec;
  String? AdrRec;
  String? DescRec;
  String? type;
  String NumRec='';
 bool? error;

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
      
        // await flutterTts.setLanguage("fr-FR");
    }

    await flutterTts.speak(message);

    return flutterTts;
  }
void _voiceBot(String msg){
       speak(msg);
              _insertSingleItem(
                  msg,
                  MessageType.Receiver,
                  DateFormat("HH:mm").format(DateTime.now()));
}
  int v = 0;
  Future<void> _getResponse(txt) async {
    _insertSingleItem(
        txt, MessageType.Sender, DateFormat("HH:mm").format(DateTime.now()));
    if (txt.toString().contains("réclamation") ||
        txt.toString().contains("شكوى") ||
        txt.toString().contains("reclamation")) {
      switch (_currentLocaleId) {
        case 'ar_SA':
        _voiceBot("مرحبا في فضاء الشكايات من فضلك ارسل لي اسم العائلة ");
          v = 1;

          break;
        case 'fr_CA':
   _voiceBot("Bienvenue dans l`espace de réclamation merci d`envoyer votre nom");
          v = 1;

          break;
        case 'en_US':
        _voiceBot("Hello! please send me your last name");
          v = 1;
          break;
      }
      txt = "";
    }
       if ((txt.toString().contains("suivi"))|| (txt.toString().contains("اتباع"))
        || (txt.toString().contains("check"))) {
           
           
                switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me the claim number you want to track");
                        
                        v = 8;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi le numéro de réclamation que vous voullez suivre");
                       
                        v = 8;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v = 8;
                        break;
                }
             txt = "";
              
        }
    switch (v) {
      case 0:
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

          setState(() async {
            await flutterTts.getLanguages;

           _voiceBot(response.data);
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
          print("nom "+NomRec.toString());
          if (NomRec is String && NomRec.toString().trim().length >= 4) {
            switch (_currentLocaleId) {
              case 'ar_SA':

                _voiceBot("السيد/السيدة $NomRec ارسل لي اسمك");
              

                break;
              case 'fr_CA':
                _voiceBot(
                    "Monsieur/Madame $NomRec s`il vous plait envoyer moi votre prénom");
            
                break;
              case 'en_US':
                _voiceBot("Mr/Mrs $NomRec please send me your first name");
                
                break;
            }
            v = 2;
          } else {
            switch (_currentLocaleId) {
              case 'ar_SA':
                _voiceBot("اسم غير صحيح");
            
                break;
              case 'fr_CA':
                _voiceBot("Nom non valide");
                
                break;
              case 'en_US':
                _voiceBot("Invalid name");
          
                break;
            }
          }
        }
        break;
      case 2:
        PrenomRec = txt;
         print("prenom "+PrenomRec.toString());
        if (PrenomRec is String && PrenomRec.toString().trim().length > 3) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("السيد/السيدة $PrenomRec $NomRec ارسل لي رقم بطاقة هويتك");
             

              break;
            case 'fr_CA':
              _voiceBot(
                  "Monsieur/Madame $NomRec $PrenomRec  envoyer moi votre numéro de carte d`identité");
             

              break;
            case 'en_US':
              _voiceBot(
                  "Mr/Mrs $NomRec $PrenomRec send me your identity card number");
             
              break;
          }

          v = 3;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("قل الاسم الحقيقي من فضلك");
             
              break;
            case 'fr_CA':
              _voiceBot("Dire un vrai prénom s`il vous plait");
              
              break;
            case 'en_US':
              _voiceBot("Say a real name please");
             

              break;
          }
        }
        break;
      case 3:
          // cinRec = txt.replaceAll(' ', '');
           cinRec =txt;
            if(cinRec.contains('صفر')){
    cinRec=cinRec.replaceAll('صفر', '0');
   }
     if(cinRec.contains('واحد')){
    cinRec=cinRec.replaceAll('واحد', '1');
   }
     if(cinRec.contains('اثنين')){
    cinRec=cinRec.replaceAll('اثنين', '2');
   }
     if(cinRec.contains('ثلاثه')){
    cinRec=cinRec.replaceAll('ثلاثه', '3');
   }
     if(cinRec.contains('اربعه')){
    cinRec=cinRec.replaceAll('اربعه', '4');
   }
     if(cinRec.contains('خمسه')){
    cinRec=cinRec.replaceAll('خمسه', '5');
   }
     if(cinRec.contains('سته')){
    cinRec=cinRec.replaceAll('سته', '6');
   }
     if(cinRec.contains('سبعه')){
    cinRec=cinRec.replaceAll('سبعه', '7');
   }
     if(cinRec.contains('ثمانيه')){
    cinRec=cinRec.replaceAll('ثمانيه', '8');
   }
      if(cinRec.contains('تسعه')){
    cinRec=cinRec.replaceAll('تسعه', '9');
   }
       
      cinRec=cinRec.replaceAll(' ', '');
             
                      
                        // String cinArray = txt.split(' ');
                        // for (var i = 0; i < cinArray.length; i++) {
                        //     cinRec += getNumLet(cinArray[i]);
                        // }
                    
                    // else {
                    //     cinRec = txt.replaceAll(' ', '');
                    // }
 print("cin "+cinRec.toString());
        if ((cinRec.toString().length == 8)) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
            case 'fr_CA':
              _voiceBot("Génial maintenant c`est quoi votre adresse");
           
              break;
            case 'en_US':
              _voiceBot("Great now what is your address");
            
              break;
          }

          v = 4;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("يجب أن يكون رقم بطاقة الهوية رقمًا يساوي 8");
           
              break;
            case 'fr_CA':
              _voiceBot(
                  "Le numéro de carte d`identité doit etre un nombre de 8 chiffres");
           
              break;
            case 'en_US':
              _voiceBot("The identity card number must be a number of 8");
            
              break;
          }
        }
        break;
      case 4:
        AdrRec = txt;
         print("adresse "+AdrRec.toString());
        if (AdrRec is String && NomRec.toString().trim().length > 4) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
              break;
            case 'fr_CA':
              _voiceBot("c`est quoi Votre email ");
              
              break;
            case 'en_US':
              _voiceBot("what is your email");
             
              break;
          }

          v = 5;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("هناك خطأ ما حاول مرة أخرى");
            
              break;
            case 'fr_CA':
              _voiceBot("il y a une erreur réessayer");
             
              break;
            case 'en_US':
              _voiceBot("there is an error try again");
             
              break;
          }
        }
        break;
      case 5:
       for (int i = 0; i < txt.length; i++) {
          txt = txt.replaceAll("at", "@");
        }
        EmailRec = txt.toString().replaceAll(" ", "");
        print("email "+EmailRec.toString());
        if (RegExp(r'\S+@\S+\.\S+').hasMatch(EmailRec.toString())) {
            _currentLocaleId='ar_SA';
          switch (_currentLocaleId) {
            case 'ar_SA':
          
              _voiceBot(
                  "اختر نوعًا من هذه القائمة قل 1 إذا كانت الشكوى من نوع الإدارة 2 إذا كانت من نوع البناء الفوضوي 3 إذا كانت من نوع الإضاءة العامة 4 إذا كانت من نوع الطاقة 5 إذا كانت من المساحة الخضراء اكتب 6 التنقل 7 الصحة والنظافة 8 إذا كان من نوع آخر");
              

              break;
            case 'fr_CA':
              _voiceBot(
                  "Choisir un type parmi cette liste dire 1 si la réclamation de type administration 2 si de type construction anarchique 3 si de type éclairage publique 4 si de type énergie 5 si de type espace verts 6 mobilité 7 santé et hiégiéne et 8 si c est une autre type");
              
              break;
            case 'en_US':
              _voiceBot(
                  "Choose a type from this list say 1 if the complaint is of the administration type 2 if of the anarchic construction type 3 if of the public lighting type 4 if of the energy type 5 if of the green space type 6 mobility 7 health and hygiene and 8 if it is another kind");
             
              break;
          }

          v = 6;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("البريد الإلكتروني غير صالح حاول مرة أخرى");
             
              break;
            case 'fr_CA':
              _voiceBot("email non valide réessayer");
             
              break;
            case 'en_US':
              _voiceBot("invalid email try again");
            
              break;
          }
        }
        break;
      case 6:
        if ((txt.toString().contains('1')) || (txt.toString().contains('واحد'))) {
          type = "administration";
        } else if ((txt.toString().contains('2')) || (txt.toString().contains('اثنين'))){
          type = "construction anarchiques";
        } else if ((txt.toString().contains('3'))|| (txt.toString().contains('ثلاثه'))) {
          type = "Eclairage publique";
        } else if ((txt.toString().contains('4'))|| (txt.toString().contains('اربعه'))) {
          type = "Energie";
        } else if ((txt.toString().contains('5'))|| (txt.toString().contains('خمسه'))) {
          type = "Espaces Verts";
        } else if ((txt.toString().contains('6'))|| (txt.toString().contains('سته'))) {
          type = "Mobilité";
        } else if ((txt.toString().contains('7'))|| (txt.toString().contains('سبعه'))) {
          type = "Santé et Higiéne";
        } else if ((txt.toString().contains('8'))|| (txt.toString().contains('ثمانيه')) ){
          type = "Autres Réclamations ";
        }
        else{
        switch (_currentLocaleId) {
          case 'ar_SA':
            _voiceBot("نوع غير معروف حاول مرة أخرى");
       
            break;
          case 'fr_CA':
            _voiceBot(
                "Type non connue réessayer");
           
            break;
          case 'en_US':
            _voiceBot("Unknown type try again");
           
            break;
        }  
        }

        switch (_currentLocaleId) {
          case 'ar_SA':
            _voiceBot("من فضلك أرسل لي وصفا موجزا لشكواك");
           
            break;
          case 'fr_CA':
            _voiceBot(
                "Merci de m envoyer une petite description de votre réclamation");
            
            break;
          case 'en_US':
            _voiceBot("Please send me a short description of your complaint");
            break;
        }

        v = 7;

        break;
      case 7:
        DescRec = txt;
         print("description "+DescRec.toString());
        if (DescRec is String && DescRec.toString().trim().length > 10) {
          
        ajoutRecVoiceBot();
        _createPDF();
          print("nom " +
              NomRec.toString() +
              " prenom " +
              PrenomRec.toString() +
              " cin " +
              cinRec.toString() +
              " email " +
              EmailRec.toString() +
              " adr " +
              AdrRec.toString() +
              " type " +
              type.toString() +
              " description " +
              DescRec.toString());

          // v = 8;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("قل وصفا صحيحا");
              
              break;
            case 'fr_CA':
              _voiceBot("Dire une correcte description");
            
              break;
            case 'en_US':
              _voiceBot("Say a correct description");
             
              break;
          }
        }
        break;
   case 8:
             String num_rec='';
            if (txt.toString() != ""){
               num_rec=txt;
    if(num_rec.contains('صفر')){
    num_rec=num_rec.replaceAll('صفر', '0');
   }
     if(num_rec.contains('واحد')){
    num_rec=num_rec.replaceAll('واحد', '1');
   }
     if(num_rec.contains('اثنين')){
    num_rec=num_rec.replaceAll('اثنين', '2');
   }
     if(num_rec.contains('ثلاثه')){
    num_rec=num_rec.replaceAll('ثلاثه', '3');
   }
     if(num_rec.contains('اربعه')){
    num_rec=num_rec.replaceAll('اربعه', '4');
   }
     if(num_rec.contains('خمسه')){
    num_rec=num_rec.replaceAll('خمسه', '5');
   }
     if(num_rec.contains('سته')){
    num_rec=num_rec.replaceAll('سته', '6');
   }
     if(num_rec.contains('سبعه')){
    num_rec=num_rec.replaceAll('سبعه', '7');
   }
     if(num_rec.contains('ثمانيه')){
    num_rec=num_rec.replaceAll('ثمانيه', '8');
   }
      if(num_rec.contains('تسعه')){
    num_rec=num_rec.replaceAll('تسعه', '9');
   }

       num_rec=num_rec.replaceAll(' ', '');
      // num_rec=txt.toString().replaceAll(' ', '');
                //    if (_currentLocaleId == "ar_SA") {
                //     String NumRecArray = txt.split(' ');
                //     for (var i = 0; i < NumRecArray.length; i++) {
                //       num_rec = num_rec + getNumLet(NumRecArray[i]);
                //     }
                   
                // } else {
                //     num_rec = txt.replaceAll(' ', '');
                // }
               
             
                print("je suis la");
                
                print("nummm "+num_rec);
                if (num_rec.length == 8) {
                    SuiviRec(num_rec);
                }
                else {
                    _voiceBot("Revérifier");
                }
            }
            
            break;
    }
  }
 getNumLet(s) {
    if(s.toString().contains('صفر')){
    s= s.toString().replaceAll('صفر', '0');
   }
     if(s.toString().contains('واحد')){
    s= s.toString().replaceAll('واحد', '1');
   }
     if(s.toString().contains('اثنين')){
    s= s.toString().replaceAll('اثنين', '2');
   }
     if(s.toString().contains('ثلاثه')){
    s= s.toString().replaceAll('ثلاثه', '3');
   }
     if(s.toString().contains('اربعه')){
    s= s.toString().replaceAll('اربعه', '4');
   }
     if(s.toString().contains('خمسه')){
    s= s.toString().replaceAll('خمسه', '5');
   }
     if(s.toString().contains('سته')){
    s= s.toString().replaceAll('سته', '6');
   }
     if(s.toString().contains('سبعه')){
    s= s.toString().replaceAll('سبعه', '7');
   }
     if(s.toString().contains('ثمانيه')){
    s= s.toString().replaceAll('ثمانيه', '8');
   }
      if(s.toString().contains('تسعه')){
    s= s.toString().replaceAll('تسعه', '9');
   }
  //  s=s..toString().replaceAll(' ', '');
//  

    // switch (s) {
    //     case 'واحد':
    //         return 1;
    //     case 'اثنين':
    //         return 2;
    //     case 'ثلاثه':
    //         return 3;
    //     case 'اربعه':
    //         return 4;
    //     case 'خمسه':
    //         return 5;
    //     case 'سته':
    //         return 6;
    //     case 'سبعه':
    //         return 7;
    //     case 'ثمانيه':
    //         return 8;
    //     case 'تسعه':
    //         return 9;
    //     case 'صفر':
    //         return 0;
    // }
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
  //consommation api
  Future SuiviRec(numrec) async {
    String apiurl =
        "http://192.168.1.7:8080/work/consommation%20api/suiviRec.php"; //api url
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    var response = await http.post(Uri.parse(apiurl), body: {
      'num_rec': numrec, //get the username text
    });
    print(response.body);
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"]) {
        setState(() {
          error = true;
          print(jsondata["message"]);
         _voiceBot("Numéro pas trouvé ");
        });
      } else {
        if (jsondata["success"]) {
          setState(() {
            error = false;
            print(jsondata["message"]);
             switch (_currentLocaleId) {
            case 'ar_SA':
                    switch(jsondata['status']){
                        case "0":
                            _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم تسليم مطالبتك ولكن لم تتم معالجتها بعد ");
                            break;
                            case "1":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" شكواك قيد المعالجة ");
                            break;
                            case "2":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم حل شكواك ");
                            break;
                    }
             
              break;
            case 'fr_CA':
             switch(jsondata['status']){
                        case "0":
                            _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre réclamation est delivré mais pas encore traité ");
                            break;
                            case "1":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre réclamation est en cours de traitement ");
                            break;
                            case "2":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre réclamation est résolu ");
                            break;
              }
              break;
            case 'en_US':
            switch(jsondata['status']){
                        case "0":
                            _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your claim is delivered but not yet processed ");
                            break;
                            case "1":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your complaint is being processed ");
                            break;
                            case "2":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your complaint is resolved ");
                            break;
                    }
       
          }
          });
        } else {
          error = true;
          _voiceBot("Vérifier du numéro de réclamation");
         
        }
      }
    } else {
      setState(() {
        error = true;
        print("Error during connecting to server.");
      });
    }
  }
   Future ajoutRecVoiceBot() async {
             var rng = Random();
  for (var i = 1; i < 9; i++) {
    print(rng.nextInt(9));
    NumRec += rng.nextInt(9).toString();  
  }
    print(NomRec);
    print(PrenomRec);
    print(EmailRec);
    print(cinRec);
    print(AdrRec);
    print(type);
    print(DescRec);
 print(NumRec);
    String url = "http://192.168.1.7:8080/work/consommation%20api/ajoutrec.php";

    // var body2 = {};
    var response = await http.post(Uri.parse(url), body: {
      "nom": NomRec.toString(),
      "prenom": PrenomRec.toString(),
      "email": EmailRec.toString(),
      "cin": cinRec.toString(),
      "address": AdrRec.toString(),
      "type": type.toString(),
      "description": DescRec.toString(),
      "num_rec": NumRec.toString(),
    });
    if (response.statusCode == 200) {
      print('ok');
      // var data = json.decode(response.body);
      var jsondata = await json.decode(response.body);
      // print(jsondata);
      if (jsondata["error"]) {
        print("probleme");
        setState(() {
          // showprogress = false; //don't show progress indicator
          error = true;
          print(jsondata["message"]);
          // errormsg = jsondata["message"];
        });
      } else {
        setState(() {
          error = false;
          print("Register succes");
          print(jsondata["message"]);
          NumRec='';
        });
        switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("تم تسجيل طلب الشكوى. يرجى تحميل الملخص الخاص بك");
             
              break;
            case 'fr_CA':
              _voiceBot("Demande de réclamation enregistré. Merci de télécharger votre décharge");
            
              break;
            case 'en_US':
              _voiceBot("Complaint request registered. Please upload your waiver");
       
          }
       
       
      }
    } else {
      setState(() {
        // showprogress = false; //don't show progress indicator
        error = true;
        print("Error during connecting to server.");
      });
  
    }
    
  }
  
Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(0, 0, 100, 100));
    page.graphics.drawString(
        'Commune de  MANZEL ABDERRAHMAN \n Tel (+216) 72 570 125/ (+216) 72 571 295 \n Fax (+216) 72 570 125 \n communemenzelabderrahmen@gmail.com \n Rue El Mongi Slim 7035 menzel abdel rahmen',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(150, 100, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Ce document est votre décharge de réclamation ".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(30, 200, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Monsieur/madame ".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-100, 230, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "$NomRec $PrenomRec votre réclation de type $type est bien enregistrée "
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 320, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Vous pouvez suivre votre réclamation a travers ce numéro $NumRec "
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 400, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
;

    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, '$NomRec$PrenomRec.pdf');
    NumRec = "";
  }
}
Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
 
  

