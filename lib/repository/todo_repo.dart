import 'dart:io';
import 'package:bulletin_board/data/entities/todo/liked_by_user.dart';
import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';


final todoRepositoryProvider = Provider<TodoRepositoryImpl>(
  (ref) => TodoRepositoryImpl(),
);

abstract class BaseTodoRepository {
  String get generateNewId;
  Future<Todo> addTodo({
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
  });
  Stream<List<Todo?>> getRecentLikePostList();
    Future<void> deleteTodoListByUser(String uid);
}

class TodoRepositoryImpl implements BaseTodoRepository {
  final _todoDB = FirebaseFirestore.instance.collection('todos');
  final _cloudinary = CloudinaryPublic(
    'dkoddd9bd', 
    'test-preset', 
    cache: false,
  );

  @override
  String get generateNewId => _todoDB.doc().id;

  @override
  Future<Todo> addTodo({
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
  }) async {
    final newId = generateNewId;
    String? imageUrl;
    if (imageFile != null && imageFile.existsSync()) {
      try {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            resourceType: CloudinaryResourceType.Image,
            folder: "todo_images",
            publicId: newId,
          ),
        );
        imageUrl = response.secureUrl;
      } catch (e) {
        throw Exception("Image upload failed: $e");
      }
    }
    final todo = Todo(
      id: newId,
      title: title,
      description: description,
      isPublish: isPublish,
      image: imageUrl,
      uid: uid,
      likesCount: 0,
      likedByUsers: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _todoDB.doc(newId).set({
      ...todo.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return todo;
  }


@override
Stream<List<Todo>> getRecentLikePostList() {
  return auth.FirebaseAuth.instance.authStateChanges().switchMap((user) {
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final todos = snapshot.docs.map((doc) {
        final raw = doc.data();
        final safeData = {
          ...raw,
          'id': doc.id,
          'likesCount': raw['likesCount'] ?? 0,
          'likedByUsers': raw['likedByUsers'] ?? <dynamic>[],
          'createdAt': raw['createdAt'] ?? Timestamp.now(),
          'updatedAt': raw['updatedAt'] ?? Timestamp.now(),
        };
        return Todo.fromJson(safeData);
      }).toList();
      final likedByUser = todos.where((todo) {
        return todo.likedByUsers.any((like) => like.uid == user.uid);
      }).toList();

      likedByUser.sort((a, b) {
        final aLike = a.likedByUsers.firstWhere(
          (like) => like.uid == user.uid,
          orElse: () => LikedByUser(uid: user.uid, likedAt: DateTime(0)),
        );
        final bLike = b.likedByUsers.firstWhere(
          (like) => like.uid == user.uid,
          orElse: () => LikedByUser(uid: user.uid, likedAt: DateTime(0)),
        );
        return bLike.likedAt.compareTo(aLike.likedAt);
      });

      return likedByUser.take(5).toList();
    });
  });
}


  @override
  Future<void> deleteTodoListByUser(String uid) async {
    try {
      final todosSnapshot = await FirebaseFirestore.instance
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .get();

      for (final doc in todosSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete todos by user UID: $e');
    }
  }

}