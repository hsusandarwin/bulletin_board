import 'package:bulletin_board/presentation/storage/theme_setting.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeState(),
);

class AppThemeState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final _themeSetting = CurrentThemeSetting();

  ThemeMode get themeMode => _themeMode;

  AppThemeState() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _themeMode = await _themeSetting.get();
    notifyListeners();
  }

  void setLightTheme() {
    _themeMode = ThemeMode.light;
    _themeSetting.update(themeMode: _themeMode);
    notifyListeners();
  }

  void setDarkTheme() {
    _themeMode = ThemeMode.dark;
    _themeSetting.update(themeMode: _themeMode);
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _themeSetting.update(themeMode: _themeMode);
    notifyListeners();
  }
}
