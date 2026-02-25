import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/criar_screen.dart';
import 'screens/templates_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/agenda_screen.dart';
import 'services/document_service.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'widgets/theme.dart';

// ─── SVGs inline ───────────────────────────────────────────────────────────────

const _homeOutline = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069ZM15,22.007H9V18.073a3,3,0,0,1,6,0Zm7-1a1,1,0,0,1-1,1H17V18.073a5,5,0,0,0-10,0v3.934H3a1,1,0,0,1-1-1V11.19a1.008,1.008,0,0,1,.293-.707L9.878,2.9a3.008,3.008,0,0,1,4.244,0l7.585,7.586A1.008,1.008,0,0,1,22,11.19Z"/></svg>';
const _homeFilled  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H9V18.073a3,3,0,0,1,6,0v5.934h6a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069Z"/></svg>';

const _criarOutline = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m15,13c0,.553-.447,1-1,1s-1-.447-1-1v-2h-2c-.553,0-1-.447-1-1s.447-1,1-1h2v-2c0-.553.447-1,1-1s1,.447,1,1v2h2c.553,0,1,.447,1,1s-.447,1-1,1h-2v2Zm9-8v8.373c0,1.053-.427,2.084-1.172,2.828l-2.627,2.627c-.744.745-1.775,1.172-2.828,1.172h-8.373c-2.757,0-5-2.243-5-5V5C4,2.243,6.243,0,9,0h10c2.757,0,5,2.243,5,5Zm-15,13h8v-3c0-1.105.895-2,2-2h3V5c0-1.654-1.346-3-3-3h-10c-1.654,0-3,1.346-3,3v10c0,1.654,1.346,3,3,3Zm8,4H5c-1.654,0-3-1.346-3-3V7c0-.553-.447-1-1-1s-1,.447-1,1v12c0,2.757,2.243,5,5,5h12c.553,0,1-.447,1-1s-.447-1-1-1Z"/></svg>';
const _criarFilled  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m17,24H5c-2.757,0-5-2.243-5-5V7c0-.553.447-1,1-1s1,.447,1,1v12c0,1.654,1.346,3,3,3h12c.553,0,1,.447,1,1s-.447,1-1,1Zm0-4h-8c-2.757,0-5-2.243-5-5V5C4,2.243,6.243,0,9,0h10c2.757,0,5,2.243,5,5v8h-4c-1.654,0-3,1.346-3,3v4Zm-2-7v-2h2c.553,0,1-.447,1-1s-.447-1-1-1h-2v-2c0-.553-.447-1-1-1s-1,.447-1,1v2h-2c-.553,0-1,.447-1,1s.447,1,1,1h2v2c0,.553.447,1,1,1s1-.447,1-1Zm5,2c-.552,0-1,.448-1,1v3.642c.443-.198.855-.467,1.201-.814l2.627-2.627c.346-.346.616-.758.814-1.201h-3.642Z"/></svg>';

const _templatesOutline = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m9,0h-4C2.243,0,0,2.243,0,5v2c0,1.103.897,2,2,2h7c1.103,0,2-.897,2-2V2c0-1.103-.897-2-2-2ZM2,7v-2c0-1.654,1.346-3,3-3h4l.002,5H2Zm20,8h-7c-1.103,0-2,.897-2,2v5c0,1.103.897,2,2,2h4c2.757,0,5-2.243,5-5v-2c0-1.103-.897-2-2-2Zm0,4c0,1.654-1.346,3-3,3h-4v-5h7v2ZM19,0h-4c-1.103,0-2,.897-2,2v9c0,1.103.897,2,2,2h7c1.103,0,2-.897,2-2v-6c0-2.757-2.243-5-5-5Zm-4,11V2h4c1.654,0,3,1.346,3,3l.002,6h-7.002Zm-6,0H2c-1.103,0-2,.897-2,2v6c0,2.757,2.243,5,5,5h4c1.103,0,2-.897,2-2v-9c0-1.103-.897-2-2-2Zm-4,11c-1.654,0-3-1.346-3-3v-6h7l.002,9h-4.002Z"/></svg>';
const _templatesFilled  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m9,9H2c-1.103,0-2-.897-2-2v-2C0,2.243,2.243,0,5,0h4c1.103,0,2,.897,2,2v5c0,1.103-.897,2-2,2Zm10,15h-4c-1.103,0-2-.897-2-2v-5c0-1.103.897-2,2-2h7c1.103,0,2,.897,2,2v2c0,2.757-2.243,5-5,5Zm3-11h-7c-1.103,0-2-.897-2-2V2c0-1.103.897-2,2-2h4c2.757,0,5,2.243,5,5v6c0,1.103-.897,2-2,2Zm-13,11h-4c-2.757,0-5-2.243-5-5v-6c0-1.103.897-2,2-2h7c1.103,0,2,.897,2,2v9c0,1.103-.897,2-2,2Z"/></svg>';

const _sunSvg  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,17c-2.76,0-5-2.24-5-5s2.24-5,5-5,5,2.24,5,5-2.24,5-5,5Zm1-13V1c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1Zm0,19v-3c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1ZM5,12c0-.55-.45-1-1-1H1c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1Zm19,0c0-.55-.45-1-1-1h-3c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1ZM6.71,6.71c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm14,14c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm-16,0l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29ZM18.71,6.71l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Z"/></svg>';
const _moonSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m15,12.5c0,3.018,1.5,5.733,3.54,7.646.85.798.462,2.242-.668,2.527-1.381.348-3.09.431-4.63.187C8.396,22.091,4.565,18.053,4.061,13.173,3.378,6.571,8.539,1,15,1c1.279,0,2.861.223,4,.629,1.106.394,1.344,1.867.417,2.588C16.948,6.136,15,9.13,15,12.5Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';

// ─── SVG botões do AppBar ──────────────────────────────────────────────────────
const _historySvg  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,24C5.383,24,0,18.617,0,12S5.383,0,12,0s12,5.383,12,12-5.383,12-12,12Zm0-22C6.486,2,2,6.486,2,12s4.486,10,10,10,10-4.486,10-10S17.514,2,12,2Zm5,10c0-.553-.447-1-1-1h-3V6c0-.553-.448-1-1-1s-1,.447-1,1v6c0,.553,.448,1,1,1h4c.553,0,1-.447,1-1Z"/></svg>';
const _calendarSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,2H18V1a1,1,0,0,0-2,0V2H8V1A1,1,0,0,0,6,1V2H5A5.006,5.006,0,0,0,0,7V19a5.006,5.006,0,0,0,5,5H19a5.006,5.006,0,0,0,5-5V7A5.006,5.006,0,0,0,19,2ZM2,7A3,3,0,0,1,5,4H19a3,3,0,0,1,3,3V8H2ZM19,22H5a3,3,0,0,1-3-3V10H22v9A3,3,0,0,1,19,22Z"/><circle cx="12" cy="15" r="1.5"/><circle cx="7" cy="15" r="1.5"/><circle cx="17" cy="15" r="1.5"/></svg>';

// ─── MAIN ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt', null);
  await AuthService.instance.init();   // restaura sessão + verifica token
  await DocumentService.instance.load(); // local + merge da nuvem se logado
  runApp(const AriaApp());
}

// ─── APP ROOT ─────────────────────────────────────────────────────────────────

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

    final baseText = GoogleFonts.robotoTextTheme();

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.acc,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseText.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.roboto(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.divider, thickness: 1, space: 0),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
        elevation: 4,
        shadowColor: Colors.black26,
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
      textTheme: baseText.apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.roboto(
            color: AppColors.darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider, thickness: 1, space: 0),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Color(0xFF3A3A3A), width: 0.8),
        ),
        elevation: 4,
        shadowColor: Colors.black54,
      ),
    );

    return MaterialApp(
      title: 'Aria',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthGate(),
    );
  }
}

// ─── AUTH GATE — decide mostrar AuthScreen ou MainShell ─────────────────────────

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _authed = false; // true = mostra MainShell

  @override
  void initState() {
    super.initState();
    // Se já está logado (sessão restaurada), vai directo ao shell
    _authed = AuthService.instance.loggedIn;
  }

  void _onDone() => setState(() => _authed = true);

  @override
  Widget build(BuildContext context) {
    if (_authed) return const MainShell();
    return AuthScreen(onDone: _onDone);
  }
}

// ─── SHELL PRINCIPAL ───────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final _homeKey = GlobalKey<HomeScreenState>();
  static const _titles = ['Início', 'Criar', 'Templates'];

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

  void _openHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
  }

  void _openAgenda() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;
    final navBg       = isDark ? AppColors.darkNavBg         : AppColors.navBg;
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final surfBg      = isDark ? AppColors.darkSurface       : AppColors.surface;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final pages = <Widget>[
      HomeScreen(key: _homeKey),
      CriarScreen(onDocCreated: () {
        setState(() => _idx = 0);
        Future.delayed(const Duration(milliseconds: 300), _reloadHome);
      }),
      const TemplatesScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_idx],
          style: GoogleFonts.roboto(
              color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          // History button
          _AppBarIconBtn(
            svg: _historySvg,
            color: textPrimary,
            onTap: _openHistory,
            tooltip: 'Atividade',
          ),
          // Account button
          _AccountBtn(textPrimary: textPrimary),
          // Calendar button
          _AppBarIconBtn(
            svg: _calendarSvg,
            color: textPrimary,
            onTap: _openAgenda,
            tooltip: 'Agenda',
          ),
          // Theme popup
          _ThemePopupMenu(
            isDark: isDark,
            textPrimary: textPrimary,
            textSec: textSec,
            surfBg: surfBg,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(key: ValueKey(_idx), child: pages[_idx]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: divColor),
          Container(
            color: navBg,
            height: 64,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _AnimatedNavItem(
                    outlineSvg: _homeOutline,
                    filledSvg: _homeFilled,
                    label: 'Início',
                    selected: _idx == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _idx = 0),
                  ),
                  _AnimatedNavItem(
                    outlineSvg: _criarOutline,
                    filledSvg: _criarFilled,
                    label: 'Criar',
                    selected: _idx == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _idx = 1),
                  ),
                  _AnimatedNavItem(
                    outlineSvg: _templatesOutline,
                    filledSvg: _templatesFilled,
                    label: 'Templates',
                    selected: _idx == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _idx = 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AppBar icon button ────────────────────────────────────────────────────────

class _AppBarIconBtn extends StatelessWidget {
  final String svg;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _AppBarIconBtn({
    required this.svg,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40, height: 40,
          alignment: Alignment.center,
          child: SvgPicture.string(svg,
              width: 22, height: 22,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
      ),
    );
  }
}

// ─── NAV ITEM ANIMADO (zoom in/out suave) ─────────────────────────────────────

class _AnimatedNavItem extends StatefulWidget {
  final String outlineSvg;
  final String filledSvg;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.outlineSvg,
    required this.filledSvg,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    // Smooth zoom in then zoom out
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.22)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.22, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 60),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final sel        = widget.selected;
    final isDark     = widget.isDark;
    final selColor   = isDark ? AppColors.darkNavSelected   : AppColors.navSelected;
    final unselColor = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final color      = sel ? selColor : unselColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (ctx, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(anim),
                    child: child,
                  ),
                ),
                child: SvgPicture.string(
                  sel ? widget.filledSvg : widget.outlineSvg,
                  key: ValueKey(sel),
                  width: 22, height: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: GoogleFonts.roboto(
                  color: color,
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── POPUP MENU TEMA ──────────────────────────────────────────────────────────

// ─── Account button ────────────────────────────────────────────────────────────

const _svgAccount = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,12A6,6,0,1,0,6,6,6.006,6.006,0,0,0,12,12ZM12,2a4,4,0,1,1-4,4A4,4,0,0,1,12,2ZM12,14a9.01,9.01,0,0,0-9,9,1,1,0,0,0,2,0,7,7,0,0,1,14,0,1,1,0,0,0,2,0A9.01,9.01,0,0,0,12,14Z"/></svg>';

class _AccountBtn extends StatelessWidget {
  final Color textPrimary;
  const _AccountBtn({super.key, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final auth   = AuthService.instance;
    return GestureDetector(
      onTap: () => _showSheet(context, auth, isDark, acc),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: auth.loggedIn
            ? CircleAvatar(
                radius: 16,
                backgroundColor: acc.withOpacity(.15),
                child: Text(
                  (auth.user?.name ?? 'U')[0].toUpperCase(),
                  style: TextStyle(color: acc, fontSize: 14, fontWeight: FontWeight.w700),
                ))
            : SvgPicture.string(_svgAccount, width: 22, height: 22,
                colorFilter: ColorFilter.mode(textPrimary, BlendMode.srcIn)),
      ),
    );
  }

  void _showSheet(BuildContext context, AuthService auth, bool isDark, Color acc) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final tp = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final ts = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: auth.loggedIn
              ? _LoggedSheet(auth: auth, tp: tp, ts: ts, acc: acc, isDark: isDark)
              : _GuestSheet(acc: acc, tp: tp, ts: ts),
        ),
      ),
    );
  }
}

class _LoggedSheet extends StatelessWidget {
  final AuthService auth;
  final Color tp, ts, acc;
  final bool isDark;
  const _LoggedSheet({required this.auth, required this.tp, required this.ts, required this.acc, required this.isDark});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(color: ts.withOpacity(.3), borderRadius: BorderRadius.circular(2))),
    CircleAvatar(radius: 30, backgroundColor: acc.withOpacity(.15),
        child: Text((auth.user?.name ?? 'U')[0].toUpperCase(),
            style: TextStyle(color: acc, fontSize: 26, fontWeight: FontWeight.w800))),
    const SizedBox(height: 12),
    Text(auth.user?.name ?? '', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: tp)),
    const SizedBox(height: 4),
    Text(auth.user?.phone ?? auth.user?.email ?? '',
        style: GoogleFonts.roboto(fontSize: 13.5, color: ts)),
    const SizedBox(height: 6),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: acc.withOpacity(.1), borderRadius: BorderRadius.circular(999)),
      child: Text('Plano \${auth.user?.plan ?? "free"}',
          style: GoogleFonts.roboto(fontSize: 11.5, fontWeight: FontWeight.w700, color: acc)),
    ),
    const SizedBox(height: 28),
    SizedBox(width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          Navigator.pop(context);
          await auth.logout();
          if (context.mounted) Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()), (_) => false);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Terminar sessão', style: GoogleFonts.roboto(fontWeight: FontWeight.w700)),
      ),
    ),
  ]);
}

class _GuestSheet extends StatelessWidget {
  final Color acc, tp, ts;
  const _GuestSheet({required this.acc, required this.tp, required this.ts});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(color: ts.withOpacity(.3), borderRadius: BorderRadius.circular(2))),
    Text('Sem sessão iniciada', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: tp)),
    const SizedBox(height: 8),
    Text('Entra para guardar os teus documentos\ne histórico na nuvem.',
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(fontSize: 14, color: ts)),
    const SizedBox(height: 28),
    SizedBox(width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AuthScreen(onDone: () => Navigator.pop(context))));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: acc,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Entrar / Criar conta',
            style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    ),
  ]);
}


class _ThemePopupMenu extends StatefulWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSec;
  final Color surfBg;

  const _ThemePopupMenu({
    required this.isDark,
    required this.textPrimary,
    required this.textSec,
    required this.surfBg,
  });

  @override
  State<_ThemePopupMenu> createState() => _ThemePopupMenuState();
}

class _ThemePopupMenuState extends State<_ThemePopupMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final isDark      = widget.isDark;
    final textPrim    = widget.textPrimary;
    final textSec     = widget.textSec;
    final surfBg      = widget.surfBg;
    final acc         = accColor(isDark);
    final borderColor = isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300;

    return PopupMenuButton<String>(
      onOpened:   () => setState(() => _isOpen = true),
      onCanceled: () => setState(() => _isOpen = false),
      onSelected: (v) {
        setState(() => _isOpen = false);
        if (v == 'theme') themeNotifier.toggle();
      },
      tooltip: 'Mais opções',
      offset: const Offset(0, 48),
      color: surfBg,
      elevation: 4,
      shadowColor: isDark ? Colors.black54 : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 0.8),
      ),
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _isOpen
              ? (isDark ? Colors.white12 : Colors.black12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Center(child: _ThreeDotsIcon(color: textPrim)),
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

// ─── ITEM TEMA DO POPUP ───────────────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: widget.isDark ? 1.0 : 0.0,
    );
    _rotate = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ThemeMenuItem old) {
    super.didUpdateWidget(old);
    if (old.isDark != widget.isDark) {
      widget.isDark ? _ctrl.forward() : _ctrl.reverse();
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
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
                        colorFilter: ColorFilter.mode(widget.acc, BlendMode.srcIn))
                    : SvgPicture.string(_moonSvg,
                        key: const ValueKey('moon'),
                        width: 20, height: 20,
                        colorFilter: ColorFilter.mode(widget.textPrim, BlendMode.srcIn)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0), end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              label,
              key: ValueKey(label),
              style: GoogleFonts.roboto(
                color: widget.textPrim, fontWeight: FontWeight.w600, fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

// ─── TRÊS PONTINHOS ───────────────────────────────────────────────────────────

class _ThreeDotsIcon extends StatelessWidget {
  final Color color;
  const _ThreeDotsIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">'
      '<circle cx="5"  cy="12" r="2"/>'
      '<circle cx="12" cy="12" r="2"/>'
      '<circle cx="19" cy="12" r="2"/>'
      '</svg>',
      width: 22, height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}