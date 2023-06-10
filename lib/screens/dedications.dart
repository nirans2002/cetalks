import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/myalertdialog.dart';

import 'package:google_fonts/google_fonts.dart';

class Dedication {
  final String? sender;
  final String? reciever;
  final String? song;
  final String message;
  Dedication({this.sender, this.reciever, this.song, this.message = ''});
}

class DedicationsPage extends StatefulWidget {
  static const routeName = '/dedications';

  @override
  _DedicationsPageState createState() => _DedicationsPageState();
}

class _DedicationsPageState extends State<DedicationsPage> {
  final _form = GlobalKey<FormState>();
  final _toFocusNode = FocusNode();
  final _songFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();

  late var currentDedication;
  var _isLoading = false;

  @override
  void dispose() {
    _toFocusNode.dispose();
    _songFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

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
      await _addToDB(currentDedication);
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

  Future<void> _addToDB(Dedication dedication) async {
    try {
      await FirebaseFirestore.instance.collection('Dedications').add({
        'from': dedication.sender,
        'to': dedication.reciever,
        'song': dedication.song,
        'message': dedication.message,
        'time': DateTime.now()
      });

      Fluttertoast.showToast(msg: 'Success!');
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Dedications', style: TextStyle(fontSize: 25)),
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
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Form(
                  key: _form,
                  child: Container(
                    // height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height:
                              MediaQuery.of(context).viewInsets.bottom + 100,
                        ),
                        buildNameField(context),
                        buildRecieverNameField(context),
                        buildSongField(context),
                        buildMessageField(context),
                        SizedBox(height: 15),
                        buildSubmitButton(context),
                        SizedBox(
                          height:
                              MediaQuery.of(context).viewInsets.bottom + 300,
                        )
                      ],
                    ),
                  ),
                ),
              ),
      );

  ElevatedButton buildSubmitButton(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: Colors.white, onPrimary: Colors.black),
      child: Text(
        "Submit",
        style: TextStyle(fontSize: 16),
      ),
      onPressed: () {
        final validity = _form.currentState!.validate();
        if (!validity) return;

        return showAlertDialog(
            context,
            "Are you sure you want to submit your dedication?",
            () => _saveform(context));
      });

  TextFormField buildMessageField(BuildContext context) => TextFormField(
        maxLines: 5,
        cursorColor: Colors.pink,
        focusNode: _messageFocusNode,
        onSaved: (value) {
          currentDedication = Dedication(
              message: value!,
              sender: currentDedication.sender,
              reciever: currentDedication.reciever,
              song: currentDedication.song);
        },
        style: TextStyle(color: Theme.of(context).accentColor),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink),
          ),
          hintText: '(optional)',
          hintStyle: TextStyle(color: Colors.white54),
          labelText: 'Message',
          labelStyle: TextStyle(color: Colors.white54),
        ),
      );

  TextFormField buildSongField(BuildContext context) => TextFormField(
        maxLines: 1,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a song name';
          }
          return null;
        },
        focusNode: _songFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_messageFocusNode);
        },
        cursorColor: Colors.pink,
        onSaved: (value) {
          currentDedication = Dedication(
              message: currentDedication.message,
              sender: currentDedication.sender,
              reciever: currentDedication.reciever,
              song: value);
        },
        style: TextStyle(color: Theme.of(context).accentColor),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink),
          ),
          labelText: 'Song:',
          labelStyle: TextStyle(color: Colors.white54),
        ),
      );

  TextFormField buildRecieverNameField(BuildContext context) => TextFormField(
        maxLines: 1,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a name ';
          }
          return null;
        },
        focusNode: _toFocusNode,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_songFocusNode);
        },
        onSaved: (value) {
          currentDedication = Dedication(
              message: currentDedication.message,
              sender: currentDedication.sender,
              reciever: value,
              song: currentDedication.song);
        },
        cursorColor: Colors.pink,
        style: TextStyle(color: Theme.of(context).accentColor),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink),
          ),
          labelText: 'To:',
          labelStyle: TextStyle(color: Colors.white54),
        ),
      );

  TextFormField buildNameField(BuildContext context) => TextFormField(
        maxLines: 1,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        onSaved: (value) {
          currentDedication =
              Dedication(message: '', sender: value, reciever: '', song: '');
        },
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_toFocusNode);
        },
        cursorColor: Colors.pink,
        style: TextStyle(color: Theme.of(context).accentColor),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink),
          ),
          labelText: 'From:',
          labelStyle: TextStyle(color: Colors.white54),
        ),
      );
}
