import 'package:cloud_firestore/cloud_firestore.dart';

class LikedByUser {
  final String uid;
  final DateTime likedAt;

  LikedByUser({
    required this.uid,
    required this.likedAt,
  });

  factory LikedByUser.fromJson(Map<String, dynamic> json) {
    return LikedByUser(
      uid: json['uid'] as String,
      likedAt: (json['likedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'likedAt': Timestamp.fromDate(likedAt),
    };
  }
}
