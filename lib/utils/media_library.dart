import 'package:audio_service/audio_service.dart';

import '../global.dart';

class MediaLibrary {
  MediaLibrary._privateConstructor();
  static final MediaLibrary instance = MediaLibrary._privateConstructor();

  final _items = <MediaItem>[
    MediaItem(
      id: Config.liveUrl,
      album: "Live Stream",
      title: "CETalks",
      // artist: "Science Friday and WNYC Studios",
      // duration: Duration(milliseconds: 5739820),
      artUri: Uri.parse('https://i.imgur.com/X05Xrr0.png'),
    ),
  ];

  List<MediaItem> get items => _items;
  void setItems(List<MediaItem> newItems) {
    _items.clear();
    _items.addAll(newItems);
  }
}
