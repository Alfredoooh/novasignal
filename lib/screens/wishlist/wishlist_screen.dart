import 'package:flutter/material.dart';

// screens/wishlist/wishlist_screen.dart (estrutura básica)
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Desejos')),
      body: const Center(child: Text('Tela de Wishlist')),
    );
  }
}