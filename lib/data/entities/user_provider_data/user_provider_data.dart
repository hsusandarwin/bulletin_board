import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_provider_data.freezed.dart';
part 'user_provider_data.g.dart';

@freezed
abstract class UserProviderData with _$UserProviderData{
  const factory UserProviderData({
    @Default('') String uid,
    @Default('') String email,
    @Default('') String name,
    @Default('') String password,
    @Default(false) bool role,
    @Default('') String address,
    @Default('') String photo
  }) = _UserProviderDate;

  factory UserProviderData.fromJson(Map<String, dynamic> json) => _$UserProviderDataFromJson(json);
}