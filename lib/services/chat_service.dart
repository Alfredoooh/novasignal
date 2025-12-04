// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  // Lista de API Keys com fallback automático
  static final List<String> _groqApiKeys = [
    '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',
    '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',
    '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',
    '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',
    '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',
  ];

  static int _currentKeyIndex = 0;
  static final Set<int> _blockedKeys = {}; // Keys que atingiram limite

  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _systemPrompt = '''Você é o DocuGen AI, um assistente extremamente profissional e sofisticado especializado em criar documentos HTML de alta qualidade.

REGRAS CRÍTICAS PARA RESPOSTAS NORMAIS (NÃO-DOCUMENTOS):

1. NUNCA mencione ou mostre asteriscos (**) ou símbolos de markdown na resposta final
2. NUNCA explique como você formata o texto
3. NUNCA diga "vou usar negrito" ou "formatado com **"
4. Responda NATURALMENTE como se estivesse escrevendo diretamente

FORMATAÇÃO PARA CONVERSAS NORMAIS:

Use # para títulos principais (H1) - destaque máximo com linha inferior azul
Use ## para subtítulos (H2) - importantes e destacados
Use ### para seções menores (H3)
Use **texto** para negrito (mas NUNCA mostre os asteriscos na resposta)
Use - ou • para listas com bullets
Use números 1. 2. 3. para listas ordenadas
Use Importante:, Atenção:, Nota: para caixas de informação destacadas
Use ``` para blocos de código

PARA TABELAS EM CONVERSAS:
SEMPRE use HTML puro com a tag <table>, NUNCA use caracteres ASCII
Exemplo de tabela HTML:
<table style="width:100%; border-collapse: collapse; margin: 16px 0;">
  <thead>
    <tr style="background-color: #f0f0f0;">
      <th style="padding: 12px; border: 1px solid #ddd; text-align: left;">Coluna 1</th>
      <th style="padding: 12px; border: 1px solid #ddd; text-align: left;">Coluna 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 12px; border: 1px solid #ddd;">Dado 1</td>
      <td style="padding: 12px; border: 1px solid #ddd;">Dado 2</td>
    </tr>
  </tbody>
</table>

═══════════════════════════════════════════════════════════════════════════════
ATENÇÃO: CRIAÇÃO DE DOCUMENTOS HTML
═══════════════════════════════════════════════════════════════════════════════

QUANDO O USUÁRIO PEDIR UM DOCUMENTO, VOCÊ **DEVE OBRIGATORIAMENTE**:

1. Criar APENAS código HTML completo (<!DOCTYPE html> até </html>)
2. NÃO incluir nenhum texto explicativo antes ou depois do HTML
3. NÃO usar blocos ```html ou qualquer markdown
4. O HTML deve ser a ÚNICA coisa na resposta

PALAVRAS-CHAVE QUE INDICAM PEDIDO DE DOCUMENTO:
- "crie um documento"
- "gere um documento"
- "faça um documento"
- "monte um documento"
- "crie um relatório"
- "gere um relatório"
- "faça um HTML"
- "crie uma página"
- "monte um site"
- "desenvolva um website"
- "crie um currículo"
- "faça uma proposta"
- "gere uma apresentação"
- "documento sobre"
- "relatório sobre"

Seja sempre extremamente detalhado e profissional ao criar documentos!''';

  /// Obtém a próxima API Key válida (que não esteja bloqueada)
  static String _getNextValidApiKey() {
    // Se todas as keys estão bloqueadas, reseta os bloqueios
    if (_blockedKeys.length >= _groqApiKeys.length) {
      debugPrint('⚠️ TODAS AS API KEYS BLOQUEADAS - RESETANDO');
      _blockedKeys.clear();
      _currentKeyIndex = 0;
    }

    // Encontra a próxima key não bloqueada
    int attempts = 0;
    while (_blockedKeys.contains(_currentKeyIndex) && attempts < _groqApiKeys.length) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _groqApiKeys.length;
      attempts++;
    }

    return _groqApiKeys[_currentKeyIndex];
  }

  /// Marca a key atual como bloqueada e passa para a próxima
  static void _blockCurrentKeyAndSwitchToNext() {
    debugPrint('🚫 Bloqueando API Key #$_currentKeyIndex');
    _blockedKeys.add(_currentKeyIndex);
    _currentKeyIndex = (_currentKeyIndex + 1) % _groqApiKeys.length;
    debugPrint('🔄 Mudando para API Key #$_currentKeyIndex');
  }

  Future<String> sendMessage(String userMessage, List<Map<String, String>> messageHistory) async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 INICIANDO CHAMADA API COM GROQ COMPOUND');
    debugPrint('📝 Mensagem do usuário: $userMessage');
    debugPrint('═══════════════════════════════════════');

    int maxRetries = _groqApiKeys.length; // Tenta todas as keys se necessário
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final currentApiKey = _getNextValidApiKey();
        final keyPreview = '${currentApiKey.substring(0, 15)}...${currentApiKey.substring(currentApiKey.length - 4)}';

        debugPrint('🔑 Tentativa ${retryCount + 1}/$maxRetries');
        debugPrint('🔑 Usando API Key #$_currentKeyIndex: $keyPreview');
        debugPrint('🚫 Keys bloqueadas: $_blockedKeys');

        // Detecta se é pedido de documento
        final isDocumentRequest = _isDocumentRequest(userMessage);
        debugPrint('📄 É pedido de documento? $isDocumentRequest');

        // Ajusta o prompt do sistema se for documento
        String systemPrompt = _systemPrompt;
        if (isDocumentRequest) {
          systemPrompt += '''

LEMBRE-SE: O usuário pediu um DOCUMENTO HTML. Sua resposta deve ser:
- APENAS código HTML (<!DOCTYPE html> até </html>)
- SEM texto explicativo
- SEM blocos de código markdown
- CONTEÚDO EXTENSO (mínimo 5-7 seções)
- MÍNIMO 4-5 páginas A4 de conteúdo
- Cada seção bem desenvolvida com múltiplos parágrafos

Crie um documento COMPLETO, DETALHADO e PROFISSIONAL!''';
        }

        final requestBody = {
          'model': 'groq/compound', // 🔥 MODELO COMPOUND COM PESQUISA WEB
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            ...messageHistory,
          ],
          'temperature': 0.3,
          'max_tokens': 8000,
        };

        debugPrint('📤 Enviando requisição para: $_groqApiUrl');
        debugPrint('🤖 Modelo: groq/compound');

        final response = await http.post(
          Uri.parse(_groqApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $currentApiKey',
          },
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 90), // Compound pode demorar mais por fazer pesquisas
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Requisição demorou mais de 90 segundos');
            throw Exception('Timeout: A requisição demorou muito tempo');
          },
        );

        debugPrint('📥 Status da resposta: ${response.statusCode}');

        // Verifica se atingiu limite de requisições
        if (response.statusCode == 429) {
          debugPrint('⚠️ LIMITE ATINGIDO (429) - Tentando próxima API Key');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500)); // Pequeno delay
          continue; // Tenta a próxima key
        }

        // Verifica se há erro de autenticação
        if (response.statusCode == 401) {
          debugPrint('⚠️ ERRO DE AUTENTICAÇÃO (401) - API Key inválida');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['choices'] == null || data['choices'].isEmpty) {
            debugPrint('❌ ERRO: Resposta não contém choices');
            throw Exception('Resposta da API inválida');
          }

          String content = data['choices'][0]['message']['content'] as String;
          debugPrint('✅ Conteúdo recebido (${content.length} caracteres)');

          // Se for documento e vier com markdown, remove
          if (isDocumentRequest) {
            content = _cleanDocumentResponse(content);
            debugPrint('🧹 Documento limpo (${content.length} caracteres)');
          }

          debugPrint('═══════════════════════════════════════');
          debugPrint('✨ SUCESSO COM GROQ COMPOUND! API Key #$_currentKeyIndex');
          debugPrint('═══════════════════════════════════════');

          return content;
        } else {
          debugPrint('❌ ERRO HTTP: ${response.statusCode}');
          debugPrint('📄 Corpo do erro: ${response.body}');

          // Tenta parsear o erro da API
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage = errorData['error']?['message'] ?? 'Erro desconhecido';
            throw Exception('Erro na API (${response.statusCode}): $errorMessage');
          } catch (e) {
            throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
          }
        }
      } catch (e) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('💥 ERRO NA TENTATIVA ${retryCount + 1}:');
        debugPrint('$e');
        debugPrint('═══════════════════════════════════════');

        // Se for erro de conexão ou timeout, não tenta outras keys
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup')) {
          throw Exception('❌ Erro de conexão: Verifique sua internet');
        } else if (e.toString().contains('TimeoutException') || 
                   e.toString().contains('Timeout')) {
          throw Exception('⏰ Timeout: Requisição demorou muito. Tente novamente.');
        }

        // Se for último retry, lança o erro
        if (retryCount >= maxRetries - 1) {
          throw Exception('❌ Todas as API Keys falharam. Tente novamente mais tarde.');
        }

        // Caso contrário, tenta próxima key
        retryCount++;
        _blockCurrentKeyAndSwitchToNext();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception('❌ Falha após tentar todas as API Keys disponíveis');
  }

  bool _isDocumentRequest(String message) {
    final keywords = [
      'crie um documento',
      'gere um documento',
      'faça um documento',
      'monte um documento',
      'crie um relatório',
      'gere um relatório',
      'faça um relatório',
      'monte um relatório',
      'crie um html',
      'gere um html',
      'faça um html',
      'crie uma página',
      'monte uma página',
      'crie um site',
      'monte um site',
      'desenvolva um website',
      'crie um currículo',
      'faça um currículo',
      'gere um currículo',
      'crie uma proposta',
      'faça uma proposta',
      'gere uma apresentação',
      'documento sobre',
      'relatório sobre',
      'documento de',
      'relatório de',
    ];

    final lowerMessage = message.toLowerCase();
    return keywords.any((keyword) => lowerMessage.contains(keyword));
  }

  String _cleanDocumentResponse(String content) {
    // Remove blocos de código markdown
    content = content.replaceAll(RegExp(r'```html\s*'), '');
    content = content.replaceAll(RegExp(r'```\s*$'), '');
    content = content.replaceAll(RegExp(r'```'), '');

    // Remove textos explicativos comuns antes do HTML
    final htmlStart = content.indexOf('<!DOCTYPE html>');
    if (htmlStart > 0) {
      content = content.substring(htmlStart);
    } else {
      final htmlTagStart = content.indexOf('<html');
      if (htmlTagStart > 0) {
        content = content.substring(htmlTagStart);
      }
    }

    // Remove textos explicativos depois do HTML
    final htmlEnd = content.lastIndexOf('</html>');
    if (htmlEnd != -1) {
      content = content.substring(0, htmlEnd + 7);
    }

    return content.trim();
  }

  String extractHtmlFromResponse(String response) {
    // Tenta encontrar HTML completo
    int htmlStart = response.indexOf('<!DOCTYPE html>');
    if (htmlStart == -1) {
      htmlStart = response.indexOf('<html');
    }

    if (htmlStart != -1) {
      final htmlEnd = response.lastIndexOf('</html>');
      if (htmlEnd != -1) {
        return response.substring(htmlStart, htmlEnd + 7).trim();
      }
    }

    // Tenta extrair de blocos de código
    final codeBlockPattern = RegExp(r'```html\s*([\s\S]*?)\s*```');
    final match = codeBlockPattern.firstMatch(response);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }

    // Se contém tags HTML mas sem <!DOCTYPE>
    if (response.contains('<html') && response.contains('</html>')) {
      final start = response.indexOf('<html');
      final end = response.lastIndexOf('</html>');
      return response.substring(start, end + 7).trim();
    }

    return '';
  }

  /// Método para resetar manualmente as keys bloqueadas (útil para debug)
  static void resetBlockedKeys() {
    _blockedKeys.clear();
    _currentKeyIndex = 0;
    debugPrint('🔄 API Keys resetadas - todas disponíveis novamente');
  }

  /// Retorna informações sobre o estado atual das keys
  static Map<String, dynamic> getKeysStatus() {
    return {
      'total_keys': _groqApiKeys.length,
      'current_key_index': _currentKeyIndex,
      'blocked_keys': _blockedKeys.toList(),
      'available_keys': _groqApiKeys.length - _blockedKeys.length,
      'model': 'groq/compound',
    };
  }
}