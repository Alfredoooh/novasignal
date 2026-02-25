import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import '../models/document.dart';

// ── Design tokens ─────────────────────────────────────
const _kPill  = 999.0;
const _kCard  = 12.0;
const _kModal = 20.0;
const _kChip  = 6.0;

// ── Template model ────────────────────────────────────
class _Tpl {
  final String category, title, preview, html;
  const _Tpl({required this.category, required this.title, required this.preview, required this.html});
}

// ═══════════════════════════════════════════════════════
// TEMPLATES — 24 templates across 6 categories
// ═══════════════════════════════════════════════════════
const _kTemplates = <_Tpl>[

  // ── Negócios ──────────────────────────────────────
  _Tpl(
    category: 'Negócios', title: 'Relatório Executivo',
    preview: 'Relatório trimestral com KPIs, resultados e recomendações estratégicas.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm 20mm 15mm 20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;padding:0;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:2em;font-weight:800;color:#1a1a1a;margin-bottom:6px}
h2{font-size:1.3em;font-weight:700;color:#2d2d2d;margin:20px 0 10px;border-left:4px solid #555;padding-left:12px}
h3{font-size:1.1em;font-weight:600;color:#2d2d2d;margin:14px 0 6px}
p{margin-bottom:10px;font-size:.95em}
ul,ol{margin:0 0 10px 20px;font-size:.95em}
li{margin-bottom:4px}
hr{border:none;border-top:1.5px solid #2d2d2d;margin:16px 0}
blockquote{border-left:4px solid #888;padding:8px 14px;background:#f5f5f5;margin:14px 0;font-style:italic;color:#444}
table{width:100%;border-collapse:collapse;margin:14px 0;font-size:.88em}
th{background:#2d2d2d;color:#fff;padding:8px 10px;text-align:left;font-weight:600}
td{padding:7px 10px;border-bottom:1px solid #e0e0e0}
tr:nth-child(even) td{background:#f8f8f8}
header{text-align:center;border-bottom:2px solid #2d2d2d;padding-bottom:18px;margin-bottom:24px}
.subtitle{color:#555;font-size:1em;margin-top:4px}
.badge{display:inline-block;background:#2d2d2d;color:#fff;padding:3px 10px;border-radius:4px;font-size:.78em;font-weight:600;margin-top:6px}
</style></head><body>
<div class="page">
<header>
<h1>Relatório Executivo</h1>
<p class="subtitle">Período: Q1 2025 &nbsp;·&nbsp; Elaborado por: ___________</p>
<span class="badge">CONFIDENCIAL</span>
</header>
<h2>Resumo Executivo</h2>
<p>Este relatório apresenta os principais indicadores de desempenho do período, consolidando resultados financeiros, operacionais e estratégicos para apoiar a tomada de decisão.</p>
<blockquote><strong>Insight chave:</strong> Crescimento de 12% na receita em relação ao trimestre anterior, impulsionado pela expansão do portfólio de serviços.</blockquote>
<h2>1. Resultados Financeiros</h2>
<ul>
<li><strong>Receita total:</strong> R$ ___________</li>
<li><strong>Lucro bruto:</strong> R$ ___________</li>
<li><strong>Margem líquida:</strong> ___%</li>
<li><strong>Custo operacional:</strong> R$ ___________</li>
</ul>
<h2>2. KPIs Operacionais</h2>
<table>
<tr><th>Indicador</th><th>Meta</th><th>Realizado</th><th>Variação</th></tr>
<tr><td>Vendas</td><td>___</td><td>___</td><td>+__%</td></tr>
<tr><td>NPS</td><td>___</td><td>___</td><td>+___</td></tr>
<tr><td>Churn</td><td>___%</td><td>___%</td><td>-__%</td></tr>
</table>
</div>
<div class="page">
<h2>3. Destaques do Período</h2>
<ul>
<li>Lançamento de novo produto em ___________</li>
<li>Expansão para mercado de ___________</li>
<li>Parceria estratégica com ___________</li>
</ul>
<h2>4. Análise de Riscos</h2>
<table>
<tr><th>Risco</th><th>Probabilidade</th><th>Impacto</th><th>Mitigação</th></tr>
<tr><td>Risco 1</td><td>Média</td><td>Alto</td><td>___________</td></tr>
<tr><td>Risco 2</td><td>Baixa</td><td>Médio</td><td>___________</td></tr>
</table>
<h2>5. Próximos Passos</h2>
<ol>
<li>Definir proprietário do projeto</li>
<li>Validar cronograma com stakeholders</li>
<li>Executar prova de conceito até ___________</li>
</ol>
<h2>Conclusão</h2>
<p>Os resultados do período demonstram ___________ . A equipa mantém o foco em ___________ para o próximo trimestre.</p>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Negócios', title: 'Proposta Comercial',
    preview: 'Proposta profissional com escopo, investimento, prazo e condições.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm 20mm 15mm 20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;padding:0;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:2em;font-weight:800;color:#1a1a1a;margin-bottom:6px}
h2{font-size:1.3em;font-weight:700;color:#2d2d2d;margin:20px 0 10px;border-left:4px solid #555;padding-left:12px}
p{margin-bottom:10px;font-size:.95em}
ul,ol{margin:0 0 10px 20px;font-size:.95em}li{margin-bottom:4px}
hr{border:none;border-top:1.5px solid #ddd;margin:16px 0}
table{width:100%;border-collapse:collapse;margin:14px 0;font-size:.88em}
th{background:#1a1a1a;color:#fff;padding:8px 10px;text-align:left;font-weight:600}
td{padding:7px 10px;border-bottom:1px solid #e0e0e0}
tr:nth-child(even) td{background:#f8f8f8}
.cover{text-align:center;padding:60px 0 40px}
.cover h1{font-size:2.6em;margin-bottom:10px}
.cover .sub{font-size:1.1em;color:#555;margin-bottom:24px}
.info-row{display:flex;gap:30px;margin:14px 0}
.info-box{flex:1;background:#f5f5f5;padding:14px;border-radius:6px}
.info-box strong{display:block;font-size:.75em;text-transform:uppercase;letter-spacing:1px;color:#888;margin-bottom:4px}
</style></head><body>
<div class="page">
<div class="cover">
<h1>Proposta Comercial</h1>
<p class="sub">Preparada para: <strong>___________</strong></p>
<hr>
</div>
<div class="info-row">
<div class="info-box"><strong>Data</strong>___________</div>
<div class="info-box"><strong>Validade</strong>30 dias</div>
<div class="info-box"><strong>Referência</strong>PC-2025-001</div>
</div>
<h2>Introdução</h2>
<p>Apresentamos esta proposta com o objetivo de atender às necessidades de <strong>___________</strong>, oferecendo uma solução completa e personalizada ao vosso contexto específico.</p>
<h2>Solução Proposta</h2>
<ol>
<li><strong>Fase 1 — Diagnóstico:</strong> Análise detalhada do contexto atual. Duração: ___ semanas.</li>
<li><strong>Fase 2 — Implementação:</strong> Execução das soluções definidas. Duração: ___ semanas.</li>
<li><strong>Fase 3 — Acompanhamento:</strong> Suporte e ajustes pós-entrega. Duração: ___ semanas.</li>
</ol>
<h2>Escopo de Entrega</h2>
<ul>
<li>Entrega 1 — Descrição detalhada</li>
<li>Entrega 2 — Descrição detalhada</li>
<li>Entrega 3 — Descrição detalhada</li>
</ul>
</div>
<div class="page">
<h2>Investimento</h2>
<table>
<tr><th>Serviço / Item</th><th>Qtd.</th><th>Valor Unit.</th><th>Total</th></tr>
<tr><td>Fase 1 — Diagnóstico</td><td>1</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Fase 2 — Implementação</td><td>1</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Fase 3 — Suporte</td><td>1</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td><strong>Total</strong></td><td></td><td></td><td><strong>R$ ___________</strong></td></tr>
</table>
<h2>Condições Comerciais</h2>
<ul>
<li><strong>Pagamento:</strong> 50% na assinatura, 50% na entrega final</li>
<li><strong>Prazo total:</strong> ___ semanas a partir da aprovação</li>
<li><strong>Suporte pós-entrega:</strong> ___ dias</li>
</ul>
<h2>Próximos Passos</h2>
<ol>
<li>Aprovação da proposta pelo cliente</li>
<li>Assinatura do contrato</li>
<li>Pagamento da primeira parcela</li>
<li>Início do projeto: ___________</li>
</ol>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Negócios', title: 'Acta de Reunião',
    preview: 'Registo estruturado com participantes, decisões e tarefas atribuídas.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.8em;font-weight:800;color:#1a1a1a;border-bottom:2px solid #1a1a1a;padding-bottom:10px;margin-bottom:16px}
h2{font-size:1.2em;font-weight:700;color:#2d2d2d;margin:18px 0 8px;text-transform:uppercase;letter-spacing:1px;font-size:.85em;color:#888}
h3{font-size:1.05em;font-weight:700;color:#1a1a1a;margin:12px 0 6px}
p{margin-bottom:8px;font-size:.95em}
ul{margin:0 0 10px 18px;font-size:.95em}li{margin-bottom:4px}
table{width:100%;border-collapse:collapse;margin:10px 0;font-size:.88em}
th{background:#f0f0f0;color:#1a1a1a;padding:8px 10px;text-align:left;font-weight:700;border-bottom:2px solid #ddd}
td{padding:7px 10px;border-bottom:1px solid #eee}
.meta-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:20px}
.meta-item{background:#f8f8f8;padding:10px 14px;border-radius:6px}
.meta-label{font-size:.72em;text-transform:uppercase;letter-spacing:1px;color:#888;font-weight:600;margin-bottom:2px}
.meta-value{font-size:.92em;color:#1a1a1a;font-weight:500}
.status{display:inline-block;padding:2px 8px;border-radius:4px;font-size:.72em;font-weight:700}
.s-done{background:#d1fae5;color:#065f46}
.s-pend{background:#fef3c7;color:#92400e}
</style></head><body>
<div class="page">
<h1>Acta de Reunião</h1>
<div class="meta-grid">
<div class="meta-item"><div class="meta-label">Data</div><div class="meta-value">___________</div></div>
<div class="meta-item"><div class="meta-label">Hora</div><div class="meta-value">___________</div></div>
<div class="meta-item"><div class="meta-label">Local / Plataforma</div><div class="meta-value">___________</div></div>
<div class="meta-item"><div class="meta-label">Moderador</div><div class="meta-value">___________</div></div>
</div>
<h2>Participantes</h2>
<ul>
<li>___________ — Função/Departamento</li>
<li>___________ — Função/Departamento</li>
<li>___________ — Função/Departamento</li>
</ul>
<h2>Ordem de Trabalhos</h2>
<ul>
<li>Ponto 1 — ___________</li>
<li>Ponto 2 — ___________</li>
<li>Ponto 3 — ___________</li>
</ul>
<h2>Desenvolvimento</h2>
<h3>1. Ponto 1 — ___________</h3>
<p>Resumo da discussão. Quem falou, o que foi apresentado, questões levantadas.</p>
<h3>2. Ponto 2 — ___________</h3>
<p>Resumo da discussão.</p>
<h2>Decisões Tomadas</h2>
<ul>
<li>Decisão 1: ___________</li>
<li>Decisão 2: ___________</li>
</ul>
<h2>Tarefas e Responsáveis</h2>
<table>
<tr><th>Tarefa</th><th>Responsável</th><th>Prazo</th><th>Estado</th></tr>
<tr><td>Tarefa 1</td><td>___________</td><td>___________</td><td><span class="status s-pend">Pendente</span></td></tr>
<tr><td>Tarefa 2</td><td>___________</td><td>___________</td><td><span class="status s-pend">Pendente</span></td></tr>
</table>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Negócios', title: 'Plano de Negócios',
    preview: 'Documento completo para apresentar um negócio a investidores ou sócios.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm 20mm 15mm 20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.cover{display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:200mm;text-align:center}
.cover-logo{font-size:3.5em;font-weight:900;letter-spacing:-1px;margin-bottom:8px}
.cover-sub{font-size:1.1em;color:#666;margin-bottom:30px}
.cover-line{width:80px;height:3px;background:#1a1a1a;margin:20px auto}
.cover-info{font-size:.85em;color:#888}
h2{font-size:1.3em;font-weight:700;color:#1a1a1a;margin:22px 0 10px;border-left:4px solid #1a1a1a;padding-left:12px}
h3{font-size:1.05em;font-weight:700;color:#2d2d2d;margin:14px 0 6px}
p{margin-bottom:10px;font-size:.95em}
ul,ol{margin:0 0 10px 20px;font-size:.95em}li{margin-bottom:5px}
table{width:100%;border-collapse:collapse;margin:14px 0;font-size:.88em}
th{background:#1a1a1a;color:#fff;padding:8px 12px;text-align:left}
td{padding:8px 12px;border-bottom:1px solid #e8e8e8}
.swot{display:grid;grid-template-columns:1fr 1fr;gap:0;border:1px solid #ddd}
.swot-cell{padding:14px;border:1px solid #ddd}
.swot-cell h4{font-size:.8em;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px;color:#888}
.swot-cell ul{margin-left:14px;font-size:.88em}
</style></head><body>
<div class="page">
<div class="cover">
<div class="cover-logo">Nome do Negócio</div>
<div class="cover-sub">Plano de Negócios · ___________</div>
<div class="cover-line"></div>
<div class="cover-info">Preparado por: ___________ <br>Data: ___________</div>
</div>
</div>
<div class="page">
<h2>1. Sumário Executivo</h2>
<p>Descrição concisa do negócio, proposta de valor, mercado-alvo e vantagem competitiva. Este sumário deve ser suficiente para despertar interesse num investidor.</p>
<h2>2. Descrição do Negócio</h2>
<h3>2.1 Missão</h3><p>___________</p>
<h3>2.2 Visão</h3><p>___________</p>
<h3>2.3 Valores</h3>
<ul><li>Valor 1</li><li>Valor 2</li><li>Valor 3</li></ul>
<h3>2.4 Produto / Serviço</h3>
<p>Descrição detalhada do que a empresa oferece e como resolve o problema do cliente.</p>
<h2>3. Análise de Mercado</h2>
<h3>3.1 Público-Alvo</h3><p>Descrição detalhada do cliente ideal — demográfico, comportamental, necessidades.</p>
<h3>3.2 Tamanho do Mercado</h3>
<ul><li>TAM (Mercado total): R$ ___________</li><li>SAM (Mercado disponível): R$ ___________</li><li>SOM (Mercado alcançável): R$ ___________</li></ul>
<h2>4. Análise SWOT</h2>
<div class="swot">
<div class="swot-cell"><h4>Forças</h4><ul><li>___________</li><li>___________</li></ul></div>
<div class="swot-cell"><h4>Fraquezas</h4><ul><li>___________</li><li>___________</li></ul></div>
<div class="swot-cell"><h4>Oportunidades</h4><ul><li>___________</li><li>___________</li></ul></div>
<div class="swot-cell"><h4>Ameaças</h4><ul><li>___________</li><li>___________</li></ul></div>
</div>
</div>
<div class="page">
<h2>5. Plano Financeiro</h2>
<table>
<tr><th>Item</th><th>Ano 1</th><th>Ano 2</th><th>Ano 3</th></tr>
<tr><td>Receita</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Custo Operacional</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Lucro Líquido</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
</table>
<h2>6. Plano de Ação</h2>
<table>
<tr><th>Ação</th><th>Responsável</th><th>Prazo</th><th>Status</th></tr>
<tr><td>Ação 1</td><td>___</td><td>___</td><td>___</td></tr>
<tr><td>Ação 2</td><td>___</td><td>___</td><td>___</td></tr>
</table>
</div>
</body></html>''',
  ),

  // ── CV & Perfil ───────────────────────────────────
  _Tpl(
    category: 'CV & Perfil', title: 'Currículo Profissional',
    preview: 'CV completo com experiência, competências, educação e projetos.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:18mm 20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.6;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.cv-header{display:flex;justify-content:space-between;align-items:flex-end;border-bottom:2px solid #1a1a1a;padding-bottom:16px;margin-bottom:20px}
.cv-name{font-size:2em;font-weight:900;letter-spacing:-0.5px;line-height:1}
.cv-title{font-size:1em;color:#555;margin-top:4px}
.cv-contacts{text-align:right;font-size:.82em;color:#666;line-height:1.8}
.cv-contacts a{color:#1a1a1a;text-decoration:none}
h2{font-size:.72em;text-transform:uppercase;letter-spacing:2px;color:#888;font-weight:700;margin:20px 0 10px;padding-bottom:4px;border-bottom:1px solid #e0e0e0}
h3{font-size:1em;font-weight:700;color:#1a1a1a;margin-bottom:2px}
.job-meta{font-size:.82em;color:#888;margin-bottom:6px}
p{font-size:.9em;margin-bottom:8px}
ul{margin:4px 0 10px 16px;font-size:.88em}li{margin-bottom:3px}
.skills-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px 20px;margin-bottom:10px}
.skill-tag{font-size:.82em;padding:3px 0;color:#444}
.job-block{margin-bottom:14px;padding-bottom:14px;border-bottom:1px solid #f0f0f0}
.job-block:last-child{border-bottom:none}
</style></head><body>
<div class="page">
<div class="cv-header">
<div>
<div class="cv-name">Nome Completo</div>
<div class="cv-title">Cargo / Especialidade · Localidade</div>
</div>
<div class="cv-contacts">
email@exemplo.com<br>
+244 9XX XXX XXX<br>
www.linkedin.com/in/nome<br>
www.exemplo.com
</div>
</div>
<h2>Resumo Profissional</h2>
<p>Profissional com mais de ___ anos de experiência em ___________. Forte background em ___________, com foco em resultados mensuráveis e trabalho colaborativo. Apaixonado por soluções que conectam tecnologia e impacto real ao utilizador.</p>
<h2>Experiência Profissional</h2>
<div class="job-block">
<h3>Cargo Atual — Empresa Atual</h3>
<div class="job-meta">Jan 2022 — Atualmente &nbsp;·&nbsp; Luanda, Angola &nbsp;·&nbsp; Remoto</div>
<ul>
<li>Responsabilidade com resultado mensurável — ex.: reduzi tempo de entrega em 30%.</li>
<li>Responsabilidade com resultado mensurável.</li>
<li>Responsabilidade com resultado mensurável.</li>
</ul>
</div>
<div class="job-block">
<h3>Cargo Anterior — Empresa Anterior</h3>
<div class="job-meta">Mar 2019 — Dez 2021 &nbsp;·&nbsp; Luanda, Angola</div>
<ul>
<li>Responsabilidade com resultado mensurável.</li>
<li>Responsabilidade com resultado mensurável.</li>
</ul>
</div>
<h2>Educação</h2>
<div class="job-block">
<h3>Licenciatura em ___________ — Universidade ___________</h3>
<div class="job-meta">2015 — 2018</div>
</div>
<h2>Competências</h2>
<div class="skills-grid">
<div class="skill-tag">· JavaScript / TypeScript</div>
<div class="skill-tag">· React / Next.js</div>
<div class="skill-tag">· Python / FastAPI</div>
<div class="skill-tag">· Flutter / Dart</div>
<div class="skill-tag">· Figma / Design UI</div>
<div class="skill-tag">· Git / Docker / Firebase</div>
</div>
<h2>Idiomas</h2>
<ul>
<li>Português — Nativo</li>
<li>Inglês — Fluente (C1)</li>
</ul>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'CV & Perfil', title: 'Carta de Apresentação',
    preview: 'Carta de candidatura com introdução, valor diferenciado e encerramento.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:22mm 24mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.75;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.sender{font-size:.9em;color:#555;margin-bottom:24px}
.sender strong{display:block;font-size:1.15em;color:#1a1a1a;font-weight:700;margin-bottom:2px}
.date{margin-bottom:20px;font-size:.88em;color:#888}
.recipient{margin-bottom:24px;font-size:.9em}
.recipient strong{font-weight:700}
.salutation{margin-bottom:18px;font-size:.95em}
h2{font-size:1.05em;font-weight:700;color:#1a1a1a;margin:20px 0 8px}
p{margin-bottom:12px;font-size:.93em}
ul{margin:6px 0 14px 18px;font-size:.9em}li{margin-bottom:5px}
.closing{margin-top:28px;font-size:.92em}
.signature{margin-top:36px;font-size:.95em;font-weight:700}
hr{border:none;border-top:1px solid #e0e0e0;margin:20px 0}
</style></head><body>
<div class="page">
<div class="sender">
<strong>Nome Completo</strong>
email@exemplo.com &nbsp;·&nbsp; +244 9XX XXX XXX &nbsp;·&nbsp; Localidade
</div>
<div class="date">___________ (data)</div>
<div class="recipient">
<p><strong>A atenção de:</strong></p>
<p>Nome do Responsável / Recursos Humanos<br>Nome da Empresa</p>
</div>
<div class="salutation">Exm.ª(o) Sr.ª(o) ___________,</div>
<h2>Porquê esta empresa?</h2>
<p>Escrevo com entusiasmo para candidatar-me à vaga de <strong>___________</strong> na <strong>___________</strong>. Acompanho o trabalho da vossa equipa há algum tempo e admiro profundamente como a empresa aborda ___________.</p>
<h2>O Que Trago</h2>
<p>Ao longo dos últimos ___ anos, desenvolvi competências sólidas em ___________, com resultados concretos:</p>
<ul>
<li>Resultado 1 — descrição com impacto mensurável.</li>
<li>Resultado 2 — descrição com impacto mensurável.</li>
<li>Resultado 3 — descrição com impacto mensurável.</li>
</ul>
<h2>Encerramento</h2>
<p>Fico ao dispor para uma conversa e agradeço desde já a atenção dispensada. Em anexo encontra o meu currículo para referência adicional.</p>
<div class="closing">Com os melhores cumprimentos,</div>
<div class="signature">Nome Completo</div>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'CV & Perfil', title: 'Portfólio de Projetos',
    preview: 'Apresentação de projetos realizados com descrição, tecnologias e resultados.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.port-header{border-bottom:3px solid #1a1a1a;padding-bottom:14px;margin-bottom:24px}
.port-header h1{font-size:2.2em;font-weight:900;letter-spacing:-1px}
.port-header p{font-size:.9em;color:#666;margin-top:4px}
.project{border:1px solid #e0e0e0;border-radius:8px;padding:18px;margin-bottom:18px}
.proj-title{font-size:1.1em;font-weight:800;margin-bottom:4px}
.proj-meta{font-size:.78em;color:#888;margin-bottom:10px}
.proj-desc{font-size:.88em;color:#444;margin-bottom:12px;line-height:1.6}
.tags{display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px}
.tag{background:#f0f0f0;padding:3px 10px;border-radius:4px;font-size:.75em;font-weight:600;color:#444}
.proj-result{background:#f8f8f8;padding:10px 14px;border-radius:4px;font-size:.82em;border-left:3px solid #1a1a1a}
h2{font-size:.72em;text-transform:uppercase;letter-spacing:2px;color:#888;font-weight:700;margin:24px 0 12px}
</style></head><body>
<div class="page">
<div class="port-header">
<h1>Portfólio</h1>
<p>Nome Completo &nbsp;·&nbsp; Especialidade &nbsp;·&nbsp; email@exemplo.com</p>
</div>
<h2>Projetos em Destaque</h2>
<div class="project">
<div class="proj-title">Nome do Projeto 1</div>
<div class="proj-meta">2024 &nbsp;·&nbsp; Tipo de projeto &nbsp;·&nbsp; Cliente/Empresa</div>
<div class="proj-desc">Descrição do projeto: o que foi construído, qual o problema que resolve, e qual a abordagem utilizada. Inclui contexto e decisões de design relevantes.</div>
<div class="tags">
<span class="tag">Tecnologia 1</span>
<span class="tag">Tecnologia 2</span>
<span class="tag">Ferramenta 3</span>
</div>
<div class="proj-result">🎯 Resultado: Descrição do impacto gerado — ex.: aumento de 40% na conversão.</div>
</div>
<div class="project">
<div class="proj-title">Nome do Projeto 2</div>
<div class="proj-meta">2023 &nbsp;·&nbsp; Tipo de projeto &nbsp;·&nbsp; Cliente/Empresa</div>
<div class="proj-desc">Descrição do projeto 2. Destaca as responsabilidades específicas e contribuições individuais no projeto.</div>
<div class="tags">
<span class="tag">React</span>
<span class="tag">Node.js</span>
<span class="tag">PostgreSQL</span>
</div>
<div class="proj-result">🎯 Resultado: Descrição do impacto mensurável.</div>
</div>
<div class="project">
<div class="proj-title">Nome do Projeto 3</div>
<div class="proj-meta">2023 &nbsp;·&nbsp; Tipo de projeto &nbsp;·&nbsp; Cliente/Empresa</div>
<div class="proj-desc">Descrição do projeto 3.</div>
<div class="tags">
<span class="tag">Flutter</span>
<span class="tag">Firebase</span>
</div>
<div class="proj-result">🎯 Resultado: Descrição do impacto mensurável.</div>
</div>
</div>
</body></html>''',
  ),

  // ── Académico ─────────────────────────────────────
  _Tpl(
    category: 'Académico', title: 'Ensaio Académico',
    preview: 'Estrutura com resumo, introdução, desenvolvimento, conclusão e referências.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:25mm 25mm 20mm 30mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Georgia,'Times New Roman',serif;line-height:1.8;color:#1a1a1a;background:#fff}
.page{min-height:247mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.cover{text-align:center;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:200mm}
.cover h1{font-size:1.5em;font-weight:700;margin-bottom:12px;line-height:1.3}
.cover p{font-size:.9em;color:#555;margin-bottom:6px}
.cover hr{width:60%;border:none;border-top:1px solid #ccc;margin:20px auto}
h1{font-size:1.3em;font-weight:700;text-align:center;margin-bottom:20px;line-height:1.3}
h2{font-size:1.05em;font-weight:700;margin:24px 0 10px;text-align:left}
h3{font-size:.98em;font-weight:700;margin:18px 0 8px}
p{margin-bottom:12px;font-size:.95em;text-align:justify}
.abstract{background:#f8f8f8;border:1px solid #e0e0e0;padding:16px 20px;margin:16px 0;font-size:.88em}
.abstract strong{display:block;font-weight:700;margin-bottom:8px;font-size:.9em;text-transform:uppercase;letter-spacing:1px}
.keywords{font-style:italic;font-size:.85em;margin-top:10px}
blockquote{margin:14px 0;padding:8px 20px;border-left:3px solid #999;color:#555;font-style:italic;font-size:.9em}
.references p{font-size:.85em;padding-left:20px;text-indent:-20px;margin-bottom:8px}
</style></head><body>
<div class="page">
<div class="cover">
<h1>Título do Ensaio Académico</h1>
<p><strong>Autor(a):</strong> ___________</p>
<p><strong>Instituição:</strong> ___________</p>
<p><strong>Disciplina:</strong> ___________ &nbsp;·&nbsp; <strong>Professor(a):</strong> ___________</p>
<hr>
<p><strong>Data:</strong> ___________</p>
</div>
</div>
<div class="page">
<div class="abstract">
<strong>Resumo</strong>
Este trabalho analisa ___________. O objectivo central é ___________. A metodologia empregada baseia-se em ___________, e as principais conclusões indicam que ___________.
<div class="keywords"><strong>Palavras-chave:</strong> palavra1, palavra2, palavra3.</div>
</div>
<h2>1. Introdução</h2>
<p>A presente análise tem como objectivo explorar o tema <em>___________</em>, abordando os seus principais aspectos sob a perspectiva de ___________. A relevância desta temática justifica-se pelo facto de ___________.</p>
<p>Para tal, estrutura-se o presente trabalho em quatro partes: a fundamentação teórica, a análise e discussão dos dados, as conclusões e, por último, as referências bibliográficas.</p>
<h2>2. Fundamentação Teórica</h2>
<p>Com base na literatura existente, é possível identificar três perspectivas principais. Em primeiro lugar, ___________ (Autor, ano) argumenta que ___________. Em segundo lugar, ___________ (Autor, ano) propõe que ___________.</p>
<blockquote>"Citação directa do autor mais relevante para este estudo." (Autor, ano, p. __)</blockquote>
<h2>3. Análise e Discussão</h2>
<p>A análise dos dados revela que ___________. Este resultado está em consonância com as ideias de ___________ (Autor, ano). Contrariamente, ___________ (Autor, ano) sustenta que ___________.</p>
<h2>4. Conclusão</h2>
<p>Em suma, os argumentos apresentados demonstram que ___________. As principais contribuições deste trabalho residem em: (1) ___________; (2) ___________; (3) ___________.</p>
<h2 class="references">Referências Bibliográficas</h2>
<div class="references">
<p>Autor, A. B. (2024). <em>Título da obra completa</em>. Editora.</p>
<p>Autor, C. D. &amp; Autor, E. F. (2023). Título do artigo. <em>Nome da Revista</em>, <em>10</em>(2), 45–67.</p>
</div>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Académico', title: 'Relatório de Pesquisa',
    preview: 'Artigo científico com metodologia, resultados, discussão e referências.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:22mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.7;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.6em;font-weight:800;border-bottom:2px solid #1a1a1a;padding-bottom:12px;margin-bottom:18px}
h2{font-size:1.1em;font-weight:700;color:#2d2d2d;margin:20px 0 8px;text-transform:uppercase;font-size:.8em;letter-spacing:1.5px;color:#666}
h3{font-size:1em;font-weight:700;margin:14px 0 6px}
p{margin-bottom:10px;font-size:.92em}
ul,ol{margin:0 0 10px 18px;font-size:.9em}li{margin-bottom:4px}
table{width:100%;border-collapse:collapse;margin:14px 0;font-size:.86em}
th{background:#333;color:#fff;padding:8px 10px;text-align:left}
td{padding:7px 10px;border-bottom:1px solid #e0e0e0}
.abstract-box{border:1px solid #ccc;padding:16px;margin:16px 0;background:#fafafa}
.abstract-box h4{font-size:.75em;text-transform:uppercase;letter-spacing:1.5px;color:#888;margin-bottom:8px}
.keyword{display:inline-block;background:#e8e8e8;padding:2px 8px;border-radius:3px;font-size:.75em;margin:2px;font-weight:600}
</style></head><body>
<div class="page">
<h1>Título da Pesquisa</h1>
<p><strong>Autores:</strong> ___________ · <strong>Instituição:</strong> ___________ · <strong>Data:</strong> ___________</p>
<div class="abstract-box">
<h4>Abstract / Resumo</h4>
<p>Este estudo investigou ___________. A metodologia empregada foi ___________. Os resultados indicam que ___________. Conclui-se que ___________.</p>
<div><span class="keyword">keyword1</span> <span class="keyword">keyword2</span> <span class="keyword">keyword3</span></div>
</div>
<h2>1. Introdução</h2>
<p>O presente trabalho tem como objectivo ___________. A relevância desta pesquisa reside em ___________. A hipótese central é que ___________.</p>
<h2>2. Metodologia</h2>
<ul>
<li><strong>Abordagem:</strong> Qualitativa / Quantitativa / Mista</li>
<li><strong>Amostra:</strong> Descrição da amostra e critérios de seleção.</li>
<li><strong>Instrumentos:</strong> Questionários, entrevistas, análise documental.</li>
</ul>
<h2>3. Resultados</h2>
<table>
<tr><th>Variável</th><th>Resultado</th><th>Significância (p)</th><th>Interpretação</th></tr>
<tr><td>Variável A</td><td>___</td><td>p &lt; 0.05</td><td>Significativo</td></tr>
<tr><td>Variável B</td><td>___</td><td>p &lt; 0.01</td><td>Muito significativo</td></tr>
<tr><td>Variável C</td><td>___</td><td>p &gt; 0.05</td><td>Não significativo</td></tr>
</table>
<h2>4. Discussão</h2>
<p>Os dados apresentados corroboram a hipótese inicial de que ___________. Contudo, observa-se que ___________ constitui uma limitação importante do estudo.</p>
<h2>5. Conclusão</h2>
<p>Conclui-se que ___________. As principais contribuições são: (1) ___________; (2) ___________. Pesquisas futuras deverão explorar ___________.</p>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Académico', title: 'Trabalho de Grupo',
    preview: 'Relatório colaborativo com capa, introdução, desenvolvimento e contribuições.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:22mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.7;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.cover{display:flex;flex-direction:column;align-items:center;text-align:center;justify-content:center;min-height:220mm;gap:10px}
.univ{font-size:.85em;color:#888;text-transform:uppercase;letter-spacing:2px}
.course{font-size:.9em;color:#555;margin:8px 0}
.cover h1{font-size:1.8em;font-weight:800;line-height:1.2;max-width:400px;margin:20px 0}
.cover hr{width:50px;border:none;border-top:2px solid #1a1a1a;margin:16px auto}
.members{margin:20px 0;font-size:.88em;color:#555;line-height:2}
h2{font-size:1.1em;font-weight:700;border-left:4px solid #1a1a1a;padding-left:12px;margin:22px 0 10px}
h3{font-size:.98em;font-weight:700;margin:16px 0 6px}
p{margin-bottom:10px;font-size:.92em}
ul,ol{margin:0 0 10px 18px;font-size:.9em}li{margin-bottom:4px}
.member-table{width:100%;border-collapse:collapse;margin:12px 0;font-size:.88em}
.member-table th{background:#f0f0f0;padding:8px 12px;font-weight:700;border-bottom:1.5px solid #ddd}
.member-table td{padding:8px 12px;border-bottom:1px solid #eee}
</style></head><body>
<div class="page">
<div class="cover">
<div class="univ">Universidade ___________</div>
<div class="course">Curso: ___________ · Disciplina: ___________</div>
<hr>
<h1>Título do Trabalho de Grupo</h1>
<div class="members">
Membro 1 — N.º ___________<br>
Membro 2 — N.º ___________<br>
Membro 3 — N.º ___________<br>
Membro 4 — N.º ___________
</div>
<div style="font-size:.82em;color:#888">Professor(a): ___________ · ___________</div>
</div>
</div>
<div class="page">
<h2>Índice</h2>
<ol>
<li>Introdução ...... 3</li>
<li>Desenvolvimento ...... 4</li>
<li>Conclusão ...... 6</li>
<li>Referências ...... 7</li>
</ol>
<h2>1. Introdução</h2>
<p>O presente trabalho, elaborado no âmbito da disciplina de ___________, tem como objectivo ___________. O tema escolhido justifica-se pela sua relevância em ___________ e pelo seu impacto em ___________.</p>
<h2>2. Desenvolvimento</h2>
<h3>2.1 ___________</h3>
<p>Conteúdo da primeira secção do desenvolvimento. Apresente os conceitos teóricos, dados empíricos e análises relevantes para o tema.</p>
<h3>2.2 ___________</h3>
<p>Conteúdo da segunda secção. Desenvolva a argumentação com base em fontes fidedignas.</p>
<h3>2.3 ___________</h3>
<p>Conteúdo da terceira secção. Analise casos práticos ou exemplos que ilustrem os conceitos.</p>
<h2>3. Conclusão</h2>
<p>Em síntese, o presente trabalho permitiu compreender que ___________. Os principais ensinamentos retirados desta investigação foram ___________.</p>
<h2>4. Contribuição dos Membros</h2>
<table class="member-table">
<tr><th>Membro</th><th>Secções</th><th>Contribuição</th></tr>
<tr><td>Membro 1</td><td>Introdução, 2.1</td><td>___________</td></tr>
<tr><td>Membro 2</td><td>2.2, 2.3</td><td>___________</td></tr>
<tr><td>Membro 3</td><td>Conclusão</td><td>___________</td></tr>
<tr><td>Membro 4</td><td>Formatação, Referências</td><td>___________</td></tr>
</table>
</div>
</body></html>''',
  ),

  // ── Pessoal ───────────────────────────────────────
  _Tpl(
    category: 'Pessoal', title: 'Diário / Reflexão',
    preview: 'Página de diário guiado com humor, gratidão, aprendizagens e intenções.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:22mm 24mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Georgia,'Times New Roman',serif;line-height:1.8;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.day-header{border-bottom:1px solid #ccc;padding-bottom:14px;margin-bottom:22px}
.day-title{font-size:1.8em;font-weight:700;font-style:italic;color:#1a1a1a}
.day-meta{font-size:.85em;color:#888;margin-top:4px}
.mood-row{display:flex;gap:20px;margin:16px 0;padding:12px 16px;background:#f8f8f8;border-radius:6px}
.mood-item{font-size:.85em;color:#555}
.mood-item strong{display:block;font-size:.75em;text-transform:uppercase;letter-spacing:1px;color:#aaa;margin-bottom:2px}
h2{font-size:1em;font-weight:700;color:#1a1a1a;margin:20px 0 10px;font-family:'Segoe UI',sans-serif;text-transform:uppercase;letter-spacing:1.5px;font-size:.72em;color:#888}
p{margin-bottom:10px;font-size:.93em;color:#333}
ul,ol{margin:0 0 10px 18px;font-size:.9em}li{margin-bottom:8px;color:#333;min-height:24px}
.lines{margin:6px 0 16px;padding:12px 0}
.line{border-bottom:1px dashed #ddd;height:32px;margin-bottom:4px}
blockquote{border-left:3px solid #ccc;padding:10px 16px;margin:16px 0;font-style:italic;color:#666;background:#f8f8f8}
</style></head><body>
<div class="page">
<div class="day-header">
<div class="day-title">Entrada do Diário</div>
<div class="day-meta">Data: ___________ &nbsp;·&nbsp; Hora: ___________</div>
</div>
<div class="mood-row">
<div class="mood-item"><strong>Humor</strong>Feliz / Tranquilo / Outro</div>
<div class="mood-item"><strong>Energia</strong>___/5</div>
<div class="mood-item"><strong>Clima</strong>___________</div>
</div>
<h2>O que aconteceu hoje</h2>
<div class="lines">
<div class="line"></div><div class="line"></div><div class="line"></div><div class="line"></div>
</div>
<h2>Como me senti</h2>
<div class="lines">
<div class="line"></div><div class="line"></div><div class="line"></div>
</div>
<h2>O que aprendi hoje</h2>
<ul><li></li><li></li><li></li></ul>
<h2>3 coisas pelas quais sou grato/a</h2>
<ol><li></li><li></li><li></li></ol>
<h2>Para amanhã</h2>
<p>A <strong>única coisa mais importante</strong> que quero fazer amanhã: ___________</p>
<p>Intenção do dia: ___________</p>
<blockquote>Frase / pensamento do dia — escreve aqui algo que queres guardar.</blockquote>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Pessoal', title: 'Plano de Objetivos',
    preview: 'Sistema de metas SMART com curto, médio e longo prazo e hábitos de suporte.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:2em;font-weight:900;letter-spacing:-1px;margin-bottom:4px}
.intro{font-size:.85em;color:#888;margin-bottom:20px;padding-bottom:14px;border-bottom:1px solid #eee}
h2{font-size:1.05em;font-weight:700;margin:20px 0 10px;border-left:4px solid #1a1a1a;padding-left:12px}
h3{font-size:.95em;font-weight:700;margin:14px 0 6px}
p{margin-bottom:8px;font-size:.9em}
ul{margin:0 0 10px 18px;font-size:.9em}li{margin-bottom:4px}
table{width:100%;border-collapse:collapse;margin:12px 0;font-size:.86em}
th{background:#1a1a1a;color:#fff;padding:8px 10px}
td{padding:8px 10px;border-bottom:1px solid #eee}
blockquote{border-left:3px solid #1a1a1a;padding:10px 14px;margin:12px 0;background:#f8f8f8;font-style:italic;font-size:.88em}
.goal-box{border:1px solid #e0e0e0;border-radius:6px;padding:14px;margin-bottom:12px}
.goal-box h3{margin-top:0}
.smart{display:grid;grid-template-columns:repeat(5,1fr);gap:6px;margin:10px 0}
.smart-item{background:#f0f0f0;padding:6px 8px;border-radius:4px;text-align:center;font-size:.72em;font-weight:700}
.smart-item span{display:block;font-size:.9em;font-weight:400;margin-top:2px;color:#666}
</style></head><body>
<div class="page">
<h1>Os Meus Objetivos</h1>
<div class="intro">Definido em: ___________ &nbsp;·&nbsp; Próxima revisão: ___________</div>
<h2>A minha visão de vida (5–10 anos)</h2>
<blockquote>Quem quero ser? Como quero viver? O que quero ter construído? Escreve em presente, como se já fosse realidade.</blockquote>
<h2>Curto Prazo — 1 a 3 meses</h2>
<div class="goal-box">
<h3>Objetivo 1</h3>
<p><strong>O quê:</strong> ___________</p>
<p><strong>Por quê importa:</strong> ___________</p>
<p><strong>Prazo:</strong> ___________ &nbsp;·&nbsp; <strong>Próxima ação:</strong> ___________</p>
<div class="smart">
<div class="smart-item">S<span>Específico</span></div>
<div class="smart-item">M<span>Mensurável</span></div>
<div class="smart-item">A<span>Alcançável</span></div>
<div class="smart-item">R<span>Relevante</span></div>
<div class="smart-item">T<span>Temporal</span></div>
</div>
</div>
<h2>Médio Prazo — 3 a 12 meses</h2>
<ul>
<li><strong>Meta 1:</strong> ___________ — Prazo: ___________</li>
<li><strong>Meta 2:</strong> ___________ — Prazo: ___________</li>
<li><strong>Meta 3:</strong> ___________ — Prazo: ___________</li>
</ul>
<h2>Áreas de vida</h2>
<table>
<tr><th>Área</th><th>Satisfação (0–10)</th><th>Meta em 6 meses</th></tr>
<tr><td>Saúde &amp; Bem-estar</td><td></td><td></td></tr>
<tr><td>Carreira &amp; Finanças</td><td></td><td></td></tr>
<tr><td>Relações</td><td></td><td></td></tr>
<tr><td>Crescimento pessoal</td><td></td><td></td></tr>
<tr><td>Propósito &amp; Impacto</td><td></td><td></td></tr>
</table>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Pessoal', title: 'Orçamento Pessoal',
    preview: 'Controlo de receitas, despesas fixas, variáveis, poupança e metas financeiras.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.8em;font-weight:900;margin-bottom:4px}
.period{font-size:.85em;color:#888;margin-bottom:18px;padding-bottom:14px;border-bottom:1px solid #eee}
h2{font-size:.72em;font-weight:700;text-transform:uppercase;letter-spacing:2px;color:#888;margin:20px 0 10px}
table{width:100%;border-collapse:collapse;margin:0 0 18px;font-size:.88em}
th{background:#1a1a1a;color:#fff;padding:8px 12px;text-align:left;font-weight:600}
td{padding:8px 12px;border-bottom:1px solid #eee}
tr:last-child td{font-weight:700;border-top:1.5px solid #1a1a1a;border-bottom:none}
.positive{color:#16a34a}
.negative{color:#dc2626}
.summary{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin:16px 0}
.sum-box{border:1px solid #e0e0e0;border-radius:6px;padding:14px;text-align:center}
.sum-label{font-size:.7em;text-transform:uppercase;letter-spacing:1px;color:#888;margin-bottom:6px;display:block}
.sum-val{font-size:1.4em;font-weight:800}
p{font-size:.88em;margin-bottom:8px}
</style></head><body>
<div class="page">
<h1>Orçamento Mensal</h1>
<div class="period">Mês: ___________ &nbsp;·&nbsp; Responsável: ___________</div>
<div class="summary">
<div class="sum-box"><span class="sum-label">Receita Total</span><div class="sum-val positive">R$ ___</div></div>
<div class="sum-box"><span class="sum-label">Despesas Totais</span><div class="sum-val negative">R$ ___</div></div>
<div class="sum-box"><span class="sum-label">Saldo</span><div class="sum-val">R$ ___</div></div>
</div>
<h2>Receitas</h2>
<table>
<tr><th>Fonte</th><th>Valor Previsto</th><th>Valor Real</th></tr>
<tr><td>Salário</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Freelance</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Outros</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Total</td><td>R$ ___</td><td>R$ ___</td></tr>
</table>
<h2>Despesas Fixas</h2>
<table>
<tr><th>Categoria</th><th>Previsto</th><th>Real</th><th>Dif.</th></tr>
<tr><td>Habitação / Renda</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Alimentação</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Transporte</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Saúde</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Educação</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
<tr><td>Total</td><td>R$ ___</td><td>R$ ___</td><td>R$ ___</td></tr>
</table>
<h2>Poupança &amp; Metas</h2>
<table>
<tr><th>Meta</th><th>Valor alvo</th><th>Acumulado</th><th>Prazo</th></tr>
<tr><td>Fundo de emergência</td><td>R$ ___</td><td>R$ ___</td><td>___</td></tr>
<tr><td>Viagem / Lazer</td><td>R$ ___</td><td>R$ ___</td><td>___</td></tr>
<tr><td>Investimento</td><td>R$ ___</td><td>R$ ___</td><td>___</td></tr>
</table>
</div>
</body></html>''',
  ),

  // ── Criativo ──────────────────────────────────────
  _Tpl(
    category: 'Criativo', title: 'Conto / Narrativa',
    preview: 'Estrutura narrativa com personagens, cenário, conflito e arcos dramáticos.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:22mm 28mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Georgia,'Times New Roman',serif;line-height:1.85;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.story-cover{display:flex;flex-direction:column;justify-content:center;align-items:flex-start;min-height:200mm}
.genre{font-size:.75em;text-transform:uppercase;letter-spacing:3px;color:#999;margin-bottom:16px;font-family:'Segoe UI',sans-serif}
.story-title{font-size:2.8em;font-weight:700;line-height:1.1;margin-bottom:14px;letter-spacing:-1px}
.story-author{font-size:.95em;color:#666;font-style:italic}
.story-line{width:60px;height:2px;background:#1a1a1a;margin:20px 0}
h2{font-size:.78em;text-transform:uppercase;letter-spacing:2px;color:#aaa;margin:28px 0 14px;font-family:'Segoe UI',sans-serif;font-weight:700}
h3{font-size:1.05em;font-weight:700;font-family:'Segoe UI',sans-serif;margin:18px 0 6px;color:#333}
p{margin-bottom:12px;font-size:.95em;text-align:justify}
.char-block{border-left:3px solid #ccc;padding:10px 16px;margin:10px 0;background:#fafafa}
.char-block strong{display:block;font-size:.85em;font-family:'Segoe UI',sans-serif;margin-bottom:4px}
blockquote{padding:10px 20px;margin:16px 0;border-left:3px solid #999;font-style:italic;color:#555;background:#f8f8f8}
</style></head><body>
<div class="page">
<div class="story-cover">
<div class="genre">Género: ___________ &nbsp;·&nbsp; Tom: ___________</div>
<div class="story-title">Título da História</div>
<div class="story-line"></div>
<div class="story-author">por ___________</div>
</div>
</div>
<div class="page">
<h2>Mundo da História</h2>
<h3>Sinopse</h3>
<p>Em 2–3 frases, descreve o que acontece e o que está em jogo. Captura a essência do conflito central e o tom emocional da narrativa.</p>
<h3>Cenário</h3>
<p>Onde e quando se passa a história? Descreve o ambiente, a época, o clima social e os elementos físicos mais importantes que influenciam a trama.</p>
<h2>Personagens</h2>
<div class="char-block">
<strong>Protagonista — ___________</strong>
<p><strong>Desejo central:</strong> O que quer desesperadamente?<br>
<strong>Medo central:</strong> O que mais teme?<br>
<strong>Arco:</strong> Quem é no início → Quem se torna no final.</p>
</div>
<div class="char-block">
<strong>Antagonista — ___________</strong>
<p><strong>Motivação:</strong> Por que faz o que faz?<br>
<strong>Relação com protagonista:</strong> ___________</p>
</div>
<h2>Estrutura Narrativa</h2>
<h3>Acto I — Gancho &amp; Situação Inicial</h3>
<p>Apresenta o protagonista no seu mundo normal. Define o tom. O evento perturbador que quebra o equilíbrio.</p>
<blockquote>Cena de abertura — a primeira linha que vai prender o leitor: "___________"</blockquote>
<h3>Acto II — Conflito &amp; Ponto de Virada</h3>
<p>Obstáculos crescentes. Alianças e traições. A crise máxima que parece insuperável.</p>
<h3>Acto III — Clímax &amp; Resolução</h3>
<p>Como o protagonista resolve o conflito? O que muda nele/a? Que preço pagou?</p>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Criativo', title: 'Roteiro de Vídeo',
    preview: 'Script com gancho, cenas, diálogos, chamada à ação e notas de produção.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Courier New',Courier,monospace;line-height:1.7;color:#1a1a1a;background:#fff;font-size:13px}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.script-header{border:2px solid #1a1a1a;padding:16px 20px;margin-bottom:20px}
.script-title{font-size:1.5em;font-weight:700;text-align:center;text-transform:uppercase;letter-spacing:2px}
.script-meta{text-align:center;margin-top:8px;font-size:.85em;color:#555}
.scene{margin:16px 0}
.scene-heading{background:#1a1a1a;color:#fff;padding:5px 10px;font-weight:700;font-size:.85em;text-transform:uppercase;letter-spacing:1px}
.action{margin:10px 0;font-size:.9em;color:#333;padding:0 10px}
.character{text-align:center;font-weight:700;text-transform:uppercase;margin:12px 0 2px;font-size:.88em}
.dialogue{margin:0 60px 10px;font-size:.88em}
.parenthetical{text-align:center;font-style:italic;margin:2px 80px;font-size:.82em;color:#666}
.note{background:#fffbcc;border:1px solid #e0d800;padding:10px 14px;margin:10px 0;font-size:.82em}
h2{margin:18px 0 8px;text-transform:uppercase;font-size:.85em;letter-spacing:2px;border-bottom:1px solid #ccc;padding-bottom:4px}
</style></head><body>
<div class="page">
<div class="script-header">
<div class="script-title">Título do Vídeo / Episódio</div>
<div class="script-meta">Duração: ___ &nbsp;·&nbsp; Plataforma: ___________ &nbsp;·&nbsp; Formato: ___________<br>
Audiência: ___________ &nbsp;·&nbsp; Objetivo: ___________</div>
</div>

<div class="scene">
<div class="scene-heading">CENA 1 — GANCHO (0:00–0:30)</div>
<div class="action">[CÂMERA: Close-up no apresentador. Música de fundo começa.]</div>
<div class="character">APRESENTADOR</div>
<div class="parenthetical">(olhando directo para a câmera, sério)</div>
<div class="dialogue">"Pergunta provocadora ou afirmação surpreendente que prende o espectador nos primeiros segundos..."</div>
<div class="action">[CORTE para imagens de suporte — B-roll]</div>
</div>

<div class="scene">
<div class="scene-heading">CENA 2 — INTRODUÇÃO (0:30–1:30)</div>
<div class="character">APRESENTADOR</div>
<div class="dialogue">"Hoje vamos falar sobre ___________. No final, vais saber exactamente como ___________."</div>
</div>

<div class="scene">
<div class="scene-heading">CENA 3 — PONTO 1</div>
<div class="character">APRESENTADOR</div>
<div class="dialogue">"Ponto 1: ___________. O que isto significa é que ___________."</div>
<div class="action">[GRÁFICO na tela — estatística ou visualização]</div>
</div>

<div class="scene">
<div class="scene-heading">CENA 4 — PONTO 2</div>
<div class="character">APRESENTADOR</div>
<div class="dialogue">"Ponto 2: ___________."</div>
</div>

<div class="scene">
<div class="scene-heading">CENA 5 — ENCERRAMENTO E CTA</div>
<div class="character">APRESENTADOR</div>
<div class="dialogue">"Em resumo, vimos que ___________. Se este conteúdo foi útil, deixa um like e subscreve para mais."</div>
<div class="action">[CALL TO ACTION na tela]</div>
</div>

<h2>Notas de Produção</h2>
<div class="note">
📌 Thumbnail: ___________<br>
📌 Título SEO: ___________<br>
📌 Descrição: ___________<br>
📌 Tags: ___________<br>
📌 Duração estimada: ___ minutos
</div>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Criativo', title: 'Storyboard',
    preview: 'Guião visual com quadros de cena, ação, diálogo e notas de câmera.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4 landscape;margin:14mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.5;color:#1a1a1a;background:#fff}
.page{page-break-after:always}
.page:last-child{page-break-after:auto}
.sb-header{display:flex;justify-content:space-between;align-items:center;border-bottom:2px solid #1a1a1a;padding-bottom:8px;margin-bottom:14px}
.sb-title{font-size:1.1em;font-weight:800}
.sb-meta{font-size:.75em;color:#888}
.sb-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}
.frame{border:1px solid #ccc;border-radius:4px;overflow:hidden}
.frame-number{background:#1a1a1a;color:#fff;padding:3px 8px;font-size:.7em;font-weight:700}
.frame-visual{height:90px;background:#f5f5f5;border-bottom:1px solid #e0e0e0;display:flex;align-items:center;justify-content:center;color:#bbb;font-size:.8em}
.frame-body{padding:8px}
.frame-label{font-size:.68em;text-transform:uppercase;letter-spacing:1px;color:#aaa;margin-bottom:2px;margin-top:6px;font-weight:700}
.frame-label:first-child{margin-top:0}
.frame-text{font-size:.75em;color:#333;min-height:16px}
</style></head><body>
<div class="page">
<div class="sb-header">
<div>
<div class="sb-title">Storyboard — ___________</div>
<div class="sb-meta">Projecto: ___________ &nbsp;·&nbsp; Data: ___________ &nbsp;·&nbsp; Director: ___________</div>
</div>
<div class="sb-meta">Página 1 / ___</div>
</div>
<div class="sb-grid">
${List.generate(6, (i) => '''
<div class="frame">
<div class="frame-number">Cena ${i + 1}</div>
<div class="frame-visual">[Esboço visual]</div>
<div class="frame-body">
<div class="frame-label">Câmera</div><div class="frame-text">___________</div>
<div class="frame-label">Acção</div><div class="frame-text">___________</div>
<div class="frame-label">Diálogo / SFX</div><div class="frame-text">___________</div>
<div class="frame-label">Duração</div><div class="frame-text">___ seg</div>
</div>
</div>''').join('\n')}
</div>
</div>
</body></html>''',
  ),

  // ── Projeto & Planeamento ─────────────────────────
  _Tpl(
    category: 'Projeto', title: 'Plano de Projeto',
    preview: 'Documento de arranque com objetivos, entregas, cronograma e responsáveis.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.proj-header{border-bottom:3px solid #1a1a1a;padding-bottom:14px;margin-bottom:20px}
.proj-header h1{font-size:1.8em;font-weight:900}
.proj-header .meta{font-size:.82em;color:#888;margin-top:4px}
.info-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin:16px 0}
.info-box{background:#f5f5f5;padding:12px;border-radius:5px}
.info-box .label{font-size:.68em;text-transform:uppercase;letter-spacing:1px;color:#888;font-weight:700;margin-bottom:3px}
.info-box .val{font-size:.9em;font-weight:600}
h2{font-size:.75em;font-weight:700;text-transform:uppercase;letter-spacing:2px;color:#888;margin:20px 0 10px}
p{margin-bottom:8px;font-size:.9em}
ul,ol{margin:0 0 10px 18px;font-size:.9em}li{margin-bottom:4px}
table{width:100%;border-collapse:collapse;margin:10px 0;font-size:.86em}
th{background:#1a1a1a;color:#fff;padding:7px 10px;text-align:left;font-weight:600}
td{padding:7px 10px;border-bottom:1px solid #eee}
.status-chip{display:inline-block;padding:2px 8px;border-radius:3px;font-size:.72em;font-weight:700}
.s-todo{background:#f0f0f0;color:#666}
.s-prog{background:#dbeafe;color:#1d4ed8}
.s-done{background:#d1fae5;color:#065f46}
.s-late{background:#fee2e2;color:#991b1b}
.gantt{margin:10px 0}
.gantt-row{display:flex;align-items:center;margin-bottom:6px;font-size:.82em}
.gantt-label{width:140px;flex-shrink:0;color:#555;font-weight:500}
.gantt-bar-wrap{flex:1;background:#f0f0f0;height:16px;border-radius:3px;overflow:hidden}
.gantt-bar{height:100%;background:#1a1a1a;border-radius:3px}
</style></head><body>
<div class="page">
<div class="proj-header">
<h1>Nome do Projeto</h1>
<div class="meta">Versão 1.0 &nbsp;·&nbsp; Gestor: ___________ &nbsp;·&nbsp; Criado em: ___________</div>
</div>
<div class="info-grid">
<div class="info-box"><div class="label">Data de Início</div><div class="val">___________</div></div>
<div class="info-box"><div class="label">Data de Fim</div><div class="val">___________</div></div>
<div class="info-box"><div class="label">Orçamento</div><div class="val">R$ ___________</div></div>
</div>
<h2>Objetivo do Projeto</h2>
<p>Descrição clara e mensurável do que este projeto pretende alcançar, com critérios de sucesso bem definidos.</p>
<h2>Âmbito e Entregas</h2>
<ul>
<li><strong>Entrega 1:</strong> ___________ — Prazo: ___________</li>
<li><strong>Entrega 2:</strong> ___________ — Prazo: ___________</li>
<li><strong>Entrega 3:</strong> ___________ — Prazo: ___________</li>
</ul>
<h2>Equipa e Responsabilidades</h2>
<table>
<tr><th>Membro</th><th>Função</th><th>Responsabilidades</th></tr>
<tr><td>___________</td><td>Gestor</td><td>Coordenação geral, comunicação</td></tr>
<tr><td>___________</td><td>Técnico</td><td>___________</td></tr>
<tr><td>___________</td><td>Designer</td><td>___________</td></tr>
</table>
<h2>Cronograma de Tarefas</h2>
<table>
<tr><th>Tarefa</th><th>Responsável</th><th>Início</th><th>Fim</th><th>Estado</th></tr>
<tr><td>Tarefa 1</td><td>___</td><td>___</td><td>___</td><td><span class="status-chip s-todo">Por fazer</span></td></tr>
<tr><td>Tarefa 2</td><td>___</td><td>___</td><td>___</td><td><span class="status-chip s-prog">Em curso</span></td></tr>
<tr><td>Tarefa 3</td><td>___</td><td>___</td><td>___</td><td><span class="status-chip s-done">Concluído</span></td></tr>
</table>
<h2>Riscos Identificados</h2>
<table>
<tr><th>Risco</th><th>Probabilidade</th><th>Impacto</th><th>Mitigação</th></tr>
<tr><td>___________</td><td>Média</td><td>Alto</td><td>___________</td></tr>
<tr><td>___________</td><td>Baixa</td><td>Médio</td><td>___________</td></tr>
</table>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Projeto', title: 'Briefing Criativo',
    preview: 'Briefing para projetos criativos com público, mensagem, tom e referências.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.8em;font-weight:900;margin-bottom:4px}
.subtitle{font-size:.85em;color:#888;margin-bottom:20px;padding-bottom:12px;border-bottom:1px solid #eee}
.section{margin-bottom:22px}
.section-label{font-size:.68em;text-transform:uppercase;letter-spacing:2px;color:#aaa;font-weight:700;margin-bottom:8px}
.section-content{background:#f8f8f8;border-radius:6px;padding:14px;font-size:.9em;min-height:40px;border-left:3px solid #1a1a1a}
.two-col{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.tone-tags{display:flex;flex-wrap:wrap;gap:6px;margin-top:8px}
.tone-tag{border:1.5px solid #1a1a1a;padding:4px 12px;border-radius:4px;font-size:.75em;font-weight:700}
.persona-box{border:1px solid #e0e0e0;border-radius:6px;padding:14px;background:#fff}
.persona-box h3{font-size:.82em;font-weight:700;margin-bottom:8px;text-transform:uppercase;letter-spacing:1px}
.persona-item{font-size:.82em;color:#555;margin-bottom:4px}
</style></head><body>
<div class="page">
<h1>Briefing Criativo</h1>
<div class="subtitle">Projecto: ___________ &nbsp;·&nbsp; Cliente: ___________ &nbsp;·&nbsp; Data: ___________ &nbsp;·&nbsp; Gestor: ___________</div>

<div class="section">
<div class="section-label">Objectivo do Projecto</div>
<div class="section-content">O que pretendemos alcançar com este projecto? Qual o resultado mensurável esperado?</div>
</div>

<div class="section">
<div class="section-label">Mensagem Central</div>
<div class="section-content">Em uma frase: qual a ideia mais importante que o público deve guardar?</div>
</div>

<div class="section">
<div class="section-label">Público-Alvo</div>
<div class="two-col">
<div class="persona-box">
<h3>Persona Principal</h3>
<div class="persona-item">👤 ___________, ___ anos</div>
<div class="persona-item">💼 ___________</div>
<div class="persona-item">🎯 Objetivo: ___________</div>
<div class="persona-item">😟 Dor: ___________</div>
</div>
<div class="persona-box">
<h3>Persona Secundária</h3>
<div class="persona-item">👤 ___________, ___ anos</div>
<div class="persona-item">💼 ___________</div>
<div class="persona-item">🎯 Objetivo: ___________</div>
</div>
</div>
</div>

<div class="section">
<div class="section-label">Tom e Personalidade</div>
<div class="section-content">Selecciona os adjectivos que descrevem o tom da comunicação:
<div class="tone-tags">
<span class="tone-tag">Profissional</span>
<span class="tone-tag">Descontraído</span>
<span class="tone-tag">Inovador</span>
<span class="tone-tag">Confiável</span>
<span class="tone-tag">Empático</span>
</div>
</div>
</div>

<div class="section">
<div class="section-label">Entregas Esperadas</div>
<div class="section-content">Liste os formatos, dimensões e quantidades de cada entrega prevista.</div>
</div>

<div class="section">
<div class="section-label">Referências e Inspirações</div>
<div class="section-content">Links, exemplos, marcas ou estilos visuais de referência para este projecto.</div>
</div>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Projeto', title: 'Post-Mortem de Projeto',
    preview: 'Análise pós-projeto com o que correu bem, o que falhou e lições aprendidas.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:20mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;line-height:1.65;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.7em;font-weight:900;margin-bottom:4px}
.meta{font-size:.82em;color:#888;padding-bottom:14px;border-bottom:1px solid #eee;margin-bottom:18px}
h2{font-size:.72em;font-weight:700;text-transform:uppercase;letter-spacing:2px;color:#888;margin:22px 0 10px}
.summary-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin:14px 0}
.s-box{background:#f5f5f5;border-radius:5px;padding:12px;text-align:center}
.s-box .label{font-size:.68em;text-transform:uppercase;letter-spacing:1px;color:#aaa;margin-bottom:4px}
.s-box .val{font-size:1.2em;font-weight:800}
.well-box{background:#d1fae5;border-radius:6px;padding:14px;margin-bottom:10px}
.ill-box{background:#fee2e2;border-radius:6px;padding:14px;margin-bottom:10px}
.box-title{font-size:.78em;font-weight:700;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px}
.well-box .box-title{color:#065f46}
.ill-box .box-title{color:#991b1b}
ul{margin:0 0 0 16px;font-size:.88em}li{margin-bottom:4px}
table{width:100%;border-collapse:collapse;margin:10px 0;font-size:.86em}
th{background:#1a1a1a;color:#fff;padding:7px 10px;text-align:left}
td{padding:7px 10px;border-bottom:1px solid #eee}
.lesson{background:#f8f8f8;border-left:4px solid #1a1a1a;padding:10px 14px;margin:8px 0;font-size:.88em}
</style></head><body>
<div class="page">
<h1>Post-Mortem — ___________</h1>
<div class="meta">Data de conclusão: ___________ &nbsp;·&nbsp; Facilitador: ___________ &nbsp;·&nbsp; Participantes: ___________</div>
<div class="summary-grid">
<div class="s-box"><div class="label">Prazo</div><div class="val">✓ / ✗</div></div>
<div class="s-box"><div class="label">Orçamento</div><div class="val">✓ / ✗</div></div>
<div class="s-box"><div class="label">Qualidade</div><div class="val">___/5</div></div>
<div class="s-box"><div class="label">Satisfação</div><div class="val">___/5</div></div>
</div>
<h2>O Que Correu Bem</h2>
<div class="well-box">
<div class="box-title">✓ Pontos Positivos</div>
<ul>
<li>___________</li>
<li>___________</li>
<li>___________</li>
</ul>
</div>
<h2>O Que Falhou</h2>
<div class="ill-box">
<div class="box-title">✗ Problemas Encontrados</div>
<ul>
<li>___________</li>
<li>___________</li>
<li>___________</li>
</ul>
</div>
<h2>Lições Aprendidas</h2>
<div class="lesson">💡 Lição 1: ___________</div>
<div class="lesson">💡 Lição 2: ___________</div>
<div class="lesson">💡 Lição 3: ___________</div>
<h2>Próximas Acções (Para o Próximo Projeto)</h2>
<table>
<tr><th>Acção</th><th>Responsável</th><th>Prazo</th></tr>
<tr><td>___________</td><td>___________</td><td>___________</td></tr>
<tr><td>___________</td><td>___________</td><td>___________</td></tr>
</table>
</div>
</body></html>''',
  ),

  // ── Legal & Formal ────────────────────────────────
  _Tpl(
    category: 'Legal & Formal', title: 'Contrato Simples',
    preview: 'Contrato de prestação de serviços com cláusulas essenciais e assinaturas.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:25mm 22mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Georgia,'Times New Roman',serif;line-height:1.8;color:#1a1a1a;background:#fff;font-size:13px}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
h1{font-size:1.4em;font-weight:700;text-align:center;text-transform:uppercase;letter-spacing:2px;margin-bottom:20px;padding-bottom:12px;border-bottom:1px solid #ccc}
h2{font-size:1em;font-weight:700;margin:18px 0 8px;text-transform:uppercase;letter-spacing:1px}
p{margin-bottom:10px;font-size:.9em;text-align:justify}
.parties{background:#f8f8f8;border:1px solid #e0e0e0;padding:16px;margin:16px 0}
.party{margin-bottom:10px;font-size:.88em}
.party strong{display:block;font-size:.75em;text-transform:uppercase;letter-spacing:1px;color:#888;margin-bottom:2px}
ol{margin:0 0 10px 20px}li{margin-bottom:6px;font-size:.88em}
.clause{margin-bottom:14px}
.clause h3{font-size:.9em;font-weight:700;margin-bottom:6px}
.signatures{display:grid;grid-template-columns:1fr 1fr;gap:30px;margin-top:40px}
.sig-block{text-align:center}
.sig-line{border-bottom:1px solid #1a1a1a;height:50px;margin-bottom:8px}
.sig-label{font-size:.78em;color:#666}
</style></head><body>
<div class="page">
<h1>Contrato de Prestação de Serviços</h1>
<div class="parties">
<div class="party"><strong>Prestador</strong>Nome: ___________ &nbsp;·&nbsp; NIF: ___________ &nbsp;·&nbsp; Morada: ___________</div>
<div class="party"><strong>Cliente</strong>Nome: ___________ &nbsp;·&nbsp; NIF: ___________ &nbsp;·&nbsp; Morada: ___________</div>
</div>
<p>As partes acima identificadas celebram o presente contrato, que se rege pelas seguintes cláusulas:</p>
<div class="clause">
<h3>Cláusula 1.ª — Objecto</h3>
<p>O Prestador compromete-se a prestar ao Cliente os seguintes serviços: ___________.</p>
</div>
<div class="clause">
<h3>Cláusula 2.ª — Prazo</h3>
<p>O contrato terá início em ___________ e término em ___________, podendo ser renovado por acordo escrito entre as partes.</p>
</div>
<div class="clause">
<h3>Cláusula 3.ª — Remuneração</h3>
<p>O Cliente pagará ao Prestador o valor de R$ ___________ (___________ reais), nas seguintes condições de pagamento: ___________.</p>
</div>
<div class="clause">
<h3>Cláusula 4.ª — Obrigações do Prestador</h3>
<ol>
<li>Executar os serviços com diligência e qualidade.</li>
<li>Guardar confidencialidade sobre as informações do Cliente.</li>
<li>Cumprir os prazos acordados.</li>
</ol>
</div>
<div class="clause">
<h3>Cláusula 5.ª — Resolução de Conflitos</h3>
<p>Em caso de conflito, as partes acordam em recorrer à mediação antes de qualquer acção judicial, elegendo o foro da comarca de ___________ para dirimir eventuais litígios.</p>
</div>
<p>Feito em dois exemplares, em ___________, aos ___ de ___________ de ___________.</p>
<div class="signatures">
<div class="sig-block"><div class="sig-line"></div><div class="sig-label">O Prestador<br>___________</div></div>
<div class="sig-block"><div class="sig-line"></div><div class="sig-label">O Cliente<br>___________</div></div>
</div>
</div>
</body></html>''',
  ),

  _Tpl(
    category: 'Legal & Formal', title: 'Declaração Oficial',
    preview: 'Declaração formal para fins institucionais, académicos ou profissionais.',
    html: '''<!DOCTYPE html><html lang="pt"><head><meta charset="UTF-8">
<style>
@page{size:A4;margin:25mm 28mm}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Georgia,'Times New Roman',serif;line-height:1.9;color:#1a1a1a;background:#fff}
.page{min-height:257mm;page-break-after:always}
.page:last-child{page-break-after:auto}
.letterhead{text-align:center;border-bottom:2px solid #1a1a1a;padding-bottom:16px;margin-bottom:30px}
.letterhead h1{font-size:1.3em;font-weight:700;text-transform:uppercase;letter-spacing:2px}
.letterhead p{font-size:.82em;color:#666;margin-top:4px}
.doc-title{text-align:center;font-size:1.1em;font-weight:700;text-transform:uppercase;letter-spacing:2px;margin:20px 0 24px;padding:10px;border:1px solid #ccc}
p{margin-bottom:14px;font-size:.92em;text-align:justify}
.body-text{padding:0 10px}
.date-place{margin:30px 0 10px;font-size:.88em;color:#555}
.sig-block{margin-top:50px;text-align:center}
.sig-line{border-bottom:1px solid #1a1a1a;width:280px;margin:0 auto 8px}
.sig-info{font-size:.82em;color:#555}
.stamp{border:2px solid #ccc;width:120px;height:80px;margin:0 auto;display:flex;align-items:center;justify-content:center;font-size:.65em;color:#bbb;text-transform:uppercase;letter-spacing:1px;margin-top:20px}
</style></head><body>
<div class="page">
<div class="letterhead">
<h1>Nome da Instituição / Empresa</h1>
<p>Endereço completo &nbsp;·&nbsp; Tel: ___________ &nbsp;·&nbsp; Email: ___________</p>
</div>
<div class="doc-title">Declaração</div>
<div class="body-text">
<p>___________ (nome do declarante), portador(a) do BI/Passaporte n.º ___________, residente em ___________, na qualidade de ___________ da ___________, declara para os devidos efeitos legais que:</p>
<p>___________ (nome da pessoa sobre quem se declara) é/foi ___________ desta instituição, desde ___________ até ___________, tendo cumprido as suas funções com ___________.</p>
<p>Mais se declara que ___________, conforme consta nos nossos registos internos.</p>
<p>A presente declaração é passada a pedido do(a) interessado(a), para os fins que este(a) entender convenientes.</p>
</div>
<div class="date-place">___________ (local), aos ___ de ___________ de ___________.</div>
<div class="sig-block">
<div class="sig-line"></div>
<div class="sig-info">Nome completo do declarante<br>Cargo &nbsp;·&nbsp; ___________</div>
</div>
<div class="stamp">Carimbo</div>
</div>
</body></html>''',
  ),
];

// ═══════════════════════════════════════════════════════
// SVGs
// ═══════════════════════════════════════════════════════
const _searchSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ═══════════════════════════════════════════════════════
// SCREEN — sem AppBar própria (o app já tem a sua)
// ═══════════════════════════════════════════════════════
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});
  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _filter = '';
  String? _cat;

  @override
  void initState() { super.initState(); themeNotifier.addListener(_onTheme); }
  @override
  void dispose()   { themeNotifier.removeListener(_onTheme); super.dispose(); }
  void _onTheme()  => setState(() {});

  List<_Tpl> get _filtered {
    var list = _kTemplates.toList();
    if (_cat != null) list = list.where((t) => t.category == _cat).toList();
    if (_filter.isNotEmpty) {
      final q = _filter.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          t.preview.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<String> get _categories =>
      _kTemplates.map((t) => t.category).toSet().toList();

  void _openEditor(_Tpl tpl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(
      docType: DocType.document,
      importHtml: tpl.html,
      importTitle: tpl.title,
    )));
  }

  void _showPreview(_Tpl tpl) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final tp   = isDark ? Colors.white : Colors.black;
    final ts   = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div  = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc  = accColor(isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.97,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal)),
          ),
          child: Column(children: [
            // Handle
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Center(child: Container(width: 36, height: 3.5,
                  decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
            // Header
            Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tpl.title, style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: tp.withOpacity(.08), borderRadius: BorderRadius.circular(_kChip)),
                    child: Text(tpl.category, style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ])),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () { Navigator.pop(context); _openEditor(tpl); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                    child: Text('Usar', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ])),
            const SizedBox(height: 10),
            Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(tpl.preview, style: GoogleFonts.roboto(color: ts, fontSize: 13, height: 1.5))),
            Container(height: 0.5, color: div),
            // Preview das páginas HTML — indicador visual
            Expanded(child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .4 : .12), blurRadius: 12, offset: const Offset(0, 3))],
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                  child: _DocPreview(html: tpl.html, tp: tp, ts: ts, div: div, acc: acc, isDark: isDark),
                ),
              ],
            )),
            // Bottom action
            Container(
              color: bg,
              padding: EdgeInsets.fromLTRB(18, 10, 18, MediaQuery.of(context).padding.bottom + 12),
              child: GestureDetector(
                onTap: () { Navigator.pop(context); _openEditor(tpl); },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                  child: Text('Usar este template', textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? AppColors.darkBackground   : AppColors.background;
    final tp   = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div  = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc  = accColor(isDark);
    final pill = isDark ? const Color(0xFF363636)     : const Color(0xFFF2F2F7);

    final filtered = _filtered;

    // Sem AppBar — apenas body
    return Column(children: [
      // ── Search ──────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          height: 42,
          decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(_kPill)),
          child: Row(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _svgW(_searchSvg, ts, s: 15)),
            Expanded(child: TextField(
              onChanged: (v) => setState(() => _filter = v),
              style: GoogleFonts.roboto(color: tp, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Pesquisar templates…',
                hintStyle: GoogleFonts.roboto(color: ts, fontSize: 14),
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                isDense: true, contentPadding: EdgeInsets.zero,
              ),
            )),
          ]),
        ),
      ),

      // ── Category chips ───────────────────────────────
      SizedBox(height: 44,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          scrollDirection: Axis.horizontal,
          children: [
            _CatChip(label: 'Todos', selected: _cat == null, acc: acc, tp: tp, ts: ts,
                onTap: () => setState(() => _cat = null)),
            ..._categories.map((c) => _CatChip(
                label: c, selected: _cat == c, acc: acc, tp: tp, ts: ts,
                onTap: () => setState(() => _cat = _cat == c ? null : c))),
          ],
        ),
      ),
      Container(height: 0.5, color: div, margin: const EdgeInsets.only(top: 6)),

      // ── Grid ────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
          ? Center(child: Text('Sem resultados', style: GoogleFonts.roboto(color: ts, fontSize: 14)))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.65,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _TplCard(
                tpl: filtered[i], isDark: isDark, tp: tp, ts: ts, acc: acc,
                onTap: () => _showPreview(filtered[i]),
              ),
            ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// CATEGORY CHIP
// ═══════════════════════════════════════════════════════
class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color acc, tp, ts;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.selected, required this.acc, required this.tp, required this.ts, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? acc : Colors.transparent,
        borderRadius: BorderRadius.circular(_kPill),
        border: Border.all(color: selected ? acc : ts.withOpacity(.3)),
      ),
      child: Text(label, style: GoogleFonts.roboto(
          color: selected ? Colors.white : ts,
          fontSize: 12, fontWeight: FontWeight.w700)),
    ),
  );
}

// ═══════════════════════════════════════════════════════
// TEMPLATE CARD
// ═══════════════════════════════════════════════════════
class _TplCard extends StatelessWidget {
  final _Tpl tpl;
  final bool isDark;
  final Color tp, ts, acc;
  final VoidCallback onTap;
  const _TplCard({required this.tpl, required this.isDark, required this.tp, required this.ts, required this.acc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardBg    = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final previewBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final divC      = isDark ? AppColors.darkDivider : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(_kCard),
          border: Border.all(color: divC.withOpacity(.6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .3 : .07), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(_kCard), topRight: Radius.circular(_kCard)),
              child: Container(
                color: previewBg,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                child: OverflowBox(
                  maxHeight: double.infinity,
                  alignment: Alignment.topCenter,
                  child: Transform.scale(
                    scale: 0.42,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 400,
                      child: _DocPreview(html: tpl.html, tp: tp, ts: ts, div: divC, acc: acc, isDark: isDark, compact: true),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: divC.withOpacity(.5), width: 0.5))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tpl.title, style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w700, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(tpl.category, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DOC PREVIEW — renders HTML as Flutter widgets for card preview
// ═══════════════════════════════════════════════════════
class _DocPreview extends StatelessWidget {
  final String html;
  final Color tp, ts, div, acc;
  final bool isDark, compact;
  const _DocPreview({
    required this.html, required this.tp, required this.ts,
    required this.div, required this.acc, required this.isDark,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = _parseHtml(html);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: nodes.map((n) => _buildNode(n)).toList(),
    );
  }

  Widget _buildNode(_HtmlNode n) {
    final double h1  = compact ? 16 : 22;
    final double h2  = compact ? 13 : 17;
    final double h3  = compact ? 11 : 14;
    final double body= compact ? 10 : 13;
    final double li  = compact ? 9.5: 12.5;

    switch (n.tag) {
      case 'h1':
        return Padding(padding: EdgeInsets.only(bottom: compact ? 6 : 10),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h1, fontWeight: FontWeight.w800, height: 1.2)));
      case 'h2':
        return Padding(padding: EdgeInsets.only(top: compact ? 6 : 10, bottom: compact ? 3 : 5),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h2, fontWeight: FontWeight.w700)));
      case 'h3':
        return Padding(padding: EdgeInsets.only(top: compact ? 4 : 7, bottom: compact ? 2 : 4),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h3, fontWeight: FontWeight.w700)));
      case 'p':
        if (n.text.isEmpty) return SizedBox(height: compact ? 3 : 6);
        return Padding(padding: EdgeInsets.only(bottom: compact ? 3 : 6),
          child: Text(n.text, style: GoogleFonts.roboto(color: ts, fontSize: body, height: 1.5),
              maxLines: compact ? 2 : 100, overflow: TextOverflow.ellipsis));
      case 'blockquote':
        return Container(
          margin: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 4 : 7),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: acc, width: 2.5)),
            color: acc.withOpacity(.06),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
          ),
          child: Text(n.text, style: GoogleFonts.roboto(color: ts, fontSize: compact ? 9 : 12, fontStyle: FontStyle.italic),
              maxLines: 2, overflow: TextOverflow.ellipsis));
      case 'ul':
      case 'ol':
        return Padding(padding: EdgeInsets.only(bottom: compact ? 3 : 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: n.items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: compact ? 14 : 18,
                  child: Text(n.tag == 'ol' ? '${e.key + 1}.' : '•',
                    style: GoogleFonts.roboto(color: acc, fontSize: li, fontWeight: FontWeight.w700))),
                Expanded(child: Text(e.value, style: GoogleFonts.roboto(color: ts, fontSize: li),
                    maxLines: compact ? 1 : 3, overflow: TextOverflow.ellipsis)),
              ]),
            )).toList()));
      case 'table':
        return _buildTable(n, compact);
      case 'hr':
        return Container(height: 0.5, color: div, margin: EdgeInsets.symmetric(vertical: compact ? 6 : 10));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTable(_HtmlNode n, bool compact) {
    if (n.rows.isEmpty) return const SizedBox.shrink();
    final fontSize = compact ? 8.5 : 11.5;
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 5 : 10),
      decoration: BoxDecoration(border: Border.all(color: div), borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: div, width: 0.5),
            verticalInside: BorderSide(color: div, width: 0.5),
          ),
          defaultColumnWidth: const FlexColumnWidth(),
          children: n.rows.asMap().entries.map((rowEntry) {
            final isHeader = rowEntry.key == 0;
            return TableRow(
              decoration: BoxDecoration(
                color: isHeader ? acc.withOpacity(.1) : (rowEntry.key.isOdd ? tp.withOpacity(.02) : null),
              ),
              children: rowEntry.value.map((cell) => Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8, vertical: compact ? 3 : 6),
                child: Text(cell, style: GoogleFonts.roboto(
                    color: isHeader ? tp : ts, fontSize: fontSize,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              )).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<_HtmlNode> _parseHtml(String raw) {
    final result = <_HtmlNode>[];
    String clean(String s) => s
        .replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ').replaceAll(RegExp(r'<[^>]+>'), '').trim();

    final tagRe = RegExp(
        r'<(h[123]|p|blockquote|ul|ol|table|hr|li|tr|th|td|thead|tbody)[^>]*>([\s\S]*?)<\/\1>|<hr\s*/?>',
        caseSensitive: false);

    for (final m in tagRe.allMatches(raw)) {
      final tag  = (m.group(1) ?? 'hr').toLowerCase();
      final body = m.group(2) ?? '';
      if (tag == 'hr') { result.add(_HtmlNode('hr', '')); continue; }
      if (tag == 'ul' || tag == 'ol') {
        final items = RegExp(r'<li[^>]*>([\s\S]*?)<\/li>', caseSensitive: false)
            .allMatches(body).map((li) => clean(li.group(1) ?? '')).where((s) => s.isNotEmpty).toList();
        if (items.isNotEmpty) result.add(_HtmlNode(tag, '', items: items));
        continue;
      }
      if (tag == 'table') {
        final rows = <List<String>>[];
        for (final row in RegExp(r'<tr[^>]*>([\s\S]*?)<\/tr>', caseSensitive: false).allMatches(body)) {
          final cells = RegExp(r'<t[hd][^>]*>([\s\S]*?)<\/t[hd]>', caseSensitive: false)
              .allMatches(row.group(1) ?? '').map((c) => clean(c.group(1) ?? '')).toList();
          if (cells.isNotEmpty) rows.add(cells);
        }
        if (rows.isNotEmpty) { final n = _HtmlNode('table', ''); n.rows = rows; result.add(n); }
        continue;
      }
      final text = clean(body);
      if (text.isNotEmpty || tag == 'p') result.add(_HtmlNode(tag, text));
    }
    return result;
  }
}

class _HtmlNode {
  final String tag, text;
  final List<String> items;
  List<List<String>> rows;
  _HtmlNode(this.tag, this.text, {this.items = const [], List<List<String>>? rows})
      : rows = rows ?? [];
}
