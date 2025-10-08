import 'package:bulletin_board/utils/converters/timestamp_con.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
abstract class Todo with _$Todo{
  const factory Todo({
    required String id,
    required String uid,
    required String title,
    required String description,
    required bool isPublish,
    required String? image,
    required int likesCount,
    required List<String> likedByUsers,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _Todo;
  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);

}