import 'package:cetalks/screens/storyviewnew.dart';
import 'package:cetalks/widgets/custom_pageview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'errorscreen.dart';

class TeamViewScreen extends StatelessWidget {
  static const routeName = '/teamview';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Team', style: TextStyle(fontSize: 25)),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Team')
                  .orderBy('rank')
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else {
                  QuerySnapshot query = snapshot.data!;
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                      query.docs
                          as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
                  var teamList = docs.map((e) => e.data()).toList();
                  if (teamList.isEmpty) {
                    return Center(
                      child: Text(
                        'Please Try Again Later',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                          mainAxisSpacing: 10),
                      itemCount: teamList.length,
                      itemBuilder: (ctx, index) {
                        return GestureDetector(
                          onTap: () async {
                            List<dynamic>? panelList = [];

                            if (teamList[index]['members'] != null)
                              panelList = teamList[index]['members'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomPageView(
                                  initialPage: 0,
                                  children: <Widget>[
                                    if (panelList!.isEmpty) ErrorScreen(),
                                    ...panelList.map((e) {
                                      return ScreenStory(e);
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Column(children: <Widget>[
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    teamList[index]['thumbUrl'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                border: Border.all(
                                  color: Theme.of(context).accentColor,
                                  width: 1.25,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Container(
                              child: Text(
                                teamList[index]['name'],
                                style: GoogleFonts.lato(
                                    color: Theme.of(context).accentColor),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ]),
                        );
                      });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
