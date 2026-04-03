import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerTile extends StatelessWidget {
  const ColorPickerTile({
    required this.label,
    required this.color,
    required this.onColorChanged,
    this.description,
    this.colorKey,
    super.key,
  });

  final String label;
  final String? description;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final Key? colorKey;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: description == null ? null : Text(description!),
      trailing: InkWell(
        key: colorKey,
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showColorDialog(context),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorDialog(BuildContext context) async {
    Color nextColor = color;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(label),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: nextColor,
              enableOpacity: false,
              borderRadius: 18,
              spacing: 8,
              runSpacing: 8,
              pickersEnabled: const {
                ColorPickerType.wheel: true,
                ColorPickerType.primary: true,
                ColorPickerType.accent: false,
                ColorPickerType.bw: false,
                ColorPickerType.both: false,
                ColorPickerType.custom: false,
              },
              onColorChanged: (value) => nextColor = value,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                onColorChanged(nextColor);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
