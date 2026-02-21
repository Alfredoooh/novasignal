import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
// SVGs INLINE
// ─────────────────────────────────────────────

const String _mensagensFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m13-.004H5C2.243-.004,0,2.239,0,4.996v12.854c0,.793.435,1.519,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.191-.36l3.963-2.643h5.697c2.757,0,5-2.243,5-5v-7C18,2.239,15.757-.004,13-.004Zm11,9v12.854c0,.793-.435,1.519-1.134,1.894-.318.171-.667.255-1.015.256-.416,0-.831-.121-1.19-.36l-3.964-2.644h-5.697c-1.45,0-2.747-.631-3.661-1.62l.569-.38h5.092c3.859,0,7-3.141,7-7v-7c0-.308-.027-.608-.065-.906,2.311.44,4.065,2.469,4.065,4.906Z"/>
</svg>
''';

const String _mensagensOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m19,4h-1.101c-.465-2.279-2.485-4-4.899-4H5C2.243,0,0,2.243,0,5v12.854c0,.794.435,1.52,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.19-.36l2.95-1.967c.691,1.935,2.541,3.324,4.711,3.324h5.697l3.964,2.643c.36.24.774.361,1.19.361.348,0,.696-.085,1.015-.256.7-.374,1.134-1.1,1.134-1.894v-12.854c0-2.757-2.243-5-5-5ZM2.23,17.979c-.019.012-.075.048-.152.007-.079-.042-.079-.109-.079-.131V5c0-1.654,1.346-3,3-3h8c1.654,0,3,1.346,3,3v7c0,1.654-1.346,3-3,3h-6c-.327,0-.541.159-.565.175l-4.205,2.804Zm19.77,3.876c0,.021,0,.089-.079.131-.079.041-.133.005-.151-.007l-4.215-2.811c-.164-.109-.357-.168-.555-.168h-6c-1.304,0-2.415-.836-2.828-2h4.828c2.757,0,5-2.243,5-5v-6h1c1.654,0,3,1.346,3,3v12.854Z"/>
</svg>
''';

const String _inicioFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
<path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/>
<path d="M362.667,383.841v128H448c35.346,0,64-28.654,64-64V253.26c0.005-11.083-4.302-21.733-12.011-29.696l-181.29-195.99c-31.988-34.61-85.976-36.735-120.586-4.747c-1.644,1.52-3.228,3.103-4.747,4.747L12.395,223.5C4.453,231.496-0.003,242.31,0,253.58v194.261c0,35.346,28.654,64,64,64h85.333v-128c0.399-58.172,47.366-105.676,104.073-107.044C312.01,275.383,362.22,323.696,362.667,383.841z"/>
</svg>
''';

const String _inicioOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069ZM15,22.007H9V18.073a3,3,0,0,1,6,0Zm7-1a1,1,0,0,1-1,1H17V18.073a5,5,0,0,0-10,0v3.934H3a1,1,0,0,1-1-1V11.19a1.008,1.008,0,0,1,.293-.707L9.878,2.9a3.008,3.008,0,0,1,4.244,0l7.585,7.586A1.008,1.008,0,0,1,22,11.19Z"/>
</svg>
''';

const String _lojasFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.962,7.725l-1.172-4.099c-.61-2.135-2.588-3.626-4.808-3.626h-.982V4c-.006,1.308-1.995,1.307-2,0V0h-6V4c-.006,1.308-1.994,1.307-2,0V0h-.983C3.797,0,1.82,1.491,1.209,3.626L.039,7.725c-.161,1.066,.314,2.138,.961,2.893v9.382c0,2.206,1.794,4,4,4h6c2.206,0,4-1.794,4-4V11.444c.378-.221,.714-.498,1-.826,.734,.84,1.799,1.382,3,1.382h1c.347,0,.678-.058,1-.142v11.142c.006,1.308,1.995,1.307,2,0V10.618c.648-.754,1.122-1.826,.962-2.893Zm-10.962,9.275H3v-5.142c.322,.084,.653,.142,1,.142h1c1.2,0,2.266-.542,3-1.382,.734,.84,1.8,1.382,3,1.382h2v5Z"/>
</svg>
''';

const String _lojasOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M24,8c0-.093-.013-.186-.038-.275l-1.172-4.099c-.61-2.135-2.588-3.626-4.808-3.626H6.017C3.797,0,1.82,1.491,1.209,3.626L.039,7.725c-.025,.089-.039,.182-.039,.275,0,1.012,.378,1.937,1,2.643v9.357c0,2.206,1.794,4,4,4h6c2.206,0,4-1.794,4-4V11.463c.376-.218,.714-.496,1-.82,.733,.832,1.806,1.357,3,1.357h1c.345,0,.68-.044,1-.127v11.127c0,.552,.447,1,1,1s1-.448,1-1V10.643c.622-.705,1-1.631,1-2.643Zm-13,14H5c-1.103,0-2-.897-2-2v-2H13v2c0,1.103-.897,2-2,2Zm2-6H3v-4.127c.32,.083,.655,.127,1,.127h1c1.194,0,2.266-.526,3-1.357,.734,.832,1.806,1.357,3,1.357h2v4Zm6-6c-1.103,0-2-.897-2-2,0-.552-.447-1-1-1s-1,.448-1,1c0,1.103-.897,2-2,2h-2c-1.103,0-2-.897-2-2,0-.552-.448-1-1-1s-1,.448-1,1c0,1.103-.897,2-2,2h-1c-.49,0-.94-.178-1.288-.471-.029-.029-.059-.056-.091-.082-.354-.337-.585-.802-.617-1.32l1.128-3.951c.366-1.281,1.552-2.176,2.885-2.176h.983v2c0,.552,.448,1,1,1s1-.448,1-1V2h6v2c0,.552,.447,1,1,1s1-.448,1-1V2h.982c1.332,0,2.519,.895,2.885,2.176l1.129,3.951c-.065,1.044-.936,1.874-1.996,1.874h-1Z"/>
</svg>
''';

const String _carrinhoFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.297,9.034c-.57-.657-1.396-1.034-2.267-1.034h-.086C20.445,3.506,16.625,0,12,0S3.555,3.506,3.056,8h-.056c-.87,0-1.695,.377-2.266,1.034S-.093,10.562,.03,11.425l1.061,7.424c.42,2.937,2.974,5.151,5.94,5.151h9.969c2.966,0,5.52-2.215,5.94-5.151l1.061-7.424c.123-.862-.134-1.733-.704-2.391ZM12,2c3.52,0,6.441,2.613,6.928,6H5.072c.487-3.387,3.408-6,6.928-6Zm-4,17c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1v6Zm5,0c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1v6Zm5,0c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1v6Z"/>
</svg>
''';

const String _carrinhoOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.297,9.034c-.57-.657-1.396-1.034-2.267-1.034h-.086C20.445,3.506,16.625,0,12,0S3.555,3.506,3.056,8h-.056c-.87,0-1.695,.377-2.266,1.034S-.093,10.562,.03,11.425l1.061,7.424c.42,2.937,2.974,5.151,5.94,5.151h9.969c2.966,0,5.52-2.215,5.94-5.151l1.061-7.424c.123-.862-.134-1.733-.704-2.391ZM12,2c3.52,0,6.441,2.613,6.928,6H5.072c.487-3.387,3.408-6,6.928-6Zm10.021,9.142l-1.061,7.424c-.28,1.958-1.982,3.435-3.96,3.435H7.031c-1.979,0-3.681-1.477-3.96-3.435l-1.061-7.424c-.042-.291,.042-.574,.234-.797,.193-.223,.461-.345,.755-.345H21.03c.294,0,.562,.122,.756,.345,.192,.223,.276,.506,.234,.797Zm-9.021,1.858v6c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1Zm5,0v6c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1Zm-10,0v6c0,.553-.447,1-1,1s-1-.447-1-1v-6c0-.553,.447-1,1-1s1,.447,1,1Z"/>
</svg>
''';

const String _pesquisaFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M14,0C6.665-.189,1.6,8.253,5.139,14.618L.879,18.879a3,3,0,0,0,4.242,4.242l4.261-4.26C15.748,22.4,24.189,17.336,24,10A10.011,10.011,0,0,0,14,0Zm0,17C4.749,16.7,4.751,3.294,14,3a1,1,0,0,1,0,2c-6.607.21-6.607,9.791,0,10a5.006,5.006,0,0,0,5-5,1,1,0,0,1,2,0A7.009,7.009,0,0,1,14,17Z"/>
</svg>
''';

const String _pesquisaOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M14,0C6.664-.19,1.6,8.253,5.139,14.619L.878,18.879a3,3,0,1,0,4.243,4.243l4.26-4.261C15.748,22.4,24.189,17.336,24,10A10.013,10.013,0,0,0,14,0ZM3.707,21.708a1,1,0,0,1-1.415-1.414l3.969-3.97a10.12,10.12,0,0,0,1.415,1.415ZM14,18a8.009,8.009,0,0,1-8-8C6.375-.589,21.626-.586,22,10A8.01,8.01,0,0,1,14,18Zm6-8c-.251,7.93-11.75,7.928-12,0a6.007,6.007,0,0,1,6-6,1,1,0,0,1,0,2,4,4,0,0,0-4,4c.138,5.275,7.863,5.274,8,0A1,1,0,0,1,20,10Z"/>
</svg>
''';

const String _agendaFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M0,8v-1C0,4.243,2.243,2,5,2h1V1c0-.552,.447-1,1-1s1,.448,1,1v1h8V1c0-.552,.447-1,1-1s1,.448,1,1v1h1c2.757,0,5,2.243,5,5v1H0Zm24,2v9c0,2.757-2.243,5-5,5H5c-2.757,0-5-2.243-5-5V10H24Zm-12,9c0-.552-.447-1-1-1H6c-.553,0-1,.448-1,1s.447,1,1,1h5c.553,0,1-.448,1-1Zm7-4c0-.552-.447-1-1-1H6c-.553,0-1,.448-1,1s.447,1,1,1h12c.553,0,1-.448,1-1Z"/>
</svg>
''';

const String _agendaOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,12.5c0,.829-.672,1.5-1.5,1.5H7.5c-.828,0-1.5-.671-1.5-1.5s.672-1.5,1.5-1.5h9c.828,0,1.5,.671,1.5,1.5Zm-6.5,3.5H7.5c-.828,0-1.5,.671-1.5,1.5s.672,1.5,1.5,1.5h4c.828,0,1.5-.671,1.5-1.5s-.672-1.5-1.5-1.5ZM24,7.5v11c0,3.033-2.468,5.5-5.5,5.5H5.5c-3.032,0-5.5-2.467-5.5-5.5V7.5C0,4.467,2.468,2,5.5,2h.5v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h6v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h.5c3.032,0,5.5,2.467,5.5,5.5Zm-3,11V9H3v9.5c0,1.378,1.121,2.5,2.5,2.5h13c1.379,0,2.5-1.122,2.5-2.5Z"/>
</svg>
''';

const String _noticiasOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m18.5,0h-3c-3.033,0-5.5,2.467-5.5,5.5v13c0,3.033,2.467,5.5,5.5,5.5h3c3.033,0,5.5-2.467,5.5-5.5V5.5c0-3.033-2.467-5.5-5.5-5.5Zm2.5,18.5c0,1.378-1.122,2.5-2.5,2.5h-3c-1.378,0-2.5-1.122-2.5-2.5V5.5c0-1.378,1.122-2.5,2.5-2.5h3c1.378,0,2.5,1.122,2.5,2.5v13ZM8,4.5v15c0,.829-.671,1.5-1.5,1.5s-1.5-.671-1.5-1.5V4.5c0-.829.671-1.5,1.5-1.5s1.5.671,1.5,1.5Zm-5,3v9c0,.829-.671,1.5-1.5,1.5s-1.5-.671-1.5-1.5V7.5c0-.829.671-1.5,1.5-1.5s1.5.671,1.5,1.5Z"/>
</svg>
''';


const String _maisOpcoesSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm0,22c-5.514,0-10-4.486-10-10S6.486,2,12,2s10,4.486,10,10-4.486,10-10,10Zm-4-10c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm11,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Zm-5.5,0c0,.828-.672,1.5-1.5,1.5s-1.5-.672-1.5-1.5.672-1.5,1.5-1.5,1.5.672,1.5,1.5Z"/>
</svg>
''';

// Ir para hoje — Filled
const String _hojeFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M0,8v-1C0,4.243,2.243,2,5,2h1V1c0-.552,.447-1,1-1s1,.448,1,1v1h8V1c0-.552,.447-1,1-1s1,.448,1,1v1h1c2.757,0,5,2.243,5,5v1H0Zm24,2v9c0,2.757-2.243,5-5,5H5c-2.757,0-5-2.243-5-5V10H24Zm-6.168,3.152c-.384-.397-1.016-.409-1.414-.026l-4.754,4.582c-.376,.376-1.007,.404-1.439-.026l-2.278-2.117c-.403-.375-1.035-.354-1.413,.052-.376,.404-.353,1.037,.052,1.413l2.252,2.092c.566,.567,1.32,.879,2.121,.879s1.556-.312,2.108-.866l4.74-4.568c.397-.383,.409-1.017,.025-1.414Z"/>
</svg>
''';

// Ir para hoje — Outline
const String _hojeOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18.5,2h-.5v-.5c0-.829-.672-1.5-1.5-1.5s-1.5,.671-1.5,1.5v.5h-6v-.5c0-.829-.672-1.5-1.5-1.5s-1.5,.671-1.5,1.5v.5h-.5C2.468,2,0,4.467,0,7.5v11c0,3.033,2.468,5.5,5.5,5.5h13c3.032,0,5.5-2.467,5.5-5.5V7.5c0-3.033-2.468-5.5-5.5-5.5Zm0,19H5.5c-1.379,0-2.5-1.122-2.5-2.5V9H21v9.5c0,1.378-1.121,2.5-2.5,2.5Zm-.655-9.026c.566,.604,.535,1.554-.069,2.12l-4.176,3.914c-.626,.627-1.505,.992-2.439,.992s-1.814-.364-2.476-1.026l-2.478-2.396c-.596-.576-.611-1.525-.035-2.121,.576-.594,1.526-.61,2.121-.035l2.496,2.414c.146,.145,.294,.164,.371,.164s.226-.019,.354-.146l4.211-3.948c.604-.567,1.552-.536,2.12,.068Z"/>
</svg>
''';

const String _agendaVaziaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m15.561,13.561l-1.439,1.439,1.439,1.439c.586.586.586,1.535,0,2.121-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439l-1.439-1.439-1.439,1.439c-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439c-.586-.586-.586-1.535,0-2.121l1.439-1.439-1.439-1.439c-.586-.586-.586-1.535,0-2.121s1.535-.586,2.121,0l1.439,1.439,1.439-1.439c.586-.586,1.535-.586,2.121,0s.586,1.535,0,2.121Zm8.439-6.061v11c0,3.032-2.467,5.5-5.5,5.5H5.5c-3.033,0-5.5-2.468-5.5-5.5V7.5C0,4.468,2.467,2,5.5,2h.5v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h6v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h.5c3.033,0,5.5,2.468,5.5,5.5Zm-3,11v-9.5H3v9.5c0,1.379,1.122,2.5,2.5,2.5h13c1.378,0,2.5-1.121,2.5-2.5Z"/>
</svg>
''';

// ─────────────────────────────────────────────
// CORES
// ─────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE0E0E0);
  static const navBg = Color(0xFFFFFFFF);
  static const navUnselected = Color(0xFF8E8E8E);
  static const navSelected = Color(0xFF000000);
  static const pillLight = Color(0xFF3A3A3A);
  static const pillLightIcon = Color(0xFFFFFFFF);

  static const darkBackground = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF272727);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider = Color(0xFF2C2C2C);
  static const darkNavBg = Color(0xFF0D0D0D);
  static const darkNavUnselected = Color(0xFF8E8E8E);
  static const darkNavSelected = Color(0xFFFFFFFF);
  static const darkDrawerBg = Color(0xFF262626);
  static const pillDark = Color(0xFFE0E0E0);
  static const pillDarkIcon = Color(0xFF0D0D0D);
}

// ─────────────────────────────────────────────
// NOTIFIER DE TEMA
// ─────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    final pillColor = isDark ? AppColors.pillDark : AppColors.pillLight;
    final pillIconColor = isDark ? AppColors.pillDarkIcon : AppColors.pillLightIcon;
    final unselectedColor = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final labelSelectedColor = isDark ? AppColors.darkNavSelected : AppColors.navSelected;

    final navBarTheme = NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkNavBg : AppColors.navBg,
      indicatorColor: pillColor,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: pillIconColor, size: 24);
        }
        return IconThemeData(color: unselectedColor, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(color: labelSelectedColor, fontWeight: FontWeight.w700, fontSize: 11);
        }
        return TextStyle(color: unselectedColor, fontWeight: FontWeight.w400, fontSize: 11);
      }),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    );

    return MaterialApp(
      title: 'NovaSignal',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.navSelected,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        navigationBarTheme: navBarTheme,
        dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkNavSelected,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        navigationBarTheme: navBarTheme,
        dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.darkDivider),
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER SVG
// ─────────────────────────────────────────────
Widget _svg(String data, Color color, {double size = 24}) => SvgPicture.string(
      data,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );

// ─────────────────────────────────────────────
// ÍCONE DRAWER — 2 linhas, a de baixo mais curta
// ─────────────────────────────────────────────
class _DrawerIcon extends StatelessWidget {
  final Color color;
  const _DrawerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 22, height: 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 5),
        Container(width: 14, height: 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SHELL PRINCIPAL
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();
  static const _titles = ['Início', 'Carrinho', 'Pesquisa', 'Lojas'];

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final navUnselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    // Bottom bar: branco 100% no claro, fundo escuro no dark
    final navBgColor = isDark ? AppColors.darkBackground : Colors.white;

    final pages = [
      const InicioPage(),
      const CarrinhoPage(),
      const PesquisaPage(),
      const LojasPage(),
    ];

    // Tamanho dos ícones: 10% menor que 24 = ~21.6
    const double iconSize = 21.6;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: _AppDrawer(isDark: isDark),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: _DrawerIcon(color: textPrimary),
          onPressed: _openDrawer,
        ),
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: dividerColor),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 450),
            backgroundColor: navBgColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64,
            indicatorColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon: _svg(_inicioOutlineSvg, navUnselected, size: iconSize),
                selectedIcon: _svg(_inicioFilledSvg, textPrimary, size: iconSize),
                label: 'Início',
              ),
              NavigationDestination(
                icon: _svg(_carrinhoOutlineSvg, navUnselected, size: iconSize),
                selectedIcon: _svg(_carrinhoFilledSvg, textPrimary, size: iconSize),
                label: 'Carrinho',
              ),
              NavigationDestination(
                icon: _svg(_pesquisaOutlineSvg, navUnselected, size: iconSize),
                selectedIcon: _svg(_pesquisaFilledSvg, textPrimary, size: iconSize),
                label: 'Pesquisa',
              ),
              NavigationDestination(
                icon: _svg(_lojasOutlineSvg, navUnselected, size: iconSize),
                selectedIcon: _svg(_lojasFilledSvg, textPrimary, size: iconSize),
                label: 'Lojas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTÕES DA APPBAR DA AGENDA
// ─────────────────────────────────────────────
class _AgendaAppBarActions extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  const _AgendaAppBarActions({required this.isDark, required this.textPrimary});

  void _showPopup(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // 5% mais escuro que darkSurface/background
    final surfaceBg = isDark ? const Color(0xFF222222) : const Color(0xFFF2F2F2);
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    await showMenu<String>(
      context: context,
      position: position,
      color: surfaceBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      popUpAnimationStyle: AnimationStyle(
        curve: Curves.easeOutQuart,
        duration: const Duration(milliseconds: 300),
        reverseCurve: Curves.easeInQuart,
        reverseDuration: const Duration(milliseconds: 200),
      ),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'novo',
          child: Row(children: [
            Icon(Icons.add_rounded, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Novo evento', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'filtrar',
          child: Row(children: [
            Icon(Icons.filter_list_rounded, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Filtrar', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'semana',
          child: Row(children: [
            Icon(Icons.view_week_outlined, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text('Ver semana', style: TextStyle(color: textColor, fontSize: 15)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'definicoes',
          child: Row(children: [
            Icon(Icons.settings_outlined, color: textSecondary, size: 20),
            const SizedBox(width: 12),
            Text('Definições', style: TextStyle(color: textSecondary, fontSize: 15)),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão ir para hoje
        IconButton(
          icon: _svg(_hojeOutlineSvg, textPrimary, size: 22),
          onPressed: () {
            // navegar para hoje — a AgendaPage trata via GlobalKey se necessário
          },
        ),
        // Botão popup menu
        Builder(
          builder: (ctx) => IconButton(
            icon: _svg(_maisOpcoesSvg, textPrimary, size: 22),
            onPressed: () => _showPopup(ctx),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER
// ─────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  final bool isDark;
  const _AppDrawer({required this.isDark});
  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkDrawerBg : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceBg = isDark ? const Color(0xFF323232) : const Color(0xFFF5F5F5);
    final toggleBg = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Agenda
            ListTile(
              leading: _svg(_agendaOutlineSvg, textSecondary, size: 22),
              title: Text('Agenda', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaPage()));
              },
            ),
            // Notícias
            ListTile(
              leading: _svg(_noticiasOutlineSvg, textSecondary, size: 22),
              title: Text('Notícias', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            Divider(height: 1, color: divider),
            // Fundo: switch + utilizador lado a lado
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  // Container do utilizador — circular
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: surfaceBg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _svg(_utilizadorSvg, textSecondary, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Switch do tema — mais curto (Expanded)
                  Expanded(
                    child: GestureDetector(
                      onTap: themeNotifier.toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: toggleBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                              color: textPrimary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isDark ? 'Tema claro' : 'Tema escuro',
                                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? textPrimary : const Color(0xFFD0D0D0),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.darkDrawerBg : AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: INÍCIO
// ─────────────────────────────────────────────
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: CARRINHO
// ─────────────────────────────────────────────
class CarrinhoPage extends StatelessWidget {
  const CarrinhoPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: PESQUISA
// ─────────────────────────────────────────────
class PesquisaPage extends StatelessWidget {
  const PesquisaPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: LOJAS
// ─────────────────────────────────────────────
class LojasPage extends StatelessWidget {
  const LojasPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: NOTÍCIAS (acessível via drawer)
// ─────────────────────────────────────────────
class NoticiasFeedPage extends StatelessWidget {
  const NoticiasFeedPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

const String _arrowLeftSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240">
<path d="M35 160 l-39 -40 41 -42 c47 -47 73 -45 28 2 l-29 30 102 0 c61 0 102 4 102 10 0 6 -41 10 -102 10 l-102 0 27 28 c15 15 27 31 27 35 0 16 -18 5 -55 -33z"/>
</svg>
''';

const String _utilizadorSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
<path d="M2340 4984 c-488 -59 -876 -209 -1240 -480 -132 -98 -383 -348 -479 -477 -243 -326 -393 -676 -463 -1082 -30 -176 -33 -570 -5 -740 69 -420 219 -778 463 -1105 98 -131 348 -382 476 -478 280 -210 586 -352 923 -432 198 -46 290 -55 555 -54 229 1 270 3 400 27 395 71 736 219 1059 459 122 91 375 344 469 470 249 333 398 687 469 1113 25 156 25 554 0 710 -71 426 -220 780 -469 1113 -94 126 -347 379 -469 470 -324 241 -668 390 -1059 459 -121 21 -182 26 -370 28 -124 2 -241 1 -260 -1z m400 -325 c741 -67 1380 -505 1710 -1171 164 -331 240 -720 212 -1076 -43 -530 -260 -996 -633 -1359 -172 -167 -326 -276 -541 -383 -583 -289 -1267 -289 -1853 -1 -341 168 -619 412 -832 729 -141 210 -256 488 -308 745 -92 455 -30 931 175 1345 135 273 307 490 545 692 411 348 986 529 1525 479z M2473 3859 c-293 -29 -558 -230 -664 -503 -179 -463 75 -961 556 -1087 59 -15 111 -21 195 -21 570 0 957 563 755 1097 -127 339 -475 551 -842 514z M2029 2054 c-166 -30 -360 -118 -495 -225 -127 -101 -276 -284 -293 -361 -15 -69 5 -115 82 -190 244 -239 577 -409 924 -474 122 -22 390 -30 522 -14 379 44 754 221 1025 485 80 78 100 123 85 193 -18 82 -186 284 -318 381 -136 101 -314 177 -479 206 -117 21 -939 20 -1053 -1z"/>
</svg>
''';


// ─────────────────────────────────────────────
// PÁGINA: AGENDA
// ─────────────────────────────────────────────
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  late AnimationController _springCtrl;
  late Animation<double> _springScaleX;

  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  bool _expanded = false;

  static const List<String> _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  List<List<DateTime?>> get _allWeeks {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
    final cells = ((offset + daysInMonth) / 7).ceil() * 7;
    final allDays = List.generate(cells, (i) {
      final d = i - offset + 1;
      if (d < 1 || d > daysInMonth) return null;
      return DateTime(_selectedDate.year, _selectedDate.month, d);
    });
    return List.generate(allDays.length ~/ 7, (r) => allDays.sublist(r * 7, r * 7 + 7));
  }

  int get _selectedWeekIndex {
    final weeks = _allWeeks;
    for (int r = 0; r < weeks.length; r++) {
      if (weeks[r].any((d) => d != null && _isSameDay(d!, _selectedDate))) return r;
    }
    return 0;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _springScaleX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.88).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 35),
    ]).animate(_springCtrl);

    _expandCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  void _selectDate(DateTime date) {
    if (_isSameDay(date, _selectedDate)) return;
    setState(() => _selectedDate = date);
    _springCtrl.forward(from: 0);
    if (_expanded) {
      _expandCtrl.reverse().then((_) => setState(() => _expanded = false));
    }
  }

  void _toggleExpand() {
    if (_expanded) {
      _expandCtrl.reverse().then((_) => setState(() => _expanded = false));
    } else {
      setState(() => _expanded = true);
      _expandCtrl.forward();
    }
  }

  Widget _buildDayCell(DateTime? date, {bool showLabel = false, int labelIndex = 0,
      required Color textPrimary, required Color textSecondary, required bool isDark}) {
    final isSelected = date != null && _isSameDay(date, _selectedDate);

    return GestureDetector(
      onTap: date != null ? () => _selectDate(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showLabel ? _dayLabels[labelIndex] : '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.darkBackground : AppColors.background)
                    : textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _springScaleX,
              builder: (ctx, child) => Transform.scale(
                scaleX: isSelected ? _springScaleX.value : 1.0,
                child: child,
              ),
              child: Text(
                date != null ? '${date.day}' : '',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? AppColors.darkBackground : AppColors.background)
                      : textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final allWeeks = _allWeeks;
    final selectedWeek = allWeeks[_selectedWeekIndex];

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
          icon: _svg(_arrowLeftSvg, textPrimary, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Agenda',
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [_AgendaAppBarActions(isDark: isDark, textPrimary: textPrimary)],
      ),
      body: Column(
        children: [
          GestureDetector(
            onVerticalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v > 80 && !_expanded) _toggleExpand();
              if (v < -80 && _expanded) _toggleExpand();
            },
            child: Container(
              color: bg,
              child: Column(
                children: [
                  // Strip semanal
                  if (!_expanded || _expandCtrl.value < 1.0)
                    SizeTransition(
                      sizeFactor: Tween(begin: 1.0, end: 0.0).animate(_expandAnim),
                      axisAlignment: -1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) => _buildDayCell(
                            selectedWeek[i],
                            showLabel: true,
                            labelIndex: i,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            isDark: isDark,
                          )),
                        ),
                      ),
                    ),

                  // Calendário completo expandido
                  SizeTransition(
                    sizeFactor: _expandAnim,
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Column(
                        children: List.generate(allWeeks.length, (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (i) => _buildDayCell(
                              allWeeks[r][i],
                              showLabel: r == 0,
                              labelIndex: i,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              isDark: isDark,
                            )),
                          ),
                        )),
                      ),
                    ),
                  ),

                  Divider(height: 1, color: divider),
                ],
              ),
            ),
          ),

          // Estado vazio
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: _svg(_agendaVaziaSvg, const Color(0xFFFF3B30), size: 38)),
                  ),
                  const SizedBox(height: 18),
                  Text('Sem nada agendado',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 6),
                  Text('Não há eventos para este dia.',
                      style: TextStyle(fontSize: 14, color: textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}