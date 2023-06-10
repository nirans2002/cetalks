import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

import '../screens/nowplaying.dart';

class BottomPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (context, snapshot) {
          final screenState = snapshot.data;

          final mediaItem = screenState?.mediaItem;
          final state = screenState?.playbackState;
          final processingState =
              state?.processingState ?? AudioProcessingState.none;
          final playing = state?.playing ?? false;

          if (processingState != AudioProcessingState.ready) return Container();
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(NowPlayingScreen.routeName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black45)],
              ),
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      child: Image(
                        image: NetworkImage(
                          mediaItem!.artUri!.toString(),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mediaItem.album,
                        style: GoogleFonts.lato(
                            color: Theme.of(context).accentColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      child: playing
                          ? IconButton(
                              icon: Icon(
                                Icons.pause,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () {
                                AudioService.pause();
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Theme.of(context).accentColor,
                              ),
                              onPressed: () {
                                AudioService.play();
                              },
                            ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
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
