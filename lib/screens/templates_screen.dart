import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import '../models/document.dart';

// ── Design tokens ─────────────────────────────────────
const _kPill  = 999.0;
const _kCard  = 10.0;  // template card radius
const _kModal = 10.0;  // modal top radius (50% less than before)
const _kChip  = 6.0;

// ── Template model ────────────────────────────────────
class _Tpl {
  final String category, title, preview, html;
  const _Tpl({required this.category, required this.title, required this.preview, required this.html});
}

// ═══════════════════════════════════════════════════════
// TEMPLATES
// ═══════════════════════════════════════════════════════
const _kTemplates = <_Tpl>[

  // ── Negócios ──────────────────────────────────────
  _Tpl(
    category: 'Negócios', title: 'Relatório Executivo',
    preview: 'Relatório trimestral com KPIs, resultados e recomendações estratégicas.',
    html: '<h1>Relatório Executivo</h1>\n<p><strong>Período:</strong> Q1 2025 &nbsp;&nbsp; <strong>Elaborado por:</strong> ___________</p>\n<hr/>\n<h2>Resumo Executivo</h2>\n<p>Este relatório apresenta os principais indicadores de desempenho do período, consolidando resultados financeiros, operacionais e estratégicos para apoiar a tomada de decisão.</p>\n<blockquote><strong>Insight chave:</strong> Crescimento de 12% na receita em relação ao trimestre anterior, impulsionado pela expansão do portfólio de serviços.</blockquote>\n<h2>1. Resultados Financeiros</h2>\n<ul>\n<li><strong>Receita total:</strong> R\$ ___________</li>\n<li><strong>Lucro bruto:</strong> R\$ ___________</li>\n<li><strong>Margem líquida:</strong> ___%</li>\n<li><strong>Custo operacional:</strong> R\$ ___________</li>\n</ul>\n<h2>2. KPIs Operacionais</h2>\n<table>\n<tr><th>Indicador</th><th>Meta</th><th>Realizado</th><th>Variação</th></tr>\n<tr><td>Vendas</td><td>___</td><td>___</td><td>+__%</td></tr>\n<tr><td>NPS</td><td>___</td><td>___</td><td>+___</td></tr>\n<tr><td>Churn</td><td>___%</td><td>___%</td><td>-__%</td></tr>\n</table>\n<h2>3. Destaques do Período</h2>\n<ul>\n<li>Lançamento de novo produto em ___________</li>\n<li>Expansão para mercado de ___________</li>\n<li>Parceria estratégica com ___________</li>\n</ul>\n<h2>4. Próximos Passos</h2>\n<ol>\n<li>Definir proprietário do projeto</li>\n<li>Validar cronograma com stakeholders</li>\n<li>Executar prova de conceito até ___________</li>\n</ol>',
  ),

  _Tpl(
    category: 'Negócios', title: 'Proposta Comercial',
    preview: 'Proposta profissional com escopo, investimento, prazo e condições.',
    html: '<h1>Proposta Comercial</h1>\n<p><strong>Data:</strong> ___________ &nbsp;&nbsp; <strong>Validade:</strong> 30 dias</p>\n<p><strong>Para:</strong> ___________ &nbsp;&nbsp; <strong>De:</strong> ___________</p>\n<hr/>\n<h2>Introdução</h2>\n<p>Apresentamos esta proposta com o objetivo de atender às necessidades de <strong>___________</strong>, oferecendo uma solução completa e personalizada ao vosso contexto específico.</p>\n<h2>Solução Proposta</h2>\n<ol>\n<li><strong>Fase 1 — Diagnóstico:</strong> Análise detalhada do contexto atual. Duração: ___ semanas.</li>\n<li><strong>Fase 2 — Implementação:</strong> Execução das soluções definidas. Duração: ___ semanas.</li>\n<li><strong>Fase 3 — Acompanhamento:</strong> Suporte e ajustes pós-entrega. Duração: ___ semanas.</li>\n</ol>\n<h2>Escopo de Entrega</h2>\n<ul>\n<li>Entrega 1 — Descrição detalhada</li>\n<li>Entrega 2 — Descrição detalhada</li>\n<li>Entrega 3 — Descrição detalhada</li>\n</ul>\n<p><strong>Fora do escopo:</strong> ___________</p>\n<h2>Investimento</h2>\n<table>\n<tr><th>Serviço / Item</th><th>Qtd.</th><th>Valor Unit.</th><th>Total</th></tr>\n<tr><td>Fase 1 — Diagnóstico</td><td>1</td><td>R\$ ___</td><td>R\$ ___</td></tr>\n<tr><td>Fase 2 — Implementação</td><td>1</td><td>R\$ ___</td><td>R\$ ___</td></tr>\n<tr><td><strong>Total</strong></td><td></td><td></td><td><strong>R\$ ___________</strong></td></tr>\n</table>\n<h2>Próximos Passos</h2>\n<ol>\n<li>Aprovação da proposta pelo cliente</li>\n<li>Assinatura do contrato</li>\n<li>Pagamento da primeira parcela</li>\n</ol>',
  ),

  _Tpl(
    category: 'Negócios', title: 'Acta de Reunião',
    preview: 'Registo estruturado com participantes, decisões e tarefas atribuídas.',
    html: '<h1>Acta de Reunião</h1>\n<p><strong>Data:</strong> ___________ &nbsp;&nbsp; <strong>Hora:</strong> ___________</p>\n<p><strong>Local / Plataforma:</strong> ___________</p>\n<p><strong>Moderador:</strong> ___________ &nbsp;&nbsp; <strong>Secretário:</strong> ___________</p>\n<hr/>\n<h2>Participantes</h2>\n<ul>\n<li>___________ — Função/Departamento</li>\n<li>___________ — Função/Departamento</li>\n<li>___________ — Função/Departamento</li>\n</ul>\n<h2>Ordem de Trabalhos</h2>\n<ol>\n<li>Ponto 1 — ___________</li>\n<li>Ponto 2 — ___________</li>\n<li>Ponto 3 — ___________</li>\n</ol>\n<h2>Desenvolvimento</h2>\n<h3>1. Ponto 1 — ___________</h3>\n<p>Resumo da discussão. Quem falou, o que foi apresentado, questões levantadas.</p>\n<blockquote>Observação ou decisão relevante do ponto 1.</blockquote>\n<h3>2. Ponto 2 — ___________</h3>\n<p>Resumo da discussão.</p>\n<h2>Decisões Tomadas</h2>\n<ul>\n<li>Decisão 1: ___________</li>\n<li>Decisão 2: ___________</li>\n</ul>\n<h2>Tarefas e Responsáveis</h2>\n<table>\n<tr><th>Tarefa</th><th>Responsável</th><th>Prazo</th></tr>\n<tr><td>Tarefa 1</td><td>___________</td><td>___________</td></tr>\n<tr><td>Tarefa 2</td><td>___________</td><td>___________</td></tr>\n</table>',
  ),

  // ── CV & Perfil ───────────────────────────────────
  _Tpl(
    category: 'CV & Perfil', title: 'Currículo Profissional',
    preview: 'CV completo com experiência, competências, educação e projetos.',
    html: '<h1>Nome Completo</h1>\n<p><em>Cargo / Especialidade — Localidade</em></p>\n<p>Email: email@exemplo.com &nbsp; Tel: +244 9XX XXX XXX &nbsp; Web: www.exemplo.com</p>\n<hr/>\n<h2>Resumo Profissional</h2>\n<p>Profissional com mais de ___ anos de experiência em ___________. Forte background em ___________, com foco em resultados mensuráveis e trabalho colaborativo. Apaixonado por soluções que conectam tecnologia e impacto real ao utilizador.</p>\n<h2>Experiência Profissional</h2>\n<h3>Cargo Atual — Empresa Atual</h3>\n<p><em>Jan 2022 — Atualmente · Luanda, Angola · Remoto</em></p>\n<ul>\n<li>Descrição de responsabilidade com resultado mensurável — ex.: reduzi tempo de entrega em 30%.</li>\n<li>Descrição de responsabilidade com resultado mensurável.</li>\n<li>Descrição de responsabilidade com resultado mensurável.</li>\n</ul>\n<h3>Cargo Anterior — Empresa Anterior</h3>\n<p><em>Mar 2019 — Dez 2021 · Luanda, Angola</em></p>\n<ul>\n<li>Descrição de responsabilidade com resultado mensurável.</li>\n<li>Descrição de responsabilidade com resultado mensurável.</li>\n</ul>\n<h2>Educação</h2>\n<h3>Licenciatura em ___________ — Universidade ___________</h3>\n<p><em>2015 — 2018</em></p>\n<h2>Competências Técnicas</h2>\n<ul>\n<li><strong>Linguagens:</strong> JavaScript, Python, Dart, TypeScript</li>\n<li><strong>Frameworks:</strong> React, Flutter, Node.js, FastAPI</li>\n<li><strong>Ferramentas:</strong> Figma, Git, Docker, Firebase</li>\n<li><strong>Idiomas:</strong> Português (Nativo), Inglês (Fluente)</li>\n</ul>',
  ),

  _Tpl(
    category: 'CV & Perfil', title: 'Carta de Apresentação',
    preview: 'Carta de candidatura com introdução, valor diferenciado e encerramento.',
    html: '<p><strong>Nome Completo</strong></p>\n<p>email@exemplo.com · +244 9XX XXX XXX · Localidade</p>\n<p>___________ (data)</p>\n<hr/>\n<p><strong>A atenção de:</strong></p>\n<p>Nome do Responsável / Recursos Humanos<br/>Nome da Empresa</p>\n<p>Exm.ª(o) Sr.ª(o) ___________,</p>\n<h2>Porquê esta empresa?</h2>\n<p>Escrevo com entusiasmo para candidatar-me à vaga de <strong>___________</strong> na <strong>___________</strong>. Acompanho o trabalho da vossa equipa há algum tempo e admiro profundamente como a empresa aborda ___________.</p>\n<h2>O Que Trago</h2>\n<p>Ao longo dos últimos ___ anos, desenvolvi competências sólidas em ___________, com resultados concretos:</p>\n<ul>\n<li>Resultado 1 — descrição com impacto mensurável.</li>\n<li>Resultado 2 — descrição com impacto mensurável.</li>\n<li>Resultado 3 — descrição com impacto mensurável.</li>\n</ul>\n<h2>Encerramento</h2>\n<p>Fico ao dispor para uma conversa e agradeço desde já a atenção dispensada. Em anexo encontra o meu currículo para referência adicional.</p>\n<p>Com os melhores cumprimentos,</p>\n<p><strong>Nome Completo</strong></p>',
  ),

  // ── Académico ─────────────────────────────────────
  _Tpl(
    category: 'Académico', title: 'Ensaio Académico',
    preview: 'Estrutura com resumo, introdução, desenvolvimento, conclusão e referências.',
    html: '<h1>Título do Ensaio Académico</h1>\n<p><strong>Autor(a):</strong> ___________</p>\n<p><strong>Instituição:</strong> ___________</p>\n<p><strong>Disciplina:</strong> ___________ &nbsp; <strong>Professor(a):</strong> ___________</p>\n<p><strong>Data:</strong> ___________</p>\n<hr/>\n<h2>Resumo</h2>\n<p>Este trabalho analisa ___________. O objectivo central é ___________. A metodologia empregada baseia-se em ___________, e as principais conclusões indicam que ___________.</p>\n<p><strong>Palavras-chave:</strong> palavra1, palavra2, palavra3.</p>\n<h2>1. Introdução</h2>\n<p>A presente análise tem como objectivo explorar o tema <em>___________</em>, abordando os seus principais aspectos sob a perspectiva de ___________. A relevância desta temática justifica-se pelo facto de ___________.</p>\n<h2>2. Fundamentação Teórica</h2>\n<p>Com base na literatura existente, é possível identificar três perspectivas principais. Em primeiro lugar, ___________ (Autor, ano) argumenta que ___________. Em segundo lugar, ___________ (Autor, ano) propõe que ___________.</p>\n<blockquote>Citação directa: "___________" (Autor, ano, p. __).</blockquote>\n<h2>3. Análise e Discussão</h2>\n<p>A análise dos dados revela que ___________. Este resultado está em consonância com as ideias de ___________ (Autor, ano).</p>\n<h2>4. Conclusão</h2>\n<p>Em suma, os argumentos apresentados demonstram que ___________.</p>\n<h2>Referências Bibliográficas</h2>\n<p>Autor, A. B. (2024). <em>Título da obra completa</em>. Editora.</p>',
  ),

  _Tpl(
    category: 'Académico', title: 'Relatório de Pesquisa',
    preview: 'Artigo científico com metodologia, resultados, discussão e referências.',
    html: '<h1>Título da Pesquisa</h1>\n<p><strong>Autores:</strong> ___________</p>\n<p><strong>Instituição:</strong> ___________ &nbsp; <strong>Data:</strong> ___________</p>\n<hr/>\n<h2>Abstract / Resumo</h2>\n<p>Este estudo investigou ___________. A metodologia empregada foi ___________. Os resultados indicam que ___________. Conclui-se que ___________.</p>\n<p><strong>Keywords:</strong> keyword1, keyword2, keyword3.</p>\n<h2>1. Introdução</h2>\n<p>O presente trabalho tem como objectivo ___________. A relevância desta pesquisa reside em ___________. A hipótese central é que ___________.</p>\n<h2>2. Metodologia</h2>\n<ul>\n<li><strong>Abordagem:</strong> Qualitativa / Quantitativa / Mista</li>\n<li><strong>Amostra:</strong> Descrição da amostra e critérios de seleção.</li>\n<li><strong>Instrumentos:</strong> Questionários, entrevistas, análise documental.</li>\n</ul>\n<h2>3. Resultados</h2>\n<table>\n<tr><th>Variável</th><th>Resultado</th><th>Significância (p)</th></tr>\n<tr><td>Variável A</td><td>___</td><td>p &lt; 0.05</td></tr>\n<tr><td>Variável B</td><td>___</td><td>p &lt; 0.01</td></tr>\n</table>\n<h2>4. Discussão</h2>\n<p>Os dados apresentados corroboram a hipótese inicial de que ___________.</p>\n<h2>5. Conclusão</h2>\n<p>Conclui-se que ___________. As principais contribuições são: (1) ___________; (2) ___________.</p>',
  ),

  // ── Pessoal ───────────────────────────────────────
  _Tpl(
    category: 'Pessoal', title: 'Diário / Reflexão',
    preview: 'Página de diário guiado com humor, gratidão, aprendizagens e intenções.',
    html: '<h1>Entrada do Diário</h1>\n<p><strong>Data:</strong> ___________ &nbsp;&nbsp; <strong>Hora:</strong> ___________</p>\n<p><strong>Humor:</strong> Feliz / Tranquilo / Triste / Stressado / Pensativo</p>\n<p><strong>Energia:</strong> ___/5</p>\n<hr/>\n<h2>O que aconteceu hoje</h2>\n<p>Descreve os eventos mais marcantes do dia — trabalho, relações, situações inesperadas...</p>\n<h2>Como me senti</h2>\n<p>O que as emoções de hoje tentaram comunicar-te? O que estava por baixo do que sentiste?</p>\n<h2>O que aprendi hoje</h2>\n<ul>\n<li></li>\n<li></li>\n</ul>\n<h2>3 coisas pelas quais sou grato/a hoje</h2>\n<ol>\n<li></li>\n<li></li>\n<li></li>\n</ol>\n<h2>Para amanhã</h2>\n<p>A <strong>única coisa mais importante</strong> que quero fazer amanhã: ___________</p>\n<p>Intenção do dia: ___________</p>\n<blockquote>Frase / pensamento do dia — escreve aqui algo que queres guardar.</blockquote>',
  ),

  _Tpl(
    category: 'Pessoal', title: 'Plano de Objetivos',
    preview: 'Sistema de metas SMART com curto, médio e longo prazo e hábitos de suporte.',
    html: '<h1>Os Meus Objetivos</h1>\n<p><em>Definido em: ___________ &nbsp;&nbsp; Revisão: ___________</em></p>\n<hr/>\n<h2>A minha visão de vida (5–10 anos)</h2>\n<blockquote>Quem quero ser? Como quero viver? O que quero ter construído? Escreve em presente, como se já fosse realidade.</blockquote>\n<h2>Curto Prazo — 1 a 3 meses</h2>\n<h3>Objetivo 1</h3>\n<p><strong>O quê:</strong> ___________</p>\n<p><strong>Por quê importa:</strong> ___________</p>\n<p><strong>Prazo:</strong> ___________ &nbsp; <strong>Próxima ação:</strong> ___________</p>\n<h3>Objetivo 2</h3>\n<p><strong>O quê:</strong> ___________ &nbsp; <strong>Prazo:</strong> ___________</p>\n<h2>Médio Prazo — 3 a 12 meses</h2>\n<ul>\n<li><strong>Meta 1:</strong> ___________ — Prazo: ___________</li>\n<li><strong>Meta 2:</strong> ___________ — Prazo: ___________</li>\n</ul>\n<h2>Longo Prazo — 1 a 5 anos</h2>\n<ul>\n<li><strong>Visão 1:</strong> ___________</li>\n<li><strong>Visão 2:</strong> ___________</li>\n</ul>\n<h2>Áreas de vida</h2>\n<table>\n<tr><th>Área</th><th>Satisfação (0–10)</th><th>Onde quero chegar</th></tr>\n<tr><td>Saúde &amp; Bem-estar</td><td></td><td></td></tr>\n<tr><td>Carreira &amp; Finanças</td><td></td><td></td></tr>\n<tr><td>Relações</td><td></td><td></td></tr>\n<tr><td>Crescimento pessoal</td><td></td><td></td></tr>\n</table>',
  ),

  // ── Criativo ──────────────────────────────────────
  _Tpl(
    category: 'Criativo', title: 'Conto / Narrativa',
    preview: 'Estrutura narrativa com personagens, cenário, conflito e arcos dramáticos.',
    html: '<h1>Título da História</h1>\n<p><em>Género: ___________ &nbsp; Público-alvo: ___________ &nbsp; Tom: ___________</em></p>\n<hr/>\n<h2>Sinopse</h2>\n<p>Em 2–3 frases, descreve o que acontece e o que está em jogo.</p>\n<h2>Personagens Principais</h2>\n<h3>Protagonista</h3>\n<p><strong>Nome:</strong> ___________ &nbsp; <strong>Idade:</strong> ___________</p>\n<p><strong>Desejo central:</strong> O que quer desesperadamente?</p>\n<p><strong>Medo central:</strong> O que mais teme?</p>\n<p><strong>Arco de transformação:</strong> Quem é no início → Quem se torna no final.</p>\n<h3>Antagonista / Obstáculo</h3>\n<p><strong>Nome:</strong> ___________ &nbsp; <strong>Motivação:</strong> Por que faz o que faz?</p>\n<h2>Acto I — Gancho</h2>\n<p>Apresenta o protagonista e o evento que quebra a normalidade.</p>\n<blockquote>Cena de abertura — a primeira linha que vai prender o leitor.</blockquote>\n<h2>Acto II — Conflito</h2>\n<p>Obstáculos crescentes, ponto de virada, crise.</p>\n<h2>Acto III — Resolução</h2>\n<p>Como o protagonista resolve o conflito? O que muda nele/a?</p>',
  ),

  _Tpl(
    category: 'Criativo', title: 'Roteiro de Vídeo',
    preview: 'Script com gancho, cenas, diálogos, chamada à ação e notas de produção.',
    html: '<h1>TÍTULO DO VÍDEO / EPISÓDIO</h1>\n<p><strong>Duração estimada:</strong> ___ &nbsp; <strong>Plataforma:</strong> ___________ &nbsp; <strong>Formato:</strong> ___________</p>\n<p><strong>Audiência-alvo:</strong> ___________</p>\n<p><strong>Objetivo:</strong> O que o espectador vai aprender/sentir/fazer após ver?</p>\n<hr/>\n<h2>GANCHO — 0:00 a 0:30</h2>\n<p><strong>[CÂMERA: Close-up]</strong></p>\n<p><strong>VOZ:</strong> "Pergunta provocadora ou afirmação surpreendente que prende o espectador nos primeiros segundos..."</p>\n<h2>INTRODUÇÃO — 0:30 a 1:30</h2>\n<p><strong>VOZ:</strong> "Hoje vamos falar sobre ___________. No final, vais saber exactamente como ___________."</p>\n<h2>PONTO 1 — ___________</h2>\n<p><strong>VOZ:</strong> Conteúdo do ponto 1. Explica o conceito, dá exemplos, usa analogias.</p>\n<h2>PONTO 2 — ___________</h2>\n<p><strong>VOZ:</strong> Conteúdo do ponto 2.</p>\n<h2>ENCERRAMENTO E CTA</h2>\n<p><strong>VOZ:</strong> "Em resumo, vimos que ___________. Se este vídeo foi útil, deixa um like e subscreve."</p>\n<h2>NOTAS DE PRODUÇÃO</h2>\n<ul>\n<li>Thumbnail: ___________</li>\n<li>Descrição SEO: ___________</li>\n<li>Tags: ___________</li>\n</ul>',
  ),
];

// ═══════════════════════════════════════════════════════
// SVGs
// ═══════════════════════════════════════════════════════
const _backSvg   = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';
const _searchSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ═══════════════════════════════════════════════════════
// SCREEN
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
          t.preview.toLowerCase().contains(q)).toList();
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
    final card = isDark ? const Color(0xFF252525) : const Color(0xFFF9F9F9);

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
                    decoration: BoxDecoration(
                      color: tp.withOpacity(.08),
                      borderRadius: BorderRadius.circular(_kChip),
                    ),
                    child: Text(tpl.category, style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ])),
                const SizedBox(width: 12),
                // Use button — top right
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

            // ── Document preview (A4-like) ──────────────────
            Expanded(child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(isDark ? .4 : .12),
                          blurRadius: 12, offset: const Offset(0, 3)),
                    ],
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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: _svgW(_backSvg, tp, s: 20),
        ),
        title: Text('Templates', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: div),
        ),
      ),
      body: Column(children: [
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.65,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _TplCard(
                  tpl: filtered[i],
                  isDark: isDark, tp: tp, ts: ts, acc: acc,
                  onTap: () => _showPreview(filtered[i]),
                ),
              ),
        ),
      ]),
    );
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
// TEMPLATE CARD — Canva style document preview
// ═══════════════════════════════════════════════════════
class _TplCard extends StatelessWidget {
  final _Tpl tpl;
  final bool isDark;
  final Color tp, ts, acc;
  final VoidCallback onTap;
  const _TplCard({required this.tpl, required this.isDark, required this.tp, required this.ts, required this.acc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardBg     = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final previewBg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final divC       = isDark ? AppColors.darkDivider : AppColors.divider;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(_kCard),
          border: Border.all(color: divC.withOpacity(.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .3 : .07),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Document mini-preview ──────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_kCard),
                topRight: Radius.circular(_kCard),
              ),
              child: Container(
                color: previewBg,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                // Transform to show A4 proportion but fit the card
                child: OverflowBox(
                  maxHeight: double.infinity,
                  alignment: Alignment.topCenter,
                  child: Transform.scale(
                    scale: 0.42,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 400, // approx A4 width at preview scale
                      child: _DocPreview(
                        html: tpl.html, tp: tp, ts: ts,
                        div: divC, acc: acc, isDark: isDark,
                        compact: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Label ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: divC.withOpacity(.5), width: 0.5)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tpl.title,
                  style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w700, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(tpl.category,
                  style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// DOC PREVIEW — renders HTML-like content as Flutter widgets
// Shows the actual document structure (title, body, headings, table, etc.)
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
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 6 : 10),
          child: Text(n.text, style: GoogleFonts.roboto(
              color: tp, fontSize: h1, fontWeight: FontWeight.w800, height: 1.2)),
        );
      case 'h2':
        return Padding(
          padding: EdgeInsets.only(top: compact ? 6 : 10, bottom: compact ? 3 : 5),
          child: Text(n.text, style: GoogleFonts.roboto(
              color: tp, fontSize: h2, fontWeight: FontWeight.w700)),
        );
      case 'h3':
        return Padding(
          padding: EdgeInsets.only(top: compact ? 4 : 7, bottom: compact ? 2 : 4),
          child: Text(n.text, style: GoogleFonts.roboto(
              color: tp, fontSize: h3, fontWeight: FontWeight.w700)),
        );
      case 'p':
        if (n.text.isEmpty) return SizedBox(height: compact ? 3 : 6);
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 3 : 6),
          child: Text(n.text, style: GoogleFonts.roboto(
              color: ts, fontSize: body, height: 1.5),
              maxLines: compact ? 2 : 100, overflow: TextOverflow.ellipsis),
        );
      case 'blockquote':
        return Container(
          margin: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 4 : 7),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: acc, width: 2.5)),
            color: acc.withOpacity(.06),
            borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
          ),
          child: Text(n.text, style: GoogleFonts.roboto(
              color: ts, fontSize: compact ? 9 : 12, fontStyle: FontStyle.italic),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        );
      case 'ul':
      case 'ol':
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 3 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: n.items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: compact ? 14 : 18,
                  child: Text(
                    n.tag == 'ol' ? '${e.key + 1}.' : '•',
                    style: GoogleFonts.roboto(color: acc, fontSize: li, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(child: Text(e.value, style: GoogleFonts.roboto(
                    color: ts, fontSize: li), maxLines: compact ? 1 : 3, overflow: TextOverflow.ellipsis)),
              ]),
            )).toList(),
          ),
        );
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
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 5 : 8, vertical: compact ? 3 : 6),
                child: Text(cell, style: GoogleFonts.roboto(
                    color: isHeader ? tp : ts,
                    fontSize: fontSize,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              )).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Minimal HTML parser ──────────────────────────────
  List<_HtmlNode> _parseHtml(String raw) {
    final result = <_HtmlNode>[];
    // Remove HTML entities from display
    String clean(String s) => s
        .replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ').replaceAll(RegExp(r'<[^>]+>'), '').trim();

    final tagRe = RegExp(
        r'<(h[123]|p|blockquote|ul|ol|table|hr|li|tr|th|td|thead|tbody)[^>]*>([\s\S]*?)<\/\1>|<hr\s*\/?>',
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
        final rowRe = RegExp(r'<tr[^>]*>([\s\S]*?)<\/tr>', caseSensitive: false);
        for (final row in rowRe.allMatches(body)) {
          final cellRe = RegExp(r'<t[hd][^>]*>([\s\S]*?)<\/t[hd]>', caseSensitive: false);
          final cells = cellRe.allMatches(row.group(1)??'')
              .map((c) => clean(c.group(1) ?? '')).toList();
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
