class ColorTableSection {
  const ColorTableSection({
    required this.title,
    required this.columns,
    required this.rows,
  });

  final String title;
  final List<String> columns;
  final List<ColorTableRow> rows;
}

class ColorTableRow {
  const ColorTableRow({
    required this.label,
    required this.fields,
  });

  final String label;
  final List<String?> fields;
}

const colorTableSections = <ColorTableSection>[
  ColorTableSection(
    title: 'Accent Families',
    columns: ['Primary', 'Secondary', 'Tertiary', 'Error'],
    rows: [
      ColorTableRow(
        label: 'Base',
        fields: ['primary', 'secondary', 'tertiary', 'error'],
      ),
      ColorTableRow(
        label: 'On Base',
        fields: ['onPrimary', 'onSecondary', 'onTertiary', 'onError'],
      ),
      ColorTableRow(
        label: 'Container',
        fields: [
          'primaryContainer',
          'secondaryContainer',
          'tertiaryContainer',
          'errorContainer',
        ],
      ),
      ColorTableRow(
        label: 'On Container',
        fields: [
          'onPrimaryContainer',
          'onSecondaryContainer',
          'onTertiaryContainer',
          'onErrorContainer',
        ],
      ),
    ],
  ),
  ColorTableSection(
    title: 'Surface System',
    columns: ['Surface', 'Strong Surface', 'Inverse', 'Outline'],
    rows: [
      ColorTableRow(
        label: 'Base',
        fields: [
          'surface',
          'surfaceContainerHighest',
          'inverseSurface',
          'outline',
        ],
      ),
      ColorTableRow(
        label: 'On Base',
        fields: [
          'onSurface',
          'onSurfaceVariant',
          'onInverseSurface',
          'outlineVariant',
        ],
      ),
    ],
  ),
  ColorTableSection(
    title: 'Global Keys',
    columns: ['Seed', 'Inverse Primary', 'Surface Tint', 'Scrim'],
    rows: [
      ColorTableRow(
        label: 'Color',
        fields: ['seed', 'inversePrimary', 'surfaceTint', 'scrim'],
      ),
    ],
  ),
];
