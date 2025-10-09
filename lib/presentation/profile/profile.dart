// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
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
    final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['displayName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _addressController.text = data['address'] ?? '';
        _uploadedImageUrl = data['profile'];
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
    final imageUrl = _selectedImage!.path;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({'profile': imageUrl});

    setState(() => _uploadedImageUrl = imageUrl);
  }

  Future<void> _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await _currentUser.updateDisplayName(newName);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({'displayName': newName});

    setState(() => _isEditingName = false);
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) return;

    await _currentUser.sendEmailVerification();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({'email': newEmail});

    setState(() => _isEditingEmail = false);
  }

  Future<void> _updateAddress() async {
    final newAddress = _addressController.text.trim();
    if (newAddress.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .update({'address': newAddress});

    setState(() {});
  }
  

  Future<void> _changePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              CustomTextField(
                controller: oldPasswordController,
                label: 'Password',
                isRequired: true,
                maxLength: 26,
                validator: (value) => Validators.validatePassword(
                    value: value,
                labelText: 'Enter Old Password...',
                context: context),
              ),
              CustomTextField(
                controller: newPasswordController,
                label: 'Password',
                isRequired: true,
                maxLength: 26,
                validator: (value) => Validators.validatePassword(
                    value: value,
                labelText: 'Enter New Password...',
                context: context),
              ),
              CustomTextField(
                controller: confirmPasswordController,
                label: 'Password',
                isRequired: true,
                maxLength: 26,
                validator: (value) => Validators.validatePassword(
                    value: value,
                labelText: 'Enter Confirm New Password...',
                context: context),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (newPassword != confirmPassword) {
                showSnackBar(context, 'New Password and Confirm Password do not match', Colors.red);
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
                showSnackBar(context, 'Success! New Password Updated.', Colors.green);
              } on FirebaseAuthException catch (e) {
                showSnackBar(context, 'Error: ${e.message}', Colors.red);
              } catch (e) {
                showSnackBar(context, 'Error:  $e', Colors.red);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              )
            : Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(
                    isPassword ? '********' : value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: onSave),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: onCancel),
                    ],
                  )
                : IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: onEdit),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile,textAlign: TextAlign.start,style: TextStyle(fontSize: 20),),
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
                        child: Icon(Icons.person, size: 60, color: Colors.white),
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
                          title: Text(AppLocalizations.of(context)!.selectImageSource),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                                child: Text(AppLocalizations.of(context)!.gallery)),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                                child: Text(AppLocalizations.of(context)!.camera)),
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
                  Text(AppLocalizations.of(context)!.joined,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 3),
                  Icon(Icons.calendar_today),
                  Text(
                    DateFormat('dd/MM/yyyy')
                        .format(_currentUser.metadata.creationTime!),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  );
                },
                  icon: const Icon(Icons.logout_rounded,color: Colors.red,), 
                  label: Text(AppLocalizations.of(context)!.logout,style: TextStyle(color: Colors.red,fontSize: 18),),
                ),
          ],
        ),
      ),
    );
  }
}
