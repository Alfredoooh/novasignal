import 'package:flutter/material.dart';

// screens/home/home_screen.dart (estrutura básica)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DocMarket')),
      body: const Center(child: Text('Tela Principal')),
    );
  }
}
