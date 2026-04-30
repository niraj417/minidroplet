/*
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tinydroplets/core/constant/app_export.dart';

import '../utils/shared_pref.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

    // Sign in with email and password

  Future<User?> signInWithEmail(String email, String password,
      {Duration timeoutDuration = const Duration(seconds: 10)}) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(timeoutDuration, onTimeout: () {
        throw TimeoutException(
            'The sign-in operation timed out after $timeoutDuration.');
      });

      String idToken = await userCredential.user?.getIdToken() ?? '';

      CommonMethods.devLog(
          logName: 'Login successfully \n Email: $email \n Password: $password',
          message: 'Access Token: ${userCredential.credential?.accessToken}\n'
              'ID Token: $idToken\n'
              'User UID: ${userCredential.user?.uid}\n'
              'User Email: ${userCredential.user?.email}\n'
              'Display Name: ${userCredential.user?.displayName}\n');

      return userCredential.user;
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String idToken = await userCredential.user?.getIdToken() ?? '';
      CommonMethods.devLog(
          logName:
              'Sign up successfully \n Email: $email \n Password: $password',
          message: 'ID Token: $idToken\n'
              'User UID: ${userCredential.user?.uid}\n'
              'User Email: ${userCredential.user?.email}\n'
              'Display Name: ${userCredential.user?.displayName}\n');
      return userCredential.user;
    } catch (e) {
      CommonMethods.devLog(logName: 'error', message: e.toString());
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      CommonMethods.devLog(
          logName: 'Sign out successfully', message: 'User signed out');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Add data to Firestore
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      print('Error adding data: $e');
      rethrow;
    }
  }

  // Get data from Firestore
  Future<List<Map<String, dynamic>>> getData(String collection) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(collection).get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting data: $e');
      rethrow;
    }
  }
}
*/
