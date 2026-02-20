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
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512.001 512.001">
<path d="M490.134,185.472L338.966,34.304c-45.855-45.737-120.076-45.737-165.931,0L21.867,185.472C7.819,199.445-0.055,218.457,0,238.272v221.397C0.047,488.568,23.475,511.976,52.374,512h407.253c28.899-0.023,52.326-23.432,52.373-52.331V238.272C512.056,218.457,504.182,199.445,490.134,185.472z M448,448H341.334v-67.883c0-44.984-36.467-81.451-81.451-81.451h-7.765c-44.984,0-81.451,36.467-81.451,81.451V448H64V238.272c0.007-2.829,1.125-5.541,3.115-7.552L218.283,79.552c20.825-20.831,54.594-20.835,75.425-0.01c0.003,0.003,0.007,0.007,0.01,0.01L444.886,230.72c1.989,2.011,3.108,4.723,3.115,7.552V448z"/>
</svg>
''';

const String _utilizadorFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m12,12c-3.309,0-6-2.691-6-6S8.691,0,12,0s6,2.691,6,6-2.691,6-6,6Zm0,2c-5.103,0-9.375,3.822-9.936,8.89-.031.283.06.565.249.777.19.212.461.333.745.333h2.941c0-3.309,2.691-6,6-6s6,2.691,6,6h2.941c.284,0,.555-.121.745-.333.189-.212.28-.494.249-.777-.561-5.068-4.833-8.89-9.936-8.89Zm0,6c-2.206,0-4,1.794-4,4h8c0-2.206-1.794-4-4-4Z"/>
</svg>
''';

const String _utilizadorOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m12,12c3.309,0,6-2.691,6-6S15.309,0,12,0s-6,2.691-6,6,2.691,6,6,6Zm0-9c1.654,0,3,1.346,3,3s-1.346,3-3,3-3-1.346-3-3,1.346-3,3-3Zm4.934,19.286c.119.82-.357,1.714-1.486,1.714-.733,0-1.375-.539-1.482-1.286-.142-.978-.986-1.714-1.965-1.714s-1.824.737-1.965,1.714c-.118.82-.878,1.389-1.699,1.27-.82-.118-1.389-.879-1.27-1.699.353-2.443,2.474-4.286,4.934-4.286s4.582,1.842,4.934,4.286Zm5.038.127c.048.827-.583,1.537-1.41,1.585-.03.001-.06.002-.089.002-.789,0-1.45-.615-1.496-1.413-.215-3.694-3.28-6.587-6.977-6.587s-6.762,2.894-6.977,6.587c-.048.827-.76,1.453-1.585,1.41-.827-.048-1.458-.758-1.41-1.585.308-5.278,4.688-9.413,9.972-9.413s9.664,4.134,9.972,9.413Z"/>
</svg>
''';

const String _feedFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m19,24h-4c-2.757,0-5-2.243-5-5V5c0-2.757,2.243-5,5-5h4c2.757,0,5,2.243,5,5v14c0,2.757-2.243,5-5,5Zm-12-3V4c0-.552-.448-1-1-1s-1,.448-1,1v17c0,.552.448,1,1,1s1-.448,1-1Zm-5-3V7c0-.552-.448-1-1-1s-1,.448-1,1v11c0,.552.448,1,1,1s1-.448,1-1Z"/>
</svg>
''';

const String _feedOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m18.5,0h-3c-3.033,0-5.5,2.467-5.5,5.5v13c0,3.033,2.467,5.5,5.5,5.5h3c3.033,0,5.5-2.467,5.5-5.5V5.5c0-3.033-2.467-5.5-5.5-5.5Zm2.5,18.5c0,1.378-1.122,2.5-2.5,2.5h-3c-1.378,0-2.5-1.122-2.5-2.5V5.5c0-1.378,1.122-2.5,2.5-2.5h3c1.378,0,2.5,1.122,2.5,2.5v13ZM8,4.5v15c0,.829-.671,1.5-1.5,1.5s-1.5-.671-1.5-1.5V4.5c0-.829.671-1.5,1.5-1.5s1.5.671,1.5,1.5Zm-5,3v9c0,.829-.671,1.5-1.5,1.5s-1.5-.671-1.5-1.5V7.5c0-.829.671-1.5,1.5-1.5s1.5.671,1.5,1.5Z"/>
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

// Três pontos circular (popup menu)
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
  static const _titles = ['Início', 'Agenda', 'Notícias', 'Utilizador'];

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

    // Bottom bar: 3% mais escuro que o fundo
    final navBgColor = isDark
        ? Color.lerp(AppColors.darkBackground, Colors.black, 0.03)!
        : Color.lerp(AppColors.background, Colors.black, 0.03)!;

    final pages = [
      const InicioPage(),
      const AgendaPage(),
      const NoticiasFeedPage(),
      const UtilizadorPage(),
    ];

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
        actions: _selectedIndex == 1
            ? [_AgendaAppBarActions(isDark: isDark, textPrimary: textPrimary)]
            : null,
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
          // Linha de separação fina
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
            height: 64, // padrão ~80px, reduzido ~20%
            // Sem pill — indicatorColor transparente
            indicatorColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon: _svg(_inicioOutlineSvg, navUnselected),
                selectedIcon: _svg(_inicioFilledSvg, textPrimary),
                label: 'Início',
              ),
              NavigationDestination(
                icon: _svg(_agendaOutlineSvg, navUnselected),
                selectedIcon: _svg(_agendaFilledSvg, textPrimary),
                label: 'Agenda',
              ),
              NavigationDestination(
                icon: _svg(_feedOutlineSvg, navUnselected),
                selectedIcon: _svg(_feedFilledSvg, textPrimary),
                label: 'Notícias',
              ),
              NavigationDestination(
                icon: _svg(_utilizadorOutlineSvg, navUnselected),
                selectedIcon: _svg(_utilizadorFilledSvg, textPrimary),
                label: 'Utilizador',
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

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: surfaceBg,
                    child: Icon(Icons.person_outline_rounded, size: 28, color: textSecondary),
                  ),
                  const SizedBox(width: 14),
                  Text('Utilizador',
                      style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: themeNotifier.toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: toggleBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        color: textPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        isDark ? 'Tema claro' : 'Tema escuro',
                        style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 46,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: isDark ? textPrimary : const Color(0xFFD0D0D0),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            width: 20,
                            height: 20,
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
            const SizedBox(height: 8),
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
// PÁGINA: NOTÍCIAS
// ─────────────────────────────────────────────
class NoticiasFeedPage extends StatelessWidget {
  const NoticiasFeedPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: UTILIZADOR
// ─────────────────────────────────────────────
class UtilizadorPage extends StatelessWidget {
  const UtilizadorPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

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

  // Todas as semanas do mês da data seleccionada
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

  // Índice da semana que contém a data seleccionada
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
    final isToday = date != null &&
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

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
            // Label do dia — visível sempre no calendário completo, escondido no strip via opacity
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
                      : isToday ? textPrimary : textPrimary,
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
    final selectedWeekIdx = _selectedWeekIndex;
    final selectedWeek = allWeeks[selectedWeekIdx];

    return Column(
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
                // ── Quando NÃO expandido: strip semanal original com labels
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

                // ── Quando expandido: calendário completo com todas as semanas
                SizeTransition(
                  sizeFactor: _expandAnim,
                  axisAlignment: -1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: Column(
                      children: List.generate(allWeeks.length, (r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (i) => _buildDayCell(
                              allWeeks[r][i],
                              showLabel: r == 0, // labels só na primeira linha
                              labelIndex: i,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              isDark: isDark,
                            )),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                Divider(height: 1, color: divider),
              ],
            ),
          ),
        ),

        // ── Conteúdo vazio
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
    );
  }
}