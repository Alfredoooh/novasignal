import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

class WebViewHelper {
  final String url;
  final String viewId;
  final Function(double) onProgress;
  html.IFrameElement? _iframeElement;

  WebViewHelper({
    required this.url,
    required this.viewId,
    required this.onProgress,
  });

  void initialize() {
    _iframeElement = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'camera; microphone; geolocation'
      ..allowFullscreen = true;

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => _iframeElement!,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      onProgress(0.5);
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      onProgress(1.0);
    });
  }

  void injectScript(String script) {
    try {
      _iframeElement?.contentWindow?.postMessage({
        'type': 'inject-styles',
        'script': script,
      }, '*');
    } catch (e) {
      print('Erro ao injetar script: $e');
    }
  }

  void reload() {
    if (_iframeElement != null) {
      _iframeElement!.src = '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void dispose() {
    _iframeElement?.remove();
  }
}

dynamic createWebViewHelper({
  required String url,
  required String viewId,
  required Function(double) onProgress,
}) {
  return WebViewHelper(
    url: url,
    viewId: viewId,
    onProgress: onProgress,
  );
}

Widget getWebView(String viewId) {
  return HtmlElementView(viewType: viewId);
}