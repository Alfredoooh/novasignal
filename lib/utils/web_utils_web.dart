import 'dart:html' as html;
import 'dart:ui' as ui;

void registerWebViewFactory(String viewType, html.Element Function(int) callback) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, callback);
}

void downloadHtmlFile(String htmlContent, String filename) {
  final blob = html.Blob([htmlContent], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '$filename.html')
    ..click();
  
  html.Url.revokeObjectUrl(url);
}