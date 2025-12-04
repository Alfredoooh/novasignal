// lib/screens/storage_screen.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class StorageScreen extends StatelessWidget {
  final bool isDarkMode;

  const StorageScreen({
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
          'Armazenamento',
          style: TextStyle(color: textColor),
        ),
      ),
      body: Container(),
    );
  }
}