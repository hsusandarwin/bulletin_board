// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProviderDate _$UserProviderDateFromJson(Map<String, dynamic> json) =>
    _UserProviderDate(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: json['role'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
    );

Map<String, dynamic> _$UserProviderDateToJson(_UserProviderDate instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'password': instance.password,
      'role': instance.role,
      'address': instance.address,
      'photo': instance.photo,
    };
