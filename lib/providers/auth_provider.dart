import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;

  UserModel? get user => _user;

  AuthenticationProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null && firebaseUser.emailVerified) {
      try {
        final doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          _user = UserModel.fromMap(doc.data()!);
          notifyListeners();
        }
      } catch (e) {
        print('Error loading user: $e');
      }
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUser();
      return true;
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
      return false;
    }
  }

  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error fetching role: $e');
      return null;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    String nickname,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await userCredential.user!.sendEmailVerification();

        // Default role is "user", can be changed manually in Firestore to "admin"
        await createUserDocument(
          userCredential.user!,
          name,
          nickname,
          role: "user",
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<void> createUserDocument(
    User user,
    String name,
    String nickname, {
    String role = "user",
  }) async {
    final userDoc = {
      'userId': user.uid,
      'email': user.email,
      'name': name,
      'nickname': nickname,
      'profileImage': '',
      'joinedDate': FieldValue.serverTimestamp(),
      'favorites': [],
      'role': role, // <-- tambahkan role di sini
    };
    await _firestore.collection('users').doc(user.uid).set(userDoc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google Sign-In canceled.');
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        await user.reload();
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          await _auth.signOut();
          return false;
        }

        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await createUserDocument(
            user,
            user.displayName ?? "No Name",
            "",
            role: "user",
          );
        }

        await loadUser();
        return true;
      }
      return false;
    } catch (e) {
      print('Google Sign-In error: $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
    }
  }
}
