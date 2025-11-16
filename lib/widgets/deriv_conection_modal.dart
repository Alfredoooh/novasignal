// lib/widgets/deriv_connection_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deriv_service.dart';

class DerivConnectionModal extends StatefulWidget {
  final VoidCallback onConnected;

  const DerivConnectionModal({
    super.key,
    required this.onConnected,
  });

  @override
  State<DerivConnectionModal> createState() => _DerivConnectionModalState();
}

class _DerivConnectionModalState extends State<DerivConnectionModal> {
  final TextEditingController _tokenController = TextEditingController();
  final DerivService _derivService = DerivService();
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connectToDeriv() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      setState(() => _errorMessage = 'Por favor, insira o token API');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final success = await _derivService.connect(token);

      if (success && mounted) {
        // Salvar token localmente (você pode usar SharedPreferences ou Firebase)
        widget.onConnected();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conectado ao Deriv com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Falha ao conectar. Verifique seu token.';
          _isConnecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao conectar: ${e.toString()}';
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E8E93),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              const Text(
                'Conectar ao Deriv',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Conecte sua conta Deriv para começar a negociar',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 24),

              // Instruções
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Como obter o token API',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep('1', 'Acesse api.deriv.com'),
                    _buildStep('2', 'Faça login na sua conta'),
                    _buildStep('3', 'Gere um novo token API'),
                    _buildStep('4', 'Copie e cole abaixo'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campo de token
              TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: 'Token API',
                  labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                  hintText: 'Cole seu token aqui',
                  hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6A2F),
                      width: 2,
                    ),
                  ),
                  errorText: _errorMessage,
                  errorStyle: const TextStyle(color: Color(0xFFEF4444)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste, color: Color(0xFFFF6A2F)),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data != null) {
                        _tokenController.text = data.text ?? '';
                      }
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Botão de conectar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connectToDeriv,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A2F),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF8E8E93),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Conectar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Link para obter token
              Center(
                child: TextButton(
                  onPressed: () {
                    // Abrir link do Deriv API
                  },
                  child: const Text(
                    'Não tem um token? Obtenha aqui',
                    style: TextStyle(
                      color: Color(0xFFFF6A2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6A2F).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF6A2F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ],
      ),
    );
  }
}