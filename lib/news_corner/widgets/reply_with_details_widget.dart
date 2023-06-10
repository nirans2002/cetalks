import 'package:cetalks/news_corner/widgets/reply_form_widget.dart';
import 'package:cetalks/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../screens/account_page.dart';

class ReplyWithDetailsWidget extends StatelessWidget {
  const ReplyWithDetailsWidget(
      {Key? key, required this.docId, required this.docTitle})
      : super(key: key);

  final String docId;
  final String docTitle;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isLoggedIn) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: TextButton.icon(
            onPressed: () {
              Fluttertoast.showToast(msg: 'Login to continue');
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AccountPage()));
            },
            icon: Icon(Icons.reply),
            label: Text('Reply'),
            style: TextButton.styleFrom(
                onSurface: Colors.white, primary: Colors.white),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                )),
          );
        }
        final doc = snapshot.data!.data()!;
        final List<String> replies =
            (doc['replies'] as List?)?.map((e) => e.toString()).toList() ?? [];
        bool isReplied = replies.contains(docId);
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ReplyFormWidget(
                        docTitle: docTitle,
                        docId: docId,
                        docRef: snapshot.data!.reference,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                    onSurface: Colors.white, primary: Colors.white),
                icon: Icon(Icons.reply),
                label: Text('Reply'),
              ),
            ),
          );
        }
      },
    );
  }
}
