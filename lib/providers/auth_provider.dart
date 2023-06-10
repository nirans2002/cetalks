import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  AuthProvider() {
    _googleSignIn.onCurrentUserChanged.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
    try {
      silentLogin();
    } catch (e) {
      print(e);
    }
  }

  Future logout() async {
    await _googleSignIn.signOut();
  }

  String get userName => _currentUser?.displayName ?? 'Guest';

  bool get isLoggedIn => _currentUser != null;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future silentLogin() async {
    _currentUser = await _googleSignIn.signInSilently();
    notifyListeners();
  }

  Future login() async {
    _currentUser = await _googleSignIn.signIn();
    FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.id)
        .set({'name': _currentUser!.displayName}, SetOptions(merge: true));
  }
}
