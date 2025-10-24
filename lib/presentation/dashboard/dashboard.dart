import 'package:bulletin_board/data/entities/todo/todo.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/dashboard/widgets/navigator_drawer.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_update.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_add.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool isFavorite = false;
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text("No user logged in"));
    }

    final todosAsync = ref.watch(todosByUserProvider(currentUser.uid));
    final likedPostsAsync = ref.watch(getRecentLikesProvider);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          child: Icon(Icons.sort,size: 35,),
          onTap: (){_scaffoldKey.currentState?.openDrawer();},
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              AppLocalizations.of(context)!.dashboard,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),
      drawer: const NavigatorDrawer(),
      body: todosAsync.when(
        data: (todos) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  AppLocalizations.of(context)!.likedPosts,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: likedPostsAsync.when(
                  data: (likedPosts) {
                    if (likedPosts.isEmpty) {
                      return const Center(child: Text("No liked posts yet."));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: likedPosts.length,
                      itemBuilder: (context, index) {
                        final todo = likedPosts[index];
                        final imageUrl = todo.image ?? '';
                        final title = todo.title.isNotEmpty
                            ? todo.title
                            : '(No title)';
                        final description = todo.description.isNotEmpty
                            ? todo.description
                            : '(No description)';

                        return Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 24,
                                                    color: Colors.grey,
                                                  ),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          width: double.infinity,
                                          height: 70,
                                          child: const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 24,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Text(
                                    description,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),

              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.yourPosts,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(flex: 3, child: allTodoPosts(todos, currentUser)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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

  Widget allTodoPosts(List<Todo> todos, User? currentUser) {
    if (todos.isEmpty) {
      return const Center(child: Text("No published todos yet."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: todos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final todoUid = todo.uid;
        final isPublish = (todo.isPublish == true) ? 'Publish' : 'UnPublish';

        final userNameFuture = ref
            .read(userRepositoryProvider)
            .getUserName(todoUid);

        return FutureBuilder<String>(
          future: userNameFuture,
          builder: (context, userSnapshot) {
            final todoUserName = userSnapshot.data ?? "......";

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
                              color: Color(0xFF3777C1),
                            ),
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final todoAsync = ref.watch(
                              todoByIdProvider(todo.id),
                            );

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
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  label: Text("$likeCount"),
                                );
                              },
                              loading: () => const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                              error: (err, _) =>
                                  const Icon(Icons.error, color: Colors.red),
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
                      '($isPublish)',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: Color(0xFF3777C1),
                      ),
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
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: todo.image != null && todo.image!.isNotEmpty
                            ? FutureBuilder(
                                future: precacheImage(
                                  NetworkImage(todo.image!),
                                  context,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return Image.network(
                                    todo.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  );
                                },
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
                  ),
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
                                  todoData: todos[index],
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
                              confirmText: AppLocalizations.of(context)!.delete,
                              confirmIcon: Icons.delete,
                              confirmColor: Colors.red,
                              onConfirm: () async {
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
