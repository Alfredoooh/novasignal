import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';

// Importação condicional — WebView só no nativo, iframe só na web
import 'editor_native.dart' if (dart.library.html) 'editor_web.dart';

class EditorScreen extends StatefulWidget {
  final ADocument? document;
  const EditorScreen({super.key, this.document});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool _saving = false;
  String _title = 'Sem título';

  @override
  void initState() {
    super.initState();
    _title = widget.document?.title ?? 'Sem título';
  }

  // Chamado pelo editor (web ou nativo) ao receber mensagem "save"
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
      setState(() { _saving = false; _title = doc.title; });
      _snack('Guardado');
    }
  }

  // Chamado pelo editor ao receber "back"
  void handleBack() {
    Navigator.of(context).pop();
  }

  void setSaving(bool v) { if (mounted) setState(() => _saving = v); }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700)),
      backgroundColor: AriaTheme.acc,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // O editor cuida do próprio header — sem AppBar Flutter
      // para não duplicar com o header do Ionic
      body: buildEditorView(context, this),
    );
  }
}
