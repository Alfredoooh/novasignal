// lib/screens/bot_page.dart
import 'package:flutter/material.dart'

class BotPage extends StatelessWidget {
  const BotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 50,
                color: Color(0xFF1877F2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bot de Trading',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Configure seu bot automatizado\npara fazer trades inteligentes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}