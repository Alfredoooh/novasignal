// lib/screens/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../services/deriv_service.dart';
import '../widgets/deriv_connection_modal.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DerivService _derivService = DerivService();
  bool _isConnectedToDeriv = false;
  String? _derivAccountId;
  double? _derivBalance;

  @override
  void initState() {
    super.initState();
    _checkDerivConnection();
  }

  Future<void> _checkDerivConnection() async {
    // CORRIGIDO: Removido os parênteses () - agora é um getter
    final isConnected = await _derivService.isConnected;
    if (mounted) {
      setState(() {
        _isConnectedToDeriv = isConnected;
        if (isConnected) {
          _loadDerivAccountInfo();
        }
      });
    }
  }

  Future<void> _loadDerivAccountInfo() async {
    final accountInfo = await _derivService.getAccountInfo();
    if (mounted && accountInfo != null) {
      setState(() {
        _derivAccountId = accountInfo['loginid'];
        _derivBalance = accountInfo['balance'];
      });
    }
  }

  void _showDerivConnectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DerivConnectionModal(
        onConnected: () {
          _checkDerivConnection();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _disconnectDeriv() async {
    final confirm = await _showConfirmDialog(
      'Desconectar Deriv',
      'Tem certeza que deseja desconectar sua conta Deriv?',
    );

    if (confirm) {
      await _derivService.disconnect();
      setState(() {
        _isConnectedToDeriv = false;
        _derivAccountId = null;
        _derivBalance = null;
      });
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ) ?? false;
    } else {
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Color(0xFF8E8E93))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header do perfil
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF1C1C1E),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Usuário',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'usuario@email.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Card de conexão Deriv
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _isConnectedToDeriv
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isConnectedToDeriv ? Icons.check_circle : Icons.link,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isConnectedToDeriv ? 'Deriv Conectado' : 'Conectar Deriv',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isConnectedToDeriv && _derivAccountId != null) ...[
                const SizedBox(height: 12),
                Text(
                  'ID: $_derivAccountId',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                if (_derivBalance != null)
                  Text(
                    'Saldo: \$${_derivBalance!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConnectedToDeriv ? _disconnectDeriv : _showDerivConnectionModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _isConnectedToDeriv 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFFF6A2F),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isConnectedToDeriv ? 'Desconectar' : 'Conectar Agora',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Opções do perfil
        _buildProfileOption(Icons.account_circle_outlined, 'Minha Conta'),
        _buildProfileOption(Icons.security_outlined, 'Segurança'),
        _buildProfileOption(Icons.help_outline, 'Ajuda'),
        _buildProfileOption(Icons.info_outline, 'Sobre'),
        _buildProfileOption(Icons.logout, 'Sair', isDestructive: true),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? const Color(0xFFEF4444) : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? const Color(0xFFEF4444) : Colors.white,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF8E8E93),
        ),
        onTap: () {},
      ),
    );
  }
}