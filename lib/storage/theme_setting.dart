import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class CurrentThemeSetting {
  factory CurrentThemeSetting() => _instance;
  CurrentThemeSetting._internal();
  static final CurrentThemeSetting _instance = CurrentThemeSetting._internal();

  static const _themeKey = 'themeModeType';

  Future<ThemeMode> get() async {
    final box = GetStorage();
    final stored = box.read<String?>(_themeKey);

    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system; 
    }
  }

  Future<void> update({required ThemeMode themeMode}) async {
    final box = GetStorage();
    final value = themeMode == ThemeMode.dark
        ? 'dark'
        : themeMode == ThemeMode.light
            ? 'light'
            : 'system';
    await box.write(_themeKey, value);
  }
}
