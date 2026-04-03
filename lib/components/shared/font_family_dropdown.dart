import 'package:flutter/material.dart';

class FontFamilyDropdown extends StatelessWidget {
  const FontFamilyDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.dropdownKey,
    this.hintText,
    super.key,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final Key? dropdownKey;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      key: dropdownKey,
      value: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: hintText,
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Default'),
        ),
        ...options.map(
          (family) => DropdownMenuItem<String?>(
            value: family,
            child: Text(family),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
