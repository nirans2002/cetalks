import 'package:audio_service/audio_service.dart';
import 'package:cetalks/global.dart';
import 'package:cetalks/widgets/audioplayertask.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

//import '../widgets/audioplayertask.dart';
import '../models/pastep.dart';
import '../widgets/bottomplayer.dart';

class EpisodeDetail extends StatelessWidget {
  static const routeName = '/episodedetail';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    final currEp = args[0] as PastEp;

    var currMedia = <MediaItem>[
      MediaItem(
          id: currEp.audiLocation,
          artUri: Uri.parse(currEp.artUrl),
          title: currEp.program,
          album: currEp.epName,
          artist: currEp.rjs,
          duration: Duration(seconds: currEp.duration))
    ];

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          BlurHash(hash: 'L35;~?IVD\$s;.AoIM_fk9Zt7t7WB'),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Container(
                  height: 56,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 280,
                            height: 280,
                            child: Hero(
                              tag: currEp.artUrl + currEp.epName,
                              child: Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(currEp.artUrl),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          ButtonTheme(
                            minWidth: 120,
                            height: 45,
                            child: StreamBuilder<PlaybackState>(
                                stream: AudioService.playbackStateStream,
                                builder: (context, snapshot) {
                                  final AudioProcessingState processingState =
                                      snapshot.data?.processingState ??
                                          AudioProcessingState.stopped;
                                  return StreamBuilder<bool>(
                                    stream: AudioService.playbackStateStream
                                        .map((state) => state.playing)
                                        .distinct(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      final playing = snapshot.data ?? false;
                                      if (processingState ==
                                              AudioProcessingState.none ||
                                          processingState ==
                                              AudioProcessingState.stopped) {
                                        return ElevatedButton(
                                          onPressed: () async {
                                            print('Executing START');
                                            // Navigator.of(context).pushNamed(
                                            //     NowPlayingScreen.routeName,
                                            //     arguments: currEp);
                                            try {
                                              await AudioService.start(
                                                androidStopForegroundOnPause:
                                                    true,
                                                params:
                                                    currMedia.first.toJson(),
                                                backgroundTaskEntrypoint:
                                                    _audioPlayerTaskEntrypoint,
                                                androidNotificationChannelName:
                                                    'CETalks',
                                                androidNotificationColor:
                                                    0x00000000,
                                                androidNotificationIcon:
                                                    'mipmap/ic_launcher',
                                                androidEnableQueue: true,
                                              );

                                              // await AudioService.updateQueue(
                                              //     currMedia);
                                            } catch (e, s) {
                                              FirebaseCrashlytics.instance
                                                  .recordError(e, s,
                                                      reason:
                                                          'STARTING PODCAST');

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Something went wrong, Please try again later'),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: StadiumBorder(),
                                            primary: Colors.yellow[300],
                                            onPrimary: Colors.black,
                                            minimumSize: Size(100, 40),
                                          ),
                                          child: Text('Play'),
                                        );
                                      } else if (processingState ==
                                              AudioProcessingState
                                                  .skippingToNext ||
                                          processingState ==
                                              AudioProcessingState.connecting ||
                                          processingState ==
                                              AudioProcessingState.buffering) {
                                        return ElevatedButton(
                                          onPressed: () {},
                                          child: SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.black,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                          Color?>(
                                                      Colors.yellow[300]),
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shape: StadiumBorder(),
                                            primary: Colors.yellow[300],
                                            onPrimary: Colors.black,
                                            minimumSize: Size(100, 40),
                                          ),
                                        );
                                      } else if (playing &&
                                          AudioService.currentMediaItem!.id ==
                                              currEp.audiLocation) {
                                        return ElevatedButton(
                                          onPressed: () {
                                            print('Executing Pause');
                                            AudioService.pause();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: StadiumBorder(),
                                            primary: Colors.yellow[300],
                                            onPrimary: Colors.black,
                                            minimumSize: Size(100, 40),
                                          ),
                                          child: Text('Pause'),
                                        );
                                      } else if (AudioService
                                              .currentMediaItem!.id ==
                                          currEp.audiLocation) {
                                        return ElevatedButton(
                                          onPressed: () {
                                            print('Executing Resume');

                                            AudioService.play();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: StadiumBorder(),
                                            primary: Colors.yellow[300],
                                            onPrimary: Colors.black,
                                            minimumSize: Size(100, 40),
                                          ),
                                          child: Text('Resume'),
                                        );
                                      } else {
                                        return ElevatedButton(
                                          onPressed: () async {
                                            print('Executin Update Only');
                                            try {
                                              await AudioService.updateQueue(
                                                  currMedia);
                                            } catch (e, s) {
                                              FirebaseCrashlytics.instance
                                                  .recordError(e, s,
                                                      reason:
                                                          'UPDATING TO PODCAST');

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.red,
                                                  content: Text(
                                                      'Something went wrong, Please try again later'),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: StadiumBorder(),
                                            primary: Colors.yellow[300],
                                            onPrimary: Colors.black,
                                            minimumSize: Size(100, 40),
                                          ),
                                          child: Text('Play'),
                                        );
                                      }
                                    },
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currEp.epName,
                              style: GoogleFonts.lato(
                                  color: Theme.of(context).accentColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(currEp.rjs,
                                style: GoogleFonts.roboto(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w400)),
                          ),
                          SizedBox(height: 15),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currEp.description,
                              style: GoogleFonts.lato(color: Colors.white70),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                StreamBuilder<ScreenState>(
                    stream: _screenStateStream,
                    builder: (context, snapshot) {
                      final screenState = snapshot.data;

                      final mediaItem = screenState?.mediaItem;
                      if (mediaItem == null)
                        return Container();
                      else if (mediaItem.id == Config.liveUrl)
                        return Container();
                      else
                        return BottomPlayer();
                    })
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class ScreenState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

Stream<ScreenState> get _screenStateStream =>
    Rx.combineLatest3<List<MediaItem>?, MediaItem?, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));
