import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerWebViewFactory(String viewType, html.Element Function(int) callback) {
  ui_web.platformViewRegistry.registerViewFactory(viewType, callback);
}

void downloadHtmlFile(String htmlContent, String filename) {
  final blob = html.Blob([htmlContent], 'text/html');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '$filename.html')
    ..click();

  html.Url.revokeObjectUrl(url);
}