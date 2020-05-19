
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petrolshare/models/UserModel.dart';


class AuthSevice{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  // auth change user stream
  Stream<UserModel> get user {
    return _auth.onAuthStateChanged.asyncMap((FirebaseUser user) async{
      if (user == null) return null;
      DocumentReference userRef = Firestore.instance.collection('users').document(user.uid);
      DocumentSnapshot userDoc = await userRef.get();
      if (!userDoc.exists) return UserModel(user.uid, user.displayName, user.photoUrl, false, null);  
      else return UserModel(user.uid, userDoc['name'], userDoc['photoURL'], true, null, user.email ?? user.phoneNumber);
    });
  }

  // sign in anonymously
  Future<FirebaseUser> signInAnon() async{

    /*
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      updateUserData(user);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
    */

    //presumably identical syntactic sugar
    
    return _auth.signInAnonymously()
    .then((result) => result.user)
    .catchError((error) {
        print(error.toString());
        return null;
    });
    
    
  }


  // sign in with email & password

  // sign in with Google
  Future<FirebaseUser> signInGoogle() async {

    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser user = await _auth.signInWithCredential(credential).then((AuthResult result) => result.user);
    if (user == null){
      return null;
    }
    return user;

  }

  // register with email & password

  // register with Google

  // sign out
  Future signOut() {
    return _auth.signOut().catchError((error) {
      print(error);
      return null;
    });
  }

}