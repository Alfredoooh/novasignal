import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../widgets/theme.dart';
import '../services/notification_service.dart';

class CvEditorScreen extends StatefulWidget {
  final String? docId;
  final String? docTitle;
  const CvEditorScreen({super.key, this.docId, this.docTitle});
  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen> {
  InAppWebViewController? _wvc;
  late TextEditingController _titleCtrl;
  bool _changed = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.docTitle ?? 'Currículo');
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
    _wvc?.evaluateJavascript(source: 'setTheme(${themeNotifier.isDark})');
  }

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (img == null) return;
      final bytes = await img.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = img.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
      await _wvc?.evaluateJavascript(source: 'insertImageBase64("$b64","$mime")');
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _handleExportPdf(Map<String, dynamic> data) async {
    final base64Str = data['base64'] as String? ?? '';
    final title = _titleCtrl.text.trim().isEmpty ? 'curriculo' : _titleCtrl.text.trim();
    if (base64Str.isEmpty) { _showSnack('Erro ao gerar PDF.', err: true); return; }
    final path = await NotificationService.instance.savePdfBase64(
      base64Data: base64Str, title: title,
    );
    if (path != null) {
      _showSnack('"$title" guardado em Downloads ✓');
    } else {
      try {
        final bytes = base64Decode(base64Str);
        final dir = await getTemporaryDirectory();
        final safe = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
        final file = File('${dir.path}/$safe.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')], subject: title);
      } catch (e) {
        _showSnack('Erro ao exportar PDF.', err: true);
      }
    }
  }

  void _showSnack(String msg, {bool err = false}) {
    final isDark = themeNotifier.isDark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: err ? Colors.red : accColor(isDark),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? AppColors.darkBackground    : AppColors.background;
    final tp  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final acc = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: acc, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _titleCtrl,
          style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            border: InputBorder.none, isDense: true,
            hintText: 'Título do CV', hintStyle: GoogleFonts.roboto(color: ts, fontSize: 17),
          ),
          onChanged: (_) { if (!_changed) setState(() => _changed = true); },
        ),
        actions: [
          if (_changed)
            TextButton(
              onPressed: () async {
                await _wvc?.evaluateJavascript(source: "showToast('Guardado ✓')");
                setState(() => _changed = false);
              },
              child: Text('Guardar', style: GoogleFonts.roboto(color: acc, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: InAppWebView(
        initialFile: 'assets/cv/cv_editor.html',
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          supportZoom: false,
          disableHorizontalScroll: false,
        ),
        onWebViewCreated: (ctrl) {
          _wvc = ctrl;
          ctrl.addJavaScriptHandler(
            handlerName: 'CvBridge',
            callback: (args) async {
              try {
                final d = jsonDecode(args[0] as String) as Map<String, dynamic>;
                final action = d['action'] as String?;
                switch (action) {
                  case 'autosave':
                  case 'changed':
                    if (!_changed && mounted) setState(() => _changed = true);
                    break;
                  case 'insertImage':
                    await _pickImage();
                    break;
                  case 'exportPDF':
                    await _handleExportPdf(d);
                    break;
                }
              } catch (e) {
                debugPrint('CvBridge error: $e');
              }
            },
          );
        },
        onLoadStop: (ctrl, _) async {
          await ctrl.evaluateJavascript(source: 'setTheme(${themeNotifier.isDark})');
        },
      ),
    );
  }
}
