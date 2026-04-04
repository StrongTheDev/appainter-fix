import 'package:google_fonts/google_fonts.dart';

class FontCatalogService {
  late final List<String> _families = () {
    final families = GoogleFonts.asMap().keys.map<String>((key) => '$key').toList()
      ..sort();
    return List<String>.unmodifiable(families);
  }();

  List<String> get families => _families;
}
