import 'package:freezed_annotation/freezed_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,

  @JsonValue('user')
  user,
}
