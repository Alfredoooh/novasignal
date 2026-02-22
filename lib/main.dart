import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/criar_screen.dart';
import 'services/document_service.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt', null);
  await DocumentService.instance.load();

  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const AriaApp());
}

class AriaApp extends StatelessWidget {
  const AriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aria',
      theme: AriaTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  // Chave global para forçar reload da home quando voltar do editor
  final _homeKey = GlobalKey<State<HomeScreen>>();

  void _reloadHome() {
    // Força o HomeScreen a recarregar os documentos
    (_homeKey.currentState as dynamic)?.load?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(key: _homeKey),
          CriarScreen(
            onDocCreated: () {
              // Volta para a home e recarrega
              setState(() => _tab = 0);
              Future.delayed(const Duration(milliseconds: 200), _reloadHome);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: Colors.white,
          selectedItemColor: AriaTheme.acc,
          unselectedItemColor: const Color(0xFFCCCCCC),
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Syne', fontWeight: FontWeight.w800,
            fontSize: 10, letterSpacing: 0.6,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Syne', fontWeight: FontWeight.w700,
            fontSize: 10, letterSpacing: 0.6,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'INÍCIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box_rounded),
              label: 'CRIAR',
            ),
          ],
        ),
      ),
    );
  }
}
