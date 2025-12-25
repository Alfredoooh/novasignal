// ==================== comunidade_page.dart ====================
import 'package:flutter/material.dart';

class ComunidadePage extends StatelessWidget {
  const ComunidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups_rounded,
                size: 80,
                color: cs.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Comunidade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Conecte-se com outros membros da comunidade',
                style: TextStyle(
                  fontSize: 16,
                  color: cs.onBackground.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
