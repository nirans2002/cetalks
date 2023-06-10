import 'package:audio_service/audio_service.dart';

class Config {
  static const _zenoUrl = 'https://stream.zeno.fm/fzcvyyer01zuv';
  static const streemlionUrl = 'https://radio.streemlion.com/ttcetalks';

  static var isLiveUrlAvailable = false;

  static MediaItem liveMedia = MediaItem(
    id: liveUrl,
    album: "Live Stream",
    title: "CETalks",
    artUri: Uri.parse('https://i.imgur.com/X05Xrr0.png'),
  );

  static String get liveUrl => isLiveUrlAvailable ? streemlionUrl : _zenoUrl;
}
