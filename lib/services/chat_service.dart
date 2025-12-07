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

  static const String _systemPrompt = '''Você é um assistente AI profissional e criativo.

REGRAS FUNDAMENTAIS:

1. NUNCA use emojis nas respostas
2. Seja direto, objetivo e profissional
3. NUNCA mostre asteriscos (**) ou símbolos markdown nas respostas
4. Use formatação natural com títulos e seções quando apropriado
5. NUNCA mencione ou explique como você cria documentos HTML
6. NUNCA faça introduções explicando suas capacidades ou processo
7. Responda APENAS o que foi perguntado, sem informações extras sobre seus recursos

FORMATAÇÃO PARA CONVERSAS:

Use # para títulos principais
Use ## para subtítulos  
Use ### para seções menores
Use **texto** para ênfase (mas os ** não aparecem na resposta final)
Use - ou • para listas quando necessário
Use números 1. 2. 3. para listas ordenadas quando apropriado

═══════════════════════════════════════════════════════════════════════════════
CRIAÇÃO DE DOCUMENTOS HTML PROFISSIONAIS
═══════════════════════════════════════════════════════════════════════════════

QUANDO O USUÁRIO PEDIR UM DOCUMENTO:

1. Criar APENAS código HTML completo (<!DOCTYPE html> até </html>)
2. NÃO incluir NENHUM texto explicativo antes ou depois
3. NÃO usar blocos ```html ou markdown
4. O HTML deve ser a ÚNICA coisa na resposta
5. NÃO diga "Vou criar", "Aqui está", ou qualquer introdução
6. Comece IMEDIATAMENTE com <!DOCTYPE html>

TEMPLATE OBRIGATÓRIO PARA DOCUMENTOS (ESTILO A4 MODERNO):

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Título do Documento]</title>
    <style>
        @media print {
            body { margin: 0; }
            .page { margin: 0; box-shadow: none; page-break-after: always; }
            .page:last-child { page-break-after: auto; }
        }
        
        body {
            margin: 0;
            padding: 20px;
            background: #e0e0e0;
            font-family: 'Georgia', serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }
        
        .page {
            width: 210mm;
            height: 297mm;
            background: white;
            padding: 25mm;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            box-sizing: border-box;
            position: relative;
        }
        
        h1 {
            color: #2c3e50;
            font-size: 28px;
            margin: 0 0 10px 0;
            text-align: center;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        
        h2 {
            color: #34495e;
            font-size: 20px;
            margin: 25px 0 15px 0;
            border-left: 4px solid #3498db;
            padding-left: 10px;
        }
        
        h3 {
            color: #555;
            font-size: 16px;
            margin: 20px 0 10px 0;
        }
        
        .subtitle {
            text-align: center;
            color: #7f8c8d;
            font-style: italic;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        p {
            text-align: justify;
            line-height: 1.8;
            color: #34495e;
            margin-bottom: 15px;
            font-size: 12px;
        }
        
        .first-letter::first-letter {
            font-size: 48px;
            font-weight: bold;
            float: left;
            line-height: 40px;
            padding-right: 8px;
            color: #3498db;
        }
        
        .highlight {
            background: #fff3cd;
            padding: 15px;
            border-left: 4px solid #ffc107;
            margin: 20px 0;
            font-style: italic;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 11px;
        }
        
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }
        
        td {
            padding: 10px 12px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        tr:hover {
            background-color: #f5f5f5;
        }
        
        tr:nth-child(even) {
            background-color: #fafafa;
        }
        
        .table-caption {
            font-size: 11px;
            color: #666;
            font-style: italic;
            margin-top: 5px;
            text-align: center;
        }
        
        .image-container {
            text-align: center;
            margin: 25px 0;
        }
        
        .document-image {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .image-caption {
            font-size: 11px;
            color: #666;
            font-style: italic;
            margin-top: 8px;
        }
        
        .footer {
            position: absolute;
            bottom: 20mm;
            left: 25mm;
            right: 25mm;
            text-align: center;
            font-size: 10px;
            color: #95a5a6;
            border-top: 1px solid #ecf0f1;
            padding-top: 10px;
        }
        
        ul, ol {
            margin: 15px 0;
            padding-left: 30px;
        }
        
        li {
            margin-bottom: 8px;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="page">
        <h1>[Título Principal]</h1>
        <div class="subtitle">[Subtítulo]</div>
        
        <p class="first-letter">[Primeiro parágrafo]</p>
        
        <h2>[Seção 1]</h2>
        <p>[Conteúdo com 3-5 parágrafos bem desenvolvidos]</p>
        
        <div class="footer">
            Documento gerado • Página 1
        </div>
    </div>
</body>
</html>

═══════════════════════════════════════════════════════════════════════════════
REGRAS PARA TABELAS E IMAGENS
═══════════════════════════════════════════════════════════════════════════════

TABELAS:
✓ Usar SOMENTE quando fizer sentido (dados comparativos, estatísticas)
✓ NÃO usar apenas para decoração
✓ Sempre incluir cabeçalhos descritivos
✓ Sempre adicionar legenda

IMAGENS:
✓ Usar SOMENTE quando solicitado ou necessário
✓ URLs válidas: placeholder.com, picsum.photos
✓ Sempre incluir alt text e legenda

═══════════════════════════════════════════════════════════════════════════════

REQUISITOS OBRIGATÓRIOS PARA DOCUMENTOS:

✓ MÍNIMO 6-8 seções principais
✓ Cada seção com 3-5 parágrafos detalhados
✓ Total mínimo: 2000-3000 palavras
✓ Conteúdo profundo e técnico
✓ Texto justificado
✓ Formatação elegante e profissional
✓ Tabelas e imagens SOMENTE quando apropriado

PALAVRAS-CHAVE PARA DOCUMENTOS:
"crie um documento", "gere um documento", "faça um documento", "relatório", "currículo", "proposta"

IMPORTANTE PARA CONVERSAS NORMAIS:
- Seja DIRETO e OBJETIVO
- NÃO mencione que você pode criar documentos HTML
- NÃO faça introduções sobre suas capacidades
- NÃO use emojis
- Responda apenas o que foi perguntado
- Use formatação quando ajudar na clareza''';

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
    debugPrint('🚀 INICIANDO CHAMADA API');
    debugPrint('📝 Mensagem: $userMessage');
    debugPrint('═══════════════════════════════════════');

    int maxRetries = _groqApiKeys.length;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final currentApiKey = _getNextValidApiKey();
        final keyPreview = '${currentApiKey.substring(0, 15)}...${currentApiKey.substring(currentApiKey.length - 4)}';

        debugPrint('🔑 Tentativa ${retryCount + 1}/$maxRetries');
        debugPrint('🔑 API Key #$_currentKeyIndex: $keyPreview');

        final isDocumentRequest = _isDocumentRequest(userMessage);
        final needsTable = _needsTable(userMessage);
        final needsImage = _needsImage(userMessage);

        debugPrint('📄 Documento? $isDocumentRequest');

        String systemPrompt = _systemPrompt;
        if (isDocumentRequest) {
          systemPrompt += '''

IMPORTANTE: Responda APENAS com código HTML. Comece IMEDIATAMENTE com <!DOCTYPE html>.
NÃO escreva "Vou criar", "Aqui está", ou qualquer texto introdutório.
CONTEÚDO EXTENSO: mínimo 6-8 seções, 2000-3000 palavras.''';

          if (needsTable) {
            systemPrompt += '\nINCLUIR tabelas relevantes com dados bem formatados.';
          }

          if (needsImage) {
            systemPrompt += '\nINCLUIR imagens usando URLs válidas (placeholder.com ou picsum.photos).';
          }
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

        debugPrint('📤 Enviando...');

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
            debugPrint('⏰ TIMEOUT');
            throw Exception('Timeout: Requisição demorou muito');
          },
        );

        debugPrint('📥 Status: ${response.statusCode}');

        if (response.statusCode == 429) {
          debugPrint('⚠️ LIMITE ATINGIDO - Próxima key');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (response.statusCode == 401) {
          debugPrint('⚠️ ERRO AUTENTICAÇÃO');
          _blockCurrentKeyAndSwitchToNext();
          retryCount++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['choices'] == null || data['choices'].isEmpty) {
            debugPrint('❌ Resposta inválida');
            throw Exception('Resposta da API inválida');
          }

          String content = data['choices'][0]['message']['content'] as String;
          debugPrint('✅ Recebido (${content.length} chars)');

          if (isDocumentRequest) {
            content = _cleanDocumentResponse(content);
            debugPrint('🧹 Limpo (${content.length} chars)');
          }

          debugPrint('═══════════════════════════════════════');
          debugPrint('✨ SUCESSO!');
          debugPrint('═══════════════════════════════════════');

          return content;
        } else {
          debugPrint('❌ ERRO HTTP: ${response.statusCode}');

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
        debugPrint('💥 ERRO: $e');
        debugPrint('═══════════════════════════════════════');

        if (e.toString().contains('SocketException') || 
            e.toString().contains('Failed host lookup')) {
          throw Exception('Erro de conexão: Verifique sua internet');
        } else if (e.toString().contains('TimeoutException') || 
                   e.toString().contains('Timeout')) {
          throw Exception('Timeout: Requisição demorou muito. Tente novamente.');
        }

        if (retryCount >= maxRetries - 1) {
          throw Exception('Todas as API Keys falharam. Tente novamente mais tarde.');
        }

        retryCount++;
        _blockCurrentKeyAndSwitchToNext();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception('Falha após tentar todas as API Keys');
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
      'crie um html',
      'gere um html',
      'crie uma página',
      'crie um site',
      'crie um currículo',
      'faça um currículo',
      'crie uma proposta',
      'documento sobre',
      'relatório sobre',
    ];

    final lowerMessage = message.toLowerCase();
    return keywords.any((keyword) => lowerMessage.contains(keyword));
  }

  bool _needsTable(String message) {
    final tableKeywords = [
      'tabela',
      'comparação',
      'comparativo',
      'dados',
      'estatística',
      'preço',
      'valores',
      'cronograma',
    ];

    final lowerMessage = message.toLowerCase();
    return tableKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  bool _needsImage(String message) {
    final imageKeywords = [
      'imagem',
      'foto',
      'ilustração',
      'figura',
      'gráfico',
      'com imagens',
      'adicione imagens',
    ];

    final lowerMessage = message.toLowerCase();
    return imageKeywords.any((keyword) => lowerMessage.contains(keyword));
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