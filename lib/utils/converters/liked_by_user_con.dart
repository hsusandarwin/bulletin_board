import 'package:bulletin_board/data/entities/todo/liked_by_user.dart';
import 'package:json_annotation/json_annotation.dart';

class LikedByUserListConverter
    implements JsonConverter<List<LikedByUser>, List<dynamic>> {
  const LikedByUserListConverter();

  @override
  List<LikedByUser> fromJson(List<dynamic> json) {
    return json.map((e) {
      if (e is String) {
        return LikedByUser(uid: e, likedAt: DateTime.now());
      } else if (e is Map<String, dynamic>) {
        return LikedByUser.fromJson(e);
      } else {
        throw Exception('Invalid likedByUser data: $e');
      }
    }).toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<LikedByUser> users) {
    return users.map((e) => e.toJson()).toList();
  }
}
