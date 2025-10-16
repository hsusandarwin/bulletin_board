import 'package:flutter/material.dart';

enum Language {
  english(flag: '🇺🇲', name: 'English', code: 'en'),
  myanmar(flag: '🇲🇲', name: 'မြန်မာ', code: 'my'),
  japanese(flag: '🇯🇵', name: '日本語', code: 'ja'),
  korean(flag: '🇰🇷', name: '한국어', code: 'ko');

  const Language({required this.flag, required this.name, required this.code});

  final String flag;
  final String name;
  final String code;

  Locale get locale => Locale(code);

  static Language fromCode(String? code) {
    switch (code) {
      case 'my':
        return Language.myanmar;
      case 'ja':
        return Language.japanese;
      case 'ko':
        return Language.korean;
      case 'en':
      default:
        return Language.english;
    }
  }
}
