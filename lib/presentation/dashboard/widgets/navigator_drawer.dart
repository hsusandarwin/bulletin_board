import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/dashboard/widgets/mapscreen.dart';
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
                  'You can select user(s) and view their location!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    final isSelected = _selectedUsers.contains(user);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedUsers.remove(user);
                          } else {
                            _selectedUsers.add(user!);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[180] : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            insertLineBreaks(
                              "${AppLocalizations.of(context)!.name}: ${user?.name}",
                            ),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            insertLineBreaks(
                              "${AppLocalizations.of(context)!.email}: ${user?.email}",
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_selectedUsers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MapScreenPage(
                              selectedUsers: _selectedUsers.toList(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'View Selected on Map',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
