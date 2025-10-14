// ignore_for_file: deprecated_member_use
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/repository/user_repo.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class UserAddPage extends StatefulHookConsumerWidget {
  const UserAddPage({super.key});

  @override
  UserAddPageState createState() => UserAddPageState();
}

class UserAddPageState extends ConsumerState<UserAddPage> {

   bool isPasswordVisible = false;
   String role = "User";

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _pswcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final userRepository = ref.read(userRepositoryProvider);


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.userAddPage,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
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
                  Container(
                    padding: EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _addresscontroller,
                      label: AppLocalizations.of(context)!.address,
                      maxLength: 40,
                      isRequired: true,
                      validator: (value) => Validators.validateRequiredField(
                        value: value,
                        labelText: AppLocalizations.of(context)!.enterAddress,
                        context: context,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: CustomTextField(
                      controller: _pswcontroller,
                      label: AppLocalizations.of(context)!.password,
                      isRequired: true,
                      maxLength: 26,
                      obscured: !isPasswordVisible,
                      validator: (value) => Validators.validatePassword(
                          value: value,
                          labelText: AppLocalizations.of(context)!.enterPassword,
                          context: context),
                      onTogglePassword: (isVisible) {
                        setState(() {
                          isPasswordVisible = !isVisible;
                        });
                      },
                    ),
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
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            ref.read(loadingProvider.notifier).state = true;

                            try {
                              final adminEmail = FirebaseAuth.instance.currentUser!.email!;
                              final adminPassword = await showAdminPasswordDialog(context);
                              if (adminPassword == null) return;

                              final newUser = User(
                                id: userRepository.generateNewId,
                                name: _namecontroller.text.trim(),
                                email: _emailcontroller.text.trim(),
                                password: _pswcontroller.text.trim(),
                                profile: '',
                                role: role == "Admin",
                                address: _addresscontroller.text.trim(),
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(), 
                              );

                              await userRepository.addUser(newUser, adminEmail, adminPassword);

                              if (context.mounted) {
                                showSnackBar(context, AppLocalizations.of(context)!.successAdd, Colors.green);
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showSnackBar(context, e.toString(), Colors.red);
                              }
                            } finally {
                              if (context.mounted) {
                                ref.read(loadingProvider.notifier).state = false;
                              }
                            }
                          }
                        },
                            child: Text(AppLocalizations.of(context)!.add,style: TextStyle(fontSize: 20,color: Colors.white),)
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: (){
                            Navigator.pop(context);
                          }, child: Text(AppLocalizations.of(context)!.cancel,style: TextStyle(fontSize: 20,color: Colors.white),))
                    ],
                  ),
              ],
            )
            ),
        )
      ),
    );
  }
}