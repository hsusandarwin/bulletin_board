import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/profile/profile.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_update.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:bulletin_board/provider/user/user_notifier.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_add.dart';
import 'package:intl/intl.dart';

class ToDoListPage extends StatefulHookConsumerWidget {
  const ToDoListPage({super.key});

  @override
  ConsumerState<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends ConsumerState<ToDoListPage> {
  String insertLineBreaks(String text, {int limit = 15}) {
    final buffer = StringBuffer();
    int count = 0;
    for (var char in text.characters) {
      buffer.write(char);
      count++;
      if (count >= limit) {
        buffer.write('\n');
        count = 0;
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(publishedTodosProvider);
    final todosStream = todosAsync.when(
      data: (data) => data, // List<Todo>
      error: (e, stack) => <Todo>[], // return empty list or handle error
      loading: () => <Todo>[], // return empty list or placeholder
    );

    final topPosts = List<Todo>.from(todosStream)
    ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    final topFive = topPosts.take(5).toList();

    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final userAsync = ref.watch(userProviderStream(currentUid));
    final user = userAsync.when(
      data: (data) => data, // List<Todo>
      error: (e, stack) => null, // return empty list or handle error
      loading: () => null, // return empty list or placeholder
    );

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final isAdmin = user.role;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin
              ? AppLocalizations.of(context)!.adminHomePage
              : AppLocalizations.of(context)!.userHomePage,
          style: const TextStyle(fontSize: 20),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                  TextButton.icon(
                    onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: Text(currentUser?.displayName ?? 'User'),
                    ),
                IconButton(
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      title: AppLocalizations.of(context)!.confirmLogout,
                      confirmText: AppLocalizations.of(context)!.logout,
                      confirmIcon: Icons.logout,
                      confirmColor: Colors.red,
                      onConfirm: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          carouselSlider(topFive),
          SizedBox(height: 15),
          Text(
            AppLocalizations.of(context)!.publishPosts,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(child: todoPublishList(todosStream, currentUser)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: ToDoAddPage(),
            ),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  Card carouselSlider(List<Todo> topFive) {
    return Card(
      shadowColor: Colors.red,
      color: const Color(0xFFD3D6D3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: CarouselSlider(
        items: topFive.map((data) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    FutureBuilder<String>(
                      future: ref
                          .read(userRepositoryProvider)
                          .getUserName(data.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(".....");
                        }
                        return Text(
                          snapshot.data ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B6FAB),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      insertLineBreaks(data.title),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      insertLineBreaks(data.description),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.thumb_up),
                        SizedBox(width: 5),
                        Text("${data.likesCount}"),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child:
                        data.image != null && data.image.toString().isNotEmpty
                        ? Image.network(
                            data.image!,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: 180,
          enlargeCenterPage: true,
          autoPlay: true,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: true,
          autoPlayAnimationDuration: const Duration(milliseconds: 600),
          viewportFraction: 0.8,
        ),
      ),
    );
  }

  GridView todoPublishList(List<Todo> todos, User? currentUser) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: todos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final todoUid = todo.uid;

        final userNameFuture = ref
            .read(userRepositoryProvider)
            .getUserName(todoUid);

        return FutureBuilder<String>(
          future: userNameFuture,
          builder: (context, userSnapshot) {
            final todoUserName = userSnapshot.data ?? ".....";

            DateTime? createdAtDate = todo.createdAt;

            return Card(
              shadowColor: Colors.red,
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            todoUserName,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                              color: Color(0xFF3B6FAB),
                            ),
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final todoAsync = ref.watch(todoByIdProvider(todo.id));

                            return todoAsync.when(
                              data: (freshTodo) {
                                final likedBy = freshTodo.likedByUsers;
                                final isFavorite = likedBy.any((u) {
                                  return u.uid == currentUser?.uid;
                                });
                                final likeCount = freshTodo.likesCount;

                                return TextButton.icon(
                                  onPressed: () async {
                                    await ref
                                        .read(todoNotifierProvider.notifier)
                                        .toggleLike(todo.id, currentUser!.uid);
                                  },
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  label: Text("$likeCount"),
                                );
                              },
                              loading: () => const CircularProgressIndicator(strokeWidth: 2),
                              error: (err, _) => const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 3),
                        Text(
                          DateFormat('dd/MM/yyyy').format(createdAtDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      todo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child:
                          todo.image != null && todo.image.toString().isNotEmpty
                          ? Image.network(
                              todo.image!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (currentUser != null &&
                      currentUser.displayName == todoUserName)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: ToDoUpdatePage(
                                    id: todos[index].id,
                                    todoData:
                                        todos[index],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.white),
                            label: Text(
                              AppLocalizations.of(context)!.edit,
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              showConfirmationDialog(
                                context: context,
                                title: AppLocalizations.of(
                                  context,
                                )!.confirmDelete,
                                confirmText: AppLocalizations.of(
                                  context,
                                )!.delete,
                                confirmIcon: Icons.delete,
                                confirmColor: Colors.red,
                                onConfirm: () async {
                                  ref.read(loadingProvider.notifier).state =
                                      true;
                                  try {
                                    final todoRepo = ref.read(
                                      todoNotifierProvider.notifier,
                                    );
                                    final todoId = todos[index].id;
                                    await todoRepo.deleteTodo(todoId);
                                    if (context.mounted) {
                                      showSnackBar(
                                        context,
                                        AppLocalizations.of(
                                          context,
                                        )!.successDelete,
                                        Colors.green,
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showSnackBar(
                                        context,
                                        '${AppLocalizations.of(context)!.failDelete} - $e',
                                        Colors.red,
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      ref.read(loadingProvider.notifier).state =
                                          false;
                                    }
                                  }
                                },
                              );
                            },
                            icon: Icon(Icons.delete, color: Colors.white),
                            label: Text(
                              AppLocalizations.of(context)!.delete,
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
