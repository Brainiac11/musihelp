import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeSetting { system, light, dark }

class Settings {
  final ThemeModeSetting themeMode;

  Settings({
    this.themeMode = ThemeModeSetting.system,
  });

  Settings copyWith({
    ThemeModeSetting? themeMode,

  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  void setThemeMode(ThemeModeSetting mode) {
    state = state.copyWith(themeMode: mode);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});