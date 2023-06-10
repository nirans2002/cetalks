import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Text(
          'Coming Soon..',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
    );
  }
}
