import 'package:flutter/material.dart';

// screens/profile/profile_screen.dart (estrutura básica)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(child: Text('Tela de Perfil')),
    );
  }
}