// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_provider_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProviderData {

 String get uid; String get email; String get name; String get password; bool get role; String get address; String get photo;
/// Create a copy of UserProviderData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProviderDataCopyWith<UserProviderData> get copyWith => _$UserProviderDataCopyWithImpl<UserProviderData>(this as UserProviderData, _$identity);

  /// Serializes this UserProviderData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProviderData&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.address, address) || other.address == address)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,name,password,role,address,photo);

@override
String toString() {
  return 'UserProviderData(uid: $uid, email: $email, name: $name, password: $password, role: $role, address: $address, photo: $photo)';
}


}

/// @nodoc
abstract mixin class $UserProviderDataCopyWith<$Res>  {
  factory $UserProviderDataCopyWith(UserProviderData value, $Res Function(UserProviderData) _then) = _$UserProviderDataCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String name, String password, bool role, String address, String photo
});




}
/// @nodoc
class _$UserProviderDataCopyWithImpl<$Res>
    implements $UserProviderDataCopyWith<$Res> {
  _$UserProviderDataCopyWithImpl(this._self, this._then);

  final UserProviderData _self;
  final $Res Function(UserProviderData) _then;

/// Create a copy of UserProviderData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? name = null,Object? password = null,Object? role = null,Object? address = null,Object? photo = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as bool,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProviderData].
extension UserProviderDataPatterns on UserProviderData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProviderData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProviderData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProviderData value)  $default,){
final _that = this;
switch (_that) {
case _UserProviderData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProviderData value)?  $default,){
final _that = this;
switch (_that) {
case _UserProviderData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String name,  String password,  bool role,  String address,  String photo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProviderData() when $default != null:
return $default(_that.uid,_that.email,_that.name,_that.password,_that.role,_that.address,_that.photo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String name,  String password,  bool role,  String address,  String photo)  $default,) {final _that = this;
switch (_that) {
case _UserProviderData():
return $default(_that.uid,_that.email,_that.name,_that.password,_that.role,_that.address,_that.photo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String name,  String password,  bool role,  String address,  String photo)?  $default,) {final _that = this;
switch (_that) {
case _UserProviderData() when $default != null:
return $default(_that.uid,_that.email,_that.name,_that.password,_that.role,_that.address,_that.photo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProviderData implements UserProviderData {
  const _UserProviderData({this.uid = '', this.email = '', this.name = '', this.password = '', this.role = false, this.address = '', this.photo = ''});
  factory _UserProviderData.fromJson(Map<String, dynamic> json) => _$UserProviderDataFromJson(json);

@override@JsonKey() final  String uid;
@override@JsonKey() final  String email;
@override@JsonKey() final  String name;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool role;
@override@JsonKey() final  String address;
@override@JsonKey() final  String photo;

/// Create a copy of UserProviderData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProviderDataCopyWith<_UserProviderData> get copyWith => __$UserProviderDataCopyWithImpl<_UserProviderData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProviderDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProviderData&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.password, password) || other.password == password)&&(identical(other.role, role) || other.role == role)&&(identical(other.address, address) || other.address == address)&&(identical(other.photo, photo) || other.photo == photo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,name,password,role,address,photo);

@override
String toString() {
  return 'UserProviderData(uid: $uid, email: $email, name: $name, password: $password, role: $role, address: $address, photo: $photo)';
}


}

/// @nodoc
abstract mixin class _$UserProviderDataCopyWith<$Res> implements $UserProviderDataCopyWith<$Res> {
  factory _$UserProviderDataCopyWith(_UserProviderData value, $Res Function(_UserProviderData) _then) = __$UserProviderDataCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String name, String password, bool role, String address, String photo
});




}
/// @nodoc
class __$UserProviderDataCopyWithImpl<$Res>
    implements _$UserProviderDataCopyWith<$Res> {
  __$UserProviderDataCopyWithImpl(this._self, this._then);

  final _UserProviderData _self;
  final $Res Function(_UserProviderData) _then;

/// Create a copy of UserProviderData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? name = null,Object? password = null,Object? role = null,Object? address = null,Object? photo = null,}) {
  return _then(_UserProviderData(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as bool,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
