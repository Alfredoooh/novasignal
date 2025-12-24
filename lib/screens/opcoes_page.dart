// ==================== opcoes_page.dart ====================
import 'package:flutter/material.dart';
import 'trading_aviso_page.dart';

class OpcoesPage extends StatelessWidget {
  const OpcoesPage({super.key});

  void _navegarParaTrading(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TradingAvisoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: const SafeArea(
        child: SizedBox.shrink(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(top: BorderSide(color: cs.surfaceVariant)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _navegarParaTrading(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF444F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Negociar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}