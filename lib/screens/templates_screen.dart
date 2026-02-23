import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

const _templates = [
  _TemplateData(
    category: 'Negócios',
    title: 'Relatório Executivo',
    preview: 'Relatório de desempenho trimestral com análise de KPIs e resultados financeiros.',
    html: '&lt;h1&gt;Relatório Executivo&lt;/h1&gt;&lt;h2&gt;Resumo&lt;/h2&gt;&lt;p&gt;Este relatório apresenta os principais indicadores do período.&lt;/p&gt;&lt;h2&gt;Resultados&lt;/h2&gt;&lt;p&gt;Os resultados demonstram um crescimento consistente nas métricas principais.&lt;/p&gt;&lt;h2&gt;Conclusões&lt;/h2&gt;&lt;p&gt;Com base nos dados analisados, recomendamos as seguintes ações estratégicas.&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Negócios',
    title: 'Proposta Comercial',
    preview: 'Proposta de negócio profissional com secções de escopo, orçamento e cronograma.',
    html: '&lt;h1&gt;Proposta Comercial&lt;/h1&gt;&lt;p&gt;&lt;strong&gt;Data:&lt;/strong&gt; ___________&lt;/p&gt;&lt;p&gt;&lt;strong&gt;Para:&lt;/strong&gt; ___________&lt;/p&gt;&lt;h2&gt;Introdução&lt;/h2&gt;&lt;p&gt;Apresentamos esta proposta com o objetivo de atender às suas necessidades.&lt;/p&gt;&lt;h2&gt;Escopo do Projeto&lt;/h2&gt;&lt;p&gt;O projeto contempla as seguintes entregas:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;Entrega 1&lt;/li&gt;&lt;li&gt;Entrega 2&lt;/li&gt;&lt;li&gt;Entrega 3&lt;/li&gt;&lt;/ul&gt;&lt;h2&gt;Investimento&lt;/h2&gt;&lt;p&gt;Valor total: R\$ ___________&lt;/p&gt;&lt;h2&gt;Prazo&lt;/h2&gt;&lt;p&gt;Prazo estimado: ___________ semanas&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Académico',
    title: 'Ensaio Académico',
    preview: 'Estrutura padrão para ensaios com introdução, desenvolvimento e conclusão.',
    html: '&lt;h1&gt;Título do Ensaio&lt;/h1&gt;&lt;p&gt;&lt;strong&gt;Autor:&lt;/strong&gt; ___________&lt;/p&gt;&lt;p&gt;&lt;strong&gt;Data:&lt;/strong&gt; ___________&lt;/p&gt;&lt;h2&gt;Introdução&lt;/h2&gt;&lt;p&gt;A presente análise tem como objetivo explorar o tema em questão, abordando os principais aspectos que o envolvem.&lt;/p&gt;&lt;h2&gt;Desenvolvimento&lt;/h2&gt;&lt;p&gt;Com base na literatura existente, podemos identificar três perspectivas principais:&lt;/p&gt;&lt;p&gt;Em primeiro lugar, é necessário considerar...&lt;/p&gt;&lt;p&gt;Em segundo lugar, observa-se que...&lt;/p&gt;&lt;h2&gt;Conclusão&lt;/h2&gt;&lt;p&gt;Em suma, os argumentos apresentados demonstram que o tema merece atenção aprofundada.&lt;/p&gt;&lt;h2&gt;Referências&lt;/h2&gt;&lt;p&gt;1. Autor, A. (2024). &lt;em&gt;Título da obra&lt;/em&gt;. Editora.&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Académico',
    title: 'Relatório de Pesquisa',
    preview: 'Template científico com metodologia, resultados e discussão.',
    html: '&lt;h1&gt;Relatório de Pesquisa&lt;/h1&gt;&lt;h2&gt;Resumo&lt;/h2&gt;&lt;p&gt;Este estudo investigou...&lt;/p&gt;&lt;h2&gt;1. Introdução&lt;/h2&gt;&lt;p&gt;O presente trabalho tem como objetivo...&lt;/p&gt;&lt;h2&gt;2. Metodologia&lt;/h2&gt;&lt;p&gt;Para a realização desta pesquisa, foram utilizados os seguintes métodos:&lt;/p&gt;&lt;ul&gt;&lt;li&gt;Coleta de dados&lt;/li&gt;&lt;li&gt;Análise qualitativa&lt;/li&gt;&lt;li&gt;Revisão bibliográfica&lt;/li&gt;&lt;/ul&gt;&lt;h2&gt;3. Resultados&lt;/h2&gt;&lt;p&gt;Os resultados obtidos indicam que...&lt;/p&gt;&lt;h2&gt;4. Discussão&lt;/h2&gt;&lt;p&gt;Os dados apresentados corroboram a hipótese inicial de que...&lt;/p&gt;&lt;h2&gt;5. Conclusão&lt;/h2&gt;&lt;p&gt;Conclui-se que...&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Pessoal',
    title: 'Diário Pessoal',
    preview: 'Página de diário com data, humor e espaço para reflexões.',
    html: '&lt;h1&gt;Entrada do Diário&lt;/h1&gt;&lt;p&gt;&lt;strong&gt;Data:&lt;/strong&gt; ___________&lt;/p&gt;&lt;p&gt;&lt;strong&gt;Como me sinto hoje:&lt;/strong&gt; ___________&lt;/p&gt;&lt;h2&gt;O que aconteceu hoje&lt;/h2&gt;&lt;p&gt;Escreve aqui sobre o teu dia...&lt;/p&gt;&lt;h2&gt;O que aprendi&lt;/h2&gt;&lt;p&gt;Hoje aprendi que...&lt;/p&gt;&lt;h2&gt;Gratidão&lt;/h2&gt;&lt;p&gt;Hoje sou grato/a por...&lt;/p&gt;&lt;h2&gt;Amanhã&lt;/h2&gt;&lt;p&gt;Para amanhã, planejo...&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Pessoal',
    title: 'Lista de Objetivos',
    preview: 'Plano de metas pessoais com curto, médio e longo prazo.',
    html: '&lt;h1&gt;Os Meus Objetivos&lt;/h1&gt;&lt;p&gt;&lt;em&gt;Definido em: ___________&lt;/em&gt;&lt;/p&gt;&lt;h2&gt;Curto Prazo (1–3 meses)&lt;/h2&gt;&lt;ul&gt;&lt;li&gt;Objetivo 1&lt;/li&gt;&lt;li&gt;Objetivo 2&lt;/li&gt;&lt;li&gt;Objetivo 3&lt;/li&gt;&lt;/ul&gt;&lt;h2&gt;Médio Prazo (3–12 meses)&lt;/h2&gt;&lt;ul&gt;&lt;li&gt;Meta 1&lt;/li&gt;&lt;li&gt;Meta 2&lt;/li&gt;&lt;/ul&gt;&lt;h2&gt;Longo Prazo (1–5 anos)&lt;/h2&gt;&lt;ul&gt;&lt;li&gt;Visão 1&lt;/li&gt;&lt;li&gt;Visão 2&lt;/li&gt;&lt;/ul&gt;&lt;h2&gt;Por que estes objetivos importam&lt;/h2&gt;&lt;p&gt;Escreve aqui a tua motivação...&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Criativo',
    title: 'Conto Curto',
    preview: 'Estrutura narrativa clássica com personagens, conflito e resolução.',
    html: '&lt;h1&gt;Título da História&lt;/h1&gt;&lt;p&gt;&lt;em&gt;Género: ___________&lt;/em&gt;&lt;/p&gt;&lt;h2&gt;Personagens&lt;/h2&gt;&lt;p&gt;&lt;strong&gt;Protagonista:&lt;/strong&gt; ___________&lt;/p&gt;&lt;p&gt;&lt;strong&gt;Antagonista:&lt;/strong&gt; ___________&lt;/p&gt;&lt;h2&gt;Cenário&lt;/h2&gt;&lt;p&gt;A história passa-se em...&lt;/p&gt;&lt;h2&gt;Acto I — O Início&lt;/h2&gt;&lt;p&gt;Era uma vez...&lt;/p&gt;&lt;h2&gt;Acto II — O Conflito&lt;/h2&gt;&lt;p&gt;Mas então...&lt;/p&gt;&lt;h2&gt;Acto III — A Resolução&lt;/h2&gt;&lt;p&gt;No final...&lt;/p&gt;',
  ),
  _TemplateData(
    category: 'Criativo',
    title: 'Roteiro de Vídeo',
    preview: 'Script para vídeo com cenas, diálogos e direções de câmera.',
    html: '&lt;h1&gt;TÍTULO DO VÍDEO&lt;/h1&gt;&lt;p&gt;&lt;strong&gt;Duração estimada:&lt;/strong&gt; ___&lt;/p&gt;&lt;p&gt;&lt;strong&gt;Audiência:&lt;/strong&gt; ___&lt;/p&gt;&lt;h2&gt;CENA 1 — INTRODUÇÃO&lt;/h2&gt;&lt;p&gt;&lt;strong&gt;[CÂMERA: Plano geral]&lt;/strong&gt;&lt;/p&gt;&lt;p&gt;&lt;strong&gt;VOZ:&lt;/strong&gt; Bem-vindo ao nosso vídeo sobre...&lt;/p&gt;&lt;h2&gt;CENA 2 — DESENVOLVIMENTO&lt;/h2&gt;&lt;p&gt;&lt;strong&gt;[CÂMERA: Close-up]&lt;/strong&gt;&lt;/p&gt;&lt;p&gt;&lt;strong&gt;VOZ:&lt;/strong&gt; Hoje vamos explorar...&lt;/p&gt;&lt;h2&gt;CENA 3 — ENCERRAMENTO&lt;/h2&gt;&lt;p&gt;&lt;strong&gt;[CÂMERA: Plano médio]&lt;/strong&gt;&lt;/p&gt;&lt;p&gt;&lt;strong&gt;VOZ:&lt;/strong&gt; Obrigado por assistir. Não se esqueça de...&lt;/p&gt;',
  ),
];

class _TemplateData {
  final String category;
  final String title;
  final String preview;
  final String html;
  const _TemplateData({
    required this.category,
    required this.title,
    required this.preview,
    required this.html,
  });
}

const _searchSvg = '''
&lt;svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"&gt;
&lt;path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/&gt;
&lt;/svg&gt;
''';

Widget _svg(String d, Color c, {double s = 20}) =&gt; SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});
  @override
  State&lt;TemplatesScreen&gt; createState() =&gt; _TemplatesScreenState();
}

class _TemplatesScreenState extends State&lt;TemplatesScreen&gt; {
  String _filter = '';
  String? _selectedCat;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() =&gt; setState(() {});

  List&lt;_TemplateData&gt; get _filtered {
    var list = _templates.toList();
    if (_selectedCat != null) list = list.where((t) =&gt; t.category == _selectedCat).toList();
    if (_filter.isNotEmpty) {
      list = list
          .where((t) =&gt;
              t.title.toLowerCase().contains(_filter.toLowerCase()) ||
              t.preview.toLowerCase().contains(_filter.toLowerCase()))
          .toList();
    }
    return list;
  }

  List&lt;String&gt; get _categories {
    final cats = &lt;String&gt;{};
    for (final t in _templates) cats.add(t.category);
    return cats.toList();
  }

  void _openTemplate(_TemplateData tpl) async {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final tp = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final ts = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final acc = accColor(isDark);

    final ok = await showDialog&lt;bool&gt;(
      context: context,
      builder: (ctx) =&gt; AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Usar template',
            style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Criar novo documento com o template "${tpl.title}"?',
            style: GoogleFonts.syne(color: ts, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () =&gt; Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.syne(color: ts)),
          ),
          TextButton(
            onPressed: () =&gt; Navigator.pop(ctx, true),
            child: Text('Criar', style: GoogleFonts.syne(color: acc, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok == true &amp;&amp; mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =&gt; EditorScreen(
            importHtml: tpl.html,
            importTitle: tpl.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final surfBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final acc = accColor(isDark);

    final filtered = _filtered;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Container(height: 0.5, color: divColor),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            height: 44,
            decoration: BoxDecoration(
              color: surfBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: divColor),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                _svg(_searchSvg, textSec, s: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) =&gt; setState(() =&gt; _filter = v),
                    style: GoogleFonts.syne(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar templates…',
                      hintStyle: GoogleFonts.syne(color: textSec, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _CategoryChip(
                  label: 'Todos',
                  selected: _selectedCat == null,
                  acc: acc,
                  textSec: textSec,
                  onTap: () =&gt; setState(() =&gt; _selectedCat = null),
                ),
                ..._categories.map((cat) =&gt; _CategoryChip(
                  label: cat,
                  selected: _selectedCat == cat,
                  acc: acc,
                  textSec: textSec,
                  onTap: () =&gt; setState(() =&gt; _selectedCat = _selectedCat == cat ? null : cat),
                )),
              ],
            ),
          ),
          Container(height: 0.5, color: divColor),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Nenhum template encontrado',
                        style: GoogleFonts.syne(color: textSec, fontSize: 14)),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) =&gt; _TemplateCard(
                      template: filtered[i],
                      isDark: isDark,
                      acc: acc,
                      textPrimary: textPrimary,
                      textSec: textSec,
                      onTap: () =&gt; _openTemplate(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color acc;
  final Color textSec;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.acc,
    required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? acc : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? acc : textSec.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.syne(
            color: selected ? Colors.white : textSec,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final _TemplateData template;
  final bool isDark;
  final Color acc;
  final Color textPrimary;
  final Color textSec;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isDark,
    required this.acc,
    required this.textPrimary,
    required this.textSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final divColor = isDark ? AppColors.darkDivider : AppColors.divider;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: divColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 7, width: 70,
                      decoration: BoxDecoration(
                        color: acc.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(5, (i) =&gt; Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        height: 5,
                        width: i == 4 ? 50 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    )),
                    const SizedBox(height: 4),
                    Container(height: 5, width: 80,
                      decoration: BoxDecoration(color: acc.withOpacity(0.4), borderRadius: BorderRadius.circular(3))),
                    const SizedBox(height: 4),
                    ...List.generate(3, (i) =&gt; Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        height: 5,
                        width: i == 2 ? 40 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: divColor, width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: GoogleFonts.syne(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: acc.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      template.category,
                      style: GoogleFonts.syne(
                        color: acc,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}