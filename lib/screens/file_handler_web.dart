import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'editor_screen.dart';
import 'pdf_viewer_screen.dart';

Future<void> pickAndOpenFile(BuildContext context, VoidCallback? onDone) async {
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,.docx,.doc,.txt,.rtf,.md'
    ..multiple = false;
  input.click();

  await input.onChange.first;
  if (input.files == null || input.files!.isEmpty) return;

  final htmlFile = input.files!.first;
  final name = htmlFile.name;
  final ext  = name.contains('.') ? name.split('.').last.toLowerCase() : '';

  final reader = html.FileReader();

  if (ext == 'txt' || ext == 'md') {
    reader.readAsText(htmlFile);
    await reader.onLoad.first;
    final text = reader.result as String;
    final htmlContent = '<p>${text.replaceAll('\n\n', '</p><p>').replaceAll('\n', '<br/>')}</p>';

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          importHtml: htmlContent,
          importTitle: name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        ),
      ),
    );
    onDone?.call();
  } else if (ext == 'docx' || ext == 'doc') {
    reader.readAsArrayBuffer(htmlFile);
    await reader.onLoad.first;
    final bytes = Uint8List.fromList((reader.result as List<int>));
    final b64 = base64Encode(bytes);
    final docTitle = name.replaceAll(RegExp(r'\.[^.]+$'), '');

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          importDocxBase64: b64,
          importTitle: docTitle,
        ),
      ),
    );
    onDone?.call();
  } else if (ext == 'pdf') {
    reader.readAsArrayBuffer(htmlFile);
    await reader.onLoad.first;
    final bytes = Uint8List.fromList((reader.result as List<int>));

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(pdfBytes: bytes, title: name),
      ),
    );
  }
}
