import 'package:appainter/models/text_variant.dart';
import 'package:appainter/providers/theme_editor_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/fake_home_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('advanced page renders preview-facing sections', (tester) async {
    final provider =
        await tester.pumpEditorApp(homeRepository: FakeHomeRepository());
    provider.setEditorMode(EditorMode.advanced);
    await tester.pumpAndSettle();

    expect(find.text('Advanced Controls'), findsOneWidget);
    expect(find.text('App bar'), findsOneWidget);
    expect(find.text('Buttons'), findsOneWidget);
    expect(find.text('Inputs'), findsOneWidget);
    expect(find.text('Tabs'), findsOneWidget);
    expect(find.text('Floating action button'), findsOneWidget);
    expect(find.text('Bottom navigation'), findsOneWidget);
    expect(find.text('Typography'), findsOneWidget);
  });

  testWidgets('advanced font override can be changed and reset', (tester) async {
    final provider =
        await tester.pumpEditorApp(homeRepository: FakeHomeRepository());
    provider.setEditorMode(EditorMode.advanced);
    provider.setDisplayFontFamily('Poppins');
    await tester.pumpAndSettle();

    provider.setTextStyleFont(TextVariant.titleLarge, 'Playfair Display');
    await tester.pumpAndSettle();
    expect(provider.fontForVariant(TextVariant.titleLarge), 'Playfair Display');

    await tester.tap(find.byKey(const Key('advanced_font_reset_titleLarge')));
    await tester.pumpAndSettle();
    expect(provider.fontForVariant(TextVariant.titleLarge), 'Poppins');
  });
}
