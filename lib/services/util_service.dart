import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UtilService {
  static MaterialColor getColorSwatch(Color color) {
    return MaterialColor(color.toARGB32(), <int, Color>{
      50: _tint(color, 0.9),
      100: _tint(color, 0.8),
      200: _tint(color, 0.6),
      300: _tint(color, 0.4),
      400: _tint(color, 0.2),
      500: color,
      600: _shade(color, 0.1),
      700: _shade(color, 0.2),
      800: _shade(color, 0.3),
      900: _shade(color, 0.4),
    });
  }

  static Color _tint(Color color, double factor) {
    return Color.lerp(color, Colors.white, factor) ?? color;
  }

  static Color _shade(Color color, double factor) {
    return Color.lerp(color, Colors.black, factor) ?? color;
  }

  static Future<void> launchUrl(String href) async {
    await Clipboard.setData(ClipboardData(text: href));
    debugPrint('Copied URL to clipboard: $href');
  }
}
