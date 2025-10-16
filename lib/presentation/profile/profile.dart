// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/presentation/widgets/loading_overlay.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulHookConsumerWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _uploadedImageUrl;

  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingAddress = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  User get _currentUser => FirebaseAuth.instance.currentUser!;
  String get _userId => _currentUser.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(userRepositoryProvider);
    final appUser = await repo.getUserFuture(userId: _userId);

    if (appUser != null) {
      setState(() {
        _nameController.text = appUser.name;
        _emailController.text = appUser.email;
        _addressController.text = appUser.address;
        _uploadedImageUrl = appUser.profile;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    final repo = ref.read(userRepositoryProvider);
    final imageUrl = await repo.uploadProfilePhoto(_selectedImage!, _userId);
    setState(() => _uploadedImageUrl = imageUrl);
  }

  Future<void> _updateDisplayName() async {
    final repo = ref.read(userRepositoryProvider);
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await _currentUser.updateDisplayName(newName);
    await repo.updateProfileDisplayName(_userId, newName);

    setState(() => _isEditingName = false);
  }

  Future<void> _updateEmail() async {
    final repo = ref.read(userRepositoryProvider);
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) return;

    await _currentUser.sendEmailVerification();
    await repo.updateEmail(_userId, newEmail);

    setState(() => _isEditingEmail = false);
  }

  Future<void> _updateAddress() async {
    final repo = ref.read(userRepositoryProvider);
    final newAddress = _addressController.text.trim();
    if (newAddress.isEmpty) return;

    await repo.updateAddress(_userId, newAddress);
    setState(() => _isEditingAddress = false);
  }

  Future<void> _changePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changePsw),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: oldPasswordController,
              label: AppLocalizations.of(context)!.oldPsw,
              isRequired: true,
              maxLength: 26,
              validator: (value) => Validators.validatePassword(
                value: value,
                labelText: AppLocalizations.of(context)!.enterOldPsw,
                context: context,
              ),
            ),
            CustomTextField(
              controller: newPasswordController,
              label: AppLocalizations.of(context)!.newPsw,
              isRequired: true,
              maxLength: 26,
              validator: (value) => Validators.validatePassword(
                value: value,
                labelText: AppLocalizations.of(context)!.enternewPsw,
                context: context,
              ),
            ),
            CustomTextField(
              controller: confirmPasswordController,
              label: AppLocalizations.of(context)!.retypeNewPsw,
              isRequired: true,
              maxLength: 26,
              validator: (value) => Validators.validatePassword(
                value: value,
                labelText: AppLocalizations.of(context)!.enterretypeNewPsw,
                context: context,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (newPassword != confirmPassword) {
                showSnackBar(
                  context,
                  AppLocalizations.of(context)!.passwordNotMatch,
                  Colors.red,
                );
                return;
              }

              try {
                final cred = EmailAuthProvider.credential(
                  email: _currentUser.email!,
                  password: oldPassword,
                );
                await _currentUser.reauthenticateWithCredential(cred);
                await _currentUser.updatePassword(newPassword);
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_userId)
                    .update({'password': newPassword});
                Navigator.pop(context);
                showSnackBar(
                  context,
                  'Success! New Password Updated.',
                  Colors.green,
                );
              } on FirebaseAuthException catch (e) {
                showSnackBar(context, 'Error: ${e.message}', Colors.red);
              } catch (e) {
                showSnackBar(context, 'Error:  $e', Colors.red);
              }
            },
            child: Text(AppLocalizations.of(context)!.update),
          ),
        ],
      ),
    );
  }

  Future<void> logOut() async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      final authNotifier = ref.watch(authNotifierProvider.notifier);
      await authNotifier.signOut();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Logout failed: ${e.toString()}', Colors.red);
      }
    } finally {
      if (context.mounted) {
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onSave,
    required VoidCallback onCancel,
    required VoidCallback onEdit,
    bool isPassword = false,
    VoidCallback? onPasswordEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isEditing
            ? SizedBox(
                width: 200,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: isPassword,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(
                    isPassword ? '********' : value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        const SizedBox(width: 8),
        isPassword
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: onPasswordEdit,
              )
            : isEditing
            ? Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onSave,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onCancel,
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: onEdit,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.profile,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  _uploadedImageUrl != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: File(_uploadedImageUrl!).existsSync()
                              ? FileImage(File(_uploadedImageUrl!))
                              : null,
                          backgroundColor: Colors.grey[300],
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    right: -10,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 30),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.selectImageSource,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.gallery,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.camera,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildEditableRow(
                icon: Icons.person,
                value: _nameController.text,
                isEditing: _isEditingName,
                controller: _nameController,
                onSave: _updateDisplayName,
                onCancel: () {
                  setState(() {
                    _isEditingName = false;
                    _nameController.text = _currentUser.displayName ?? '';
                  });
                },
                onEdit: () => setState(() => _isEditingName = true),
              ),
              const SizedBox(height: 20),
              _buildEditableRow(
                icon: Icons.email,
                value: _emailController.text,
                isEditing: _isEditingEmail,
                controller: _emailController,
                onSave: _updateEmail,
                onCancel: () {
                  setState(() {
                    _isEditingEmail = false;
                    _emailController.text = _currentUser.email ?? '';
                  });
                },
                onEdit: () => setState(() => _isEditingEmail = true),
              ),
              const SizedBox(height: 20),
              _buildEditableRow(
                icon: Icons.home,
                value: _addressController.text,
                isEditing: _isEditingAddress,
                controller: _addressController,
                onSave: _updateAddress,
                onCancel: () {
                  setState(() {
                    _isEditingAddress = false;
                  });
                },
                onEdit: () => setState(() => _isEditingAddress = true),
              ),
              const SizedBox(height: 20),
              _buildEditableRow(
                icon: Icons.lock,
                value: '********',
                isEditing: false,
                controller: TextEditingController(),
                onSave: () {},
                onCancel: () {},
                onEdit: () {},
                isPassword: true,
                onPasswordEdit: _changePasswordDialog,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.joined,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.calendar_today),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(_currentUser.metadata.creationTime!),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () {
                  showConfirmationDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.confirmLogout,
                    confirmText: AppLocalizations.of(context)!.logout,
                    confirmIcon: Icons.logout,
                    confirmColor: Colors.red,
                    onConfirm: () {
                      logOut();
                    },
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: Text(
                  AppLocalizations.of(context)!.logout,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
