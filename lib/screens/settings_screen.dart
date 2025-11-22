import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final ApiService apiService;

  const SettingsScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TextEditingController _apiKeyController;
  late TextEditingController _maxTokensController;
  late TextEditingController _baseUrlController;
  late String _selectedModel;
  late double _temperature;
  late bool _useProxyNoKey;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Color> _colorOptions = [
    const Color(0xFF0A84FF), // Blue
    const Color(0xFF5856D6), // Purple
    const Color(0xFFFF2D55), // Pink
    const Color(0xFF30D158), // Green
    const Color(0xFFFF9500), // Orange
    const Color(0xFFFF453A), // Red
  ];

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.apiService.apiKey);
    _maxTokensController = TextEditingController(text: widget.apiService.maxTokens.toString());
    _baseUrlController = TextEditingController(text: widget.apiService.baseUrl);
    _selectedModel = widget.apiService.model;
    _temperature = widget.apiService.temperature;
    _useProxyNoKey = widget.apiService.useProxyNoKey;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: themeProvider.navigationBarColor,
        border: Border(
          bottom: BorderSide(
            color: themeProvider.borderColor,
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chevron_left,
                size: 28,
                color: themeProvider.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Chat',
                style: TextStyle(
                  color: themeProvider.primaryColor,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          onPressed: () {
            widget.apiService.updateSettings(
              _apiKeyController.text,
              _selectedModel,
              _temperature,
              int.tryParse(_maxTokensController.text) ?? 2000,
              _baseUrlController.text.trim(),
              _useProxyNoKey,
            );
            Navigator.pop(context);
          },
        ),
        middle: Text(
          themeProvider.translate('settings'),
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            children: [
              const SizedBox(height: 24),

              // Seção de Aparência
              _buildSectionHeader('Aparência', themeProvider),
              _buildSettingsGroup(
                themeProvider,
                children: [
                  _buildSwitchRow(
                    'Tema Escuro',
                    themeProvider.isDark,
                    (value) => themeProvider.toggleTheme(),
                    themeProvider,
                    CupertinoIcons.moon_fill,
                  ),
                  _buildDivider(themeProvider),
                  _buildColorPicker(themeProvider),
                ],
              ),

              const SizedBox(height: 24),

              // Seção de Idioma
              _buildSectionHeader('Idioma', themeProvider),
              _buildSettingsGroup(
                themeProvider,
                children: [
                  _buildLanguageSelector(themeProvider),
                ],
              ),

              const SizedBox(height: 24),

              // Seção de API
              _buildSectionHeader('API Configuration', themeProvider),
              _buildTextFieldRow(
                _apiKeyController,
                'Enter API Key',
                true,
                themeProvider,
                CupertinoIcons.lock,
              ),

              const SizedBox(height: 16),
              _buildTextFieldRow(
                _baseUrlController,
                'https://api.deepseek.com',
                false,
                themeProvider,
                CupertinoIcons.link,
              ),

              const SizedBox(height: 16),
              _buildSettingsGroup(
                themeProvider,
                children: [
                  _buildSwitchRow(
                    'Use proxy sem chave',
                    _useProxyNoKey,
                    (value) {
                      setState(() {
                        _useProxyNoKey = value;
                      });
                    },
                    themeProvider,
                    CupertinoIcons.shield_fill,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Seção de Modelo
              _buildSectionHeader('Model Settings', themeProvider),
              _buildSettingsGroup(
                themeProvider,
                children: [
                  _buildModelSelector(themeProvider),
                  _buildDivider(themeProvider),
                  _buildTemperatureSlider(themeProvider),
                  _buildDivider(themeProvider),
                  _buildMaxTokensField(themeProvider),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(ThemeProvider theme, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    Function(bool) onChanged,
    ThemeProvider theme,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Container(
        height: 0.5,
        color: theme.borderColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildColorPicker(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.paintbrush_fill,
                  color: theme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Cor Primária',
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((color) {
              final isSelected = color.value == theme.primaryColor.value;
              return GestureDetector(
                onTap: () => theme.setPrimaryColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: theme.textColor,
                            width: 3,
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.white,
                          size: 22,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeProvider theme) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 220,
            decoration: BoxDecoration(
              color: theme.navigationBarColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.borderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      theme.setLanguage(index == 0 ? 'pt' : 'en');
                    },
                    children: [
                      Center(
                        child: Text(
                          'Português',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'English',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.globe,
              color: theme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              theme.language == 'pt' ? 'Português' : 'English',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(
    TextEditingController controller,
    String placeholder,
    bool obscure,
    ThemeProvider theme,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                obscureText: obscure,
                placeholder: placeholder,
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey2,
                ),
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 16,
                ),
                decoration: const BoxDecoration(),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector(ThemeProvider theme) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 270,
            decoration: BoxDecoration(
              color: theme.navigationBarColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.borderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 44,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedModel = index == 0
                            ? 'deepseek-chat'
                            : 'deepseek-reasoner';
                      });
                    },
                    children: [
                      Center(
                        child: Text(
                          'deepseek-chat',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'deepseek-reasoner',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.cube_box_fill,
              color: theme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Model',
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _selectedModel,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 18,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureSlider(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.flame_fill,
                      color: theme.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Temperature',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _temperature.toStringAsFixed(1),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoSlider(
            value: _temperature,
            min: 0,
            max: 2,
            divisions: 20,
            activeColor: theme.primaryColor,
            onChanged: (value) {
              setState(() {
                _temperature = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaxTokensField(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.textformat_123,
                  color: theme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Max Tokens',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _maxTokensController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
            ),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _maxTokensController.dispose();
    _baseUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}