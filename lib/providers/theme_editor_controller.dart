import 'package:appainter/models/theme_usage.dart';
import 'package:appainter/repositories/home_repository.dart';
import 'package:appainter/services/basic_theme_service.dart';
import 'package:appainter/services/util_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

enum AppStatus { initial, ready }
enum EditorMode { basic, advanced }

class ThemeEditorController extends ChangeNotifier {
  ThemeEditorController({required this.homeRepo}) : _theme = ThemeData();

  final HomeRepository homeRepo;
  final BasicThemeService _basicThemeService = BasicThemeService();

  ThemeData _theme;
  ThemeMode _themeMode = ThemeMode.system;
  AppStatus _status = AppStatus.initial;
  EditorMode _editorMode = EditorMode.basic;
  ThemeUsage? _themeUsage;

  ThemeData get theme => _theme;
  ThemeMode get themeMode => _themeMode;
  AppStatus get status => _status;
  EditorMode get editorMode => _editorMode;
  ThemeUsage? get themeUsage => _themeUsage;
  bool get isDark => _theme.brightness == Brightness.dark;
  ColorScheme get colorScheme => _theme.colorScheme;

  Future<void> initialize() async {
    await Future.wait([fetchThemeMode(), fetchThemeUsage()]);
    _status = AppStatus.ready;
    notifyListeners();
  }

  Future<void> fetchThemeUsage() async {
    _themeUsage = await homeRepo.fetchThemeUsage();
    notifyListeners();
  }

  Future<void> fetchThemeMode() async {
    final saved = await homeRepo.getIsDarkTheme();
    _themeMode = switch (saved) {
      true => ThemeMode.dark,
      false => ThemeMode.light,
      null => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(bool isDarkTheme) async {
    await homeRepo.setIsDarkTheme(isDarkTheme);
    _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setEditorMode(EditorMode mode) {
    _editorMode = mode;
    notifyListeners();
  }

  Future<void> importTheme() async {
    final imported = await homeRepo.importTheme();
    if (imported != null) {
      _theme = imported;
      _editorMode = EditorMode.advanced;
      notifyListeners();
    }
  }

  Future<void> exportTheme() => homeRepo.exportTheme(_theme);

  void resetTheme() {
    _theme = ThemeData();
    notifyListeners();
  }

  void randomizeTheme([int? seed]) {
    final scheme = randomColorScheme(
      seed: seed ?? DateTime.now().millisecondsSinceEpoch,
      isDark: isDark,
      shouldPrint: false,
    );
    _theme = ThemeData.from(
      colorScheme: scheme,
      useMaterial3: _theme.useMaterial3,
    );
    notifyListeners();
  }

  void setBrightness(bool isDarkTheme) {
    _theme = _theme.copyWith(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      colorScheme: _theme.colorScheme.copyWith(
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      ),
    );
    notifyListeners();
  }

  void setUseMaterial3(bool useMaterial3) {
    _theme = _theme.copyWith(useMaterial3: useMaterial3);
    notifyListeners();
  }

  void seedColorChanged(Color color) {
    _theme = _theme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: _theme.brightness,
      ),
    );
    notifyListeners();
  }

  void primaryColorChanged(Color color) {
    final swatch = UtilService.getColorSwatch(color);
    final onColor = isDark ? Colors.white : Colors.black;
    _theme = _theme.copyWith(
      primaryColor: color,
      primaryColorLight: swatch[100],
      primaryColorDark: swatch[700],
      secondaryHeaderColor: swatch[50],
      colorScheme: _theme.colorScheme.copyWith(
        primary: color,
        onPrimary: onColor,
        secondary: color,
        onSecondary: onColor,
        surface: swatch[200],
      ),
    );
    notifyListeners();
  }

  void onPrimaryColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(onPrimary: color));

  void primaryContainerColorChanged(Color color) => _updateColorScheme(
        _theme.colorScheme.copyWith(
          primaryContainer: color,
          onPrimaryContainer: _basicThemeService.getOnContainerColor(color),
        ),
      );

  void onPrimaryContainerColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(onPrimaryContainer: color));

  void secondaryColorChanged(Color color) {
    final onColor = isDark ? Colors.white : Colors.black;
    _updateColorScheme(
      _theme.colorScheme.copyWith(
        secondary: color,
        onSecondary: onColor,
      ),
    );
  }

  void onSecondaryColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(onSecondary: color));

  void secondaryContainerColorChanged(Color color) => _updateColorScheme(
        _theme.colorScheme.copyWith(
          secondaryContainer: color,
          onSecondaryContainer: _basicThemeService.getOnContainerColor(color),
        ),
      );

  void onSecondaryContainerColorChanged(Color color) => _updateColorScheme(
        _theme.colorScheme.copyWith(onSecondaryContainer: color),
      );

  void tertiaryColorChanged(Color color) => _updateColorScheme(
        _theme.colorScheme.copyWith(
          tertiary: color,
          onTertiary: _basicThemeService.getOnKeyColor(color),
          tertiaryContainer: _basicThemeService.getContainerColor(color),
          onTertiaryContainer: _basicThemeService.getOnContainerColor(color),
        ),
      );

  void errorColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(error: color));

  void surfaceColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(surface: color));

  void outlineColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(outline: color));

  void inverseSurfaceColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(inverseSurface: color));

  void onInverseSurfaceColorChanged(Color color) => _updateColorScheme(
        _theme.colorScheme.copyWith(onInverseSurface: color),
      );

  void inversePrimaryColorChanged(Color color) =>
      _updateColorScheme(_theme.colorScheme.copyWith(inversePrimary: color));

  void updateAppBarTheme(AppBarThemeData theme) {
    _theme = _theme.copyWith(appBarTheme: theme);
    notifyListeners();
  }

  void appBarBackgroundColorChanged(Color color) {
    updateAppBarTheme(_theme.appBarTheme.copyWith(backgroundColor: color));
  }

  void setStatusBarStyle(SystemUiOverlayStyle style) {
    updateAppBarTheme(_theme.appBarTheme.copyWith(systemOverlayStyle: style));
  }

  void _updateColorScheme(ColorScheme scheme) {
    _theme = _theme.copyWith(colorScheme: scheme);
    notifyListeners();
  }
}
