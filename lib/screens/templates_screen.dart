import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import '../models/document.dart';

const _kPill  = 999.0;
const _kCard  = 12.0;
const _kModal = 20.0;
const _kChip  = 6.0;

class _Tpl {
  final String category, title, preview, html;
  const _Tpl({required this.category, required this.title, required this.preview, required this.html});
}

// Estilos inline reutilizáveis para tabelas
const _ts = 'style="width:100%;border-collapse:collapse;margin:12px 0;font-size:.9em"';
const _th = 'style="background:#f0f0f0;padding:8px 10px;border:1px solid #ddd;font-weight:700;text-align:left"';
const _td = 'style="padding:8px 10px;border:1px solid #e8e8e8"';

const _kTemplates = <_Tpl>[

  // ── Negócios ──────────────────────────────────────────
  _Tpl(
    category: 'Negócios', title: 'Relatório Executivo',
    preview: 'Relatório trimestral com KPIs, resultados e recomendações.',
    html: '<h1>Relatório Executivo</h1>'
        '<p><strong>Período:</strong> Q1 2025 &nbsp;·&nbsp; <strong>Elaborado por:</strong> ___________</p>'
        '<hr>'
        '<h2>Resumo Executivo</h2>'
        '<p>Este relatório apresenta os principais indicadores de desempenho do período, consolidando resultados financeiros, operacionais e estratégicos para apoiar a tomada de decisão.</p>'
        '<blockquote><strong>Insight chave:</strong> Crescimento de 12% na receita em relação ao trimestre anterior.</blockquote>'
        '<h2>1. Resultados Financeiros</h2>'
        '<ul><li><strong>Receita total:</strong> R\$ ___________</li>'
        '<li><strong>Lucro bruto:</strong> R\$ ___________</li>'
        '<li><strong>Margem líquida:</strong> ___%</li></ul>'
        '<h2>2. KPIs Operacionais</h2>'
        '<table $_ts>'
        '<tr><th $_th>Indicador</th><th $_th>Meta</th><th $_th>Realizado</th><th $_th>Variação</th></tr>'
        '<tr><td $_td>Vendas</td><td $_td>___</td><td $_td>___</td><td $_td>+__%</td></tr>'
        '<tr><td $_td>NPS</td><td $_td>___</td><td $_td>___</td><td $_td>+___</td></tr>'
        '<tr><td $_td>Churn</td><td $_td>___%</td><td $_td>___%</td><td $_td>-__%</td></tr>'
        '</table>'
        '<h2>3. Próximos Passos</h2>'
        '<ol><li>Definir proprietário do projeto</li>'
        '<li>Validar cronograma com stakeholders</li>'
        '<li>Executar prova de conceito até ___________</li></ol>'
        '<h2>Conclusão</h2>'
        '<p>Os resultados demonstram ___________. A equipa mantém o foco em ___________ para o próximo trimestre.</p>',
  ),

  _Tpl(
    category: 'Negócios', title: 'Proposta Comercial',
    preview: 'Proposta com escopo, investimento, prazo e condições.',
    html: '<h1>Proposta Comercial</h1>'
        '<p><strong>Para:</strong> ___________ &nbsp;·&nbsp; <strong>Data:</strong> ___________ &nbsp;·&nbsp; <strong>Validade:</strong> 30 dias</p>'
        '<hr>'
        '<h2>Introdução</h2>'
        '<p>Apresentamos esta proposta com o objetivo de atender às necessidades de <strong>___________</strong>, oferecendo uma solução completa e personalizada.</p>'
        '<h2>Solução Proposta</h2>'
        '<ol><li><strong>Fase 1 — Diagnóstico:</strong> Análise detalhada. Duração: ___ semanas.</li>'
        '<li><strong>Fase 2 — Implementação:</strong> Execução das soluções. Duração: ___ semanas.</li>'
        '<li><strong>Fase 3 — Acompanhamento:</strong> Suporte pós-entrega. Duração: ___ semanas.</li></ol>'
        '<h2>Investimento</h2>'
        '<table $_ts>'
        '<tr><th $_th>Serviço</th><th $_th>Qtd.</th><th $_th>Valor Unit.</th><th $_th>Total</th></tr>'
        '<tr><td $_td>Fase 1 — Diagnóstico</td><td $_td>1</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Fase 2 — Implementação</td><td $_td>1</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Fase 3 — Suporte</td><td $_td>1</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td><strong>Total</strong></td><td $_td></td><td $_td></td><td $_td><strong>R\$ ___________</strong></td></tr>'
        '</table>'
        '<h2>Condições</h2>'
        '<ul><li><strong>Pagamento:</strong> 50% na assinatura, 50% na entrega final</li>'
        '<li><strong>Prazo total:</strong> ___ semanas a partir da aprovação</li>'
        '<li><strong>Suporte pós-entrega:</strong> ___ dias</li></ul>',
  ),

  _Tpl(
    category: 'Negócios', title: 'Acta de Reunião',
    preview: 'Registo com participantes, decisões e tarefas.',
    html: '<h1>Acta de Reunião</h1>'
        '<p><strong>Data:</strong> ___________ &nbsp;·&nbsp; <strong>Hora:</strong> ___________ &nbsp;·&nbsp; <strong>Moderador:</strong> ___________</p>'
        '<hr>'
        '<h2>Participantes</h2>'
        '<ul><li>___________ — Função</li><li>___________ — Função</li><li>___________ — Função</li></ul>'
        '<h2>Ordem de Trabalhos</h2>'
        '<ul><li>Ponto 1 — ___________</li><li>Ponto 2 — ___________</li></ul>'
        '<h2>Desenvolvimento</h2>'
        '<h3>1. Ponto 1 — ___________</h3>'
        '<p>Resumo da discussão. Quem falou, o que foi apresentado, questões levantadas.</p>'
        '<h3>2. Ponto 2 — ___________</h3>'
        '<p>Resumo da discussão.</p>'
        '<h2>Decisões Tomadas</h2>'
        '<ul><li>Decisão 1: ___________</li><li>Decisão 2: ___________</li></ul>'
        '<h2>Tarefas e Responsáveis</h2>'
        '<table $_ts>'
        '<tr><th $_th>Tarefa</th><th $_th>Responsável</th><th $_th>Prazo</th></tr>'
        '<tr><td $_td>Tarefa 1</td><td $_td>___________</td><td $_td>___________</td></tr>'
        '<tr><td $_td>Tarefa 2</td><td $_td>___________</td><td $_td>___________</td></tr>'
        '</table>',
  ),

  // ── CV & Perfil ───────────────────────────────────────
  _Tpl(
    category: 'CV & Perfil', title: 'Currículo Profissional',
    preview: 'CV com experiência, competências, educação e idiomas.',
    html: '<h1>Nome Completo</h1>'
        '<p>Cargo / Especialidade &nbsp;·&nbsp; email@exemplo.com &nbsp;·&nbsp; +244 9XX XXX XXX &nbsp;·&nbsp; Localidade</p>'
        '<hr>'
        '<h2>Resumo Profissional</h2>'
        '<p>Profissional com mais de ___ anos de experiência em ___________. Forte background em ___________, com foco em resultados mensuráveis e trabalho colaborativo.</p>'
        '<h2>Experiência Profissional</h2>'
        '<h3>Cargo Atual — Empresa Atual</h3>'
        '<p>Jan 2022 — Atualmente &nbsp;·&nbsp; Luanda, Angola</p>'
        '<ul><li>Responsabilidade com resultado mensurável — ex.: reduzi tempo de entrega em 30%.</li>'
        '<li>Responsabilidade com resultado mensurável.</li></ul>'
        '<h3>Cargo Anterior — Empresa Anterior</h3>'
        '<p>Mar 2019 — Dez 2021 &nbsp;·&nbsp; Luanda, Angola</p>'
        '<ul><li>Responsabilidade com resultado mensurável.</li>'
        '<li>Responsabilidade com resultado mensurável.</li></ul>'
        '<h2>Educação</h2>'
        '<p><strong>Licenciatura em ___________</strong> — Universidade ___________ &nbsp;·&nbsp; 2015–2018</p>'
        '<h2>Competências</h2>'
        '<ul><li>JavaScript / TypeScript &nbsp;·&nbsp; React / Next.js</li>'
        '<li>Python / FastAPI &nbsp;·&nbsp; Flutter / Dart</li>'
        '<li>Figma / Design UI &nbsp;·&nbsp; Git / Docker / Firebase</li></ul>'
        '<h2>Idiomas</h2>'
        '<ul><li>Português — Nativo</li><li>Inglês — Fluente (C1)</li></ul>',
  ),

  _Tpl(
    category: 'CV & Perfil', title: 'Carta de Apresentação',
    preview: 'Carta de candidatura com introdução, valor e encerramento.',
    html: '<p>___________ (data)</p>'
        '<p><strong>A atenção de:</strong> Nome do Responsável / RH<br>Nome da Empresa</p>'
        '<p>Exm.ª(o) Sr.ª(o) ___________,</p>'
        '<h2>Porquê esta empresa?</h2>'
        '<p>Escrevo com entusiasmo para candidatar-me à vaga de <strong>___________</strong> na <strong>___________</strong>. Acompanho o trabalho da vossa equipa há algum tempo e admiro profundamente como abordam ___________.</p>'
        '<h2>O Que Trago</h2>'
        '<p>Ao longo dos últimos ___ anos, desenvolvi competências sólidas em ___________, com resultados concretos:</p>'
        '<ul><li>Resultado 1 — descrição com impacto mensurável.</li>'
        '<li>Resultado 2 — descrição com impacto mensurável.</li>'
        '<li>Resultado 3 — descrição com impacto mensurável.</li></ul>'
        '<h2>Encerramento</h2>'
        '<p>Fico ao dispor para uma conversa e agradeço desde já a atenção dispensada. Em anexo encontra o meu currículo para referência adicional.</p>'
        '<p>Com os melhores cumprimentos,</p>'
        '<p><strong>Nome Completo</strong></p>',
  ),

  // ── Académico ──────────────────────────────────────────
  _Tpl(
    category: 'Académico', title: 'Ensaio Académico',
    preview: 'Estrutura com resumo, desenvolvimento, conclusão e referências.',
    html: '<h1>Título do Ensaio Académico</h1>'
        '<p><strong>Autor(a):</strong> ___________ &nbsp;·&nbsp; <strong>Instituição:</strong> ___________ &nbsp;·&nbsp; <strong>Data:</strong> ___________</p>'
        '<hr>'
        '<blockquote><strong>Resumo:</strong> Este trabalho analisa ___________. O objetivo central é ___________. Conclui-se que ___________.<br>'
        '<strong>Palavras-chave:</strong> palavra1, palavra2, palavra3.</blockquote>'
        '<h2>1. Introdução</h2>'
        '<p>A presente análise tem como objetivo explorar o tema <em>___________</em>. A relevância desta temática justifica-se pelo facto de ___________. Estrutura-se o trabalho em quatro partes: fundamentação teórica, análise, conclusões e referências.</p>'
        '<h2>2. Fundamentação Teórica</h2>'
        '<p>Com base na literatura existente, é possível identificar três perspectivas. Em primeiro lugar, ___________ (Autor, ano) argumenta que ___________.</p>'
        '<blockquote>"Citação directa do autor mais relevante." (Autor, ano, p. __)</blockquote>'
        '<h2>3. Análise e Discussão</h2>'
        '<p>A análise dos dados revela que ___________. Este resultado está em consonância com as ideias de ___________ (Autor, ano).</p>'
        '<h2>4. Conclusão</h2>'
        '<p>Em suma, os argumentos demonstram que ___________. As principais contribuições residem em: (1) ___________; (2) ___________.</p>'
        '<h2>Referências Bibliográficas</h2>'
        '<p>Autor, A. B. (2024). <em>Título da obra</em>. Editora.</p>'
        '<p>Autor, C. D. &amp; Autor, E. F. (2023). Título do artigo. <em>Nome da Revista</em>, <em>10</em>(2), 45–67.</p>',
  ),

  _Tpl(
    category: 'Académico', title: 'Relatório de Pesquisa',
    preview: 'Artigo com metodologia, resultados e discussão.',
    html: '<h1>Título da Pesquisa</h1>'
        '<p><strong>Autores:</strong> ___________ &nbsp;·&nbsp; <strong>Instituição:</strong> ___________ &nbsp;·&nbsp; <strong>Data:</strong> ___________</p>'
        '<hr>'
        '<blockquote><strong>Resumo:</strong> Este estudo investigou ___________. A metodologia empregada foi ___________. Os resultados indicam que ___________.<br>'
        '<strong>Keywords:</strong> keyword1 &nbsp;·&nbsp; keyword2 &nbsp;·&nbsp; keyword3</blockquote>'
        '<h2>1. Introdução</h2>'
        '<p>O presente trabalho tem como objetivo ___________. A hipótese central é que ___________.</p>'
        '<h2>2. Metodologia</h2>'
        '<ul><li><strong>Abordagem:</strong> Qualitativa / Quantitativa / Mista</li>'
        '<li><strong>Amostra:</strong> Descrição da amostra e critérios de seleção.</li>'
        '<li><strong>Instrumentos:</strong> Questionários, entrevistas, análise documental.</li></ul>'
        '<h2>3. Resultados</h2>'
        '<table $_ts>'
        '<tr><th $_th>Variável</th><th $_th>Resultado</th><th $_th>p</th><th $_th>Interpretação</th></tr>'
        '<tr><td $_td>Variável A</td><td $_td>___</td><td $_td>&lt; 0.05</td><td $_td>Significativo</td></tr>'
        '<tr><td $_td>Variável B</td><td $_td>___</td><td $_td>&lt; 0.01</td><td $_td>Muito significativo</td></tr>'
        '</table>'
        '<h2>4. Conclusão</h2>'
        '<p>Conclui-se que ___________. Pesquisas futuras deverão explorar ___________.</p>',
  ),

  // ── Pessoal ────────────────────────────────────────────
  _Tpl(
    category: 'Pessoal', title: 'Plano de Objetivos',
    preview: 'Metas SMART com curto, médio e longo prazo.',
    html: '<h1>Os Meus Objetivos</h1>'
        '<p><strong>Definido em:</strong> ___________ &nbsp;·&nbsp; <strong>Próxima revisão:</strong> ___________</p>'
        '<hr>'
        '<h2>Visão de vida (5–10 anos)</h2>'
        '<blockquote>Quem quero ser? Como quero viver? O que quero ter construído? Escreve em presente, como se já fosse realidade.</blockquote>'
        '<h2>Curto Prazo — 1 a 3 meses</h2>'
        '<h3>Objetivo 1</h3>'
        '<ul><li><strong>O quê:</strong> ___________</li>'
        '<li><strong>Por quê importa:</strong> ___________</li>'
        '<li><strong>Prazo:</strong> ___________ &nbsp;·&nbsp; <strong>Próxima ação:</strong> ___________</li></ul>'
        '<h2>Médio Prazo — 3 a 12 meses</h2>'
        '<ul><li><strong>Meta 1:</strong> ___________ — Prazo: ___________</li>'
        '<li><strong>Meta 2:</strong> ___________ — Prazo: ___________</li>'
        '<li><strong>Meta 3:</strong> ___________ — Prazo: ___________</li></ul>'
        '<h2>Áreas de vida</h2>'
        '<table $_ts>'
        '<tr><th $_th>Área</th><th $_th>Satisfação (0–10)</th><th $_th>Meta em 6 meses</th></tr>'
        '<tr><td $_td>Saúde &amp; Bem-estar</td><td $_td></td><td $_td></td></tr>'
        '<tr><td $_td>Carreira &amp; Finanças</td><td $_td></td><td $_td></td></tr>'
        '<tr><td $_td>Relações</td><td $_td></td><td $_td></td></tr>'
        '<tr><td $_td>Crescimento pessoal</td><td $_td></td><td $_td></td></tr>'
        '</table>',
  ),

  _Tpl(
    category: 'Pessoal', title: 'Orçamento Pessoal',
    preview: 'Receitas, despesas e metas de poupança.',
    html: '<h1>Orçamento Mensal</h1>'
        '<p><strong>Mês:</strong> ___________ &nbsp;·&nbsp; <strong>Responsável:</strong> ___________</p>'
        '<hr>'
        '<h2>Resumo</h2>'
        '<table $_ts>'
        '<tr><th $_th>Receita Total</th><th $_th>Despesas Totais</th><th $_th>Saldo</th></tr>'
        '<tr><td $_td>R\$ ___</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '</table>'
        '<h2>Receitas</h2>'
        '<table $_ts>'
        '<tr><th $_th>Fonte</th><th $_th>Previsto</th><th $_th>Real</th></tr>'
        '<tr><td $_td>Salário</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Freelance</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '</table>'
        '<h2>Despesas</h2>'
        '<table $_ts>'
        '<tr><th $_th>Categoria</th><th $_th>Previsto</th><th $_th>Real</th></tr>'
        '<tr><td $_td>Habitação</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Alimentação</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Transporte</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '<tr><td $_td>Saúde</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td></tr>'
        '</table>'
        '<h2>Poupança</h2>'
        '<table $_ts>'
        '<tr><th $_th>Meta</th><th $_th>Alvo</th><th $_th>Acumulado</th><th $_th>Prazo</th></tr>'
        '<tr><td $_td>Fundo de emergência</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td><td $_td>___</td></tr>'
        '<tr><td $_td>Investimento</td><td $_td>R\$ ___</td><td $_td>R\$ ___</td><td $_td>___</td></tr>'
        '</table>',
  ),

  // ── Projeto ────────────────────────────────────────────
  _Tpl(
    category: 'Projeto', title: 'Plano de Projeto',
    preview: 'Objetivos, entregas, cronograma, equipa e riscos.',
    html: '<h1>Nome do Projeto</h1>'
        '<p><strong>Gestor:</strong> ___________ &nbsp;·&nbsp; <strong>Início:</strong> ___________ &nbsp;·&nbsp; <strong>Fim:</strong> ___________ &nbsp;·&nbsp; <strong>Orçamento:</strong> R\$ ___________</p>'
        '<hr>'
        '<h2>Objetivo do Projeto</h2>'
        '<p>Descrição clara e mensurável do que este projeto pretende alcançar, com critérios de sucesso bem definidos.</p>'
        '<h2>Entregas</h2>'
        '<ul><li><strong>Entrega 1:</strong> ___________ — Prazo: ___________</li>'
        '<li><strong>Entrega 2:</strong> ___________ — Prazo: ___________</li>'
        '<li><strong>Entrega 3:</strong> ___________ — Prazo: ___________</li></ul>'
        '<h2>Cronograma</h2>'
        '<table $_ts>'
        '<tr><th $_th>Tarefa</th><th $_th>Responsável</th><th $_th>Início</th><th $_th>Fim</th></tr>'
        '<tr><td $_td>Tarefa 1</td><td $_td>___</td><td $_td>___</td><td $_td>___</td></tr>'
        '<tr><td $_td>Tarefa 2</td><td $_td>___</td><td $_td>___</td><td $_td>___</td></tr>'
        '<tr><td $_td>Tarefa 3</td><td $_td>___</td><td $_td>___</td><td $_td>___</td></tr>'
        '</table>'
        '<h2>Riscos</h2>'
        '<table $_ts>'
        '<tr><th $_th>Risco</th><th $_th>Probabilidade</th><th $_th>Impacto</th><th $_th>Mitigação</th></tr>'
        '<tr><td $_td>___________</td><td $_td>Média</td><td $_td>Alto</td><td $_td>___________</td></tr>'
        '</table>',
  ),

  // ── Legal ──────────────────────────────────────────────
  _Tpl(
    category: 'Legal', title: 'Contrato de Serviços',
    preview: 'Contrato com cláusulas essenciais e assinaturas.',
    html: '<h1 style="text-align:center;text-transform:uppercase;letter-spacing:2px">Contrato de Prestação de Serviços</h1>'
        '<hr>'
        '<p><strong>Prestador:</strong> ___________ &nbsp;·&nbsp; NIF: ___________ &nbsp;·&nbsp; Morada: ___________</p>'
        '<p><strong>Cliente:</strong> ___________ &nbsp;·&nbsp; NIF: ___________ &nbsp;·&nbsp; Morada: ___________</p>'
        '<p>As partes celebram o presente contrato, regido pelas seguintes cláusulas:</p>'
        '<h2>Cláusula 1.ª — Objecto</h2>'
        '<p>O Prestador compromete-se a prestar ao Cliente: ___________.</p>'
        '<h2>Cláusula 2.ª — Prazo</h2>'
        '<p>Início em ___________ e término em ___________, podendo ser renovado por acordo escrito.</p>'
        '<h2>Cláusula 3.ª — Remuneração</h2>'
        '<p>O Cliente pagará R\$ ___________, nas condições: ___________.</p>'
        '<h2>Cláusula 4.ª — Obrigações do Prestador</h2>'
        '<ol><li>Executar os serviços com diligência e qualidade.</li>'
        '<li>Guardar confidencialidade sobre as informações do Cliente.</li>'
        '<li>Cumprir os prazos acordados.</li></ol>'
        '<h2>Cláusula 5.ª — Resolução de Conflitos</h2>'
        '<p>Em caso de conflito, as partes recorrem à mediação, elegendo o foro de ___________.</p>'
        '<p>Feito em ___________, aos ___ de ___________ de ___________.</p>'
        '<br><p>_____________________________________ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _____________________________________</p>'
        '<p>O Prestador &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; O Cliente</p>',
  ),

  _Tpl(
    category: 'Legal', title: 'Declaração Oficial',
    preview: 'Declaração formal para fins institucionais ou profissionais.',
    html: '<h1 style="text-align:center;text-transform:uppercase;letter-spacing:2px">Nome da Instituição</h1>'
        '<p style="text-align:center">Endereço &nbsp;·&nbsp; Tel: ___________ &nbsp;·&nbsp; Email: ___________</p>'
        '<hr>'
        '<h2 style="text-align:center;text-transform:uppercase;letter-spacing:2px">Declaração</h2>'
        '<p>___________ (nome do declarante), portador(a) do BI/Passaporte n.º ___________, na qualidade de ___________ da ___________, declara que:</p>'
        '<p>___________ é/foi ___________ desta instituição, desde ___________ até ___________, tendo cumprido as suas funções com ___________.</p>'
        '<p>Mais se declara que ___________, conforme consta nos nossos registos internos.</p>'
        '<p>A presente declaração é passada a pedido do(a) interessado(a), para os fins que entender convenientes.</p>'
        '<br><p>___________ (local), aos ___ de ___________ de ___________.</p>'
        '<br><br>'
        '<p style="text-align:center">___________________________________________</p>'
        '<p style="text-align:center">Nome completo &nbsp;·&nbsp; Cargo</p>',
  ),
];

// ── SVG pesquisa ───────────────────────────────────────
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
    final bg  = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.72, minChildSize: 0.4, maxChildSize: 0.97, expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
          child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Center(child: Container(width: 36, height: 3.5,
                  decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
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
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(tpl.preview, style: GoogleFonts.roboto(color: ts, fontSize: 13, height: 1.5))),
            Container(height: 0.5, color: div),
            Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .4 : .12), blurRadius: 12, offset: const Offset(0, 3))],
                ),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                child: _DocPreview(html: tpl.html, tp: tp, ts: ts, div: div, acc: acc),
              ),
            ])),
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

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          height: 42,
          decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(_kPill)),
          child: Row(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _svgW(_searchSvg, ts, s: 15)),
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
      SizedBox(height: 44,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          scrollDirection: Axis.horizontal,
          children: [
            _CatChip(label: 'Todos', selected: _cat == null, acc: acc, tp: tp, ts: ts, onTap: () => setState(() => _cat = null)),
            ..._categories.map((c) => _CatChip(
                label: c, selected: _cat == c, acc: acc, tp: tp, ts: ts,
                onTap: () => setState(() => _cat = _cat == c ? null : c))),
          ],
        ),
      ),
      Container(height: 0.5, color: div, margin: const EdgeInsets.only(top: 6)),
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
          color: selected ? Colors.white : ts, fontSize: 12, fontWeight: FontWeight.w700)),
    ),
  );
}

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
                  maxHeight: double.infinity, alignment: Alignment.topCenter,
                  child: Transform.scale(scale: 0.42, alignment: Alignment.topLeft,
                    child: SizedBox(width: 400,
                      child: _DocPreview(html: tpl.html, tp: tp, ts: ts, div: divC, acc: acc, compact: true)),
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
// DOC PREVIEW
// ═══════════════════════════════════════════════════════
class _DocPreview extends StatelessWidget {
  final String html;
  final Color tp, ts, div, acc;
  final bool compact;
  const _DocPreview({required this.html, required this.tp, required this.ts, required this.div, required this.acc, this.compact = false});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
    children: _parse(html).map(_build).toList(),
  );

  Widget _build(_Node n) {
    final h1 = compact ? 16.0 : 22.0;
    final h2 = compact ? 13.0 : 17.0;
    final h3 = compact ? 11.0 : 14.0;
    final bd = compact ? 10.0 : 13.0;
    final li = compact ? 9.5  : 12.5;
    switch (n.tag) {
      case 'h1': return Padding(padding: EdgeInsets.only(bottom: compact ? 5.0 : 10),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h1, fontWeight: FontWeight.w800, height: 1.2)));
      case 'h2': return Padding(padding: EdgeInsets.only(top: compact ? 6.0 : 10, bottom: compact ? 3.0 : 5),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h2, fontWeight: FontWeight.w700)));
      case 'h3': return Padding(padding: EdgeInsets.only(top: compact ? 4.0 : 7, bottom: compact ? 2.0 : 4),
          child: Text(n.text, style: GoogleFonts.roboto(color: tp, fontSize: h3, fontWeight: FontWeight.w700)));
      case 'p':
        if (n.text.isEmpty) return SizedBox(height: compact ? 3.0 : 6);
        return Padding(padding: EdgeInsets.only(bottom: compact ? 3.0 : 6),
          child: Text(n.text, style: GoogleFonts.roboto(color: ts, fontSize: bd, height: 1.5),
              maxLines: compact ? 2 : 100, overflow: TextOverflow.ellipsis));
      case 'blockquote': return Container(
          margin: EdgeInsets.symmetric(vertical: compact ? 4.0 : 8),
          padding: EdgeInsets.fromLTRB(compact ? 6.0 : 10, compact ? 4.0 : 7, compact ? 6.0 : 10, compact ? 4.0 : 7),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: acc, width: 2.5)), color: acc.withOpacity(.06)),
          child: Text(n.text, style: GoogleFonts.roboto(color: ts, fontSize: compact ? 9.0 : 12, fontStyle: FontStyle.italic),
              maxLines: 2, overflow: TextOverflow.ellipsis));
      case 'ul':
      case 'ol': return Padding(padding: EdgeInsets.only(bottom: compact ? 3.0 : 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: n.items.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: compact ? 14.0 : 18, child: Text(n.tag == 'ol' ? '${e.key+1}.' : '•',
                    style: GoogleFonts.roboto(color: acc, fontSize: li, fontWeight: FontWeight.w700))),
                Expanded(child: Text(e.value, style: GoogleFonts.roboto(color: ts, fontSize: li),
                    maxLines: compact ? 1 : 3, overflow: TextOverflow.ellipsis)),
              ]),
            )).toList()));
      case 'table': return _buildTable(n);
      case 'hr': return Container(height: 0.5, color: div, margin: EdgeInsets.symmetric(vertical: compact ? 6.0 : 10));
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildTable(_Node n) {
    if (n.rows.isEmpty) return const SizedBox.shrink();
    final fs = compact ? 8.5 : 11.5;
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 5.0 : 10),
      decoration: BoxDecoration(border: Border.all(color: div), borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(borderRadius: BorderRadius.circular(4),
        child: Table(
          border: TableBorder(horizontalInside: BorderSide(color: div, width: 0.5), verticalInside: BorderSide(color: div, width: 0.5)),
          defaultColumnWidth: const FlexColumnWidth(),
          children: n.rows.asMap().entries.map((re) {
            final isH = re.key == 0;
            return TableRow(
              decoration: BoxDecoration(color: isH ? acc.withOpacity(.1) : (re.key.isOdd ? tp.withOpacity(.02) : null)),
              children: re.value.map((cell) => Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 5.0 : 8, vertical: compact ? 3.0 : 6),
                child: Text(cell, style: GoogleFonts.roboto(color: isH ? tp : ts, fontSize: fs,
                    fontWeight: isH ? FontWeight.w700 : FontWeight.w400),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              )).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<_Node> _parse(String raw) {
    final result = <_Node>[];
    String clean(String s) => s
        .replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ').replaceAll(RegExp(r'<[^>]+>'), '').trim();
    final re = RegExp(r'<(h[123]|p|blockquote|ul|ol|table|hr)[^>]*>([\s\S]*?)<\/\1>|<hr\s*/?>', caseSensitive: false);
    for (final m in re.allMatches(raw)) {
      final tag = (m.group(1) ?? 'hr').toLowerCase();
      final body = m.group(2) ?? '';
      if (tag == 'hr') { result.add(_Node('hr', '')); continue; }
      if (tag == 'ul' || tag == 'ol') {
        final items = RegExp(r'<li[^>]*>([\s\S]*?)<\/li>', caseSensitive: false)
            .allMatches(body).map((li) => clean(li.group(1) ?? '')).where((s) => s.isNotEmpty).toList();
        if (items.isNotEmpty) result.add(_Node(tag, '', items: items));
        continue;
      }
      if (tag == 'table') {
        final rows = <List<String>>[];
        for (final row in RegExp(r'<tr[^>]*>([\s\S]*?)<\/tr>', caseSensitive: false).allMatches(body)) {
          final cells = RegExp(r'<t[hd][^>]*>([\s\S]*?)<\/t[hd]>', caseSensitive: false)
              .allMatches(row.group(1) ?? '').map((c) => clean(c.group(1) ?? '')).toList();
          if (cells.isNotEmpty) rows.add(cells);
        }
        if (rows.isNotEmpty) { final nd = _Node('table', ''); nd.rows = rows; result.add(nd); }
        continue;
      }
      final text = clean(body);
      if (text.isNotEmpty || tag == 'p') result.add(_Node(tag, text));
    }
    return result;
  }
}

class _Node {
  final String tag, text;
  final List<String> items;
  List<List<String>> rows;
  _Node(this.tag, this.text, {this.items = const [], List<List<String>>? rows}) : rows = rows ?? [];
}
