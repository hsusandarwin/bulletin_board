import 'dart:typed_data';

import 'package:bulletin_board/data/entities/address/address.dart';
import 'package:bulletin_board/data/enums/user_role/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    String? id,
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String profile,
    @Default(UserRole.user) UserRole role,
    Address? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    Uint8List? imageData,
  }) = _UserState;
}