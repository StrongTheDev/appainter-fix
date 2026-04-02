class ThemeUsage {
  const ThemeUsage([this.markdownData]);

  final String? markdownData;

  static const markdownUrl =
      'https://github.com/zeshuaro/appainter/blob/main/USAGE.md';
  static const defaultMarkdown = '''
# Appainter

This lightweight rewrite focuses on editing and previewing a Material theme
with a simpler provider-based architecture.

## What you can do

- switch between basic and advanced editing
- preview the current theme in a live demo surface
- toggle brightness and Material 3
- randomize, reset, import, and export themes

## Why this rewrite

The previous cubit-heavy structure made the app harder to follow and harder to
contribute to. The current code keeps state in one controller and keeps UI
under straightforward pages and components.

## Export

Use the Export action in the toolbar to save the current theme as JSON.
''';
}
