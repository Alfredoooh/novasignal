// lib/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoading = false;
  String? _conversationTitle;

  static const String _groqApiKey = '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';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _sendIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  static const String _stopIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="6" y="6" width="12" height="12" rx="2" fill="#FFFFFF"/>
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

          _htmlInput!.onKeyPress.listen((e) {
            if (e.key == 'Enter') {
              e.preventDefault();
              _sendMessageFromHtml();
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
      if (text.isNotEmpty && !_isLoading) {
        _sendMessage(text);
        _htmlInput!.value = '';
      }
    }
  }

  // Fechar teclado ao clicar fora
  void _unfocusKeyboard() {
    _focusNode.unfocus();
    if (kIsWeb && _htmlInput != null) {
      _htmlInput!.blur();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Column(
            children: [
              // Header (removido o título estático)
              const SizedBox(height: 16),
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
                    : Column(
                        children: [
                          // Título gerado por IA
                          if (_conversationTitle != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                              child: Text(
                                _conversationTitle!,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.isDarkMode 
                                      ? Colors.white 
                                      : const Color(0xFF212529),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildMessageBubble(_messages[index], themeProvider);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          _buildInputArea(themeProvider),
        ],
      ),
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
        child: message.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              )
            : Text(
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
                              color: themeProvider.isDarkMode 
                                  ? const Color(0xFF495057) 
                                  : const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              enabled: !_isLoading,
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode 
                                    ? Colors.white 
                                    : const Color(0xFF212529),
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: 'Ask DocuGen',
                                hintStyle: TextStyle(
                                  color: themeProvider.isDarkMode 
                                      ? Colors.white54 
                                      : const Color(0xFFADB5BD),
                                  fontSize: 16,
                                ),
                              ),
                              cursorColor: themeProvider.isDarkMode 
                                  ? Colors.white 
                                  : const Color(0xFF212529),
                              enableSuggestions: false,
                              autocorrect: false,
                              onSubmitted: (_) => _sendMessageNative(),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botão de enviar/parar
                GestureDetector(
                  onTap: _isLoading ? null : (kIsWeb ? _sendMessageFromHtml : _sendMessageNative),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode 
                          ? const Color(0xFF6C757D) 
                          : const Color(0xFF212529),
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
                      child: _isLoading
                          ? SvgPicture.string(
                              _stopIconSvg,
                              width: 20,
                              height: 20,
                            )
                          : SvgPicture.string(
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
    if (text.isEmpty || _isLoading) return;
    _sendMessage(text);
    _messageController.clear();
    _focusNode.unfocus();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _messages.add(ChatMessage(text: '', isUser: false, isLoading: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': _buildMessageHistory(),
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        if (mounted) {
          setState(() {
            _messages.removeLast();
            _messages.add(ChatMessage(text: aiResponse, isUser: false));
            _isLoading = false;
          });

          // Gerar título após a primeira troca de mensagens
          if (_conversationTitle == null && _messages.length == 2) {
            _generateConversationTitle();
          }
        }
      } else {
        throw Exception('Erro na API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao enviar mensagem: $e');
      if (mounted) {
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            text: 'Desculpe, ocorreu um erro. Tente novamente.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }

    _scrollToBottom();
  }

  List<Map<String, String>> _buildMessageHistory() {
    return _messages
        .where((msg) => !msg.isLoading)
        .map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.text,
            })
        .toList();
  }

  Future<void> _generateConversationTitle() async {
    if (_messages.isEmpty) return;

    try {
      final firstMessage = _messages.first.text;
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'Gere um título curto e descritivo (máximo 6 palavras) para esta conversa. Responda apenas com o título, sem pontuação no final.',
            },
            {
              'role': 'user',
              'content': firstMessage,
            },
          ],
          'temperature': 0.5,
          'max_tokens': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['choices'][0]['message']['content'].trim();

        if (mounted) {
          setState(() {
            _conversationTitle = title;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao gerar título: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });
}
