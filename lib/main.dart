import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo')),
      body: DetectInformation(),
    );
  }
}

class DetectInformation extends StatefulWidget {
  const DetectInformation({Key? key}) : super(key: key);

  @override
  State<DetectInformation> createState() => _DetectInformationState();
}

class _DetectInformationState extends State<DetectInformation> {

  final Stream<QuerySnapshot> _detectStream =
      FirebaseFirestore.instance.collection('DetectEquit').snapshots();

  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double rate =0.5;
  bool isCurrentLanguageInstalled = false;

  @override
  initState() {
    super.initState();
    initTts();
    FirebaseFirestore.instance.collection("DetectEquit").doc("0013a20041a72946")
       .snapshots().listen((event)=> _speak());
    FirebaseFirestore.instance.collection("DetectEquit").doc("0013a20041a713b4")
        .snapshots().listen((event)=> _speak2());
  }
  initTts() {
    flutterTts = FlutterTts();
    _getDefaultEngine();
    _getDefaultVoice();

  }
  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }
  Future _speak() async{
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setVolume(volume);

    var result = await flutterTts.speak("six meter");
  }
 Future _speak2() async{
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setVolume(volume);

    var result = await flutterTts.speak("three meter");
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _detectStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }


        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            print(data);

            return ListTile(

              tileColor: Colors.red,
              title: Text(data['adresse_mac_remote64_xbee']),
              subtitle:
                  Text(data['distance'] != null ? data['distance'].toString() : "Unknown"),

            );
          }).toList(),
        );
      },
    );
  }
}
