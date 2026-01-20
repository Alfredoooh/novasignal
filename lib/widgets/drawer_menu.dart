import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../assets/app_icons.dart';

const Color primaryColor = Color(0xFF2C3E50);

class DrawerMenu extends StatelessWidget {
  final String appName;
  final String settingsLabel;
  final VoidCallback onSettingsTap;

  const DrawerMenu({
    Key? key,
    required this.appName,
    required this.settingsLabel,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerBgColor = primaryColor;

    return Container(
      width: 280,
      color: drawerBgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    appName,
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            GestureDetector(
              onTap: onSettingsTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.string(AppIcons.settingsIcon, color: const Color(0xFFFFFFFF)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      settingsLabel,
                      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}