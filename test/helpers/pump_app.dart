import 'package:appainter/components/toolbar/editor_toolbar.dart';
import 'package:appainter/pages/editor_page.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:appainter/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

extension PumpApp on WidgetTester {
  Future<AppProvider> pumpEditorApp({
    HomeRepository? homeRepository,
    AppProvider? provider,
  }) async {
    final appProvider =
        provider ?? AppProvider(homeRepo: homeRepository ?? HomeRepository());
    await appProvider.initialize();

    await pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: appProvider,
        child: Consumer<AppProvider>(
          builder: (context, app, child) {
            return MaterialApp(
              themeAnimationDuration: Duration.zero,
              theme: app.editorLightTheme,
              darkTheme: app.editorDarkTheme,
              themeMode: app.themeMode,
              home: const EditorPage(),
            );
          },
        ),
      ),
    );
    await pumpAndSettle();
    return appProvider;
  }

  Future<AppProvider> pumpToolbar({
    HomeRepository? homeRepository,
  }) async {
    final provider = AppProvider(homeRepo: homeRepository ?? HomeRepository());
    await provider.initialize();
    await pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: provider,
        child: MaterialApp(
          home: const Scaffold(appBar: EditorToolbar()),
        ),
      ),
    );
    await pumpAndSettle();
    return provider;
  }
}
