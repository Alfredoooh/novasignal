// lib/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter_svg/flutter_svg.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  static const String _viewType = 'chat-input-only';
  static bool _viewRegistered = false;
  html.InputElement? _htmlInput;

  static const String _sendIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          final inputBgColor = themeProvider.isDarkMode ? '#495057' : '#FFFFFF';
          final inputTextColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';
          final inputPlaceholderColor = themeProvider.isDarkMode ? '#ADB5BD' : '#6C757D';

          final element = html.DivElement()
            ..id = 'chat-input-wrapper-$viewId'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'flex'
            ..style.alignItems = 'center';

          _htmlInput = html.InputElement()
            ..id = 'chatInput-$viewId'
            ..type = 'text'
            ..placeholder = 'Ask DocuGen'
            ..autocomplete = 'off'
            ..setAttribute('spellcheck', 'false')
            ..style.flex = '1'
            ..style.padding = '12px 20px'
            ..style.border = 'none'
            ..style.borderRadius = '24px'
            ..style.fontSize = '16px'
            ..style.outline = 'none'
            ..style.backgroundColor = inputBgColor
            ..style.color = inputTextColor
            ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
            ..style.transition = 'background-color 0.3s'
            ..style.setProperty('-webkit-user-select', 'text')
            ..style.userSelect = 'text'
            ..style.setProperty('-webkit-tap-highlight-color', 'transparent');

          // CSS para placeholder
          final style = html.StyleElement()
            ..text = '''
              #chatInput-$viewId::placeholder {
                color: $inputPlaceholderColor;
              }
              #chatInput-$viewId:focus {
                box-shadow: none !important;
                outline: none !important;
              }
            ''';

          element.append(style);
          element.append(_htmlInput!);

          // Listener para Enter
          _htmlInput!.onKeyPress.listen((e) {
            if (e.key == 'Enter') {
              e.preventDefault();
              _sendMessageFromHtml();
            }
          });

          // Remover foco ao clicar fora
          element.onClick.listen((e) {
            if (e.target != _htmlInput) {
              _htmlInput?.blur();
            }
          });

          return element;
        },
      );
    } catch (e) {
      debugPrint('Error registering view: $e');
    }
  }

  void _sendMessageFromHtml() {
    if (_htmlInput != null) {
      final text = _htmlInput!.value?.trim() ?? '';
      if (text.isNotEmpty) {
        _sendMessage(text);
        _htmlInput!.value = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'DocuGen',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                    ),
                  ),
                ],
              ),
            ),
            // Messages Area
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.chatbubble_ellipses_outline,
                            size: 64,
                            color: themeProvider.isDarkMode 
                                ? Colors.grey.shade700 
                                : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comece uma conversa',
                            style: TextStyle(
                              color: themeProvider.isDarkMode 
                                  ? Colors.grey.shade600 
                                  : Colors.grey.shade400,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Envie uma mensagem para iniciar',
                            style: TextStyle(
                              color: themeProvider.isDarkMode 
                                  ? Colors.grey.shade600 
                                  : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index], themeProvider);
                      },
                    ),
            ),
          ],
        ),
        _buildInputArea(themeProvider),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeProvider themeProvider) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? (themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFF212529))
              : (themeProvider.isDarkMode ? const Color(0xFF343A40) : const Color(0xFFF1F3F5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser 
                ? Colors.white 
                : (themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529)),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeProvider themeProvider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Input (HTML no web, nativo no app)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: kIsWeb
                        ? HtmlElementView(
                            viewType: _viewType,
                            key: ValueKey(themeProvider.isDarkMode),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: 'Ask DocuGen',
                                hintStyle: TextStyle(
                                  color: themeProvider.isDarkMode ? Colors.white54 : const Color(0xFFADB5BD),
                                  fontSize: 16,
                                ),
                              ),
                              cursorColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                              enableSuggestions: false,
                              autocorrect: false,
                              onSubmitted: (_) => _sendMessageNative(),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botão de enviar (sempre Flutter nativo)
                GestureDetector(
                  onTap: kIsWeb ? _sendMessageFromHtml : _sendMessageNative,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFF212529),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.string(
                        _sendIconSvg,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessageNative() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _sendMessage(text);
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    if (!mounted) return;
    
    debugPrint('📨 Mensagem enviada: $text');
    
    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}