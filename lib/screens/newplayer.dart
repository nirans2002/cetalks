import 'package:audio_service/audio_service.dart';
import 'package:cetalks/news_corner/pages/news_corner_page.dart';
import 'package:cetalks/widgets/player_stream_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:volume_watcher/volume_watcher.dart';

import '../widgets/mydrawer.dart';
import '../widgets/pastep.dart';

class Player extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  String? latest = '';

  //double currentVolume = 40;

  @override
  void initState() {
    super.initState();

    _latestDoc();
  }

  _latestDoc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      latest = prefs.getString('latest');
    });
    print(latest);
  }

  PanelController _pc = PanelController();
  var currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      if (_pc.isPanelOpen) {
        _pc.close();
        _pc.show();
      }

      Fluttertoast.showToast(
        msg: 'Press back again to exit',
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'CETALKS',
            ),
            textTheme: Theme.of(context).appBarTheme.textTheme,
            actions: [
              SizedBox(width: 8),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('news')
                      .orderBy('time', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData) {
                      return IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(NewsCornerPage.routeName)
                                .whenComplete(() {
                              _latestDoc();
                            });
                          },
                          padding: EdgeInsets.only(right: 15),
                          icon: Icon(Icons.notifications_none));
                    } else {
                      QuerySnapshot query = snapshot.data!;
                      List<DocumentSnapshot> docs = query.docs;
                      if (docs.isEmpty)
                        return IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(NewsCornerPage.routeName)
                                  .whenComplete(() {
                                _latestDoc();
                              });
                            },
                            padding: EdgeInsets.only(right: 15),
                            icon: Icon(Icons.notifications_none));
                      var doc = docs[0];
                      var newLatest = doc.id;
                      if (newLatest == latest) {
                        return IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(NewsCornerPage.routeName)
                                .whenComplete(() {
                              print('running');
                              _latestDoc();
                            });
                          },
                          padding: EdgeInsets.only(right: 15),
                          icon: Icon(Icons.notifications_none),
                        );
                      } else {
                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(NewsCornerPage.routeName)
                                    .whenComplete(() {
                                  _latestDoc();
                                });
                              },
                              padding: EdgeInsets.only(right: 15),
                              icon: Icon(Icons.notifications),
                            ),
                            Positioned(
                              right: 20,
                              top: 11,
                              child: new Container(
                                padding: EdgeInsets.all(2),
                                decoration: new BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 11,
                                  minHeight: 11,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  }),
            ],
          ),
          drawer: MyDrawer(),
          backgroundColor: Theme.of(context).primaryColor,
          body: SlidingUpPanel(
            controller: _pc,
            collapsed: GestureDetector(
              onTap: () {
                _pc.open();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(25))),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.expand_less,
                        color: Theme.of(context).accentColor,
                      ),
                      Text(
                        'Our Podcasts',
                        style: GoogleFonts.lato(
                            color: Theme.of(context).accentColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            header: Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25))),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.expand_more,
                      color: Theme.of(context).accentColor,
                    ),
                    Text(
                      'Our Podcasts',
                      style: GoogleFonts.lato(
                          color: Theme.of(context).accentColor),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Missed the livestream? Catch up here',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w300),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
            minHeight: 55,
            maxHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                5,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            panel: Center(child: buildPastEpisodes(context)),
            body: RefreshIndicator(
              onRefresh: () => AudioService.stop(),

              /// stack plus listview is used to enable refreshindicator
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ListView(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 150,
                              child: const Image(
                                image: AssetImage('assets/images/cetalks.png'),
                              ),
                            ),
                            VolumeWidget(),
                          ],
                        ),

                        /// TO MOVE THE STACK UP, SO THAT IT IS CENTERED W.R.T THE
                        /// SLIDING UP PANEL
                        SizedBox(
                          height: 111,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VolumeWidget extends StatefulWidget {
  const VolumeWidget({
    Key? key,
  }) : super(key: key);

  @override
  _VolumeWidgetState createState() => _VolumeWidgetState();
}

class _VolumeWidgetState extends State<VolumeWidget> {
  double? currentVolume = 0.4;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      VolumeWatcher.hideVolumeView = true;
    } on PlatformException {
      print('EXCEPTION');
    }

    double? _initVolume;

    try {
      _initVolume = await VolumeWatcher.getCurrentVolume;
    } on PlatformException {
      print('ERROR');
    }

    if (!mounted) return;

    setState(() {
      this.currentVolume = _initVolume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VolumeWatcher(
      onVolumeChangeListener: (double volume) {
        print(volume);
        setState(() {
          currentVolume = volume;
        });
      },
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
          size: 220,
          customWidths: CustomSliderWidths(
            handlerSize: 8.5,
            progressBarWidth: 5,
          ),
          customColors: CustomSliderColors(
            trackColor: Colors.grey,
            shadowColor: Colors.white,
            progressBarColor: Colors.white,
          ),
          angleRange: 360,
          startAngle: 270,
        ),
        initialValue: currentVolume!,
        min: 0,
        max: 1,
        onChange: (vol) async {
          VolumeWatcher.setVolume(vol);
        },
        innerWidget: (_) => PlayerStreamWidget(),
      ),
    );
  }
}
