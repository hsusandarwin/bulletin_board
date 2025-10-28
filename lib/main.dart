import 'package:bulletin_board/config/logger.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:bulletin_board/config/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  const googleApiKey = String.fromEnvironment('GOOGLE_API_KEY');
  logger.f('api ---->$googleApiKey');
  runApp(const ProviderScope(child: MyApp()));
}
