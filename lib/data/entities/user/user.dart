// ignore_for_file: invalid_annotation_target

import 'package:bulletin_board/utils/converters/timestamp_con.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User{
  const factory User({
    required String id,
    @JsonKey(name: 'displayName') required String name,
    required String email,
    required String password,
    required bool role,
    required String address,
    String? profile,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt
  })= _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}