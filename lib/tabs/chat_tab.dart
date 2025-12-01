import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui' as ui;

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

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerWebView();
      _setupMessageListener();
    }
  }

  void _registerWebView() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final element = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%';

        element.setInnerHtml(
          '''
          <div style="display: flex; align-items: center; gap: 12px; width: 100%; height: 100%; padding: 0;">
            <input 
              type="text" 
              id="chatInput" 
              placeholder="Type a message..."
              style="
                flex: 1;
                padding: 12px 20px;
                border: 1px solid #e0e0e0;
                border-radius: 24px;
                font-size: 16px;
                outline: none;
                background-color: #f5f5f5;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                transition: all 0.3s;
              "
            >
            <button 
              id="sendBtn"
              style="
                width: 48px;
                height: 48px;
                border: none;
                border-radius: 50%;
                background-color: #2196F3;
                color: white;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
                box-shadow: 0 2px 8px rgba(33, 150, 243, 0.3);
                transition: all 0.3s;
              "
            >
              <svg fill="currentColor" width="24" height="24" viewBox="0 0 512 512">
                <path d="M476.59 227.05l-.16-.07L49.35 49.84A23.56 23.56 0 0027.14 52 24.65 24.65 0 0016 72.59v113.29a24 24 0 0019.52 23.57l232.93 43.07a4 4 0 010 7.86L35.53 303.45A24 24 0 0016 327v113.31A23.57 23.57 0 0026.59 460a23.94 23.94 0 0013.22 4 24.55 24.55 0 009.52-1.93L476.4 285.94l.19-.09a32 32 0 000-58.8z"/>
              </svg>
            </button>
          </div>
          <style>
            #chatInput:focus {
              border-color: #2196F3;
              background-color: white;
            }
            #sendBtn:hover {
              background-color: #1976D2;
              box-shadow: 0 4px 12px rgba(33, 150, 243, 0.4);
            }
            #sendBtn:active {
              transform: scale(0.95);
            }
          </style>
          <script>
            const input = document.getElementById('chatInput');
            const btn = document.getElementById('sendBtn');
            
            function send() {
              const msg = input.value.trim();
              if (msg) {
                window.parent.postMessage({type: 'chat-message', message: msg}, '*');
                input.value = '';
                input.blur();
              }
            }
            
            btn.addEventListener('click', send);
            input.addEventListener('keypress', (e) => {
              if (e.key === 'Enter') send();
            });
          </script>
          ''',
          treeSanitizer: html.NodeTreeSanitizer.trusted,
        );

        return element;
      },
    );
  }

  void _setupMessageListener() {
    html.window.onMessage.listen((event) {
      if (event.data is Map && event.data['type'] == 'chat-message') {
        _sendMessage(event.data['message']);
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
                      child: Text(
                        'Crie algo Novo',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
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
              ? const Color(0xFF2196F3)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessageNative(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _sendMessageNative,
            icon: const Icon(Ionicons.send),
            color: Colors.white,
            iconSize: 22,
            padding: const EdgeInsets.all(12),
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
    if (_messageController.text.trim().isEmpty) return;
    _sendMessage(_messageController.text.trim());
    _messageController.clear();
    _focusNode.unfocus();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
      ));
    });

    Future.delayed(const Duration(milliseconds: 100), () {
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

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}