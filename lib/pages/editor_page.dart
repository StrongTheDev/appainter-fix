import 'package:appainter/components/editors/advanced_theme_panel.dart';
import 'package:appainter/components/editors/basic_theme_panel.dart';
import 'package:appainter/components/preview/theme_preview_panel.dart';
import 'package:appainter/components/toolbar/editor_toolbar.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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
    final editorMode = context.select<AppProvider, EditorMode>(
      (app) => app.editorMode,
    );
    final isDark = context.select<AppProvider, bool>((app) => app.isDark);
    final targetIndex = EditorMode.values.indexOf(editorMode);
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
                            Tab(
                              child: SizedBox.expand(
                                child: Center(child: Text('Colors')),
                              ),
                            ),
                            Tab(
                              child: SizedBox.expand(
                                child: Center(child: Text('Typography')),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Tooltip(
                      //   message: "Use Material ${app.useMaterial3 ? "2" : "3"}",
                      //   child: IconSwitch(
                      //     value: app.useMaterial3,
                      //     onChanged: app.setUseMaterial3,
                      //     valueTrueIcon: IconData(51, fontFamily: "monospace"),
                      //     valueFalseIcon: IconData(50),
                      //   ),
                      // ),
                      Tooltip(
                        message:
                            "Set Preview Brightnes to ${isDark ? "Light" : "Dark"}",
                        child: IconSwitch(
                          value: isDark,
                          onChanged:
                              context.read<AppProvider>().setPreviewBrightness,
                          valueTrueIcon: LucideIcons.moonStar,
                          valueFalseIcon: LucideIcons.sun,
                        ),
                      ),
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
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      children: const [
                        _KeepAliveTab(child: BasicThemePanel()),
                        _KeepAliveTab(child: AdvancedThemePanel()),
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

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class IconSwitch extends StatelessWidget {
  const IconSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.valueTrueIcon,
    required this.valueFalseIcon,
  });

  final bool value;
  final void Function(bool)? onChanged;
  final IconData valueTrueIcon;
  final IconData valueFalseIcon;

  @override
  Widget build(BuildContext context) {
    var colorScheme2 = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
        ),
        Positioned(
          left: value ? 34 : 14,
          child: IgnorePointer(
            child: Icon(
              value ? valueTrueIcon : valueFalseIcon,
              color: value ? colorScheme2.onSurface : colorScheme2.surface,
              size: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
