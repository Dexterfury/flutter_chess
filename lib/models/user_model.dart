import 'package:flutter_chess/constants.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String image;
  String createdAt;
  int playerRating;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.createdAt,
    required this.playerRating,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.email: email,
      Constants.image: image,
      Constants.createdAt: createdAt,
      Constants.playerRating: playerRating,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data[Constants.uid] ?? '',
      name: data[Constants.name] ?? '',
      email: data[Constants.email] ?? '',
      image: data[Constants.image] ?? '',
      createdAt: data[Constants.createdAt] ?? '',
      playerRating: data[Constants.playerRating] ?? 1200,
    );
  }
}
