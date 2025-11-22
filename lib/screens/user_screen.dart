import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onAddPressed: () {
          HapticFeedback.mediumImpact();
        },
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildProfileTab(),
                _buildThemeTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFA500)],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuário',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'usuario@email.com',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF8E8E93),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        onTap: (_) => HapticFeedback.lightImpact(),
        tabs: const [
          Tab(text: 'Perfil'),
          Tab(text: 'Tema'),
          Tab(text: 'Configurações'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoCard(
            icon: Ionicons.person_outline,
            title: 'Nome',
            value: 'Usuário',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Ionicons.mail_outline,
            title: 'Email',
            value: 'usuario@email.com',
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Ionicons.calendar_outline,
            title: 'Membro desde',
            value: 'Janeiro 2024',
          ),
          const SizedBox(height: 20),
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Documentos',
                  value: '143',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Armazenamento',
                  value: '4.2 GB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aparência',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 15),
              _buildSwitchCard(
                icon: themeProvider.isDark
                    ? Ionicons.moon_outline
                    : Ionicons.sunny_outline,
                title: 'Modo Escuro',
                subtitle: themeProvider.isDark ? 'Ativado' : 'Desativado',
                value: themeProvider.isDark,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  themeProvider.toggleTheme();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Cor de Destaque',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildColorOption(
                    color: const Color(0xFFFF375F),
                    isSelected: themeProvider.accentColor.value == 0xFFFF375F,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFFFF375F));
                    },
                  ),
                  _buildColorOption(
                    color: const Color(0xFF007AFF),
                    isSelected: themeProvider.accentColor.value == 0xFF007AFF,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFF007AFF));
                    },
                  ),
                  _buildColorOption(
                    color: const Color(0xFF34C759),
                    isSelected: themeProvider.accentColor.value == 0xFF34C759,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFF34C759));
                    },
                  ),
                  _buildColorOption(
                    color: const Color(0xFFFF9500),
                    isSelected: themeProvider.accentColor.value == 0xFFFF9500,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFFFF9500));
                    },
                  ),
                  _buildColorOption(
                    color: const Color(0xFFAF52DE),
                    isSelected: themeProvider.accentColor.value == 0xFFAF52DE,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFFAF52DE));
                    },
                  ),
                  _buildColorOption(
                    color: const Color(0xFFFF2D55),
                    isSelected: themeProvider.accentColor.value == 0xFFFF2D55,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      themeProvider.setAccentColor(const Color(0xFFFF2D55));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingCard(
            icon: Ionicons.notifications_outline,
            title: 'Notificações',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            icon: Ionicons.lock_closed_outline,
            title: 'Privacidade',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            icon: Ionicons.shield_checkmark_outline,
            title: 'Segurança',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            icon: Ionicons.language_outline,
            title: 'Idioma',
            subtitle: 'Português',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sobre',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingCard(
            icon: Ionicons.information_circle_outline,
            title: 'Sobre o App',
            subtitle: 'Versão 1.0.0',
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            icon: Ionicons.help_circle_outline,
            title: 'Ajuda & Suporte',
            onTap: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF375F), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF375F), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF375F),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Ionicons.checkmark, color: Colors.white, size: 28)
            : null,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF375F), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Ionicons.chevron_forward_outline,
              size: 20,
              color: Color(0xFF8E8E93),
            ),
          ],
        ),
      ),
    );
  }
}