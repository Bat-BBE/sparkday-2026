import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

const _kThemeKey = 'theme_key';

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemeKey>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<AppThemeKey> {
  ThemeController() : super(AppThemeKey.violet) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kThemeKey);
    state = AppThemes.fromWire(v);
  }

  Future<void> setTheme(AppThemeKey key) async {
    state = key;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeKey, AppThemes.toWire(key));
  }
}
