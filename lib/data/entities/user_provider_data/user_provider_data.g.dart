// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProviderData _$UserProviderDataFromJson(Map<String, dynamic> json) =>
    _UserProviderData(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      providerType: json['providerType'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
    );

Map<String, dynamic> _$UserProviderDataToJson(_UserProviderData instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'providerType': instance.providerType,
      'photo': instance.photo,
    };
