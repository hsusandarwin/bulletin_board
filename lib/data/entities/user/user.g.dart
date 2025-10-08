// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['displayName'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  role: json['role'] as bool,
  address: json['address'] as String,
  profile: json['profile'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.name,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'address': instance.address,
  'profile': instance.profile,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
