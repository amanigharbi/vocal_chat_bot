// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:open_file/open_file.dart';
// import 'package:printing/printing.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'mobile.dart' if (dart.library.html) 'web.dart';
import 'package:vocal_chat_bot/models/doc_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';



// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;




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
  //recamation
  String? NomRec;
  String? PrenomRec;
  String cinRec ="";
  String? EmailRec;
  String? AdrRec;
  String? DescRec;
  String? type;
  String NumRec='';
//document
 bool? error;
  String file = "";
  String nameFile = "";
  //branchement
  String? NomRes;
  String? PrenomRes;
  String cinRes ="";
  String? EmailRes;
  String? AdrRes;
  String? DescRes;
  String? typeRes;
  String NumRes='';
   String? type_res;
  String? type_soc;
    String? type_branch;
  //batir
  String? NomAutor;
  String? PrenomAutor;
  String cinAutor ="";
  String? EmailAutor;
  String? AdrAutor;
  String surface="";
    String commentaire="";
  String? prop;
  String NumAutor='';
  int v = 0;
  bool verifLangAr=false;
    bool verifLangTN=false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
   allDocs();

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
        print("word "+result.recognizedWords);
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
                              FlagsCode.TN,
                              height: 30,
                              width: 30,
                            ),
                            label: 'Tounsi',
                            onTap: () {
                              setState(() {
                                _currentLocaleId = "ar_TN";
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
      case 'ar_SA' :
        await flutterTts.setLanguage("ar");
        await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
        break;
            case 'ar_TN' :
        await flutterTts.setLanguage("ar");
        await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
        break;
      case 'fr_CA':
        await flutterTts.setLanguage("fr-FR");
        await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
        for (int i = 0; i < message.length; i++) {
          message = message.replaceAll('`', ' ');
        }
        break;
      case 'en_US':
        await flutterTts.setLanguage("en-US");
        await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
        break;
      
        // await flutterTts.setLanguage("fr-FR");
    }
  
    await flutterTts.speak(message);

    return flutterTts;
  }
void _voiceBot(String msg){
  print("replay "+msg);
       speak(msg);
              _insertSingleItem(
                  msg,
                  MessageType.Receiver,
                  DateFormat("HH:mm").format(DateTime.now()));
}
void checkRec(String txt) async{
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
                case 'ar_TN':
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
                case 'ar_TN':
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
                 case 'ar_TN':
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
              case 'ar_TN':
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
             
                      
               
 print("cin "+cinRec.toString());
        if ((cinRec.toString().length == 8)) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
              case 'ar_TN':
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
                case 'ar_TN':
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
      verifLangAr =true;
              break;
               case 'ar_TN':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
      verifLangTN =true;

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
              case 'ar_TN':
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
          if (verifLangAr){
                                 _currentLocaleId='ar_SA';

          }
           if (verifLangTN){
                                 _currentLocaleId='ar_TN';

          }
          switch (_currentLocaleId) {
            case 'ar_SA':
            
              _voiceBot(
                  "اختر نوعًا من هذه القائمة قل 1 إذا كانت الشكوى من نوع الإدارة 2 إذا كانت من نوع البناء الفوضوي 3 إذا كانت من نوع الإضاءة العامة 4 إذا كانت من نوع الطاقة 5 إذا كانت من المساحة الخضراء اكتب 6 التنقل 7 الصحة والنظافة 8 إذا كان من نوع آخر");
              

              break;
                  case 'ar_TN':
           _currentLocaleId='ar_SA';
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
                  case 'ar_TN':
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
              case 'ar_TN':
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
             case 'ar_TN':
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
        //  _createPDFArabe();
        //_createPDF();
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
              case 'ar_TN':
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
           
            if (txt.toString() != ""){
               NumRec=txt;
    if(NumRec.contains('صفر')){
    NumRec=NumRec.replaceAll('صفر', '0');
   }
     if(NumRec.contains('واحد')){
    NumRec=NumRec.replaceAll('واحد', '1');
   }
     if(NumRec.contains('اثنين')){
    NumRec=NumRec.replaceAll('اثنين', '2');
   }
     if(NumRec.contains('ثلاثه')){
    NumRec=NumRec.replaceAll('ثلاثه', '3');
   }
     if(NumRec.contains('اربعه')){
    NumRec=NumRec.replaceAll('اربعه', '4');
   }
     if(NumRec.contains('خمسه')){
    NumRec=NumRec.replaceAll('خمسه', '5');
   }
     if(NumRec.contains('سته')){
    NumRec=NumRec.replaceAll('سته', '6');
   }
     if(NumRec.contains('سبعه')){
    NumRec=NumRec.replaceAll('سبعه', '7');
   }
     if(NumRec.contains('ثمانيه')){
    NumRec=NumRec.replaceAll('ثمانيه', '8');
   }
      if(NumRec.contains('تسعه')){
    NumRec=NumRec.replaceAll('تسعه', '9');
   }

       NumRec=NumRec.replaceAll(' ', '');
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
                
                print("nummm "+NumRec);
                if (NumRec.length == 8) {
                    switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me your card identity number");
                        
                        v = 9;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi votre numéro de carte d`identité");
                       
                        v = 9;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 9;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 9;
                        break;
                }
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }
            }
            
            break;
  case 9:
            
            if (txt.toString() != ""){
              
   
      // cinRec=txt.toString().replaceAll(' ', '');
      //              if ((_currentLocaleId == "ar_SA") || (_currentLocaleId == "ar_TN")) {
      //               String CinRecArray = txt.split(' ');
      //               for (var i = 0; i < CinRecArray.length; i++) {
      //                 cinRec = cinRec + getNumLet(CinRecArray[i]);
      //               }
                   
      //           } else {
      //               cinRec = txt.replaceAll(' ', '');
      //           }
                 cinRec=txt;
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
             
                print("je suis la");
                
                print("nummm "+cinRec);
                if (cinRec.length == 8) {
            SuiviRec(NumRec,cinRec);
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }

            
           
    
    
}
    }}
void getDocAdmin(String txt) async{
  switch (v) {
    case 10 :
             
        if (txt.toString() != "") {
          docName = txt.toString().replaceAll("é", "e");
          print("docName "+docName.toString());
           print("list "+DocumentsList.toString());
             DocumentsList.forEach((documents) async {
               print("docccc "+documents.name.toString());
            if (documents.name.contains(docName!)) {
              print("dkhalt");
              filteredListDoc.add(documents);
              nameFile = documents.name;
              file = 'http://192.168.1.7:8000/storage/${documents.file}';
            }
          });
        
          
          print("doc ok "+nameFile);
          if (nameFile.isNotEmpty) {
            // ignore: unnecessary_this
            switch (_currentLocaleId) {
 case 'ar_SA':
              _voiceBot("سيتم تنزيل المستند الخاص بك");
              
              break;
              case 'ar_TN':
              _voiceBot("سيتم تنزيل المستند الخاص بك");
              
              break;
            case 'fr_CA':
              _voiceBot("votre document va étre téléchargé");
            
              break;
            case 'en_US':
              _voiceBot("your document will be downloaded");
             
              break;
          }   
            // file = 'http://192.168.1.17/baladiya-app-web/${documents.file}';
            await Future.delayed(Duration(seconds: 1));

            launch(file);
          } else {
            switch (_currentLocaleId) {
           
              case "en_US":
            _voiceBot("document with this name could not be found");
                break;
              case "ar_SA":
            _voiceBot("تعذر العثور على المستند بهذا الاسم");
                break;
                     case "ar_TN":
            _voiceBot("تعذر العثور على المستند بهذا الاسم");
                break;
              case "fr_CA":
            _voiceBot("document avec ce nom est introuvable");
                break;
            }
          }
        }
        file = "";
        nameFile = "";
        break;
    }
  }
void verifResPublic(String txt){
   switch (v) {
     
      case 20:
        if (txt.toString().isNotEmpty) {
          NomAutor = txt;
          print("nom "+NomAutor.toString());
          if (NomAutor is String && NomAutor.toString().trim().length >= 4) {
            switch (_currentLocaleId) {
              case 'ar_SA':

                _voiceBot("السيد/السيدة $NomAutor ارسل لي اسمك");
              

                break;
                case 'ar_TN':
                _voiceBot("السيد/السيدة $NomAutor ارسل لي اسمك");
                break;
              case 'fr_CA':
                _voiceBot(
                    "Monsieur/Madame $NomAutor s`il vous plait envoyer moi votre prénom");
            
                break;
              case 'en_US':
                _voiceBot("Mr/Mrs $NomAutor please send me your first name");
                
                break;
            }
            v = 21;
          } else {
            switch (_currentLocaleId) {
              case 'ar_SA':
                _voiceBot("اسم غير صحيح");
            
                break;
                case 'ar_TN':
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
      case 21:
        PrenomAutor = txt;
         print("prenom "+PrenomAutor.toString());
        if (PrenomAutor is String && PrenomAutor.toString().trim().length > 3) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("السيد/السيدة $PrenomAutor $NomAutor ارسل لي رقم بطاقة هويتك");
             

              break;
                 case 'ar_TN':
              _voiceBot("السيد/السيدة $PrenomAutor $NomAutor ارسل لي رقم بطاقة هويتك");
             

              break;
            case 'fr_CA':
              _voiceBot(
                  "Monsieur/Madame $NomAutor $PrenomAutor  envoyer moi votre numéro de carte d`identité");
             

              break;
            case 'en_US':
              _voiceBot(
                  "Mr/Mrs $NomAutor $PrenomAutor send me your identity card number");
             
              break;
          }

          v = 23;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("قل الاسم الحقيقي من فضلك");
             
              break;
              case 'ar_TN':
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
      case 23:
          // cinRec = txt.replaceAll(' ', '');
           cinAutor =txt;
            if(cinAutor.contains('صفر')){
    cinAutor=cinAutor.replaceAll('صفر', '0');
   }
     if(cinAutor.contains('واحد')){
    cinAutor=cinAutor.replaceAll('واحد', '1');
   }
     if(cinAutor.contains('اثنين')){
    cinAutor=cinAutor.replaceAll('اثنين', '2');
   }
     if(cinAutor.contains('ثلاثه')){
    cinAutor=cinAutor.replaceAll('ثلاثه', '3');
   }
     if(cinAutor.contains('اربعه')){
    cinAutor=cinAutor.replaceAll('اربعه', '4');
   }
     if(cinAutor.contains('خمسه')){
    cinAutor=cinAutor.replaceAll('خمسه', '5');
   }
     if(cinAutor.contains('سته')){
    cinAutor=cinAutor.replaceAll('سته', '6');
   }
     if(cinAutor.contains('سبعه')){
    cinAutor=cinAutor.replaceAll('سبعه', '7');
   }
     if(cinAutor.contains('ثمانيه')){
    cinAutor=cinAutor.replaceAll('ثمانيه', '8');
   }
      if(cinAutor.contains('تسعه')){
    cinAutor=cinAutor.replaceAll('تسعه', '9');
   }
       
      cinAutor=cinAutor.replaceAll(' ', '');
             
                      
               
 print("cin "+cinAutor.toString());
        if ((cinAutor.toString().length == 8)) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
              case 'ar_TN':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
            case 'fr_CA':
              _voiceBot("Génial maintenant c`est quoi votre adresse");
           
              break;
            case 'en_US':
              _voiceBot("Great now what is your address");
            
              break;
          }

          v = 24;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("يجب أن يكون رقم بطاقة الهوية رقمًا يساوي 8");
           
              break;
                case 'ar_TN':
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
      case 24:
        AdrAutor = txt;
         print("adresse "+AdrAutor.toString());
        if (AdrAutor is String && AdrAutor.toString().trim().length > 4) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
            verifLangAr =true;

              break;
               case 'ar_TN':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
            verifLangTN =true;

              break;
            case 'fr_CA':
              _voiceBot("c`est quoi Votre email ");
              
              break;
            case 'en_US':
              _voiceBot("what is your email");
             
              break;
          }

          v = 25;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("هناك خطأ ما حاول مرة أخرى");
            
              break;
              case 'ar_TN':
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
      case 25:
       for (int i = 0; i < txt.length; i++) {
          txt = txt.replaceAll("at", "@");
        }
        EmailAutor = txt.toString().replaceAll(" ", "");
        print("email "+EmailAutor.toString());
        if (RegExp(r'\S+@\S+\.\S+').hasMatch(EmailAutor.toString())) {
 if (verifLangAr){
                                 _currentLocaleId='ar_SA';

          }
           if (verifLangTN){
                                 _currentLocaleId='ar_TN';

          }          switch (_currentLocaleId) {
            case 'ar_SA':
          
              _voiceBot("كم يبلغ مساحة سطح المبنى الخاص بك");              

              break;
                  case 'ar_TN':
          
              _voiceBot("كم يبلغ مساحة سطح المبنى الخاص بك");              

              break;
            case 'fr_CA':
              _voiceBot("c`est quoi la surface de votre batir");              
              break;
            case 'en_US':
              _voiceBot("what is the surface of your building");             
              break;
          }

          v = 26;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("البريد الإلكتروني غير صالح حاول مرة أخرى");
             
              break;
                  case 'ar_TN':
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
      case 26:
       surface =txt;
            if(surface.contains('صفر')){
    surface=surface.replaceAll('صفر', '0');
   }
     if(surface.contains('واحد')){
    surface=surface.replaceAll('واحد', '1');
   }
     if(surface.contains('اثنين')){
    surface=surface.replaceAll('اثنين', '2');
   }
     if(surface.contains('ثلاثه')){
    surface=surface.replaceAll('ثلاثه', '3');
   }
     if(surface.contains('اربعه')){
    surface=surface.replaceAll('اربعه', '4');
   }
     if(surface.contains('خمسه')){
    surface=surface.replaceAll('خمسه', '5');
   }
     if(surface.contains('سته')){
    surface=surface.replaceAll('سته', '6');
   }
     if(surface.contains('سبعه')){
    surface=surface.replaceAll('سبعه', '7');
   }
     if(surface.contains('ثمانيه')){
    surface=surface.replaceAll('ثمانيه', '8');
   }
      if(surface.contains('تسعه')){
    surface=surface.replaceAll('تسعه', '9');
   }
       
      surface=surface.replaceAll(' ', '');
        print("urfce "+surface);

        switch (_currentLocaleId) {
          case 'ar_SA':
            _voiceBot("هل الأرض مجاورة للممتلكات العامة؟ قل 1 إذا كانت الإجابة بنعم و 2 إذا لم يكن كذلك");
           
            break;
             case 'ar_TN':
            _voiceBot("هل الأرض مجاورة للممتلكات العامة؟ قل 1 إذا كانت الإجابة بنعم و 2 إذا لم يكن كذلك");
           
            break;
          case 'fr_CA':
            _voiceBot(
                "Le terrain jouxte-t-il une propriété publique? dire 1 si oui et 2 sinon");
            
            break;
          case 'en_US':
            _voiceBot("Does the land adjoin public property? say 1 if yes and 2 if not");
            break;
        }

        v = 27;

        break;
      case 27:
        if ((txt.toString().contains('1'))  ||  (txt.toString().contains('واحد'))) {
          prop = "oui";
        } else if  ((txt.toString().contains('2')) || (txt.toString().contains('اثنين'))) {
          prop = "non";
        }
        else{
        switch (_currentLocaleId) {
          case 'ar_SA':
            _voiceBot(" حاول مرة أخرى");
       
            break;
              case 'ar_TN':
            _voiceBot(" حاول مرة أخرى");
       
            break;
          case 'fr_CA':
            _voiceBot(
                "réessayer");
           
            break;
          case 'en_US':
            _voiceBot("try again");
           
            break;
        }  
        }
        ajoutBatir();
        //  _createPDFArabe();
        //_createPDF();
          print("nom " +
              NomAutor.toString() +
              " prenom " +
              PrenomAutor.toString() +
              " cin " +
              cinAutor.toString() +
              " email " +
              EmailAutor.toString() +
              " adr " +
              AdrAutor.toString() +
              " surface " +
              surface.toString() +
              " prop " +
              prop.toString());

          // v = 8;
       
        
        break;
   case 28:
           
            if (txt.toString() != ""){
               NumAutor=txt;
    if(NumAutor.contains('صفر')){
    NumAutor=NumAutor.replaceAll('صفر', '0');
   }
     if(NumAutor.contains('واحد')){
    NumAutor=NumAutor.replaceAll('واحد', '1');
   }
     if(NumAutor.contains('اثنين')){
    NumAutor=NumAutor.replaceAll('اثنين', '2');
   }
     if(NumAutor.contains('ثلاثه')){
    NumAutor=NumAutor.replaceAll('ثلاثه', '3');
   }
     if(NumAutor.contains('اربعه')){
    NumAutor=NumAutor.replaceAll('اربعه', '4');
   }
     if(NumAutor.contains('خمسه')){
    NumAutor=NumAutor.replaceAll('خمسه', '5');
   }
     if(NumAutor.contains('سته')){
    NumAutor=NumAutor.replaceAll('سته', '6');
   }
     if(NumAutor.contains('سبعه')){
    NumAutor=NumAutor.replaceAll('سبعه', '7');
   }
     if(NumAutor.contains('ثمانيه')){
    NumAutor=NumAutor.replaceAll('ثمانيه', '8');
   }
      if(NumAutor.contains('تسعه')){
    NumAutor=NumAutor.replaceAll('تسعه', '9');
   }

       NumAutor=NumAutor.replaceAll(' ', '');
      // num_rec=txt.toString().replaceAll(' ', '');
                //    if (_currentLocaleId == "ar_SA") {
                //     String NumResArray = txt.split(' ');
                //     for (var i = 0; i < NumResArray.length; i++) {
                //       num_rec = num_rec + getNumLet(NumResArray[i]);
                //     }
                   
                // } else {
                //     num_rec = txt.replaceAll(' ', '');
                // }
               
             
                print("je suis la");
                
                print("nummm "+NumAutor);
                if (NumAutor.length == 8) {
                    switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me your card identity number");
                        
                        v = 29;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi votre numéro de carte d`identité");
                       
                        v = 29;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 29;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 29;
                        break;
                }
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }
            }
            
            break;
  case 29:
            
            if (txt.toString() != ""){
              
   
      // cinRes=txt.toString().replaceAll(' ', '');
      //              if ((_currentLocaleId == "ar_SA") || (_currentLocaleId == "ar_TN")) {
      //               String cinResArray = txt.split(' ');
      //               for (var i = 0; i < cinResArray.length; i++) {
      //                 cinRes = cinRes + getNumLet(cinResArray[i]);
      //               }
                   
      //           } else {
      //               cinRes = txt.replaceAll(' ', '');
      //           }
                 cinAutor=txt;
    if(cinAutor.contains('صفر')){
    cinAutor=cinAutor.replaceAll('صفر', '0');
   }
     if(cinAutor.contains('واحد')){
    cinAutor=cinAutor.replaceAll('واحد', '1');
   }
     if(cinAutor.contains('اثنين')){
    cinAutor=cinAutor.replaceAll('اثنين', '2');
   }
     if(cinAutor.contains('ثلاثه')){
    cinAutor=cinAutor.replaceAll('ثلاثه', '3');
   }
     if(cinAutor.contains('اربعه')){
    cinAutor=cinAutor.replaceAll('اربعه', '4');
   }
     if(cinAutor.contains('خمسه')){
    cinAutor=cinAutor.replaceAll('خمسه', '5');
   }
     if(cinAutor.contains('سته')){
    cinAutor=cinAutor.replaceAll('سته', '6');
   }
     if(cinAutor.contains('سبعه')){
    cinAutor=cinAutor.replaceAll('سبعه', '7');
   }
     if(cinAutor.contains('ثمانيه')){
    cinAutor=cinAutor.replaceAll('ثمانيه', '8');
   }
      if(cinAutor.contains('تسعه')){
    cinAutor=cinAutor.replaceAll('تسعه', '9');
   }

       cinAutor=cinAutor.replaceAll(' ', '');
             
                print("je suis la");
                
                print("nummm "+cinAutor);
                if (cinAutor.length == 8) {
            SuiviBatir(NumAutor,cinAutor);
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }

            
            }}}

void verifAutoBatir(String txt){
  switch (v) {
     
      case 11:
        if (txt.toString().isNotEmpty) {
          NomRes = txt;
          print("nom "+NomRes.toString());
          if (NomRes is String && NomRes.toString().trim().length >= 4) {
            switch (_currentLocaleId) {
              case 'ar_SA':

                _voiceBot("السيد/السيدة $NomRes ارسل لي اسمك");
              

                break;
                case 'ar_TN':
                _voiceBot("السيد/السيدة $NomRes ارسل لي اسمك");
                break;
              case 'fr_CA':
                _voiceBot(
                    "Monsieur/Madame $NomRes s`il vous plait envoyer moi votre prénom");
            
                break;
              case 'en_US':
                _voiceBot("Mr/Mrs $NomRes please send me your first name");
                
                break;
            }
            v = 12;
          } else {
            switch (_currentLocaleId) {
              case 'ar_SA':
                _voiceBot("اسم غير صحيح");
            
                break;
                case 'ar_TN':
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
      case 12:
        PrenomRes = txt;
         print("prenom "+PrenomRes.toString());
        if (PrenomRes is String && PrenomRes.toString().trim().length > 3) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("السيد/السيدة $PrenomRes $NomRes ارسل لي رقم بطاقة هويتك");
             

              break;
                 case 'ar_TN':
              _voiceBot("السيد/السيدة $PrenomRes $NomRes ارسل لي رقم بطاقة هويتك");
             

              break;
            case 'fr_CA':
              _voiceBot(
                  "Monsieur/Madame $NomRes $PrenomRes  envoyer moi votre numéro de carte d`identité");
             

              break;
            case 'en_US':
              _voiceBot(
                  "Mr/Mrs $NomRes $PrenomRes send me your identity card number");
             
              break;
          }

          v = 13;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("قل الاسم الحقيقي من فضلك");
             
              break;
              case 'ar_TN':
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
      case 13:
          // cinRec = txt.replaceAll(' ', '');
           cinRes =txt;
            if(cinRes.contains('صفر')){
    cinRes=cinRes.replaceAll('صفر', '0');
   }
     if(cinRes.contains('واحد')){
    cinRes=cinRes.replaceAll('واحد', '1');
   }
     if(cinRes.contains('اثنين')){
    cinRes=cinRes.replaceAll('اثنين', '2');
   }
     if(cinRes.contains('ثلاثه')){
    cinRes=cinRes.replaceAll('ثلاثه', '3');
   }
     if(cinRes.contains('اربعه')){
    cinRes=cinRes.replaceAll('اربعه', '4');
   }
     if(cinRes.contains('خمسه')){
    cinRes=cinRes.replaceAll('خمسه', '5');
   }
     if(cinRes.contains('سته')){
    cinRes=cinRes.replaceAll('سته', '6');
   }
     if(cinRes.contains('سبعه')){
    cinRes=cinRes.replaceAll('سبعه', '7');
   }
     if(cinRes.contains('ثمانيه')){
    cinRes=cinRes.replaceAll('ثمانيه', '8');
   }
      if(cinRes.contains('تسعه')){
    cinRes=cinRes.replaceAll('تسعه', '9');
   }
       
      cinRes=cinRes.replaceAll(' ', '');
             
                      
               
 print("cin "+cinRes.toString());
        if ((cinRes.toString().length == 8)) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
              case 'ar_TN':
              _voiceBot("عظيم الآن ما هو عنوانك");
          

              break;
            case 'fr_CA':
              _voiceBot("Génial maintenant c`est quoi votre adresse");
           
              break;
            case 'en_US':
              _voiceBot("Great now what is your address");
            
              break;
          }

          v = 14;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("يجب أن يكون رقم بطاقة الهوية رقمًا يساوي 8");
           
              break;
                case 'ar_TN':
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
      case 14:
        AdrRes = txt;
         print("adresse "+AdrRes.toString());
        if (AdrRes is String && NomRes.toString().trim().length > 4) {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
        verifLangAr =true;

              break;
               case 'ar_TN':
              _voiceBot("ماهو بريدك الإلكتروني");
              
      _currentLocaleId = 'en_US';
            verifLangTN =true;

              break;
            case 'fr_CA':
              _voiceBot("c`est quoi Votre email ");
              
              break;
            case 'en_US':
              _voiceBot("what is your email");
             
              break;
          }

          v = 15;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("هناك خطأ ما حاول مرة أخرى");
            
              break;
              case 'ar_TN':
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
      case 15:
       for (int i = 0; i < txt.length; i++) {
          txt = txt.replaceAll("at", "@");
        }
        EmailRes = txt.toString().replaceAll(" ", "");
        print("email "+EmailRes.toString());
        if (RegExp(r'\S+@\S+\.\S+').hasMatch(EmailRes.toString())) {
             if (verifLangAr){
                                 _currentLocaleId='ar_SA';

          }
           if (verifLangTN){
                                 _currentLocaleId='ar_TN';

          }
          switch (_currentLocaleId) {
            case 'ar_SA':
          
              _voiceBot("اختر نوع طلبك ، قل 1 إذا كان نوع الماء و 2 إذا كان نوع الكهرباء و الغاز");              

              break;
                  case 'ar_TN':
          
              _voiceBot("اختر نوع طلبك ، قل 1 إذا كان نوع الماء و 2 إذا كان نوع الكهرباء و الغاز");              

              break;
            case 'fr_CA':
              _voiceBot("Choisir le type de votre demande dire 1 si de type sonede et 2 si de type steg");              
              break;
            case 'en_US':
              _voiceBot("Choose the type of your request say 1 if  sonede type and 2 if steg type");             
              break;
          }

          v = 16;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("البريد الإلكتروني غير صالح حاول مرة أخرى");
             
              break;
                  case 'ar_TN':
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
      case 16:
        if (txt.toString().contains('1'))  {
          typeRes = "Sonede";
        } else if  (txt.toString().contains('2')) {
          typeRes = "Steg";
        } else if  (txt.toString().contains('واحد')) {
          typeRes = "الماء";
        } else if (txt.toString().contains('اثنين')) {
          typeRes = "الكهرباء و الغاز";
        }
        else{
        switch (_currentLocaleId) {
          case 'ar_SA':
            _voiceBot("نوع غير معروف حاول مرة أخرى");
       
            break;
              case 'ar_TN':
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
            _voiceBot("من فضلك أرسل لي وصفا موجزا لطلبك");
           
            break;
             case 'ar_TN':
            _voiceBot("من فضلك أرسل لي وصفا موجزا لطلبك");
           
            break;
          case 'fr_CA':
            _voiceBot(
                "Merci de m envoyer une petite description de votre demande");
            
            break;
          case 'en_US':
            _voiceBot("Please send me a short description of your request");
            break;
        }

        v = 17;

        break;
      case 17:
        DescRes = txt;
         print("description "+DescRec.toString());
        if (DescRes is String && DescRes.toString().trim().length > 10) {
          
        ajoutResVoiceBot();
        //  _createPDFArabe();
        //_createPDF();
          print("nom " +
              NomRes.toString() +
              " prenom " +
              PrenomRes.toString() +
              " cin " +
              cinRes.toString() +
              " email " +
              EmailRes.toString() +
              " adr " +
              AdrRes.toString() +
              " type " +
              typeRes.toString() +
              " description " +
              DescRes.toString());

          // v = 8;
        } else {
          switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("قل وصفا صحيحا");
              
              break;
              case 'ar_TN':
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
   case 18:
           
            if (txt.toString() != ""){
               NumRes=txt;
    if(NumRes.contains('صفر')){
    NumRes=NumRes.replaceAll('صفر', '0');
   }
     if(NumRes.contains('واحد')){
    NumRes=NumRes.replaceAll('واحد', '1');
   }
     if(NumRes.contains('اثنين')){
    NumRes=NumRes.replaceAll('اثنين', '2');
   }
     if(NumRes.contains('ثلاثه')){
    NumRes=NumRes.replaceAll('ثلاثه', '3');
   }
     if(NumRes.contains('اربعه')){
    NumRes=NumRes.replaceAll('اربعه', '4');
   }
     if(NumRes.contains('خمسه')){
    NumRes=NumRes.replaceAll('خمسه', '5');
   }
     if(NumRes.contains('سته')){
    NumRes=NumRes.replaceAll('سته', '6');
   }
     if(NumRes.contains('سبعه')){
    NumRes=NumRes.replaceAll('سبعه', '7');
   }
     if(NumRes.contains('ثمانيه')){
    NumRes=NumRes.replaceAll('ثمانيه', '8');
   }
      if(NumRes.contains('تسعه')){
    NumRes=NumRes.replaceAll('تسعه', '9');
   }

       NumRes=NumRes.replaceAll(' ', '');
      // num_rec=txt.toString().replaceAll(' ', '');
                //    if (_currentLocaleId == "ar_SA") {
                //     String NumResArray = txt.split(' ');
                //     for (var i = 0; i < NumResArray.length; i++) {
                //       num_rec = num_rec + getNumLet(NumResArray[i]);
                //     }
                   
                // } else {
                //     num_rec = txt.replaceAll(' ', '');
                // }
               
             
                print("je suis la");
                
                print("nummm "+NumRes);
                if (NumRes.length == 8) {
                    switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me your card identity number");
                        
                        v = 19;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi votre numéro de carte d`identité");
                       
                        v = 19;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 19;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم بطاقة هويتك");
                        
                        v = 19;
                        break;
                }
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }
            }
            
            break;
  case 19:
            
            if (txt.toString() != ""){
              
   
      // cinRes=txt.toString().replaceAll(' ', '');
      //              if ((_currentLocaleId == "ar_SA") || (_currentLocaleId == "ar_TN")) {
      //               String cinResArray = txt.split(' ');
      //               for (var i = 0; i < cinResArray.length; i++) {
      //                 cinRes = cinRes + getNumLet(cinResArray[i]);
      //               }
                   
      //           } else {
      //               cinRes = txt.replaceAll(' ', '');
      //           }
                 cinRes=txt;
    if(cinRes.contains('صفر')){
    cinRes=cinRes.replaceAll('صفر', '0');
   }
     if(cinRes.contains('واحد')){
    cinRes=cinRes.replaceAll('واحد', '1');
   }
     if(cinRes.contains('اثنين')){
    cinRes=cinRes.replaceAll('اثنين', '2');
   }
     if(cinRes.contains('ثلاثه')){
    cinRes=cinRes.replaceAll('ثلاثه', '3');
   }
     if(cinRes.contains('اربعه')){
    cinRes=cinRes.replaceAll('اربعه', '4');
   }
     if(cinRes.contains('خمسه')){
    cinRes=cinRes.replaceAll('خمسه', '5');
   }
     if(cinRes.contains('سته')){
    cinRes=cinRes.replaceAll('سته', '6');
   }
     if(cinRes.contains('سبعه')){
    cinRes=cinRes.replaceAll('سبعه', '7');
   }
     if(cinRes.contains('ثمانيه')){
    cinRes=cinRes.replaceAll('ثمانيه', '8');
   }
      if(cinRes.contains('تسعه')){
    cinRes=cinRes.replaceAll('تسعه', '9');
   }

       cinRes=cinRes.replaceAll(' ', '');
             
                print("je suis la");
                
                print("nummm "+cinRes);
                if (cinRes.length == 8) {
            SuiviRes(NumRes,cinRes);
                }
                else {
                  switch (_currentLocaleId) {
                    case 'ar_SA':
              _voiceBot("حاول مرة اخرى");
              
              break;
              case 'ar_TN':
              _voiceBot("حاول مرة اخرى");
              
              break;
            case 'fr_CA':
              _voiceBot("Revérifier");
            
              break;
            case 'en_US':
              _voiceBot("Recheck");
             
              break;
          }
                }

            
            }}

}
  Future<void> _getResponse(txt) async {
    _insertSingleItem(
        txt, MessageType.Sender, DateFormat("HH:mm").format(DateTime.now()));
    if (txt.toString().contains("ajouter réclamation") ||
        txt.toString().contains("نعدي شكوى") ||
        txt.toString().contains("reclamation") || (txt.toString().contains("اضافه شكوى")) || (txt.toString().contains("complaint")) ){
      switch (_currentLocaleId) {
        case 'ar_SA':
        _voiceBot("مرحبا في فضاء الشكايات من فضلك ارسل لي اسم العائلة ");
          v = 1;

          break;
             case 'ar_TN':
        _voiceBot("مرحبا في فضاء الشكايات من فضلك ارسل لي اسم العائلة ");
          v = 1;

          break;
        case 'fr_CA':
   _voiceBot("Bienvenue dans l`espace de réclamation merci d`envoyer votre nom");
   v=1;
          break;
        case 'en_US':
        _voiceBot("Hello! please send me your last name");
          v = 1;
          break;
      }
      txt = "";
    }
       if ((txt.toString().contains("suivi réclamation"))|| (txt.toString().contains("اتباع الشكوى"))
        || (txt.toString().contains("check")) || (txt.toString().contains("وين وصلت الشكوى"))) {
           
           
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
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v = 8;
                        break;
                }
             txt = "";
              
        }
            if ((txt.toString().contains("document"))|| (txt.toString().contains("وثيقة"))) {
           

                switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("hello, what is the name of the desired administrative document");
                        _currentLocaleId ="fr_CA";
                        v = 10;
                        break;
                    case "fr_CA":
                        _voiceBot("bonjour,c`est quoi le nom du document administratif souhaité");
                       
                        v = 10;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، ما هو اسم المستند الإداري المطلوب");
                         _currentLocaleId ="fr_CA";
                        v = 10;
                        break;
                         case "ar_TN":
                        _voiceBot("مرحبًا ، ما هو اسم المستند الإداري المطلوب");
                         _currentLocaleId ="fr_CA";
                        v = 10;
                        break;
                }
             txt = "";
              
        }
        if ((txt.toString().contains("réseau public")) || (txt.toString().contains("شبكه عامه"))||
         (txt.toString().contains("public network")) || (txt.toString().contains("ماء وضوء")))
            {
                switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hello! please send me your last name");
                        
                        v = 11;
                        break;
                    case "fr_CA":
                        _voiceBot("Bienvenue merci d`envoyer votre nom");
                       
                        v = 11;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبا  من فضلك ارسل لي اسم العائلة");
                        
                        v = 11;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبا  من فضلك ارسل لي اسم العائلة");
                        
                        v = 11;
                        break;
                }
             txt = "";
            }
            if ((txt.toString().contains("suivi demande réseau")) || (txt.toString().contains("اتباع مطلب"))|| 
            (txt.toString().contains("check public ")) || (txt.toString().contains("وين وصل المطلب"))){
              switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me the request number you want to track");
                        
                        v = 18;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi le numéro de demande que vous voullez suivre");
                       
                        v = 18;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v = 18;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v = 18;
                        break;
                }
             txt = "";  
            }
              if ((txt.toString().contains("autorisation bâtir"))|| (txt.toString().contains("رخصه بناء")) || (txt.toString().contains("رخصة"))||
         (txt.toString().contains("permit")))
            {
                switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hello! please send me your last name");
                        
                        v = 20;
                        break;
                    case "fr_CA":
                        _voiceBot("Bienvenue merci d`envoyer votre nom");
                       
                        v = 20;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبا  من فضلك ارسل لي اسم العائلة");
                        
                        v = 20;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبا  من فضلك ارسل لي اسم العائلة");
                        
                        v = 20;
                        break;
                }
             txt = "";
            }
          if ((txt.toString().contains("suivi bâtir")) || (txt.toString().contains("اتباع رخصه"))||
           (txt.toString().contains("check request")) || (txt.toString().contains("وين وصل مطلب الرخصه")))
          {
              switch (_currentLocaleId) {
                    case "en_US":
                        _voiceBot("Hi send me the request number you want to track");
                        
                        v = 28;
                        break;
                    case "fr_CA":
                        _voiceBot("Salut envoyez moi le numéro de demande que vous voullez suivre");
                       
                        v = 28;
                        break;
                    case "ar_SA":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v =28;
                        break;
                               case "ar_TN":
                        _voiceBot("مرحبًا ، أرسل لي رقم المطالبة الذي تريد تتبعه");
                        
                        v = 28;
                        break;
                }
             txt = "";  
            }
        checkRec(txt);
        getDocAdmin(txt);
                verifResPublic(txt);
                verifAutoBatir(txt);

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
  Future SuiviRec(numrec,cin) async {
    String apiurl =
        "http://192.168.1.7:8080/work/consommation%20api/suiviRec.php"; //api url
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    var response = await http.post(Uri.parse(apiurl), body: {
      'num_rec': numrec,
      'cin':cin, //get the username text
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
                 case 'ar_TN':
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
        });
        switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("تم تسجيل طلب الشكوى. يرجى تحميل الملخص الخاص بك");
                     _createPDFArabe(NumRec);

              break;
               case 'ar_TN':
              _voiceBot("تم تسجيل طلب الشكوى. يرجى تحميل الملخص الخاص بك");
                     _createPDFArabe(NumRec);

              break;
            case 'fr_CA':
              _voiceBot("Demande de réclamation enregistré. Merci de télécharger votre décharge");
            _createPDF(NumRec);

              break;
            case 'en_US':
              _voiceBot("Complaint request registered. Please upload your waiver");
       _createPDF(NumRec);

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
   Future SuiviBatir(numAutor,cin) async {
    String apiurl =
        "http://192.168.1.7:8080/work/consommation%20api/SuiviAutorisationBatir.php"; //api url
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    var response = await http.post(Uri.parse(apiurl), body: {
      'num_autor': numAutor,
      'cin':cin, //get the username text
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
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" طلبك قيد المعالجة ");
                            break;
                            case "2":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم قبول طلبك ");
                      
                            NomAutor = jsondata["first_name"].toString();
                  PrenomAutor = jsondata["last_name"].toString();
                  AdrAutor = jsondata["adresse"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrAccord();
                  } else {
                    _createPDFArabeAccordBatir();
                  }
                            break;
                             case "3":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم رفض طلبك ");
                            NomAutor = jsondata["last_name"];
                  PrenomAutor = jsondata["first_name"];
                  AdrAutor = jsondata["adresse"];
                  commentaire = jsondata["response"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrRejet(commentaire);
                  } else {
                    _createPDFArabeRefusBatir(commentaire);
                  }
            
                            break;
                    }
             
              break;
                 case 'ar_TN':
                    switch(jsondata['status']){
                        case "0":
                            _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم تسليم مطالبتك ولكن لم تتم معالجتها بعد ");
                            break;
                            case "1":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" شكواك قيد المعالجة ");
                            break;
                            case "2":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم قبول طلبك ");
                      
                                 NomAutor = jsondata["first_name"].toString();
                  PrenomAutor = jsondata["last_name"].toString();
                  AdrAutor = jsondata["adresse"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrAccord();
                  } else {
                    _createPDFArabeAccordBatir();
                  }
                            break;
                             case "3":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم رفض طلبك ");
                             NomAutor = jsondata["last_name"];
                  PrenomAutor = jsondata["first_name"];
                  AdrAutor = jsondata["adresse"];
                  commentaire = jsondata["response"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrRejet(commentaire);
                  } else {
                    _createPDFArabeRefusBatir(commentaire);
                  }  
                            break;
                    }
             
              break;
            case 'fr_CA':
             switch(jsondata['status']){
                        case "0":
                            _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est delivré mais pas encore traité ");
                            break;
                            case "1":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est en cours de traitement ");
                            break;
                            case "2":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est acceptée ");
                             NomAutor = jsondata["first_name"].toString();
                  PrenomAutor = jsondata["last_name"].toString();
                  AdrAutor = jsondata["adresse"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrAccord();
                  } else {
                    _createPDFArabeAccordBatir();
                  }
                            break;
                             case "3":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est refusée ");
                             NomAutor = jsondata["last_name"];
                  PrenomAutor = jsondata["first_name"];
                  AdrAutor = jsondata["adresse"];
                  commentaire = jsondata["response"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrRejet(commentaire);
                  } else {
                    _createPDFArabeRefusBatir(commentaire);
                  }
                            break;
              }
              break;
            case 'en_US':
            switch(jsondata['status']){
                        case "0":
                            _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is delivered but not yet processed ");
                            break;
                            case "1":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is being processed ");
                            break;
                            case "2":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is accepted ");
                            NomAutor = jsondata["first_name"].toString();
                  PrenomAutor = jsondata["last_name"].toString();
                  AdrAutor = jsondata["adresse"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrAccord();
                  } else {
                    _createPDFArabeAccordBatir();
                  }
                            break;
                            case "3":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is rejected ");
                                 NomAutor = jsondata["last_name"];
                  PrenomAutor = jsondata["first_name"];
                  AdrAutor = jsondata["adresse"];
                  commentaire = jsondata["response"];

                  if (NomAutor.toString().contains(RegExp(r'[A-Z,a-z]'))) {
                    _createPDFfrRejet(commentaire);
                  } else {
                    _createPDFArabeRefusBatir(commentaire);
                  }
                                break;
                    }
       
          }
          });
        } else {
          error = true;
          _voiceBot("Vérifier du numéro de demande");
         
        }
      }
    } else {
      setState(() {
        error = true;
        print("Error during connecting to server.");
      });
    }
  }
   Future ajoutBatir() async {
             var rng = Random();
  for (var i = 1; i < 9; i++) {
    print(rng.nextInt(9));
    NumAutor += rng.nextInt(9).toString();  
  }

    String url = "http://192.168.1.7:8080/work/consommation%20api/add_autorisation_batir.php";

    // var body2 = {};
    var response = await http.post(Uri.parse(url), body: {
      "nom": NomAutor.toString(),
      "prenom": PrenomAutor.toString(),
      "email": EmailAutor.toString(),
      "cin": cinAutor.toString(),
      "address": AdrAutor.toString(),
      "surface": surface.toString(),
      "prop": prop.toString(),
      "num_autor": NumAutor.toString(),
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
        });
        switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("تم تسجيل  طلبكم. يرجى تحميل الملخص الخاص بك");
                _createPDFArabeForBatir(NumAutor);
              break;
               case 'ar_TN':
              _voiceBot("تم تسجيل  طلبكم. يرجى تحميل الملخص الخاص بك");
_createPDFArabeForBatir(NumAutor);
              break;
            case 'fr_CA':
              _voiceBot("Demande enregistré. Merci de télécharger votre décharge");
            _createPDFBatir(NumAutor);

              break;
            case 'en_US':
              _voiceBot("Request registered. Please upload your waiver");
            _createPDFBatir(NumAutor);

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

 Future SuiviRes(numres,cin) async {
    String apiurl =
        "http://192.168.1.7:8080/work/consommation%20api/suiviDemandeBranchement.php"; //api url
    //dont use http://localhost , because emulator don't get that address
    //insted use your local IP address or use live URL
    //hit "ipconfig" in windows or "ip a" in linux to get you local IP

    var response = await http.post(Uri.parse(apiurl), body: {
      'num_branch': numres,
      'cin':cin, //get the username text
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
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" طلبك قيد المعالجة ");
                            break;
                            case "2":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم قبول طلبك ");
                      
                        NomRes = jsondata["first_name"].toString();
                  PrenomRes = jsondata["last_name"].toString();
                  AdrRes = jsondata["adresse"];
                  if (jsondata["type"] == "Sonede") {
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSonede()
                        : _createPDFArabeAccordSonede();
                  } else {
                    print("steg");
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSteg()
                        : _createPDFArabeAccordSteg();
                  }
                            break;
                             case "3":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم رفض طلبك ");
                            break;
                    }
             
              break;
                 case 'ar_TN':
                    switch(jsondata['status']){
                        case "0":
                            _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم تسليم مطالبتك ولكن لم تتم معالجتها بعد ");
                            break;
                            case "1":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" شكواك قيد المعالجة ");
                            break;
                            case "2":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم قبول طلبك ");
                      
                        NomRes = jsondata["first_name"].toString();
                  PrenomRes = jsondata["last_name"].toString();
                  AdrRes = jsondata["adresse"];
                  if (jsondata["type"] == "Sonede") {
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSonede()
                        : _createPDFArabeAccordSonede();
                  } else {
                    print("steg");
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSteg()
                        : _createPDFArabeAccordSteg();
                  }
                            break;
                             case "3":
                                _voiceBot("السيد او السيدة  "+jsondata['last_name'] +' '+ jsondata['first_name']+" تم رفض طلبك ");
                            break;
                    }
             
              break;
            case 'fr_CA':
             switch(jsondata['status']){
                        case "0":
                            _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est delivré mais pas encore traité ");
                            break;
                            case "1":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est en cours de traitement ");
                            break;
                            case "2":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est acceptée ");
                              NomRes = jsondata["first_name"].toString();
                  PrenomRes = jsondata["last_name"].toString();
                  AdrRes = jsondata["adresse"];
                  if (jsondata["type"] == "Sonede") {
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSonede()
                        : _createPDFArabeAccordSonede();
                  } else {
                    print("steg");
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSteg()
                        : _createPDFArabeAccordSteg();
                  }
                            break;
                             case "3":
                                _voiceBot("Monsieur ou Madame "+jsondata['last_name'] +' '+ jsondata['first_name']+" votre demande est refusée ");
                            break;
              }
              break;
            case 'en_US':
            switch(jsondata['status']){
                        case "0":
                            _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is delivered but not yet processed ");
                            break;
                            case "1":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is being processed ");
                            break;
                            case "2":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is accepted ");
                                                  NomRes = jsondata["first_name"].toString();
                  PrenomRes = jsondata["last_name"].toString();
                  AdrRes = jsondata["adresse"];
                  if (jsondata["type"] == "Sonede") {
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSonede()
                        : _createPDFArabeAccordSonede();
                  } else {
                    print("steg");
                    NomRes.toString().contains(RegExp(r'[A-Z,a-z]'))
                        ? _createPDFfrAccordSteg()
                        : _createPDFArabeAccordSteg();
                  }
                            break;
                            case "3":
                                _voiceBot("Mr or Mrs "+jsondata['last_name'] +' '+ jsondata['first_name']+" your request is rejected ");
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
   Future ajoutResVoiceBot() async {
             var rng = Random();
  for (var i = 1; i < 9; i++) {
    print(rng.nextInt(9));
    NumRes += rng.nextInt(9).toString();  
  }
 
    String url = "http://192.168.1.7:8080/work/consommation%20api/adddemendebranchement.php";

    // var body2 = {};
    var response = await http.post(Uri.parse(url), body: {
   'nomRes':  NomRes.toString(),
        'prenomRes' :  PrenomRes.toString(),
        'emailRes': EmailRes.toString(),
        'cinRes': cinRes.toString(),
        'adrRes': AdrRes.toString(),
        'typeRes': typeRes.toString(),
        'descRes': DescRes.toString(),
        'num_branch': NumRes.toString(),
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
         
        });
        switch (_currentLocaleId) {
            case 'ar_SA':
              _voiceBot("تم تسجيل طلبكم. يرجى تحميل الملخص الخاص بك");
            _createPDFArabeBranchemnt(NumRes);

              break;
               case 'ar_TN':
              _voiceBot("تم تسجيل طلبكم .يرجى تحميل الملخص الخاص بك");
            _createPDFArabeBranchemnt(NumRes);

              break;
            case 'fr_CA':
              _voiceBot("Demande  enregistré. Merci de télécharger votre décharge");
            _createPDFBranchement(NumRes);

              break;
            case 'en_US':
              _voiceBot("Request registered. Please upload your waiver");
            _createPDFBranchement(NumRes);

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
    String? docName;
  // consomation api liste documents
  List<Documents> DocumentsList = [];
  late Future<List<Documents>> futureDoc;
  late List<Documents> filteredListDoc = [];
  TextEditingController controllerDoc = new TextEditingController();
  final ScrollController _listScrollControllerDoc = new ScrollController();

  sendDoc(String text) async {
    DocumentsList.forEach((documents) {
      if (documents.name.contains(text)) {
        _insertSingleItem(documents.toString(), MessageType.Receiver,
            DateFormat("HH:mm").format(DateTime.now()));
      } else {
        _voiceBot("Document introuvable");
      }
    });

    setState(() {});
  }

  Future<List<Documents>> allDocs() async {
    final response = await http.get(Uri.parse(
        "http://192.168.1.7:8080/work/consommation%20api/viewAllDocuments.php"));
    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      DocumentsList = items.map<Documents>((json) {
        return Documents.fromJson(json);
      }).toList();

      return DocumentsList;
    }
    //   final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    //   return parsed.map<Documents>((json) => Documents.fromMap(json)).toList();
    // }
    else {
      throw Exception('Failed to load album');
    }
  }
   // open pdf
  Future<void> launchFile(List<int> bytes, String fileName) async {
    final path = (await getExternalStorageDirectory())!.path;

    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/$fileName');
  }
  
// branchement
  Future<void> _createPDFBranchement(String NumRes) async {
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
        bounds: Rect.fromLTWH(100, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "$NomRes $PrenomRes \n $EmailRes \n Bizerte le " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0.5),
        bounds: Rect.fromLTWH(300, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Numéro dossier: $NumRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 180, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Décharge de demande de branchement  aux réseaux publics de type  $typeRes"
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 210, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Monsieur/madame $NomRes $PrenomRes titulaire de cin $cinRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(0, 240, pageSize.width - 100, 200),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Nous avons bien récu votre demande de branchement aux réseaux publics de type $typeRes.Nous essayons de vous répondre dés que possible.\nVous pouvez suivre votre demande a travers ce numéro $NumRes pour restez en contact de tous. \n Veuillez recevoir, Madame, ou Monsieur, $NomRes $PrenomRes nos salutations distinguées."
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 310, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "les documents fournis pour compléter votre dossier :".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        pen: PdfPen(PdfColor(255, 0, 0)),
        bounds: Rect.fromLTWH(0, 420, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "-Une demande au nom de madame le maire ,identifiable par signature sous forme de plus d'un propriétaire \n- Certificat de propriété iu contrat de vente "
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 455, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Commune MANZEL ABDERRAHMEN".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(230, 550, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRes$PrenomRes.pdf');
    NumRes = "";
  }

// arabic pdf
  Future<void> _createPDFArabeBranchemnt(String NumRes) async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(400, 0, 100, 100));
    page.graphics.drawString(
        'بلدية منزل عبد الرحمن \n هاتف (+216) 72570125 / (+216) 72571295 \n فاكس (+216) 72570125 \n communemenzelabderrahmen@gmail.com \n شارع المنجي سليم 7035 منزل عبد الرحمن',
        PdfTrueTypeFont(fontData, 15),
        bounds: Rect.fromLTWH(-15, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "$NomRes $PrenomRes \n $EmailRes \n بنزرت في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 15),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 255)),
        bounds: Rect.fromLTWH(-200, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "  رقم المطلب:$NumRes".toString(), PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 180, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    // page.graphics.drawString(
    //     "  مطالبة من نوع $typeRec".toString(), PdfTrueTypeFont(fontData, 18),

    //     // PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(190, 210, pageSize.width - 100, 200),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.justify,
    //         lineAlignment: PdfVerticalAlignment.middle,
    //         textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "  السيد ,السيدة  $NomRes $PrenomRes ,صاحب بطاقة تعريف وطنية عدد $cinRes  "
            .toString(),
        PdfTrueTypeFont(fontData, 15),
        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(60, 220, pageSize.width - 100, 200),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "لقد تلقينا طلبك للاتصال بالشبكات العامة  من نوع $typeRes.نحاول الرد عليك في أقرب وقت ممكن.\n يمكنك تتبع مطالبتك من خلال رقم $NumRes هذا للبقاء على اتصال مع الجميع. \nمن فضلك استقبل ، سيدتي ، أو سيدي ، $NomRes $PrenomRes  أطيب تحياتنا."
            .toString(),
        PdfTrueTypeFont(fontData, 15),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 240, pageSize.width - 100, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "يرجى احضار هذه الوثيقة الى البلدية مع الاوراق التالية لاتمام الاجراءات"
            .toString(),
        PdfTrueTypeFont(fontData, 15),
        pen: PdfPen(PdfColor(255, 0, 0)),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(50, 350, pageSize.width - 100, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "مطلب باسم السيدة رئيسة البلدية معرف بالامضاء في صورة اكثر من مالك" +
            "\n شهادة ملكية او عقد بيع",
        PdfTrueTypeFont(fontData, 13),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(50, 380, pageSize.width - 100, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        " بلدية منزل عبد الرحمان".toString(), PdfTrueTypeFont(fontData, 13),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(30, 550, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(300, 0, 255), width: 0),
        bounds: Rect.fromLTWH(30, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NumRes $PrenomRes.pdf');
    NumRes = "";
  }
   Future<void> _createPDFArabeForBatir(String NumAutor) async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(400, 0, 100, 100));
    page.graphics.drawString(
        'بلدية منزل عبد الرحمن \n هاتف (+216) 72570125 / (+216) 72571295 \n فاكس (+216) 72570125 \n communemenzelabderrahmen@gmail.com \n شارع المنجي سليم 7035 منزل عبد الرحمن',
        PdfTrueTypeFont(fontData, 14),
        bounds: Rect.fromLTWH(-15, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "$NomAutor $PrenomAutor \n $EmailAutor \n بنزرت في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 14),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 255)),
        bounds: Rect.fromLTWH(-200, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "  رقم طلب تصريح البناء :$NumAutor " + "\n طلب تصريح البناء".toString(),
        PdfTrueTypeFont(fontData, 14),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 180, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "  السيد ,السيدة  $NomAutor $PrenomAutor ,صاحب بطاقة تعريف وطنية عدد $cinAutor  "
            .toString(),
        PdfTrueTypeFont(fontData, 14),
        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(60, 210, pageSize.width - 100, 200),
        pen: PdfPen(PdfColor(20, 0, 255), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " \nلقد تلقينا طلب تصريح البناء الخاص بك" +
            ".نحاول الرد عليك في أقرب وقت ممكن. \n  يمكنك تتبع مطالبتك من خلال رقم $NumAutor هذا للبقاء على اتصال مع الجميع. \n من فضلك استقبل ، سيدتي ، أو سيدي ، $NomAutor  $PrenomAutor  أطيب تحياتنا."
                .toString(),
        PdfTrueTypeFont(fontData, 14),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(50, 250, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "يرجى إحضار هذه الوثيقة الى مقر البلدية مع الأوراق التالية لإتمام الإجراءات"
            .toString(),
        PdfTrueTypeFont(fontData, 14),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        pen: PdfPen(PdfColor(255, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(50, 320, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "مطلب بإسم السيدة رئيسة البلدية معرف بالإمضاء في صورة أكثر من مالك" +
            "\nشهادة ملكية أو عقد بيع" +
            "\n 5 أمثلة هندسية" +
            "\n شهادة خلاص الاداءات المتعلقة بالأرض أو العقار موضوع طلب الرخصة" +
            "\nالدخل السنوي أو بطاقة إقامة بالخارج".toString(),
        PdfTrueTypeFont(fontData, 12),
        bounds: Rect.fromLTWH(50, 350, pageSize.width - 100, 300),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(300, 0, 255), width: 0),
        bounds: Rect.fromLTWH(30, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
    NumAutor = "";
  }

Future<void> _createPDFArabe(String NumRec) async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(400, 0, 100, 100));
    page.graphics.drawString(
        'بلدية منزل عبد الرحمن \n هاتف (+216) 72570125 / (+216) 72571295 \n فاكس (+216) 72570125 \n communemenzelabderrahmen@gmail.com \n شارع المنجي سليم 7035 منزل عبد الرحمن',
        PdfTrueTypeFont(fontData, 18),
        bounds: Rect.fromLTWH(-15, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "$NomRec $PrenomRec \n $EmailRec \n بنزرت في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0.5),
        bounds: Rect.fromLTWH(-200, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "  رقم الشكوى:$NumRec", PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 180, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    // page.graphics.drawString(
    //     "  مطالبة من نوع $typeRec".toString(), PdfTrueTypeFont(fontData, 18),

    //     // PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(190, 210, pageSize.width - 100, 200),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.justify,
    //         lineAlignment: PdfVerticalAlignment.middle,
    //         textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "  السيد ,السيدة  $NomRec $PrenomRec ,صاحب بطاقة تعريف وطنية عدد $cinRec  "
            .toString(),
        PdfTrueTypeFont(fontData, 18),
        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(60, 210, pageSize.width - 100, 200),
        pen: PdfPen(PdfColor(20, 0, 255), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " \n لقد تلقينا شكواك من نوع $type.نحاول تصحيح المشكلة في أقرب وقت ممكن. \n \n يمكنك تتبع مطالبتك من خلال رقم $NumRec هذا للبقاء على اتصال مع الجميع. \n \n من فضلك استقبل ، سيدتي ، أو سيدي ، $NomRec $PrenomRec  أطيب تحياتنا."
            .toString(),
        PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(50, 280, pageSize.width - 60, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(300, 0, 255), width: 0),
        bounds: Rect.fromLTWH(30, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRec$PrenomRec.pdf');
    NumRec = "";
  }
Future<void> _createPDF(String NumRec) async {
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
        bounds: Rect.fromLTWH(100, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "$NomRec $PrenomRec \n $EmailRec \n Bizerte le " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0.5),
        bounds: Rect.fromLTWH(300, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Numéro réclamation: $NumRec",
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 180, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Décharge de réclamation de $type".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 210, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Monsieur/madame $NomRec $PrenomRec titulaire de cin $cinRec "
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(0, 250, pageSize.width - 100, 200),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Nous avons bien récu votre réclamation de type $type \n\n Nous essayons de corriger le problème dés que possible . \n\n Vous pouvez suivre votre réclamation a travers ce numéro $NumRec pour restez en contact de tous. \n\n Veuillez recevoir, Madame, ou Monsieur, $NomRec $PrenomRec nos salutations distinguées."
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(0, 300, pageSize.width - 100, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRec$PrenomRec.pdf');
    NumRec = "";
  }
  

  
  Future<void> _createPDFBatir(String NumAutor) async {
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
        bounds: Rect.fromLTWH(100, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "$NomAutor $PrenomAutor \n $EmailAutor \n Manzel Abderrahmen  le " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0.5),
        bounds: Rect.fromLTWH(270, 90, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Numéro dossier: $NumAutor".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 180, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Décharge de demande d'autorisation de batir".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 200, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Monsieur/madame $NomAutor $PrenomAutor titulaire de cin $cinAutor".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 230, pageSize.width - 100, 100),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Nous avons bien récu votre demande d'autorisation de batir \nNous essayons de vous répondre dés que possible . Vous pouvez suivre votre demande a travers ce numéro $NumAutor pour restez en contact de tous. \n Veuillez recevoir, Madame, ou Monsieur, $NomAutor $PrenomAutor nos salutations distinguées."
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 14),
        bounds: Rect.fromLTWH(0, 250, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Merci d'apporter ce document à la municipalité accompagné des documents suivants pour terminer les procédures:"
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        pen: PdfPen(PdfColor(255, 0, 0)),
        bounds: Rect.fromLTWH(0, 300, pageSize.width - 100, 400),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "-Une demande au nom de madame le maire ,identifiable par signature sous forme de plus d'un propriétaire \n- Certificat de propriété iu contrat de vente \n- 5 exemple de plan \n-Attestation de libération des paiements afférents au terrain ou à l'immeuble,objet de la demande de licence \n-Revenu annuel ou carte de séjour à l'étranger"
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 430, pageSize.width - 100, 300),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Commune MANZEL ABDERRAHMEN".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(230, 600, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
  NumAutor='';
  }
   // accord fr
  Future<void> _createPDFfrAccord() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(220, 0, 100, 100));

    page.graphics.drawString(
        "République Tunisienne" +
            "\nMinistère de l'Intérieur" +
            "\nProvince de Bizerte" +
            "\nMunicipalité de Manzel Abd al-Rahman",
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            "\n" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Du maire de la municipalité d'Abd al-Rahman A" +
            "\n       Madame/Monsieur $NomAutor $PrenomAutor" +
            "\n        Adresse $AdrAutor".toString(),
        PdfStandardFont(PdfFontFamily.courier, 14),
        pen: PdfPen(PdfColor(0, 0, 255)),
        bounds: Rect.fromLTWH(120, 60, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Sujet: À propos du dossier de permis de construire".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        pen: PdfPen(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 190, pageSize.width - 100, 200));

    page.graphics.drawString(
        "Monsieur/Madame $NomAutor $PrenomAutor titulaire de cin $cinAutor"
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        pen: PdfPen(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 210, pageSize.width - 100, 200));
    page.graphics.drawString(
        "Et après, selon le dossier de permis de construire déposé par vous concernant le bien situé dans la" +
            "maison d'Abd al-Rahman, nous vous informons que votre dossier a été présenté à l'attention de la" +
            "commission technique régionale des permis de construire lors de la séance tenue " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()).toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 200, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Et celle qui a donné son avis: acceptation",
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        pen: PdfPen(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, 240, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Très important", PdfStandardFont(PdfFontFamily.helvetica, 11),
        bounds: Rect.fromLTWH(0, 300, pageSize.width - 60, 200),
        pen: PdfPen(PdfColor(255, 0, 0)),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Vu l'arrêté du ministre de l'équipement, de l'habitat et de l'aménagement du territoire en date du" +
            "17 avril 2007, relatif au contrôle des pièces constituant le dossier de permis de construire, sa" +
            "durée de validité et sa prorogation, les conditions de son renouvellement, et notamment le" +
            "chapitre brut de celui-ci, nous vous invitons à retirer le permis de construire dans un délai" +
            "maximum d'un mois à compter de la date de ce média, faute de quoi il n'est plus valable.",
        PdfStandardFont(PdfFontFamily.helvetica, 11),
        pen: PdfPen(PdfColor(255, 0, 0)),
        bounds: Rect.fromLTWH(0, 350, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Menzel Abderrahman le" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "\n\n    Maire de la municipalité".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(230, 540, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
  }

// rejet demande fr
// accord fr
  Future<void> _createPDFfrRejet(String commentaire) async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(220, 0, 100, 100));

    page.graphics.drawString(
        "République Tunisienne" +
            "\nMinistère de l'Intérieur" +
            "\nProvince de Bizerte" +
            "\nMunicipalité de Manzel Abd al-Rahman",
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            "\n" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Du maire de la municipalité d'Abd al-Rahman A" +
            "\n          Madame/Monsieur $NomAutor $PrenomAutor" +
            "\n          Adresse $AdrAutor".toString(),
        PdfStandardFont(PdfFontFamily.courier, 14),
        pen: PdfPen(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(90, 60, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Sujet: À propos du dossier de permis de construire".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 210, pageSize.width - 60, 200));
    page.graphics.drawString(
        "Monsieur/Madame $NomAutor $PrenomAutor titulaire de cin $cinAutor"
            .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 230, pageSize.width - 60, 200));
    page.graphics.drawString(
        "Et après, selon le dossier de permis de construire déposé par vous concernant le bien situé dans la" +
            "maison d'Abd al-Rahman, nous vous informons que votre dossier a été présenté à l'attention de la" +
            "commission technique régionale des permis de construire lors de la séance tenue " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()).toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 240, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Et celle qui a donné son avis: rejet ",
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 280, pageSize.width - 60, 200),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
 page.graphics.drawString("Pour les raisons suivantes: \n $commentaire ",
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 320, pageSize.width - 60, 200),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "\n\n    Maire de la municipalité".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(230, 540, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
  }

  Future<void> _createPDFArabeAccordBatir() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(200, 0, 100, 100));
    page.graphics.drawString(
        'الجمهورية التونسية\n ولاية بنزرت\n وزارة الداخلية \nبلدية منزل عبد الرحمان ',
        PdfTrueTypeFont(fontData, 10),
        bounds: Rect.fromLTWH(400, -40, 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " منزل عبد الرحمان في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(0, 0, 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "من رئيس(ة) البلدية \n\t\t\tالى\t\t\t\n  السيد ة: $NomAutor $PrenomAutor\n   القاطن(ة)ب: $AdrAutor"
            .toString(),
        PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-90, 80, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(" الموضوع : حول ملف رخصة بناء ".toString(),
        PdfTrueTypeFont(fontData, 15),
        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(280, 210, 200, 100),
        pen: PdfPen(PdfColor(20, 0, 220), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " و بعد تبعا لملف رخصة البناء المقدم من طرفكم حول العقار الموجود بمنزل عبد الرحمان\n نعلمك أنه تم عرض ملفك على نضار اللجنة الفنية الجهوية لرخص البناء\nوالتي ابدت رايها ب :المواقفة"
            .toString(),
        PdfTrueTypeFont(fontData, 12),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(30, 220, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "\n\n\n\n\n\n\nهام جدا \n بناء على قرار السيدة وزيرة التجهيز و الاسكان و التهيئة الترابية المؤرخ في 17 أفريل 2007 \nالمتعلق بضبط الوثائق المكونة لملف رخصة البناء و اجل صلاحيتها و التمديد فيها و شروط تجديدها وخاصة الفصل الخامس منه" +
            "\nفاننا ندعوكم الىتسلم رخصة البناء في أجل اقصاه شهر من تاريخ هذا الاعلام و الا عدت غير سارية المفعول"
                .toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 275, pageSize.width - 60, 200),
        pen: PdfPen(PdfColor(255, 0, 0), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    // page.graphics.drawString(
    //     "فاننا ندعوكم الىتسلم رخصة البناء في أجل اقصاه شهر من تاريخ هذا الاعلام و الا عدت غير سارية المفعول "
    //         .toString(),
    //     PdfTrueTypeFont(fontData, 10),

    //     // PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(50, 300, 400, 200),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.right,
    //         lineAlignment: PdfVerticalAlignment.middle,
    //         textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "منزل عبد الرحمان في :" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-10, 500, 200, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        " رئيس (ة) البلدية".toString(), PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 520, 80, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
    // NumRec = "";
  }

// Refus demande d'autorsation de batir
  Future<void> _createPDFArabeRefusBatir(String commentaire) async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(200, 0, 100, 100));
    page.graphics.drawString(
        'الجمهورية التونسية\n ولاية بنزرت\n وزارة الداخلية \nبلدية منزل عبد الرحمان ',
        PdfTrueTypeFont(fontData, 10),
        bounds: Rect.fromLTWH(400, -40, 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " منزل عبد الرحمان في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(0, 0, 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        "من رئيس(ة) البلدية \n\t\t\tالى\t\t\t\n  السيد ة: $NomAutor  $PrenomAutor \n   القاطن(ة)ب: $AdrAutor"
            .toString(),
        PdfTrueTypeFont(fontData, 18),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-90, 80, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(" الموضوع : حول ملف رخصة بناء ".toString(),
        PdfTrueTypeFont(fontData, 15),
        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        bounds: Rect.fromLTWH(280, 210, 200, 100),
        pen: PdfPen(PdfColor(20, 0, 220), width: 0),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " و بعد تبعا لملف رخصة البناء المقدم من طرفكم حول العقار الموجود بمنزل عبد الرحمان\n نعلمك أنه تم عرض ملفك على نضار اللجنة الفنية الجهوية لرخص البناء" +
            "\nوالتي ابدت رايها بعدم الموافقة للاسباب التالية:" +
            "\n $commentaire".toString(),
        PdfTrueTypeFont(fontData, 12),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(30, 220, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "منزل عبد الرحمان في :" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-10, 500, 200, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        " رئيس (ة) البلدية".toString(), PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 520, 80, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomAutor $PrenomAutor.pdf');
  }
   Future<void> _createPDFArabeAccordSonede() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(200, 0, 100, 100));
    page.graphics.drawString(
        'الجمهورية التونسية\n ولاية بنزرت\n وزارة الداخلية \nبلدية منزل عبد الرحمان ',
        PdfTrueTypeFont(fontData, 10),
        bounds: Rect.fromLTWH(400, -40, 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " منزل عبد الرحمان في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(0, 0, 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString("ترخيص في ادخال الماء الصالح للشراب".toString(),
        PdfTrueTypeFont(fontData, 18),
        pen: PdfPen(PdfColor(255, 0, 0)),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-60, 45, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "ان رئيس ة بلدية عبد الرحمان بعد اطلاعها على المطلب الذي تقدم به السيد $PrenomRes $NomRes لتزويد محله ها الكائن ب $AdrRes بالماء الصالح للشرب من طرف الشركة الوطنية لاستغلال و توزيع المياه\nوتبعا للجلسة المحلية لاسناد تراخيص الربط بالشبكات العمومية للبناءات المشيدة بدون ترخيص المنعقدة بمقر بلدية منزل عبد الرحمان بتاريخ 23 ديسمبر  2021" +
            "\n واستنادا لمصادقة السيد والي بنزرت بتاريخ 02 جانفي 2021 وجدول ارسال الولاية عدد13/972 بتاريخ 04 فيفري 2022" +
            "\nو بعد تبعا لمحضر جلسة اللجنة المحلية لاسناد تراخيص الربط بشبكتي الماء الصالح للشراب و النور الكهربائي" +
            "\nيرخص للسيد (ة) $PrenomRes $NomRes في ربط محله (ها) المذكور بالشبكة العمومية لتوزيع المياه " +
            "\nسلمت هذه الشهادة للادلاء بها لدى مصالح الشركة الوطنية لاستغلال  و توزيع  المياه"
                .toString(),
        PdfTrueTypeFont(fontData, 12),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(30, 250, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "منزل عبد الرحمان في :" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-10, 500, 200, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        " رئيس (ة) البلدية".toString(), PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 520, 80, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRes $PrenomRes .pdf');
  }

  // accord brachement éléctricité
  Future<void> _createPDFArabeAccordSteg() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    List<int> fontData = await _readData('arabic.ttf');
    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(200, 0, 100, 100));
    page.graphics.drawString(
        'الجمهورية التونسية\n ولاية بنزرت\n وزارة الداخلية \nبلدية منزل عبد الرحمان ',
        PdfTrueTypeFont(fontData, 10),
        bounds: Rect.fromLTWH(400, -40, 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        " منزل عبد الرحمان في " +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 15),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(0, 0, 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString("ترخيص في ادخال الإنارة العامة".toString(),
        PdfTrueTypeFont(fontData, 18),
        pen: PdfPen(PdfColor(255, 0, 0)),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-60, 45, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "ان رئيس ة بلدية عبد الرحمان بعد اطلاعها على المطلب الذي تقدم به السيد $PrenomRes $NomRes لتزويد محله ها الكائن ب $AdrRes بالانارة العامة من طرف الشركة التونسية للكهرباء والغاز\nوتبعا للجلسة المحلية لاسناد تراخيص الربط بالشبكات العمومية للبناءات المشيدة بدون ترخيص المنعقدة بمقر بلدية منزل عبد الرحمان بتاريخ 23 ديسمبر  2021" +
            "\n واستنادا لمصادقة السيد والي بنزرت بتاريخ 02 جانفي 2021 وجدول ارسال الولاية عدد13/972 بتاريخ 04 فيفري 2022" +
            "\nو بعد تبعا لمحضر جلسة اللجنة المحلية لاسناد تراخيص الربط بشبكتي الماء الصالح للشراب و النور الكهربائي" +
            "\nيرخص للسيد (ة) $PrenomRes $NomRes في ربط محله (ها) المذكور ب شبكة توزيع الكهرباء  " +
            "\nسلمت هذه الشهادة للادلاء بها لدى مصالح الشركة التونسية للكهرباء والغاز"
                .toString(),
        PdfTrueTypeFont(fontData, 12),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(30, 250, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    page.graphics.drawString(
        "منزل عبد الرحمان في :" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "".toString(),
        PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(-10, 500, 200, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));
    page.graphics.drawString(
        " رئيس (ة) البلدية".toString(), PdfTrueTypeFont(fontData, 10),

        // PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(60, 520, 80, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
            textDirection: PdfTextDirection.rightToLeft));

    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRes $PrenomRes .pdf');
  }

  // approbation demande d'eclairage public
  Future<void> _createPDFfrAccordSteg() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(220, 0, 100, 100));

    page.graphics.drawString(
        "République Tunisienne" +
            "\nMinistère de l'Intérieur" +
            "\nProvince de Bizerte" +
            "\nMunicipalité de Manzel Abd al-Rahman",
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            "\n" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Autorisation d'ammenr d'éclairage public".toString(),
        PdfStandardFont(PdfFontFamily.courier, 14),
        pen: PdfPen(PdfColor(255, 0, 0)),
        bounds: Rect.fromLTWH(80, 60, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Le maire de Menzel Abderrahmane, après examen de la demande présentée par M./Mme $NomRes" +
            "$PrenomRes, d'approvisionner son commerce situé en $AdrRes en eclairage publicde la" +
            "Société tunisienne de l`électricité et du gaz".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 130, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Et selon la session locale d'attribution des licences de raccordement aux réseaux publics pour les" +
            "bâtiments construits sans licence, tenue au siège de la municipalité de Manzil Abd al-Rahman le" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()).toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 200, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Et sur la base de l'approbation de M. Gouverneur de Bizerte en date du 2022-07-23 et du" +
            "bordereau d'expédition de l'etat n° 13/972 en date du 2022-09-23"
                .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 250, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Autorisé à M.Mme $NomRes $PrenomRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 300, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Raccordement de ses locaux précités au réseau public de réseau public de distribution" +
            "de l`électricité\n" +
            "Ce certificat a été délivré aux intérêts de la Société tunisienne de l`électricité et du gaz" +
            "Numéro dossier: $NumRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 350, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "\n         Maire de la municipalité".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(230, 540, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRes $PrenomRes.pdf');
  }

 Future<void> _createPDFfrAccordSonede() async {
    PdfDocument document = PdfDocument();

    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    // page.graphics.drawString('Inscription autorisation de batir',
    //     PdfStandardFont(PdfFontFamily.helvetica, 30));
//Create a PDF page template and add header content.

    page.graphics.drawImage(PdfBitmap(await _readImageData('commune.jpg')),
        Rect.fromLTWH(220, 0, 100, 100));

    page.graphics.drawString(
        "République Tunisienne" +
            "\nMinistère de l'Intérieur" +
            "\nProvince de Bizerte" +
            "\nMunicipalité de Manzel Abd al-Rahman",
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            "\n" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()),
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 100, 100),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString("Autorisation d'ammenr d'eau potable".toString(),
        PdfStandardFont(PdfFontFamily.courier, 14),
        pen: PdfPen(PdfColor(255, 0, 0)),
        bounds: Rect.fromLTWH(80, 60, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Le maire de Menzel Abderrahmane, après examen de la demande présentée par M./Mme $NomRes" +
            "$PrenomRes, d'approvisionner son commerce situé en $AdrRes en eau potable la" +
            "nationale d`exploitation et de distribution des eaux .".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 130, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Et selon la session locale d'attribution des licences de raccordement aux réseaux publics pour les" +
            "bâtiments construits sans licence, tenue au siège de la municipalité de Manzil Abd al-Rahman le" +
            DateFormat("dd/MM/yyyy")
                .format(DateTime.now())
                .toString()
                .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 200, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Et sur la base de l'approbation de M. Gouverneur de Bizerte en date du 2022-07-23 et du" +
            "bordereau d'expédition de l'etat n° 13/972 en date du 2022-09-23"
                .toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 250, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawString(
        "Autorisé à M.Mme $NomRes $PrenomRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 300, pageSize.width - 600, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Raccordement de ses locaux précités au réseau public de réseau public de distribution d`eau\n" +
            "Ce certificat a été délivré aux intérêts de la Société nationale d`exploitation et de distribution des eaux" +
            "Numéro dossier: $NumRes".toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 13),
        bounds: Rect.fromLTWH(0, 350, pageSize.width - 60, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "Menzel Abderrahman le" +
            DateFormat("dd/MM/yyyy").format(DateTime.now()) +
            "\n    Maire de la municipalité".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 0), width: 0),
        bounds: Rect.fromLTWH(230, 540, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawString(
        "http://www.commune-menzel-abderrahmen.gov.tn".toString(),
        PdfStandardFont(
          PdfFontFamily.helvetica,
          12,
        ),
        pen: PdfPen(PdfColor(0, 0, 255), width: 0),
        bounds: Rect.fromLTWH(230, 650, pageSize.width - 100, 200),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.justify,
            lineAlignment: PdfVerticalAlignment.middle));
    List<int> bytes = document.save();

    document.dispose();

    saveAndLaunchFile(bytes, '$NomRes $PrenomRes.pdf');
  }

}

Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load('assets/images/$name');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
 Future<List<int>> _readData(String name) async {
final ByteData data = await rootBundle.load('assets/fonts/$name');
return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
  

