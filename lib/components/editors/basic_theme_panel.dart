import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicThemePanel extends StatelessWidget {
  const BasicThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final scheme = app.colorScheme;

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ColorTile(
            label: 'Seed color',
            color: scheme.primary,
            onTap: () => app.seedColorChanged(_nextColor(scheme.primary)),
          ),
          const Divider(),
          _Section(
            title: 'Primary',
            children: [
              _ColorTile(
                label: 'Primary',
                color: scheme.primary,
                onTap: () => app.primaryColorChanged(_nextColor(scheme.primary)),
              ),
              _ColorTile(
                label: 'On primary',
                color: scheme.onPrimary,
                onTap: () => app.onPrimaryColorChanged(_nextColor(scheme.onPrimary)),
              ),
            ],
          ),
          _Section(
            title: 'Secondary',
            children: [
              _ColorTile(
                label: 'Secondary',
                color: scheme.secondary,
                onTap: () => app.secondaryColorChanged(_nextColor(scheme.secondary)),
              ),
              _ColorTile(
                label: 'Surface',
                color: scheme.surface,
                onTap: () => app.surfaceColorChanged(_nextColor(scheme.surface)),
              ),
            ],
          ),
          _Section(
            title: 'Utility',
            children: [
              _ColorTile(
                label: 'Error',
                color: scheme.error,
                onTap: () => app.errorColorChanged(_nextColor(scheme.error)),
              ),
              _ColorTile(
                label: 'Outline',
                color: scheme.outline,
                onTap: () => app.outlineColorChanged(_nextColor(scheme.outline)),
              ),
              _ColorTile(
                label: 'Inverse primary',
                color: scheme.inversePrimary,
                onTap: () => app.inversePrimaryColorChanged(_nextColor(scheme.inversePrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _nextColor(Color color) {
    return Color.lerp(color, Colors.primaries[color.value % Colors.primaries.length], 0.35) ??
        color;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
        ),
      ),
    );
  }
}
