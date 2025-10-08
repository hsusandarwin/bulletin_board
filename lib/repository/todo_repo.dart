import 'dart:io';
import 'dart:math' as logger;
import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hooks_riverpod/hooks_riverpod.dart';


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

    await _todoDB.doc(newId).set(todo.toJson());
    return todo;
  }


 @override
  Stream<List<Todo?>> getRecentLikePostList() {
    try {
      final user = auth.FirebaseAuth.instance.currentUser;
      final snapshotData = _todoDB 
          .where('likedByUsers', arrayContains: user!.uid) 
          .limit(5) 
          .snapshots();

      return snapshotData.map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Todo.fromJson(data);
        }).toList();
      });
    } on Exception catch (e) {
      logger.e;
      return Stream.error('$e');
    }
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