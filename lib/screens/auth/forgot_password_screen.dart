import 'package:flutter/material.dart';

// screens/auth/forgot_password_screen.dart (estrutura básica)
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: const Center(child: Text('Tela de Recuperação de Senha')),
    );
  }
}
