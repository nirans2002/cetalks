import 'package:audio_service/audio_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global.dart';
import 'audioplayertask.dart';

class PlayerStreamWidget extends StatelessWidget {
  const PlayerStreamWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// THIS STREAMBUILDER IS FOR ACCESSING PLAYBACK STATE
    /// AND THUS PROCESSING STATE
    return StreamBuilder<PlaybackState>(
      stream: AudioService.playbackStateStream,
      builder: (context, snapshot) {
        final AudioProcessingState processingState =
            snapshot.data?.processingState ?? AudioProcessingState.stopped;

        final streamMedia = [
          MediaItem(
            id: Config.liveUrl,
            album: "Live Stream",
            title: "CETALKS",
            artUri: Uri.parse('https://i.imgur.com/X05Xrr0.png'),
          )
        ];

        /// THIS STREAMBUILDER IS USED TO CHECK TO CHECK PLAY/PAUSE
        /// STATE
        return StreamBuilder<bool>(
            stream: AudioService.playbackStateStream
                .map((state) => state.playing)
                .distinct(),
            builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // IF NO AUDIO IS PLAYING START THE TASK
                    if (processingState == AudioProcessingState.none ||
                        processingState == AudioProcessingState.stopped) ...{
                      Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.play_arrow,
                          ),
                          iconSize: 110.0,
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            Fluttertoast.showToast(msg: 'Buffering..');
                            // try {
                            //   await AudioService.stop();
                            // } catch (e) {
                            //   print("COULD NOT STOP");
                            // }
                            try {
                              await AudioService.start(
                                androidStopForegroundOnPause: true,
                                backgroundTaskEntrypoint:
                                    _audioPlayerTaskEntrypoint,
                                androidNotificationChannelName: 'CETalks',
                                androidNotificationColor: 0x00000000,
                                androidNotificationIcon: 'mipmap/ic_launcher',
                                androidEnableQueue: true,
                                params: Config.liveMedia.toJson(),
                              );

                              // if (Config.isLiveUrlAvailable)
                              //   await AudioService.updateQueue(
                              //       [Config.liveMedia]);
                            } catch (e, s) {
                              print(e);
                              FirebaseCrashlytics.instance
                                  .recordError(e, s, reason: 'STARTING AUDIO');

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      'Something went wrong, Please try again later'),
                                ),
                              );
                              await AudioService.stop();
                            }
                          },
                        ),
                      ),
                    }

                    /// LOADING CASE
                    else if (processingState ==
                            AudioProcessingState.skippingToNext ||
                        processingState == AudioProcessingState.connecting ||
                        processingState == AudioProcessingState.buffering) ...{
                      Center(
                        child: SizedBox(
                          height: 55,
                          width: 55,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    }

                    /// IF PLAYING THE LIVESTREAM
                    else if (playing &&
                        AudioService.currentMediaItem?.id == Config.liveUrl)
                      Center(
                        child: IconButton(
                          icon: Icon(Icons.pause),
                          iconSize: 100.0,
                          color: Theme.of(context).accentColor,
                          onPressed: AudioService.pause,
                        ),
                      )

                    /// IF NOT PLAYING LIVESTREAM, i.e either LIVE STREAM PAUSED STATE
                    /// OR EPISODE PLAYING STATE
                    else
                      Center(
                        child: AudioService.currentMediaItem?.id ==
                                Config.liveUrl

                            /// IF LIVE STREAM IS PAUSED, RESUME IT
                            ? IconButton(
                                icon: Icon(Icons.play_arrow),
                                iconSize: 110.0,
                                color: Theme.of(context).accentColor,
                                onPressed: AudioService.play,
                              )

                            /// IF PODCASTS WERE BEING PLAYED, UPDATE TO LIVESTREAM
                            : IconButton(
                                icon: Icon(
                                  Icons.play_arrow,
                                ),
                                iconSize: 110.0,
                                color: Theme.of(context).accentColor,
                                onPressed: () async {
                                  Fluttertoast.showToast(msg: 'Buffering');

                                  try {
                                    await AudioService.updateQueue(streamMedia);
                                  } catch (e, s) {
                                    FirebaseCrashlytics.instance.recordError(
                                        e, s,
                                        reason: 'Resuming AUDIO');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'Something went wrong, Please try again later'),
                                      ),
                                    );
                                    await AudioService.stop();
                                  }
                                },
                              ),
                      ),
                  ],
                ),
              );
            });
      },
    );
  }
}

// NOTE: Your entrypoint MUST be a top-level function.
//Notifications can be tweaked from AudioPLayerTask
void _audioPlayerTaskEntrypoint() async {
  print('RUNNING MAIN TASK');
  await AudioServiceBackground.run(() => AudioPlayerTask());
}
