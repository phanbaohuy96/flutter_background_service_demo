import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    final dynamic data = message['data'];
    print('data $data');
  }

  if (message.containsKey('notification')) {
    final dynamic notification = message['notification'];
    print('notification $notification');
  }

  print('message $message');
}

void main() {
  runApp(MyApp());
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

class _MyHomePageState extends State<MyHomePage> {
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
      onBackgroundMessage: myBackgroundMessageHandler,
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
