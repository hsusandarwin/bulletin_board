import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class CurrentLanguageSetting {
  factory CurrentLanguageSetting() => _instance;
  CurrentLanguageSetting._internal();
  static final _instance = CurrentLanguageSetting._internal();

  static const _languageKey = 'languageKey';

  Future<Locale> get() async {
    final box = GetStorage();
    final code = box.read<String?>(_languageKey);
    return Locale(code ?? 'en');
  }

  Future<void> update({required Locale locale}) async {
    final box = GetStorage();
    await box.write(_languageKey, locale.languageCode);
  }
}
