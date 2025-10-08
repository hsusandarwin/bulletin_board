import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/dashboard/dashboard.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/profile/profile.dart';
import 'package:bulletin_board/presentation/setting/setting.dart';
import 'package:bulletin_board/presentation/todo_list/todo_list.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  int currentindex = 1;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userHomePage,style: const TextStyle(fontSize: 20),),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return TextButton.icon(
                        onPressed: null,
                        icon: Icon(Icons.person),
                        label: Text('User'),
                      );
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final displayName = userData['displayName'] ?? 'User';

                    return TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfilePage()),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: Text(displayName),
                    );
                  },
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
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentindex = index;
          });
        },
        selectedIndex: currentindex,
        indicatorColor: Colors.amber,
        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.dashboard), 
            label: AppLocalizations.of(context)!.dashboard
            ),
          NavigationDestination(
            icon: Icon(Icons.book), 
            label: AppLocalizations.of(context)!.posts
            ),
            NavigationDestination(
            icon: Icon(Icons.settings),  
            label: AppLocalizations.of(context)!.setting
            ),
        ]
        ), 
        body: <Widget>[
          DashboardPage(),
          ToDoListPage(),
          SettingPage()
        ][currentindex],
    );
  }
}