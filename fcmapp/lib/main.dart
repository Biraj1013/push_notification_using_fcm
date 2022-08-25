import 'package:fcmapp/model/pushnotification_model.dart';
import 'package:fcmapp/notification_badge.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //initialize some values
  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;

  //model
  PushNotification? _notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    //instance for firebse messaging
    _messaging = FirebaseMessaging.instance;

    //three tyep of state in notification
    //not determined (null),granted(true) and decline(false)

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted the permission");
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //saving the pushNoitification to the model
        //remote message is the message from firebase server
        PushNotification notification = PushNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            dataTitle: message.data['title'],
            dataBody: message.data["body"]);
        setState(() {
          _totalNotificationCounter++;
          _notificationInfo = notification;
        });
        if (notification != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadege(
                totalNotification: _totalNotificationCounter),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: const Duration(seconds: 2),
          );
        }
      });
    } else {
      print("permission not access");
    }
  }

//check the initial message that we receivw
  checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
          title: initialMessage.notification!.title,
          body: initialMessage.notification!.body,
          dataTitle: initialMessage.data['title'],
          dataBody: initialMessage.data["body"]);
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }

  @override
  void initState() {
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data["body"]);
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    });
    //normal notification
    registerNotification();
    //when app is in terminated state
    checkForInitialMessage();
    _totalNotificationCounter = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Push Notification using FCM",
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          )),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            "Flutter Push Notification using FCM",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          //showing a notification badge white will
          // count the total notification that we rwceive
          const SizedBox(
            height: 10,
          ),
          NotificationBadege(totalNotification: _totalNotificationCounter),
          //if notificationInfo is no null
          const SizedBox(
            height: 30,
          ),
          _notificationInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "TITLE:${_notificationInfo!.dataTitle ?? _notificationInfo!.title}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "BODY:${_notificationInfo!.dataBody ?? _notificationInfo!.body}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  ],
                )
              : Container(),
        ]),
      ),
    );
  }
}
