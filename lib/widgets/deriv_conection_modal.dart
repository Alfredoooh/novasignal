// lib/widgets/deriv_connection_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deriv_auth_service.dart';

class DerivConnectionModal extends StatefulWidget {
  final VoidCallback onConnected;

  const DerivConnectionModal({
    super.key,
    required this.onConnected,
  });

  @override
  State<DerivConnectionModal> createState() => _DerivConnectionModalState();
}

class _DerivConnectionModalState extends State<DerivConnectionModal> with SingleTickerProviderStateMixin {
  final TextEditingController _tokenController = TextEditingController();
  final DerivAuthService _derivAuthService = DerivAuthService();
  
  late TabController _tabController;
  bool _isConnecting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupAuthCallbacks();
  }

  void _setupAuthCallbacks() {
    _derivAuthService.onAuthSuccess((token) {
      if (mounted) {
        setState(() {
          _successMessage = 'Conectado com sucesso!';
          _isConnecting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conectado ao Deriv com sucesso!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onConnected();
        });
      }
    });

    _derivAuthService.onAuthError((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _isConnecting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _connectWithToken() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      setState(() => _errorMessage = 'Por favor, insira o token API');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final success = await _derivAuthService.connectWithApiToken(token);

    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Falha ao conectar. Verifique seu token.';
        _isConnecting = false;
      });
    }
  }

  Future<void> _connectWithOAuth() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final success = await _derivAuthService.connectWithOAuth();

    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Não foi possível abrir a autenticação';
        _isConnecting = false;
      });
    }
    // O callback será chamado quando o deep link retornar
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conectar ao Deriv',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Escolha o método de conexão',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF8E8E93),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'OAuth (Fácil)'),
                Tab(text: 'Token API'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOAuthTab(),
                _buildTokenTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOAuthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações sobre OAuth
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
                        Icons.security,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Método Recomendado',
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
                const Text(
                  '✓ Autenticação segura via Deriv\n'
                  '✓ Não precisa copiar tokens\n'
                  '✓ Login com email e senha\n'
                  '✓ Conexão automática',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Como funciona
          const Text(
            'Como funciona:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Clique em "Conectar com Deriv"'),
          _buildStep('2', 'Faça login na página do Deriv'),
          _buildStep('3', 'Autorize o NovaSignal'),
          _buildStep('4', 'Você será redirecionado automaticamente'),
          const SizedBox(height: 24),

          // Mensagens de status
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
          if (_successMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
          if (_errorMessage != null || _successMessage != null)
            const SizedBox(height: 16),

          // Botão de conectar OAuth
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectWithOAuth,
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Conectar com Deriv',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTokenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        Icons.key,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Como obter o token',
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
                _buildStep('3', 'Crie um novo token API'),
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
            maxLines: 2,
            obscureText: false,
          ),
          const SizedBox(height: 24),

          // Botão de conectar com token
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectWithToken,
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
            child: TextButton.icon(
              onPressed: () {
                // Abrir link do Deriv API
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Obter token no Deriv'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6A2F),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
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