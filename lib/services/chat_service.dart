// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  static final List<String> _groqApiKeys = [
    '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',
    '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',
    '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',
    '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',
    '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',
  ];

  static int _currentKeyIndex = 0;
  static final Set<int> _blockedKeys = {};

  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _systemPrompt = '''Você é o DocuGen AI, um assistente extremamente profissional e sofisticado.

REGRAS CRÍTICAS:

1. Use emojis de forma natural e frequente nas respostas 😊
2. Seja amigável e use linguagem conversacional
3. NUNCA mostre asteriscos (**) ou símbolos markdown nas respostas finais
4. Responda naturalmente como em uma conversa real

FORMATAÇÃO PARA CONVERSAS:

Use # para títulos principais (H1)
Use ## para subtítulos (H2)
Use ### para seções menores (H3)
Use **texto** para negrito (mas NUNCA mostre os ** na resposta)
Use - ou • para listas
Use números 1. 2. 3. para listas ordenadas

PARA TABELAS:
SEMPRE use HTML puro com <table>, NUNCA use caracteres ASCII

═══════════════════════════════════════════════════════════════════════════════
CRIAÇÃO DE DOCUMENTOS HTML PROFISSIONAIS
═══════════════════════════════════════════════════════════════════════════════

QUANDO O USUÁRIO PEDIR UM DOCUMENTO:

1. Criar APENAS código HTML completo (<!DOCTYPE html> até </html>)
2. NÃO incluir texto explicativo antes ou depois
3. NÃO usar blocos ```html ou markdown
4. O HTML deve ser a ÚNICA coisa na resposta

TEMPLATE OBRIGATÓRIO PARA DOCUMENTOS:

<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>[Título do Documento]</title>
<style>
@page {
    size: A4;
    margin: 2cm;
}
body {
    font-family: 'Times New Roman', serif;
    font-size: 12pt;
    line-height: 1.6;
    color: #000;
    background-color: #fff;
    margin: 0;
    padding: 0;
}
header {
    text-align: center;
    margin-bottom: 2em;
}
header h1 {
    font-size: 24pt;
    margin: 0;
    padding: 0;
}
header h2 {
    font-size: 16pt;
    margin: 0;
    padding: 0;
    font-weight: normal;
    color: #555;
}
main {
    padding: 0 1cm;
}
section {
    margin-bottom: 2em;
}
h3 {
    font-size: 14pt;
    margin-bottom: 0.5em;
    border-bottom: 1px solid #ccc;
    padding-bottom: 0.2em;
}
p {
    text-align: justify;
    margin-bottom: 1em;
}
ul, ol {
    margin-bottom: 1em;
    padding-left: 2em;
}
li {
    margin-bottom: 0.5em;
}
table {
    width: 100%;
    border-collapse: collapse;
    margin: 1em 0;
}
th, td {
    border: 1px solid #ccc;
    padding: 0.5em;
    text-align: left;
}
th {
    background-color: #f0f0f0;
    font-weight: bold;
}
footer {
    text-align: center;
    font-size: 10pt;
    color: #555;
    position: fixed;
    bottom: 1cm;
    width: 100%;
}
</style>
</head>
<body>
<header>
    <h1>[Título Principal]</h1>
    <h2>[Subtítulo]</h2>
</header>
<main>
    <section>
        <h3>[Seção 1]</h3>
        <p>[Mínimo 3-4 parágrafos bem desenvolvidos com conteúdo relevante]</p>
    </section>
    [MÍNIMO 6-8 SEÇÕES COM CONTEÚDO APROFUNDADO]
</main>
<footer>
    Página 1
</footer>
</body>
</html>

REQUISITOS OBRIGATÓRIOS PARA DOCUMENTOS:

✓ MÍNIMO 6-8 seções principais
✓ Cada seção com 3-5 parágrafos detalhados
✓ Total mínimo: 2000-3000 palavras
✓ Conteúdo profundo e técnico quando aplicável
✓ Usar listas, tabelas e formatação quando apropriado
✓ Header com título e subtítulo
✓ Footer com numeração de página
✓ Times New Roman 12pt
✓ Texto justificado
✓ Margens de 2cm

PALAVRAS-CHAVE PARA DOCUMENTOS:
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

IMPORTANTE: Documentos devem ser EXTENSOS, DETALHADOS e PROFISSIONAIS com conteúdo real e relevante!''';

  static String _getNextValidApiKey() {
    if (_blockedKeys.length >= _groqApiKeys.length) {
      debugPrint('⚠️ TODAS AS API KEYS BLOQUEADAS - RESETANDO');
      _blockedKeys.clear();
      _currentKeyIndex = 0;
    }

    int attempts = 0;
    while (_blockedKeys.contains(_currentKeyIndex) && attempts < _groqApiKeys.length) {
      _currentKeyIndex = (_currentKeyIndex + 1) % _groqApiKeys.length;
      attempts++;
    }

    return _groqApiKeys[_currentKeyIndex];
  }

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
    debugPrint('📊 Histórico: ${messageHistory.length} mensagens');
    debugPrint('═══════════════════════════════════════');

    int maxRetries = _groqApiKeys.length;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final currentApiKey = _getNextValidApiKey();
        final keyPreview = '${currentApiKey.substring(0, 15)}...${currentApiKey.substring(currentApiKey.length - 4)}';

        debugPrint('🔑 Tentativa ${retryCount + 1}/$maxRetries');
        debugPrint('🔑 Usando API Key #$_currentKeyIndex: $keyPreview');

        final isDocumentRequest = _isDocumentRequest(userMessage);
        debugPrint('📄 É pedido de documento? $isDocumentRequest');

        String systemPrompt = _systemPrompt;
        if (isDocumentRequest) {
          systemPrompt += '''

LEMBRE-SE: O usuário pediu um DOCUMENTO HTML PROFISSIONAL. Sua resposta deve ser:
- APENAS código HTML (<!DOCTYPE html> até </html>)
- SEM texto explicativo antes ou depois
- SEM blocos de código markdown
- Usar o template fornecido acima com Times New Roman
- CONTEÚDO EXTENSO: mínimo 6-8 seções principais
- Cada seção com 3-5 parágrafos bem desenvolvidos
- Total: 2000-3000 palavras de conteúdo real
- Incluir header com título e subtítulo
- Incluir footer com numeração de página
- Texto justificado, margens 2cm, fonte 12pt

Crie um documento COMPLETO, EXTENSO, DETALHADO e PROFISSIONAL com conteúdo relevante e aprofundado!''';
        }

        final requestBody = {
          'model': 'groq/compound',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            ...messageHistory,
          ],
          'temperature': 0.7,
          'max_tokens': 8000,
        };

        debugPrint('📤 Enviando requisição...');

        final response = await http.post(
          Uri.parse(_groqApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $currentApiKey',
          },
          body: jsonEncode(requestBody),
        ).timeout(
          const Duration(seconds: 90),
          onTimeout: () {
            debugPrint('⏰ TIMEOUT: Requisição demorou mais de 90 segundos');
            throw Exception('Timeout: A requisição demorou muito tempo');
          },
        );

        debugPrint('📥 Status: ${response.statusCode}');

        if (response.statusCode == 429) {
          debugPrint('⚠️ LIMITE ATINGIDO (429) - Tentando próxima API Key');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (response.statusCode == 401) {
          debugPrint('⚠️ ERRO DE AUTENTICAÇÃO (401)');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['choices'] == null || data['choices'].isEmpty) {
            debugPrint('❌ ERRO: Resposta inválida');
            throw Exception('Resposta da API inválida');
          }

          String content = data['choices'][0]['message']['content'] as String;
          debugPrint('✅ Conteúdo recebido (${content.length} caracteres)');

          if (isDocumentRequest) {
            content = _cleanDocumentResponse(content);
            debugPrint('🧹 Documento limpo (${content.length} caracteres)');
          }

          debugPrint('═══════════════════════════════════════');
          debugPrint('✨ SUCESSO COM GROQ COMPOUND!');
          debugPrint('═══════════════════════════════════════');

          return content;
        } else {
          debugPrint('❌ ERRO HTTP: ${response.statusCode}');
          debugPrint('📄 Corpo: ${response.body}');

          try {
            final errorData = jsonDecode(response.body);
            final errorMessage = errorData['error']?['message'] ?? 'Erro desconhecido';
            throw Exception('Erro na API (${response.statusCode}): $errorMessage');
          } catch (e) {
            throw Exception('Erro na API: ${response.statusCode}');
          }
        }
      } catch (e) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('💥 ERRO NA TENTATIVA ${retryCount + 1}: $e');
        debugPrint('═══════════════════════════════════════');

        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup')) {
          throw Exception('❌ Erro de conexão: Verifique sua internet');
        } else if (e.toString().contains('TimeoutException') || 
                   e.toString().contains('Timeout')) {
          throw Exception('⏰ Timeout: Requisição demorou muito. Tente novamente.');
        }

        if (retryCount >= maxRetries - 1) {
          throw Exception('❌ Todas as API Keys falharam. Tente novamente mais tarde.');
        }

        retryCount++;
        _blockCurrentKeyAndSwitchToNext();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception('❌ Falha após tentar todas as API Keys');
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
    content = content.replaceAll(RegExp(r'```html\s*'), '');
    content = content.replaceAll(RegExp(r'```\s*$'), '');
    content = content.replaceAll(RegExp(r'```'), '');

    final htmlStart = content.indexOf('<!DOCTYPE html>');
    if (htmlStart > 0) {
      content = content.substring(htmlStart);
    } else {
      final htmlTagStart = content.indexOf('<html');
      if (htmlTagStart > 0) {
        content = content.substring(htmlTagStart);
      }
    }

    final htmlEnd = content.lastIndexOf('</html>');
    if (htmlEnd != -1) {
      content = content.substring(0, htmlEnd + 7);
    }

    return content.trim();
  }

  String extractHtmlFromResponse(String response) {
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

    final codeBlockPattern = RegExp(r'```html\s*([\s\S]*?)\s*```');
    final match = codeBlockPattern.firstMatch(response);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }

    if (response.contains('<html') && response.contains('</html>')) {
      final start = response.indexOf('<html');
      final end = response.lastIndexOf('</html>');
      return response.substring(start, end + 7).trim();
    }

    return '';
  }

  static void resetBlockedKeys() {
    _blockedKeys.clear();
    _currentKeyIndex = 0;
    debugPrint('🔄 API Keys resetadas');
  }

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