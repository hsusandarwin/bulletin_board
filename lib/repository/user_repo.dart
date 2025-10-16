import 'dart:io';
import 'package:bulletin_board/config/logger.dart';
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/data/entities/user_provider_data/user_provider_data.dart';
import 'package:bulletin_board/storage/provider_setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseUserRepository {
  auth.User? get getCurrentUser;
  Stream<User?> getUserStream({required String userId});
  Future<User?> getUserFuture({required String userId});
  Stream<auth.User?> authUserStream();
  Future<void> register(User user);
  Future<auth.User?> signInWithGoogle();
  Future<bool> isEmailRegistered(String email);
  Future<User?> getUserByEmail(String email);
  Future<void> saveUserToFirestore(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<void> deleteUserByAdmin(
    String userId,
    String adminEmail,
    String adminPassword,
  );
  Future<void> deleteFromStorage(String url);
  Future<void> addUser(User user, String adminEmail, String adminPassword);
  Future<void> signOut();
  Future<void> create(String authUserId);
  Future<void> updateProvider(User user);
  String get generateNewId;
  Future<auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String?> uploadProfileImage(File imageFile, String userId);
  Future<void> updateDisplayName(String userId, String name);
  Future<String?> loadProfileImage(String userId);
  Future<String> getUserName(String uid);
  Future<void> updateProfileUser(User user);
  Future<String?> uploadProfilePhoto(File imageFile, String userId);
  Future<void> updateProfileDisplayName(String userId, String name);
  Future<void> updateEmail(String userId, String email);
  Future<void> updateAddress(String userId, String address);
  Future<String?> loadProfilePhoto(String userId);
  Stream<List<User>> fetchUsers();
}

final userRepositoryProvider = Provider<UserRepositoryImpl>(
  (ref) => UserRepositoryImpl(),
);

class UserRepositoryImpl implements BaseUserRepository {
  final _auth = auth.FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _userDB = FirebaseFirestore.instance.collection('users');
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  @override
  auth.User? get getCurrentUser => _auth.currentUser;

  @override
  String get generateNewId => _userDB.doc().id;

  @override
  Stream<User?> getUserStream({required String userId}) {
    return _userDB.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      } else {
        return null;
      }
    });
  }

  @override
  Future<void> deleteFromStorage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      return;
    }
  }

  @override
  Future<void> updateProfileUser(User user) async {
    await _userDB.doc(user.id).update(user.toJson());
  }

  @override
  Future<void> updateProfileDisplayName(String userId, String name) async {
    await _userDB.doc(userId).update({'displayName': name});
  }

  @override
  Future<void> updateEmail(String userId, String email) async {
    await _userDB.doc(userId).update({'email': email});
  }

  @override
  Future<void> updateAddress(String userId, String address) async {
    await _userDB.doc(userId).update({'address': address});
  }

  @override
  Future<String?> uploadProfilePhoto(File imageFile, String userId) async {
    final ref = _storage.ref().child('profiles/$userId.jpg');
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();
    await _userDB.doc(userId).update({'profile': downloadUrl});
    return downloadUrl;
  }

  @override
  Future<String?> loadProfilePhoto(String userId) async {
    final doc = await _userDB.doc(userId).get();
    return doc.data()?['profile'];
  }

  @override
  Future<void> addUser(
    User user,
    String adminEmail,
    String adminPassword,
  ) async {
    try {
      final userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
      await userCredential.user?.updateDisplayName(user.name);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());
      await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email is already used');
      } else if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak');
      } else {
        throw Exception('Failed to add user: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final docRef = _userDB.doc(userId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        logger.w('User $userId does not exist');
        return;
      }
      await docRef.delete();
      logger.i('User $userId deleted successfully');
    } catch (error, stackTrace) {
      logger.e(
        'Error deleting user: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteUserByAdmin(
    String userId,
    String adminEmail,
    String adminPassword,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('users').doc(userId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) throw Exception('User not found');

      final data = snapshot.data();
      final userEmail = data?['email'] as String?;
      final userPassword = data?['password'] as String?;

      if (userEmail == null || userPassword == null) {
        throw Exception('User email or password missing in database');
      }

      final authInstance = auth.FirebaseAuth.instance;
      final admin = authInstance.currentUser;
      if (admin == null) throw Exception('Admin not logged in');
      await authInstance.signOut();
      final userCredential = await authInstance.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );
      await userCredential.user?.delete();
      await docRef.delete();
      await authInstance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      logger.i('User $userId deleted successfully by admin $adminEmail');
    } on auth.FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Exception while deleting user: $e');
      throw Exception('FirebaseAuth error: ${e.message}');
    } catch (e, st) {
      logger.e('Error deleting user: $e', error: e, stackTrace: st);
      throw Exception('Failed to delete user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _userDB.doc(user.id).set(user.toJson());
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == user.id) {
        if (user.name.isNotEmpty && user.name != currentUser.displayName) {
          await currentUser.updateDisplayName(user.name);
        }
        if (user.email.isNotEmpty && user.email != currentUser.email) {
          await currentUser.verifyBeforeUpdateEmail(user.email);
        }
        if (user.password.isNotEmpty) {
          await currentUser.updatePassword(user.password);
        }
        await currentUser.reload();
      }
    } on auth.FirebaseAuthException catch (error) {
      logger.e('Error updating user in FirebaseAuth: $error');
      throw Exception('Failed to update user: ${error.message}');
    } catch (e) {
      logger.e('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> register(User user) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await userCredential.user!.updateDisplayName(user.name);
      await _userDB.doc(userCredential.user!.uid).set(user.toJson());
      await CurrentProviderSetting().update(providerId: 'password');
    } on auth.FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        throw Exception('Email is already used');
      } else if (error.code == 'weak-password') {
        throw Exception('The password provided is too weak');
      }
      throw Exception('Registration failed: ${error.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<bool> isEmailRegistered(String? email) async {
    if (email == null || email.trim().isEmpty) return false;

    final user = await getUserByEmail(email);
    return user != null;
  }

  @override
  Future<User?> getUserByEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return null;

    final normalizedEmail = email.trim().toLowerCase();

    try {
      final querySnapshot = await _userDB
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return User.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to fetch user by email: $e');
    }
  }

  @override
  Future<void> saveUserToFirestore(User user) async {
    try {
      await _userDB.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to save user to Firestore: $e');
    }
  }

  @override
  Future<auth.User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      await CurrentProviderSetting().update(providerId: 'google.com');
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      logger.e('Google Sign-In Error: $e');
      return Future.error(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final providerId = await CurrentProviderSetting().get() ?? '';
      if (providerId.contains('google.com')) {
        await GoogleSignIn().signOut();
      }
      await _auth.signOut();
    } catch (e) {
      logger.e('⚡ ERROR in signOut: $e');
      rethrow;
    }
  }

  @override
  Future<auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final cloudinary = CloudinaryPublic(
        'dkoddd9bd',
        'test-preset',
        cache: false,
      );

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final imageUrl = response.secureUrl;

      await _userDB.doc(userId).update({"profileImage": imageUrl});

      return imageUrl;
    } on CloudinaryException catch (e) {
      logger.e("Cloudinary error: ${e.message}");
      return null;
    } catch (e) {
      logger.e("Unexpected error uploading image: $e");
      return null;
    }
  }

  @override
  Future<void> updateDisplayName(String userId, String name) async {
    try {
      await _userDB.doc(userId).update({'displayName': name});
      await _auth.currentUser?.updateDisplayName(name);
    } catch (e) {
      logger.e("Error updating display name: $e");
      throw Exception("Error updating display name: $e");
    }
  }

  @override
  Future<String?> loadProfileImage(String userId) async {
    try {
      final doc = await _userDB.doc(userId).get();
      if (doc.exists && doc.data()?['profileImage'] != null) {
        return doc['profileImage'];
      }
      return null;
    } catch (e) {
      logger.e("Error loading profile image: $e");
      return null;
    }
  }

  @override
  Stream<auth.User?> authUserStream() => _auth.authStateChanges();

  @override
  Future<User?> getUserFuture({required String userId}) async {
    final doc = await _userDB.doc(userId).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  @override
  Future<String> getUserName(String uid) async {
    final userDoc = await _userDB.doc(uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('displayName')) {
      return userDoc['displayName'];
    }
    return "Unknown";
  }

  @override
  Future<void> create(String authUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final userProviderData = UserProviderData(
      name: currentUser.displayName ?? '',
      email: currentUser.email!,
      providerType: currentUser.providerData.first.providerId == 'password'
          ? 'email/password'
          : currentUser.providerData.first.providerId,
      uid: currentUser.providerData.first.uid!,
    );

    final newUser = User(
      id: authUserId,
      name: currentUser.displayName ?? 'New User',
      email: currentUser.email!,
      password: '',
      role: false,
      address: '',
      profile: '',
      providerData: [userProviderData],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    debugPrint('Saving user: ${newUser.toJson()}');

    await _userDB.doc(authUserId).set(newUser.toJson());
  }

  @override
  Future<void> updateProvider(User user) async {
    final currentUser = _auth.currentUser!;
    final authProviderType = currentUser.providerData.first.providerId;
    final providerList = user.providerData ?? [];

    final providerExists = providerList.any(
      (provider) =>
          provider.providerType ==
          (authProviderType == 'password'
              ? 'email/password'
              : authProviderType),
    );

    if (!providerExists) {
      final newProviderData = UserProviderData(
        name: currentUser.displayName ?? '',
        email: currentUser.email!,
        providerType: authProviderType == 'password'
            ? 'email/password'
            : authProviderType,
        uid: currentUser.providerData.first.uid!,
        photo: currentUser.photoURL ?? '',
      );

      final updatedUser = user.copyWith(
        providerData: [...providerList, newProviderData],
        updatedAt: DateTime.now(),
      );
      await _userDB.doc(user.id).set(updatedUser.toJson());
    }
  }

  @override
  Stream<List<User>> fetchUsers() {
    return _userDB
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList(),
        );
  }
}
