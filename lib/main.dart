import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:speech_recognition/speech_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      TextEditingController,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController msg = TextEditingController();
  late SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String _currentLocale ="en-US";

  String resultText = "";
    String reponseText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }
  Future<void> getrep(String txt) async{
    print("ok");
    var dataForm = {
                             "message": txt,
                           };
var response = await Dio().post(
                            "http://192.168.1.9:5050/predict",
                            options: Options(
                              headers: {
                                Headers.contentTypeHeader: 'application/json',
                                Headers.acceptHeader: 'application/json'
                               },
                             ),
                             data: dataForm,
                           
                          );
                     reponseText = response.data;    
                        
                        
                        
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
       (String speech) => setState(() => resultText = speech),
     
    );
    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                child: const Icon(Icons.cancel),
                mini: true,
                backgroundColor: Colors.deepOrange,
                onPressed: () {
                  if (_isListening) {
                    _speechRecognition.cancel().then(
                          (result) => setState(() {
                                _isListening = result;
                                resultText = "";
                                reponseText ="";
                              }),
                        );
                  }
                },
              ),
              FloatingActionButton(
                child: const Icon(Icons.mic),
                onPressed: ()  {
                  if (_isAvailable && !_isListening) {
                    _speechRecognition
                        .listen(locale:_currentLocale)
                        // ignore: avoid_print
                        .then((result) => print('$result'));
                
                  
                  }
                },
                backgroundColor: Colors.pink,
              ),
              FloatingActionButton(
                // ignore: prefer_const_constructors
                child: Icon(Icons.stop),
                mini: true,
                backgroundColor: Colors.deepPurple,
                onPressed: ()  {
                                    getrep(resultText);

                  if (_isListening) {
                     
                    _speechRecognition.stop().then(
                          (result) => setState(() => _isListening = result),             
                        );

                  }
                  
                },
                
              ),
            
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.cyanAccent[100],
              borderRadius: BorderRadius.circular(6.0),
            ),
            // ignore: prefer_const_constructors
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Text(
              resultText,
              style: const TextStyle(fontSize: 24.0),
            ),
           
          ),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.cyanAccent[100],
              borderRadius: BorderRadius.circular(6.0),
            ),
            // ignore: prefer_const_constructors
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Text(
               reponseText,
              style: const TextStyle(fontSize: 24.0),
              
            ),
           
          )
        ],
      ),
    );
  }
}