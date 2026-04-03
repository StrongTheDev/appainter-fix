enum FontRole { display, body }

enum TextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

extension TextVariantX on TextVariant {
  String get label => switch (this) {
        TextVariant.displayLarge => 'Display Large',
        TextVariant.displayMedium => 'Display Medium',
        TextVariant.displaySmall => 'Display Small',
        TextVariant.headlineLarge => 'Headline Large',
        TextVariant.headlineMedium => 'Headline Medium',
        TextVariant.headlineSmall => 'Headline Small',
        TextVariant.titleLarge => 'Title Large',
        TextVariant.titleMedium => 'Title Medium',
        TextVariant.titleSmall => 'Title Small',
        TextVariant.bodyLarge => 'Body Large',
        TextVariant.bodyMedium => 'Body Medium',
        TextVariant.bodySmall => 'Body Small',
        TextVariant.labelLarge => 'Label Large',
        TextVariant.labelMedium => 'Label Medium',
        TextVariant.labelSmall => 'Label Small',
      };

  FontRole get role => switch (this) {
        TextVariant.displayLarge ||
        TextVariant.displayMedium ||
        TextVariant.displaySmall ||
        TextVariant.headlineLarge ||
        TextVariant.headlineMedium ||
        TextVariant.headlineSmall ||
        TextVariant.titleLarge ||
        TextVariant.titleMedium ||
        TextVariant.titleSmall =>
          FontRole.display,
        TextVariant.bodyLarge ||
        TextVariant.bodyMedium ||
        TextVariant.bodySmall ||
        TextVariant.labelLarge ||
        TextVariant.labelMedium ||
        TextVariant.labelSmall =>
          FontRole.body,
      };
}
