import 'package:cetalks/global.dart';
import 'package:cetalks/news_corner/pages/news_corner_page.dart';
import 'package:cetalks/providers/auth_provider.dart';
import 'package:cetalks/screens/team_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import './screens/confessions.dart';
import './screens/dedications.dart';
import './screens/episodedetail.dart';
import './screens/myhomepage.dart';
import './screens/nowplaying.dart';
import './screens/programs.dart';
import './screens/tellus.dart';
import './utils/theme.dart';

void main() async {
  try {
    final response = await http.head(Uri.parse(Config.streemlionUrl));

    print(response.statusCode);
    if (response.statusCode == 200) {
      Config.isLiveUrlAvailable = true;
    }
    print(Config.liveUrl);
  } catch (e) {
    print(e);
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(App());
}

class App extends StatelessWidget {
  // Create the initilization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: Text("An error occured"),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else {
          return ChangeNotifierProvider(
              create: (context) => AuthProvider(), child: MyApp());
        }
      },
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //checkUpdates();
    initFirebaseCrashlytics();
  }

  /// initialise firebase crashlytics services
  Future initFirebaseCrashlytics() async {
    Function? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError!(errorDetails);
    };
    FirebaseCrashlytics.instance.sendUnsentReports();
    if (kDebugMode) {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CETalks',
      theme: cetalksTheme,
      home: MyHomePage(),
      routes: {
        TeamViewScreen.routeName: (ctx) => TeamViewScreen(),
        ConfessionsPage.routeName: (ctx) => ConfessionsPage(),
        DedicationsPage.routeName: (ctx) => DedicationsPage(),
        Programs.routeName: (ctx) => Programs(),
        TellUs.routeName: (ctx) => TellUs(),
        EpisodeDetail.routeName: (ctx) => EpisodeDetail(),
        NowPlayingScreen.routeName: (ctx) => NowPlayingScreen(),
        NewsCornerPage.routeName: (ctx) => NewsCornerPage()
      },
    );
  }
}
