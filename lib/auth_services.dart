import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authState => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required email,
    required String password,
    }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password);
  }
  Future<UserCredential> createAccount({
    required String firstName,
    required String lastName,
    required email,
    required String password,
    }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password);
  }
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
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
      await firebaseAuth.signOut();
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
    return user != null ? myUser(uid: user.uid) : null;
  }
  //auth change user stream
  Stream<myUser?> get user {
    return firebaseAuth.authStateChanges().map((User? user) => _userfromFirebase(user!));
  }
  Future signInAnon() async {
    try {
      UserCredential result = await firebaseAuth.signInAnonymously();
      User? user = result.user;
      return _userfromFirebase(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  
  
}
