import 'package:bulletin_board/data/entities/todo/liked_by_user.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_update.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bulletin_board/presentation/todo_list/widgets/todo_add.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulHookConsumerWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Future<String> _getUserName(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('displayName')) {
      return userDoc['displayName'];
    }
    return "Unknown";
  }

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

      final todosStream = FirebaseFirestore.instance
      .collection('todos')
      .where('uid', isEqualTo: currentUser?.uid)
      .orderBy('createdAt',descending: true)
      .snapshots();

      final likedPostsAsync = ref.watch(getRecentLikesProvider);
              
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.dashboard,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: todosStream,
        builder: (context, snapshot) {

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(AppLocalizations.of(context)!.likedPosts,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                        final title = todo.title.isNotEmpty ? todo.title : '(No title)';
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
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          width: double.infinity,
                                          height: 70,
                                          child: const Center(
                                            child: Icon(Icons.image, size: 24, color: Colors.grey),
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
                                        fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Text(
                                    description,
                                    maxLines: 2,
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
              ),
              SizedBox(height: 15,),
              Text(AppLocalizations.of(context)!.yourPosts,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              Expanded(
                flex: 3,
                child: allTodoPosts(snapshot, currentUser)),
            ],
          );
        },
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
        child: const Icon(Icons.add, size: 28,color: Colors.white,),
      ),
    );
  }

 Widget allTodoPosts(AsyncSnapshot<QuerySnapshot> snapshot, User? currentUser) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }
  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(child: Text("No published todos yet."));
  }
  final todos = snapshot.data!.docs;
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
      final todoDoc = todos[index];
      final todo = todoDoc.data() as Map<String, dynamic>;
      final todoUid = todo['uid'];
      final isPublish = (todo['isPublish'] == true) ? 'Publish' : 'UnPublish';
      final likeCount = todo['likeCount'] ?? 0;
    
      return FutureBuilder<String>(
        future: _getUserName(todoUid),
        builder: (context, userSnapshot) {
          final todoUserName = userSnapshot.data ?? "......";
    
          final likedBy = todo['likedByUsers'];
          final isFavorite = likedBy.any((u) {
            if (u is LikedByUser) return u.uid == currentUser?.uid;
            if (u is Map && u['uid'] != null) return u['uid'] == currentUser?.uid;
            if (u is String) return u == currentUser?.uid;
            return false;
          });

          final createdAt = todo['createdAt'];
                  DateTime? createdAtDate;

                  if (createdAt is Timestamp) {
                    createdAtDate = createdAt.toDate();
                  } else if (createdAt is DateTime) {
                    createdAtDate = createdAt;
                  }
    
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
                      TextButton.icon(
                        onPressed: () async {
                          final docRef = FirebaseFirestore.instance.collection('todos').doc(todoDoc.id);
                          final docSnap = await docRef.get();
                          final data = docSnap.data() as Map<String, dynamic>;
                          final List likedBy = List.from(data['likedByUsers'] ?? []);
                          final String uid = currentUser!.uid;

                          bool alreadyLiked = likedBy.any((u) {
                            if (u is Map && u['uid'] != null) return u['uid'] == uid;
                            if (u is String) return u == uid;
                            return false;
                          });
                  
                          if (alreadyLiked) {
                            likedBy.removeWhere((u) {
                              if (u is Map && u['uid'] != null) return u['uid'] == uid;
                              if (u is String) return u == uid;
                              return false;
                            });

                            await docRef.update({
                              'likedByUsers': likedBy,
                              'likeCount': FieldValue.increment(-1),
                            });
                          } else {
                            likedBy.add({'uid': uid, 'likedAt': Timestamp.now()});

                            await docRef.update({
                              'likedByUsers': likedBy,
                              'likeCount': FieldValue.increment(1),
                            });
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        label: Text("$likeCount"),
                      )
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
                              createdAtDate != null
                                  ? DateFormat('dd/MM/yyyy').format(createdAtDate)
                                  : '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
              Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('($isPublish)',
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
                  todo['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  todo['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: todo['image'] != null && todo['image'].toString().isNotEmpty
                      ? Image.network(
                          todo['image'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image, size: 60, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(onPressed: (){
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                            child: ToDoUpdatePage(
                              id: todos[index].id, 
                              todoData: todos[index].data() as Map<String, dynamic>,
                          ),
                        ),
                      );
                    }, icon: Icon(Icons.edit,color: Colors.white), 
                    label: Text(AppLocalizations.of(context)!.edit,style: TextStyle(color: Colors.white,)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                      minimumSize: const Size(0, 30), 
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                    ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                      showConfirmationDialog(
                        context: context,
                        title: AppLocalizations.of(context)!.confirmDelete,
                        confirmText: AppLocalizations.of(context)!.delete,
                        confirmIcon: Icons.delete,
                        confirmColor: Colors.red,
                        onConfirm: () async {
                          try {
                              final todoRepo = ref.read(todoNotifierProvider.notifier);
                              final todoId = todos[index].id; 
                              await todoRepo.deleteTodo(todoId);
                            if (context.mounted) {
                              Navigator.pop(context);
                              showSnackBar(context, AppLocalizations.of(context)!.successDelete, Colors.green);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showSnackBar(context, '${AppLocalizations.of(context)!.failDelete} - $e', Colors.red);
                            }
                          }
                        },
                      );
                    },
                    icon: Icon(Icons.delete,color: Colors.white), label: Text(AppLocalizations.of(context)!.delete,style: TextStyle(color: Colors.white,),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                    ),)
                  ],
                ),
              )
            ],
          ),
        );
        }
        );
      },
    );
  }
}
