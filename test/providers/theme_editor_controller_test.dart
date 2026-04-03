import 'package:appainter/models/text_variant.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/fake_home_repository.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ThemeEditorController', () {
    test('preview brightness preserves edited colors', () async {
      final repo = FakeHomeRepository();
      final controller = AppProvider(homeRepo: repo);
      await controller.initialize();
      const customPrimary = Color(0xFF7C3AED);

      controller.primaryColorChanged(customPrimary);
      await controller.setPreviewBrightness(true);

      expect(controller.previewTheme.colorScheme.primary, customPrimary);
      expect(controller.previewTheme.brightness, Brightness.dark);
    });

    test('shell brightness follows preview only when separation is off', () async {
      final controller = AppProvider(homeRepo: FakeHomeRepository());
      await controller.initialize();

      await controller.setPreviewBrightness(true);
      expect(controller.editorTheme.brightness, Brightness.dark);

      controller.setKeepEditorBrightnessSeparate(true);
      expect(controller.editorTheme.brightness, Brightness.light);
    });

    test('role fonts and overrides resolve correctly', () async {
      final controller = AppProvider(homeRepo: FakeHomeRepository());
      await controller.initialize();

      controller.setDisplayFontFamily('Poppins');
      controller.setBodyFontFamily('Inter');

      expect(
        controller.fontForVariant(TextVariant.headlineMedium),
        'Poppins',
      );
      expect(
        controller.fontForVariant(TextVariant.bodyMedium),
        'Inter',
      );

      controller.setTextStyleFont(TextVariant.bodyMedium, 'Lora');
      expect(
        controller.fontForVariant(TextVariant.bodyMedium),
        'Lora',
      );

      controller.clearTextStyleFont(TextVariant.bodyMedium);
      expect(
        controller.fontForVariant(TextVariant.bodyMedium),
        'Inter',
      );
    });

    test('export uses preview theme', () async {
      final repo = FakeHomeRepository();
      final controller = AppProvider(homeRepo: repo);
      await controller.initialize();

      controller.primaryColorChanged(const Color(0xFF10B981));
      await controller.exportTheme();

      expect(repo.exportedTheme, isNotNull);
      expect(
        repo.exportedTheme!.colorScheme.primary,
        const Color(0xFF10B981),
      );
    });

    test('normalized preview text styles keep inherit true', () async {
      final controller = AppProvider(homeRepo: FakeHomeRepository());
      await controller.initialize();

      controller.setDisplayFontFamily('Space Grotesk');
      controller.setBodyFontFamily('Inter');

      expect(controller.previewTheme.textTheme.displayLarge?.inherit, isTrue);
      expect(controller.previewTheme.textTheme.bodyMedium?.inherit, isTrue);
    });
  });
}
