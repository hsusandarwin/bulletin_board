import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/user/widgets/user_add.dart';
import 'package:bulletin_board/presentation/user/widgets/user_update.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
      String searchQuery = "";

      String insertLineBreaks(String text, {int limit = 28}) {
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
    return Scaffold(
      body: Column(
        children: [
             Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.search,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); 
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
            
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
            
                final users = snapshot.data!.docs;
                final filteredUsers = users.where((doc) {
                final userData = doc.data() as Map<String, dynamic>;

                final name = (userData['displayName'] ?? '').toString().toLowerCase();
                final email = (userData['email'] ?? '').toString().toLowerCase();
                final password = (userData['password'] ?? '').toString().toLowerCase();
                final address = (userData['address'] ?? '').toString().toLowerCase();
                final role = (userData['role'] == true ? 'admin' : 'user').toLowerCase();

                final combined = "$name $email $password $address $role";
                return combined.contains(searchQuery.toLowerCase());
              }).toList();

    final todoListStateNotifier = ref.watch(todoNotifierProvider.notifier);

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index].data() as Map<String, dynamic>;
            
                    final name = userData['displayName'] ?? 'No Name';
                    final email = userData['email'] ?? 'No Email';
                    final password = '********';
                    final address = userData['address'] ?? 'No Address';
                    final role = (userData['role'] == true) ? 'admin' : 'user';
            
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(insertLineBreaks("${AppLocalizations.of(context)!.name} : $name"),style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(insertLineBreaks("${AppLocalizations.of(context)!.email} : $email")),
                              Text("${AppLocalizations.of(context)!.password} : $password"),
                              Text(insertLineBreaks("${AppLocalizations.of(context)!.address} : $address")),
                              Text("${AppLocalizations.of(context)!.role} : $role",
                                  style: TextStyle(
                                    color: role == 'admin' ? Colors.red : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                           Column(
                            children: [
                              ElevatedButton.icon(onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                    ),
                                     child: UserUpdatePage(
                                      userId: users[index].id,
                                      userData: users[index].data() as Map<String, dynamic>,
                                    ),
                                  ),
                                );
                              }, icon: Icon(Icons.edit,color: Colors.white,), label: Text(AppLocalizations.of(context)!.edit,style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),),
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
                                      final currentUser = FirebaseAuth.instance.currentUser;
                                      if (currentUser == null) {
                                        throw Exception("Admin is not logged in");
                                      }

                                      final adminEmail = currentUser.email ?? '';
                                      if (adminEmail.isEmpty) {
                                        throw Exception("Admin email missing");
                                      }

                                      final adminPassword = await showAdminPasswordDialog(context);
                                      if (adminPassword == null) return;

                                      final userRepository = ref.read(userRepositoryProvider);
                                      final userId = users[index].id;

                                      await userRepository.deleteUserByAdmin(userId, adminEmail, adminPassword);
                                      await todoListStateNotifier.deleteTodoByUser(userId);

                                      if (context.mounted && Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                        showSnackBar(
                                          context,
                                          AppLocalizations.of(context)!.successDelete,
                                          Colors.green,
                                        );
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      showSnackBar(
                                        context,
                                        '${AppLocalizations.of(context)?.failDelete ?? "Failed to delete"} - $e',
                                        Colors.red,
                                      );
                                    }
                                  },
                                );
                              },
                              icon: Icon(Icons.delete,color: Colors.white), label: Text(AppLocalizations.of(context)!.delete,style: TextStyle(color: Colors.white),),style: ElevatedButton.styleFrom(backgroundColor: Colors.red,),)
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
              child: UserAddPage(),
            ),
          );
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.add, size: 28,color: Colors.white,),
      ),
    );
  }
}
