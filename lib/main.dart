import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
// SVGs INLINE
// ─────────────────────────────────────────────

// HOME FILLED (viewBox 512×512)
const String _homeFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
<g>
  <path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/>
  <g>
    <path d="M362.667,383.841v128H448c35.346,0,64-28.654,64-64V253.26c0.005-11.083-4.302-21.733-12.011-29.696l-181.29-195.99c-31.988-34.61-85.976-36.735-120.586-4.747c-1.644,1.52-3.228,3.103-4.747,4.747L12.395,223.5C4.453,231.496-0.003,242.31,0,253.58v194.261c0,35.346,28.654,64,64,64h85.333v-128c0.399-58.172,47.366-105.676,104.073-107.044C312.01,275.383,362.22,323.696,362.667,383.841z"/>
    <path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/>
  </g>
</g>
</svg>
''';

// HOME OUTLINE (viewBox 512.001×512.001)
const String _homeOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512.001 512.001">
<g>
  <path d="M490.134,185.472L338.966,34.304c-45.855-45.737-120.076-45.737-165.931,0L21.867,185.472C7.819,199.445-0.055,218.457,0,238.272v221.397C0.047,488.568,23.475,511.976,52.374,512h407.253c28.899-0.023,52.326-23.432,52.373-52.331V238.272C512.056,218.457,504.182,199.445,490.134,185.472z M448,448H341.334v-67.883c0-44.984-36.467-81.451-81.451-81.451c0,0,0,0,0,0h-7.765c-44.984,0-81.451,36.467-81.451,81.451l0,0V448H64V238.272c0.007-2.829,1.125-5.541,3.115-7.552L218.283,79.552c20.825-20.831,54.594-20.835,75.425-0.01c0.003,0.003,0.007,0.007,0.01,0.01L444.886,230.72c1.989,2.011,3.108,4.723,3.115,7.552V448z"/>
</g>
</svg>
''';

// AGENDA FILLED (viewBox 24×24)
const String _agendaFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M0,8v-1C0,4.243,2.243,2,5,2h1V1c0-.552,.447-1,1-1s1,.448,1,1v1h8V1c0-.552,.447-1,1-1s1,.448,1,1v1h1c2.757,0,5,2.243,5,5v1H0Zm24,2v9c0,2.757-2.243,5-5,5H5c-2.757,0-5-2.243-5-5V10H24Zm-12,9c0-.552-.447-1-1-1H6c-.553,0-1,.448-1,1s.447,1,1,1h5c.553,0,1-.448,1-1Zm7-4c0-.552-.447-1-1-1H6c-.553,0-1,.448-1,1s.447,1,1,1h12c.553,0,1-.448,1-1Z"/>
</svg>
''';

// AGENDA OUTLINE (viewBox 24×24)
const String _agendaOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,12.5c0,.829-.672,1.5-1.5,1.5H7.5c-.828,0-1.5-.671-1.5-1.5s.672-1.5,1.5-1.5h9c.828,0,1.5,.671,1.5,1.5Zm-6.5,3.5H7.5c-.828,0-1.5,.671-1.5,1.5s.672,1.5,1.5,1.5h4c.828,0,1.5-.671,1.5-1.5s-.672-1.5-1.5-1.5ZM24,7.5v11c0,3.033-2.468,5.5-5.5,5.5H5.5c-3.032,0-5.5-2.467-5.5-5.5V7.5C0,4.467,2.468,2,5.5,2h.5v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h6v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h.5c3.032,0,5.5,2.467,5.5,5.5Zm-3,11V9H3v9.5c0,1.378,1.121,2.5,2.5,2.5h13c1.379,0,2.5-1.122,2.5-2.5Z"/>
</svg>
''';

// LANÇAMENTO FILLED (viewBox 512×512)
const String _lancamentoFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512 512">
<path d="M11.815,289.919c-11.596-17.06-13.914-38.781-6.179-57.904c17.287-35.265,46.246-63.459,81.961-79.795c25.858-12.859,53.867-20.834,82.619-23.527c-12.528,15.416-25.07,31.864-37.626,49.347c-25.554,38.696-47.428,79.7-65.335,122.475l-7.708,17.284C40.239,316.201,22.691,305.952,11.815,289.919z M41.181,379.609c-18.448,25.473-31.689,54.335-38.963,84.934c-4.535,19.882,7.906,39.677,27.789,44.212c5.411,1.234,11.03,1.233,16.441-0.004c30.552-7.286,59.369-20.518,84.807-38.942l0,0c24.908-24.896,24.918-65.271,0.021-90.179c-24.896-24.908-65.271-24.918-90.179-0.021H41.181z M209.711,442.885l-17.411,7.729v6.243c0.042,14.955,6.031,29.279,16.647,39.813c10.098,9.821,23.625,15.32,37.711,15.331c50.047-0.722,90.625-46.289,111.922-88.713c13.047-26.256,21.049-54.727,23.59-83.936c-15.571,12.74-32.268,25.48-50.09,38.22c-38.681,25.561-79.679,47.428-122.454,65.314H209.711z M510.802,62.827c-2.824,92.429-69.37,184.094-203.459,280.282c-36.49,23.654-74.985,44.06-115.043,60.983v-11.954c-0.198-40.962-33.355-74.12-74.317-74.317h-11.954c16.962-40.059,37.403-78.554,61.089-115.043C263.071,69.006,354.587,2.375,446.868-0.64C492.859-0.64,510.802,18.088,510.802,62.827z M383.401,179.802c0-29.317-23.766-53.084-53.084-53.084s-53.084,23.766-53.084,53.084c0,29.317,23.766,53.084,53.084,53.084S383.401,209.119,383.401,179.802z"/>
</svg>
''';

// LANÇAMENTO OUTLINE (viewBox 24×24)
const String _lancamentoOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M5.3,18.7a2.4,2.4,0,0,1,0,3.394,12.8,12.8,0,0,1-4.212,1.88A.887.887,0,0,1,.023,22.915,12.8,12.8,0,0,1,1.9,18.7,2.4,2.4,0,0,1,5.3,18.7Zm10.745-1.087ZM6.257,8.139h0C6.29,8.093,6.273,8.116,6.257,8.139ZM18,8.5a2.5,2.5,0,0,0-5,0A2.5,2.5,0,0,0,18,8.5Zm-1.976,9.129.008-.006a12.106,12.106,0,0,1-.823,2.111,8.713,8.713,0,0,1-3.848,4.07A2.427,2.427,0,0,1,8,21.554V19a3.015,3.015,0,0,0-3-3H2.392a2.373,2.373,0,0,1-2.2-3.287A8.518,8.518,0,0,1,4.172,8.95a11.881,11.881,0,0,1,2.085-.811c-.016.022-.031.044,0,0C10.088,2.8,14.469.171,20.458,0A3.513,3.513,0,0,1,24,3.5c-.171,6.031-2.625,10.293-7.967,14.123ZM21,3.458A.493.493,0,0,0,20.5,3c-5.036.144-8.3,2-11.612,6.614a28.038,28.038,0,0,0-2.153,3.64,6.018,6.018,0,0,1,3.984,3.922L12.882,16.1c.506-.3,1.018-.634,1.505-.983C19,11.8,20.856,8.536,21,3.458ZM16.032,17.623l.01-.007-.009.007Z"/>
</svg>
''';

// EXIBIÇÃO FILLED (viewBox 24×24)
const String _exibicaoFilledSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="m16.914,1h2.086c.621,0,1.215.114,1.764.322l-5.678,5.678h-4.172l6-6Zm7.086,6v-1c0-1.4-.579-2.668-1.51-3.576l-4.576,4.576h6.086ZM10.522,1l-6.084,6h3.648L14.086,1h-3.564ZM1.59,7L7.674,1h-2.674C2.243,1,0,3.243,0,6v1h1.59Zm22.41,2v9c0,2.757-2.243,5-5,5H5c-2.757,0-5-2.243-5-5v-9h24Zm-8.953,6.2l-4.634-2.48c-.622-.373-1.413.075-1.413.8v4.961c0,.725.791,1.173,1.413.8l4.634-2.48c.604-.362.604-1.238,0-1.6Z"/>
</svg>
''';

// EXIBIÇÃO OUTLINE (viewBox 24×24)
const String _exibicaoOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="m18.5,1H5.5C2.467,1,0,3.467,0,6.5v11c0,3.033,2.467,5.5,5.5,5.5h13c3.033,0,5.5-2.467,5.5-5.5V6.5c0-3.033-2.467-5.5-5.5-5.5Zm2.5,6h-3.879l2.651-2.651c.734.436,1.228,1.237,1.228,2.151v.5Zm-11.879,0l3-3h3.758l-3,3h-3.758Zm-3.621-3h2.379l-3,3h-1.879v-.5c0-1.378,1.122-2.5,2.5-2.5Zm13,16H5.5c-1.378,0-2.5-1.122-2.5-2.5v-7.5h18v7.5c0,1.378-1.122,2.5-2.5,2.5Zm-3.453-4.2l-4.634,2.48c-.622.373-1.413-.075-1.413-.8v-4.961c0-.725.791-1.173,1.413-.8l4.634,2.48c.604.362.604,1.238,0,1.6Z"/>
</svg>
''';

// AGENDA VAZIA / SEM EVENTOS (viewBox 24×24) - vermelho
const String _agendaVaziaSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m15.561,13.561l-1.439,1.439,1.439,1.439c.586.586.586,1.535,0,2.121-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439l-1.439-1.439-1.439,1.439c-.293.293-.677.439-1.061.439s-.768-.146-1.061-.439c-.586-.586-.586-1.535,0-2.121l1.439-1.439-1.439-1.439c-.586-.586-.586-1.535,0-2.121s1.535-.586,2.121,0l1.439,1.439,1.439-1.439c.586-.586,1.535-.586,2.121,0s.586,1.535,0,2.121Zm8.439-6.061v11c0,3.032-2.467,5.5-5.5,5.5H5.5c-3.033,0-5.5-2.468-5.5-5.5V7.5C0,4.468,2.467,2,5.5,2h.5v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h6v-.5c0-.828.671-1.5,1.5-1.5s1.5.672,1.5,1.5v.5h.5c3.033,0,5.5,2.468,5.5,5.5Zm-3,11v-9.5H3v9.5c0,1.379,1.122,2.5,2.5,2.5h13c1.378,0,2.5-1.121,2.5-2.5Z"/>
</svg>
''';

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
    return MaterialApp(
      title: 'App Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6EF7),
          brightness: Brightness.light,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF4F6EF7).withOpacity(0.15),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF4F6EF7));
            }
            return const IconThemeData(color: Color(0xFF9AA0B2));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF4F6EF7), fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(color: Color(0xFF9AA0B2), fontWeight: FontWeight.w500, fontSize: 12);
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1F36),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1F36),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F6EF7),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF111318),
          onSurface: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1C1C1E),
          indicatorColor: const Color(0xFF4F6EF7).withOpacity(0.25),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF4F6EF7));
            }
            return const IconThemeData(color: Color(0xFF8E8E93));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF4F6EF7), fontWeight: FontWeight.w600, fontSize: 12);
            }
            return const TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500, fontSize: 12);
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFF111318),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1C1C1E),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER: SVG colorido
// ─────────────────────────────────────────────
Widget _svgIcon(String svgString, Color color, {double size = 24}) {
  return SvgPicture.string(
    svgString,
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

// ─────────────────────────────────────────────
// SHELL PRINCIPAL — único Scaffold com GlobalKey
// ─────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // ★ GlobalKey — permite abrir o drawer de qualquer widget filho
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  static const _titles = ['Início', 'Agenda', 'Lançamentos', 'Exibição'];

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    final navBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    // Páginas sem Scaffold/AppBar próprios — recebem _openDrawer via construtor
    final pages = [
      InicioPAge(onOpenDrawer: _openDrawer),
      AgendaPage(onOpenDrawer: _openDrawer),
      LancamentosPage(onOpenDrawer: _openDrawer),
      ExibicaoPage(onOpenDrawer: _openDrawer),
    ];

    return Scaffold(
      key: _scaffoldKey, // ★ key no único Scaffold raiz
      drawer: const _AppDrawer(),
      // ★ AppBar único no MainShell
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: colorScheme.primary),
          onPressed: _openDrawer,
          tooltip: 'Menu',
        ),
        title: Text(_titles[_selectedIndex]),
        actions: _buildActions(colorScheme),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            NavigationDestination(
              icon: _svgIcon(_homeOutlineSvg, const Color(0xFF9AA0B2)),
              selectedIcon: _svgIcon(_homeFilledSvg, colorScheme.primary),
              label: 'Início',
            ),
            NavigationDestination(
              icon: _svgIcon(_agendaOutlineSvg, const Color(0xFF9AA0B2)),
              selectedIcon: _svgIcon(_agendaFilledSvg, colorScheme.primary),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: _svgIcon(_lancamentoOutlineSvg, const Color(0xFF9AA0B2)),
              selectedIcon: _svgIcon(_lancamentoFilledSvg, colorScheme.primary),
              label: 'Lançamentos',
            ),
            NavigationDestination(
              icon: _svgIcon(_exibicaoOutlineSvg, const Color(0xFF9AA0B2)),
              selectedIcon: _svgIcon(_exibicaoFilledSvg, colorScheme.primary),
              label: 'Exibição',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(ColorScheme colorScheme) {
    switch (_selectedIndex) {
      case 0:
        return [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.person_outline_rounded, size: 20, color: colorScheme.primary),
            ),
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {},
            color: colorScheme.primary,
          ),
        ];
      case 2:
        return [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
            color: colorScheme.primary,
          ),
        ];
      default:
        return [];
    }
  }
}

// ─────────────────────────────────────────────
// DRAWER
// ─────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  const _AppDrawer();

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
    final colorScheme = Theme.of(context).colorScheme;
    final drawerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF9AA0B2) : const Color(0xFF6B7280);
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.primary.withOpacity(0.15),
                    child: Icon(Icons.person_outline_rounded, size: 28, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Utilizador',
                            style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('utilizador@email.com',
                            style: TextStyle(color: textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 12),

            _DrawerItem(icon: Icons.home_outlined, label: 'Início', onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.settings_outlined, label: 'Definições', onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.help_outline_rounded, label: 'Ajuda', onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.info_outline_rounded, label: 'Sobre', onTap: () => Navigator.pop(context)),

            const Spacer(),
            Divider(height: 1, color: dividerColor),
            const SizedBox(height: 8),

            // Botão tema com Container Transform
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 450),
                openColor: drawerBg,
                closedColor: colorScheme.primary.withOpacity(0.08),
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                closedElevation: 0,
                openElevation: 0,
                closedBuilder: (context, _) => InkWell(
                  onTap: themeNotifier.toggle,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Icon(
                          isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          isDark ? 'Tema Claro' : 'Tema Escuro',
                          style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? colorScheme.primary : colorScheme.primary.withOpacity(0.2),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white : colorScheme.primary,
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
                  return Container(color: drawerBg);
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon,
          color: isDark ? const Color(0xFF9AA0B2) : const Color(0xFF6B7280),
          size: 22),
      title: Text(label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          )),
      onTap: onTap,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }
}

// ─────────────────────────────────────────────
// PÁGINA: INÍCIO (sem Scaffold nem AppBar)
// ─────────────────────────────────────────────
class InicioPAge extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  const InicioPAge({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class AgendaPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const AgendaPage({super.key, required this.onOpenDrawer});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  int _selectedDay = 2;
  // Apenas o índice 2 (Qua) tem eventos
  static const _daysWithEvents = {2};
  final List<String> _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  final List<String> _dates = ['10', '11', '12', '13', '14', '15', '16'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeNotifier.isDark;
    final headerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final hasEvents = _daysWithEvents.contains(_selectedDay);

    return Column(
      children: [
        Container(
          color: headerBg,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isSelected = i == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(_days[i], style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF9AA0B2),
                      )),
                      const SizedBox(height: 4),
                      Text(_dates[i], style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
                      )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: hasEvents
                ? ListView(
                    key: const ValueKey('events'),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _EventCard(time: '09:00', title: 'Standup diário', description: 'Alinhamento da equipa', duration: '30 min', color: const Color(0xFF4F6EF7), isDark: themeNotifier.isDark),
                      _EventCard(time: '11:00', title: 'Revisão de código', description: 'Sprint 14 – módulo de pagamentos', duration: '1h 30min', color: const Color(0xFF34D399), isDark: themeNotifier.isDark),
                      _EventCard(time: '14:00', title: 'Reunião com cliente', description: 'Demo do novo dashboard', duration: '1h', color: const Color(0xFFFF6B6B), isDark: themeNotifier.isDark),
                      _EventCard(time: '16:30', title: 'Planeamento semanal', description: 'Definição de prioridades', duration: '45 min', color: const Color(0xFFFFB547), isDark: themeNotifier.isDark),
                    ],
                  )
                : const _EmptyAgendaState(key: ValueKey('empty')),
          ),
        ),
      ],
    );
  }
}

class _EmptyAgendaState extends StatelessWidget {
  const _EmptyAgendaState({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFFF6B6B);
    final isDark = themeNotifier.isDark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: red.withOpacity(0.10), shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.string(
                _agendaVaziaSvg,
                width: 44,
                height: 44,
                colorFilter: const ColorFilter.mode(red, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Sem nada agendado',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Não há eventos para este dia.\nToque em + para adicionar um.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF9AA0B2), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final String duration;
  final Color color;
  final bool isDark;

  const _EventCard({
    required this.time,
    required this.title,
    required this.description,
    required this.duration,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF9AA0B2))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: color, width: 3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                        const SizedBox(height: 4),
                        Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF9AA0B2))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(30)),
                    child: Text(duration, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
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

// ─────────────────────────────────────────────
// PÁGINA: LANÇAMENTOS (sem Scaffold nem AppBar)
// ─────────────────────────────────────────────
class LancamentosPage extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  const LancamentosPage({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

// ─────────────────────────────────────────────
// PÁGINA: EXIBIÇÃO (sem Scaffold nem AppBar)
// ─────────────────────────────────────────────
class ExibicaoPage extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  const ExibicaoPage({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
