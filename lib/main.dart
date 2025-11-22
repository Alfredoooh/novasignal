import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NovaSignalApp(),
    ),
  );
}

class NovaSignalApp extends StatelessWidget {
  const NovaSignalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          title: 'NovaSignal',
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: themeProvider.isDark ? Brightness.dark : Brightness.light,
            primaryColor: themeProvider.primaryColor,
            scaffoldBackgroundColor: themeProvider.backgroundColor,
            barBackgroundColor: themeProvider.navigationBarColor,
            textTheme: CupertinoTextThemeData(
              primaryColor: themeProvider.textColor,
            ),
          ),
          home: const ChatScreen(),
        );
      },
    );
  }
}