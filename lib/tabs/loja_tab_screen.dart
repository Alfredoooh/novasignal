import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class LojaTabScreen extends StatelessWidget {
  final Color bgColor;
  final bool isDark;
  final String currentLocale;

  const LojaTabScreen({
    Key? key,
    required this.bgColor,
    required this.isDark,
    required this.currentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: const SizedBox.shrink(),
    );
  }
}