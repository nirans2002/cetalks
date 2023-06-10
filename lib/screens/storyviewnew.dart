import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenStory extends StatelessWidget {
  final Map detail;
  ScreenStory(this.detail);

  @override
  Widget build(BuildContext context) {
    const color = Color(0xDD182628);
    var mediaQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: color,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: color,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(detail['name'],
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                detail['designation'],
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: mediaQuery.width,
                  maxHeight: mediaQuery.height * 0.9),
              decoration: BoxDecoration(
                color: Color(0xFF182628),
                border: Border.all(
                  width: 2,
                  color: Color(0xFF182628),
                ),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FadeInImage.assetNetwork(
                    image: detail['imageUrl'],
                    placeholder: 'assets/images/load.gif',
                    fit: BoxFit.cover,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
