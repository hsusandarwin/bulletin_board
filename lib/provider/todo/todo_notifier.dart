import 'dart:io';
import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/repository/todo_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final todoRepositoryProvider = Provider<TodoRepositoryImpl>((ref) {
  return TodoRepositoryImpl();
});

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>(
  (ref) => TodoNotifier(ref),
);

final getRecentLikesProvider = StreamProvider<List<Todo>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getRecentLikePostList();
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  final Ref ref;
  final TodoRepositoryImpl _repo = TodoRepositoryImpl();
  final _todoDB = FirebaseFirestore.instance.collection('todos');
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dkoddd9bd', 
    'test-preset',
    cache: false,
  );

  TodoNotifier(this.ref) : super([]);

  Future<void> addTodo({
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
    required BuildContext context,
  }) async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      final existing = await FirebaseFirestore.instance
        .collection('todos')
        .where('uid', isEqualTo: uid)
        .where('title', isEqualTo: title) 
        .get();

      if (existing.docs.isNotEmpty) {
        if (context.mounted) {
          showSnackBar(context, 'A todo with this title already exists!', Colors.red);
        }
        return; 
      }

      final todo = await _repo.addTodo(
        title: title,
        description: description,
        isPublish: isPublish,
        uid: uid,
        imageFile: imageFile,
      );
      state = [...state, todo];
      if (context.mounted) {
          showSnackBar(context, AppLocalizations.of(context)!.successAdd, Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, e.toString(), Colors.red);
      }
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    required String description,
    required bool isPublish,
    required String uid,
    File? imageFile,
    required BuildContext context,
  }) async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      String? imageUrl;
      if (imageFile != null) {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFile.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        imageUrl = response.secureUrl;
      }
      final updatedData = {
        'title': title,
        'description': description,
        'isPublish': isPublish,
        'userId': uid,
        if (imageUrl != null) 'image': imageUrl,
        'updatedAt': DateTime.now(),
      };
      await _todoDB.doc(id).update(updatedData);
      state = [
        for (final todo in state)
          if (todo.id == id)
            todo.copyWith(
              title: title,
              description: description,
              isPublish: isPublish,
              uid: uid,
              image: imageUrl ?? todo.image,
              updatedAt: DateTime.now(),
            )
          else
            todo,
      ];
      if (context.mounted) {
          showSnackBar(context, AppLocalizations.of(context)!.successUpdate, Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context,'${AppLocalizations.of(context)!.failDelete} - $e', Colors.red);
      }
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoDB.doc(todoId).delete();
      state = state.where((todo) => todo.id != todoId).toList();
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

 Future<void> deleteTodoByUser(String uid) async {
  try {
    ref.read(loadingProvider.notifier).state = true;

    final todosSnapshot = await FirebaseFirestore.instance
        .collection('todos')
        .where('uid', isEqualTo: uid)
        .get();

    for (final doc in todosSnapshot.docs) {
      await doc.reference.delete();
    }

    state = state.where((todo) => todo.uid != uid).toList();
  } catch (e) {
    debugPrint('Error deleting user todos: $e');
    rethrow;
  } finally {
    ref.read(loadingProvider.notifier).state = false;
  }
}
  
}
