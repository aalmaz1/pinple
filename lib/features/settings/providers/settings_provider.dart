import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class SettingsState {
  final AppThemeMode themeMode;
  final Locale locale;

  SettingsState({required this.themeMode, required this.locale});

  SettingsState copyWith({AppThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
    : super(
        SettingsState(
          themeMode: _loadThemeMode(_prefs),
          locale: _loadLocale(_prefs),
        ),
      );

  static AppThemeMode _loadThemeMode(SharedPreferences prefs) {
    final theme = prefs.getString('themeMode') ?? 'system';
    return AppThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => AppThemeMode.system,
    );
  }

  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString('languageCode') ?? 'ko';
    return Locale(languageCode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString('themeMode', mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _prefs.setString('languageCode', locale.languageCode);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SettingsNotifier(prefs);
  },
);
