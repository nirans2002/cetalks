import 'package:cetalks/news_corner/models/news.dart';
import 'package:cetalks/news_corner/widgets/reply_field_widget.dart';
import 'package:cetalks/news_corner/widgets/reply_with_details_widget.dart';
import 'package:cetalks/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsCornerPage extends StatelessWidget {
  static const routeName = '/news';
  _launchURL(myurl) async {
    if (await canLaunch(myurl)) {
      await launch(myurl);
    } else {
      throw 'Could not launch $myurl';
    }
  }

  _setLastnews(String docid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('latest', docid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('News Corner'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(10),
            child: StreamBuilder<List<News>>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('time', descending: true)
                  .snapshots()
                  .transform(Utils.transformer(News.fromJson)),
              builder: (context, AsyncSnapshot<List<News>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else {
                  final newsList = snapshot.data!;
                  if (newsList.isEmpty) {
                    return Text('Please Try Again Later');
                  }
                  _setLastnews(newsList.first.id);

                  return ListView.builder(
                    itemBuilder: (ctx, index) {
                      if (index == newsList.length) {
                        return SizedBox(
                          height: 150,
                        );
                      }
                      final news = newsList[index];
                      // if (news.newsType == NewsType.poll)
                      //   return PollWidget(news: news);

                      final date = news.dateTime;
                      final formattedDate = DateFormat.yMMMd().format(date);
                      final formattedTime = DateFormat.jm().format(date);

                      return Card(
                        key: Key(news.id),
                        elevation: 0,
                        color: Colors.grey[900],
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.white30),
                            child: ExpansionTile(
                              childrenPadding: EdgeInsets.only(
                                  left: 15, bottom: 5, right: 10),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              expandedAlignment: Alignment.centerLeft,
                              children: [
                                if (news.description != null)
                                  Text(
                                    news.description!,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                if (news.description == null &&
                                    news.description!.trim() != '')
                                  Text(
                                    'No desciption',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                if (news.link != null &&
                                    news.link!.trim() != '')
                                  SizedBox(
                                    height: 5,
                                  ),
                                if (news.link != null &&
                                    news.link!.trim() != '')
                                  GestureDetector(
                                    child: Text(news.link!,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w400)),
                                    onTap: () {
                                      _launchURL(news.link);
                                    },
                                  ),
                                if (news.newsType == NewsType.repliableNews ||
                                    news.newsType ==
                                        NewsType.replyWithDetailsNews)
                                  SizedBox(height: 10),
                                if (news.newsType == NewsType.repliableNews)
                                  ReplyFieldWidget(
                                    docTitle: news.title,
                                    docId: news.id,
                                  ),
                                if (news.newsType ==
                                    NewsType.replyWithDetailsNews)
                                  ReplyWithDetailsWidget(
                                    docId: news.id,
                                    docTitle: news.title,
                                  )
                              ],
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      news.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  )
                                ],
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        news.subtitle!,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          color: Colors.white60, fontSize: 12),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: newsList.length + 1,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
