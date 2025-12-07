// lib/screens/edit_document_screen_web_html_stub.dart
// Stub robusto para dart:html usado apenas em builds não-web.

import 'dart:async';

class _Style {
  String width = '';
  String minHeight = '';
  String height = '';
  String display = '';
  String flexDirection = '';
  String overflow = '';
  String padding = '';
  String backgroundColor = '';
  String boxShadow = '';
  String boxSizing = '';
  String margin = '';
  String flex = '';
  String justifyContent = '';
  String alignItems = '';
  String userSelect = '';
  String outline = ''; // ← ADICIONADO
  String border = '';
  String fontSize = '';
  String color = '';
  String fontStyle = '';
  String fontWeight = '';
  String textAlign = '';
  String borderCollapse = '';
  String borderLeft = '';
  String background = '';
  String marginTop = '';
  String cursor = '';
  String transition = '';
  String maxWidth = '';
  
  void setProperty(String name, String value) {}
}

class DivElement {
  String id = '';
  String contentEditable = 'false';
  bool spellcheck = false;
  String className = '';

  final _Style style = _Style();

  String _innerHtml = '';
  String get innerHtml => _innerHtml;
  set innerHtml(String v) => _innerHtml = v;

  final StreamController<dynamic> _onInputController = StreamController<dynamic>.broadcast();
  final StreamController<Event> _onClickController = StreamController<Event>.broadcast();

  Stream<dynamic> get onInput => _onInputController.stream;
  Stream<Event> get onClick => _onClickController.stream;

  void append(dynamic _) {}
  void remove() {}

  void setInnerHtml(String html, {dynamic treeSanitizer}) {
    _innerHtml = html;
  }

  List<ImageElement> querySelectorAll(String selector) => [];
}

class ImageElement extends DivElement {
  String src = '';
  final classList = _ClassList();
}

class _ClassList {
  void add(String className) {}
  void remove(String className) {}
}

class StyleElement {
  String text = '';
}

class HtmlElement {}

class NodeTreeSanitizer {
  static final trusted = NodeTreeSanitizer();
}

class File {
  String name = '';
}

class FileUploadInputElement {
  String accept = '';
  final StreamController<dynamic> _onChangeController = StreamController<dynamic>.broadcast();
  List<File>? _files;

  void click() {}
  List<File>? get files => _files;
  Stream<dynamic> get onChange => _onChangeController.stream;
}

class FileReader {
  dynamic result;
  final StreamController<dynamic> _onLoadEnd = StreamController<dynamic>.broadcast();

  Stream<dynamic> get onLoadEnd => _onLoadEnd.stream;

  void readAsDataUrl(File file) {}
}

class Event {
  dynamic get target => null;
  void preventDefault() {}
  String get key => '';
}