// lib/widgets/chat_input_web_html_stub.dart
// Stub para dart:html usado em builds mobile

import 'dart:async';

class _Style {
  String width = '';
  String height = '';
  String display = '';
  String alignItems = '';
  String flex = '';
  String padding = '';
  String border = '';
  String borderRadius = '';
  String fontSize = '';
  String outline = '';
  String backgroundColor = '';
  String color = '';
  String fontFamily = '';
  String transition = '';
  String userSelect = '';
  
  void setProperty(String name, String value) {}
}

class DivElement {
  final _Style style = _Style();
  void append(dynamic _) {}
}

class InputElement {
  String? value;
  String type = '';
  String placeholder = '';
  String id = '';
  final _Style style = _Style();
  
  void setAttribute(String name, String value) {}
  void focus() {}
  void blur() {}
  
  final StreamController<_KeyEvent> _onKeyPressController = StreamController<_KeyEvent>.broadcast();
  final StreamController<dynamic> _onInputController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _onFocusController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _onBlurController = StreamController<dynamic>.broadcast();
  
  Stream<_KeyEvent> get onKeyPress => _onKeyPressController.stream;
  Stream<dynamic> get onInput => _onInputController.stream;
  Stream<dynamic> get onFocus => _onFocusController.stream;
  Stream<dynamic> get onBlur => _onBlurController.stream;
}

class StyleElement {
  String text = '';
}

class _KeyEvent {
  String get key => '';
  void preventDefault() {}
}