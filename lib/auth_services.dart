import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/user.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCredential?> loginWithGoogle() async {
    try {
     final googleUser = await GoogleSignIn().signIn();
    
     final googleAuth = await googleUser?.authentication;

     final cred = GoogleAuthProvider.credential(
       idToken: googleAuth?.idToken,
       accessToken: googleAuth?.accessToken,
     );
     return await _auth.signInWithCredential(cred);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
  Future<User?> signInAccount({
    required email,
    required String password,
    }) async {
      try {
            final cred = await _auth.signInWithEmailAndPassword(
      email: email, password: password);
      return cred.user;
      } catch (e) {
        print("Something went wrong");
      }
      return null;
  }
  Future<User?> createAccount({
    required email,
    required String password,
    }) async {
      try {
            final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
      return cred.user;
      } catch (e) {
        print("Something went wrong");
      }
      return null;
  }
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Something went wrong");
    }
  }
  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  Future<void> updateUsername({
    required String username,
    }) async {
    await currentUser!.updateDisplayName(username);
  }
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = 
      EmailAuthProvider.credential(email: email, password: password);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete(); 
      await _auth.signOut();
  }
  Future<void> resetPasswordFromCurrentPassword({
    required String currentpassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: currentpassword);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
  }
  //create a user object based on the firebase user
  myUser? _userfromFirebase(User user) {
    // ignore: unnecessary_null_comparison
    return user != null ? myUser(uid: user.uid) : null;
  }
  //auth change user stream
  Stream<myUser?> get user {
    return _auth.authStateChanges().map((User? user) => _userfromFirebase(user!));
  }
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userfromFirebase(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  Future <void> sendEmailVerificationLink() async {
    try {
     await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }
  
  
}
