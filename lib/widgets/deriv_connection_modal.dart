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
            duration: Duration(seconds: 2),
          ),
        );

        // Fechar modal e atualizar a tela
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pop(context);
            widget.onConnected();
          }
        });
      }
    });

    _derivAuthService.onAuthError((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $error'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
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

    // Validar formato básico do token (deve começar com letra e ter pelo menos 20 caracteres)
    if (token.length < 20) {
      setState(() => _errorMessage = 'Token inválido. Muito curto.');
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _derivAuthService.connectWithApiToken(token);

      if (success) {
        // Sucesso - callback será chamado
        if (mounted) {
          setState(() {
            _successMessage = 'Conectado com sucesso!';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Falha ao conectar. Verifique seu token.';
            _isConnecting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro: ${e.toString()}';
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _connectWithOAuth() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final success = await _derivAuthService.connectWithOAuth();

      if (success) {
        if (mounted) {
          // OAuth foi iniciado com sucesso
          // Mostrar mensagem e aguardar callback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aguardando autenticação no Deriv...'),
              backgroundColor: Color(0xFFFF6A2F),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Não foi possível abrir a autenticação';
            _isConnecting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao iniciar OAuth: ${e.toString()}';
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF8E8E93),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Cabeçalho
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Expanded(
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
                      SizedBox(height: 4),
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
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

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
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
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
          const SizedBox(height: 16),

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
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_successMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                _buildStep('3', 'Crie um novo token API com permissões: Read, Trade'),
                _buildStep('4', 'Copie o token e cole abaixo'),
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
              hintText: 'Cole seu token aqui (ex: a1-b2c3d4...)',
              hintStyle: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste, color: Color(0xFFFF6A2F)),
                tooltip: 'Colar da área de transferência',
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data != null && data.text != null) {
                    setState(() {
                      _tokenController.text = data.text!.trim();
                      _errorMessage = null;
                    });
                  }
                },
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 3,
            minLines: 2,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
          ),
          
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 13,
                ),
              ),
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
                      'Conectar com Token',
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
              onPressed: () async {
                final url = Uri.parse('https://api.deriv.com');
                // Usar url_launcher para abrir
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}