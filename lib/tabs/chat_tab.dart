import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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
  static const String _viewType = 'chat-input-view';
  static bool _viewRegistered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_viewRegistered) {
      _registerWebView();
      _viewRegistered = true;
    }
    if (kIsWeb) {
      _setupMessageListener();
    }
  }

  void _registerWebView() {
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final element = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%';

          element.setInnerHtml(
            // substituí placeholder para "Ask DocuGen" e alterei o SVG para ícone de send/arrow
            '''
            <div style="display: flex; align-items: center; gap: 12px; width: 100%; height: 100%; padding: 0;">
              <input 
                type="text" 
                id="chatInput" 
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
                id="sendBtn"
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
                <!-- papel/arrow send icon SVG (direita) -->
                <svg fill="currentColor" width="20" height="20" viewBox="0 0 512 512" aria-hidden="true">
                  <path d="M476 3L36 213c-30 14-25 54 7 62l93 26 26 93c8 32 48 37 62 7L509 36c19-33-6-69-33-33zM124 265l-12-42 272-160-260 202z"/>
                </svg>
              </button>
            </div>
            <style>
              * {
                -webkit-touch-callout: none;
                -webkit-user-select: none;
                -moz-user-select: none;
                -ms-user-select: none;
                user-select: none;
              }
              
              /* permitir seleção apenas no input */
              #chatInput {
                -webkit-user-select: text !important;
                user-select: text !important;
              }

              /* REMOVE efeitos de foco: sem box-shadow, sem outline */
              #chatInput:focus {
                background-color: #FFFFFF;
                box-shadow: none !important;
                outline: none !important;
              }
              
              #chatInput::placeholder {
                color: #ADB5BD;
              }
              
              #sendBtn:hover {
                background-color: #343A40;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
              }
              
              #sendBtn:active {
                transform: scale(0.95);
                background-color: #495057;
              }
            </style>
            <script>
              const input = document.getElementById('chatInput');
              const btn = document.getElementById('sendBtn');
              
              function send() {
                const msg = input.value.trim();
                console.log('Sending message:', msg);
                if (msg) {
                  // usamos window.postMessage (funciona melhor em diferentes contextos)
                  try {
                    window.postMessage({type: 'chat-message', message: msg}, '*');
                  } catch (e) {
                    window.parent.postMessage({type: 'chat-message', message: msg}, '*');
                  }
                  input.value = '';
                }
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
              
              input.addEventListener('touchstart', (e) => {
                e.stopPropagation();
              });
              
              btn.addEventListener('touchstart', (e) => {
                e.stopPropagation();
              });

              // garantir que ao focar não surja nenhum outline nativo em alguns browsers
              input.addEventListener('focus', (e) => {
                input.style.outline = 'none';
                input.style.boxShadow = 'none';
              });
            </script>
            ''',
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          return element;
        },
      );
    } catch (e) {
      // log de erro mas sem quebrar app
      // ignore: avoid_print
      print('Error registering view: $e');
    }
  }

  void _setupMessageListener() {
    html.window.onMessage.listen((event) {
      // Debug
      // ignore: avoid_print
      print('Message received (raw): ${event.data}');

      String? message;

      final data = event.data;
      if (data is Map) {
        if (data['type'] == 'chat-message') {
          message = data['message']?.toString();
        }
      } else if (data is String) {
        // às vezes chega string JSON — tentamos desserializar
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map && parsed['type'] == 'chat-message') {
            message = parsed['message']?.toString();
          }
        } catch (e) {
          // não era JSON — ignorar
        }
      }

      if (message != null) {
        // garantimos que chamamos setState no zone do Flutter
        if (mounted) {
          _sendMessage(message);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comece uma conversa',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Envie uma mensagem para iniciar',
                            style: TextStyle(
                              color: Colors.grey.shade400,
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
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
          ],
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
              ? const Color(0xFF212529)
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : const Color(0xFF212529),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
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
                  : _buildNativeInput(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF212529),
              ),
              // usamos collapsed para remover qualquer borda/outline nativo ao focar
              decoration: const InputDecoration.collapsed(
                hintText: 'Ask DocuGen',
                hintStyle: TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 16,
                ),
              ),
              cursorColor: const Color(0xFF212529),
              enableSuggestions: false,
              autocorrect: false,
              onSubmitted: (_) => _sendMessageNative(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF212529),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _sendMessageNative,
            // ícone arrow (em vez de chevron)
            icon: const Icon(Ionicons.arrow_forward),
            color: Colors.white,
            iconSize: 20,
            padding: const EdgeInsets.all(14),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessageNative() {
    final text = _messageController.text.trim();
    // ignore: avoid_print
    print('Native send: $text');
    if (text.isEmpty) return;

    _sendMessage(text);
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _sendMessage(String text) {
    // ignore: avoid_print
    print('Adding message: $text');
    if (text.trim().isEmpty) return;

    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
      ));
      // debug
      // ignore: avoid_print
      print('Messages count: ${_messages.length}');
    });

    // garantir que o ListView role até o fim
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

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}