// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:bulletin_board/config/app.dart';
import 'package:bulletin_board/data/entities/user/user.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/admin_home/admin_home.dart';
import 'package:bulletin_board/presentation/forget_password/forget_password.dart';
import 'package:bulletin_board/presentation/register/register_page.dart';
import 'package:bulletin_board/presentation/user_home/user_home.dart';
import 'package:bulletin_board/presentation/varification/verification_page.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/presentation/widgets/loading_overlay.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/provider/user/user_notifier.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends StatefulHookConsumerWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  bool isPasswordVisible = false;
  final emailController = TextEditingController();
  final pswController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isMounted = useIsMounted();

    return LoadingOverlay(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 50),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.loginPage,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: CustomTextField(
                        controller: emailController,
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
                        controller: pswController,
                        label: AppLocalizations.of(context)!.password,
                        isRequired: true,
                        maxLength: 26,
                        obscured: !isPasswordVisible,
                        validator: (value) => Validators.validatePassword(
                          value: value,
                          labelText: AppLocalizations.of(
                            context,
                          )!.enterPassword,
                          context: context,
                        ),
                        onTogglePassword: (isVisible) {
                          setState(() {
                            isPasswordVisible = !isVisible;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.forgetPassword,
                            style: TextStyle(color: const Color(0xFF060186)),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final form = formKey.currentState;
                        if (form == null || !form.validate()) {
                          return;
                        }

                        ref.read(loadingProvider.notifier).state = true;

                        final email = emailController.text.trim();
                        final password = pswController.text.trim();

                        final notifier = ref.read(
                          userNotifierProvider(null).notifier,
                        );

                        try {
                          final User? user = await notifier.login(
                            email,
                            password,
                          );

                          if (!isMounted()) return;

                          if (user != null) {
                            final firebaseUser =
                                firebase_auth.FirebaseAuth.instance.currentUser;
                            await firebaseUser?.reload();
                            final isVerified =
                                firebaseUser?.emailVerified ?? false;

                            if (!isVerified) {
                              Navigator.of(context).pushAndRemoveUntil<void>(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EmailVerificationPage(),
                                ),
                                (route) => false,
                              );

                              showSnackBar(
                                context,
                                AppLocalizations.of(context)!.verify,
                                Colors.green,
                              );
                            } else {
                              Navigator.of(context).pushAndRemoveUntil<void>(
                                MaterialPageRoute(
                                  builder: (context) => const MyApp(),
                                ),
                                (route) => false,
                              );

                              showSnackBar(
                                context,
                                AppLocalizations.of(context)!.successLogin,
                                Colors.green,
                              );
                            }
                          } else {
                            showSnackBar(
                              context,
                              AppLocalizations.of(context)!.invalidEmailPsw,
                              Colors.red,
                            );
                          }
                        } catch (e) {
                          if (!isMounted()) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppLocalizations.of(context)!.failLogin}: $e',
                              ),
                            ),
                          );
                        } finally {
                          if (context.mounted) {
                            ref.read(loadingProvider.notifier).state = false;
                          }
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.login,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Image.asset('assets/login/OR.png'),
                    TextButton.icon(
                      onPressed: () async {
                        final notifier = ref.read(
                          authNotifierProvider.notifier,
                        );
                        ref.read(loadingProvider.notifier).state = true;
                        try {
                          await notifier.loginWithGoogle();

                          final state = ref.read(authNotifierProvider);

                          if (state.isSuccess && state.user != null) {
                            showSnackBar(
                              context,
                              "${AppLocalizations.of(context)!.welcome} ${state.user!.name}",
                              Colors.green,
                            );
                            if (state.user!.role == false) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const UserHomePage(),
                                ),
                              );
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const AdminHomePage(),
                                ),
                              );
                            }
                          } else if (state.errorMsg.isNotEmpty) {
                            showSnackBar(context, state.errorMsg, Colors.red);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showSnackBar(context, e.toString(), Colors.red);
                          }
                        } finally {
                          ref
                              .read(loadingProvider.notifier)
                              .update((state) => false);
                        }
                      },
                      icon: FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                        size: 30,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.loginGoogle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.askRegister,
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
