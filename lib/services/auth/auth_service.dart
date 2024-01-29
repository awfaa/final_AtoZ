import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign in
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //add a new document for the user in users collection if it doesn't exist
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'uid': userCredential.user!.uid,
      }, SetOptions(merge: true));

      return userCredential;
    }

    // catch errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

//create a new user
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //after creating user, create a document for the user in the user collections
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'uid': userCredential.user!.uid,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
