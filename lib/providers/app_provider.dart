import 'package:appainter/providers/theme_editor_controller.dart';
import 'package:appainter/repositories/home_repository.dart';

export 'package:appainter/providers/theme_editor_controller.dart';

class AppProvider extends ThemeEditorController {
  AppProvider({required HomeRepository homeRepo}) : super(homeRepo: homeRepo);
}
