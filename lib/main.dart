import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(const DocuGenApp());
}

class DocuGenApp extends StatelessWidget {
  const DocuGenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DocuGen AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF212529),
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DocuGenHomePage(),
          );
        },
      ),
    );
  }
}