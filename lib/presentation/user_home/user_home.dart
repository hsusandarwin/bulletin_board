import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/dashboard/dashboard.dart';
import 'package:bulletin_board/presentation/setting/setting.dart';
import 'package:bulletin_board/presentation/todo_list/todo_list.dart';
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
            label: AppLocalizations.of(context)!.dashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: AppLocalizations.of(context)!.posts,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.setting,
          ),
        ],
      ),
      body: <Widget>[
        DashboardPage(),
        ToDoListPage(),
        SettingPage(),
      ][currentindex],
    );
  }
}
