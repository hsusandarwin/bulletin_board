import 'dart:io';
import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/repository/todo_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final todoNotifierProvider = StateNotifierProvider<TodoNotifier, List<Todo>>(
  (ref) => TodoNotifier(ref),
);

final getRecentLikesProvider = StreamProvider<List<Todo>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getRecentLikePostList();
});

final todosByUserProvider = StreamProvider.family<QuerySnapshot, String>((ref, uid) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getTodosByUser(uid);
});

class TodoNotifier extends StateNotifier<List<Todo>> {
  final Ref ref;
  final TodoRepositoryImpl _repo;

  TodoNotifier(this.ref) 
      : _repo = ref.read(todoRepositoryProvider),
        super([]);

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
    if (context.mounted) showSnackBar(context, e.toString(), Colors.red);
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
      final updatedTodo = await _repo.updateTodo(
        id: id,
        title: title,
        description: description,
        isPublish: isPublish,
        uid: uid,
        imageFile: imageFile,
      );

      state = [
        for (final todo in state)
          if (todo.id == id) updatedTodo else todo,
      ];

      if (context.mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.successUpdate, Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) showSnackBar(context,'${AppLocalizations.of(context)!.failDelete} - $e', Colors.red);
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteTodo(String todoId) async {
    await _repo.deleteTodo(todoId);
    state = state.where((todo) => todo.id != todoId).toList();
  }

  Future<void> deleteTodoByUser(String uid) async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      await _repo.deleteTodoListByUser(uid);
      state = state.where((todo) => todo.uid != uid).toList();
    } catch (e) {
      debugPrint('Error deleting user todos: $e');
      rethrow;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
