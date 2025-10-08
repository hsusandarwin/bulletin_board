// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoState {

 String? get id; String get title; String get description; bool get isPublish; String get uid; String? get image; int get likesCount; List<String> get likedByUsers; String? get latitude; String? get longitude; String? get location; Uint8List? get imageData; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoStateCopyWith<TodoState> get copyWith => _$TodoStateCopyWithImpl<TodoState>(this as TodoState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoState&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublish, isPublish) || other.isPublish == isPublish)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.image, image) || other.image == image)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&const DeepCollectionEquality().equals(other.likedByUsers, likedByUsers)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.imageData, imageData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,isPublish,uid,image,likesCount,const DeepCollectionEquality().hash(likedByUsers),latitude,longitude,location,const DeepCollectionEquality().hash(imageData),createdAt,updatedAt);

@override
String toString() {
  return 'TodoState(id: $id, title: $title, description: $description, isPublish: $isPublish, uid: $uid, image: $image, likesCount: $likesCount, likedByUsers: $likedByUsers, latitude: $latitude, longitude: $longitude, location: $location, imageData: $imageData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TodoStateCopyWith<$Res>  {
  factory $TodoStateCopyWith(TodoState value, $Res Function(TodoState) _then) = _$TodoStateCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String description, bool isPublish, String uid, String? image, int likesCount, List<String> likedByUsers, String? latitude, String? longitude, String? location, Uint8List? imageData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$TodoStateCopyWithImpl<$Res>
    implements $TodoStateCopyWith<$Res> {
  _$TodoStateCopyWithImpl(this._self, this._then);

  final TodoState _self;
  final $Res Function(TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? isPublish = null,Object? uid = null,Object? image = freezed,Object? likesCount = null,Object? likedByUsers = null,Object? latitude = freezed,Object? longitude = freezed,Object? location = freezed,Object? imageData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublish: null == isPublish ? _self.isPublish : isPublish // ignore: cast_nullable_to_non_nullable
as bool,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,likedByUsers: null == likedByUsers ? _self.likedByUsers : likedByUsers // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageData: freezed == imageData ? _self.imageData : imageData // ignore: cast_nullable_to_non_nullable
as Uint8List?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoState].
extension TodoStatePatterns on TodoState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoState value)  $default,){
final _that = this;
switch (_that) {
case _TodoState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoState value)?  $default,){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String description,  bool isPublish,  String uid,  String? image,  int likesCount,  List<String> likedByUsers,  String? latitude,  String? longitude,  String? location,  Uint8List? imageData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isPublish,_that.uid,_that.image,_that.likesCount,_that.likedByUsers,_that.latitude,_that.longitude,_that.location,_that.imageData,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String description,  bool isPublish,  String uid,  String? image,  int likesCount,  List<String> likedByUsers,  String? latitude,  String? longitude,  String? location,  Uint8List? imageData,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TodoState():
return $default(_that.id,_that.title,_that.description,_that.isPublish,_that.uid,_that.image,_that.likesCount,_that.likedByUsers,_that.latitude,_that.longitude,_that.location,_that.imageData,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String description,  bool isPublish,  String uid,  String? image,  int likesCount,  List<String> likedByUsers,  String? latitude,  String? longitude,  String? location,  Uint8List? imageData,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isPublish,_that.uid,_that.image,_that.likesCount,_that.likedByUsers,_that.latitude,_that.longitude,_that.location,_that.imageData,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TodoState implements TodoState {
  const _TodoState({this.id = '', this.title = '', this.description = '', this.isPublish = true, this.uid = '', this.image = '', this.likesCount = 0, final  List<String> likedByUsers = const [], this.latitude = '', this.longitude = '', this.location = '', this.imageData, this.createdAt, this.updatedAt}): _likedByUsers = likedByUsers;
  

@override@JsonKey() final  String? id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublish;
@override@JsonKey() final  String uid;
@override@JsonKey() final  String? image;
@override@JsonKey() final  int likesCount;
 final  List<String> _likedByUsers;
@override@JsonKey() List<String> get likedByUsers {
  if (_likedByUsers is EqualUnmodifiableListView) return _likedByUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_likedByUsers);
}

@override@JsonKey() final  String? latitude;
@override@JsonKey() final  String? longitude;
@override@JsonKey() final  String? location;
@override final  Uint8List? imageData;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoStateCopyWith<_TodoState> get copyWith => __$TodoStateCopyWithImpl<_TodoState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoState&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublish, isPublish) || other.isPublish == isPublish)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.image, image) || other.image == image)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&const DeepCollectionEquality().equals(other._likedByUsers, _likedByUsers)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.imageData, imageData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,isPublish,uid,image,likesCount,const DeepCollectionEquality().hash(_likedByUsers),latitude,longitude,location,const DeepCollectionEquality().hash(imageData),createdAt,updatedAt);

@override
String toString() {
  return 'TodoState(id: $id, title: $title, description: $description, isPublish: $isPublish, uid: $uid, image: $image, likesCount: $likesCount, likedByUsers: $likedByUsers, latitude: $latitude, longitude: $longitude, location: $location, imageData: $imageData, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TodoStateCopyWith<$Res> implements $TodoStateCopyWith<$Res> {
  factory _$TodoStateCopyWith(_TodoState value, $Res Function(_TodoState) _then) = __$TodoStateCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String description, bool isPublish, String uid, String? image, int likesCount, List<String> likedByUsers, String? latitude, String? longitude, String? location, Uint8List? imageData, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$TodoStateCopyWithImpl<$Res>
    implements _$TodoStateCopyWith<$Res> {
  __$TodoStateCopyWithImpl(this._self, this._then);

  final _TodoState _self;
  final $Res Function(_TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? isPublish = null,Object? uid = null,Object? image = freezed,Object? likesCount = null,Object? likedByUsers = null,Object? latitude = freezed,Object? longitude = freezed,Object? location = freezed,Object? imageData = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_TodoState(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublish: null == isPublish ? _self.isPublish : isPublish // ignore: cast_nullable_to_non_nullable
as bool,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,likedByUsers: null == likedByUsers ? _self._likedByUsers : likedByUsers // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,imageData: freezed == imageData ? _self.imageData : imageData // ignore: cast_nullable_to_non_nullable
as Uint8List?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
