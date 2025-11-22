import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ApiService {
  String apiKey = '';
  String model = 'deepseek-chat';
  double temperature = 0.7;
  int maxTokens = 2000;
  String baseUrl = 'https://api.deepseek.com';
  bool useProxyNoKey = false;

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      apiKey = prefs.getString('apiKey') ?? '';
      model = prefs.getString('model') ?? 'deepseek-chat';
      temperature = prefs.getDouble('temperature') ?? 0.7;
      maxTokens = prefs.getInt('maxTokens') ?? 2000;
      baseUrl = prefs.getString('baseUrl') ?? 'https://api.deepseek.com';
      useProxyNoKey = prefs.getBool('useProxyNoKey') ?? false;

      await _loadApiKeyFromGitHub();
    } catch (e) {
      print('❌ Erro ao carregar preferências: $e');
    }
  }

  Future<void> _loadApiKeyFromGitHub() async {
    try {
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/Alfredoooh/data-server/main/public/APi/data.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (apiKey.isEmpty) {
          apiKey = data['apiKey'] ?? apiKey;
        }
        if (data['defaultModel'] != null) model = data['defaultModel'];
        if (data['defaultTemperature'] != null) temperature = data['defaultTemperature'];
        if (data['defaultMaxTokens'] != null) maxTokens = data['defaultMaxTokens'];
        
        await _savePreferences();
      }
    } catch (e) {
      print('❌ Erro ao carregar API Key do GitHub: $e');
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', apiKey);
    await prefs.setString('model', model);
    await prefs.setDouble('temperature', temperature);
    await prefs.setInt('maxTokens', maxTokens);
    await prefs.setString('baseUrl', baseUrl);
    await prefs.setBool('useProxyNoKey', useProxyNoKey);
  }

  void updateSettings(
    String newApiKey,
    String newModel,
    double newTemperature,
    int newMaxTokens,
    String newBaseUrl,
    bool newUseProxyNoKey,
  ) {
    apiKey = newApiKey;
    model = newModel;
    temperature = newTemperature;
    maxTokens = newMaxTokens;
    baseUrl = newBaseUrl;
    useProxyNoKey = newUseProxyNoKey;
    _savePreferences();
  }

  Future<Message> sendMessage(List<Message> messages) async {
    if (apiKey.isEmpty && !useProxyNoKey) {
      throw Exception('API Key não configurada');
    }

    try {
      final response = await _postToEndpoint(
        baseUrl: baseUrl,
        apiKey: apiKey,
        messages: messages,
        sendAuthHeader: !useProxyNoKey,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          return Message(
            role: 'assistant',
            content: data['choices'][0]['message']?['content'] ?? 'Sem resposta',
          );
        }
        throw Exception('Resposta vazia da API');
      } else {
        if (!useProxyNoKey) {
          final fallbackResponse = await _postToEndpoint(
            baseUrl: baseUrl,
            apiKey: '',
            messages: messages,
            sendAuthHeader: false,
          );

          if (fallbackResponse.statusCode == 200) {
            final data = json.decode(utf8.decode(fallbackResponse.bodyBytes));
            if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
              return Message(
                role: 'assistant',
                content: data['choices'][0]['message']?['content'] ?? 'Sem resposta (fallback)',
              );
            }
          }
        }

        throw Exception(_getErrorMessage(response.statusCode, response.body));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> _postToEndpoint({
    required String baseUrl,
    String? apiKey,
    required List<Message> messages,
    bool sendAuthHeader = true,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/completions');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (sendAuthHeader && (apiKey?.isNotEmpty ?? false)) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final body = json.encode({
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': false,
    });

    return await http.post(uri, headers: headers, body: body);
  }

  String _getErrorMessage(int statusCode, String responseBody) {
    Map<int, String> commonErrors = {
      400: '❌ Requisição inválida',
      401: '🔑 API Key inválida',
      402: '💳 Créditos insuficientes',
      403: '🚫 Acesso negado',
      404: '❓ Modelo não encontrado',
      429: '⏱️ Muitas requisições',
      500: '⚠️ Erro interno do servidor',
    };

    try {
      final errorData = json.decode(responseBody);
      String apiMessage = '';

      if (errorData is Map) {
        if (errorData['error'] is Map) {
          apiMessage = errorData['error']['message'] ?? '';
        } else {
          apiMessage = errorData['message'] ?? '';
        }
      }

      if (apiMessage.isNotEmpty) {
        return apiMessage;
      }
    } catch (e) {
      // Ignora
    }

    return commonErrors[statusCode] ?? '❌ Erro $statusCode';
  }
}