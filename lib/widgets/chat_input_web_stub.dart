// Stub para dart:html (mobile)
class DivElement {
  final style = _Style();
  void append(dynamic _) {}
}

class InputElement {
  String? value;
  String type = '';
  String placeholder = '';
  final style = _Style();
  void setAttribute(String name, String value) {}
  void focus() {}
  void blur() {}
  Stream<dynamic> get onKeyPress => Stream.empty();
  Stream<dynamic> get onInput => Stream.empty();
  Stream<dynamic> get onFocus => Stream.empty();
  Stream<dynamic> get onBlur => Stream.empty();
}

class StyleElement {
  String text = '';
}

class _Style {
  String width = '';
  String height = '';
  String display = '';
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