import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../helpers/fake_home_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('app boots with editor and preview panels', (tester) async {
    await tester.pumpEditorApp(homeRepository: FakeHomeRepository());

    expect(find.text('Theme configuration'), findsOneWidget);
    expect(find.text('Preview Canvas'), findsOneWidget);
    expect(find.byIcon(LucideIcons.palette), findsOneWidget);
  });

  testWidgets('help dialog shows export usage instructions', (tester) async {
    await tester.pumpToolbar(homeRepository: FakeHomeRepository());

    await tester.tap(find.byKey(const Key('toolbar_help_button')));
    await tester.pumpAndSettle();

    expect(find.text('Usage'), findsOneWidget);
    expect(find.textContaining('json_theme'), findsWidgets);
    expect(find.textContaining('MaterialApp('), findsWidgets);
  });
}
