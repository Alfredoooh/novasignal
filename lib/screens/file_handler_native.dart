import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'editor_screen.dart';
import 'pdf_viewer_screen.dart';

Future<void> pickAndOpenFile(BuildContext context, VoidCallback? onDone) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'rtf', 'md'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return;

  final file  = result.files.first;
  final ext   = (file.extension ?? '').toLowerCase();
  final name  = file.name;
  final bytes = file.bytes;
  if (bytes == null) return;

  if (ext == 'pdf') {
    final dir     = await getTemporaryDirectory();
    final tmpPath = '${dir.path}/$name';
    await File(tmpPath).writeAsBytes(bytes);

    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(path: tmpPath, title: name),
      ),
    );
  } else if (ext == 'txt' || ext == 'md') {
    final text        = utf8.decode(bytes, allowMalformed: true);
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
    final b64      = base64Encode(bytes);
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
  }
}
