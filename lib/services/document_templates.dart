// lib/services/document_templates.dart

class DocumentTemplates {
  
  /// Template A4 Profissional (Padrão)
  static String getProfessionalA4Template() {
    return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Documento Profissional — A4</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
  @page { size: A4; margin: 18mm; }

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

  .doc-header, .doc-footer {
    position: fixed;
    left: 0;
    right: 0;
    width: calc(210mm - 36mm);
    margin-left: 18mm;
    margin-right: 18mm;
    box-sizing: border-box;
  }
  .doc-header { top: 6mm; height: 10mm; display: none; }
  .doc-footer { bottom: 6mm; height: 10mm; display: none; }

  @media print {
    .doc-header, .doc-footer { display: block; }
  }

  .doc-header .left { float: left; font-size: 9pt; color: var(--muted); }
  .doc-header .right { float: right; font-size: 9pt; color: var(--muted); }
  .doc-footer { text-align: center; font-size: 9pt; color: var(--muted); }

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
    display:flex;align-items:center;justify-content:center;color:white;font-weight:700;font-size:28px;
    box-shadow: 0 6px 18px rgba(10,50,90,0.12);
  }
  .cover h1 { font-size: 34pt; margin-top: 18pt; }
  .cover p.lead { font-size: 12pt; color: var(--muted); margin-top: 12pt; max-width: 60%; }

  .toc { padding: 6mm 0; }
  .toc h2 { margin-bottom: 8px; }
  .toc ol { counter-reset: section; margin-left: 18px; }
  .toc li { margin: 6px 0; font-size: 11pt; color: #222; }
  .toc a { text-decoration: none; color: #123; }

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

  pre.code {
    background: #0f1724;
    color: #e6eef8;
    padding: 12px;
    border-radius: 6px;
    overflow:auto;
    font-family: "Courier New", monospace;
    font-size: 10pt;
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
  .kpi { display:flex; gap:14px; align-items:center; margin: 6px 0 16px 0; }
  .kpi .item { background:#f6fbff; padding:10px 12px; border-radius:6px; box-shadow: inset 0 1px 0 rgba(255,255,255,0.6); }

  .small { font-size: 10pt; color: var(--muted); }
  .avoid-break { page-break-inside: avoid; }
  .page-break { page-break-after: always; height: 0; }

  .screen-help { display:block; color:var(--muted); font-size:10pt; margin-top:8px; }
  @media print { .screen-help { display:none; } }

  .footnotes { font-size:10pt; border-top:1px solid #e6ecf5; margin-top:10px; padding-top:6px; color: var(--muted); }
</style>
</head>
<body>
  <!-- Cabeçalho/rodapé para impressão -->
  <div class="doc-header">
    <div class="left">{{HEADER_LEFT}}</div>
    <div class="right">{{HEADER_RIGHT}}</div>
  </div>
  <div class="doc-footer">
    <span class="page-number"></span> — <span class="small">{{FOOTER_TEXT}}</span>
  </div>

  <!-- Conteúdo será inserido aqui -->
  {{CONTENT}}

</body>
</html>''';
  }

  /// Template Minimalista
  static String getMinimalistTemplate() {
    return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Documento Minimalista</title>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@300;400;600&display=swap" rel="stylesheet">

<style>
  @page { size: A4; margin: 25mm; }

  html, body {
    background: #ffffff;
    font-family: "IBM Plex Sans", system-ui, sans-serif;
    color: #1a1a1a;
    font-size: 11pt;
    line-height: 1.6;
  }

  .sheet {
    width: 210mm;
    min-height: 297mm;
    margin: 0 auto;
    background: white;
    padding: 25mm;
    box-sizing: border-box;
  }

  @media print {
    .sheet { page-break-after: always; margin: 0; }
  }

  h1 { font-size: 28pt; margin: 12pt 0; font-weight: 600; color: #000; border-bottom: 2px solid #000; padding-bottom: 8pt; }
  h2 { font-size: 16pt; margin: 18pt 0 8pt 0; color: #000; font-weight: 600; }
  h3 { font-size: 13pt; margin: 12pt 0 6pt 0; font-weight: 600; color: #333; }
  p { margin: 8pt 0; color: #1a1a1a; }

  table { width: 100%; border-collapse: collapse; margin: 12pt 0; }
  table thead th {
    text-align:left;
    padding: 8px;
    border-bottom: 2px solid #000;
    font-weight:600;
  }
  table tbody td {
    padding: 8px;
    border-bottom: 1px solid #ddd;
  }

  ul, ol { margin-left: 1.2em; }
  blockquote { 
    margin: 12pt 0; 
    padding-left: 16pt; 
    border-left: 3px solid #000; 
    font-style: italic; 
  }
</style>
</head>
<body>
  {{CONTENT}}
</body>
</html>''';
  }

  /// Template Corporativo Moderno
  static String getCorporateModernTemplate() {
    return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Documento Corporativo</title>
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">

<style>
  @page { size: A4; margin: 20mm; }

  html, body {
    background: #f5f5f5;
    font-family: "Roboto", Arial, sans-serif;
    color: #333;
    font-size: 11pt;
    line-height: 1.5;
  }

  .sheet {
    width: 210mm;
    min-height: 297mm;
    margin: 10mm auto;
    background: white;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    padding: 20mm;
    box-sizing: border-box;
  }

  @media print {
    body { background: white; }
    .sheet { box-shadow: none; margin: 0; page-break-after: always; }
  }

  :root {
    --primary: #1e3a8a;
    --secondary: #3b82f6;
    --accent: #60a5fa;
  }

  h1 { 
    font-size: 24pt; 
    margin: 0 0 12pt 0; 
    font-weight: 700; 
    color: var(--primary);
    border-bottom: 3px solid var(--secondary);
    padding-bottom: 8pt;
  }
  h2 { 
    font-size: 16pt; 
    margin: 16pt 0 8pt 0; 
    color: var(--primary); 
    font-weight: 500;
    background: linear-gradient(90deg, var(--accent), transparent);
    padding: 8pt 12pt;
    border-radius: 4px;
  }
  h3 { font-size: 13pt; margin: 12pt 0 6pt 0; font-weight: 500; color: #444; }
  p { margin: 6pt 0; }

  .header-bar {
    background: var(--primary);
    color: white;
    padding: 12pt;
    margin: -20mm -20mm 15mm -20mm;
    text-align: center;
  }

  table { width: 100%; border-collapse: collapse; margin: 12pt 0; }
  table thead th {
    background: var(--primary);
    color: white;
    text-align:left;
    padding: 10px;
    font-weight:500;
  }
  table tbody td {
    padding: 10px;
    border-bottom: 1px solid #e5e7eb;
  }
  tbody tr:hover { background: #f9fafb; }

  .info-box {
    background: #eff6ff;
    border-left: 4px solid var(--secondary);
    padding: 12pt;
    margin: 12pt 0;
    border-radius: 4px;
  }
</style>
</head>
<body>
  {{CONTENT}}
</body>
</html>''';
  }

  /// Retorna lista de templates disponíveis
  static List<Map<String, String>> getAvailableTemplates() {
    return [
      {
        'id': 'professional',
        'name': 'Profissional A4',
        'description': 'Template padrão otimizado para documentos formais e relatórios',
      },
      {
        'id': 'minimalist',
        'name': 'Minimalista',
        'description': 'Design limpo e focado no conteúdo',
      },
      {
        'id': 'corporate',
        'name': 'Corporativo Moderno',
        'description': 'Visual corporativo com cores modernas',
      },
    ];
  }

  /// Retorna template específico pelo ID
  static String getTemplateById(String id) {
    switch (id) {
      case 'professional':
        return getProfessionalA4Template();
      case 'minimalist':
        return getMinimalistTemplate();
      case 'corporate':
        return getCorporateModernTemplate();
      default:
        return getProfessionalA4Template();
    }
  }
}