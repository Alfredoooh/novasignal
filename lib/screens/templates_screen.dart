import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

// ─── Templates disponíveis ───────────────────────────
const _templates = [
  _TemplateData(
    category: 'Negócios',
    title: 'Relatório Executivo',
    preview: 'Relatório de desempenho trimestral com análise de KPIs e resultados financeiros.',
    html: '<h1>Relatório Executivo</h1><h2>Resumo</h2><p>Este relatório apresenta os principais indicadores do período.</p><h2>Resultados</h2><p>Os resultados demonstram um crescimento consistente nas métricas principais.</p><h2>Conclusões</h2><p>Com base nos dados analisados, recomendamos as seguintes ações estratégicas.</p>',
  ),
  _TemplateData(
    category: 'Negócios',
    title: 'Proposta Comercial',
    preview: 'Proposta de negócio profissional com secções de escopo, orçamento e cronograma.',
    html: '<h1>Proposta Comercial</h1><p><strong>Data:</strong> ___________</p><p><strong>Para:</strong> ___________</p><h2>Introdução</h2><p>Apresentamos esta proposta com o objetivo de atender às suas necessidades.</p><h2>Escopo do Projeto</h2><p>O projeto contempla as seguintes entregas:</p><ul><li>Entrega 1</li><li>Entrega 2</li><li>Entrega 3</li></ul><h2>Investimento</h2><p>Valor total: R$ ___________</p><h2>Prazo</h2><p>Prazo estimado: ___________ semanas</p>',
  ),
  _TemplateData(
    category: 'Académico',
    title: 'Ensaio Académico',
    preview: 'Estrutura padrão para ensaios com introdução, desenvolvimento e conclusão.',
    html: '<h1>Título do Ensaio</h1><p><strong>Autor:</strong> ___________</p><p><strong>Data:</strong> ___________</p><h2>Introdução</h2><p>A presente análise tem como objetivo explorar o tema em questão, abordando os principais aspectos que o envolvem.</p><h2>Desenvolvimento</h2><p>Com base na literatura existente, podemos identificar três perspectivas principais:</p><p>Em primeiro lugar, é necessário considerar...</p><p>Em segundo lugar, observa-se que...</p><h2>Conclusão</h2><p>Em suma, os argumentos apresentados demonstram que o tema merece atenção aprofundada.</p><h2>Referências</h2><p>1. Autor, A. (2024). <em>Título da obra</em>. Editora.</p>',
  ),
  _TemplateData(
    category: 'Académico',
    title: 'Relatório de Pesquisa',
    preview: 'Template científico com metodologia, resultados e discussão.',
    html: '<h1>Relatório de Pesquisa</h1><h2>Resumo</h2><p>Este estudo investigou...</p><h2>1. Introdução</h2><p>O presente trabalho tem como objetivo...</p><h2>2. Metodologia</h2><p>Para a realização desta pesquisa, foram utilizados os seguintes métodos:</p><ul><li>Coleta de dados</li><li>Análise qualitativa</li><li>Revisão bibliográfica</li></ul><h2>3. Resultados</h2><p>Os resultados obtidos indicam que...</p><h2>4. Discussão</h2><p>Os dados apresentados corroboram a hipótese inicial de que...</p><h2>5. Conclusão</h2><p>Conclui-se que...</p>',
  ),
  _TemplateData(
    category: 'Pessoal',
    title: 'Diário Pessoal',
    preview: 'Página de diário com data, humor e espaço para reflexões.',
    html: '<h1>Entrada do Diário</h1><p><strong>Data:</strong> ___________</p><p><strong>Como me sinto hoje:</strong> ___________</p><h2>O que aconteceu hoje</h2><p>Escreve aqui sobre o teu dia...</p><h2>O que aprendi</h2><p>Hoje aprendi que...</p><h2>Gratidão</h2><p>Hoje sou grato/a por...</p><h2>Amanhã</h2><p>Para amanhã, planejo...</p>',
  ),
  _TemplateData(
    category: 'Pessoal',
    title: 'Lista de Objetivos',
    preview: 'Plano de metas pessoais com curto, médio e longo prazo.',
    html: '<h1>Os Meus Objetivos</h1><p><em>Definido em: ___________</em></p><h2>Curto Prazo (1–3 meses)</h2><ul><li>Objetivo 1</li><li>Objetivo 2</li><li>Objetivo 3</li></ul><h2>Médio Prazo (3–12 meses)</h2><ul><li>Meta 1</li><li>Meta 2</li></ul><h2>Longo Prazo (1–5 anos)</h2><ul><li>Visão 1</li><li>Visão 2</li></ul><h2>Por que estes objetivos importam</h2><p>Escreve aqui a tua motivação...</p>',
  ),
  _TemplateData(
    category: 'Criativo',
    title: 'Conto Curto',
    preview: 'Estrutura narrativa clássica com personagens, conflito e resolução.',
    html: '<h1>Título da História</h1><p><em>Género: ___________</em></p><h2>Personagens</h2><p><strong>Protagonista:</strong> ___________</p><p><strong>Antagonista:</strong> ___________</p><h2>Cenário</h2><p>A história passa-se em...</p><h2>Acto I — O Início</h2><p>Era uma vez...</p><h2>Acto II — O Conflito</h2><p>Mas então...</p><h2>Acto III — A Resolução</h2><p>No final...</p>',
  ),
  _TemplateData(
    category: 'Criativo',
    title: 'Roteiro de Vídeo',
    preview: 'Script para vídeo com cenas, diálogos e direções de câmera.',
    html: '<h1>TÍTULO DO VÍDEO</h1><p><strong>Duração estimada:</strong> ___</p><p><strong>Audiência:</strong> ___</p><h2>CENA 1 — INTRODUÇÃO</h2><p><strong>[CÂMERA: Plano geral]</strong></p><p><strong>VOZ:</strong> Bem-vindo ao nosso vídeo sobre...</p><h2>CENA 2 — DESENVOLVIMENTO</h2><p><strong>[CÂMERA: Close-up]</strong></p><p><strong>VOZ:</strong> Hoje vamos explorar...</p><h2>CENA 3 — ENCERRAMENTO</h2><p><strong>[CÂMERA: Plano médio]</strong></p><p><strong>VOZ:</strong> Obrigado por assistir. Não se esqueça de...</p>',
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

// ─── SVG helpers ─────────────────────────────────────
const _searchSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/>
</svg>
''';

Widget _svg(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ─── Screen ──────────────────────────────────────────
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});
  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
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

  void _onTheme() => setState(() {});

  List<_TemplateData> get _filtered {
    var list = _templates.toList();
    if (_selectedCat != null) list = list.where((t) => t.category == _selectedCat).toList();
    if (_filter.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_filter.toLowerCase()) ||
              t.preview.toLowerCase().contains(_filter.toLowerCase()))
          .toList();
    }
    return list;
  }

  List<String> get _categories {
    final cats = <String>{};
    for (final t in _templates) cats.add(t.category);
    return cats.toList();
  }

  void _openTemplate(_TemplateData tpl) async {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;
    final tp = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final ts = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final acc = accColor(isDark);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Usar template',
            style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Criar novo documento com o template "${tpl.title}"?',
            style: GoogleFonts.syne(color: ts, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.syne(color: ts)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Criar', style: GoogleFonts.syne(color: acc, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(
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
          // Search bar
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
                    onChanged: (v) => setState(() => _filter = v),
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
          // Category chips
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
                  onTap: () => setState(() => _selectedCat = null),
                ),
                ..._categories.map((cat) => _CategoryChip(
                  label: cat,
                  selected: _selectedCat == cat,
                  acc: acc,
                  textSec: textSec,
                  onTap: () => setState(() => _selectedCat = _selectedCat == cat ? null : cat),
                )),
              ],
            ),
          ),
          Container(height: 0.5, color: divColor),
          // Template grid
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
                    itemBuilder: (ctx, i) => _TemplateCard(
                      template: filtered[i],
                      isDark: isDark,
                      acc: acc,
                      textPrimary: textPrimary,
                      textSec: textSec,
                      onTap: () => _openTemplate(filtered[i]),
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
            // Paper preview
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
                    ...List.generate(5, (i) => Padding(
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
                    ...List.generate(3, (i) => Padding(
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
            // Info
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
