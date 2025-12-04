// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  static const String _groqApiKey = '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';
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

  Future<String> sendMessage(String userMessage, List<Map<String, String>> messageHistory) async {
    debugPrint('═══════════════════════════════════════');
    debugPrint('🚀 INICIANDO CHAMADA API');
    debugPrint('📝 Mensagem do usuário: $userMessage');
    debugPrint('═══════════════════════════════════════');

    try {
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
        'model': 'llama-3.3-70b-versatile',
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

      debugPrint('📤 Enviando requisição para: $_groqApiUrl');
      debugPrint('🔑 Usando API Key: ${_groqApiKey.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('⏰ TIMEOUT: Requisição demorou mais de 60 segundos');
          throw Exception('Timeout: A requisição demorou muito tempo');
        },
      );

      debugPrint('📥 Status da resposta: ${response.statusCode}');
      debugPrint('📦 Corpo da resposta (primeiros 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

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
        debugPrint('✨ SUCESSO! Resposta processada');
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
      debugPrint('💥 ERRO CAPTURADO:');
      debugPrint('$e');
      debugPrint('═══════════════════════════════════════');
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        throw Exception('Erro de conexão: Verifique sua internet');
      } else if (e.toString().contains('TimeoutException') || 
                 e.toString().contains('Timeout')) {
        throw Exception('Timeout: Requisição demorou muito');
      } else if (e.toString().contains('401')) {
        throw Exception('Erro de autenticação: API Key inválida');
      } else if (e.toString().contains('429')) {
        throw Exception('Limite de requisições atingido');
      }
      
      rethrow;
    }
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
}