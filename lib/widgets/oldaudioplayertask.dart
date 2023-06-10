// import 'dart:async';
// import 'dart:math';

// import 'package:audio_service/audio_service.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:cetalks/utils/media_library.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// class QueueState {
//   final List<MediaItem> queue;
//   final MediaItem mediaItem;

//   QueueState(this.queue, this.mediaItem);
// }

// class MediaState {
//   final MediaItem mediaItem;
//   final Duration position;

//   MediaState(this.mediaItem, this.position);
// }

// class SeekBar extends StatefulWidget {
//   final Duration duration;
//   final Duration position;
//   final ValueChanged<Duration>? onChanged;
//   final ValueChanged<Duration>? onChangeEnd;

//   SeekBar({
//     required this.duration,
//     required this.position,
//     this.onChanged,
//     this.onChangeEnd,
//   });

//   @override
//   _SeekBarState createState() => _SeekBarState();
// }

// class _SeekBarState extends State<SeekBar> {
//   double? _dragValue;
//   bool _dragging = false;

//   @override
//   Widget build(BuildContext context) {
//     final value = min(
//       _dragValue ?? widget.position.inMilliseconds.toDouble(),
//       widget.duration.inMilliseconds.toDouble(),
//     );
//     if (_dragValue != null && !_dragging) {
//       _dragValue = null;
//     }
//     return Stack(
//       children: [
//         Slider(
//           min: 0.0,
//           max: widget.duration.inMilliseconds.toDouble(),
//           value: value,
//           onChanged: (value) {
//             if (!_dragging) {
//               _dragging = true;
//             }
//             setState(() {
//               _dragValue = value;
//             });
//             if (widget.onChanged != null) {
//               widget.onChanged!(Duration(milliseconds: value.round()));
//             }
//           },
//           onChangeEnd: (value) {
//             if (widget.onChangeEnd != null) {
//               widget.onChangeEnd!(Duration(milliseconds: value.round()));
//             }
//             _dragging = false;
//           },
//         ),
//         Positioned(
//           right: 16.0,
//           bottom: 0.0,
//           child: Text(
//               RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                       .firstMatch("$_remaining")
//                       ?.group(1) ??
//                   '$_remaining',
//               style: Theme.of(context).textTheme.caption),
//         ),
//       ],
//     );
//   }

//   Duration get _remaining => widget.duration - widget.position;
// }

// // NOTE: Your entrypoint MUST be a top-level function.
// // void _audioPlayerTaskEntrypoint() async {
// //   AudioServiceBackground.run(() => AudioPlayerTask());
// // }

// /// This task defines logic for playing a list of podcast episodes.
// class AudioPlayerTask extends BackgroundAudioTask {
//   final _mediaLibrary = MediaLibrary.instance;
//   AudioPlayer _player = new AudioPlayer();
//   AudioProcessingState? _skipState;
//   Seeker? _seeker;
//   late StreamSubscription<PlaybackEvent> _eventSubscription;
//   List<MediaItem> get queue => _mediaLibrary.items;
//   int? get index => _player.currentIndex;
//   MediaItem? get mediaItem => index == null ? null : queue[index!];

//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     // We configure the audio session for speech since we're playing a podcast.
//     // You can also put this in your app's initialisation if your app doesn't
//     // switch between two types of audio as this example does.
//     print("STARTING");

//     if (params != null && params['pause'] == null) {
//       final mediaItem = MediaItem.fromJson(params);
//       _mediaLibrary.setItems([mediaItem]);
//     }
//     print('GOING FORWARD');
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.music());
//     // Broadcast media item changes.
//     _player.currentIndexStream.listen((index) {
//       if (index != null) AudioServiceBackground.setMediaItem(queue[index]);
//     });
//     // Propagate all events from the audio player to AudioService clients.
//     _eventSubscription = _player.playbackEventStream.listen((event) {
//       _broadcastState();
//     });
//     // Special processing for state transitions.
//     _player.processingStateStream.listen((state) {
//       switch (state) {
//         case ProcessingState.completed:
//           // In this example, the service stops when reaching the end.

//           onStop();
//           break;
//         case ProcessingState.ready:
//           // If we just came from skipping between tracks, clear the skip
//           // state now that we're ready to play.
//           _skipState = null;
//           break;
//         default:
//           break;
//       }
//     });

//     // Load and broadcast the queue
//     AudioServiceBackground.setQueue(queue);
//     try {
//       await _player.setAudioSource(ConcatenatingAudioSource(
//         children:
//             queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
//       ));
//       // In this example, we automatically start playing on start.
//       final shouldPause =
//           params != null && params['pause'] != null && params['pause'] == true;
//       print('SHOULD PAUHSE' + shouldPause.toString());

//       onPlay();
//     } catch (e) {
//       print("Error: $e");

//       onStop();
//     }
//   }

//   @override
//   Future<void> onSkipToQueueItem(String mediaId) async {
//     // Then default implementations of onSkipToNext and onSkipToPrevious will
//     // delegate to this method.
//     final newIndex = queue.indexWhere((item) => item.id == mediaId);
//     if (newIndex == -1) return;
//     // During a skip, the player may enter the buffering state. We could just
//     // propagate that state directly to AudioService clients but AudioService
//     // has some more specific states we could use for skipping to next and
//     // previous. This variable holds the preferred state to send instead of
//     // buffering during a skip, and it is cleared as soon as the player exits
//     // buffering (see the listener in onStart).
//     _skipState = newIndex > index!
//         ? AudioProcessingState.skippingToNext
//         : AudioProcessingState.skippingToPrevious;
//     // This jumps to the beginning of the queue item at newIndex.
//     _player.seek(Duration.zero, index: newIndex);
//     // Demonstrate custom events.
//     AudioServiceBackground.sendCustomEvent('skip to $newIndex');
//   }

//   @override
//   Future<void> onPlay() => _player.play();

//   @override
//   Future<void> onPause() => _player.pause();

//   @override
//   Future<void> onSeekTo(Duration position) => _player.seek(position);

//   @override
//   Future<void> onFastForward() => _seekRelative(fastForwardInterval);

//   @override
//   Future<void> onRewind() => _seekRelative(-rewindInterval);

//   @override
//   Future<void> onUpdateQueue(List<MediaItem> queue) async {
//     _mediaLibrary.setItems(queue);
//     print('UPDATING MEDIA');
//     await AudioServiceBackground.setQueue(queue);
//     await AudioServiceBackground.setMediaItem(mediaItem!);
//     try {
//       await _player.setAudioSource(AudioSource.uri(Uri.parse(mediaItem!.id)));
//     } catch (e) {
//       throw e;
//     }
//     onPlay();
//     super.onUpdateQueue(queue);
//   }

//   @override
//   Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

//   @override
//   Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

//   @override
//   Future<void> onStop() async {
//     await _player.dispose();
//     _eventSubscription.cancel();
//     // It is important to wait for this state to be broadcast before we shut
//     // down the task. If we don't, the background task will be destroyed before
//     // the message gets sent to the UI.
//     await _broadcastState();
//     // Shut down this task
//     await super.onStop();
//   }

//   /// Jumps away from the current position by [offset].
//   Future<void> _seekRelative(Duration offset) async {
//     var newPosition = _player.position + offset;
//     // Make sure we don't jump out of bounds.
//     if (newPosition < Duration.zero) newPosition = Duration.zero;
//     if (newPosition > mediaItem!.duration!) newPosition = mediaItem!.duration!;
//     // Perform the jump via a seek.
//     await _player.seek(newPosition);
//   }

//   /// Begins or stops a continuous seek in [direction]. After it begins it will
//   /// continue seeking forward or backward by 10 seconds within the audio, at
//   /// intervals of 1 second in app time.
//   void _seekContinuously(bool begin, int direction) {
//     _seeker?.stop();
//     if (begin) {
//       _seeker = Seeker(_player, Duration(seconds: 10 * direction),
//           Duration(seconds: 1), mediaItem)
//         ..start();
//     }
//   }

//   /// Broadcasts the current state to all clients.
//   Future<void> _broadcastState() async {
//     await AudioServiceBackground.setState(
//       controls: [
//         //   MediaControl.skipToPrevious,
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         //   MediaControl.skipToNext,
//       ],
//       systemActions: [
//         MediaAction.seekTo,
//         // MediaAction.seekForward,
//         // MediaAction.seekBackward,
//       ],
//       androidCompactActions: [0, 1],
//       processingState: _getProcessingState(),
//       playing: _player.playing,
//       position: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//     );
//   }

//   /// Maps just_audio's processing state into into audio_service's playing
//   /// state. If we are in the middle of a skip, we use [_skipState] instead.
//   AudioProcessingState? _getProcessingState() {
//     if (_skipState != null) return _skipState;
//     switch (_player.processingState) {
//       case ProcessingState.idle:
//         return AudioProcessingState.stopped;
//       case ProcessingState.loading:
//         return AudioProcessingState.connecting;
//       case ProcessingState.buffering:
//         return AudioProcessingState.buffering;
//       case ProcessingState.ready:
//         return AudioProcessingState.ready;
//       case ProcessingState.completed:
//         return AudioProcessingState.completed;
//       default:
//         throw Exception("Invalid state: ${_player.processingState}");
//     }
//   }
// }

// /// Provides access to a library of media items. In your app, this could come
// /// from a database or web service.

// class Seeker {
//   final AudioPlayer player;
//   final Duration positionInterval;
//   final Duration stepInterval;
//   final MediaItem? mediaItem;
//   bool _running = false;

//   Seeker(
//     this.player,
//     this.positionInterval,
//     this.stepInterval,
//     this.mediaItem,
//   );

//   start() async {
//     _running = true;
//     while (_running) {
//       Duration newPosition = player.position + positionInterval;
//       if (newPosition < Duration.zero) newPosition = Duration.zero;
//       if (newPosition > mediaItem!.duration!)
//         newPosition = mediaItem!.duration!;
//       player.seek(newPosition);
//       await Future.delayed(stepInterval);
//     }
//   }

//   stop() {
//     _running = false;
//   }
// }
