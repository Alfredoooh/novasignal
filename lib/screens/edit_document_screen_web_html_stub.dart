// lib/screens/edit_document_screen_web_html_stub.dart
// Stub mínimo para compilar em plataformas não-web.
// Em runtime não-web estes stubs não são usados (kIsWeb evita execução).
// Define apenas os tipos/membros usados no ficheiro principal.

import 'dart:async';

// Html element stubs
class DivElement {
  String id = '';
  final _Style style = _Style();
  String get innerHtml => '';
  set innerHtml(String v) {}
  void append(dynamic _) {}
  // For API parity
  void setInnerHtml(String html, {dynamic treeSanitizer}) {}
}

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
  void setProperty(String name, String value) {}
}

class DivElementWrapper extends DivElement {}

class ImageElement {
  String id = '';
  String src = '';
}

class StyleElement {
  String text = '';
}

class HtmlElement {}

class NodeTreeSanitizer {
  static final trusted = NodeTreeSanitizer();
}

class Event {
  dynamic get target => null;
  void preventDefault() {}
}

// Minimal contentEditable support
class ContentEditableElement extends DivElement {
  String contentEditable = 'false';
  bool spellcheck = false;
  final _Style style = _Style();
  StreamController<dynamic>? _onInputController;
  StreamController<dynamic>? _onClickController;

  Stream<dynamic> get onInput {
    _onInputController ??= StreamController<dynamic>.broadcast();
    return _onInputController!.stream;
  }

  Stream<dynamic> get onClick {
    _onClickController ??= StreamController<dynamic>.broadcast();
    return _onClickController!.stream;
  }
}

// File upload stubs
class File {
  String name = '';
}

class FileUploadInputElement {
  String accept = '';
  List<File>? _files;
  final StreamController<dynamic> _onChange = StreamController<dynamic>.broadcast();

  void click() {}
  List<File>? get files => _files;
  Stream<dynamic> get onChange => _onChange.stream;
  // helpers (not used in non-web)
  void _setFiles(List<File> files) {
    _files = files;
    _onChange.add(null);
  }
}

class FileReader {
  dynamic result;
  final StreamController<dynamic> _onLoadEnd = StreamController<dynamic>.broadcast();
  Stream<dynamic> get onLoadEnd => _onLoadEnd.stream;
  void readAsDataUrl(File file) {}
}

// Selection event stubs used in script (only types)
class Selection {}