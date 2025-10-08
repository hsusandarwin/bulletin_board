import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState{
  const factory AuthState({
    User? user,
    @Default('') String errorMsg,
    @Default(true) bool isLoading,
    @Default(false) bool isSuccess,
    @Default(false) bool isEmailSent,
  })= _AuthState;
}