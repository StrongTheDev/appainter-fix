import 'package:appainter/components/editors/section_header.dart';
import 'package:appainter/components/shared/color_picker_tile.dart';
import 'package:appainter/components/shared/font_family_dropdown.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicThemePanel extends StatelessWidget {
  const BasicThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final scheme = app.previewTheme.colorScheme;
    final families = app.availableFontFamilies;

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Quick Palette',
            subtitle:
                'Make fast color decisions for the preview without recoloring the editor shell.',
          ),
          ColorPickerTile(
            label: 'Seed color',
            description:
                'Regenerates the preview palette from a single starting hue.',
            color: scheme.primary,
            colorKey: const Key('basic_seed_color_picker'),
            onColorChanged: app.seedColorChanged,
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Primary Story',
            subtitle: 'Set the hero tones that drive your preview theme.',
          ),
          ColorPickerTile(
            label: 'Primary',
            color: scheme.primary,
            colorKey: const Key('basic_primary_color_picker'),
            onColorChanged: app.primaryColorChanged,
          ),
          ColorPickerTile(
            label: 'On primary',
            color: scheme.onPrimary,
            colorKey: const Key('basic_on_primary_color_picker'),
            onColorChanged: app.onPrimaryColorChanged,
          ),
          ColorPickerTile(
            label: 'Secondary',
            color: scheme.secondary,
            colorKey: const Key('basic_secondary_color_picker'),
            onColorChanged: app.secondaryColorChanged,
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Surfaces',
            subtitle:
                'Tune the foundations of cards, forms, and neutral backgrounds.',
          ),
          ColorPickerTile(
            label: 'Surface',
            color: scheme.surface,
            colorKey: const Key('basic_surface_color_picker'),
            onColorChanged: app.surfaceColorChanged,
          ),
          ColorPickerTile(
            label: 'Error',
            color: scheme.error,
            colorKey: const Key('basic_error_color_picker'),
            onColorChanged: app.errorColorChanged,
          ),
          ColorPickerTile(
            label: 'Outline',
            color: scheme.outline,
            colorKey: const Key('basic_outline_color_picker'),
            onColorChanged: app.outlineColorChanged,
          ),
          ColorPickerTile(
            label: 'Inverse primary',
            color: scheme.inversePrimary,
            colorKey: const Key('basic_inverse_primary_color_picker'),
            onColorChanged: app.inversePrimaryColorChanged,
          ),
          const SizedBox(height: 20),
          const SectionHeader(
            title: 'Typography Roles',
            subtitle:
                'Choose the main Google Fonts for display styles and for reading-heavy content.',
          ),
          const SizedBox(height: 12),
          FontFamilyDropdown(
            label: 'Display, headings & titles',
            value: app.displayFontFamily,
            options: families,
            dropdownKey: const Key('basic_display_font_dropdown'),
            onChanged: app.setDisplayFontFamily,
          ),
          const SizedBox(height: 12),
          FontFamilyDropdown(
            label: 'Body & labels',
            value: app.bodyFontFamily,
            options: families,
            dropdownKey: const Key('basic_body_font_dropdown'),
            onChanged: app.setBodyFontFamily,
          ),
        ],
      ),
    );
  }
}
