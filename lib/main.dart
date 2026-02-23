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
// SVGs INLINE
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

// Ícone de "Criar" (outline) — fornecido pelo utilizador
const _criarOutline = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m15,13c0,.553-.447,1-1,1s-1-.447-1-1v-2h-2c-.553,0-1-.447-1-1s.447-1,1-1h2v-2c0-.553.447-1,1-1s1,.447,1,1v2h2c.553,0,1,.447,1,1s-.447,1-1,1h-2v2Zm9-8v8.373c0,1.053-.427,2.084-1.172,2.828l-2.627,2.627c-.744.745-1.775,1.172-2.828,1.172h-8.373c-2.757,0-5-2.243-5-5V5C4,2.243,6.243,0,9,0h10c2.757,0,5,2.243,5,5Zm-15,13h8v-3c0-1.105.895-2,2-2h3V5c0-1.654-1.346-3-3-3h-10c-1.654,0-3,1.346-3,3v10c0,1.654,1.346,3,3,3Zm8,4H5c-1.654,0-3-1.346-3-3V7c0-.553-.447-1-1-1s-1,.447-1,1v12c0,2.757,2.243,5,5,5h12c.553,0,1-.447,1-1s-.447-1-1-1Z"/>
</svg>
''';

// Ícone de "Criar" (filled) — fornecido pelo utilizador
const _criarFilled = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m17,24H5c-2.757,0-5-2.243-5-5V7c0-.553.447-1,1-1s1,.447,1,1v12c0,1.654,1.346,3,3,3h12c.553,0,1,.447,1,1s-.447,1-1,1Zm0-4h-8c-2.757,0-5-2.243-5-5V5C4,2.243,6.243,0,9,0h10c2.757,0,5,2.243,5,5v8h-4c-1.654,0-3,1.346-3,3v4Zm-2-7v-2h2c.553,0,1-.447,1-1s-.447-1-1-1h-2v-2c0-.553-.447-1-1-1s-1,.447-1,1v2h-2c-.553,0-1,.447-1,1s.447,1,1,1h2v2c0,.553.447,1,1,1s1-.447,1-1Zm5,2c-.552,0-1,.448-1,1v3.642c.443-.198.855-.467,1.201-.814l2.627-2.627c.346-.346.616-.758.814-1.201h-3.642Z"/>
</svg>
''';

// Ícone Sol (tema claro) — fornecido pelo utilizador
const _sunSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M12,17c-2.76,0-5-2.24-5-5s2.24-5,5-5,5,2.24,5,5-2.24,5-5,5Zm1-13V1c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1Zm0,19v-3c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1ZM5,12c0-.55-.45-1-1-1H1c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1Zm19,0c0-.55-.45-1-1-1h-3c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1ZM6.71,6.71c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm14,14c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm-16,0l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29ZM18.71,6.71l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Z"/>
</svg>
''';

// Ícone Lua (tema escuro) — fornecido pelo utilizador
const _moonSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m15,12.5c0,3.018,1.5,5.733,3.54,7.646.85.798.462,2.242-.668,2.527-1.381.348-3.09.431-4.63.187C8.396,22.091,4.565,18.053,4.061,13.173,3.378,6.571,8.539,1,15,1c1.279,0,2.861.223,4,.629,1.106.394,1.344,1.867.417,2.588C16.948,6.136,15,9.13,15,12.5Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

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
// APP ROOT
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

    // Sem pills — indicador completamente transparente
    // Ícone seleccionado: preto (claro) / branco (escuro)
    final navSelected   = isDark ? AppColors.darkNavSelected  : AppColors.navSelected;
    final navUnselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;

    final navTheme = NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkNavBg : AppColors.navBg,
      indicatorColor: Colors.transparent,   // ← sem pill
      indicatorShape: const RoundedRectangleBorder(),
      iconTheme: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return IconThemeData(color: navSelected, size: 22);
        return IconThemeData(color: navUnselected, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((s) {
        if (s.contains(WidgetState.selected))
          return GoogleFonts.syne(color: navSelected, fontWeight: FontWeight.w700, fontSize: 11);
        return GoogleFonts.syne(color: navUnselected, fontWeight: FontWeight.w400, fontSize: 11);
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
// SHELL PRINCIPAL
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _idx = 0;
  final _homeKey = GlobalKey<HomeScreenState>();

  // Animação do ícone sol/lua no popup menu
  late final AnimationController _themeIconCtrl;
  late final Animation<double> _themeIconAnim;

  static const _titles = ['Início', 'Criar'];

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _themeIconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _themeIconAnim = CurvedAnimation(parent: _themeIconCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _themeIconCtrl.dispose();
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
    if (themeNotifier.isDark) {
      _themeIconCtrl.forward();
    } else {
      _themeIconCtrl.reverse();
    }
  }

  void _reloadHome() => _homeKey.currentState?.load();

  @override
  Widget build(BuildContext context) {
    final isDark       = themeNotifier.isDark;
    final textPrimary  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final navUnsel     = isDark ? AppColors.darkNavUnselected  : AppColors.navUnselected;
    final navSel       = isDark ? AppColors.darkNavSelected    : AppColors.navSelected;
    final divColor     = isDark ? AppColors.darkDivider        : AppColors.divider;
    final navBg        = isDark ? AppColors.darkNavBg          : AppColors.navBg;
    final bg           = isDark ? AppColors.darkBackground     : AppColors.background;
    final surfBg       = isDark ? AppColors.darkSurface        : AppColors.surface;
    final textSec      = isDark ? AppColors.darkTextSecondary  : AppColors.textSecondary;

    const double iconSize = 22.0;

    final pages = <Widget>[
      HomeScreen(key: _homeKey),
      CriarScreen(onDocCreated: () {
        setState(() => _idx = 0);
        Future.delayed(const Duration(milliseconds: 300), _reloadHome);
      }),
    ];

    return Scaffold(
      backgroundColor: bg,
      // ── AppBar fixo — sem efeitos de scroll
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
          // ── Popup menu (3 pontos) com toggle de tema + transições suaves
          _ThemePopupMenu(
            isDark: isDark,
            textPrimary: textPrimary,
            textSec: textSec,
            surfBg: surfBg,
            iconAnim: _themeIconAnim,
          ),
          const SizedBox(width: 4),
        ],
      ),
      // Transição fade entre tabs
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_idx), child: pages[_idx]),
      ),
      // Bottom nav sem pills
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: divColor),
          NavigationBar(
            selectedIndex: _idx,
            onDestinationSelected: (i) => setState(() => _idx = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 350),
            backgroundColor: navBg,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64,
            indicatorColor: Colors.transparent,   // ← sem pill
            destinations: [
              NavigationDestination(
                icon:         _svg(_homeOutline, navUnsel,   size: iconSize),
                selectedIcon: _svg(_homeFilled,  navSel,     size: iconSize),
                label: 'Início',
              ),
              NavigationDestination(
                icon:         _svg(_criarOutline, navUnsel,  size: iconSize),
                selectedIcon: _svg(_criarFilled,  navSel,    size: iconSize),
                label: 'Criar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget popup menu com tema + transições suaves
// ─────────────────────────────────────────────
class _ThemePopupMenu extends StatefulWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSec;
  final Color surfBg;
  final Animation<double> iconAnim;

  const _ThemePopupMenu({
    required this.isDark,
    required this.textPrimary,
    required this.textSec,
    required this.surfBg,
    required this.iconAnim,
  });

  @override
  State<_ThemePopupMenu> createState() => _ThemePopupMenuState();
}

class _ThemePopupMenuState extends State<_ThemePopupMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDark     = widget.isDark;
    final textPrim   = widget.textPrimary;
    final textSec    = widget.textSec;
    final surfBg     = widget.surfBg;
    final acc        = accColor(isDark);

    return PopupMenuButton<String>(
      onOpened: () => setState(() => _isOpen = true),
      onCanceled: () => setState(() => _isOpen = false),
      onSelected: (v) {
        setState(() => _isOpen = false);
        if (v == 'theme') themeNotifier.toggle();
      },
      tooltip: 'Mais opções',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfBg,
      elevation: 12,
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _isOpen
              ? (isDark ? Colors.white12 : Colors.black12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Center(
          child: _ThreeDotsIcon(color: textPrim),
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'theme',
          padding: EdgeInsets.zero,
          child: _ThemeMenuItem(
            isDark: isDark,
            textPrim: textPrim,
            textSec: textSec,
            acc: acc,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Item do popup — toggle de tema com transição
// ─────────────────────────────────────────────
class _ThemeMenuItem extends StatefulWidget {
  final bool isDark;
  final Color textPrim;
  final Color textSec;
  final Color acc;
  const _ThemeMenuItem({
    required this.isDark,
    required this.textPrim,
    required this.textSec,
    required this.acc,
  });
  @override
  State<_ThemeMenuItem> createState() => _ThemeMenuItemState();
}

class _ThemeMenuItemState extends State<_ThemeMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.isDark ? 1.0 : 0.0,
    );
    _rotate = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(_ThemeMenuItem old) {
    super.didUpdateWidget(old);
    if (old.isDark != widget.isDark) {
      if (widget.isDark) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final label  = isDark ? 'Modo claro' : 'Modo escuro';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone com animação rotate + fade
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _rotate.value * 3.14159,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: isDark
                        ? SvgPicture.string(_sunSvg,
                            key: const ValueKey('sun'),
                            width: 20, height: 20,
                            colorFilter: ColorFilter.mode(
                                widget.acc, BlendMode.srcIn))
                        : SvgPicture.string(_moonSvg,
                            key: const ValueKey('moon'),
                            width: 20, height: 20,
                            colorFilter: ColorFilter.mode(
                                widget.textPrim, BlendMode.srcIn)),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                label,
                key: ValueKey(label),
                style: GoogleFonts.syne(
                  color: widget.textPrim,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Três pontinhos (ellipsis) customizado
// ─────────────────────────────────────────────
class _ThreeDotsIcon extends StatelessWidget {
  final Color color;
  const _ThreeDotsIcon({required this.color});
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <circle cx="5"  cy="12" r="2"/>
      <circle cx="12" cy="12" r="2"/>
      <circle cx="19" cy="12" r="2"/>
      </svg>''',
      width: 22, height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
