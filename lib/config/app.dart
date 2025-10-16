// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/l10n/l10n.dart';
import 'package:bulletin_board/presentation/admin_home/admin_home.dart';
import 'package:bulletin_board/presentation/login/login_page.dart';
import 'package:bulletin_board/presentation/user_home/user_home.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:bulletin_board/provider/language/language_provider.dart';
import 'package:bulletin_board/provider/theme/theme_provider.dart';
import 'package:bulletin_board/provider/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserStream = ref.watch(authUserStreamProvider);
    final authStateNotifier = ref.watch(authNotifierProvider.notifier);
    final appThemeState = ref.watch(appThemeStateNotifier);
    final languageState = ref.watch(languageNotifierProvider);

    final isUserDataLoaded = useState(false);

    if (!languageState.isLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Bulletin Board',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeState.themeMode,
      locale: languageState.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: authUserStream.when(
        data: (user) {
          if (user != null && user.emailVerified) {
            useEffect(() {
              Future<void> fetchUserData() async {
                debugPrint('Fetching user data...');
                try {
                  await authStateNotifier.getUserFuture(authUserId: user.uid);
                  debugPrint('✅ User data loaded!');
                  isUserDataLoaded.value = true;
                } catch (e, st) {
                  debugPrint('❌ Error loading user data: $e\n$st');
                }
              }

              fetchUserData();
              return null;
            }, [user]);
            if (!isUserDataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final currentUser = authStateNotifier.state.user;
            if (currentUser != null && currentUser.role) {
              return const AdminHomePage();
            } else {
              return const UserHomePage();
            }
          } else {
            return const LoginPage();
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Something went wrong!')),
      ),
    );
  }
}
