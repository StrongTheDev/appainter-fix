import 'dart:convert';

import 'package:appainter/models/theme_usage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_theme/json_theme.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

class HomeRepository {
  HomeRepository({FilePicker? filePicker})
      : _filePicker = filePicker ?? FilePicker.platform;

  final FilePicker _filePicker;

  static const _exportFileName = 'your_app_theme.json';
  static const _isPreviewDarkThemeKey = 'isPreviewDarkTheme';
  static const _isEditorDarkThemeKey = 'isEditorDarkTheme';

  Future<ThemeUsage> fetchThemeUsage() async {
    return const ThemeUsage(ThemeUsage.defaultMarkdown);
  }

  Future<ThemeData?> importTheme() async {
    final result = await _filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return null;

    final file = result.files.single;
    late final String text;
    if (file.bytes != null) {
      text = String.fromCharCodes(file.bytes!);
    } else {
      text = await io.File(file.path!).readAsString();
    }

    final json = jsonDecode(text);
    return ThemeDecoder.decodeThemeData(json, validate: false);
  }

  Future<bool> exportTheme(ThemeData theme) async {
    final encoded = prettyJson(ThemeEncoder.encodeThemeData(theme));
    final bytes = Uint8List.fromList(encoded.codeUnits);

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = _exportFileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      return true;
    }

    final path = await _filePicker.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: _exportFileName,
    );
    if (path == null) return false;
    await io.File(path).writeAsBytes(bytes);
    return true;
  }

  Future<bool?> getPreviewDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPreviewDarkThemeKey);
  }

  Future<bool?> getEditorDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isEditorDarkThemeKey);
  }

  Future<void> setPreviewDarkTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPreviewDarkThemeKey, isDark);
  }

  Future<void> setEditorDarkTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isEditorDarkThemeKey, isDark);
  }
}
