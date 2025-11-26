// Stub para plataformas não-web
void registerWebViewFactory(String viewType, dynamic Function(int) callback) {
  throw UnsupportedError('Cannot register web view on this platform');
}

void downloadHtmlFile(String html, String filename) {
  throw UnsupportedError('Download not supported on this platform');
}