// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bulletin_board/data/entities/address/address.dart';
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/data/enums/user_role/user_role.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/presentation/widgets/loading_overlay.dart';
import 'package:bulletin_board/presentation/widgets/show_google_map_dialog.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/provider/user/user_notifier.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserUpdatePage extends StatefulHookConsumerWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserUpdatePage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  UserUpdatePageState createState() => UserUpdatePageState();
}

class UserUpdatePageState extends ConsumerState<UserUpdatePage> {
  bool isPasswordVisible = false;
  late String role;
  late String userId;

  Map<String, dynamic>? _previousAddress;

  late TextEditingController _emailcontroller;
  late TextEditingController _namecontroller;

  String insertLineBreaks(String text, {int limit = 32}) {
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadingProvider.notifier).update((state) => false);
    });
    super.initState();
    _emailcontroller = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _namecontroller = TextEditingController(
      text: widget.userData['displayName'] ?? '',
    );
    role = (widget.userData['role'] == true) ? "Admin" : "User";
    userId = (widget.userData['id']);
    _previousAddress = (widget.userData['address'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(key, value));
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _namecontroller.dispose();
    super.dispose();
  }

  Future<void> _undoAddressChange() async {
    final userRepository = ref.read(userRepositoryProvider);

    if (_previousAddress != null) {
      await userRepository.updateUserAddress(
        userId: userId,
        addressName: _previousAddress!['name'] ?? '',
        addressLocation: _previousAddress!['location'] ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final userRepository = ref.read(userRepositoryProvider);

    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _undoAddressChange();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.userUpdatePage,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _emailcontroller,
                      label: AppLocalizations.of(context)!.email,
                      maxLength: 40,
                      isRequired: true,
                      validator: (value) => Validators.validateEmail(
                        value: value,
                        labelText: AppLocalizations.of(context)!.enterEmail,
                        context: context,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _namecontroller,
                      label: AppLocalizations.of(context)!.name,
                      maxLength: 40,
                      isRequired: true,
                      validator: (value) => Validators.validateRequiredField(
                        value: value,
                        labelText: AppLocalizations.of(context)!.enterName,
                        context: context,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final userRepo = ref.read(userRepositoryProvider);
      
                      final selectedUser = await userRepo.getUserFuture(
                        userId: widget.userId,
                      );
                      if (selectedUser == null) return;
      
                      final userNotifier = ref.read(
                        userNotifierProvider(selectedUser).notifier,
                      );
      
                      await showDialog<LatLng>(
                        context: context,
                        builder: (context) {
                          return GoogleMapPickerDialog(
                            userNotifier: userNotifier,
                          );
                        },
                      );
      
                      setState(() {});
                    },
                    label: const Text('Choose Location From Google Map'),
                    icon: const Icon(Icons.location_searching_outlined),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_pin, color: Colors.red),
                      const SizedBox(width: 8),
                      FutureBuilder<String?>(
                        future: ref
                            .read(userRepositoryProvider)
                            .getUserAddress(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading address...');
                          } else if (snapshot.hasError) {
                            return const Text('Error loading address');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Text('No address found');
                          } else {
                            return Text(
                              insertLineBreaks(snapshot.data!),
                              style: TextStyle(fontSize: 15),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: "User",
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                          const Text("User"),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: "Admin",
                            groupValue: role,
                            onChanged: (value) {
                              setState(() {
                                role = value!;
                              });
                            },
                          ),
                          const Text("Admin"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            ref
                                .read(loadingProvider.notifier)
                                .update((state) => true);
      
                            try {
                              final latestUser = await userRepository
                                  .getUserFuture(userId: widget.userId);
                              final addressData =
                                  latestUser?.address ??
                                  Address(name: '', location: '');
      
                              final updatedUser = User(
                                id: widget.userId,
                                name: _namecontroller.text.trim(),
                                email: _emailcontroller.text.trim(),
                                profile: widget.userData['profile'] ?? '',
                                password: '',
                                role: role == "Admin"
                                    ? UserRole.admin
                                    : UserRole.user,
                                address: Address(
                                  name: addressData.name,
                                  location: addressData.location,
                                ),
                                createdAt:
                                    widget.userData['createdAt']?.toDate() ??
                                    DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
      
                              await userRepository.updateUser(updatedUser);
      
                              if (context.mounted) {
                                showSnackBar(
                                  context,
                                  AppLocalizations.of(context)!.successUpdate,
                                  Colors.green,
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showSnackBar(context, e.toString(), Colors.red);
                              }
                            } finally {
                              if (context.mounted) {
                                ref
                                    .read(loadingProvider.notifier)
                                    .update((state) => false);
                              }
                            }
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.update,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          await _undoAddressChange();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
