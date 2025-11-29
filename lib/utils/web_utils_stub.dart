// Stub para plataformas não-web
void registerWebViewFactory(String viewType, dynamic Function(int) callback) {
  throw UnsupportedError('Cannot register web view on this platform');
}

void downloadHtmlFile(String html, String filename) {
  throw UnsupportedError('Download not supported on this platform');
}

// Funções adicionais necessárias para o document_viewer_screen
dynamic createIFrameElement(String htmlContent) {
  throw UnsupportedError('IFrame not supported on this platform');
}

void addIFrameLoadListener(dynamic iframe, void Function() callback) {
  throw UnsupportedError('IFrame not supported on this platform');
}

void addIFrameErrorListener(dynamic iframe, void Function() callback) {
  throw UnsupportedError('IFrame not supported on this platform');
}