import 'package:audio_service/audio_service.dart';
import 'package:cetalks/global.dart';
import 'package:cetalks/screens/newplayer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initFirebaseMessaging();
    updateAudio();
  }

  /// intialize firebase cloud messaging services
  initFirebaseMessaging() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null && initialMessage.data['type'] == 'news') {
      return Navigator.pushNamed(context, '/news');
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'news') {
        Navigator.pushNamed(context, '/news');
      }
    });
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.subscribeToTopic('news');
    FirebaseMessaging.onMessage.listen((event) {
      print(event);
    });
    FirebaseMessaging.onBackgroundMessage((message) =>
        Future.delayed(Duration(seconds: 1)).then((value) => print(message)));

    _firebaseMessaging.getToken().then((value) => print("TOKEN" + value!));
  }

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(child: Player());
  }

  void updateAudio() async {
    if (Config.isLiveUrlAvailable) {
      //  print( AudioService.connected);
      //  await AudioService.updateMediaItem(mediaItem)
      //   await AudioServiceBackground.setMediaItem(Config.liveMedia);
      //   print('UPDATED MEDIA');
    }
  }
}
