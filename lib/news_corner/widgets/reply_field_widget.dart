import 'package:cetalks/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../screens/account_page.dart';

class ReplyFieldWidget extends StatefulWidget {
  const ReplyFieldWidget(
      {Key? key, required this.docId, required this.docTitle})
      : super(key: key);

  final String docId;
  final String docTitle;

  @override
  _ReplyFieldWidgetState createState() => _ReplyFieldWidgetState();
}

class _ReplyFieldWidgetState extends State<ReplyFieldWidget> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _reply = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isLoggedIn) {
      return Form(
        key: _form,
        child: Container(
          height: 65,
          child: TextFormField(
            enabled: true,
            onChanged: (String value) {
              print('value');
              _reply = value;
            },
            style: TextStyle(
              color: Colors.white60,
            ),
            expands: true,
            maxLines: null,
            decoration: InputDecoration(
              fillColor: Colors.white30,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                  borderRadius: BorderRadius.circular(10)),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white60),
                  borderRadius: BorderRadius.circular(10)),
              labelText: 'Enter your reply',
              labelStyle: TextStyle(
                color: Colors.white30,
              ),
              suffix: _isLoading
                  ? Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.white30),
                      onPressed: () {
                        Fluttertoast.showToast(msg: 'Login to continue');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AccountPage(),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      );
    }
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUser!.id)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return Center(
            child: Container(
                height: 30, width: 30, child: CircularProgressIndicator()),
          );
        }
        final doc = snapshot.data!.data()!;
        final List<String> replies =
            (doc['replies'] as List?)?.map((e) => e.toString()).toList() ?? [];
        bool isReplied = replies.contains(widget.docId);
        if (isReplied) {
          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.black38),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0, top: 10),
              child: Text(
                "Your response has been recorded",
                style: TextStyle(color: Colors.white60),
              ),
            ),
          );
        } else {
          return Form(
            key: _form,
            child: Container(
              height: 65,
              child: TextFormField(
                initialValue: _reply,
                enabled: true,
                onChanged: (String value) {
                  print('value');
                  _reply = value;
                },
                style: TextStyle(
                  color: Colors.white60,
                ),
                expands: true,
                maxLines: null,
                decoration: InputDecoration(
                  fillColor: Colors.white30,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                      borderRadius: BorderRadius.circular(10)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                      borderRadius: BorderRadius.circular(10)),
                  labelText: 'Enter your reply',
                  labelStyle: TextStyle(
                    color: Colors.white30,
                  ),
                  suffix: _isLoading
                      ? Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                      : IconButton(
                          icon: Icon(Icons.send, color: Colors.white30),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await snapshot.data!.reference.update(
                              {
                                'replies': FieldValue.arrayUnion([widget.docId])
                              },
                            );
                            await FirebaseFirestore.instance
                                .collection('Replies')
                                .add(
                              {
                                'message': _reply,
                                'title': widget.docTitle,
                                'time': DateTime.now()
                              },
                            );
                            Fluttertoast.showToast(msg: 'Replied!');
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
