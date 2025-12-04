// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _groqApiKey = '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';
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static const String _systemPrompt = '''Você é o DocuGen AI, um assistente extremamente profissional e sofisticado.

REGRAS CRÍTICAS DE FORMATAÇÃO:

1. NUNCA mencione ou mostre asteriscos (**) ou símbolos de markdown na resposta final
2. NUNCA explique como você formata o texto
3. NUNCA diga "vou usar negrito" ou "formatado com **"
4. Responda NATURALMENTE como se estivesse escrevendo diretamente

FORMATAÇÃO PARA SUAS RESPOSTAS:

Use # para títulos principais (H1) - destaque máximo com linha inferior azul
Use ## para subtítulos (H2) - importantes e destacados
Use ### para seções menores (H3)
Use **texto** para negrito (mas NUNCA mostre os asteriscos na resposta)
Use - ou • para listas com bullets
Use números 1. 2. 3. para listas ordenadas
Use Importante:, Atenção:, Nota: para caixas de informação destacadas
Use ``` para blocos de código

PARA TABELAS:
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

EXEMPLO DE BOA RESPOSTA:

# Inteligência Artificial

A inteligência artificial está revolucionando o mundo moderno de formas impressionantes.

## Principais Benefícios

A IA oferece vantagens significativas em diversas áreas:

- Automação de processos complexos e repetitivos
- Análise de grandes volumes de dados em tempo real
- Tomada de decisões mais precisas e baseadas em dados

### Aplicações Práticas

1. Saúde: diagnósticos mais precisos e tratamentos personalizados
2. Finanças: detecção de fraudes e análise de risco
3. Educação: personalização do aprendizado para cada aluno

Importante: A implementação de IA deve sempre considerar questões éticas e de privacidade.

CRIAÇÃO DE DOCUMENTOS HTML:

APENAS crie documentos HTML quando o usuário pedir EXPLICITAMENTE:
- "crie um documento"
- "gere um HTML"
- "faça um site"
- "monte uma página"
- "desenvolva um website"

Para perguntas normais, explicações, conversas: use APENAS a formatação markdown acima

Quando criar HTML:
1. Crie um documento HTML5 completo e profissional
2. Use CSS moderno e responsivo
3. Inclua meta tags apropriadas
4. Design limpo e elegante
5. Totalmente funcional

Seja claro, direto, profissional e extremamente bem organizado em todas as respostas.''';

  Future<String> sendMessage(String userMessage, List<Map<String, String>> messageHistory) async {
    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            ...messageHistory,
          ],
          'temperature': 0.7,
          'max_tokens': 4096,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  String extractHtmlFromResponse(String response) {
    int htmlStart = response.indexOf('<!DOCTYPE html>');
    if (htmlStart == -1) {
      htmlStart = response.indexOf('<html');
    }

    if (htmlStart != -1) {
      final htmlEnd = response.indexOf('</html>', htmlStart);
      if (htmlEnd != -1) {
        return response.substring(htmlStart, htmlEnd + 7);
      }
    }

    final codeBlockStart = response.indexOf('```html');
    if (codeBlockStart != -1) {
      final contentStart = response.indexOf('\n', codeBlockStart) + 1;
      final codeBlockEnd = response.indexOf('```', contentStart);
      if (codeBlockEnd != -1) {
        return response.substring(contentStart, codeBlockEnd).trim();
      }
    }

    return '';
  }
}