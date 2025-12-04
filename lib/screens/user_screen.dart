// lib/screens/user_screen.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class UserScreen extends StatelessWidget {
  final bool isDarkMode;

  const UserScreen({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF212529) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF212529);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Ionicons.close_outline, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Usuário',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Container(),
    );
  }
}