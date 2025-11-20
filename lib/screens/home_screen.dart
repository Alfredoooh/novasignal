import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_icons.dart';
import 'document_requests_screen.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget?> _pages = [null, null];
  static const Color _activeBlue = Color(0xFF1877F2);

  final List<String> _tabTitles = [
    'Editor',
    'Novo Pedido',
  ];

  final List<String> _outlinedSvgs = [
    CustomIcons.book,
    CustomIcons.addCircle,
  ];

  final List<String> _filledSvgs = [
    CustomIcons.bookFilled ?? CustomIcons.book,
    CustomIcons.addCircleFilled ?? CustomIcons.addCircle,
  ];

  Widget _getPage(int index) {
    if (_pages[index] != null) return _pages[index]!;
    switch (index) {
      case 0:
        _pages[0] = const EditorScreen();
        break;
      case 1:
        _pages[1] = const DocumentRequestsScreen();
        break;
      default:
        _pages[index] = const SizedBox.shrink();
    }
    return _pages[index]!;
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    _hideKeyboard();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDarkMode;
    final scaffoldBgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F2F5);
    final unselectedColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);

    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: List.generate(2, (i) => _getPage(i)),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(2, (index) {
                    final active = _currentIndex == index;
                    final color = active ? _activeBlue : unselectedColor;
                    final svg = active ? _filledSvgs[index] : _outlinedSvgs[index];

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTap(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.string(
                              svg,
                              width: 17.28,
                              height: 17.28,
                              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tabTitles[index],
                              style: TextStyle(
                                fontSize: 9.9,
                                color: color,
                                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}