import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'editor_native.dart';

abstract class EditorController {
  ADocument? get document;
  DocType get docType;
  String? get importHtml;
  String? get importTitle;
  String? get importDocxBase64;
  Future<void> handleSaveMessage(Map<String, dynamic> data);
  void handleBack();
  void setSaving(bool v);
}

class EditorScreen extends StatefulWidget {
  final ADocument? document;
  final DocType docType;
  final String? importHtml;
  final String? importTitle;
  final String? importDocxBase64;
  final bool isRoot;

  const EditorScreen({
    super.key,
    this.document,
    this.docType = DocType.document,
    this.importHtml,
    this.importTitle,
    this.importDocxBase64,
    this.isRoot = false,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    implements EditorController {

  @override ADocument? get document        => widget.document;
  @override DocType    get docType         => widget.document?.docType ?? widget.docType;
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
      plainText:   innerData['text'] as String? ?? '',
      wordCount:   innerData['words'] as int?   ?? 0,
      createdAt:   widget.document?.createdAt ?? now,
      updatedAt:   now,
      docType:     widget.document?.docType ?? widget.docType,
    );

    await DocumentService.instance.save(doc);

    if (AuthService.instance.loggedIn) {
      AuthService.instance.syncDocument(doc.toJson()).ignore();
    }

    if (mounted) setState(() {});
  }

  @override
  void handleBack() {
    if (!widget.isRoot) Navigator.of(context).pop();
  }

  @override
  void setSaving(bool v) { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return Scaffold(
      backgroundColor: Color(isDark ? 0xFF242424 : 0xFFFFFFFF),
      body: buildEditorView(context, this),
    );
  }
}
