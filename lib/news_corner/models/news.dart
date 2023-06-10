import 'package:cloud_firestore/cloud_firestore.dart';

enum NewsType {
  news,
  repliableNews,
  replyWithDetailsNews,
  // poll,
}

class News {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final NewsType? newsType;
  final String? link;
  final DateTime dateTime;
  final List<Map<String, dynamic>>? pollOptions;

  News({
    required this.title,
    required this.id,
    this.subtitle,
    this.description,
    this.newsType,
    this.link,
    required this.dateTime,
    this.pollOptions,
  });

  static News fromJson(Map<String, dynamic> map) => News(
        dateTime: (map['time'] as Timestamp).toDate(),
        id: map['documentId'],
        description: map['description'],
        title: map['title'],
        subtitle: map['subtitle'],
        link: map['link'],
        newsType: getNewsType(map),
        pollOptions: map['pollOptions'],
      );

  static NewsType getNewsType(Map<String, dynamic> map) {
    if (map['reply'] == true) {
      return NewsType.repliableNews;
    }
    if (map['replyWithDetails'] == true) {
      return NewsType.replyWithDetailsNews;
    }
    // if (map['isPoll'] == true) {
    //   return NewsType.poll;
    // }
    else
      return NewsType.news;
  }
}
