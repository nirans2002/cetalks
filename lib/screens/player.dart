


/// OLD VERSIONS





// import 'package:audio_service/audio_service.dart';
// import 'package:cetalks/screens/news.dart';
// import 'package:cetalks/widgets/newaudioplayertask.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sleek_circular_slider/sleek_circular_slider.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:volume/volume.dart';

// import '../global.dart';
// //import '../widgets/audioplayertask.dart';
// import '../widgets/mydrawer.dart';
// import '../widgets/pastep.dart';

// class Player extends StatefulWidget {
//   @override
//   _PlayerState createState() => _PlayerState();
// }

// class _PlayerState extends State<Player> {
//   var latest = '';
//   var first = false;
//   @override
//   void initState() {
//     super.initState();
//     initPlatformState(AudioManager.STREAM_MUSIC);
//     _latestDoc();
//   }

//   _latestDoc() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       latest = prefs.getString('latest');
//     });
//     print(latest);
//   }

//   void setVol(int i) async {
//     if (first) return;
//     await Volume.setVol(i, showVolumeUI: ShowVolumeUI.HIDE);
//   }

//   Future<void> initPlatformState(AudioManager am) async {
//     await Volume.controlVolume(am);
//   }

//   PanelController _pc = PanelController();
//   var currentBackPressTime;

//   Future<bool> onWillPop() {
//     DateTime now = DateTime.now();

//     if (currentBackPressTime == null ||
//         now.difference(currentBackPressTime) > Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       if (_pc.isPanelOpen) {
//         _pc.close();
//         _pc.show();
//       }

//       Fluttertoast.showToast(
//         msg: 'Press back again to exit',
//       );
//       return Future.value(false);
//     }
//     return Future.value(true);
//   }

//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onWillPop,
//       child: AudioServiceWidget(
//         child: SafeArea(
//           child: Scaffold(
//             appBar: AppBar(
//               centerTitle: true,
//               title: Text(
//                 'CETALKS',
//               ),
//               textTheme: Theme.of(context).appBarTheme.textTheme,
//               actions: [
//                 SizedBox(width: 8),
//                 StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('news')
//                         .orderBy('time', descending: true)
//                         .limit(1)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting ||
//                           !snapshot.hasData) {
//                         return IconButton(
//                             onPressed: () {
//                               Navigator.of(context)
//                                   .pushNamed(NewsScreen.routeName)
//                                   .whenComplete(() {
//                                 _latestDoc();
//                               });
//                             },
//                             padding: EdgeInsets.only(right: 15),
//                             icon: Icon(Icons.notifications_none));
//                       } else {
//                         QuerySnapshot query = snapshot.data;
//                         List<DocumentSnapshot> docs = query.docs;
//                         if (docs.isEmpty)
//                           return IconButton(
//                               onPressed: () {
//                                 Navigator.of(context)
//                                     .pushNamed(NewsScreen.routeName)
//                                     .whenComplete(() {
//                                   _latestDoc();
//                                 });
//                               },
//                               padding: EdgeInsets.only(right: 15),
//                               icon: Icon(Icons.notifications_none));
//                         var doc = docs[0];
//                         var newLatest = doc.id;
//                         if (newLatest == latest) {
//                           return IconButton(
//                             onPressed: () {
//                               Navigator.of(context)
//                                   .pushNamed(NewsScreen.routeName)
//                                   .whenComplete(() {
//                                 print('running');
//                                 _latestDoc();
//                               });
//                             },
//                             padding: EdgeInsets.only(right: 15),
//                             icon: Icon(Icons.notifications_none),
//                           );
//                         } else {
//                           return Stack(
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   Navigator.of(context)
//                                       .pushNamed(NewsScreen.routeName)
//                                       .whenComplete(() {
//                                     _latestDoc();
//                                   });
//                                 },
//                                 padding: EdgeInsets.only(right: 15),
//                                 icon: Icon(Icons.notifications),
//                               ),
//                               Positioned(
//                                 right: 20,
//                                 top: 11,
//                                 child: new Container(
//                                   padding: EdgeInsets.all(2),
//                                   decoration: new BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   constraints: BoxConstraints(
//                                     minWidth: 11,
//                                     minHeight: 11,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         }
//                       }
//                     }),
//               ],
//             ),
//             drawer: MyDrawer(),
//             backgroundColor: Theme.of(context).primaryColor,
//             body: SlidingUpPanel(
//               controller: _pc,
//               collapsed: GestureDetector(
//                 onTap: () {
//                   _pc.open();
//                 },
//                 child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: 55,
//                     decoration: BoxDecoration(
//                         color: Colors.grey[900],
//                         borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(25),
//                             topLeft: Radius.circular(25))),
//                     child: Center(
//                         child: Column(
//                       children: <Widget>[
//                         Icon(
//                           Icons.expand_less,
//                           color: Theme.of(context).accentColor,
//                         ),
//                         Text(
//                           'Our Podcasts',
//                           style: GoogleFonts.lato(
//                               color: Theme.of(context).accentColor),
//                         ),
//                       ],
//                     ))),
//               ),
//               header: Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: 80,
//                   decoration: BoxDecoration(
//                       color: Colors.grey[900],
//                       borderRadius: BorderRadius.only(
//                           topRight: Radius.circular(25),
//                           topLeft: Radius.circular(25))),
//                   child: Center(
//                       child: Column(
//                     children: <Widget>[
//                       Icon(
//                         Icons.expand_more,
//                         color: Theme.of(context).accentColor,
//                       ),
//                       Text(
//                         'Our Podcasts',
//                         style: GoogleFonts.lato(
//                             color: Theme.of(context).accentColor),
//                       ),
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Text(
//                         'Missed the livestream? Catch up here',
//                         style: TextStyle(
//                             color: Theme.of(context).accentColor,
//                             fontWeight: FontWeight.w300),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       )
//                     ],
//                   ))),
//               minHeight: 55,
//               maxHeight: MediaQuery.of(context).size.height,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(28), topRight: Radius.circular(28)),
//               panel: Center(child: buildPastEpisodes(context)),
//               body: RefreshIndicator(
//                 onRefresh: () => AudioService.stop(),
//                 //stack plus listview is used to enable refreshindicator
//                 child: Center(
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: <Widget>[
//                       ListView(),
//                       Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: <Widget>[
//                             Stack(
//                               alignment: Alignment.center,
//                               children: <Widget>[
//                                 Container(
//                                   width: 150,
//                                   child: const Image(
//                                     image:
//                                         AssetImage('assets/images/cetalks.png'),
//                                   ),
//                                 ),
//                                 SleekCircularSlider(
//                                   appearance: CircularSliderAppearance(
//                                       size: 220,
//                                       customWidths: CustomSliderWidths(
//                                           handlerSize: 8.5,
//                                           progressBarWidth: 5),
//                                       customColors: CustomSliderColors(
//                                           trackColor: Colors.grey,
//                                           shadowColor: Colors.white,
//                                           progressBarColor: Colors.white),
//                                       angleRange: 360,
//                                       startAngle: 270),
//                                   initialValue: 40.12345,
//                                   min: 0,
//                                   max: 100,
//                                   onChangeStart: (double start) {
//                                     if (start < 0.00001) {
//                                       first = true;
//                                     } else {
//                                       first = false;
//                                     }
//                                   },
//                                   onChange: (vol) async {
//                                     var maxVol = await Volume.getMaxVol;

//                                     var k =
//                                         (vol.floor() * (maxVol / 100)).toInt() +
//                                             1;
//                                     if (vol != 40.12345) {
//                                       setVol(k);
//                                     }
//                                   },
//                                   innerWidget: (_) {
//                                     return StreamBuilder<ScreenState>(
//                                         stream: _screenStateStream,
//                                         builder: (context, snapshot) {
//                                           final streamMedia = [
//                                             MediaItem(
//                                                 id: liveUrl,
//                                                 album: " ",
//                                                 title: "CETALKS",
//                                                 artUri:
//                                                     'https://firebasestorage.googleapis.com/v0/b/cetalks-new.appspot.com/o/cetalks.png?alt=media&token=f5f4b5c9-c481-49a3-8858-a578668d1d84')
//                                           ];
//                                           final screenState = snapshot.data;

//                                           final state =
//                                               screenState?.playbackState;
//                                           final processingState =
//                                               state?.processingState ??
//                                                   AudioProcessingState.none;

//                                           final playing =
//                                               state?.playing ?? false;
//                                           return Container(
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: <Widget>[
//                                                 if (processingState ==
//                                                         AudioProcessingState
//                                                             .none ||
//                                                     processingState ==
//                                                         AudioProcessingState
//                                                             .stopped) ...{
//                                                   Center(
//                                                     child: IconButton(
//                                                       icon: Icon(
//                                                         Icons.play_arrow,
//                                                       ),
//                                                       iconSize: 110.0,
//                                                       color: Theme.of(context)
//                                                           .accentColor,
//                                                       onPressed: () async {
//                                                         var connectivityResult =
//                                                             await (Connectivity()
//                                                                 .checkConnectivity());
//                                                         if (connectivityResult ==
//                                                                 ConnectivityResult
//                                                                     .none ||
//                                                             liveUrl == null) {
//                                                           Fluttertoast.cancel();
//                                                           Fluttertoast.showToast(
//                                                               msg:
//                                                                   'You are not connected to internet');
//                                                           return;
//                                                         }
//                                                         print(liveUrl);
//                                                         Fluttertoast.showToast(
//                                                             msg: 'Buffering..');

//                                                         try {
//                                                           await AudioService
//                                                               .start(
//                                                             androidStopForegroundOnPause:
//                                                                 true,
//                                                             backgroundTaskEntrypoint:
//                                                                 _audioPlayerTaskEntrypoint,
//                                                             androidNotificationChannelName:
//                                                                 'CETalks',
//                                                             androidNotificationColor:
//                                                                 0x00000000,
//                                                             androidNotificationIcon:
//                                                                 'mipmap/ic_launcher',
//                                                             androidEnableQueue:
//                                                                 true,
//                                                           );
//                                                           await AudioService
//                                                               .updateQueue(
//                                                                   streamMedia);
//                                                         } catch (e, s) {
//                                                           print(e);
//                                                           FirebaseCrashlytics
//                                                               .instance
//                                                               .recordError(e, s,
//                                                                   reason:
//                                                                       'STARTING AUDIO');

//                                                           ScaffoldMessenger.of(
//                                                                   context)
//                                                               .showSnackBar(
//                                                             SnackBar(
//                                                               backgroundColor:
//                                                                   Colors.red,
//                                                               content: Text(
//                                                                   'Something went wrong, Please try again later'),
//                                                             ),
//                                                           );
//                                                           await AudioService
//                                                               .stop();
//                                                         }
//                                                       },
//                                                     ),
//                                                   ),
//                                                 } else if (processingState ==
//                                                         AudioProcessingState
//                                                             .skippingToNext ||
//                                                     processingState ==
//                                                         AudioProcessingState
//                                                             .connecting ||
//                                                     processingState ==
//                                                         AudioProcessingState
//                                                             .buffering) ...{
//                                                   Center(
//                                                       child: SizedBox(
//                                                           height: 55,
//                                                           width: 55,
//                                                           child:
//                                                               CircularProgressIndicator()))
//                                                 } else if (playing &&
//                                                     AudioService
//                                                             .currentMediaItem
//                                                             .id ==
//                                                         liveUrl)
//                                                   Center(
//                                                     child: IconButton(
//                                                       icon: Icon(Icons.pause),
//                                                       iconSize: 100.0,
//                                                       color: Theme.of(context)
//                                                           .accentColor,
//                                                       onPressed:
//                                                           AudioService.pause,
//                                                     ),
//                                                   )
//                                                 else
//                                                   Center(
//                                                     child: AudioService
//                                                                 .currentMediaItem
//                                                                 ?.id ==
//                                                             liveUrl
//                                                         ? IconButton(
//                                                             icon: Icon(Icons
//                                                                 .play_arrow),
//                                                             iconSize: 110.0,
//                                                             color: Theme.of(
//                                                                     context)
//                                                                 .accentColor,
//                                                             onPressed:
//                                                                 AudioService
//                                                                     .play,
//                                                           )
//                                                         : IconButton(
//                                                             icon: Icon(
//                                                               Icons.play_arrow,
//                                                             ),
//                                                             iconSize: 110.0,
//                                                             color: Theme.of(
//                                                                     context)
//                                                                 .accentColor,
//                                                             onPressed:
//                                                                 () async {
//                                                               Fluttertoast
//                                                                   .showToast(
//                                                                       msg:
//                                                                           'Buffering');

//                                                               try {
//                                                                 await AudioService
//                                                                     .updateQueue(
//                                                                         streamMedia);
//                                                               } catch (e, s) {
//                                                                 FirebaseCrashlytics
//                                                                     .instance
//                                                                     .recordError(
//                                                                         e, s,
//                                                                         reason:
//                                                                             'Resuming AUDIO');
//                                                                 ScaffoldMessenger.of(
//                                                                         context)
//                                                                     .showSnackBar(
//                                                                   SnackBar(
//                                                                     backgroundColor:
//                                                                         Colors
//                                                                             .red,
//                                                                     content: Text(
//                                                                         'Something went wrong, Please try again later'),
//                                                                   ),
//                                                                 );
//                                                                 await AudioService
//                                                                     .stop();
//                                                               }
//                                                             },
//                                                           ),
//                                                   ),
//                                               ],
//                                             ),
//                                           );
//                                         });
//                                   },
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 111,
//                             )
//                           ])
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ScreenState {
//   final List<MediaItem> queue;
//   final MediaItem mediaItem;
//   final PlaybackState playbackState;

//   ScreenState(this.queue, this.mediaItem, this.playbackState);
// }

// Stream<ScreenState> get _screenStateStream =>
//     Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
//         AudioService.queueStream,
//         AudioService.currentMediaItemStream,
//         AudioService.playbackStateStream,
//         (queue, mediaItem, playbackState) =>
//             ScreenState(queue, mediaItem, playbackState));

// // NOTE: Your entrypoint MUST be a top-level function.
// //Notifications can be tweaked from AudioPLayerTask
// void _audioPlayerTaskEntrypoint() async {
//   AudioServiceBackground.run(() => AudioPlayerTask());
// }
