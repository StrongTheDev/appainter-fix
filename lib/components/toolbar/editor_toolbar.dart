import 'package:appainter/models/theme_usage.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:appainter/services/util_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  const EditorToolbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : Colors.grey;

    return AppBar(
      backgroundColor: isDark ? Colors.black : Colors.white,
      title: Row(
        children: [
          const Icon(Icons.palette_outlined, size: 32),
          const SizedBox(width: 12),
          Text('Appainter', style: TextStyle(color: foreground)),
        ],
      ),
      actionsIconTheme: IconThemeData(color: foreground),
      actions: [
        IconButton(
          onPressed: () => context.read<AppProvider>().importTheme(),
          icon: Icon(MdiIcons.applicationImport, color: foreground),
        ),
        TextButton.icon(
          onPressed: () => context.read<AppProvider>().exportTheme(),
          icon: Icon(MdiIcons.applicationExport, color: foreground),
          label: Text('Export', style: TextStyle(color: foreground)),
        ),
        IconButton(
          icon: Icon(
            _isDarkThemeMode(context) ? MdiIcons.weatherNight : MdiIcons.weatherSunny,
            color: foreground,
          ),
          onPressed: () =>
              context.read<AppProvider>().setThemeMode(!_isDarkThemeMode(context)),
        ),
        IconButton(
          icon: Icon(MdiIcons.helpCircleOutline, color: foreground),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const _UsageDialog(),
          ),
        ),
      ],
    );
  }

  bool _isDarkThemeMode(BuildContext context) {
    final mode = context.read<AppProvider>().themeMode;
    if (mode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }
}

class _UsageDialog extends StatelessWidget {
  const _UsageDialog();

  @override
  Widget build(BuildContext context) {
    final usage = context.watch<AppProvider>().themeUsage;
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Text('Usage'),
      content: SizedBox(
        width: size.width * 0.6,
        height: size.height * 0.6,
        child: usage != null
            ? _UsageContent(usage: usage)
            : const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _UsageContent extends StatelessWidget {
  const _UsageContent({required this.usage});

  final ThemeUsage usage;

  @override
  Widget build(BuildContext context) {
    return usage.markdownData != null
        ? Markdown(
            selectable: true,
            data: usage.markdownData!,
            onTapLink: (text, href, title) {
              if (href != null) UtilService.launchUrl(href);
            },
          )
        : RichText(
            text: TextSpan(
              text: 'Failed to fetch usage details. Please visit ',
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: 'this',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => UtilService.launchUrl(ThemeUsage.markdownUrl),
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' page instead.'),
              ],
            ),
          );
  }
}
