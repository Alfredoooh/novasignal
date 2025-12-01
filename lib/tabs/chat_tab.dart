import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final List<ChatMessage> _messages = [];
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 50,
            child: WebView(
              initialUrl: Uri.dataFromString(
                _getHtmlContent(),
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ).toString(),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              javascriptChannels: {
                JavascriptChannel(
                  name: 'FlutterChannel',
                  onMessageReceived: (JavascriptMessage message) {
                    if (message.message.isNotEmpty) {
                      _sendMessage(message.message);
                    }
                  },
                ),
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getHtmlContent() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
          overflow: hidden;
        }
        
        .input-container {
          display: flex;
          align-items: center;
          gap: 12px;
          width: 100%;
          height: 50px;
        }
        
        #messageInput {
          flex: 1;
          padding: 12px 20px;
          border: 1px solid #e0e0e0;
          border-radius: 24px;
          font-size: 16px;
          outline: none;
          transition: border-color 0.3s;
          background-color: #f5f5f5;
        }
        
        #messageInput:focus {
          border-color: #2196F3;
          background-color: white;
        }
        
        #sendButton {
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
          transition: background-color 0.3s;
          flex-shrink: 0;
        }
        
        #sendButton:active {
          background-color: #1976D2;
        }
        
        #sendButton svg {
          width: 24px;
          height: 24px;
        }
      </style>
    </head>
    <body>
      <div class="input-container">
        <input 
          type="text" 
          id="messageInput" 
          placeholder="Type a message..."
          autocomplete="off"
        >
        <button id="sendButton">
          <svg fill="currentColor" viewBox="0 0 512 512">
            <path d="M476.59 227.05l-.16-.07L49.35 49.84A23.56 23.56 0 0027.14 52 24.65 24.65 0 0016 72.59v113.29a24 24 0 0019.52 23.57l232.93 43.07a4 4 0 010 7.86L35.53 303.45A24 24 0 0016 327v113.31A23.57 23.57 0 0026.59 460a23.94 23.94 0 0013.22 4 24.55 24.55 0 009.52-1.93L476.4 285.94l.19-.09a32 32 0 000-58.8z"/>
          </svg>
        </button>
      </div>
      
      <script>
        const input = document.getElementById('messageInput');
        const button = document.getElementById('sendButton');
        
        function sendMessage() {
          const message = input.value.trim();
          if (message) {
            FlutterChannel.postMessage(message);
            input.value = '';
            input.blur();
          }
        }
        
        button.addEventListener('click', sendMessage);
        
        input.addEventListener('keypress', (e) => {
          if (e.key === 'Enter') {
            sendMessage();
          }
        });
      </script>
    </body>
    </html>
    ''';
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
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