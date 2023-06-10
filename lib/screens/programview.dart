import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class ScreenProg extends StatelessWidget {
  final Map<String, dynamic> episode;
  ScreenProg(this.episode);

  @override
  Widget build(BuildContext context) {
    const color = Color(0xDD182628);
    var mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: color,
        body: episode.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(episode['Name'],
                                  style: GoogleFonts.lato(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).accentColor)),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: mediaQuery.width - 64,
                                child: Text(
                                  episode['description'],
                                  maxLines: 4,
                                  style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w300,
                                      color: Theme.of(context).accentColor),
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                    //height: 125,
                  ),
                  Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: mediaQuery.width,
                              maxHeight: mediaQuery.height -
                                  MediaQuery.of(context).viewInsets.top -
                                  145),
                          decoration: BoxDecoration(
                            color: Color(0xFF182628),
                            border: Border.all(
                              width: 5,
                              color: Color(0xFF182628),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FadeInImage.assetNetwork(
                                  image: episode['imageUrl'],
                                  placeholder: 'assets/images/load.gif',
                                  fit: BoxFit.cover,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 2)
                ],
              ),
      ),
    );
  }
}
