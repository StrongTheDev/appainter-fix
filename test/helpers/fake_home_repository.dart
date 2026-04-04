import 'package:appainter/models/theme_usage.dart';
import 'package:appainter/repositories/home_repository.dart';
import 'package:flutter/material.dart';

class FakeHomeRepository extends HomeRepository {
  FakeHomeRepository({
    this.initialDark = false,
    this.initialUsage = const ThemeUsage(ThemeUsage.defaultMarkdown),
    this.importedTheme,
  });

  final bool initialDark;
  final ThemeUsage initialUsage;
  final ThemeData? importedTheme;
  bool? savedIsDark;
  ThemeData? exportedTheme;

  @override
  Future<ThemeUsage> fetchThemeUsage() async => initialUsage;

  @override
  Future<ThemeData?> importTheme() async => importedTheme;

  @override
  Future<bool> exportTheme(ThemeData theme) async {
    exportedTheme = theme;
    return true;
  }

  @override
  Future<bool?> getIsDarkTheme() async => savedIsDark ?? initialDark;

  @override
  Future<void> setPreviewDarkTheme(bool isDark) async {
    savedIsDark = isDark;
  }
}
