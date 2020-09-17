import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<dynamic> backgroundMessageHandler(Map<String, dynamic> message) async {
  print("coming");
  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Box box = await Hive.openBox("fcm");
  box.put("fcm", "from Hive ${message.toString()}");
  print("hello world");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await handleBox();
  runApp(MyApp());
}

Future<void> handleBox() async {
  Box box = await Hive.openBox("fcm");
  print("fcm........");
  print(box.get("fcm"));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String messageEvent;
  Map<String, dynamic> messageData;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (mounted) {
          setState(() {
            messageData = message;
            messageEvent = 'onMessage';
          });
        }
        print("onMessage: $message");
      },
      onBackgroundMessage: backgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        if (mounted) {
          setState(() {
            messageData = message;
            messageEvent = 'onLaunch';
          });
        }
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (mounted) {
          setState(() {
            messageData = message;
            messageEvent = 'onResume';
          });
        }
        print("onResume: $message");
      },
    );
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  String get _messageDataJson {
    JsonEncoder encoder = new JsonEncoder.withIndent('\t\t\t\t');
    String prettyprint = encoder.convert(messageData ?? "");
    return prettyprint;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Event: $messageEvent',
            ),
            Text(
              '$_messageDataJson',
            ),
          ],
        ),
      ),
    );
  }
}
