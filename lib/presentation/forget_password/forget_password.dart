// ignore_for_file: use_build_context_synchronously

import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForgetPasswordPage extends StatefulHookConsumerWidget {
  const ForgetPasswordPage({super.key});

  @override
  ConsumerState<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends ConsumerState<ForgetPasswordPage> {
  final emailController = TextEditingController();
  bool emailSent = false;

  reset()async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      showSnackBar(context, 'Email Sent to ${emailController.text} to change your password', Colors.green);
       setState(() {
      emailSent = true; 
    });
    }catch(e){
    showSnackBar(context, 'Error : $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true,),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.forgetPage,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              SizedBox(height: 30,),
               if (emailSent)
                Text(
                  '${AppLocalizations.of(context)!.emailSent1} ${emailController.text} ${AppLocalizations.of(context)!.emailSent2}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(20),
                  child:  CustomTextField(
                    controller: emailController,
                    label: AppLocalizations.of(context)!.email,
                    maxLength: 40,
                    isRequired: true,
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required.';
                        }
                        return null;
                      }
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                    ),
                  onPressed: (){reset();}, 
                  child: Text(AppLocalizations.of(context)!.send,style: TextStyle(color: Colors.white,fontSize: 18),)
                ),
                SizedBox(height: 40,),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(AppLocalizations.of(context)!.noteForget)
                )
            ],
          ),
        ),
      )
    );
  }
}