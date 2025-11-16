// lib/screens/user_profile_page.dart
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

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
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1877F2),
                child: Icon(Icons.person, size: 40, color: Colors.white),
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

        // Opções do perfil
        _buildProfileOption(Icons.account_circle_outlined, 'Minha Conta'),
        _buildProfileOption(Icons.security_outlined, 'Segurança'),
        _buildProfileOption(Icons.notifications_outlined, 'Notificações'),
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