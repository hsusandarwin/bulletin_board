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
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  address: const NullableAddressConverters().fromJson(
    json['address'] as Map<String, dynamic>?,
  ),
  profile: json['profile'] as String?,
  providerData: (json['providerData'] as List<dynamic>?)
      ?.map(const UserProviderDataConverter().fromJson)
      .toList(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.name,
  'email': instance.email,
  'password': instance.password,
  'role': _$UserRoleEnumMap[instance.role]!,
  'address': const NullableAddressConverters().toJson(instance.address),
  'profile': instance.profile,
  'providerData': instance.providerData
      ?.map(const UserProviderDataConverter().toJson)
      .toList(),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$UserRoleEnumMap = {UserRole.admin: 'admin', UserRole.user: 'user'};
