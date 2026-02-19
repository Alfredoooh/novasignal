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
      key: ValueKey(isDark),
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
  static const _titles = ['Mensagens', 'Agenda', 'Templates'];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final navUnselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final pillIconColor = isDark ? AppColors.pillDarkIcon : AppColors.pillLightIcon;
    final navBg = isDark ? AppColors.darkNavBg : AppColors.navBg;
    final pillColor = isDark ? AppColors.pillDark : AppColors.pillLight;

    final pages = [
      const MensagensPage(),
      const AgendaPage(),
      const TemplatesPage(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 450),
        backgroundColor: navBg,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: pillColor,
        destinations: [
          NavigationDestination(
            icon: _svg(_mensagensOutlineSvg, navUnselected),
            selectedIcon: _svg(_mensagensFilledSvg, pillIconColor),
            label: 'Mensagens',
          ),
          NavigationDestination(
            icon: _svg(_agendaOutlineSvg, navUnselected),
            selectedIcon: _svg(_agendaFilledSvg, pillIconColor),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: _svg(_feedOutlineSvg, navUnselected),
            selectedIcon: _svg(_feedFilledSvg, pillIconColor),
            label: 'Templates',
          ),
        ],
      ),
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
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Utilizador',
                            style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('utilizador@email.com',
                            style: TextStyle(color: textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: divider),
            const Spacer(),
            Divider(height: 1, color: divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 400),
                openColor: bg,
                closedColor: toggleBg,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                closedElevation: 0,
                openElevation: 0,
                closedBuilder: (context, _) => InkWell(
                  onTap: themeNotifier.toggle,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                openBuilder: (context, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  });
                  return Container(color: bg);
                },
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
// PÁGINA: MENSAGENS
// ─────────────────────────────────────────────
class MensagensPage extends StatelessWidget {
  const MensagensPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: TEMPLATES
// ─────────────────────────────────────────────
class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: AGENDA — com calendário expansível
// ─────────────────────────────────────────────
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> with TickerProviderStateMixin {
  // Dia selecionado (índice 0=Seg dentro da semana visível)
  int _selectedDayIndex = DateTime.now().weekday - 1;
  // Data selecionada completa
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  // Calendário expandido
  bool _expanded = false;
  // Mês visível no calendário expandido
  late DateTime _visibleMonth;

  // Animação do indicador elástico (spring)
  late AnimationController _indicatorCtrl;
  late Animation<double> _indicatorScaleX;

  // Animação de expansão do calendário
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  // Para o DraggableScrollableSheet
  final DraggableScrollableController _dragCtrl = DraggableScrollableController();

  static const List<String> _weekLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  static const List<String> _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

    // Indicador spring: estica horizontalmente e volta
    _indicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _indicatorScaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 0.88).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.88, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_indicatorCtrl);

    // Expansão
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _indicatorCtrl.dispose();
    _expandCtrl.dispose();
    _dragCtrl.dispose();
    super.dispose();
  }

  void _selectDay(DateTime date) {
    if (date == _selectedDate) return;
    setState(() {
      _selectedDate = date;
      _selectedDayIndex = date.weekday - 1;
    });
    _indicatorCtrl.forward(from: 0);
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandCtrl.forward();
    } else {
      _expandCtrl.reverse();
    }
  }

  // Semana actual para o strip
  List<DateTime> get _currentWeekDates {
    final now = _selectedDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  // Dias do mês visível para o calendário expandido
  List<DateTime?> get _monthDays {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    // Offset: quantos dias em branco antes do dia 1 (semana começa na segunda)
    final offset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final total = offset + daysInMonth;
    final cells = (total / 7).ceil() * 7;
    return List.generate(cells, (i) {
      final dayNum = i - offset + 1;
      if (dayNum < 1 || dayNum > daysInMonth) return null;
      return DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final weekDates = _currentWeekDates;

    return Column(
      children: [
        // ── Cabeçalho com strip semanal + handle de expansão
        GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 100 && !_expanded) _toggleExpand();
              if (details.primaryVelocity! < -100 && _expanded) _toggleExpand();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            color: bg,
            child: Column(
              children: [
                // Strip semanal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (i) {
                      final date = weekDates[i];
                      final isSelected = date.year == _selectedDate.year &&
                          date.month == _selectedDate.month &&
                          date.day == _selectedDate.day;
                      return GestureDetector(
                        onTap: () => _selectDay(date),
                        child: SizedBox(
                          width: 36,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _weekLabels[i],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? AppColors.darkBackground : AppColors.background)
                                      : textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Indicador circular com animação spring
                              AnimatedBuilder(
                                animation: _indicatorScaleX,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scaleX: isSelected ? _indicatorScaleX.value : 1.0,
                                    child: child,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected ? textPrimary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? (isDark ? AppColors.darkBackground : AppColors.background)
                                            : textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Calendário expandido com animação
                SizeTransition(
                  sizeFactor: _expandAnim,
                  axisAlignment: -1,
                  child: Column(
                    children: [
                      Divider(height: 1, color: divider),
                      // Header do mês com navegação
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() {
                                _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                              }),
                              child: Icon(Icons.chevron_left_rounded, color: textPrimary, size: 26),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() {
                                _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                              }),
                              child: Icon(Icons.chevron_right_rounded, color: textPrimary, size: 26),
                            ),
                          ],
                        ),
                      ),
                      // Labels dias da semana
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'].map((d) => SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(d,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Grid de dias do mês
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildMonthGrid(textPrimary, textSecondary, isDark),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                Divider(height: 1, color: divider),

                // Handle de arrasto
                GestureDetector(
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Conteúdo (vazio por ora)
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
                  child: Center(
                    child: _svg(_agendaVaziaSvg, const Color(0xFFFF3B30), size: 38),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Sem nada agendado',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Não há eventos para este dia.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(Color textPrimary, Color textSecondary, bool isDark) {
    final days = _monthDays;
    final rows = days.length ~/ 7;
    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (col) {
              final date = days[row * 7 + col];
              if (date == null) return const SizedBox(width: 36, height: 34);
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              return GestureDetector(
                onTap: () {
                  _selectDay(date);
                  // Fechar o calendário ao selecionar
                  if (_expanded) _toggleExpand();
                },
                child: AnimatedBuilder(
                  animation: _indicatorScaleX,
                  builder: (context, child) {
                    return Transform.scale(
                      scaleX: isSelected ? _indicatorScaleX.value : 1.0,
                      child: child,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSelected ? textPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: isToday && !isSelected
                          ? Border.all(color: textPrimary.withOpacity(0.35), width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? (isDark ? AppColors.darkBackground : AppColors.background)
                              : isToday
                                  ? textPrimary
                                  : textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}