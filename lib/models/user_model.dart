import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String nickname;
  final String profileImage;
  final Timestamp joinedDate;
  final List<String> favorites;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.nickname,
    required this.profileImage,
    required this.joinedDate,
    required this.favorites,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      profileImage: map['profileImage'] ?? '',
      joinedDate: map['joinedDate'] ?? Timestamp.now(),
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'nickname': nickname,
      'profileImage': profileImage,
      'joinedDate': joinedDate,
      'favorites': favorites,
    };
  }
  String get uid => userId;

 
}