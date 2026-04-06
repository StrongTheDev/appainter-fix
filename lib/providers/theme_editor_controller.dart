import 'dart:collection';

import 'package:appainter/models/text_variant.dart';
import 'package:appainter/models/theme_usage.dart';
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
        _previewLightThemeData = _buildInitialPreviewTheme(Brightness.light),
        _previewDarkThemeData = _buildInitialPreviewTheme(Brightness.dark) {
    _syncColorMapFromTheme();
  }

  final HomeRepository homeRepo;
  final BasicThemeService _basicThemeService;
  final ThemeTextService _textService;
  final FontCatalogService _fontCatalogService;

  ThemeData _previewLightThemeData;
  ThemeData _previewDarkThemeData;
  AppStatus _status = AppStatus.initial;
  EditorMode _editorMode = EditorMode.basic;
  ThemeUsage? _themeUsage;
  Brightness _previewBrightness = Brightness.light;
  Brightness _editorBrightness = Brightness.light;
  bool _keepEditorBrightnessSeparate = true;
  String? _displayFontFamily;
  String? _bodyFontFamily;
  final Map<TextVariant, String?> _textVariantFonts = {};
  final Map<String, Color> _colorMap = {};
  ThemeData? _cachedPreviewTheme;
  Brightness? _cachedPreviewBrightness;

  static const List<String> editableColorFields = [
    'seed',
    'primary',
    'onPrimary',
    'primaryContainer',
    'onPrimaryContainer',
    'secondary',
    'onSecondary',
    'secondaryContainer',
    'onSecondaryContainer',
    'tertiary',
    'onTertiary',
    'tertiaryContainer',
    'onTertiaryContainer',
    'error',
    'onError',
    'errorContainer',
    'onErrorContainer',
    'surface',
    'onSurface',
    'surfaceContainerHighest',
    'onSurfaceVariant',
    'outline',
    'outlineVariant',
    'inverseSurface',
    'onInverseSurface',
    'inversePrimary',
    'surfaceTint',
    'scrim',
  ];

  static ThemeData _buildInitialPreviewTheme(Brightness brightness) {
    const seedColor = Color(0xFF2563EB);
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    ).copyWith(
      brightness: brightness,
      primaryColor: seedColor,
    );
  }

  AppStatus get status => _status;
  EditorMode get editorMode => _editorMode;
  ThemeUsage? get themeUsage => _themeUsage;
  ThemeData get theme => previewTheme;
  ThemeData get previewThemeData => _previewThemeFor(_previewBrightness);
  ThemeData get previewTheme {
    if (_cachedPreviewTheme != null &&
        _cachedPreviewBrightness == _previewBrightness) {
      return _cachedPreviewTheme!;
    }
    final built = _buildPreviewTheme();
    _cachedPreviewTheme = built;
    _cachedPreviewBrightness = _previewBrightness;
    return built;
  }
  ThemeData get editorTheme => _buildEditorTheme(editorBrightness);
  ThemeData get editorLightTheme => _buildEditorTheme(Brightness.light);
  ThemeData get editorDarkTheme => _buildEditorTheme(Brightness.dark);
  ThemeMode get themeMode =>
      editorBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  Brightness get previewBrightness => _previewBrightness;
  Brightness get editorBrightness =>
      _keepEditorBrightnessSeparate ? _editorBrightness : _previewBrightness;
  bool get isDark => _previewBrightness == Brightness.dark;
  bool get isEditorDark => editorBrightness == Brightness.dark;
  bool get keepEditorBrightnessSeparate => _keepEditorBrightnessSeparate;
  bool get useMaterial3 => previewThemeData.useMaterial3;
  ColorScheme get colorScheme => previewTheme.colorScheme;
  TextTheme get previewTextTheme => previewTheme.textTheme;
  String? get displayFontFamily => _displayFontFamily;
  String? get bodyFontFamily => _bodyFontFamily;
  List<String> get availableFontFamilies => _fontCatalogService.families;
  Map<String, Color> get colorMap => UnmodifiableMapView(_colorMap);

  Future<void> initialize() async {
    await Future.wait([
      fetchThemeUsage(),
      _fetchPreviewBrightness(),
      _fetchEditorBrightness(),
    ]);
    _status = AppStatus.ready;
    _syncColorMapFromTheme();
    notifyListeners();
  }

  Future<void> fetchThemeUsage() async {
    _themeUsage = await homeRepo.fetchThemeUsage();
    notifyListeners();
  }

  Future<void> _fetchPreviewBrightness() async {
    final saved = await homeRepo.getPreviewDarkTheme();
    if (saved != null) {
      _previewBrightness = saved ? Brightness.dark : Brightness.light;
      notifyListeners();
    }
  }

  Future<void> _fetchEditorBrightness() async {
    final saved = await homeRepo.getEditorDarkTheme();
    if (saved != null) {
      _editorBrightness = saved ? Brightness.dark : Brightness.light;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(bool isDarkTheme) =>
      setPreviewBrightness(isDarkTheme);
  Future<void> setEditorThemeMode(bool isDarkTheme) =>
      setEditorBrightness(isDarkTheme);

  Future<void> setPreviewBrightness(bool isDarkTheme) async {
    _previewBrightness = isDarkTheme ? Brightness.dark : Brightness.light;
    _invalidatePreviewThemeCache();
    await homeRepo.setPreviewDarkTheme(isDarkTheme);
    notifyListeners();
  }

  Future<void> setEditorBrightness(bool isDarkTheme) async {
    if (!_keepEditorBrightnessSeparate) {
      await setPreviewBrightness(isDarkTheme);
      return;
    }
    _editorBrightness = isDarkTheme ? Brightness.dark : Brightness.light;
    await homeRepo.setEditorDarkTheme(isDarkTheme);
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
    _previewLightThemeData = _deriveThemeForBrightness(
      imported,
      Brightness.light,
    );
    _previewDarkThemeData = _deriveThemeForBrightness(
      imported,
      Brightness.dark,
    );
    _displayFontFamily = null;
    _bodyFontFamily = null;
    _textVariantFonts.clear();
    _syncColorMapFromTheme();
    _editorMode = EditorMode.advanced;
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  Future<void> exportTheme() => homeRepo.exportTheme(previewTheme);

  void resetTheme() {
    _previewLightThemeData = _buildInitialPreviewTheme(Brightness.light);
    _previewDarkThemeData = _buildInitialPreviewTheme(Brightness.dark);
    _displayFontFamily = null;
    _bodyFontFamily = null;
    _textVariantFonts.clear();
    _syncColorMapFromTheme();
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void randomizeTheme([int? seed]) {
    final randomSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    _updatePreviewThemes((brightness, theme) {
      final scheme = randomColorScheme(
        seed: randomSeed,
        isDark: brightness == Brightness.dark,
        shouldPrint: false,
      ).copyWith(brightness: brightness);
      return theme.copyWith(
        brightness: brightness,
        colorScheme: scheme,
        primaryColor: scheme.primary,
        primaryColorLight: UtilService.getColorSwatch(scheme.primary)[100],
        primaryColorDark: UtilService.getColorSwatch(scheme.primary)[700],
        secondaryHeaderColor: UtilService.getColorSwatch(scheme.primary)[50],
      );
    });
    _syncColorMapFromTheme();
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  // void setUseMaterial3(bool useMaterial3) {
  //   _updatePreviewThemes(
  //     (brightness, theme) => _rebuildPreviewBaseTheme(
  //       theme,
  //       brightness: brightness,
  //       useMaterial3: useMaterial3,
  //     ),
  //   );
  //   _syncColorMapFromTheme();
  //   notifyListeners();
  // }

  void setColor(String field, Color color) {
    _colorMap[field] = color;

    if (field == 'seed') {
      _updatePreviewThemes((brightness, theme) {
        final scheme = ColorScheme.fromSeed(
          seedColor: color,
          brightness: brightness,
        );
        return theme.copyWith(
          brightness: brightness,
          colorScheme: scheme,
          primaryColor: color,
          primaryColorLight: UtilService.getColorSwatch(color)[100],
          primaryColorDark: UtilService.getColorSwatch(color)[700],
          secondaryHeaderColor: UtilService.getColorSwatch(color)[50],
        );
      });
      _invalidatePreviewThemeCache();
      notifyListeners();
      return;
    }

    _updatePreviewThemes(
      (brightness, theme) => _applyColorField(
        theme,
        brightness: brightness,
        field: field,
        color: color,
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void seedColorChanged(Color color) => setColor('seed', color);
  void primaryColorChanged(Color color) => setColor('primary', color);
  void onPrimaryColorChanged(Color color) => setColor('onPrimary', color);
  void secondaryColorChanged(Color color) => setColor('secondary', color);
  void surfaceColorChanged(Color color) => setColor('surface', color);
  void errorColorChanged(Color color) => setColor('error', color);
  void outlineColorChanged(Color color) => setColor('outline', color);
  void inversePrimaryColorChanged(Color color) =>
      setColor('inversePrimary', color);
  void onSurfaceColorChanged(Color color) => setColor('onSurface', color);
  void surfaceContainerHighestColorChanged(Color color) =>
      setColor('surfaceContainerHighest', color);
  void onSurfaceVariantColorChanged(Color color) =>
      setColor('onSurfaceVariant', color);
  void inverseSurfaceColorChanged(Color color) =>
      setColor('inverseSurface', color);
  void onInverseSurfaceColorChanged(Color color) =>
      setColor('onInverseSurface', color);

  void appBarBackgroundColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: color,
          foregroundColor: _basicThemeService.getOnKeyColor(color),
        ),
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void filledButtonBackgroundColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
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
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void outlinedButtonColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
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
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void inputFillColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void tabIndicatorColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
        tabBarTheme: theme.tabBarTheme.copyWith(
          indicatorColor: color,
          labelColor: color,
          unselectedLabelColor: color.withValues(alpha: 0.7),
        ),
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void fabBackgroundColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
        floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
          backgroundColor: color,
          foregroundColor: _basicThemeService.getOnKeyColor(color),
        ),
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void bottomNavigationColorChanged(Color color) {
    _updatePreviewThemes(
      (brightness, theme) => theme.copyWith(
        bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
          selectedItemColor: color,
          unselectedItemColor: color.withValues(alpha: 0.6),
        ),
      ),
    );
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void setDisplayFontFamily(String? family) {
    _displayFontFamily = _normalizeFontFamily(family);
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void setBodyFontFamily(String? family) {
    _bodyFontFamily = _normalizeFontFamily(family);
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void setTextStyleFont(TextVariant variant, String? family) {
    final normalized = _normalizeFontFamily(family);
    if (normalized == null) {
      _textVariantFonts.remove(variant);
    } else {
      _textVariantFonts[variant] = normalized;
    }
    _invalidatePreviewThemeCache();
    notifyListeners();
  }

  void clearTextStyleFont(TextVariant variant) {
    _textVariantFonts.remove(variant);
    _invalidatePreviewThemeCache();
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

  Color colorForField(String field) {
    final activeTheme = previewTheme;
    return _colorMap[field] ?? switch (field) {
      'seed' => activeTheme.primaryColor,
      'primary' => activeTheme.colorScheme.primary,
      'onPrimary' => activeTheme.colorScheme.onPrimary,
      'primaryContainer' => activeTheme.colorScheme.primaryContainer,
      'onPrimaryContainer' => activeTheme.colorScheme.onPrimaryContainer,
      'secondary' => activeTheme.colorScheme.secondary,
      'onSecondary' => activeTheme.colorScheme.onSecondary,
      'secondaryContainer' => activeTheme.colorScheme.secondaryContainer,
      'onSecondaryContainer' => activeTheme.colorScheme.onSecondaryContainer,
      'tertiary' => activeTheme.colorScheme.tertiary,
      'onTertiary' => activeTheme.colorScheme.onTertiary,
      'tertiaryContainer' => activeTheme.colorScheme.tertiaryContainer,
      'onTertiaryContainer' => activeTheme.colorScheme.onTertiaryContainer,
      'error' => activeTheme.colorScheme.error,
      'onError' => activeTheme.colorScheme.onError,
      'errorContainer' => activeTheme.colorScheme.errorContainer,
      'onErrorContainer' => activeTheme.colorScheme.onErrorContainer,
      'surface' => activeTheme.colorScheme.surface,
      'onSurface' => activeTheme.colorScheme.onSurface,
      'surfaceContainerHighest' =>
        activeTheme.colorScheme.surfaceContainerHighest,
      'onSurfaceVariant' => activeTheme.colorScheme.onSurfaceVariant,
      'outline' => activeTheme.colorScheme.outline,
      'outlineVariant' => activeTheme.colorScheme.outlineVariant,
      'inverseSurface' => activeTheme.colorScheme.inverseSurface,
      'onInverseSurface' => activeTheme.colorScheme.onInverseSurface,
      'inversePrimary' => activeTheme.colorScheme.inversePrimary,
      'surfaceTint' => activeTheme.colorScheme.surfaceTint,
      'scrim' => activeTheme.colorScheme.scrim,
      _ => activeTheme.colorScheme.primary,
    };
  }

  // void _updateColorScheme(ColorScheme Function(ColorScheme scheme) update) {
  //   _updatePreviewThemes(
  //     (brightness, theme) => theme.copyWith(
  //       colorScheme: update(theme.colorScheme).copyWith(brightness: brightness),
  //     ),
  //   );
  //   notifyListeners();
  // }

  String? _normalizeFontFamily(String? family) {
    if (family == null || family.trim().isEmpty || family == 'Default') {
      return null;
    }
    return family;
  }

  ThemeData _applyColorField(
    ThemeData theme, {
    required Brightness brightness,
    required String field,
    required Color color,
  }) {
    final swatch = UtilService.getColorSwatch(color);
    final scheme = theme.colorScheme;
    final nextScheme = switch (field) {
      'primary' => scheme.copyWith(primary: color, brightness: brightness),
      'onPrimary' => scheme.copyWith(onPrimary: color, brightness: brightness),
      'primaryContainer' =>
        scheme.copyWith(primaryContainer: color, brightness: brightness),
      'onPrimaryContainer' =>
        scheme.copyWith(onPrimaryContainer: color, brightness: brightness),
      'secondary' => scheme.copyWith(secondary: color, brightness: brightness),
      'onSecondary' =>
        scheme.copyWith(onSecondary: color, brightness: brightness),
      'secondaryContainer' =>
        scheme.copyWith(secondaryContainer: color, brightness: brightness),
      'onSecondaryContainer' => scheme.copyWith(
          onSecondaryContainer: color,
          brightness: brightness,
        ),
      'tertiary' => scheme.copyWith(tertiary: color, brightness: brightness),
      'onTertiary' =>
        scheme.copyWith(onTertiary: color, brightness: brightness),
      'tertiaryContainer' =>
        scheme.copyWith(tertiaryContainer: color, brightness: brightness),
      'onTertiaryContainer' => scheme.copyWith(
          onTertiaryContainer: color,
          brightness: brightness,
        ),
      'error' => scheme.copyWith(error: color, brightness: brightness),
      'onError' => scheme.copyWith(onError: color, brightness: brightness),
      'errorContainer' =>
        scheme.copyWith(errorContainer: color, brightness: brightness),
      'onErrorContainer' =>
        scheme.copyWith(onErrorContainer: color, brightness: brightness),
      'surface' => scheme.copyWith(surface: color, brightness: brightness),
      'onSurface' => scheme.copyWith(onSurface: color, brightness: brightness),
      'surfaceContainerHighest' => scheme.copyWith(
          surfaceContainerHighest: color,
          brightness: brightness,
        ),
      'onSurfaceVariant' =>
        scheme.copyWith(onSurfaceVariant: color, brightness: brightness),
      'outline' => scheme.copyWith(outline: color, brightness: brightness),
      'outlineVariant' =>
        scheme.copyWith(outlineVariant: color, brightness: brightness),
      'inverseSurface' =>
        scheme.copyWith(inverseSurface: color, brightness: brightness),
      'onInverseSurface' =>
        scheme.copyWith(onInverseSurface: color, brightness: brightness),
      'inversePrimary' =>
        scheme.copyWith(inversePrimary: color, brightness: brightness),
      'surfaceTint' =>
        scheme.copyWith(surfaceTint: color, brightness: brightness),
      'scrim' => scheme.copyWith(scrim: color, brightness: brightness),
      _ => scheme.copyWith(brightness: brightness),
    };

    return theme.copyWith(
      brightness: brightness,
      colorScheme: nextScheme,
      primaryColor: field == 'primary' ? color : theme.primaryColor,
      primaryColorLight:
          field == 'primary' ? swatch[100] : theme.primaryColorLight,
      primaryColorDark:
          field == 'primary' ? swatch[700] : theme.primaryColorDark,
      secondaryHeaderColor:
          field == 'primary' ? swatch[50] : theme.secondaryHeaderColor,
    );
  }

  ThemeData _buildPreviewTheme() {
    final base = _previewThemeFor(_previewBrightness);
    final colorScheme = base.colorScheme.copyWith(
      brightness: _previewBrightness,
    );
    final baseTheme = base.copyWith(
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
          color: baseTheme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        ),
        toolbarTextStyle: textTheme.bodyMedium?.copyWith(
          color: baseTheme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
        ),
      ),
    );
  }

  ThemeData _previewThemeFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? _previewDarkThemeData
        : _previewLightThemeData;
  }

  ThemeData _deriveThemeForBrightness(ThemeData source, Brightness brightness) {
    final seedColor = source.primaryColor != Colors.transparent
        ? source.primaryColor
        : source.colorScheme.primary;
    return _rebuildPreviewBaseTheme(
      source,
      brightness: brightness,
      seedColor: seedColor,
    );
  }

  ThemeData _rebuildPreviewBaseTheme(
    ThemeData source, {
    required Brightness brightness,
    bool? useMaterial3,
    Color? seedColor,
  }) {
    final resolvedUseMaterial3 = useMaterial3 ?? source.useMaterial3;
    final resolvedSeedColor = seedColor ??
        (source.primaryColor != Colors.transparent
            ? source.primaryColor
            : source.colorScheme.primary);
    final derivedScheme = ColorScheme.fromSeed(
      seedColor: resolvedSeedColor,
      brightness: brightness,
    );
    final rebuilt = ThemeData.from(
      colorScheme: derivedScheme,
      useMaterial3: resolvedUseMaterial3,
    );

    return rebuilt.copyWith(
      brightness: brightness,
      primaryColor: resolvedSeedColor,
      primaryColorLight: UtilService.getColorSwatch(resolvedSeedColor)[100],
      primaryColorDark: UtilService.getColorSwatch(resolvedSeedColor)[700],
      secondaryHeaderColor: UtilService.getColorSwatch(resolvedSeedColor)[50],
      appBarTheme: source.appBarTheme,
      filledButtonTheme: source.filledButtonTheme,
      elevatedButtonTheme: source.elevatedButtonTheme,
      outlinedButtonTheme: source.outlinedButtonTheme,
      textButtonTheme: source.textButtonTheme,
      inputDecorationTheme: source.inputDecorationTheme,
      tabBarTheme: source.tabBarTheme,
      floatingActionButtonTheme: source.floatingActionButtonTheme,
      bottomNavigationBarTheme: source.bottomNavigationBarTheme,
    );
  }

  void _syncColorMapFromTheme() {
    for (final field in editableColorFields) {
      _colorMap[field] = colorForField(field);
    }
  }

  // void _setPreviewThemeFor(Brightness brightness, ThemeData theme) {
  //   if (brightness == Brightness.dark) {
  //     _previewDarkThemeData = theme;
  //   } else {
  //     _previewLightThemeData = theme;
  //   }
  // }

  void _updatePreviewThemes(
    ThemeData Function(Brightness brightness, ThemeData theme) update,
  ) {
    _previewLightThemeData = update(Brightness.light, _previewLightThemeData);
    _previewDarkThemeData = update(Brightness.dark, _previewDarkThemeData);
    _invalidatePreviewThemeCache();
  }

  void _invalidatePreviewThemeCache() {
    _cachedPreviewTheme = null;
    _cachedPreviewBrightness = null;
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
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F7F9),
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
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF111827)
            : Colors.white,
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
