import 'dart:async';

import 'package:bulletin_board/config/app.dart';
import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/auth/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  EmailVerificationPageState createState() => EmailVerificationPageState();
}

class EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).sendVerificationEmail();
      _startEmailVerificationCheck();
    });
  }

  void _startEmailVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      final authViewModel = ref.read(authNotifierProvider.notifier);
      bool isVerified = await authViewModel.checkEmailVerified();
      if (isVerified) {
        timer.cancel();
        await authViewModel.signOut();
        if (mounted) {
          showEmailVerifiedDialog(
            context: context,
            title: 'You Have Been Verified',
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.green, size: 100),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'Your Email verification is successful!',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Center(child: Text('Now you can login with your account.')),
              ],
            ),
            onSave: () => Navigator.of(context).pushAndRemoveUntil<void>(
              MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authViewModel = ref.read(authNotifierProvider.notifier);

    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.verify)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.verifySentEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            if (authState.isLoading) const CircularProgressIndicator(),
            if (!authState.isLoading && authState.isEmailSent)
              const Icon(Icons.mark_email_unread, size: 50, color: Colors.red),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      await authViewModel.sendVerificationEmail();
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          AppLocalizations.of(context)!.verifySent,
                          Colors.green,
                        );
                      }
                    },
              child: Text(AppLocalizations.of(context)!.resendEmail),
            ),
            ElevatedButton(
              onPressed: () async {
                bool isVerified = await authViewModel.checkEmailVerified();
                if (isVerified && context.mounted) {
                  showSnackBar(
                    context,
                    AppLocalizations.of(context)!.successVerify,
                    Colors.green,
                  );
                  Navigator.of(context).pushAndRemoveUntil<void>(
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (route) => false,
                  );
                } else if (authState.errorMsg.isNotEmpty && context.mounted) {
                  showSnackBar(context, authState.errorMsg, Colors.red);
                  authViewModel.clearErrorMessage();
                }
              },
              child: Text(AppLocalizations.of(context)!.checkVerify),
            ),
          ],
        ),
      ),
    );
  }
}
