import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String _homeFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
<path d="M362.667,383.841v128H448c35.346,0,64-28.654,64-64V253.26c0.005-11.083-4.302-21.733-12.011-29.696l-181.29-195.99c-31.988-34.61-85.976-36.735-120.586-4.747c-1.644,1.52-3.228,3.103-4.747,4.747L12.395,223.5C4.453,231.496-0.003,242.31,0,253.58v194.261c0,35.346,28.654,64,64,64h85.333v-128c0.399-58.172,47.366-105.676,104.073-107.044C312.01,275.383,362.22,323.696,362.667,383.841z"/>
<path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/>
</svg>
''';

const String _homeOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512.001 512.001">
<path d="M490.134,185.472L338.966,34.304c-45.855-45.737-120.076-45.737-165.931,0L21.867,185.472C7.819,199.445-0.055,218.457,0,238.272v221.397C0.047,488.568,23.475,511.976,52.374,512h407.253c28.899-0.023,52.326-23.432,52.373-52.331V238.272C512.056,218.457,504.182,199.445,490.134,185.472z M448,448H341.334v-67.883c0-44.984-36.467-81.451-81.451-81.451h-7.765c-44.984,0-81.451,36.467-81.451,81.451V448H64V238.272c0.007-2.829,1.125-5.541,3.115-7.552L218.283,79.552c20.825-20.831,54.594-20.835,75.425-0.01c0.003,0.003,0.007,0.007,0.01,0.01L444.886,230.72c1.989,2.011,3.108,4.723,3.115,7.552V448z"/>
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

const String _notificacoesFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.954,5.542,15.536,13.96a5.007,5.007,0,0,1-7.072,0L.046,5.542C.032,5.7,0,5.843,0,6V18a5.006,5.006,0,0,0,5,5H19a5.006,5.006,0,0,0,5-5V6C24,5.843,23.968,5.7,23.954,5.542Z"/>
<path d="M14.122,12.546l9.134-9.135A4.986,4.986,0,0,0,19,1H5A4.986,4.986,0,0,0,.744,3.411l9.134,9.135A3.007,3.007,0,0,0,14.122,12.546Z"/>
</svg>
''';

const String _notificacoesOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18.5,1H5.5A5.506,5.506,0,0,0,0,6.5v11A5.506,5.506,0,0,0,5.5,23h13A5.506,5.506,0,0,0,24,17.5V6.5A5.506,5.506,0,0,0,18.5,1Zm0,3a2.476,2.476,0,0,1,1.643.631l-6.5,6.5a2.373,2.373,0,0,1-3.278,0l-6.5-6.5A2.476,2.476,0,0,1,5.5,4Zm0,16H5.5A2.5,2.5,0,0,1,3,17.5V8.017l5.239,5.239a5.317,5.317,0,0,0,7.521,0L21,8.017V17.5A2.5,2.5,0,0,1,18.5,20Z"/>
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
  static const darkBackground = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF272727);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider = Color(0xFF2C2C2C);
  static const darkNavBg = Color(0xFF0D0D0D);
  static const darkNavUnselected = Color(0xFF8E8E8E);
  static const darkNavSelected = Color(0xFFFFFFFF);
  static const darkDrawerBg = Color(0xFF262626);
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

    // Pills: escuro = branco com ícone escuro | claro = preto com ícone claro
    final pillColor = isDark ? AppColors.darkNavSelected : AppColors.navSelected;
    final pillIconColor = isDark ? AppColors.darkBackground : AppColors.background;
    final unselectedIconColor = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final navBg = isDark ? AppColors.darkNavBg : AppColors.navBg;

    final navBarTheme = NavigationBarThemeData(
      backgroundColor: navBg,
      indicatorColor: pillColor,
      indicatorShape: const StadiumBorder(),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: pillIconColor, size: 24);
        }
        return IconThemeData(color: unselectedIconColor, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: isDark ? AppColors.darkNavSelected : AppColors.navSelected,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          );
        }
        return TextStyle(
          color: unselectedIconColor,
          fontWeight: FontWeight.w400,
          fontSize: 11,
        );
      }),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    );

    return MaterialApp(
      // ValueKey força rebuild completo da árvore ao mudar tema
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
  static const _titles = ['Início', 'Agenda', 'Notificações'];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final navUnselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final navSelected = isDark ? AppColors.darkNavSelected : AppColors.navSelected;
    // ícone dentro do pill tem cor invertida
    final pillIconColor = isDark ? AppColors.darkBackground : AppColors.background;
    final navBg = isDark ? AppColors.darkNavBg : AppColors.navBg;

    final pages = [
      const InicioPAge(),
      const AgendaPage(),
      const NotificacoesPage(),
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
          icon: Icon(Icons.menu_rounded, color: textPrimary),
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
        animationDuration: const Duration(milliseconds: 250),
        backgroundColor: navBg,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: navSelected,
        destinations: [
          NavigationDestination(
            icon: _svg(_homeOutlineSvg, navUnselected),
            selectedIcon: _svg(_homeFilledSvg, pillIconColor),
            label: 'Início',
          ),
          NavigationDestination(
            icon: _svg(_agendaOutlineSvg, navUnselected),
            selectedIcon: _svg(_agendaFilledSvg, pillIconColor),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: _svg(_notificacoesOutlineSvg, navUnselected),
            selectedIcon: _svg(_notificacoesFilledSvg, pillIconColor),
            label: 'Notificações',
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
// PÁGINA: INÍCIO
// ─────────────────────────────────────────────
class InicioPAge extends StatelessWidget {
  const InicioPAge({super.key});
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

class _AgendaPageState extends State<AgendaPage> {
  int _selectedDay = DateTime.now().weekday - 1;
  final List<String> _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  List<DateTime> get _weekDates {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final dates = _weekDates;

    return Column(
      children: [
        Container(
          color: bg,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final isSelected = i == _selectedDay;
                    final date = dates[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
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
                              _days[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? AppColors.darkBackground : AppColors.background)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? (isDark ? AppColors.darkBackground : AppColors.background)
                                    : textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Divider(height: 1, color: divider),
            ],
          ),
        ),
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
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: NOTIFICAÇÕES
// ─────────────────────────────────────────────
class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}