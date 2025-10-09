// ignore_for_file: use_build_context_synchronously

import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/profile/profile.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:bulletin_board/provider/language/language.dart';
import 'package:bulletin_board/provider/language/language_provider.dart';
import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:bulletin_board/provider/theme/theme_provider.dart';
import 'package:bulletin_board/provider/todo/todo_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/logger.dart';

class SettingPage extends HookConsumerWidget {
  const SettingPage({super.key});

  User get _currentUser => FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    final languageState = ref.watch(languageNotifierProvider);

    final isDark = appThemeState.themeMode == ThemeMode.dark;

    final providerId = useState<String?>('');
    final passwordInputController = useTextEditingController();

    final authStateNotifier = ref.watch(authNotifierProvider.notifier);
    final todoListStateNotifier = ref.watch(todoNotifierProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey
                  ),
              child: ListTile(
                leading: const Icon(Icons.person,size: 35,color: Colors.white,),
                title: Text(AppLocalizations.of(context)!.profile),
                titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17,color: Colors.white),
                onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()))
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey, 
              ),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.darkmode,
                  style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),
                ),
                trailing: Switch(
                  value: isDark,
                  onChanged: (enable) {
                    if (enable) {
                      ref.read(appThemeStateNotifier).setDarkTheme();
                    } else {
                      ref.read(appThemeStateNotifier).setLightTheme();
                    }
                  },
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey,
              ),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.language,
                  style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),
                ),
                trailing: DropdownButton<Language>(
                  value: languageState.language,
                  items: Language.values.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text('${lang.flag} ${lang.name}'),
                    );
                  }).toList(),
                  onChanged: (Language? newLang) {
                    if (newLang != null) {
                      ref.read(languageNotifierProvider.notifier).setLanguage(newLang);
                    }
                  },
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            TextButton.icon(
              onPressed: () async {
                // ignore: dead_code, unnecessary_null_comparison
                if (_currentUser == null) return;

                final provider = providerId.value ?? '';
                final isPassword = provider == 'password';

                await accountDeleteConfirmationDialog(
                  context: context,
                  title: AppLocalizations.of(context)!.deleteAccount,
                  message: AppLocalizations.of(context)!.confirmDelete,
                  password: isPassword,
                  passwordController: passwordInputController,
                  okFunction: (enteredPassword) async {
                    try {
                      ref.watch(loadingProvider.notifier).update((state) => true);
                      await todoListStateNotifier.deleteTodoByUser(_currentUser.uid);
                      await authStateNotifier.deleteAccount(
                        password: enteredPassword,
                        profileUrl: _currentUser.photoURL ?? '',
                      );

                      if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                         showSnackBar(
                            context,
                            AppLocalizations.of(context)!.successDelete,
                            Colors.green,
                          );
                    } catch (e) {
                      logger.e("Delete Error: $e");
                      if (!context.mounted) return;
                       showSnackBar(
                          context,
                          AppLocalizations.of(context)!.failDelete,
                          Colors.red,
                        );
                    } finally {
                      ref.watch(loadingProvider.notifier).update((state) => false);
                    }
                  },
                  okButton: AppLocalizations.of(context)!.delete,
                  cancelButton: AppLocalizations.of(context)!.cancel,
                );
              },
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              label: Text(
                AppLocalizations.of(context)!.deleteAccount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
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
             Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

