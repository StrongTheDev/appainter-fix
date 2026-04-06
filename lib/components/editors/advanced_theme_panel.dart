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
    final families = app.availableFontFamilies;

    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Typography',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the two broad font roles first, then fine-tune individual text styles.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _AdvancedSection(
            title: 'Font Roles',
            child: Column(
              children: [
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
          ),
          _AdvancedSection(
            title: 'Fine Tune Styles',
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
                            dropdownKey: Key('advanced_font_${variant.name}'),
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
