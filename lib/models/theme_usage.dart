class ThemeUsage {
  const ThemeUsage([this.markdownData]);

  final String? markdownData;

  static const markdownUrl =
      'https://github.com/zeshuaro/appainter/blob/main/USAGE.md';
  static const defaultMarkdown = '''
# Using the exported theme JSON

The exported `.json` file is a serialized Flutter `ThemeData` definition.
You can load it in another Flutter app with the `json_theme` package.

## 1. Add the package

```yaml
dependencies:
  json_theme: ^9.0.3
```

## 2. Add or load the exported file

You can bundle the JSON as an asset, download it, or read it from local
storage. If you keep it as an asset, add it to `pubspec.yaml`.

## 3. Decode it into ThemeData

```dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';

final raw = await rootBundle.loadString('assets/appainter_theme.json');
final data = jsonDecode(raw);
final theme = ThemeDecoder.decodeThemeData(data)!;
```

## 4. Pass it to MaterialApp

```dart
MaterialApp(
  theme: theme,
  home: const MyHomePage(),
);
```

## Notes

- If your exported theme uses Google Fonts or any custom font family, the
  consuming app must also make those fonts available.
- You can keep separate JSON files for light and dark themes if your app needs
  both.
''';
}
