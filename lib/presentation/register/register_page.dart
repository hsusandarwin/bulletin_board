import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/varification/verification_page.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class RegisterPage extends StatefulHookConsumerWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends ConsumerState<RegisterPage> {

   bool isPasswordVisible = false;

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _pswcontroller = TextEditingController();
  final TextEditingController _addresscontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
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
                Text(AppLocalizations.of(context)!.registerPage,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
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
                      maxLength: 15,
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                    ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      ref.read(loadingProvider.notifier).state = true;
                      try {
                        await ref.read(authNotifierProvider.notifier).register(
                          email: _emailcontroller.text.trim(),
                          password: _pswcontroller.text.trim(),
                          name: _namecontroller.text.trim(),
                          address: _addresscontroller.text.trim(),
                        );
    
                        if (context.mounted) {
                          showSnackBar(context, AppLocalizations.of(context)!.successAdd, Colors.green);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
                            (route) => false,
                          );
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
                    child: Text(AppLocalizations.of(context)!.register,style: TextStyle(fontSize: 20,color: Colors.white),)
                  ),
                  Image.asset('assets/login/OR.png'),
                  TextButton.icon(
                    onPressed: () async {
                      ref.read(loadingProvider.notifier).state = true;
    
                      try {
                        await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    
                        final authState = ref.read(authNotifierProvider);
    
                        if (!context.mounted) return;
    
                        if (authState.isSuccess) {
                          showSnackBar(context, AppLocalizations.of(context)!.successGoogleSignin, Colors.green);

    
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                          );
                        } else if (authState.errorMsg.isNotEmpty) {
                          showSnackBar(context, authState.errorMsg, Colors.red);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showSnackBar(context, e.toString(), Colors.red);

                        }
                      } finally {
                        ref.read(loadingProvider.notifier).state = false;
                      }
                    },
                    icon:  FaIcon(FontAwesomeIcons.google,color: Colors.red,size: 30,),
                    label: Text(AppLocalizations.of(context)!.signinGoogle,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold))
                    ),
                    TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    }, child: Text(AppLocalizations.of(context)!.askLogin,style: TextStyle(color: Colors.deepPurpleAccent),)
                  )
              ],
            )
            ),
        )
      ),
    );
  }
}