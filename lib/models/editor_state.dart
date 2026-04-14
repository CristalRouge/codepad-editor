import 'package:flutter/foundation.dart';

class EditorState extends ChangeNotifier {
  String _content = '';
  String _filePath = '';
  String _fileName = 'untitled.txt';
  bool _isModified = false;
  bool _wordWrap = true;
  double _fontSize = 14.0;
  bool _isReadOnly = false;
  bool _isMarkdownPreview = false;

  // ── Getters ──────────────────────────────────────────────
  String get content => _content;
  String get filePath => _filePath;
  String get fileName => _fileName;
  bool get isModified => _isModified;
  bool get wordWrap => _wordWrap;
  double get fontSize => _fontSize;
  bool get isReadOnly => _isReadOnly;
  bool get isMarkdownPreview => _isMarkdownPreview;

  int get lineCount => _content.isEmpty ? 1 : '\n'.allMatches(_content).length + 1;
  int get charCount => _content.length;

  // ── Actions ──────────────────────────────────────────────
  void openFile(String path, String name, String content) {
    _filePath = path;
    _fileName = name;
    _content = content;
    _isModified = false;
    _isMarkdownPreview = false;
    notifyListeners();
  }

  void newFile() {
    _filePath = '';
    _fileName = 'untitled.txt';
    _content = '';
    _isModified = false;
    _isMarkdownPreview = false;
    notifyListeners();
  }

  void updateContent(String content) {
    _content = content;
    _isModified = true;
    notifyListeners();
  }

  void markSaved(String path, String name) {
    _filePath = path;
    _fileName = name;
    _isModified = false;
    notifyListeners();
  }

  void toggleWordWrap() {
    _wordWrap = !_wordWrap;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(8.0, 48.0);
    notifyListeners();
  }

  void toggleReadOnly() {
    _isReadOnly = !_isReadOnly;
    notifyListeners();
  }

  void toggleMarkdownPreview() {
    _isMarkdownPreview = !_isMarkdownPreview;
    notifyListeners();
  }
}
