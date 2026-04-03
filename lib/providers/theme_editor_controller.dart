import 'package:appainter/models/theme_usage.dart';
import 'package:appainter/models/text_variant.dart';
import 'package:appainter/repositories/home_repository.dart';
import 'package:appainter/services/basic_theme_service.dart';
import 'package:appainter/services/font_catalog_service.dart';
import 'package:appainter/services/theme_text_service.dart';
import 'package:appainter/services/util_service.dart';
import 'package:flutter/material.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

enum AppStatus { initial, ready }

enum EditorMode { basic, advanced }

class ThemeEditorController extends ChangeNotifier {
  ThemeEditorController({
    required this.homeRepo,
    BasicThemeService? basicThemeService,
    ThemeTextService? textService,
    FontCatalogService? fontCatalogService,
  })  : _basicThemeService = basicThemeService ?? BasicThemeService(),
        _textService = textService ?? ThemeTextService(),
        _fontCatalogService = fontCatalogService ?? FontCatalogService(),
        _previewThemeData = _buildInitialPreviewTheme();

  final HomeRepository homeRepo;
  final BasicThemeService _basicThemeService;
  final ThemeTextService _textService;
  final FontCatalogService _fontCatalogService;

  ThemeData _previewThemeData;
  AppStatus _status = AppStatus.initial;
  EditorMode _editorMode = EditorMode.basic;
  ThemeUsage? _themeUsage;
  Brightness _previewBrightness = Brightness.light;
  bool _keepEditorBrightnessSeparate = false;
  String? _displayFontFamily;
  String? _bodyFontFamily;
  final Map<TextVariant, String?> _textVariantFonts = {};

  static ThemeData _buildInitialPreviewTheme() {
    const seedColor = Color(0xFF2563EB);
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      useMaterial3: true,
    ).copyWith(
      primaryColor: seedColor,
    );
  }

  AppStatus get status => _status;
  EditorMode get editorMode => _editorMode;
  ThemeUsage? get themeUsage => _themeUsage;
  ThemeData get theme => previewTheme;
  ThemeData get previewThemeData => _previewThemeData;
  ThemeData get previewTheme => _buildPreviewTheme();
  ThemeData get editorTheme => _buildEditorTheme(editorBrightness);
  ThemeData get editorLightTheme => _buildEditorTheme(Brightness.light);
  ThemeData get editorDarkTheme => _buildEditorTheme(Brightness.dark);
  ThemeMode get themeMode =>
      editorBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  Brightness get previewBrightness => _previewBrightness;
  Brightness get editorBrightness =>
      _keepEditorBrightnessSeparate ? Brightness.light : _previewBrightness;
  bool get isDark => _previewBrightness == Brightness.dark;
  bool get keepEditorBrightnessSeparate => _keepEditorBrightnessSeparate;
  bool get useMaterial3 => _previewThemeData.useMaterial3;
  ColorScheme get colorScheme => previewTheme.colorScheme;
  TextTheme get previewTextTheme => previewTheme.textTheme;
  String? get displayFontFamily => _displayFontFamily;
  String? get bodyFontFamily => _bodyFontFamily;
  List<String> get availableFontFamilies => _fontCatalogService.families;

  Future<void> initialize() async {
    await Future.wait([
      fetchThemeUsage(),
      _fetchPreviewBrightness(),
    ]);
    _status = AppStatus.ready;
    notifyListeners();
  }

  Future<void> fetchThemeUsage() async {
    _themeUsage = await homeRepo.fetchThemeUsage();
    notifyListeners();
  }

  Future<void> _fetchPreviewBrightness() async {
    final saved = await homeRepo.getIsDarkTheme();
    if (saved != null) {
      _previewBrightness = saved ? Brightness.dark : Brightness.light;
      _previewThemeData = _previewThemeData.copyWith(
        brightness: _previewBrightness,
        colorScheme: _previewThemeData.colorScheme.copyWith(
          brightness: _previewBrightness,
        ),
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(bool isDarkTheme) => setPreviewBrightness(isDarkTheme);

  Future<void> setPreviewBrightness(bool isDarkTheme) async {
    _previewBrightness = isDarkTheme ? Brightness.dark : Brightness.light;
    await homeRepo.setIsDarkTheme(isDarkTheme);
    _previewThemeData = _previewThemeData.copyWith(
      brightness: _previewBrightness,
      colorScheme: _previewThemeData.colorScheme.copyWith(
        brightness: _previewBrightness,
      ),
    );
    notifyListeners();
  }

  void setKeepEditorBrightnessSeparate(bool value) {
    _keepEditorBrightnessSeparate = value;
    notifyListeners();
  }

  void setEditorMode(EditorMode mode) {
    _editorMode = mode;
    notifyListeners();
  }

  Future<void> importTheme() async {
    final imported = await homeRepo.importTheme();
    if (imported == null) return;

    _previewBrightness = imported.brightness;
    _previewThemeData = imported.copyWith(
      colorScheme: imported.colorScheme.copyWith(
        brightness: imported.brightness,
      ),
    );
    _displayFontFamily = null;
    _bodyFontFamily = null;
    _textVariantFonts.clear();
    _editorMode = EditorMode.advanced;
    notifyListeners();
  }

  Future<void> exportTheme() => homeRepo.exportTheme(previewTheme);

  void resetTheme() {
    _previewThemeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: _previewBrightness,
      ),
      useMaterial3: true,
    ).copyWith(
      primaryColor: const Color(0xFF2563EB),
    );
    _displayFontFamily = null;
    _bodyFontFamily = null;
    _textVariantFonts.clear();
    notifyListeners();
  }

  void randomizeTheme([int? seed]) {
    final scheme = randomColorScheme(
      seed: seed ?? DateTime.now().millisecondsSinceEpoch,
      isDark: isDark,
      shouldPrint: false,
    );
    _previewThemeData = _previewThemeData.copyWith(
      brightness: _previewBrightness,
      colorScheme: scheme.copyWith(brightness: _previewBrightness),
      primaryColor: scheme.primary,
      primaryColorLight: UtilService.getColorSwatch(scheme.primary)[100],
      primaryColorDark: UtilService.getColorSwatch(scheme.primary)[700],
      secondaryHeaderColor: UtilService.getColorSwatch(scheme.primary)[50],
    );
    notifyListeners();
  }

  void setUseMaterial3(bool useMaterial3) {
    _previewThemeData = _previewThemeData.copyWith(useMaterial3: useMaterial3);
    notifyListeners();
  }

  void seedColorChanged(Color color) {
    final scheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: _previewBrightness,
    );
    _previewThemeData = _previewThemeData.copyWith(
      colorScheme: scheme,
      primaryColor: color,
      primaryColorLight: UtilService.getColorSwatch(color)[100],
      primaryColorDark: UtilService.getColorSwatch(color)[700],
      secondaryHeaderColor: UtilService.getColorSwatch(color)[50],
    );
    notifyListeners();
  }

  void primaryColorChanged(Color color) {
    final swatch = UtilService.getColorSwatch(color);
    final onColor = _basicThemeService.getOnKeyColor(color);
    _previewThemeData = _previewThemeData.copyWith(
      primaryColor: color,
      primaryColorLight: swatch[100],
      primaryColorDark: swatch[700],
      secondaryHeaderColor: swatch[50],
      colorScheme: _previewThemeData.colorScheme.copyWith(
        primary: color,
        onPrimary: onColor,
      ),
    );
    notifyListeners();
  }

  void onPrimaryColorChanged(Color color) =>
      _updateColorScheme(_previewThemeData.colorScheme.copyWith(onPrimary: color));

  void secondaryColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(
          secondary: color,
          onSecondary: _basicThemeService.getOnKeyColor(color),
        ),
      );

  void surfaceColorChanged(Color color) =>
      _updateColorScheme(_previewThemeData.colorScheme.copyWith(surface: color));

  void errorColorChanged(Color color) =>
      _updateColorScheme(_previewThemeData.colorScheme.copyWith(error: color));

  void outlineColorChanged(Color color) =>
      _updateColorScheme(_previewThemeData.colorScheme.copyWith(outline: color));

  void inversePrimaryColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(inversePrimary: color),
      );

  void onSurfaceColorChanged(Color color) =>
      _updateColorScheme(_previewThemeData.colorScheme.copyWith(onSurface: color));

  void surfaceContainerHighestColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(surfaceContainerHighest: color),
      );

  void onSurfaceVariantColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(onSurfaceVariant: color),
      );

  void inverseSurfaceColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(inverseSurface: color),
      );

  void onInverseSurfaceColorChanged(Color color) => _updateColorScheme(
        _previewThemeData.colorScheme.copyWith(onInverseSurface: color),
      );

  void appBarBackgroundColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      appBarTheme: _previewThemeData.appBarTheme.copyWith(
        backgroundColor: color,
        foregroundColor: _basicThemeService.getOnKeyColor(color),
      ),
    );
    notifyListeners();
  }

  void filledButtonBackgroundColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: _basicThemeService.getOnKeyColor(color),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: _basicThemeService.getOnKeyColor(color),
        ),
      ),
    );
    notifyListeners();
  }

  void outlinedButtonColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: color,
        ),
      ),
    );
    notifyListeners();
  }

  void inputFillColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      inputDecorationTheme: _previewThemeData.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: color,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _previewThemeData.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _previewThemeData.colorScheme.primary),
        ),
      ),
    );
    notifyListeners();
  }

  void tabIndicatorColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      tabBarTheme: _previewThemeData.tabBarTheme.copyWith(
        indicatorColor: color,
        labelColor: color,
        unselectedLabelColor: color.withValues(alpha: 0.7),
      ),
    );
    notifyListeners();
  }

  void fabBackgroundColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      floatingActionButtonTheme: _previewThemeData.floatingActionButtonTheme
          .copyWith(
            backgroundColor: color,
            foregroundColor: _basicThemeService.getOnKeyColor(color),
          ),
    );
    notifyListeners();
  }

  void bottomNavigationColorChanged(Color color) {
    _previewThemeData = _previewThemeData.copyWith(
      bottomNavigationBarTheme: _previewThemeData.bottomNavigationBarTheme
          .copyWith(
            selectedItemColor: color,
            unselectedItemColor: color.withValues(alpha: 0.6),
          ),
    );
    notifyListeners();
  }

  void setDisplayFontFamily(String? family) {
    _displayFontFamily = _normalizeFontFamily(family);
    notifyListeners();
  }

  void setBodyFontFamily(String? family) {
    _bodyFontFamily = _normalizeFontFamily(family);
    notifyListeners();
  }

  void setTextStyleFont(TextVariant variant, String? family) {
    final normalized = _normalizeFontFamily(family);
    if (normalized == null) {
      _textVariantFonts.remove(variant);
    } else {
      _textVariantFonts[variant] = normalized;
    }
    notifyListeners();
  }

  void clearTextStyleFont(TextVariant variant) {
    _textVariantFonts.remove(variant);
    notifyListeners();
  }

  String? fontForVariant(TextVariant variant) {
    return _textVariantFonts[variant] ?? roleFont(variant.role);
  }

  bool hasTextStyleOverride(TextVariant variant) =>
      _textVariantFonts.containsKey(variant);

  String? roleFont(FontRole role) => switch (role) {
        FontRole.display => _displayFontFamily,
        FontRole.body => _bodyFontFamily,
      };

  void _updateColorScheme(ColorScheme scheme) {
    _previewThemeData = _previewThemeData.copyWith(colorScheme: scheme);
    notifyListeners();
  }

  String? _normalizeFontFamily(String? family) {
    if (family == null || family.trim().isEmpty || family == 'Default') {
      return null;
    }
    return family;
  }

  ThemeData _buildPreviewTheme() {
    final colorScheme = _previewThemeData.colorScheme.copyWith(
      brightness: _previewBrightness,
    );
    final baseTheme = _previewThemeData.copyWith(
      brightness: _previewBrightness,
      colorScheme: colorScheme,
    );

    final textTheme = _textService.buildTextTheme(
      brightness: _previewBrightness,
      useMaterial3: baseTheme.useMaterial3,
      baseOverride: baseTheme.textTheme,
      displayFontFamily: _displayFontFamily,
      bodyFontFamily: _bodyFontFamily,
      textVariantFonts: _textVariantFonts,
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: baseTheme.appBarTheme.foregroundColor ??
              colorScheme.onSurface,
        ),
        toolbarTextStyle: textTheme.bodyMedium?.copyWith(
          color: baseTheme.appBarTheme.foregroundColor ??
              colorScheme.onSurface,
        ),
      ),
    );
  }

  ThemeData _buildEditorTheme(Brightness brightness) {
    final shellScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F766E),
      brightness: brightness,
    );
    final baseTheme = ThemeData.from(
      colorScheme: shellScheme,
      useMaterial3: true,
    );
    final textTheme = _textService.buildTextTheme(
      brightness: brightness,
      useMaterial3: true,
      baseOverride: baseTheme.textTheme,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF4F7F9),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: shellScheme.outline.withValues(alpha: 0.18),
          ),
        ),
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor:
            brightness == Brightness.dark ? const Color(0xFF111827) : Colors.white,
        foregroundColor: shellScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: shellScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: shellScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: shellScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: shellScheme.primary, width: 1.4),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: shellScheme.primary,
        unselectedLabelColor: shellScheme.onSurfaceVariant,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: shellScheme.primaryContainer.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
