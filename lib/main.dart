import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
// SVGs INLINE
// ─────────────────────────────────────────────

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

const String _lancamentoFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
<path d="M11.815,289.919c-11.596-17.06-13.914-38.781-6.179-57.904c17.287-35.265,46.246-63.459,81.961-79.795c25.858-12.859,53.867-20.834,82.619-23.527c-12.528,15.416-25.07,31.864-37.626,49.347c-25.554,38.696-47.428,79.7-65.335,122.475l-7.708,17.284C40.239,316.201,22.691,305.952,11.815,289.919z M41.181,379.609c-18.448,25.473-31.689,54.335-38.963,84.934c-4.535,19.882,7.906,39.677,27.789,44.212c5.411,1.234,11.03,1.233,16.441-0.004c30.552-7.286,59.369-20.518,84.807-38.942c24.908-24.896,24.918-65.271,0.021-90.179c-24.896-24.908-65.271-24.918-90.179-0.021H41.181z M209.711,442.885l-17.411,7.729v6.243c0.042,14.955,6.031,29.279,16.647,39.813c10.098,9.821,23.625,15.32,37.711,15.331c50.047-0.722,90.625-46.289,111.922-88.713c13.047-26.256,21.049-54.727,23.59-83.936c-15.571,12.74-32.268,25.48-50.09,38.22c-38.681,25.561-79.679,47.428-122.454,65.314H209.711z M510.802,62.827c-2.824,92.429-69.37,184.094-203.459,280.282c-36.49,23.654-74.985,44.06-115.043,60.983v-11.954c-0.198-40.962-33.355-74.12-74.317-74.317h-11.954c16.962-40.059,37.403-78.554,61.089-115.043C263.071,69.006,354.587,2.375,446.868-0.64C492.859-0.64,510.802,18.088,510.802,62.827z M383.401,179.802c0-29.317-23.766-53.084-53.084-53.084s-53.084,23.766-53.084,53.084c0,29.317,23.766,53.084,53.084,53.084S383.401,209.119,383.401,179.802z"/>
</svg>
''';

const String _lancamentoOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M5.3,18.7a2.4,2.4,0,0,1,0,3.394,12.8,12.8,0,0,1-4.212,1.88A.887.887,0,0,1,.023,22.915,12.8,12.8,0,0,1,1.9,18.7,2.4,2.4,0,0,1,5.3,18.7Zm12.7-15.242C17.829,9.531,15.375,13.793,10.033,17.623l.008-.006c-.162.599-.415,1.238-.815,2.105A8.713,8.713,0,0,1,5.378,23.792,2.427,2.427,0,0,1,2,21.554V19a3.015,3.015,0,0,0-3-3H-4.608a2.373,2.373,0,0,1-2.2-3.287A8.518,8.518,0,0,1-2.828,8.95a11.881,11.881,0,0,1,2.085-.811C3.088,2.8,7.469.171,13.458,0A3.513,3.513,0,0,1,17,3.5ZM15,3.458A.493.493,0,0,0,14.5,3C9.464,3.144,6.2,5,2.888,9.614A28.038,28.038,0,0,0,.735,13.254a6.018,6.018,0,0,1,3.984,3.922L6.882,16.1c.506-.3,1.018-.634,1.505-.983C13,11.8,14.856,8.536,15,3.458ZM12,6a2.5,2.5,0,1,0,2.5,2.5A2.5,2.5,0,0,0,12,6Z"/>
</svg>
''';

const String _exibicaoFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m16.914,1h2.086c.621,0,1.215.114,1.764.322l-5.678,5.678h-4.172l6-6Zm7.086,6v-1c0-1.4-.579-2.668-1.51-3.576l-4.576,4.576h6.086ZM10.522,1l-6.084,6h3.648L14.086,1h-3.564ZM1.59,7L7.674,1h-2.674C2.243,1,0,3.243,0,6v1h1.59Zm22.41,2v9c0,2.757-2.243,5-5,5H5c-2.757,0-5-2.243-5-5v-9h24Zm-8.953,6.2l-4.634-2.48c-.622-.373-1.413.075-1.413.8v4.961c0,.725.791,1.173,1.413.8l4.634-2.48c.604-.362.604-1.238,0-1.6Z"/>
</svg>
''';

const String _exibicaoOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m18.5,1H5.5C2.467,1,0,3.467,0,6.5v11c0,3.033,2.467,5.5,5.5,5.5h13c3.033,0,5.5-2.467,5.5-5.5V6.5c0-3.033-2.467-5.5-5.5-5.5Zm2.5,6h-3.879l2.651-2.651c.734.436,1.228,1.237,1.228,2.151v.5Zm-11.879,0l3-3h3.758l-3,3h-3.758Zm-3.621-3h2.379l-3,3h-1.879v-.5c0-1.378,1.122-2.5,2.5-2.5Zm13,16H5.5c-1.378,0-2.5-1.122-2.5-2.5v-7.5h18v7.5c0,1.378-1.122,2.5-2.5,2.5Zm-3.453-4.2l-4.634,2.48c-.622.373-1.413-.075-1.413-.8v-4.961c0-.725.791-1.173,1.413-.8l4.634,2.48c.604.362.604,1.238,0,1.6Z"/>
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
  // Light
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE0E0E0);
  static const navBg = Color(0xFFFFFFFF);
  static const navUnselected = Color(0xFF8E8E8E);
  static const navSelected = Color(0xFF000000);

  // Dark
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1C);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider = Color(0xFF2C2C2C);
  static const darkNavBg = Color(0xFF000000);
  static const darkNavUnselected = Color(0xFF8E8E8E);
  static const darkNavSelected = Color(0xFFFFFFFF);
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

    // Status bar icons adaptativos
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

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
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.navBg,
          indicatorColor: Colors.transparent,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.navSelected, size: 24);
            }
            return const IconThemeData(color: AppColors.navUnselected, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.navSelected,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              );
            }
            return const TextStyle(
              color: AppColors.navUnselected,
              fontWeight: FontWeight.w400,
              fontSize: 11,
            );
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
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
          titleTextStyle: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkNavBg,
          indicatorColor: Colors.transparent,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.darkNavSelected, size: 24);
            }
            return const IconThemeData(color: AppColors.darkNavUnselected, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.darkNavSelected,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              );
            }
            return const TextStyle(
              color: AppColors.darkNavUnselected,
              fontWeight: FontWeight.w400,
              fontSize: 11,
            );
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
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

  static const _titles = ['Início', 'Agenda', 'Lançamentos', 'Exibição'];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final navUnselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final navSelected = isDark ? AppColors.darkNavSelected : AppColors.navSelected;
    final navBg = isDark ? AppColors.darkNavBg : AppColors.navBg;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final pages = [
      const InicioPAge(),
      const AgendaPage(),
      const LancamentosPage(),
      const ExibicaoPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      drawer: _AppDrawer(isDark: isDark),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: textPrimary),
          onPressed: _openDrawer,
        ),
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: divider),
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
          Divider(height: 1, thickness: 1, color: divider),
          NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            animationDuration: const Duration(milliseconds: 200),
            backgroundColor: navBg,
            destinations: [
              NavigationDestination(
                icon: _svg(_homeOutlineSvg, navUnselected),
                selectedIcon: _svg(_homeFilledSvg, navSelected),
                label: 'Início',
              ),
              NavigationDestination(
                icon: _svg(_agendaOutlineSvg, navUnselected),
                selectedIcon: _svg(_agendaFilledSvg, navSelected),
                label: 'Agenda',
              ),
              NavigationDestination(
                icon: _svg(_lancamentoOutlineSvg, navUnselected),
                selectedIcon: _svg(_lancamentoFilledSvg, navSelected),
                label: 'Lançamentos',
              ),
              NavigationDestination(
                icon: _svg(_exibicaoOutlineSvg, navUnselected),
                selectedIcon: _svg(_exibicaoFilledSvg, navSelected),
                label: 'Exibição',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DRAWER — só tema toggle, sem botões inúteis
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
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final surfaceBg = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho utilizador
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

            // Toggle tema — único item funcional
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 400),
                openColor: bg,
                closedColor: surfaceBg,
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
                        // pill switch
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
                                color: isDark ? AppColors.darkBackground : AppColors.background,
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
// PÁGINA: INÍCIO — vazia
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
  int _selectedDay = DateTime.now().weekday - 1; // 0=Seg

  final List<String> _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  // Gera as datas da semana atual
  List<DateTime> get _weekDates {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceBg = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final dates = _weekDates;

    return Column(
      children: [
        // Seletor de dias
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

        // Estado vazio — sempre, pois não há eventos reais
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
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
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
// PÁGINA: LANÇAMENTOS — vazia
// ─────────────────────────────────────────────
class LancamentosPage extends StatelessWidget {
  const LancamentosPage({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

// ─────────────────────────────────────────────
// PÁGINA: EXIBIÇÃO — vazia
// ─────────────────────────────────────────────
class ExibicaoPage extends StatelessWidget {
  const ExibicaoPage({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
