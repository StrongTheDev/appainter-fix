import 'package:appainter/components/shared/color_picker_tile.dart';
import 'package:appainter/components/shared/font_family_dropdown.dart';
import 'package:appainter/models/text_variant.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedThemePanel extends StatelessWidget {
  const AdvancedThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final theme = app.previewTheme;
    final families = app.availableFontFamilies;

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Advanced Controls',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Refine the preview surfaces one by one. These edits stay inside the device preview.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _AdvancedSection(
            title: 'App bar',
            child: ColorPickerTile(
              label: 'Background',
              color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
              colorKey: const Key('advanced_app_bar_background_picker'),
              onColorChanged: app.appBarBackgroundColorChanged,
            ),
          ),
          _AdvancedSection(
            title: 'Buttons',
            child: Column(
              children: [
                ColorPickerTile(
                  label: 'Filled button background',
                  color: theme.filledButtonTheme.style?.backgroundColor
                          ?.resolve(<WidgetState>{}) ??
                      theme.colorScheme.primary,
                  colorKey: const Key('advanced_filled_button_picker'),
                  onColorChanged: app.filledButtonBackgroundColorChanged,
                ),
                ColorPickerTile(
                  label: 'Outlined and text button color',
                  color: theme.outlinedButtonTheme.style?.foregroundColor
                          ?.resolve(<WidgetState>{}) ??
                      theme.colorScheme.primary,
                  colorKey: const Key('advanced_outlined_button_picker'),
                  onColorChanged: app.outlinedButtonColorChanged,
                ),
              ],
            ),
          ),
          _AdvancedSection(
            title: 'Inputs',
            child: ColorPickerTile(
              label: 'Field fill color',
              color: theme.inputDecorationTheme.fillColor ??
                  theme.colorScheme.surfaceContainerHighest,
              colorKey: const Key('advanced_input_fill_picker'),
              onColorChanged: app.inputFillColorChanged,
            ),
          ),
          _AdvancedSection(
            title: 'Tabs',
            child: ColorPickerTile(
              label: 'Indicator and label color',
              color: theme.tabBarTheme.indicatorColor ?? theme.colorScheme.primary,
              colorKey: const Key('advanced_tab_indicator_picker'),
              onColorChanged: app.tabIndicatorColorChanged,
            ),
          ),
          _AdvancedSection(
            title: 'Floating action button',
            child: ColorPickerTile(
              label: 'FAB background',
              color: theme.floatingActionButtonTheme.backgroundColor ??
                  theme.colorScheme.primaryContainer,
              colorKey: const Key('advanced_fab_picker'),
              onColorChanged: app.fabBackgroundColorChanged,
            ),
          ),
          _AdvancedSection(
            title: 'Bottom navigation',
            child: ColorPickerTile(
              label: 'Selected item color',
              color: theme.bottomNavigationBarTheme.selectedItemColor ??
                  theme.colorScheme.primary,
              colorKey: const Key('advanced_bottom_nav_picker'),
              onColorChanged: app.bottomNavigationColorChanged,
            ),
          ),
          _AdvancedSection(
            title: 'Typography',
            child: Column(
              children: [
                ...TextVariant.values.map(
                  (variant) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FontFamilyDropdown(
                            label: variant.label,
                            value: app.fontForVariant(variant),
                            options: families,
                            dropdownKey: Key(
                              'advanced_font_${variant.name}',
                            ),
                            hintText: variant.role == FontRole.display
                                ? 'Falls back to ${app.displayFontFamily ?? 'Default display font'}'
                                : 'Falls back to ${app.bodyFontFamily ?? 'Default body font'}',
                            onChanged: (value) => app.setTextStyleFont(
                              variant,
                              value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          key: Key('advanced_font_reset_${variant.name}'),
                          tooltip: 'Reset ${variant.label}',
                          onPressed: app.hasTextStyleOverride(variant)
                              ? () => app.clearTextStyleFont(variant)
                              : null,
                          icon: const Icon(Icons.restart_alt),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
