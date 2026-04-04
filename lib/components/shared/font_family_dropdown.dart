import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return InkWell(
      key: dropdownKey,
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showFontPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: hintText,
          suffixIcon: const Icon(Icons.search_rounded),
        ),
        child: Text(
          value ?? 'Default',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _showFontPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _FontSearchSheet(
        label: label,
        value: value,
        options: options,
      ),
    );

    if (context.mounted && selected != null) {
      onChanged(selected.isEmpty ? null : selected);
    }
    if (context.mounted && selected == '') {
      onChanged(null);
    }
  }
}

class _FontSearchSheet extends StatefulWidget {
  const _FontSearchSheet({
    required this.label,
    required this.value,
    required this.options,
  });

  final String label;
  final String? value;
  final List<String> options;

  @override
  State<_FontSearchSheet> createState() => _FontSearchSheetState();
}

class _FontSearchSheetState extends State<_FontSearchSheet> {
  late final TextEditingController _controller;
  late List<String> _filtered;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _filtered = widget.options;
    _controller.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final query = _controller.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.options
          : widget.options
              .where((family) => family.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search Google Fonts',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Default'),
                trailing: widget.value == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(''),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(child: Text('No fonts matched your search.'))
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final family = _filtered[index];
                          final selected = family == widget.value;
                          return ListTile(
                            dense: true,
                            title: Text(
                              family,
                              style: GoogleFonts.getFont(
                                family,
                                textStyle: Theme.of(context).textTheme.titleMedium,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'The quick brown fox jumps over the lazy dog',
                              style: GoogleFonts.getFont(
                                family,
                                textStyle: Theme.of(context).textTheme.bodySmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: selected ? const Icon(Icons.check) : null,
                            onTap: () => Navigator.of(context).pop(family),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
