import 'package:bulletin_board/config/logger.dart';
import 'package:bulletin_board/data/entities/address/address.dart';
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/data/enums/user_role/user_role.dart';
import 'package:bulletin_board/provider/user/user_state.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userNotifierProvider = StateNotifierProvider.autoDispose
    .family<UserNotifier, UserState, User?>((ref, user) {
      final userRepo = ref.watch(userRepositoryProvider);
      return UserNotifier(user, userRepo);
    });

final userNameProvider = FutureProvider.family<String, String>((
  ref,
  uid,
) async {
  final repo = ref.read(userRepositoryProvider);
  return repo.getUserName(uid);
});

final userProviderFuture = FutureProvider.family<User?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserFuture(userId: userId);
});

final userProviderStream = StreamProvider.family<User?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStream(userId: userId);
});

final fetchUsersProvider = StreamProvider<List<User>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.fetchUsers();
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.user, this.userRepository) : super(UserState());

  final User? user;
  final BaseUserRepository userRepository;

  Future<User?> login(String email, String password) async {
    try {
      final credential = await userRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;
      var user = await userRepository.getUserByEmail(email);
      if (user == null) {
        user = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          password: password,
          role: UserRole.user,
          address: Address(name: '', location: ''),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await userRepository.saveUserToFirestore(user);
      } else {
        if (user.password != password) {
          user = user.copyWith(password: password, updatedAt: DateTime.now());
          await userRepository.updateUser(user);
        }
      }
      if (mounted) {
        state = state.copyWith(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          role: user.role,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        );
      }
      return user;
    } catch (e) {
      logger.e("Login failed: $e");
      return null;
    }
  }

  Future<String?> getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            (place.thoroughfare != null && place.thoroughfare != '')
            ? '${place.name}, ${place.thoroughfare}'
            : '${place.name}';
        address += (place.locality != null && place.locality != '')
            ? ', ${place.locality}'
            : '';
        address +=
            (place.administrativeArea != null && place.administrativeArea != '')
            ? ', ${place.administrativeArea}'
            : '';
        address += (place.country != null && place.country != '')
            ? ', ${place.country}'
            : '';

        return address;
      }
    } catch (e) {
      logger.e("Error during reverse geocoding: $e");
    }
    return null;
  }

  Future<void> updateAddress({
    required String name,
    required LatLng pickedLocation,
  }) async {
    if (user == null) {
      throw Exception('No user logged in');
    }
    final newAddress = Address(
      name: name,
      location: '${pickedLocation.latitude},${pickedLocation.longitude}',
    );

    await FirebaseFirestore.instance.collection('users').doc(user!.id).update({
      'address': newAddress.toJson(),
    });

    state = state.copyWith(address: newAddress);
  }
}
