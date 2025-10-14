// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
  id: json['id'] as String,
  uid: json['uid'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  isPublish: json['isPublish'] as bool,
  image: json['image'] as String?,
  likesCount: (json['likesCount'] as num).toInt(),
  likedByUsers: const LikedByUserListConverter().fromJson(
    json['likedByUsers'] as List,
  ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'title': instance.title,
  'description': instance.description,
  'isPublish': instance.isPublish,
  'image': instance.image,
  'likesCount': instance.likesCount,
  'likedByUsers': const LikedByUserListConverter().toJson(
    instance.likedByUsers,
  ),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
