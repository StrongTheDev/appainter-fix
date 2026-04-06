import 'package:appainter/components/shared/font_family_dropdown.dart';
import 'package:appainter/models/text_variant.dart';
import 'package:appainter/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedThemePanel extends StatelessWidget {
  const AdvancedThemePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TypographyIntro(),
          SizedBox(height: 16),
          _AdvancedSection(
            title: 'Font Roles',
            child: _FontRolesSection(),
          ),
          _AdvancedSection(
            title: 'Fine Tune Styles',
            child: _TypographyVariantList(),
          ),
        ],
      ),
    );
  }
}

class _TypographyIntro extends StatelessWidget {
  const _TypographyIntro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the two broad font roles first, then fine-tune individual text styles.',
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _FontRolesSection extends StatelessWidget {
  const _FontRolesSection();

  @override
  Widget build(BuildContext context) {
    final families = context.read<AppProvider>().availableFontFamilies;
    return Column(
      children: [
        Selector<AppProvider, String?>(
          selector: (_, app) => app.displayFontFamily,
          builder: (context, displayFontFamily, _) {
            return FontFamilyDropdown(
              label: 'Display, headings & titles',
              value: displayFontFamily,
              options: families,
              dropdownKey: const Key('basic_display_font_dropdown'),
              onChanged: context.read<AppProvider>().setDisplayFontFamily,
            );
          },
        ),
        const SizedBox(height: 12),
        Selector<AppProvider, String?>(
          selector: (_, app) => app.bodyFontFamily,
          builder: (context, bodyFontFamily, _) {
            return FontFamilyDropdown(
              label: 'Body & labels',
              value: bodyFontFamily,
              options: families,
              dropdownKey: const Key('basic_body_font_dropdown'),
              onChanged: context.read<AppProvider>().setBodyFontFamily,
            );
          },
        ),
      ],
    );
  }
}

class _TypographyVariantList extends StatelessWidget {
  const _TypographyVariantList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TextVariant.values.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TypographyVariantRow(variant: TextVariant.values[index]);
      },
    );
  }
}

class _TypographyVariantRow extends StatelessWidget {
  const _TypographyVariantRow({required this.variant});

  final TextVariant variant;

  @override
  Widget build(BuildContext context) {
    final families = context.read<AppProvider>().availableFontFamilies;

    return Selector<AppProvider, _TypographyRowState>(
      selector: (_, app) => _TypographyRowState(
        value: app.fontForVariant(variant),
        hasOverride: app.hasTextStyleOverride(variant),
        fallbackLabel: variant.role == FontRole.display
            ? app.displayFontFamily ?? 'Default display font'
            : app.bodyFontFamily ?? 'Default body font',
      ),
      builder: (context, rowState, _) {
        final app = context.read<AppProvider>();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FontFamilyDropdown(
                label: variant.label,
                value: rowState.value,
                options: families,
                dropdownKey: Key('advanced_font_${variant.name}'),
                hintText: 'Falls back to ${rowState.fallbackLabel}',
                onChanged: (value) => app.setTextStyleFont(variant, value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: Key('advanced_font_reset_${variant.name}'),
              tooltip: 'Reset ${variant.label}',
              onPressed: rowState.hasOverride
                  ? () => app.clearTextStyleFont(variant)
                  : null,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        );
      },
    );
  }
}

class _TypographyRowState {
  const _TypographyRowState({
    required this.value,
    required this.hasOverride,
    required this.fallbackLabel,
  });

  final String? value;
  final bool hasOverride;
  final String fallbackLabel;

  @override
  bool operator ==(Object other) {
    return other is _TypographyRowState &&
        other.value == value &&
        other.hasOverride == hasOverride &&
        other.fallbackLabel == fallbackLabel;
  }

  @override
  int get hashCode => Object.hash(value, hasOverride, fallbackLabel);
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
