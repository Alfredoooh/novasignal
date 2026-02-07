import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'trading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const DerivApp());
}

class DerivApp extends StatelessWidget {
  const DerivApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deriv Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: '-apple-system',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            HomeScreen(),
            MarketsScreen(),
            TradingScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                _homeSvg,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                _marketsSvg,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Mercados',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.string(
                _tradingSvg,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
                  BlendMode.srcIn,
                ),
              ),
              label: 'Operar',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF3B82F6),
          unselectedItemColor: const Color(0xFF9CA3AF),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Início',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Markets Screen
class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Mercados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// SVG Icons
const String _homeSvg = '''
<svg width="22" height="22" viewBox="0 0 512 512">
  <path d="M256,319.841c-35.346,0-64,28.654-64,64v128h128v-128C320,348.495,291.346,319.841,256,319.841z"/>
  <path d="M362.667,383.841v128H448c35.346,0,64-28.654,64-64V253.26c0.005-11.083-4.302-21.733-12.011-29.696l-181.29-195.99c-31.988-34.61-85.976-36.735-120.586-4.747c-1.644,1.52-3.228,3.103-4.747,4.747L12.395,223.5C4.453,231.496-0.003,242.31,0,253.58v194.261c0,35.346,28.654,64,64,64h85.333v-128c0.399-58.172,47.366-105.676,104.073-107.044C312.01,275.383,362.22,323.696,362.667,383.841z"/>
</svg>
''';

const String _marketsSvg = '''
<svg width="22" height="22" viewBox="0 0 24 24">
  <path d="M24,23c0,.55-.45,1-1,1H5c-2.76,0-5-2.24-5-5V1C0,.45,.45,0,1,0s1,.45,1,1V19c0,1.65,1.35,3,3,3H23c.55,0,1,.45,1,1ZM15,11V5c0-1.1,.9-2,2-2V1c0-.55,.45-1,1-1s1,.45,1,1V3c1.1,0,2,.9,2,2v6c0,1.1-.9,2-2,2v2c0,.55-.45,1-1,1s-1-.45-1-1v-2c-1.1,0-2-.9-2-2Zm2,0h2V5h-2v6Zm-11,3V5c0-1.1,.9-2,2-2V1c0-.55,.45-1,1-1s1,.45,1,1V3c1.1,0,2,.9,2,2V14c0,1.1-.9,2-2,2v2c0,.55-.45,1-1,1s-1-.45-1-1v-2c-1.1,0-2-.9-2-2Zm2,0h2V5h-2V14Z"/>
</svg>
''';

const String _tradingSvg = '''
<svg width="22" height="22" viewBox="0 0 24 24">
  <path d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>
''';
