import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_provider_data.freezed.dart';
part 'user_provider_data.g.dart';

@freezed
abstract class UserProviderData with _$UserProviderData {
  const factory UserProviderData({
    @Default('') String uid,
    @Default('') String email,
    @Default('') String name,
    @Default('') String providerType,
    @Default('') String photo,
  }) = _UserProviderData;

  factory UserProviderData.fromJson(Map<String, dynamic> json) =>
      _$UserProviderDataFromJson(json);
}
