import 'package:bulletin_board/config/logger.dart';
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/provider/user/user_state.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userNotifierProvider = StateNotifierProvider.autoDispose.family<UserNotifier,UserState,User?>(
  (ref, user) {
    final userRepo = ref.watch(userRepositoryProvider);
    return UserNotifier(user,userRepo);
},);

final userProviderFuture = FutureProvider.family<User?,String>((ref, userId){
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserFuture(userId: userId);
});

final userProviderStream = StreamProvider.family<User?,String>((ref, userId){
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStream(userId: userId);
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
        role: false,
        address: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), 
      );
      await userRepository.saveUserToFirestore(user);
    } else {
      if (user.password != password) {
        user = user.copyWith(
          password: password,
          updatedAt: DateTime.now(),
        );
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
        address: user.address,
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

}

