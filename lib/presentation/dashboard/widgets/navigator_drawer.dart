import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/provider/user/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NavigatorDrawer extends ConsumerStatefulWidget {
  const NavigatorDrawer({super.key});

  @override
  ConsumerState<NavigatorDrawer> createState() => _NavigatorDrawerState();
}

class _NavigatorDrawerState extends ConsumerState<NavigatorDrawer> {
  String searchQuery = "";
   final Set<User> _selectedUsers = {};

  String insertLineBreaks(String text, {int limit = 25}) {
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
    final usersAsync = ref.watch(fetchUsersByAddressStream);

    return Drawer(
      child: usersAsync.when(
        data: (users) {
          final filteredUsers = users.where((user) {
            final name = user?.name.toLowerCase();
            final email = user?.email.toLowerCase();
            final combined = "$name $email";
            return combined.contains(searchQuery.toLowerCase());
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'Users Location',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'You can select user location and view their location!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return Container(
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey,width: 2,style: BorderStyle.solid)
                      ),
                      child: ListTile(
                        title: Text(
                          insertLineBreaks(
                            "${AppLocalizations.of(context)!.name}: ${user?.name}",
                          ),
                        ),
                        subtitle: Text(
                          insertLineBreaks(
                            "${AppLocalizations.of(context)!.email}: ${user?.email}",
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
