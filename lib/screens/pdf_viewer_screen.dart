import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/theme.dart';

/// Visualizador de PDF usando InAppWebView com PDF.js (via CDN)
class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  InAppWebViewController? _wvc;
  bool _loading = true;

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    transparentBackground: false,
    disallowOverScroll: true,
    textZoom: 100,
  );

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
    _injectTheme();
  }

  void _injectTheme() {
    final isDark = themeNotifier.isDark;
    _wvc?.evaluateJavascript(
      source: 'document.body.setAttribute("data-theme", "${isDark ? 'dark' : 'light'}");',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc         = accColor(isDark);

    // Gera HTML que usa PDF.js para renderizar o PDF local
    final pdfHtml = _buildPdfHtml(widget.path, widget.title, isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: SvgPicture.string(
            '''<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M20,11H7.83l5.59-5.59L12,4l-8,8,8,8,1.41-1.41L7.83,13H20v-2Z"/>
            </svg>''',
            width: 22, height: 22,
            colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.syne(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: SvgPicture.string(
              '''<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M11,2a1,1,0,0,1,2,0V13.586l3.293-3.293a1,1,0,0,1,1.414,1.414l-5,5a1,1,0,0,1-1.414,0l-5-5a1,1,0,0,1,1.414-1.414L11,13.586ZM22,17a1,1,0,0,0-2,0v3H4V17a1,1,0,0,0-2,0v4a1,1,0,0,0,1,1H21a1,1,0,0,0,1-1Z"/>
              </svg>''',
              width: 22, height: 22,
              colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
            ),
            onPressed: () => Share.shareXFiles([XFile(widget.path)], text: widget.title),
            tooltip: 'Partilhar',
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: divColor),
        ),
      ),
      body: Stack(children: [
        InAppWebView(
          initialData: InAppWebViewInitialData(data: pdfHtml, mimeType: 'text/html'),
          initialSettings: _settings,
          onWebViewCreated: (ctrl) => _wvc = ctrl,
          onLoadStop: (ctrl, url) {
            if (mounted) setState(() => _loading = false);
          },
        ),
        if (_loading)
          Container(
            color: bg,
            child: Center(
              child: CircularProgressIndicator(color: acc, strokeWidth: 2),
            ),
          ),
      ]),
    );
  }

  String _buildPdfHtml(String filePath, String title, bool isDark) {
    final bgColor   = isDark ? '#242424' : '#f5f5f5';
    final textColor = isDark ? '#e0e0e0' : '#111111';
    final fileUri   = 'file://$filePath';

    return '''<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>$title</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{background:$bgColor;display:flex;flex-direction:column;align-items:center;padding:16px 12px 80px;min-height:100vh;}
    .page-container{display:flex;flex-direction:column;align-items:center;gap:16px;width:100%;}
    canvas{
      display:block;width:100%;max-width:800px;
      background:#fff;
      box-shadow:0 2px 12px rgba(0,0,0,.25),0 6px 30px rgba(0,0,0,.15);
    }
    .page-label{
      font-family:'Courier New',monospace;font-size:11px;
      color:$textColor;opacity:.5;text-align:center;padding:4px 0;
      letter-spacing:.05em;
    }
    .loading{color:$textColor;font-family:sans-serif;padding:40px;text-align:center;opacity:.7;}
    .error{color:#ff453a;font-family:sans-serif;padding:40px;text-align:center;}
  </style>
</head>
<body>
  <div id="container" class="page-container">
    <p class="loading">A carregar PDF…</p>
  </div>
  <script>
    pdfjsLib.GlobalWorkerOptions.workerSrc =
      'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';

    async function renderPDF() {
      const container = document.getElementById('container');
      container.innerHTML = '';
      try {
        const pdf = await pdfjsLib.getDocument('$fileUri').promise;
        for (let i = 1; i <= pdf.numPages; i++) {
          const page   = await pdf.getPage(i);
          const vp     = page.getViewport({ scale: 2.0 });
          const canvas = document.createElement('canvas');
          canvas.width  = vp.width;
          canvas.height = vp.height;
          const ctx = canvas.getContext('2d');
          await page.render({ canvasContext: ctx, viewport: vp }).promise;
          const label  = document.createElement('p');
          label.className = 'page-label';
          label.textContent = 'Página ' + i + ' de ' + pdf.numPages;
          container.appendChild(canvas);
          container.appendChild(label);
        }
      } catch(e) {
        container.innerHTML = '<p class="error">Erro ao carregar PDF.<br/>' + e.message + '</p>';
      }
    }
    renderPDF();
  </script>
</body>
</html>''';
  }
}
