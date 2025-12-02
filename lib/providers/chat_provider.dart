// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_message.dart';
import '../models/conversation.dart';

class ChatProvider extends ChangeNotifier {
  final List<Conversation> _conversations = [];
  Conversation? _currentConversation;

  static const String _groqApiKey = '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';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  List<ChatMessage> get currentMessages => _currentConversation?.messages ?? [];

  ChatProvider() {
    _createInitialConversation();
  }

  void _createInitialConversation() {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nova Conversa',
      messages: [],
      lastUpdated: DateTime.now(),
    );
    _conversations.add(conversation);
    _currentConversation = conversation;
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    if (_currentConversation == null) return;

    _currentConversation!.messages.add(message);
    _currentConversation!.lastUpdated = DateTime.now();

    if (_currentConversation!.messages.where((m) => m.isUser).length == 1 && message.isUser) {
      _generateConversationTitle(message.text);
    }

    notifyListeners();
  }

  Future<void> _generateConversationTitle(String firstMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'groq/compound',
          'messages': [
            {
              'role': 'system',
              'content': 'Você deve gerar um título curto (máximo 4-5 palavras) para uma conversa baseado na primeira mensagem do usuário. Responda APENAS com o título, sem explicações ou pontuação adicional.',
            },
            {
              'role': 'user',
              'content': firstMessage,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String title = data['choices'][0]['message']['content'] as String;
        title = title.trim().replaceAll('"', '').replaceAll("'", '');
        
        if (title.length > 40) {
          title = '${title.substring(0, 37)}...';
        }

        if (_currentConversation != null) {
          _currentConversation!.title = title;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erro ao gerar título: $e');
    }
  }

  void createNewConversation() {
    final conversation = Conversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nova Conversa',
      messages: [],
      lastUpdated: DateTime.now(),
    );
    _conversations.insert(0, conversation);
    _currentConversation = conversation;
    notifyListeners();
  }

  void switchConversation(String conversationId) {
    _currentConversation = _conversations.firstWhere((c) => c.id == conversationId);
    notifyListeners();
  }

  void deleteConversation(String conversationId) {
    _conversations.removeWhere((c) => c.id == conversationId);
    
    if (_currentConversation?.id == conversationId) {
      if (_conversations.isNotEmpty) {
        _currentConversation = _conversations.first;
      } else {
        _createInitialConversation();
      }
    }
    
    notifyListeners();
  }

  List<Map<String, String>> buildMessageHistory() {
    return _currentConversation?.messages
            .map((msg) => {
                  'role': msg.isUser ? 'user' : 'assistant',
                  'content': msg.text,
                })
            .toList() ??
        [];
  }
}