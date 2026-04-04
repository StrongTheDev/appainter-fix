import 'package:appainter/providers/app_provider.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePreviewPanel extends StatelessWidget {
  const ThemePreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DevicePreview(
                  enabled: true,
                  builder: (context) {
                    return MaterialApp(
                      key: ValueKey(app.isDark),
                      debugShowCheckedModeBanner: false,
                      themeAnimationDuration: Durations.short2,
                      theme: app.previewThemeData,
                      locale: DevicePreview.locale(context),
                      home: const _PreviewScaffold(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewScaffold extends StatefulWidget {
  const _PreviewScaffold();

  @override
  State<_PreviewScaffold> createState() => _PreviewScaffoldState();
}

class _PreviewScaffoldState extends State<_PreviewScaffold> {
  int _currentIndex = 0;
  bool _switchValue = true;
  bool _checkboxValue = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buttons'),
              Tab(text: 'Inputs'),
              Tab(text: 'Text'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: const [
              DrawerHeader(child: Text('Navigation')),
              ListTile(title: Text('Messages')),
              ListTile(title: Text('Profile')),
              ListTile(title: Text('Settings')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ButtonsTab(
              switchValue: _switchValue,
              checkboxValue: _checkboxValue,
              onSwitchChanged: (value) => setState(() => _switchValue = value),
              onCheckboxChanged: (value) =>
                  setState(() => _checkboxValue = value ?? false),
            ),
            const _InputsTab(),
            const _TextTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (value) => setState(() => _currentIndex = value),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'School'),
          ],
        ),
      ),
    );
  }
}

class _ButtonsTab extends StatelessWidget {
  const _ButtonsTab({
    required this.switchValue,
    required this.checkboxValue,
    required this.onSwitchChanged,
    required this.onCheckboxChanged,
  });

  final bool switchValue;
  final bool checkboxValue;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<bool?> onCheckboxChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            FilledButton(onPressed: () {}, child: const Text('Filled')),
            OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
            TextButton(onPressed: () {}, child: const Text('Text')),
          ],
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: switchValue,
          onChanged: onSwitchChanged,
          title: const Text('Switch'),
        ),
        CheckboxListTile(
          value: checkboxValue,
          onChanged: onCheckboxChanged,
          title: const Text('Checkbox'),
        ),
        RadioListTile<int>(
          value: 1,
          groupValue: 1,
          onChanged: (_) {},
          title: const Text('Radio'),
        ),
        const SizedBox(height: 24),
        Slider(value: 0.5, onChanged: (_) {}),
      ],
    );
  }
}

class _InputsTab extends StatelessWidget {
  const _InputsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'name@example.com',
          ),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
        ),
      ],
    );
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Display Large', style: text.displayLarge),
        const SizedBox(height: 12),
        Text('Headline Medium', style: text.headlineMedium),
        const SizedBox(height: 12),
        Text('Title Large', style: text.titleLarge),
        const SizedBox(height: 12),
        Text('Label Large', style: text.labelLarge),
        const SizedBox(height: 12),
        Text(
          'Body Medium: a quick preview paragraph showing the current text theme.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Caption-style label for metadata or helper copy.',
          style: text.labelMedium,
        ),
      ],
    );
  }
}
