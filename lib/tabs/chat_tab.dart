// lib/tabs/chat_tab.dart
import 'dart:convert';
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
  static int _viewIdCounter = 0;
  late String _viewType;

  static const String _sendIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

  @override
  void initState() {
    super.initState();
    _viewType = 'chat-input-view-${_viewIdCounter++}';
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registerWebView();
        _setupMessageListener();
      });
    }
  }

  void _setupMessageListener() {
    html.window.onMessage.listen((event) {
      final data = event.data;
      
      if (data is Map && data['source'] == 'docugen-chat') {
        final message = data['message']?.toString().trim();
        if (message != null && message.isNotEmpty && mounted) {
          _sendMessage(message);
        }
      }
    });
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final element = html.DivElement()
            ..id = 'chat-container-$viewId'
            ..style.width = '100%'
            ..style.height = '100%';

          element.setInnerHtml(
            '''
            <div style="display: flex; align-items: center; gap: 12px; width: 100%; height: 100%; padding: 0;">
              <input 
                type="text" 
                id="chatInput-$viewId" 
                placeholder="Ask DocuGen"
                autocomplete="off"
                spellcheck="false"
                style="
                  flex: 1;
                  padding: 12px 20px;
                  border: none;
                  border-radius: 24px;
                  font-size: 16px;
                  outline: none;
                  background-color: #FFFFFF;
                  color: #212529;
                  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                  transition: all 0.3s;
                  -webkit-user-select: text;
                  user-select: text;
                  -webkit-tap-highlight-color: transparent;
                "
              >
              <button 
                id="sendBtn-$viewId"
                type="button"
                style="
                  width: 48px;
                  height: 48px;
                  border: none;
                  border-radius: 50%;
                  background-color: #212529;
                  color: white;
                  cursor: pointer;
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  flex-shrink: 0;
                  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
                  transition: all 0.2s;
                  -webkit-tap-highlight-color: transparent;
                "
              >
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 5V19M12 5L6 11M12 5L18 11" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
            <style>
              * { -webkit-touch-callout: none; -webkit-user-select: none; -moz-user-select: none; -ms-user-select: none; user-select: none; }
              #chatInput-$viewId { -webkit-user-select: text !important; user-select: text !important; }
              #chatInput-$viewId:focus { background-color: #FFFFFF; box-shadow: none !important; outline: none !important; }
              #chatInput-$viewId::placeholder { color: #ADB5BD; }
              #sendBtn-$viewId:hover { background-color: #343A40; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2); }
              #sendBtn-$viewId:active { transform: scale(0.95); background-color: #495057; }
            </style>
            <script>
              (function() {
                const input = document.getElementById('chatInput-$viewId');
                const btn = document.getElementById('sendBtn-$viewId');

                function send() {
                  const msg = input.value.trim();
                  if (!msg) return;

                  // Envia mensagem para Flutter
                  window.parent.postMessage({
                    source: 'docugen-chat',
                    message: msg
                  }, '*');

                  input.value = '';
                }

                btn.addEventListener('click', (e) => { 
                  e.preventDefault(); 
                  send(); 
                });
                
                input.addEventListener('keypress', (e) => { 
                  if (e.key === 'Enter') { 
                    e.preventDefault(); 
                    send(); 
                  } 
                });
              })();
            </script>
            ''',
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          return element;
        },
      );
    } catch (e) {
      debugPrint('Error registering view: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Stack(
      children: [
        Column(
          children: [
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
            child: SizedBox(
              height: 50,
              child: kIsWeb
                  ? HtmlElementView(viewType: _viewType)
                  : _buildNativeInput(themeProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeInput(ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
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
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _sendMessageNative,
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