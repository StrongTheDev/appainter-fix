import 'package:appainter/pages/editor_page.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:appainter/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppainterApp extends StatelessWidget {
  const AppainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(homeRepo: HomeRepository())..initialize(),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Appainter',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      theme: app.editorLightTheme,
      darkTheme: app.editorDarkTheme,
      themeMode: app.themeMode,
      home: app.status == AppStatus.ready
          ? const EditorPage()
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
