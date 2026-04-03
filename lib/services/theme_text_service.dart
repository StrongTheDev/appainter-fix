import 'package:appainter/models/text_variant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeTextService {
  TextTheme buildTextTheme({
    required Brightness brightness,
    required bool useMaterial3,
    TextTheme? baseOverride,
    String? displayFontFamily,
    String? bodyFontFamily,
    Map<TextVariant, String?> textVariantFonts = const {},
  }) {
    final materialBase = ThemeData(
      brightness: brightness,
      useMaterial3: useMaterial3,
    ).textTheme;
    final merged = materialBase.merge(baseOverride);

    TextStyle resolve(TextVariant variant, TextStyle? style) {
      final fallback = _normalizeStyle(style ?? const TextStyle());
      final family = textVariantFonts[variant] ??
          (variant.role == FontRole.display
              ? displayFontFamily
              : bodyFontFamily);
      if (family == null) {
        return fallback;
      }
      final styled = GoogleFonts.getFont(
        family,
        textStyle: fallback,
      );
      return _normalizeStyle(styled);
    }

    return TextTheme(
      displayLarge: resolve(TextVariant.displayLarge, merged.displayLarge),
      displayMedium: resolve(TextVariant.displayMedium, merged.displayMedium),
      displaySmall: resolve(TextVariant.displaySmall, merged.displaySmall),
      headlineLarge: resolve(TextVariant.headlineLarge, merged.headlineLarge),
      headlineMedium:
          resolve(TextVariant.headlineMedium, merged.headlineMedium),
      headlineSmall: resolve(TextVariant.headlineSmall, merged.headlineSmall),
      titleLarge: resolve(TextVariant.titleLarge, merged.titleLarge),
      titleMedium: resolve(TextVariant.titleMedium, merged.titleMedium),
      titleSmall: resolve(TextVariant.titleSmall, merged.titleSmall),
      bodyLarge: resolve(TextVariant.bodyLarge, merged.bodyLarge),
      bodyMedium: resolve(TextVariant.bodyMedium, merged.bodyMedium),
      bodySmall: resolve(TextVariant.bodySmall, merged.bodySmall),
      labelLarge: resolve(TextVariant.labelLarge, merged.labelLarge),
      labelMedium: resolve(TextVariant.labelMedium, merged.labelMedium),
      labelSmall: resolve(TextVariant.labelSmall, merged.labelSmall),
    );
  }

  TextStyle _normalizeStyle(TextStyle style) {
    return style.copyWith(
      inherit: true,
      fontFamilyFallback: style.fontFamilyFallback == null
          ? null
          : List<String>.from(style.fontFamilyFallback!),
      decoration: style.decoration ?? TextDecoration.none,
    );
  }
}
