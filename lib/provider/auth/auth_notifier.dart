import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/presentation/storage/provider_setting.dart';
import 'package:bulletin_board/provider/auth/auth_state.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/logger.dart';

final authNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return AuthStateNotifier(repo);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
   AuthStateNotifier(this._userRepository) : super(const AuthState());

  final BaseUserRepository _userRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void clearErrorMessage() {
    state = state.copyWith(errorMsg: '');
  }

  Future<void> register({
  required String email,
  required String password,
  required String name, 
  required String address,
  bool? role
}) async {
  try {
    final userToSave = User(
      id: _userRepository.generateNewId,
      name: name,
      email: email,
      password: password,
      profile: '',
      role: role ?? false, 
      address: address,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(), 
    );

    await _userRepository.register(userToSave);
    state = state.copyWith(
      user: userToSave,
      isLoading: false,
      isSuccess: true,
      errorMsg: '',
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      isSuccess: false,
      errorMsg: e.toString(),
    );
    rethrow; 
  }
}

Future<void> signInWithGoogle() async {
  state = state.copyWith(isLoading: true, errorMsg: '', isSuccess: false);

  try {
    final firebaseUser = await _userRepository.signInWithGoogle();
    if (firebaseUser == null) {
      throw Exception("Failed to sign in with Google. User is null.");
    }
    final email = firebaseUser.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) {
      throw Exception("Google account has no email.");
    }
    final existingUser = await _userRepository.getUserByEmail(email);

    if (existingUser != null) {
      state = state.copyWith(
        user: existingUser,
        isLoading: false,
        isSuccess: true,
      );
      return;
    }
    final userToSave = User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Google User',
      email: email,
      password: '', 
      profile: firebaseUser.photoURL ?? '',
      address: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      role: false,
    );

    await _userRepository.saveUserToFirestore(userToSave);

    state = state.copyWith(
      user: userToSave,
      isLoading: false,
      isSuccess: true,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMsg: e.toString(),
      isSuccess: false,
    );
    rethrow;
  }
}

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMsg: '', isSuccess: false);

    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return; 
      }

      final email = googleUser.email;
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser == null) {
        await _googleSignIn.signOut();
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMsg: 'Email is not registered',
        );
        return;
      }
      state = state.copyWith(
        user: existingUser,
        isLoading: false,
        isSuccess: true,
        errorMsg: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMsg: 'Google login failed: $e',
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = _userRepository.getCurrentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        state = state.copyWith(isEmailSent: true);
      }
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

   Future<bool> checkEmailVerified() async {
    try {
      auth.User? user = _userRepository.getCurrentUser;
      await user?.reload();
      user = _userRepository.getCurrentUser;
      if (user != null && user.emailVerified) {
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMsg: e.toString());
      return false;
    }
  }

  Future<bool> checkEmailVerification() async {
    bool checked = false;
    await auth.FirebaseAuth.instance.currentUser?.reload().then((_) {
      checked = auth.FirebaseAuth.instance.currentUser!.emailVerified;
    });
    return checked;
  }

  Future<void> signOut() async {
    await _userRepository.signOut();
    state = state.copyWith(isLoading: false, errorMsg: 'Logout Success');
  }

  Future<void> deleteAccount({
    required String? password,
    required String profileUrl,
  }) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No user logged in");

      final providerId = await CurrentProviderSetting().get() ?? '';

      if (profileUrl.isNotEmpty) {
        await _userRepository.deleteFromStorage(profileUrl);
      }
      if (providerId.contains('password')) {
        if (password == null || password.isEmpty) {
          throw Exception("Password is required for reauthentication");
        }
        final credential = auth.EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(credential);
      } else if (providerId.contains('google')) {
        final googleProvider = auth.GoogleAuthProvider();
        await currentUser.reauthenticateWithProvider(googleProvider);
      }

      await _userRepository.deleteUser(currentUser.uid);

      await currentUser.delete();

      await _userRepository.signOut();
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        logger.e("Reauthentication required: ${e.message}");
        throw Exception("Please log in again before deleting your account.");
      } else {
        logger.e("Auth Error: ${e.code} - ${e.message}");
        rethrow;
      }
    } catch (e) {
      logger.e("Delete Error: $e");
      rethrow;
    }
  }

}