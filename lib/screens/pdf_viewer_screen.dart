import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/theme.dart';

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
  bool _preparing = true;
  String? _pdfBase64;
  String? _error;

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
    _loadPdfBytes();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  Future<void> _loadPdfBytes() async {
    try {
      final file = File(widget.path);
      if (!await file.exists()) {
        if (mounted) setState(() { _error = 'Ficheiro não encontrado.'; _preparing = false; });
        return;
      }
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      if (mounted) setState(() { _pdfBase64 = b64; _preparing = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Erro ao ler PDF: $e'; _preparing = false; });
    }
  }

  void _onTheme() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc         = accColor(isDark);

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
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>',
            width: 22, height: 22,
            colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title,
          style: GoogleFonts.roboto(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: SvgPicture.string(
              '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M11,2a1,1,0,0,1,2,0V13.586l3.293-3.293a1,1,0,0,1,1.414,1.414l-5,5a1,1,0,0,1-1.414,0l-5-5a1,1,0,0,1,1.414-1.414L11,13.586ZM22,17a1,1,0,0,0-2,0v3H4V17a1,1,0,0,0-2,0v4a1,1,0,0,0,1,1H21a1,1,0,0,0,1-1Z"/></svg>',
              width: 22, height: 22,
              colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn),
            ),
            onPressed: () => Share.shareXFiles([XFile(widget.path)], text: widget.title),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: divColor),
        ),
      ),
      body: _buildBody(bg, acc, textPrimary, textSec, isDark),
    );
  }

  Widget _buildBody(Color bg, Color acc, Color tp, Color ts, bool isDark) {
    if (_preparing) {
      return Container(color: bg, child: Center(child: CircularProgressIndicator(color: acc, strokeWidth: 2)));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, color: AppColors.danger, size: 56),
            const SizedBox(height: 16),
            Text('Erro ao carregar PDF', style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.syne(color: ts, fontSize: 13), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final html = _buildHtml(_pdfBase64!, widget.title, isDark);
    return Stack(children: [
      InAppWebView(
        initialData: InAppWebViewInitialData(data: html, mimeType: 'text/html'),
        initialSettings: _settings,
        onWebViewCreated: (c) => _wvc = c,
        onLoadStop: (c, url) { if (mounted) setState(() => _loading = false); },
      ),
      if (_loading)
        Container(color: bg, child: Center(child: CircularProgressIndicator(color: acc, strokeWidth: 2))),
    ]);
  }

  String _buildHtml(String b64, String title, bool isDark) {
    final bgColor = isDark ? '#2e2e2e' : '#f0f0f0';
    final textColor = isDark ? '#e0e0e0' : '#222222';
    return '''<!DOCTYPE html>
<html lang="pt"><head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>$title</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:$bgColor;display:flex;flex-direction:column;align-items:center;padding:16px 12px 80px;min-height:100vh;}
.pages{display:flex;flex-direction:column;align-items:center;gap:16px;width:100%;}
canvas{display:block;width:100%;max-width:800px;background:#fff;box-shadow:0 2px 12px rgba(0,0,0,.25),0 6px 30px rgba(0,0,0,.15);}
.lbl{font-family:monospace;font-size:11px;color:$textColor;opacity:.5;text-align:center;padding:4px 0;}
.msg{color:$textColor;font-family:sans-serif;padding:40px;text-align:center;opacity:.7;}
.err{color:#ff453a;font-family:sans-serif;padding:40px;text-align:center;}
</style></head><body>
<div id="c" class="pages"><p class="msg">A carregar PDF…</p></div>
<script>
pdfjsLib.GlobalWorkerOptions.workerSrc='https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
(async()=>{
  const c=document.getElementById('c');
  c.innerHTML='';
  try{
    const b64='$b64';
    const bin=atob(b64);
    const bytes=new Uint8Array(bin.length);
    for(let i=0;i<bin.length;i++)bytes[i]=bin.charCodeAt(i);
    const pdf=await pdfjsLib.getDocument({data:bytes}).promise;
    const dpr=window.devicePixelRatio||2;
    for(let i=1;i<=pdf.numPages;i++){
      const pg=await pdf.getPage(i);
      const vp=pg.getViewport({scale:2.5*dpr});
      const cv=document.createElement('canvas');
      cv.width=vp.width;cv.height=vp.height;
      const ctx=cv.getContext('2d');
      ctx.fillStyle='#ffffff';ctx.fillRect(0,0,cv.width,cv.height);
      await pg.render({canvasContext:ctx,viewport:vp}).promise;
      const lbl=document.createElement('p');
      lbl.className='lbl';lbl.textContent='Página '+i+' de '+pdf.numPages;
      c.appendChild(cv);c.appendChild(lbl);
    }
  }catch(e){c.innerHTML='<p class="err">Erro ao carregar PDF.<br/>'+e.message+'</p>';}
})();
</script></body></html>''';
  }
}
