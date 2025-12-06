// lib/screens/edit_document_screen_web_html_stub.dart
// Stub robusto para dart:html usado apenas em builds não-web.
// Fornece membros usados no ficheiro principal (contentEditable, onInput, onClick, style.userSelect, setInnerHtml, etc).
// Em runtime no dispositivo móvel estes stubs não são usados (kIsWeb evita execução).

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
  // Adicionado para corresponder ao uso .userSelect no código real
  String userSelect = '';
  // Permitir setProperty como no DOM
  void setProperty(String name, String value) {}
}

class DivElement {
  String id = '';
  // suporte básico a contentEditable e spellcheck
  String contentEditable = 'false';
  bool spellcheck = false;

  final _Style style = _Style();

  String _innerHtml = '';
  String get innerHtml => _innerHtml;
  set innerHtml(String v) => _innerHtml = v;

  // stream controllers para simular onInput/onClick listeners do DOM
  final StreamController<dynamic> _onInputController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _onClickController = StreamController<dynamic>.broadcast();

  // APIs esperadas pelo teu ficheiro
  Stream<dynamic> get onInput => _onInputController.stream;
  Stream<dynamic> get onClick => _onClickController.stream;

  // Métodos de manipulação básicos
  void append(dynamic _) {}
  void remove() {}

  // Compatibilidade com setInnerHtml usada no código
  void setInnerHtml(String html, {dynamic treeSanitizer}) {
    _innerHtml = html;
  }

  // Helpers (somente para testes locais se quiseres disparar eventos)
  void triggerInput([dynamic evt]) => _onInputController.add(evt);
  void triggerClick([dynamic evt]) => _onClickController.add(evt);
}

class ImageElement extends DivElement {
  String src = '';
  // id herdado de DivElement
}

class StyleElement {
  String text = '';
}

class HtmlElement {}

class NodeTreeSanitizer {
  static final trusted = NodeTreeSanitizer();
}

// File upload / FileReader stubs usados no teu código
class File {
  String name = '';
  // placeholder
}

class FileUploadInputElement {
  String accept = '';
  final StreamController<dynamic> _onChangeController = StreamController<dynamic>.broadcast();
  List<File>? _files;

  void click() {}
  List<File>? get files => _files;
  Stream<dynamic> get onChange => _onChangeController.stream;

  // helper para testes locais
  void _setFiles(List<File> files) {
    _files = files;
    _onChangeController.add(null);
  }
}

class FileReader {
  dynamic result;
  final StreamController<dynamic> _onLoadEnd = StreamController<dynamic>.broadcast();

  Stream<dynamic> get onLoadEnd => _onLoadEnd.stream;

  void readAsDataUrl(File file) {}
  // helper para testes locais
  void _triggerLoadEnd([dynamic evt]) => _onLoadEnd.add(evt);
}

// Event e ImageElement target shim
class Event {
  dynamic get target => null;
  void preventDefault() {}
}