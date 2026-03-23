import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/theme.dart';

const _svgArrowLeft = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M21,11H4.414l3.293-3.293c.391-.391.391-1.023,0-1.414-.391-.391-1.023-.391-1.414,0l-5,5c-.391.391-.391,1.023,0,1.414l5,5c.195.195.451.293.707.293s.512-.098.707-.293c.391-.391.391-1.023,0-1.414l-3.293-3.293H21c.552,0,1-.448,1-1s-.448-1-1-1Z"/></svg>';
const _svgOpcoes    = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm0,22c-5.514,0-10-4.486-10-10S6.486,2,12,2s10,4.486,10,10-4.486,10-10,10Zm-4-10c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm11,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm-5.5,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Z"/></svg>';

Widget _svg(String d, Color c, {double s = 22}) =>
  SvgPicture.string(d, width: s, height: s,
    colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

class CriarCodigosPage extends StatefulWidget {
  const CriarCodigosPage({super.key});
  @override
  State<CriarCodigosPage> createState() => _CriarCodigosPageState();
}

class _CriarCodigosPageState extends State<CriarCodigosPage> {
  InAppWebViewController? _wvc;

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
    final isDark = themeNotifier.isDark;
    _wvc?.evaluateJavascript(
      source: 'if(typeof window.setTheme==="function") window.setTheme(${isDark ? 'true' : 'false'});',
    );
    setState(() {});
  }

  void _showPopup(BuildContext context) async {
    final btn     = context.findRenderObject() as RenderBox;
    final overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final isDark  = themeNotifier.isDark;
    final textP   = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surfBg  = isDark ? const Color(0xFF222222) : const Color(0xFFF2F2F2);
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        btn.localToGlobal(Offset.zero, ancestor: overlay),
        btn.localToGlobal(btn.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final result = await showMenu<String>(
      context: context, position: pos,
      color: surfBg, elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeOutQuart, duration: const Duration(milliseconds: 300),
        reverseCurve: Curves.easeInQuart, reverseDuration: const Duration(milliseconds: 200),
      ),
      items: [
        PopupMenuItem<String>(value: 'qr', child: Row(children: [
          Icon(Icons.qr_code_rounded, color: textP, size: 20),
          const SizedBox(width: 12),
          Text('QR Code', style: TextStyle(color: textP, fontSize: 15)),
        ])),
        PopupMenuItem<String>(value: 'barcode', child: Row(children: [
          Icon(Icons.barcode_reader, color: textP, size: 20),
          const SizedBox(width: 12),
          Text('Código de barras', style: TextStyle(color: textP, fontSize: 15)),
        ])),
      ],
    );
    if (result != null) {
      _wvc?.evaluateJavascript(source: 'switchTab("$result")');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg     = isDark ? AppColors.darkBackground : AppColors.background;
    final textP  = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: _svg(_svgArrowLeft, textP, s: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Criar códigos',
          style: TextStyle(color: textP, fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          Builder(builder: (ctx) => IconButton(
            icon: _svg(_svgOpcoes, textP, s: 22),
            onPressed: () => _showPopup(ctx),
          )),
        ],
      ),
      body: InAppWebView(
        initialFile: 'assets/codigos/codigos.html',
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
          disallowOverScroll: true,
          textZoom: 100,
        ),
        onWebViewCreated: (ctrl) => _wvc = ctrl,
        onLoadStop: (ctrl, _) async {
          final isDark = themeNotifier.isDark;
          await ctrl.evaluateJavascript(
            source: 'if(typeof window.setTheme==="function") window.setTheme(${isDark ? 'true' : 'false'});',
          );
        },
      ),
    );
  }
}
