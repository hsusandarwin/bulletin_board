// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/presentation/widgets/loading_overlay.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ToDoAddPage extends StatefulHookConsumerWidget {
  const ToDoAddPage({super.key});

  @override
  ConsumerState<ToDoAddPage> createState() => _ToDoAddPageState();
}

class _ToDoAddPageState extends ConsumerState<ToDoAddPage> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool isPublishBool = false;

  final TextEditingController _titlecontroller = TextEditingController();
  final TextEditingController _despcontroller = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.addTodoPage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _titlecontroller,
                      label: AppLocalizations.of(context)!.title,
                      maxLength: 100,
                      isRequired: true,
                      validator: (value) => Validators.validateRequiredField(
                        value: value,
                        labelText: AppLocalizations.of(context)!.enterTitle,
                        context: context,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _despcontroller,
                      label: AppLocalizations.of(context)!.description,
                      maxLength: 400,
                      isRequired: true,
                      validator: (value) => Validators.validateRequiredField(
                        value: value,
                        labelText: AppLocalizations.of(
                          context,
                        )!.enterDescription,
                        context: context,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: isPublishBool,
                        onChanged: (value) {
                          setState(() => isPublishBool = value!);
                        },
                      ),
                      Text(AppLocalizations.of(context)!.unpublish),
                      const SizedBox(width: 20),
                      Radio<bool>(
                        value: true,
                        groupValue: isPublishBool,
                        onChanged: (value) {
                          setState(() => isPublishBool = value!);
                        },
                      ),
                      Text(AppLocalizations.of(context)!.publish),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
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
                              child: Text(AppLocalizations.of(context)!.camera),
                            ),
                          ],
                        ),
                      );
                    },
                    label: Text(
                      AppLocalizations.of(context)!.uploadImage,
                      style: TextStyle(fontSize: 20),
                    ),
                    icon: const Icon(Icons.camera_alt),
                  ),

                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.file(_selectedImage!, height: 150),
                    ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final currentUser =
                                      auth.FirebaseAuth.instance.currentUser;

                                  await ref
                                      .read(todoNotifierProvider.notifier)
                                      .addTodo(
                                        title: _titlecontroller.text.trim(),
                                        description: _despcontroller.text
                                            .trim(),
                                        isPublish: isPublishBool,
                                        uid: currentUser?.uid ?? "unknown",
                                        imageFile: _selectedImage,
                                        context: context,
                                      );
                                }
                              },
                        child: Text(
                          AppLocalizations.of(context)!.add,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
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
