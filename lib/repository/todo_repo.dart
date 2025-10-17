import 'dart:io';
import 'package:bulletin_board/config/logger.dart';
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
  Future<Todo> updateTodo({
    required String id,
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
  });
  Future<void> deleteTodo(String todoId);
  Future<void> deleteTodoListByUser(String uid);
  Stream<Todo> getTodoById(String id);
  Future<void> toggleLike({required String todoId, required String currentUid});
  Stream<List<Todo>> getRecentLikePostList();
  Stream<List<Todo>> getTodosByUser(String uid);
  Stream<List<Todo>> getPublishedTodos();
  Stream<List<Todo>> getUserTodos(String uid);
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
    final existing = await _todoDB
        .where('uid', isEqualTo: uid)
        .where('title', isEqualTo: title)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("A todo with this title already exists!");
    }

    final newId = generateNewId;
    String? imageUrl;

    if (imageFile != null && imageFile.existsSync()) {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: "todo_images",
          publicId: newId,
        ),
      );
      imageUrl = response.secureUrl;
      logger.i('add image --> $imageUrl');
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
  Future<Todo> updateTodo({
    required String id,
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null && imageFile.existsSync()) {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: "todo_images",
          publicId: id,
        ),
      );
      imageUrl = response.secureUrl;
      logger.f('image 2 --> $imageUrl');
    }

    final updatedData = {
      'title': title,
      'description': description,
      'isPublish': isPublish,
      'uid': uid,
      'image': imageUrl,
      'updatedAt': DateTime.now(),
    };
    logger.f('update todo --> $updatedData');

    await _todoDB.doc(id).update(updatedData);

    final snapshot = await _todoDB.doc(id).get();
    return Todo.fromJson({'id': snapshot.id, ...snapshot.data()!});
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    await _todoDB.doc(todoId).delete();
  }

  @override
  Future<void> deleteTodoListByUser(String uid) async {
    final todosSnapshot = await _todoDB.where('uid', isEqualTo: uid).get();
    for (final doc in todosSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Stream<List<Todo>> getTodosByUser(String uid) {
    return _todoDB
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  @override
  Stream<List<Todo>> getRecentLikePostList() {
    return auth.FirebaseAuth.instance.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value([]);

      return _todoDB
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
  Stream<List<Todo>> getPublishedTodos() {
    return _todoDB
        .where('isPublish', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  @override
  Stream<List<Todo>> getUserTodos(String uid) {
    return _todoDB
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  @override
  Stream<Todo> getTodoById(String id) {
    return _todoDB.doc(id).snapshots().map((doc) => Todo.fromJson(doc.data()!));
  }

  @override
  Future<void> toggleLike({
    required String todoId,
    required String currentUid,
  }) async {
    final docRef = _todoDB.doc(todoId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data() as Map<String, dynamic>;
    final List likedBy = List.from(data['likedByUsers'] ?? []);

    bool alreadyLiked = likedBy.any((u) {
      if (u is Map && u['uid'] != null) return u['uid'] == currentUid;
      if (u is String) return u == currentUid;
      return false;
    });

    if (alreadyLiked) {
      likedBy.removeWhere((u) {
        if (u is Map && u['uid'] != null) return u['uid'] == currentUid;
        if (u is String) return u == currentUid;
        return false;
      });

      await docRef.update({
        'likedByUsers': likedBy,
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      likedBy.add({'uid': currentUid, 'likedAt': Timestamp.now()});

      await docRef.update({
        'likedByUsers': likedBy,
        'likesCount': FieldValue.increment(1),
      });
    }
  }
}
