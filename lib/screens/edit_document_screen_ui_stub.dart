// lib/screens/edit_document_screen_web_ui_stub.dart
// Stub para platformViewRegistry quando compilado não-web.

class _PlatformViewRegistry {
  void registerViewFactory(String viewType, dynamic Function(int) factory) {}
}

class _UiWeb {
  final _PlatformViewRegistry platformViewRegistry = _PlatformViewRegistry();
}

// Expose ui_web.platformViewRegistry.registerViewFactory(...)
final _UiWeb ui_web = _UiWeb();