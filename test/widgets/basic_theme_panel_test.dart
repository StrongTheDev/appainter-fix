import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/fake_home_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('basic page shows grouped headers and font controls', (tester) async {
    await tester.pumpEditorApp(homeRepository: FakeHomeRepository());

    expect(find.text('Quick Palette'), findsOneWidget);
    expect(find.text('Typography Roles'), findsOneWidget);
    expect(find.byKey(const Key('basic_display_font_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('basic_body_font_dropdown')), findsOneWidget);
  });

  testWidgets('basic color picker opens dialog', (tester) async {
    await tester.pumpEditorApp(homeRepository: FakeHomeRepository());

    await tester.tap(find.byKey(const Key('basic_primary_color_picker')));
    await tester.pumpAndSettle();

    expect(find.text('Primary'), findsWidgets);
    expect(find.text('Apply'), findsOneWidget);
  });

  testWidgets('preview brightness toggle preserves edited color', (tester) async {
    final provider =
        await tester.pumpEditorApp(homeRepository: FakeHomeRepository());
    const customColor = Color(0xFFE11D48);
    provider.primaryColorChanged(customColor);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('preview_brightness_switch')));
    await tester.pumpAndSettle();

    expect(provider.previewTheme.colorScheme.primary, customColor);
    expect(provider.previewTheme.brightness, Brightness.dark);
  });
}
