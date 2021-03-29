import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthSevice {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // auth change user stream
  Stream<User> get user {
    debugPrint("AuthService, user state changed");
    return _auth.authStateChanges();
  }

  // sign in anonymously
  Future<User> signInAnon() async {
    /*
    try {
      AuthResult result = await _auth.signInAnonymously();
      User user = result.user;
      updateUserData(user);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
    */

    //presumably identical syntactic sugar

    return _auth
        .signInAnonymously()
        .then((result) => result.user)
        .catchError((error) {
      debugPrint(error.toString());
      return null;
    });
  }

  // sign in with email & password

  // sign in silently with Google
  Future<User> signInSilentlyGoogle() async {
    GoogleSignInAccount googleUser;
    User user;

    try {
      googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) throw 'SignIn Silently failed';
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = await _auth
          .signInWithCredential(credential)
          .then((UserCredential result) => result.user);
    } catch (e) {
      debugPrint("AuthService, Silent Google Sign in failed: " + e.toString());
    }

    if (user == null) {
      return null;
    }
    return user;
  }

  // sign in with Google
  Future<User> signInGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    User user = await _auth
        .signInWithCredential(credential)
        .then((UserCredential result) => result.user);
    if (user == null) {
      return null;
    }
    return user;
  }

  // register with email & password

  // sign out
  Future signOut() async {
    bool googleUser = await _googleSignIn.isSignedIn();
    User user = _auth.currentUser;

    try {
      if (googleUser) {
        await _googleSignIn.signOut();
      } else if (user.isAnonymous) {
        return user.delete();
      }

      return _auth.signOut();
    } catch (e) {
      debugPrint("AuthService, Logout: " + e.toString());

      return null;
    }
  }

  Future<void> changeUsername(String username) async {
    User user = _auth.currentUser;

    try {
      await user.updateProfile(displayName: username);
    } catch (e) {
      return Future.error(e);
    }

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return userRef.update({"name": username});
  }

  Future<void> deleteAccount() async {
    User user = _auth.currentUser;

    bool googleUser = await _googleSignIn.isSignedIn();

    if (googleUser) {
      await _googleSignIn.signOut();
    }

    await user.delete();

    return;
  }
}
