import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/balance_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
      ],
      child: CoinBoxApp(),
    ),
  );
}

class CoinBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0088CC),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        primaryColor: Color(0xFF0088CC),
        scaffoldBackgroundColor: Color(0xFF18191A),
        brightness: Brightness.dark,
      ),
      home: HomeScreen(),
    );
  }
}
