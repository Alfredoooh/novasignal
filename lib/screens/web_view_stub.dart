import 'package:flutter/widgets.dart';

// Stub para mobile - não faz nada
dynamic createWebViewHelper({
  required String url,
  required String viewId,
  required Function(double) onProgress,
}) {
  return null;
}

Widget getWebView(String viewId) {
  return const SizedBox.shrink();
}