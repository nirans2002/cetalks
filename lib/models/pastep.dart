class PastEp {
  final String epName;
  final String docId;
  final String program;
  final String description;
  final String artUrl;
  final String rjs;
  final String audiLocation;
  final int duration;
  final bool isLikable;
  final int? likes;
  PastEp({
    required this.docId,
    required this.epName,
    required this.artUrl,
    required this.description,
    required this.audiLocation,
    required this.program,
    required this.rjs,
    required this.duration,
    required this.isLikable,
    this.likes,
  });
}
