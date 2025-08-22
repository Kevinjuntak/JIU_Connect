import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  String? _nickname;

  String? get nickname => _nickname;

  /// Ambil data pengguna dari Firestore
  Future<void> fetchUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _nickname = doc.data()?['nickname'] ?? '';
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Fetch user error: $e');
    }
  }

 Future<void> updateUserProfile(String nickname, String? photoUrl) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId != null) {
      try {
        await _db.collection('users').doc(userId).update({
          'nickname': nickname,
          'photoUrl': photoUrl,
        });
      } catch (e) {
        throw Exception('Failed to update user profile: $e');
      }
    }
  }
  /// Update nickname di Firestore
  Future<bool> updateNickname(String newNickname) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nickname': newNickname,
        });
        _nickname = newNickname;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update nickname error: $e');
    }
    return false;
  }
}
