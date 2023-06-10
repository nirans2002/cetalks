// import 'package:cetalks/news_corner/models/news.dart';
// import 'package:cetalks/providers/auth_provider.dart';
// import 'package:cetalks/screens/account_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import 'package:provider/provider.dart';

// import 'flutter_polls.dart';

// class PollWidget extends StatelessWidget {
//   final News news;

//   const PollWidget({Key key, this.news}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     if (news.pollOptions.length < 2) return Container();
//     return Card(
//       key: Key(news.id),
//       elevation: 0,
//       color: Colors.grey[900],
//       child: authProvider.isLoggedIn
//           ? StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(authProvider.currentUser.id)
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<DocumentSnapshot> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: Container(
//                         height: 30,
//                         width: 30,
//                         child: CircularProgressIndicator()),
//                   );
//                 }
//                 final doc = snapshot.data.data();

//                 /// polls is a map of type {id:'123544',choice:1}
//                 final List<Map> polls = doc['polls'] as List ?? [];
//                 bool didPoll = polls
//                     .map((e) => e['id'].toString())
//                     .toList()
//                     .contains(news.id);
//                 if (didPoll)
//                   return FlutterPolls.viewPolls(
//                     children: news.pollOptions
//                         .map(
//                           /// pollOptions will be a map like
//                           /// {choice:'Choice 1',votes:10}
//                           (pollOption) => FlutterPolls.options(
//                             title: pollOption['choice'].toString(),
//                             value: pollOption['votes'],
//                           ),
//                         )
//                         .toList(),
//                     question: Text(news.title),
//                     description: Text(news.subtitle ?? ''),
//                   );
//                 else {
//                   return FlutterPolls.castVote(
//                     children: news.pollOptions
//                         .map(
//                           /// pollOptions will be a map like
//                           /// {choice:'Choice 1',votes:10}
//                           (pollOption) => FlutterPolls.options(
//                             title: pollOption['choice'].toString(),
//                             value: pollOption['votes'],
//                           ),
//                         )
//                         .toList(),
//                     question: Text(news.title),
//                     description: Text(news.subtitle ?? ''),
//                     onVote: (choice) async {
//                       await FirebaseFirestore.instance
//                           .collection('news')
//                           .doc(news.id)
//                           .update({'pollOptions': FieldValue.arrayUnion(elements)});
//                     },
//                   );
//                 }
//               },
//             )
//           : showPollwithoutVote(context),
//     );
//   }

//   FlutterPolls showPollwithoutVote(BuildContext context) {
//     return FlutterPolls.castVote(
//       children: news.pollOptions
//           .map(
//             /// pollOptions will be a map like
//             /// {choice:'Choice 1',votes:10}
//             (pollOption) => FlutterPolls.options(
//               title: pollOption['choice'].toString(),
//               value: pollOption['votes'],
//             ),
//           )
//           .toList(),
//       question: Text(news.title),
//       description: Text(news.subtitle ?? ''),
//       onVote: (choice) {
//         Fluttertoast.showToast(msg: 'Login to continue');
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => AccountPage(),
//           ),
//         );
//         return;
//       },
//     );
//   }
// }
