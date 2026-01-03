import 'package:flutter/material.dart';

class MetodoPagamentoPage extends StatefulWidget {
  const MetodoPagamentoPage({super.key});

  @override
  State<MetodoPagamentoPage> createState() => _MetodoPagamentoPageState();
}

class _MetodoPagamentoPageState extends State<MetodoPagamentoPage> {
  String? metodoselecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Método de Pagamento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Selecione como deseja pagar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Cartão de Crédito
                  _buildMetodoPagamento(
                    icon: Icons.credit_card,
                    titulo: 'Cartão de Crédito',
                    subtitulo: 'Visa, Mastercard, Amex',
                    valor: 'credito',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Cartão de Débito
                  _buildMetodoPagamento(
                    icon: Icons.payment,
                    titulo: 'Cartão de Débito',
                    subtitulo: 'Débito direto',
                    valor: 'debito',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // PIX
                  _buildMetodoPagamento(
                    icon: Icons.qr_code_2,
                    titulo: 'PIX',
                    subtitulo: 'Pagamento instantâneo',
                    valor: 'pix',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Boleto
                  _buildMetodoPagamento(
                    icon: Icons.receipt_long,
                    titulo: 'Boleto Bancário',
                    subtitulo: 'Vencimento em 3 dias',
                    valor: 'boleto',
                  ),
                ],
              ),
            ),
            
            // Botão Confirmar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: metodoselecionado != null
                    ? () {
                        // Ação de confirmar pagamento
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pagamento via $metodoselecionado selecionado',
                            ),
                            backgroundColor: const Color(0xFFFF444F),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFF444F),
                  disabledBackgroundColor: Colors.white.withOpacity(0.3),
                  disabledForegroundColor: Colors.white60,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetodoPagamento({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required String valor,
  }) {
    final bool selecionado = metodoselecionado == valor;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          metodoselecionado = valor;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selecionado 
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado 
                ? Colors.white
                : Colors.white.withOpacity(0.1),
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (selecionado)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}