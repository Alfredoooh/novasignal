import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';

import 'editor_native.dart' if (dart.library.html) 'editor_web.dart';

abstract class EditorController {
  ADocument? get document;
  String? get importHtml;
  String? get importTitle;
  String? get importDocxBase64;
  Future<void> handleSaveMessage(Map<String, dynamic> data);
  void handleBack();
  void setSaving(bool v);
}

class EditorScreen extends StatefulWidget {
  final ADocument? document;
  final String? importHtml;
  final String? importTitle;
  final String? importDocxBase64;

  const EditorScreen({
    super.key,
    this.document,
    this.importHtml,
    this.importTitle,
    this.importDocxBase64,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    implements EditorController {
  bool _saving = false;

  @override ADocument? get document        => widget.document;
  @override String?    get importHtml       => widget.importHtml;
  @override String?    get importTitle      => widget.importTitle;
  @override String?    get importDocxBase64 => widget.importDocxBase64;

  @override
  Future<void> handleSaveMessage(Map<String, dynamic> data) async {
    final innerData = jsonDecode(data['data'] as String) as Map<String, dynamic>;
    final now = DateTime.now();
    final id = (data['id'] as String?)?.isNotEmpty == true
        ? data['id'] as String
        : widget.document?.id ?? const Uuid().v4();

    final docTitle = (innerData['title'] as String?)?.trim();
    final doc = ADocument(
      id: id,
      title: (docTitle == null || docTitle.isEmpty) ? 'Sem título' : docTitle,
      htmlContent: innerData['html'] as String? ?? '',
      plainText: innerData['text'] as String? ?? '',
      wordCount: innerData['words'] as int? ?? 0,
      createdAt: widget.document?.createdAt ?? now,
      updatedAt: now,
    );

    await DocumentService.instance.save(doc);
    if (mounted) {
      setState(() => _saving = false);
      _snack('Guardado');
    }
  }

  @override
  void handleBack() => Navigator.of(context).pop();

  @override
  void setSaving(bool v) { if (mounted) setState(() => _saving = v); }

  void _snack(String msg) {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: acc,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return Scaffold(
      backgroundColor: Color(isDark ? 0xFF242424 : 0xFFFFFFFF),
      body: buildEditorView(context, this),
    );
  }
}
