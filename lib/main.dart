import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

const String _url = 'https://elephantbetzone.com';
const String _chromeUA =
    'Mozilla/5.0 (Linux; Android 13; itel A665L) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
const double _normalHeight = 56;
const double _smallHeight = 44;
const Color _defaultBg = Colors.white;

bool _urlRequiresSmallHeader(String url) {
  final u = url.split('?').first.toLowerCase();
  return u.contains('/app/now') || u.contains('/app/typesport/');
}

bool _isColorLight(Color color) {
  final lum = 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
  return lum > 180;
}

Color? _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  try {
    final h = hex.replaceAll('#', '').trim();
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
  } catch (_) {}
  return null;
}

class ElephantBetScreen extends StatefulWidget {
  const ElephantBetScreen({super.key});

  @override
  State<ElephantBetScreen> createState() => _ElephantBetScreenState();
}

class _ElephantBetScreenState extends State<ElephantBetScreen>
    with SingleTickerProviderStateMixin {
  InAppWebViewController? _webviewController;
  bool _canGoBack = false;
  bool _initialLoading = true;
  Color _appbarColor = _defaultBg;
  double _headerHeight = _normalHeight;

  late AnimationController _animController;
  late Animation<double> _heightAnim;

  final String _injectedBefore = """
(function(){
  try {
    var desired = 'width=device-width,initial-scale=1,viewport-fit=cover';
    var m = document.querySelector('meta[name="viewport"]');
    if (m) {
      var c = m.getAttribute('content') || '';
      if (c.indexOf('viewport-fit') === -1) {
        m.setAttribute('content', c + (c ? ',' : '') + 'viewport-fit=cover');
      } else {
        m.setAttribute('content', desired);
      }
    } else {
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = desired;
      document.head.appendChild(meta);
    }
    document.documentElement.style.paddingTop = '0px';
    document.body.style.paddingTop = '0px';
  } catch(e) {}
})(); true;
""";

  final String _injectedAfter = """
(function(){
  function toHex(n){ var h = Number(n).toString(16); return h.length===1? '0'+h : h; }
  function rgbToHex(rgb){
    if(!rgb) return null;
    try {
      rgb = rgb.replace(/\\s+/g,'');
      if(rgb.indexOf('#') === 0) return rgb;
      if(rgb.indexOf('rgb') === -1) return null;
      var nums = rgb.match(/\\d+/g);
      if(!nums || nums.length < 3) return null;
      return '#' + toHex(nums[0]) + toHex(nums[1]) + toHex(nums[2]);
    } catch(e){ return null; }
  }
  try {
    function gatherMeta(){
      var theme = null;
      try {
        var m = document.querySelector('meta[name="theme-color"]');
        if(m) theme = m.getAttribute('content');
      } catch(e){}
      var selectors = ['header','nav','#header','.site-header','.main-header','.topbar','.navbar','.header-wrapper','.mobile-header','.site-top'];
      var headerBg = null;
      for(var i=0;i<selectors.length;i++){
        try {
          var el = document.querySelector(selectors[i]);
          if(el){
            var st = window.getComputedStyle(el);
            var bg = st.backgroundColor || st.background;
            if(bg && bg !== 'transparent' && bg !== 'rgba(0,0,0,0)' && bg.indexOf('rgb') !== -1){
              headerBg = bg;
              break;
            }
          }
        } catch(e){}
      }
      if(theme && theme.indexOf('rgb') !== -1) theme = rgbToHex(theme);
      if(headerBg && headerBg.indexOf('rgb') !== -1) headerBg = rgbToHex(headerBg);
      var primary = theme || headerBg || null;
      var headerHeight = 0;
      try {
        var el2 = document.querySelector('header, nav, .site-header, .main-header, .topbar');
        if(el2) headerHeight = Math.round(el2.getBoundingClientRect().height || 0);
      } catch(e){}
      var payload = { type: 'siteMeta', primaryColor: primary, headerHeight: headerHeight, url: location.href };
      window.flutter_inappwebview.callHandler('onSiteMeta', JSON.stringify(payload));
    }
    gatherMeta();
    var runs = 0;
    var iv = setInterval(function(){ gatherMeta(); runs++; if(runs>12) clearInterval(iv); }, 200);
  } catch(e){}
})(); true;
""";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _heightAnim = Tween<double>(begin: _normalHeight, end: _normalHeight)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateHeader(bool toSmall) {
    final target = toSmall ? _smallHeight : _normalHeight;
    if (_headerHeight == target) return;
    setState(() => _headerHeight = target);
    _heightAnim = Tween<double>(
      begin: _heightAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.forward(from: 0);
  }

  void _handleSiteMeta(String json) {
    try {
      // parse manual simples
      final colorMatch = RegExp(r'"primaryColor"\s*:\s*"([^"]+)"').firstMatch(json);
      final heightMatch = RegExp(r'"headerHeight"\s*:\s*(\d+)').firstMatch(json);
      final urlMatch = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(json);

      if (colorMatch != null) {
        final color = _parseHexColor(colorMatch.group(1));
        if (color != null && mounted) {
          setState(() => _appbarColor = color);
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: color,
            statusBarIconBrightness:
                _isColorLight(color) ? Brightness.dark : Brightness.light,
          ));
        }
      }

      if (urlMatch != null) {
        _animateHeader(_urlRequiresSmallHeader(urlMatch.group(1) ?? ''));
      } else if (heightMatch != null) {
        final h = int.tryParse(heightMatch.group(1) ?? '0') ?? 0;
        if (h > 60) _animateHeader(true);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isColorLight(_appbarColor) ? Colors.black : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: _appbarColor,
        statusBarIconBrightness:
            _isColorLight(_appbarColor) ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _appbarColor,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar animado
              AnimatedBuilder(
                animation: _heightAnim,
                builder: (context, _) {
                  return Container(
                    height: _heightAnim.value,
                    color: _appbarColor,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: IconButton(
                            icon: Icon(Icons.chevron_left, color: iconColor),
                            onPressed: () async {
                              if (_canGoBack && _webviewController != null) {
                                await _webviewController!.goBack();
                              } else {
                                if (context.mounted) Navigator.of(context).maybePop();
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'elephantbetzone.com',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: IconButton(
                            icon: Icon(Icons.refresh, color: iconColor),
                            onPressed: () => _webviewController?.reload(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // WebView
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(_url),
                      ),
                      initialSettings: InAppWebViewSettings(
                        userAgent: _chromeUA,
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                        useShouldOverrideUrlLoading: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        transparentBackground: false,
                      ),
                      onWebViewCreated: (controller) {
                        _webviewController = controller;
                        controller.addJavaScriptHandler(
                          handlerName: 'onSiteMeta',
                          callback: (args) {
                            if (args.isNotEmpty) _handleSiteMeta(args.first.toString());
                          },
                        );
                      },
                      onLoadStart: (controller, url) {
                        controller.evaluateJavascript(source: _injectedBefore);
                        if (url != null) {
                          _animateHeader(_urlRequiresSmallHeader(url.toString()));
                        }
                      },
                      onLoadStop: (controller, url) async {
                        if (mounted) setState(() => _initialLoading = false);
                        await controller.evaluateJavascript(source: _injectedAfter);
                        final canGoBack = await controller.canGoBack();
                        if (mounted) setState(() => _canGoBack = canGoBack);
                      },
                      onReceivedError: (controller, request, error) {
                        if (mounted) setState(() => _initialLoading = false);
                      },
                      onUpdateVisitedHistory: (controller, url, isReload) async {
                        final canGoBack = await controller.canGoBack();
                        if (mounted) setState(() => _canGoBack = canGoBack);
                        if (url != null) {
                          _animateHeader(_urlRequiresSmallHeader(url.toString()));
                        }
                      },
                    ),
                    if (_initialLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
