import 'package:cetalks/widgets/custom_pageview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './programview.dart';

class Programs extends StatefulWidget {
  static const routeName = '/programs';

  @override
  _ProgramsState createState() => _ProgramsState();
}

class _ProgramsState extends State<Programs> {
  var episodes = [];
  var programs = [];

  void selectStory(Map program) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPageView(
          initialPage: 0,
          children: <Widget>[
            //TODO VErify
            // if (program == null) ErrorScreen(),
            ScreenProg(program as Map<String, dynamic>)
          ],
        ),
      ),
    );

    return;
  }

  Widget buildProgramGrid(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: <Widget>[
        ...programs.map((tx) {
          return GestureDetector(
            onTap: () => selectStory(tx),
            child: Column(children: <Widget>[
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  image: DecorationImage(
                    image: NetworkImage(tx['ThumbUrl']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                  tx['Name'],
                  style: GoogleFonts.lato(color: Theme.of(context).accentColor),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ]),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: const Text(
          'Programs',
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Programs')
            .doc('All Programs')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasData) {
            List docSnapList = snapshot.data!.data()!['programs'];
            programs = [];
            for (var i = 0; i < docSnapList.length; i++) {
              var currProgram = docSnapList[i];

              if (currProgram['ThumbUrl'] == null ||
                  currProgram['ID'] == null ||
                  currProgram['Name'] == null ||
                  currProgram['description'] == null ||
                  currProgram['imageUrl'] == null) continue;
              if (!programs.contains(currProgram)) {
                programs.add(currProgram);
              }
            }
            if (programs.isEmpty) {
              return Center(
                child: Text(
                  'Please try again later',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Please try again later',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return buildProgramGrid(context);
        },
      ),
    );
  }
}
