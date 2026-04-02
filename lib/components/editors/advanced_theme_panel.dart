import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedThemePanel extends StatelessWidget {
  const AdvancedThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = app.theme;

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Advanced theme', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'This rewrite keeps advanced editing lightweight for now. '
            'The app is now self-contained under lib, and we can keep rebuilding '
            'advanced sections here without depending on the old bloc files.',
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use Material 3'),
            value: theme.useMaterial3,
            onChanged: app.setUseMaterial3,
          ),
          ListTile(
            title: const Text('App bar background'),
            subtitle: Text(theme.appBarTheme.backgroundColor?.toString() ?? 'default'),
            trailing: FilledButton(
              onPressed: () => app.appBarBackgroundColorChanged(
                theme.appBarTheme.backgroundColor == Colors.teal
                    ? Colors.deepOrange
                    : Colors.teal,
              ),
              child: const Text('Toggle'),
            ),
          ),
          ListTile(
            title: const Text('Primary swatch'),
            subtitle: Text(theme.colorScheme.primary.toString()),
            trailing: FilledButton(
              onPressed: () => app.primaryColorChanged(
                theme.colorScheme.primary == Colors.blue ? Colors.green : Colors.blue,
              ),
              child: const Text('Toggle'),
            ),
          ),
        ],
      ),
    );
  }
}
