import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  String answer = "Hello i'm me7rzeya";
  stt.SpeechToText _speech=stt.SpeechToText();
   String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  bool _isListening = false;
 @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return MaterialApp(
          TextEditingController,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Voice chatbot'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(answer),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      hintText: 'Enter your message',
                      labelText: 'Message',
                    ),
                    controller: msg,
                    validator: (message) {
                      if (message!.isEmpty) {
                        return 'Message required';
                      }
                      return null;
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 150.0, top: 40.0),
                    child: ElevatedButton(
                      onPressed: _listen,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      // onPressed: () async {
                      //   if (_formKey.currentState!.validate()) {
                        

                      //     var dataForm = {
                      //       "message": msg.text,
                      //     };

                      //     var response = await Dio().post(
                      //       "http://192.168.1.9:5050/predict",
                      //       options: Options(
                      //         headers: {
                      //           Headers.contentTypeHeader: 'application/json',
                      //           Headers.acceptHeader: 'application/json'
                      //         },
                      //       ),
                      //       data: dataForm,
                      //     );

                      //     //Return response
                      //     if (response.statusCode == 200) {
                      //       //Refresh answer
                      //       setState(() {
                      //         answer = response.data;
                      //         msg.text = "";
                      //       });
                      //     }
                      //   }
                      // },
                      // child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}