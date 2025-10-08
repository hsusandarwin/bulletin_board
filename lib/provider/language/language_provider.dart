import 'package:bulletin_board/presentation/storage/language_setting.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'language.dart';

final languageNotifierProvider =
    ChangeNotifierProvider<LanguageNotifier>((ref) => LanguageNotifier());

class LanguageNotifier extends ChangeNotifier {
  Language _language = Language.english;
  final _setting = CurrentLanguageSetting();
  bool _isLoaded = false;

  Language get language => _language;
  Locale get locale => _language.locale;
  bool get isLoaded => _isLoaded;

  LanguageNotifier() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final savedLocale = await _setting.get();
    _language = Language.fromCode(savedLocale.languageCode);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(Language lang) async {
    if (_language == lang) return;
    _language = lang;
    await _setting.update(locale: lang.locale);
    notifyListeners();
  }
}
