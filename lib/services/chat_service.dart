// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

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

IMPORTANTE: Quando criar documentos HTML:

1. **CONTEÚDO EXTENSO E DETALHADO**:
   - Mínimo de 5-7 seções completas
   - Cada seção deve ter pelo menos 3-4 parágrafos bem desenvolvidos
   - Inclua subsecções quando apropriado
   - Adicione exemplos, casos práticos e detalhes relevantes
   - NÃO crie documentos curtos ou superficiais
   - Desenvolva cada tópico com profundidade

2. **ESTRUTURA PROFISSIONAL**:
   - Sempre incluir capa profissional
   - Sumário completo com links
   - Introdução detalhada
   - Desenvolvimento extenso (múltiplas páginas)
   - Conclusões e recomendações
   - Apêndices quando relevante
   - Referências bibliográficas quando apropriado

3. **ELEMENTOS VISUAIS**:
   - Tabelas bem formatadas com dados reais
   - Caixas de destaque para informações importantes
   - Citações quando relevante
   - Listas organizadas
   - Blocos de código quando técnico
   - Indicadores-chave (KPIs) quando aplicável

4. **TEMPLATE A4 PROFISSIONAL**:
   - Use o template A4 otimizado para impressão
   - Cabeçalho e rodapé apropriados
   - Margens corretas (18mm)
   - Tipografia profissional (Inter ou Segoe UI)
   - Cores corporativas elegantes
   - Layout responsivo

5. **QUALIDADE DO CONTEÚDO**:
   - Informações relevantes e bem pesquisadas
   - Linguagem profissional e clara
   - Estrutura lógica e coerente
   - Dados e estatísticas quando relevante
   - Exemplos práticos e aplicáveis

TEMPLATE BASE A4 (USE COMO REFERÊNCIA):

Estrutura mínima de um documento:
- Página 1: Capa profissional
- Página 2: Sumário
- Página 3+: Introdução (1-2 páginas)
- Página 4+: Desenvolvimento (3-4 páginas mínimo)
- Página N: Análise/Dados (com tabelas)
- Página N+1: Conclusões
- Página N+2: Apêndices/Referências

NUNCA crie documentos com menos de 4-5 páginas A4 de conteúdo real!

═══════════════════════════════════════════════════════════════════════════════

EXEMPLOS DE RESPOSTA:

Para pergunta: "O que é IA?"
Resposta: (texto formatado com markdown, SEM HTML)

Para pedido: "Crie um documento sobre IA"
Resposta: (APENAS HTML completo, sem nenhum texto extra, mínimo 5 páginas)

Seja sempre extremamente detalhado e profissional ao criar documentos!''';

  Future<String> sendMessage(String userMessage, List<Map<String, String>> messageHistory) async {
    try {
      // Detecta se é pedido de documento
      final isDocumentRequest = _isDocumentRequest(userMessage);
      
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
              'content': systemPrompt,
            },
            ...messageHistory,
          ],
          'temperature': 0.7,
          'max_tokens': 8000, // Aumentado para permitir documentos maiores
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'] as String;
        
        // Se for documento e vier com markdown, remove
        if (isDocumentRequest) {
          content = _cleanDocumentResponse(content);
        }
        
        return content;
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
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

  // Método para obter template específico
  String getDocumentTemplate(String templateType, Map<String, String> data) {
    switch (templateType) {
      case 'professional':
        return _getProfessionalTemplate(data);
      case 'minimal':
        return _getMinimalTemplate(data);
      case 'creative':
        return _getCreativeTemplate(data);
      default:
        return _getProfessionalTemplate(data);
    }
  }

  String _getProfessionalTemplate(Map<String, String> data) {
    final title = data['title'] ?? 'Documento Profissional';
    final subtitle = data['subtitle'] ?? 'Subtítulo do documento';
    final author = data['author'] ?? 'Autor';
    final date = data['date'] ?? DateTime.now().toString().substring(0, 10);
    
    return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>$title</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
  @page {
    size: A4;
    margin: 18mm;
  }

  html, body {
    height: 100%;
    background: #f2f3f5;
    font-family: "Inter", "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    -webkit-print-color-adjust: exact;
    color: #222;
    font-size: 12pt;
    line-height: 1.45;
  }

  .sheet {
    width: 210mm;
    min-height: 297mm;
    margin: 12mm auto;
    box-shadow: 0 10px 30px rgba(0,0,0,0.08);
    background: white;
    border-radius: 4px;
    padding: 26mm 20mm 20mm 20mm;
    box-sizing: border-box;
    position: relative;
    overflow: hidden;
  }

  @media print {
    body { background: white; }
    .sheet { box-shadow: none; margin: 0; border-radius: 0; page-break-after: always; }
  }

  :root{
    --accent: #2b6fb6;
    --muted: #6a7380;
    --card: #fafbff;
  }
  
  h1 { font-size: 26pt; margin: 6pt 0 8pt 0; font-weight: 700; color: #0b3a66; }
  h2 { font-size: 16pt; margin: 10pt 0 6pt 0; color: #0b3a66; font-weight: 600; }
  h3 { font-size: 13pt; margin: 8pt 0 6pt 0; font-weight: 600; color: #123; }
  p { margin: 6pt 0; font-size: 11.3pt; color: #222; }

  .cover {
    display:flex;
    flex-direction:column;
    justify-content:center;
    align-items:center;
    height: 100%;
    text-align:center;
    padding: 40mm 20mm;
  }
  
  .cover .logo {
    width: 90px; height: 90px; border-radius: 12px;
    background: var(--accent);
    display:flex;align-items:center;justify-content:center;
    color:white;font-weight:700;font-size:28px;
    box-shadow: 0 6px 18px rgba(10,50,90,0.12);
  }
  
  .cover h1 { font-size: 34pt; margin-top: 18pt; }
  .cover p.lead { font-size: 12pt; color: var(--muted); margin-top: 12pt; max-width: 60%; }

  .highlight {
    border-left: 6px solid var(--accent);
    background: var(--card);
    padding: 10px 12px;
    margin: 8px 0 12px 0;
    border-radius: 4px;
  }

  blockquote {
    margin: 10px 0;
    padding: 10px 14px;
    background: #f7f9fc;
    border-left: 4px solid #cfe3f9;
    font-style: italic;
    color:#333;
  }

  table { width: 100%; border-collapse: collapse; margin: 10px 0 16px 0; font-size: 10.5pt; }
  table thead th {
    text-align:left;
    padding: 8px 10px;
    border-bottom: 2px solid #e1e6ef;
    font-weight:600;
    background: linear-gradient(180deg,#f8fbff, #ffffff);
  }
  table tbody td {
    padding: 8px 10px;
    border-bottom: 1px solid #eef3fb;
    vertical-align: middle;
  }
  tbody tr:nth-child(odd) { background: #fff; }
  tbody tr:nth-child(even) { background: #fbfdff; }

  ul { margin-left: 1.1em; }
  .avoid-break { page-break-inside: avoid; }
  .page-break { page-break-after: always; height: 0; }
  .small { font-size: 10pt; color: var(--muted); }
</style>
</head>
<body>

  <section class="sheet cover">
    <div class="logo" aria-hidden="true">AI</div>
    <h1>$title</h1>
    <p class="lead">$subtitle</p>

    <div style="margin-top:24mm; text-align:center;">
      <div style="font-size:11pt;color:var(--muted)">Elaborado por</div>
      <div style="font-weight:600;font-size:12pt">$author</div>
      <div style="margin-top:8px;color:var(--muted)">$date</div>
    </div>
  </section>

  <!-- CONTEÚDO ADICIONAL SERÁ INSERIDO AQUI -->

</body>
</html>''';
  }

  String _getMinimalTemplate(Map<String, String> data) {
    // Template minimalista (a implementar)
    return _getProfessionalTemplate(data);
  }

  String _getCreativeTemplate(Map<String, String> data) {
    // Template criativo (a implementar)
    return _getProfessionalTemplate(data);
  }
}