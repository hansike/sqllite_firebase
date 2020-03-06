import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<String> loginGoogle();

  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  String getUserId();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser user;

  String getUserId() {
    String uid;
    if (user != null && user.uid != null) {
      uid = user.uid;
    } else {
      uid = "";
    }
    return uid;
  }

  Future<String> loginGoogle() async {
    GoogleSignInAccount account = await _googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await account.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);
    AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    user = authResult.user;
    return user.uid;
  }

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    user = null;
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}
