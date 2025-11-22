import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  final ApiService apiService;

  const SettingsScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;
  late TextEditingController _maxTokensController;
  late TextEditingController _baseUrlController;
  late String _selectedModel;
  late double _temperature;
  late bool _useProxyNoKey;

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
                style: TextStyle(color: themeProvider.primaryColor),
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
          style: TextStyle(color: themeProvider.textColor),
        ),
      ),
      child: SafeArea(
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
            _buildSectionHeader('API Key', themeProvider),
            _buildTextFieldRow(
              _apiKeyController,
              'Enter API Key',
              true,
              themeProvider,
            ),

            const SizedBox(height: 16),
            _buildSectionHeader('Base URL', themeProvider),
            _buildTextFieldRow(
              _baseUrlController,
              'https://api.deepseek.com',
              false,
              themeProvider,
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Seção de Modelo
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
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.systemGrey,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(ThemeProvider theme, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool) onChanged, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
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
        color: theme.borderColor,
      ),
    );
  }

  Widget _buildColorPicker(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cor Primária',
            style: TextStyle(
              color: theme.textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((color) {
              final isSelected = color.value == theme.primaryColor.value;
              return GestureDetector(
                onTap: () => theme.setPrimaryColor(color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: theme.textColor, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.white,
                          size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 200,
            color: theme.navigationBarColor,
            child: Column(
              children: [
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
                        child: const Text('Done'),
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
                          style: TextStyle(color: theme.textColor),
                        ),
                      ),
                      Center(
                        child: Text(
                          'English',
                          style: TextStyle(color: theme.textColor),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            theme.language == 'pt' ? 'Português' : 'English',
            style: TextStyle(color: theme.textColor, fontSize: 16),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 16,
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
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: CupertinoTextField(
        controller: controller,
        obscureText: obscure,
        placeholder: placeholder,
        placeholderStyle: const TextStyle(
          color: CupertinoColors.systemGrey2,
        ),
        style: TextStyle(color: theme.textColor),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildModelSelector(ThemeProvider theme) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 250,
            color: theme.navigationBarColor,
            child: Column(
              children: [
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
                        child: const Text('Done'),
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
                          style: TextStyle(color: theme.textColor),
                        ),
                      ),
                      Center(
                        child: Text(
                          'deepseek-reasoner',
                          style: TextStyle(color: theme.textColor),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Model',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
              Text(
                _selectedModel,
                style: TextStyle(color: theme.textColor, fontSize: 16),
              ),
            ],
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
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
          Text(
            'Temperature: ${_temperature.toStringAsFixed(1)}',
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 13,
            ),
          ),
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
          const Text(
            'Max Tokens',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _maxTokensController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: theme.textColor),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
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
    super.dispose();
  }
}