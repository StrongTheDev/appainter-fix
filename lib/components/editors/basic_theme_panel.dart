import 'package:appainter/components/editors/section_header.dart';
import 'package:appainter/components/shared/color_picker_tile.dart';
import 'package:appainter/models/color_field_table.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicThemePanel extends StatelessWidget {
  const BasicThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Theme Colors',
            subtitle:
                'Edit the preview palette from one place using field names that match the theme.',
          ),
          const SizedBox(height: 16),
          ...colorTableSections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ColorTableSection(section: section, app: app),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorTableSection extends StatelessWidget {
  const _ColorTableSection({
    required this.section,
    required this.app,
  });

  final ColorTableSection section;
  final AppProvider app;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: const IntrinsicColumnWidth(),
                  for (var i = 1; i <= section.columns.length; i++)
                    i: const FixedColumnWidth(112),
                },
                children: [
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      ...section.columns.map(
                        (column) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          child: Text(
                            column,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...section.rows.map(
                    (row) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12, top: 14),
                          child: Text(
                            row.label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        ...row.fields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.all(6),
                            child: field == null
                                ? const SizedBox.shrink()
                                : Tooltip(
                                    message: _labelForField(field),
                                    waitDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    child: ColorPickerTile(
                                      label: '',
                                      color: app.colorForField(field),
                                      colorKey: Key('color_table_$field'),
                                      onColorChanged: (color) =>
                                          app.setColor(field, color),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForField(String field) {
    return switch (field) {
      'seed' => 'Seed',
      'inversePrimary' => 'Inverse primary',
      'surfaceTint' => 'Surface tint',
      'surfaceContainerHighest' => 'Surface container highest',
      'onSurfaceVariant' => 'On surface variant',
      'onInverseSurface' => 'On inverse surface',
      'outlineVariant' => 'Outline variant',
      _ => field,
    };
  }
}
