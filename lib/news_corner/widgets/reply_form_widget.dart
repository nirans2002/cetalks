import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReplyFormWidget extends StatefulWidget {
  const ReplyFormWidget({
    Key? key,
    required this.docTitle,
    required this.docId,
    required this.docRef,
  });

  final String docTitle;
  final String docId;

  /// user replies document reference
  final DocumentReference docRef;

  @override
  _ReplyFormWidgetState createState() => _ReplyFormWidgetState();
}

class _ReplyFormWidgetState extends State<ReplyFormWidget> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _reply = '';
  var _name = '';
  var _number = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reply',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextFormField(
                onChanged: (String value) {
                  _reply = value;
                },
                style: TextStyle(color: Colors.white60),
                maxLines: 2,
                decoration: InputDecoration(
                  fillColor: Colors.white30,
                  hintText: 'Enter your reply',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                onChanged: (String value) {
                  _name = value;
                },
                validator: (value) {
                  if (value!.length < 4) {
                    return 'Enter a valid name';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white60),
                maxLines: 1,
                decoration: InputDecoration(
                  fillColor: Colors.white30,
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                onChanged: (String value) {
                  _number = value;
                },
                style: TextStyle(color: Colors.white60),
                maxLines: 1,
                validator: (value) {
                  if (int.tryParse(value!) == null || value.length < 9)
                    return 'Enter a valid number';
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white30,
                  hintText: 'Mobile Number',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
              ),
              SizedBox(height: 12),
              if (_isLoading)
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              if (!_isLoading)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white, onPrimary: Colors.black),
                    onPressed: () async {
                      final isValid = _form.currentState!.validate();
                      if (!isValid) return;

                      setState(() {
                        _isLoading = true;
                      });
                      await widget.docRef.update(
                        {
                          'replies': FieldValue.arrayUnion([widget.docId])
                        },
                      );
                      await FirebaseFirestore.instance
                          .collection('Replies')
                          .add(
                        {
                          'message': _reply,
                          'name': _name,
                          'number': _number,
                          'title': widget.docTitle,
                          'time': DateTime.now()
                        },
                      );
                      Fluttertoast.showToast(msg: 'Replied!');
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
