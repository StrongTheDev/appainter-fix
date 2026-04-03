import 'package:google_fonts/google_fonts.dart';

class FontCatalogService {
  List<String> get families {
    final families = GoogleFonts.asMap().keys.toList()..sort();
    return families;
  }
}
