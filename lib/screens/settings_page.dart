// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Português';
  String _selectedTheme = 'Escuro';
  bool _biometricsEnabled = false;

  final List<String> _languages = [
    'Português',
    'English',
    'Español',
    'Français',
    'Deutsch',
    '中文',
    '日本語',
  ];

  final List<String> _themes = [
    'Escuro',
    'Claro',
    'Automático',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Carregar configurações salvas
    // Exemplo: SharedPreferences ou Firebase
  }

  Future<void> _saveLanguage(String language) async {
    setState(() => _selectedLanguage = language);
    // Salvar no storage e aplicar mudança
  }

  Future<void> _saveTheme(String theme) async {
    setState(() => _selectedTheme = theme);
    // Salvar no storage e aplicar mudança
  }

  Future<void> _saveBiometrics(bool value) async {
    setState(() => _biometricsEnabled = value);
    // Salvar no storage e configurar biometria
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A0A0A);
    const cardColor = Color(0xFF1C1C1E);
    const textColor = Color(0xFFFFFFFF);
    const secondaryColor = Color(0xFF8E8E93);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: bgColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: cardColor,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFF2C2C2E),
              width: 0.5,
            ),
          ),
          leading: CupertinoNavigationBarBackButton(
            color: textColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
          middle: const Text(
            'Configurações',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              _buildIOSSection(
                title: 'APARÊNCIA',
                children: [
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.globe,
                    title: 'Idioma',
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showLanguagePicker(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: const TextStyle(
                              color: secondaryColor,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.paintbrush,
                    title: 'Tema',
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showThemePicker(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedTheme,
                            style: const TextStyle(
                              color: secondaryColor,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: secondaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _buildIOSSection(
                title: 'SEGURANÇA',
                children: [
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.lock_shield,
                    title: 'Autenticação Biométrica',
                    trailing: CupertinoSwitch(
                      value: _biometricsEnabled,
                      onChanged: (value) => _saveBiometrics(value),
                      activeColor: const Color(0xFFFF6A2F),
                    ),
                  ),
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.lock_rotation,
                    title: 'Alterar PIN',
                    trailing: const Icon(
                      CupertinoIcons.right_chevron,
                      size: 16,
                      color: secondaryColor,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              _buildIOSSection(
                title: 'SOBRE',
                children: [
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.info_circle,
                    title: 'Versão',
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.doc_text,
                    title: 'Termos de Uso',
                    trailing: const Icon(
                      CupertinoIcons.right_chevron,
                      size: 16,
                      color: secondaryColor,
                    ),
                    onTap: () {},
                  ),
                  _buildIOSSettingItem(
                    icon: CupertinoIcons.shield,
                    title: 'Política de Privacidade',
                    trailing: const Icon(
                      CupertinoIcons.right_chevron,
                      size: 16,
                      color: secondaryColor,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoButton(
                  color: CupertinoColors.destructiveRed,
                  onPressed: () {
                    // Logout logic
                  },
                  child: const Text('Sair da Conta'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    // Material Design para Android
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildMaterialSection(
            title: 'APARÊNCIA',
            children: [
              _buildMaterialSettingItem(
                icon: Icons.language,
                title: 'Idioma',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
              _buildMaterialSettingItem(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: _selectedTheme,
                onTap: () => _showThemeDialog(context),
              ),
            ],
          ),
          _buildMaterialSection(
            title: 'SEGURANÇA',
            children: [
              _buildMaterialSwitchItem(
                icon: Icons.fingerprint,
                title: 'Autenticação Biométrica',
                value: _biometricsEnabled,
                onChanged: (value) => _saveBiometrics(value),
              ),
              _buildMaterialSettingItem(
                icon: Icons.lock_outline,
                title: 'Alterar PIN',
                onTap: () {},
              ),
            ],
          ),
          _buildMaterialSection(
            title: 'SOBRE',
            children: [
              _buildMaterialSettingItem(
                icon: Icons.info_outline,
                title: 'Versão',
                subtitle: '1.0.0',
              ),
              _buildMaterialSettingItem(
                icon: Icons.description_outlined,
                title: 'Termos de Uso',
                onTap: () {},
              ),
              _buildMaterialSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidade',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Logout logic
              },
              child: const Text(
                'Sair da Conta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // iOS Widgets
  Widget _buildIOSSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildIOSSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6A2F), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: const Color(0xFF1C1C1E),
        child: Column(
          children: [
            Container(
              height: 44,
              color: const Color(0xFF2C2C2E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Confirmar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFF1C1C1E),
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  _saveLanguage(_languages[index]);
                },
                children: _languages.map((String language) {
                  return Center(
                    child: Text(
                      language,
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: const Color(0xFF1C1C1E),
        child: Column(
          children: [
            Container(
              height: 44,
              color: const Color(0xFF2C2C2E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Confirmar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                backgroundColor: const Color(0xFF1C1C1E),
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  _saveTheme(_themes[index]);
                },
                children: _themes.map((String theme) {
                  return Center(
                    child: Text(
                      theme,
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Material Design Widgets
  Widget _buildMaterialSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMaterialSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF6A2F)),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFFFFFFF)),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF8E8E93)),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Color(0xFF8E8E93))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildMaterialSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF6A2F)),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFFFFFFF)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFFF6A2F),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'Selecione o Idioma',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _languages.map((language) {
                return RadioListTile<String>(
                  title: Text(
                    language,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                  value: language,
                  groupValue: _selectedLanguage,
                  activeColor: const Color(0xFFFF6A2F),
                  onChanged: (String? value) {
                    _saveLanguage(value!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'Selecione o Tema',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _themes.map((theme) {
                return RadioListTile<String>(
                  title: Text(
                    theme,
                    style: const TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                  value: theme,
                  groupValue: _selectedTheme,
                  activeColor: const Color(0xFFFF6A2F),
                  onChanged: (String? value) {
                    _saveTheme(value!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}