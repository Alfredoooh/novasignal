import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'menu_screen.dart';
import 'package:novasignal/screens/pages/home_page.dart';
import 'package:novasignal/screens/pages/editor_pages.dart';
import 'package:novasignal/widgets/home/custom_search_delegate.dart';
import 'package:novasignal/screen/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const EditorPage(),
  ];

  void _showLoginModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: LoginScreen(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuScreen(),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/menu_icon.svg',
                            width: 21.6,
                            height: 21.6,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onBackground,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SvgPicture.asset(
                          'assets/logo.svg',
                          height: 25.2,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            showSearch(
                              context: context,
                              delegate: CustomSearchDelegate(),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/search_icon.svg',
                            width: 21.6,
                            height: 21.6,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onBackground,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        if (isLoggedIn)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/profile');
                            },
                            child: Container(
                              width: 28.8,
                              height: 28.8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  user.email?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _showLoginModal,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 14.4, vertical: 7.2),
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Começar',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: _pages[_currentIndex]),
            ],
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
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 0),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/home_icon.svg',
                              width: 21.6,
                              height: 21.6,
                              colorFilter: ColorFilter.mode(
                                _currentIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Início',
                              style: TextStyle(
                                fontSize: 9.9,
                                color: _currentIndex == 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: _currentIndex == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/editor_icon.svg',
                              width: 21.6,
                              height: 21.6,
                              colorFilter: ColorFilter.mode(
                                _currentIndex == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Editor',
                              style: TextStyle(
                                fontSize: 9.9,
                                color: _currentIndex == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: _currentIndex == 1
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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