import 'package:cetalks/global.dart';
import 'package:cetalks/providers/auth_provider.dart';
import 'package:cetalks/screens/account_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/pastep.dart';
import '../screens/episodedetail.dart';
import '../widgets/bottomplayer.dart';

List<PastEp> pastEpisodes = [];

Widget buildPastEpList(BuildContext context) {
  return Container(
    child: pastEpisodes.isEmpty
        ? Center(
            child: Text(
              'Something went wrong, Try again later',
              style: TextStyle(color: Colors.white),
            ),
          )
        : ListView.builder(
            // padding: EdgeInsets.only(bottom: 55),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, EpisodeDetail.routeName,
                      arguments: [pastEpisodes[index], pastEpisodes, index]);
                },
                child: Card(
                  margin: EdgeInsets.all(5),
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        child: Hero(
                          tag: pastEpisodes[index].artUrl +
                              pastEpisodes[index].epName,
                          child: Image(
                            image: NetworkImage(
                              pastEpisodes[index].artUrl,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        pastEpisodes[index].epName,
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        pastEpisodes[index].rjs,
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: pastEpisodes[index].isLikable
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                LikeButton(
                                  pastEp: pastEpisodes[index],
                                ),
                                Text(
                                  pastEpisodes[index].likes.toString(),
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
            itemCount: pastEpisodes.length,
          ),
  );
}

class LikeButton extends StatefulWidget {
  final PastEp pastEp;
  const LikeButton({
    Key? key,
    required this.pastEp,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isLoggedIn) {
      return GestureDetector(
          onTap: () {
            Fluttertoast.showToast(msg: 'Login to continue');
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AccountPage()));
          },
          child: Icon(
            Icons.favorite_border,
            color: Colors.white,
            size: 30,
          ));
    }
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.currentUser!.id)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return Container(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
              ));
        }
        final doc = snapshot.data!.data()!;
        final List<String> likes =
            (doc['likes'] as List?)?.map((e) => e.toString()).toList() ?? [];
        bool isLiked = likes.contains(widget.pastEp.docId);
        if (isLiked) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              final newlikes = likes
                  .where((element) => element != widget.pastEp.docId)
                  .toList();
              await snapshot.data!.reference.set(
                {'likes': newlikes},
              );
              await FirebaseFirestore.instance
                  .collection('PastEpisodes')
                  .doc(widget.pastEp.docId)
                  .update({'likes': FieldValue.increment(-1)});
              setState(() {
                _isLoading = false;
              });
            },
            child: Icon(
              Icons.favorite,
              size: 30,
              color: Colors.white,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              await snapshot.data!.reference.update(
                {
                  'likes': [...likes, widget.pastEp.docId]
                },
              );
              await FirebaseFirestore.instance
                  .collection('PastEpisodes')
                  .doc(widget.pastEp.docId)
                  .update({'likes': FieldValue.increment(1)});
              setState(() {
                _isLoading = false;
              });
            },
            child: Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 30,
            ),
          );
        }
      },
    );
  }
}

@override
Widget buildPastEpisodes(BuildContext context) {
  return Container(
    color: Theme.of(context).primaryColor,
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 85,
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('PastEpisodes')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              if (snapshot.hasData) {
                final listi = snapshot.data!;

                final pastEpSnapList = listi.docs;

                pastEpisodes = [];
                for (var i = 0; i < pastEpSnapList.length; i++) {
                  var currPastEp = pastEpSnapList[i].data();

                  if (currPastEp['artUrl'] == null ||
                      currPastEp['audioLocation'] == null ||
                      currPastEp['program'] == null ||
                      currPastEp['description'] == null ||
                      currPastEp['epName'] == null ||
                      currPastEp['rjs'] == null ||
                      currPastEp['duration'] == null) continue;
                  var pastEp = PastEp(
                      docId: pastEpSnapList[i].id,
                      duration: currPastEp['duration'],
                      artUrl: currPastEp['artUrl'],
                      audiLocation: currPastEp['audioLocation'],
                      program: currPastEp['program'],
                      description: currPastEp['description'],
                      epName: currPastEp['epName'],
                      isLikable: currPastEp['isLikable'] ?? false,
                      likes: currPastEp['likes'] ?? 0,
                      rjs: currPastEp['rjs']);
                  if (!pastEpisodes.contains(pastEp)) {
                    pastEpisodes.add(pastEp);
                  }
                }
              }
              return buildPastEpList(context);
            },
          ),
        ),
        StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;

            final mediaItem = screenState?.mediaItem;

            if (mediaItem == null || mediaItem.id == Config.liveUrl) {
              return SizedBox(height: 0);
            } else {
              print('Returning BOTTOM PLAYER');
              return BottomPlayer();
            }
          },
        )
      ],
    ),
  );
}

class ScreenState {
  final List<MediaItem>? queue;
  final MediaItem? mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

Stream<ScreenState> get _screenStateStream =>
    Rx.combineLatest3<List<MediaItem>?, MediaItem?, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            ScreenState(queue, mediaItem, playbackState));
