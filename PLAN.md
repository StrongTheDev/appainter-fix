# Provider Rewrite v2: Preview-First Theme Editor, Typography Controls, and Fresh Tests

## Summary

Implement the next revision of the rewritten provider app as a preview-first theme editor.

Core product rules for this pass:
- the outer editor shell has its own theme
- user theme edits affect only the device preview
- preview brightness is editable and preserved across toggles
- the editor shell can either follow preview light/dark or stay separate via a new toggle
- basic page gets real color picking plus two typography roles
- advanced page becomes the detailed editor for the surfaces visible in the preview
- new tests are created under `test/` for the provider architecture only

Also fold in the reported text-style interpolation crash by making the shell theme non-animated/stable and by normalizing generated text themes so we never lerp incompatible `TextStyle.inherit` states.

## Implementation Changes

### 1. Theme model split and controller redesign

Refactor the provider/controller so it manages two distinct themes:

- `editorThemeData`
  - the app shell theme used by the outer `MaterialApp`
- `previewThemeData`
  - the user-edited theme rendered inside the device preview

Controller state should include:
- `ThemeMode appThemeMode`
- `Brightness previewBrightness`
- `bool keepEditorBrightnessSeparate`
- `EditorMode editorMode`
- role-level font selections:
  - `String? displayFontFamily`
  - `String? bodyFontFamily`
- per-style overrides for advanced editing:
  - displayLarge/displayMedium/displaySmall
  - headlineLarge/headlineMedium/headlineSmall
  - titleLarge/titleMedium/titleSmall
  - bodyLarge/bodyMedium/bodySmall
  - labelLarge/labelMedium/labelSmall

Resolution rules:
- preview text styles resolve from:
  - explicit per-style override if present
  - else role-level font
  - else normalized base Material text theme
- display/headline/title inherit from the display role
- body/label inherit from the body role
- app import/export operates on `previewThemeData`, not the shell theme

The controller should expose:
- computed `ThemeData get editorTheme`
- computed `ThemeData get previewTheme`
- preview-only mutators for colors, typography, app bar, buttons, inputs, tabs, FAB, bottom nav
- `setPreviewBrightness(bool isDark)`
- `setKeepEditorBrightnessSeparate(bool value)`

### 2. Crash fix: TextStyle interpolation and theme stability

Fix the reported `Failed to interpolate TextStyles with different inherit values` issue as part of the redesign.

Implementation rules:
- the outer `MaterialApp` should stop relying on animated interpolation between incompatible generated themes
- use a stable shell theme and disable shell theme animation by setting:
  - `themeAnimationDuration: Duration.zero`
- generate preview/editor text themes from a normalized Material base so all produced styles use compatible structure before any Google Font application
- when applying Google Fonts, use a “base style in, normalized style out” approach rather than replacing with unrelated raw font styles
- do not lerp between `ThemeData()` defaults and ad hoc Google Fonts outputs directly
- brightness changes should rebuild the preview theme from the same normalized text-theme pipeline so the `inherit` contract remains consistent

This bugfix is required before adding font pickers.

### 3. Editor shell behavior

The outer app should use its own branded shell theme.

Behavior:
- default startup: shell follows preview light/dark only
- when `keep editor brightness separate` is enabled, shell stays on a fixed editor brightness/theme and no longer tracks preview brightness
- color edits never recolor the shell
- typography edits never re-font the shell
- only preview brightness may optionally influence shell brightness when the toggle is off

Add a visible toggle in the UI:
- label: `Keep editor brightness separate`
- default: `false`

### 4. Basic page redesign

Turn the basic page into the main “quick editing” surface.

Color editing:
- replace the placeholder cycling behavior with real color selection using `flex_color_picker`
- each picker updates only `previewThemeData`
- keep a focused basic set:
  - seed
  - primary
  - onPrimary
  - secondary
  - surface
  - error
  - outline
  - inversePrimary

Brightness:
- keep a preview brightness control on the basic page or nearby config area
- toggling brightness preserves all edited preview colors instead of regenerating defaults

Typography:
- add two Google Fonts selectors:
  - `Display, headings & titles`
  - `Body & labels`
- these write the role-level font selections in the controller

Presentation:
- section headers should become clearly distinguishable from row labels
- use stronger title styling and grouped surfaces/dividers
- avoid the current flat list look

### 5. Advanced page implementation

Rebuild advanced page as the detailed editor for preview-facing sections only.

Include sections for:
- app bar
- buttons
- text inputs
- tabs
- FAB
- bottom navigation
- typography

Typography on advanced:
- expose per-style Google Font selectors
- initialize effective values from the two basic font roles
- do not eagerly copy inherited values into overrides
- only persist an override after the user edits that specific style
- provide clear/reset action per style to return to inherited role font

Keep advanced grouped by preview surface, not by old cubit domains.

### 6. Preview panel and controls

Keep `DevicePreview`, but treat it as the canvas for the edited theme.

Rules:
- `ThemePreviewPanel` must use only `previewTheme`
- all preview controls should work without changing the outer shell theme

Preview controls:
- add a local preview toolbar/wrapper instead of modifying `DevicePreview` internals unless extension is trivial
- include:
  - preview brightness control
  - `keep editor brightness separate` toggle
  - quick font access entry point
  - any existing device/orientation controls that fit naturally

Typography preview:
- update text samples so users can actually see:
  - display
  - headline
  - title
  - body
  - label
- include both role-font inheritance and per-style override results visibly

### 7. Icons and dependency cleanup

Replace `material_design_icons_flutter` with `lucide_flutter`.

Update toolbar and editor actions to Lucide equivalents.

Clean up `pubspec.yaml` conservatively after the feature pass:
- remove clearly unused packages that are no longer imported by the rewritten app
- keep packages needed for this pass and the new tests

Likely removals if still unused after implementation:
- `collection`
- `cupertino_icons`
- `dropdown_search`
- `enum_to_string`
- `expandable`
- `intl`
- `ndialog`
- `path_provider`

Keep for this pass:
- `device_preview_plus`
- `file_picker`
- `flex_color_picker`
- `flutter_markdown` if usage/help remains markdown-rendered
- `google_fonts`
- `json_theme`
- `pretty_json`
- `provider`
- `random_color_scheme`
- `shared_preferences`
- `universal_html`
- `universal_io`
- `window_manager`

### 8. Usage/help markdown

Rewrite `ThemeUsage.defaultMarkdown` in the new model file under `lib/models/theme_usage.dart`.

The content should explain how to use the exported `.json` file in another Flutter app:
- what the file contains
- how to add `json_theme`
- how to load the JSON string or asset
- how to decode to `ThemeData`
- how to pass it to `MaterialApp(theme: ...)`
- mention that any custom fonts used by the exported theme must also be available in the consuming app

Do not describe the rewrite or app architecture there.

## Public API / Interface Changes

Add or reshape controller APIs around these behaviors:

- theme getters
  - `ThemeData get editorTheme`
  - `ThemeData get previewTheme`

- shell/preview behavior
  - `setPreviewBrightness(bool isDark)`
  - `setKeepEditorBrightnessSeparate(bool value)`

- basic font roles
  - `setDisplayFontFamily(String? family)`
  - `setBodyFontFamily(String? family)`

- advanced per-style font overrides
  - `setTextStyleFont(TextVariant variant, String? family)`
  - `clearTextStyleFont(TextVariant variant)`

- preview-facing theme mutators
  - all color/theme section updates target `previewThemeData`

- optional helper interfaces
  - a normalized text-theme builder service for generating safe text themes from base Material typography plus Google Fonts
  - a font catalog/provider for the font menus

Also add stable widget keys for:
- color pickers
- preview brightness control
- editor brightness separation toggle
- basic font selectors
- advanced per-style font selectors
- preview toolbar/menu controls

## Test Plan

Create a new `test/` folder with provider-first coverage modeled after `testo/` structure, but not copied one-to-one.

Add:
- `test/helpers/pump_app.dart`
  - wraps widgets in `ChangeNotifierProvider<AppProvider>`
  - uses lightweight fake/mock repository dependencies
- controller tests
  - preview brightness preserves edited colors
  - color edits affect preview theme only
  - shell brightness follows preview only when separation is off
  - shell remains independent when separation is on
  - role-level fonts update effective text theme
  - per-style overrides beat role fonts
  - clearing override restores inheritance
  - import/export uses preview theme
  - normalized text theme generation avoids incompatible inherit states

- widget tests
  - app boots and shows editor shell + preview
  - basic color picking updates preview samples
  - brightness toggle keeps chosen colors
  - section headers are rendered as distinct grouped headings
  - advanced page renders preview-facing sections
  - basic font selectors affect preview typography
  - advanced per-style selectors override inherited fonts
  - help dialog shows `.json` usage instructions
  - Lucide toolbar icons render
  - preview toolbar controls work

Testing philosophy:
- prefer controller tests for theme logic and inheritance
- use widget tests for visible user flows
- do not recreate the old cubit suite breadth yet

## Assumptions and Defaults

- advanced scope is limited to the surfaces currently visible in preview
- basic page owns the two high-level font roles
- advanced page owns per-style overrides
- per-style overrides are lazy and nullable, inheriting until edited
- all theme edits affect preview only
- shell theme animation is intentionally disabled to eliminate the current text-style interpolation crash
- `DevicePreview` package internals will not be patched unless extension is trivial; local wrapper controls are the default approach
- `lucide_flutter` is the default Lucide package
- usage markdown is end-user export guidance only
