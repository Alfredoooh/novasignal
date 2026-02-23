import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/criar_screen.dart';
import 'services/document_service.dart';
import 'widgets/theme.dart';

// ─────────────────────────────────────────────
// SVGs INLINE — casa outline/filled + doc outline/filled
// ─────────────────────────────────────────────
const _homeOutline = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069ZM15,22.007H9V18.073a3,3,0,0,1,6,0Zm7-1a1,1,0,0,1-1,1H17V18.073a5,5,0,0,0-10,0v3.934H3a1,1,0,0,1-1-1V11.19a1.008,1.008,0,0,1,.293-.707L9.878,2.9a3.008,3.008,0,0,1,4.244,0l7.585,7.586A1.008,1.008,0,0,1,22,11.19Z"/>
</svg>
''';

const _homeFilled = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H9V18.073a3,3,0,0,1,6,0v5.934h6a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069Z"/>
</svg>
''';

const _docOutline = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/>
</svg>
''';

const _docFilled = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/>
</svg>
''';

const _moonSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M21.064,13.679A9.722,9.722,0,0,1,10.321,2.936,9.737,9.737,0,0,0,2,12a10,10,0,0,0,10,10,9.738,9.738,0,0,0,9.064-6.138A9.748,9.748,0,0,1,21.064,13.679Z"/>
</svg>
''';

const _sunSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M12,17a5,5,0,1,1,5-5A5.006,5.006,0,0,1,12,17ZM12,9a3,3,0,1,0,3,3A3,3,0,0,0,12,9Zm1,8.95V20a1,1,0,0,1-2,0V17.95A5.035,5.035,0,0,1,9,17.268V19a1,1,0,0,1-2,0v-1.268A5.017,5.017,0,0,1,5.268,17H4a1,1,0,0,1,0-2H5.05A5.035,5.035,0,0,1,4.732,13H3a1,1,0,0,1,0-2H4.732A5.035,5.035,0,0,1,5.05,11H4A1,1,0,0,1,4,9H5.268A5.017,5.017,0,0,1,7,7.268V6A1,1,0,0,1,9,6V7.05A5.035,5.035,0,0,1,11,6.732V5a1,1,0,0,1,2,0V6.732A5.035,5.035,0,0,1,15,7.05V6a1,1,0,0,1,2,0V7.268A5.017,5.017,0,0,1,18.732,9H20a1,1,0,0,1,0,2H18.95A5.035,5.035,0,0,1,19.268,13H21a1,1,0,0,1,0,2H19.268A5.035,5.035,0,0,1,18.95,15H20a1,1,0,0,1,0,2H18.732A5.017,5.017,0,0,1,17,18.732V20a1,1,0,0,1-2,0V18.95A5.035,5.035,0,0,1,13,19.268Z"/>
</svg>
''';

// ─────────────────────────────────────────────
// HELPER SVG — exactamente igual à referência
// ─────────────────────────────────────────────
Widget _svg(String data, Color color, {double size = 22}) =>
    SvgPicture.string(data,
        width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn));

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt', null);
  await DocumentService.instance.load();
  runApp(const AriaApp());
}

// ─────────────────────────────────────────────
// APP ROOT — StatefulWidget que escuta o ThemeNotifier
// ─────────────────────────────────────────────
class AriaApp extends StatefulWidget {
  const AriaApp({super.key});
  @override
  State<AriaApp> createState() => _AriaAppState();
}

class _AriaAppState extends State<AriaApp> {
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

    // Pill do ícone selected — igual à referência
    final pillColor    = isDark ? AppColors.pillDark     : AppColors.pillLight;
    final pillIcon     = isDark ? AppColors.pillDarkIcon  : AppColors.pillLightIcon;
    final navUnsel     = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final navSel       = isDark ? AppColors.darkNavSelected   : AppColors.navSelected;

    final navTheme = NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkNavBg : AppColors.navBg,
      indicatorColor: pillColor,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return IconThemeData(color: pillIcon, size: 22);
        return IconThemeData(color: navUnsel, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return GoogleFonts.syne(color: navSel, fontWeight: FontWeight.w700, fontSize: 11);
        return GoogleFonts.syne(color: navUnsel, fontWeight: FontWeight.w400, fontSize: 11);
      }),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    );

    final baseText = GoogleFonts.syneTextTheme();

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.acc,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseText.apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.syne(
            color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: navTheme,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 0),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accDark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: baseText.apply(bodyColor: AppColors.darkTextPrimary, displayColor: AppColors.darkTextPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.syne(
            color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: navTheme,
      dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1, space: 0),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkDivider),
        ),
      ),
    );

    return MaterialApp(
      title: 'Aria',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────
// SHELL PRINCIPAL — padrão exacto da referência
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  static const _titles = ['Início', 'Criar'];

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

  void _onTheme() => setState(() {});
  void _reloadHome() => _homeKey.currentState?.load();

  @override
  Widget build(BuildContext context) {
    final isDark       = themeNotifier.isDark;
    final textPrimary  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final navUnsel     = isDark ? AppColors.darkNavUnselected  : AppColors.navUnselected;
    final pillIcon     = isDark ? AppColors.pillDarkIcon       : AppColors.pillLightIcon;
    final divColor     = isDark ? AppColors.darkDivider        : AppColors.divider;
    final navBg        = isDark ? AppColors.darkNavBg          : AppColors.navBg;
    final bg           = isDark ? AppColors.darkBackground     : AppColors.background;

    // Ícone selected: usa pillIcon (branco/preto no interior da pill)
    const double iconSize = 21.6;

    final pages = <Widget>[
      HomeScreen(key: _homeKey),
      CriarScreen(onDocCreated: () {
        setState(() => _idx = 0);
        Future.delayed(const Duration(milliseconds: 300), _reloadHome);
      }),
    ];

    return Scaffold(
      backgroundColor: bg,
      // AppBar flat sem sombra — igual à referência
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_idx],
          style: GoogleFonts.syne(
            color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          // Toggle tema claro/escuro
          IconButton(
            icon: _svg(isDark ? _sunSvg : _moonSvg, textPrimary, size: 22),
            onPressed: themeNotifier.toggle,
            tooltip: isDark ? 'Modo claro' : 'Modo escuro',
          ),
          const SizedBox(width: 4),
        ],
      ),
      // Transição fade entre tabs — igual à referência
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_idx), child: pages[_idx]),
      ),
      // Bottom nav — estrutura EXACTA da referência
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: divColor),
          NavigationBar(
            selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 450),
            backgroundColor: navBg,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64,
            indicatorColor: Colors.transparent,
            destinations: [
              NavigationDestination(
                icon:         _svg(_homeOutline, navUnsel,   size: iconSize),
                selectedIcon: _svg(_homeFilled,  pillIcon,   size: iconSize),
                label: 'Início',
              ),
              NavigationDestination(
                icon:         _svg(_docOutline, navUnsel,  size: iconSize),
                selectedIcon: _svg(_docFilled,  pillIcon,  size: iconSize),
                label: 'Criar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
