import 'package:appainter/components/editors/advanced_theme_panel.dart';
import 'package:appainter/components/editors/basic_theme_panel.dart';
import 'package:appainter/components/editors/section_header.dart';
import 'package:appainter/components/preview/theme_preview_panel.dart';
import 'package:appainter/components/toolbar/editor_toolbar.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppProvider>();
    _controller = TabController(
      length: EditorMode.values.length,
      initialIndex: EditorMode.values.indexOf(app.editorMode),
      vsync: this,
    );
    _controller.addListener(() {
      if (!_controller.indexIsChanging) {
        context
            .read<AppProvider>()
            .setEditorMode(EditorMode.values[_controller.index]);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final targetIndex = EditorMode.values.indexOf(app.editorMode);
    if (_controller.index != targetIndex) {
      _controller.animateTo(targetIndex);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const EditorToolbar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TabBar(
                          controller: _controller,
                          tabs: const [
                            Tab(text: 'Basic'),
                            Tab(text: 'Advanced'),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        key: const Key('toolbar_randomize_theme'),
                        onPressed: () =>
                            context.read<AppProvider>().randomizeTheme(),
                        icon: const Icon(Icons.shuffle_rounded),
                      ),
                      IconButton(
                        key: const Key('toolbar_reset_theme'),
                        onPressed: () =>
                            context.read<AppProvider>().resetTheme(),
                        icon: const Icon(Icons.restore),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ConfigBar(app: app),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: const [
                        BasicThemePanel(),
                        AdvancedThemePanel(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: ThemePreviewPanel()),
          ],
        ),
      ),
    );
  }
}

class _ConfigBar extends StatelessWidget {
  const _ConfigBar({required this.app});

  final AppProvider app;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SectionHeader(
                    title: "Theme configuration",
                    subtitle:
                        "Configure the themes throughout the app and preview.",
                  ),
                ),
              ],
            ),
            SwitchListTile(
              key: const Key('material3_switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Use Material 3'),
              value: app.useMaterial3,
              onChanged: app.setUseMaterial3,
            ),
            SwitchListTile(
              key: const Key('preview_brightness_switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                app.isDark
                    ? 'Preview Brightness: Dark'
                    : 'Preview Brightness: Light',
              ),
              value: app.isDark,
              onChanged: app.setPreviewBrightness,
            ),
            // SwitchListTile(
            //   key: const Key('preview_separate_shell_switch'),
            //   contentPadding: EdgeInsets.zero,
            //   title: const Text('Keep editor brightness separate'),
            //   value: app.keepEditorBrightnessSeparate,
            //   onChanged: app.setKeepEditorBrightnessSeparate,
            // ),
          ],
        ),
      ),
    );
  }
}
