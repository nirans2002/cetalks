import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/myalertdialog.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class Feedback {
  final String? message;
  Feedback(this.message);
}

class TellUs extends StatefulWidget {
  static const routeName = '/tellus';

  @override
  _TellUsState createState() => _TellUsState();
}

class _TellUsState extends State<TellUs> {
  final _form = GlobalKey<FormState>();

  late var current;
  var _isLoading = false;

  void _saveform(BuildContext context) async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      await _addToDB(current.message);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).accentColor,
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _addToDB(String? message) async {
    try {
      await FirebaseFirestore.instance
          .collection('TellUs')
          .add({'message': message});
      Fluttertoast.showToast(msg: 'Success!');
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Tell Us',
            style:
                TextStyle(fontSize: 25, color: Theme.of(context).accentColor)),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Submitting',
                    style: GoogleFonts.lato(
                        color: Theme.of(context).accentColor, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _form,
                      child: TextFormField(
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        cursorColor: Colors.pink,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter something.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          current = Feedback(value);
                        },
                        style: TextStyle(color: Theme.of(context).accentColor),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink),
                          ),
                          hintText: 'Provide your feedback',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white, onPrimary: Colors.black),
                      child: Text(
                        "Submit",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        final validity = _form.currentState!.validate();
                        if (!validity) return;
                        showAlertDialog(
                            context,
                            "Are you sure you want to submit your feedback?",
                            () => _saveform(context));
                      },
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
