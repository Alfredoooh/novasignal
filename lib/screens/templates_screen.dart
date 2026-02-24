import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import '../models/document.dart';

// ─── Design tokens ───────────────────────────────────
const _kPill  = 999.0;
const _kCard  = 18.0;
const _kModal = 20.0;

// ─── Templates ────────────────────────────────────────
class _Tpl {
  final String category, title, preview;
  final String html;
  final IconData icon;
  final Color color;
  const _Tpl({required this.category, required this.title, required this.preview, required this.html, required this.icon, required this.color});
}

const _kTemplates = <_Tpl>[
  // ── Negócios ──────────────────────────────────────
  _Tpl(
    category: 'Negócios', title: 'Relatório Executivo', icon: Icons.bar_chart_rounded, color: Color(0xFF2563EB),
    preview: 'Relatório trimestral com KPIs, resultados financeiros e análise estratégica.',
    html: '''<h1>Relatório Executivo</h1>
<p><strong>Período:</strong> ___________&nbsp;&nbsp;<strong>Prepared by:</strong> ___________</p>
<hr/>
<h2>Resumo Executivo</h2>
<p>Este relatório apresenta os principais indicadores de desempenho do período, consolidando resultados financeiros, operacionais e estratégicos.</p>
<blockquote><strong>Insight chave:</strong> Crescimento de 12% na receita em relação ao trimestre anterior.</blockquote>

<h2>1. Resultados Financeiros</h2>
<p>Os resultados demonstram um crescimento consistente nas métricas principais:</p>
<ul>
<li><strong>Receita total:</strong> R\$ ___________</li>
<li><strong>Lucro bruto:</strong> R\$ ___________</li>
<li><strong>Margem líquida:</strong> ___%</li>
<li><strong>Custo operacional:</strong> R\$ ___________</li>
</ul>

<h2>2. KPIs Operacionais</h2>
<table>
<tr><th>Indicador</th><th>Meta</th><th>Realizado</th><th>Variação</th></tr>
<tr><td>Vendas</td><td>___</td><td>___</td><td>+__%</td></tr>
<tr><td>NPS</td><td>___</td><td>___</td><td>+___</td></tr>
<tr><td>Churn</td><td>___%</td><td>___%</td><td>-__%</td></tr>
</table>

<h2>3. Destaques do Período</h2>
<p>Principais conquistas e eventos relevantes:</p>
<ul>
<li>Lançamento de novo produto/serviço em ___________</li>
<li>Expansão para mercado de ___________</li>
<li>Parceria estratégica com ___________</li>
</ul>

<h2>4. Riscos e Desafios</h2>
<p>Pontos de atenção identificados:</p>
<ul>
<li><strong>Risco 1:</strong> Descrever risco e mitigação proposta.</li>
<li><strong>Risco 2:</strong> Descrever risco e mitigação proposta.</li>
</ul>

<h2>5. Próximos Passos</h2>
<ol>
<li>Definir proprietário do projeto</li>
<li>Validar cronograma com stakeholders</li>
<li>Executar prova de conceito até ___________</li>
</ol>

<h2>Conclusão</h2>
<p>Com base nos dados analisados, recomendamos as seguintes ações estratégicas para o próximo período. A equipa está alinhada para atingir as metas estabelecidas.</p>''',
  ),

  _Tpl(
    category: 'Negócios', title: 'Proposta Comercial', icon: Icons.handshake_outlined, color: Color(0xFF16A34A),
    preview: 'Proposta profissional com escopo, investimento, cronograma e termos.',
    html: '''<h1>Proposta Comercial</h1>
<p><strong>Data:</strong> ___________&nbsp;&nbsp;<strong>Validade:</strong> 30 dias</p>
<p><strong>Para:</strong> ___________&nbsp;&nbsp;<strong>De:</strong> ___________</p>
<hr/>

<h2>Introdução</h2>
<p>Apresentamos esta proposta com o objetivo de atender às necessidades de <strong>___________</strong>, oferecendo uma solução completa e adaptada ao seu contexto.</p>

<h2>Entendimento do Problema</h2>
<p>Com base nas conversas realizadas, entendemos que o principal desafio é:</p>
<blockquote>Descreva aqui o problema central que a proposta resolve.</blockquote>

<h2>Solução Proposta</h2>
<p>Propomos uma abordagem em três fases:</p>
<ol>
<li><strong>Fase 1 — Diagnóstico:</strong> Análise detalhada do contexto atual. Duração: ___ semanas.</li>
<li><strong>Fase 2 — Implementação:</strong> Execução e entrega das soluções definidas. Duração: ___ semanas.</li>
<li><strong>Fase 3 — Acompanhamento:</strong> Suporte e ajustes pós-entrega. Duração: ___ semanas.</li>
</ol>

<h2>Escopo de Entrega</h2>
<p>O projeto contempla as seguintes entregas:</p>
<ul>
<li>Entrega 1 — Descrição detalhada</li>
<li>Entrega 2 — Descrição detalhada</li>
<li>Entrega 3 — Descrição detalhada</li>
</ul>
<p><strong>Fora do escopo:</strong> ___________</p>

<h2>Investimento</h2>
<table>
<tr><th>Serviço / Item</th><th>Qtd.</th><th>Valor Unit.</th><th>Total</th></tr>
<tr><td>Fase 1 — Diagnóstico</td><td>1</td><td>R\$ ___</td><td>R\$ ___</td></tr>
<tr><td>Fase 2 — Implementação</td><td>1</td><td>R\$ ___</td><td>R\$ ___</td></tr>
<tr><td>Fase 3 — Acompanhamento</td><td>1</td><td>R\$ ___</td><td>R\$ ___</td></tr>
<tr><td><strong>Total</strong></td><td></td><td></td><td><strong>R\$ ___________</strong></td></tr>
</table>
<p><em>Formas de pagamento: ___________</em></p>

<h2>Prazo e Cronograma</h2>
<p>Início estimado: ___________&nbsp;&nbsp;Entrega final: ___________</p>

<h2>Termos e Condições</h2>
<p>Esta proposta é válida por 30 dias. Os valores e condições apresentados podem ser revistos após este período.</p>

<h2>Próximos Passos</h2>
<ol>
<li>Aprovação da proposta pelo cliente</li>
<li>Assinatura do contrato</li>
<li>Pagamento da primeira parcela</li>
<li>Início dos trabalhos em ___________</li>
</ol>''',
  ),

  _Tpl(
    category: 'Negócios', title: 'Acta de Reunião', icon: Icons.people_outline_rounded, color: Color(0xFF9333EA),
    preview: 'Registo estruturado de reunião com participantes, decisões e tarefas.',
    html: '''<h1>Acta de Reunião</h1>
<p><strong>Data:</strong> ___________&nbsp;&nbsp;<strong>Hora:</strong> ___________</p>
<p><strong>Local / Plataforma:</strong> ___________</p>
<p><strong>Moderador:</strong> ___________&nbsp;&nbsp;<strong>Secretário:</strong> ___________</p>
<hr/>

<h2>Participantes</h2>
<ul>
<li>___________ — Função/Departamento</li>
<li>___________ — Função/Departamento</li>
<li>___________ — Função/Departamento</li>
</ul>

<h2>Ordem de Trabalhos</h2>
<ol>
<li>Ponto 1 — ___________</li>
<li>Ponto 2 — ___________</li>
<li>Ponto 3 — ___________</li>
</ol>

<h2>Desenvolvimento</h2>

<h3>1. Ponto 1 — ___________</h3>
<p>Resumo da discussão. Quem falou, o que foi apresentado, questões levantadas.</p>
<blockquote>Observação relevante ou citação importante da reunião.</blockquote>

<h3>2. Ponto 2 — ___________</h3>
<p>Resumo da discussão.</p>

<h3>3. Ponto 3 — ___________</h3>
<p>Resumo da discussão.</p>

<h2>Decisões Tomadas</h2>
<ul>
<li>✅ Decisão 1: ___________</li>
<li>✅ Decisão 2: ___________</li>
<li>✅ Decisão 3: ___________</li>
</ul>

<h2>Tarefas e Responsáveis</h2>
<table>
<tr><th>Tarefa</th><th>Responsável</th><th>Prazo</th></tr>
<tr><td>Tarefa 1</td><td>___________</td><td>___________</td></tr>
<tr><td>Tarefa 2</td><td>___________</td><td>___________</td></tr>
<tr><td>Tarefa 3</td><td>___________</td><td>___________</td></tr>
</table>

<h2>Próxima Reunião</h2>
<p><strong>Data:</strong> ___________&nbsp;&nbsp;<strong>Hora:</strong> ___________</p>
<p><strong>Pauta prevista:</strong> ___________</p>''',
  ),

  // ── CV / Perfil ───────────────────────────────────
  _Tpl(
    category: 'CV & Perfil', title: 'Currículo Profissional', icon: Icons.person_outline_rounded, color: Color(0xFF0F62FE),
    preview: 'CV completo com experiência, competências, educação e projetos.',
    html: '''<h1>Nome Completo</h1>
<p><em>Cargo / Especialidade — Localidade</em></p>
<p>📧 email@exemplo.com&nbsp;&nbsp;📞 +244 9XX XXX XXX&nbsp;&nbsp;🌐 www.exemplo.com</p>
<hr/>

<h2>Resumo Profissional</h2>
<p>Profissional com mais de ___ anos de experiência em ___________. Forte background em ___________, com foco em resultados mensuráveis e trabalho em equipa. Apaixonado por soluções que conectam tecnologia e impacto real ao utilizador.</p>

<h2>Experiência Profissional</h2>

<h3>Cargo Atual — Empresa Atual</h3>
<p><em>Jan 2022 — Atualmente · Luanda, Angola · Remoto</em></p>
<ul>
<li>Descrição de responsabilidade com resultado mensurável — ex.: reduzi tempo de entrega em 30%.</li>
<li>Descrição de responsabilidade com resultado mensurável.</li>
<li>Descrição de responsabilidade com resultado mensurável.</li>
</ul>

<h3>Cargo Anterior — Empresa Anterior</h3>
<p><em>Mar 2019 — Dez 2021 · Luanda, Angola</em></p>
<ul>
<li>Descrição de responsabilidade com resultado mensurável.</li>
<li>Descrição de responsabilidade com resultado mensurável.</li>
</ul>

<h2>Educação</h2>
<h3>Licenciatura em ___________ — Universidade ___________</h3>
<p><em>2015 — 2018</em></p>
<p>Tese: Título da tese ou projeto final.</p>

<h2>Competências Técnicas</h2>
<ul>
<li><strong>Linguagens:</strong> JavaScript, Python, Dart, TypeScript</li>
<li><strong>Frameworks:</strong> React, Flutter, Node.js, FastAPI</li>
<li><strong>Ferramentas:</strong> Figma, Git, Docker, Firebase</li>
<li><strong>Idiomas:</strong> Português (Nativo), Inglês (Fluente), Espanhol (Interm.)</li>
</ul>

<h2>Projetos em Destaque</h2>
<h3>Nome do Projeto</h3>
<p><em>GitHub · 2023</em></p>
<p>Breve descrição do projeto, tecnologias utilizadas e impacto gerado.</p>

<h2>Certificações</h2>
<ul>
<li>Certificação X — Plataforma Y — 2023</li>
<li>Certificação Z — Plataforma W — 2022</li>
</ul>

<h2>Referências</h2>
<p>Disponíveis mediante solicitação.</p>''',
  ),

  _Tpl(
    category: 'CV & Perfil', title: 'Carta de Apresentação', icon: Icons.mail_outline_rounded, color: Color(0xFFEA580C),
    preview: 'Carta de candidatura profissional com introdução, motivação e fechamento.',
    html: '''<p><strong>Nome Completo</strong></p>
<p>email@exemplo.com · +244 9XX XXX XXX · Localidade</p>
<p>___________  (data)</p>
<hr/>

<p><strong>A atenção de:</strong></p>
<p>Nome do Responsável / Recursos Humanos<br/>
Nome da Empresa<br/>
Endereço da Empresa</p>

<p>Exm.ª(o) Sr.ª(o) ___________,</p>

<h2>Abertura — Porquê esta empresa?</h2>
<p>Escrevo com entusiasmo para candidatar-me à vaga de <strong>___________</strong> na <strong>___________</strong>. Acompanho o trabalho da vossa equipa há algum tempo e admiro profundamente como a empresa aborda ___________ — uma área pela qual tenho grande paixão.</p>

<h2>O Que Trago</h2>
<p>Ao longo dos últimos ___ anos, desenvolvi competências sólidas em ___________, com resultados concretos:</p>
<ul>
<li>Resultado 1 — descrição com impacto mensurável.</li>
<li>Resultado 2 — descrição com impacto mensurável.</li>
<li>Resultado 3 — descrição com impacto mensurável.</li>
</ul>
<p>Estou convicto(a) de que esta experiência me permite contribuir diretamente para ___________.</p>

<h2>Alinhamento Cultural</h2>
<p>Além das competências técnicas, valorizo ___________ — valores que percebo serem centrais na cultura da ___________. Acredito que ambientes colaborativos e orientados a resultados são onde me realizo melhor.</p>

<h2>Encerramento</h2>
<p>Fico ao dispor para uma conversa e agradeço desde já a atenção dispensada. Em anexo encontra o meu currículo para referência adicional.</p>

<p>Com os melhores cumprimentos,</p>
<p><strong>Nome Completo</strong></p>''',
  ),

  // ── Académico ─────────────────────────────────────
  _Tpl(
    category: 'Académico', title: 'Ensaio Académico', icon: Icons.school_outlined, color: Color(0xFF2563EB),
    preview: 'Estrutura ABNT/APA com introdução, desenvolvimento, conclusão e referências.',
    html: '''<h1>Título do Ensaio Académico</h1>
<p><strong>Autor(a):</strong> ___________</p>
<p><strong>Instituição:</strong> ___________</p>
<p><strong>Disciplina/Curso:</strong> ___________</p>
<p><strong>Professor(a):</strong> ___________</p>
<p><strong>Data:</strong> ___________</p>
<hr/>

<h2>Resumo</h2>
<p>Este trabalho analisa ___________. O objectivo central é ___________. A metodologia empregada baseia-se em ___________, e as principais conclusões indicam que ___________.</p>
<p><strong>Palavras-chave:</strong> palavra1, palavra2, palavra3, palavra4.</p>

<h2>1. Introdução</h2>
<p>A presente análise tem como objectivo explorar o tema <em>___________</em>, abordando os seus principais aspectos sob a perspectiva de ___________. A relevância desta temática justifica-se pelo facto de ___________.</p>
<p>O trabalho está estruturado em ___ partes: (i) fundamentação teórica; (ii) análise e discussão; (iii) conclusão.</p>

<h2>2. Fundamentação Teórica</h2>
<p>Com base na literatura existente, é possível identificar três perspectivas principais:</p>
<p>Em primeiro lugar, ___________ (Autor, ano) argumenta que ___________. Em segundo lugar, ___________ (Autor, ano) propõe que ___________. Em terceiro lugar, uma visão alternativa é apresentada por ___________ (Autor, ano), que defende ___________.</p>
<blockquote>Citação directa relevante: "___________" (Autor, ano, p. __).</blockquote>

<h2>3. Análise e Discussão</h2>
<p>A análise dos dados/argumentos revela que ___________. Este resultado está em consonância com as ideias de ___________ (Autor, ano), embora divirja em alguns aspectos da perspectiva de ___________ (Autor, ano).</p>
<p>Um aspecto particularmente relevante é ___________. Por outro lado, é importante considerar que ___________.</p>

<h2>4. Conclusão</h2>
<p>Em suma, os argumentos apresentados demonstram que ___________. As evidências analisadas confirmam que ___________. Como implicação prática, sugere-se que ___________.</p>
<p>Este trabalho apresenta algumas limitações, nomeadamente ___________. Investigações futuras poderiam explorar ___________.</p>

<h2>Referências Bibliográficas</h2>
<p>Autor, A. B. (2024). <em>Título da obra completa</em>. Editora.</p>
<p>Autor, C. D., &amp; Autor, E. F. (2023). Título do artigo. <em>Nome da Revista</em>, <em>10</em>(2), 45–67. https://doi.org/xxxxx</p>
<p>Autor, G. H. (2022). <em>Título do capítulo</em>. In A. B. Organiz. (Ed.), <em>Título do livro</em> (pp. 100–130). Editora.</p>''',
  ),

  _Tpl(
    category: 'Académico', title: 'Relatório de Pesquisa', icon: Icons.science_outlined, color: Color(0xFF16A34A),
    preview: 'Artigo científico com metodologia, resultados, discussão e referências.',
    html: '''<h1>Título da Pesquisa</h1>
<p><em>Subtítulo descritivo (opcional)</em></p>
<p><strong>Autores:</strong> ___________</p>
<p><strong>Instituição:</strong> ___________</p>
<p><strong>Data de submissão:</strong> ___________</p>
<hr/>

<h2>Abstract / Resumo</h2>
<p>Este estudo investigou ___________. A metodologia empregada foi ___________. Os resultados indicam que ___________. Conclui-se que ___________.</p>
<p><strong>Keywords:</strong> keyword1, keyword2, keyword3.</p>

<h2>1. Introdução</h2>
<p>O presente trabalho tem como objectivo ___________. A relevância desta pesquisa reside em ___________. A hipótese central é que ___________.</p>
<p>A estrutura do artigo é a seguinte: a Secção 2 descreve a metodologia; a Secção 3 apresenta os resultados; a Secção 4 discute as implicações; a Secção 5 conclui.</p>

<h2>2. Revisão de Literatura</h2>
<p>A literatura existente sobre ___________ pode ser agrupada em duas vertentes principais. A primeira, representada por ___________ (Autor, ano), defende que ___________. A segunda, proposta por ___________ (Autor, ano), argumenta que ___________.</p>

<h2>3. Metodologia</h2>
<p>Para a realização desta pesquisa, foram utilizados os seguintes métodos:</p>
<ul>
<li><strong>Abordagem:</strong> Qualitativa / Quantitativa / Mista</li>
<li><strong>Amostra:</strong> Descrição da amostra e critérios de seleção.</li>
<li><strong>Instrumentos:</strong> Questionários, entrevistas, análise documental, etc.</li>
<li><strong>Análise:</strong> Software/técnica utilizada (SPSS, NVivo, etc.)</li>
</ul>

<h2>4. Resultados</h2>
<p>Os resultados obtidos indicam que ___________. Em particular, observou-se que ___________.</p>
<table>
<tr><th>Variável</th><th>Resultado</th><th>Significância (p)</th></tr>
<tr><td>Variável A</td><td>___</td><td>p &lt; 0.05</td></tr>
<tr><td>Variável B</td><td>___</td><td>p &lt; 0.01</td></tr>
</table>

<h2>5. Discussão</h2>
<p>Os dados apresentados corroboram a hipótese inicial de que ___________. Este resultado está alinhado com os achados de ___________ (Autor, ano), que encontraram ___________. Em contrapartida, difere da perspectiva de ___________ (Autor, ano).</p>

<h2>6. Conclusão</h2>
<p>Conclui-se que ___________. As principais contribuições deste estudo são: (1) ___________; (2) ___________; (3) ___________.</p>
<p><strong>Limitações:</strong> ___________. <strong>Pesquisas futuras:</strong> ___________.</p>

<h2>Referências</h2>
<p>Autor, A. (2024). <em>Título</em>. Editora.</p>
<p>Autor, B., &amp; Autor, C. (2023). Título do artigo. <em>Journal Name</em>, <em>15</em>(3), 112–130.</p>''',
  ),

  // ── Pessoal ───────────────────────────────────────
  _Tpl(
    category: 'Pessoal', title: 'Diário / Reflexão', icon: Icons.edit_note_rounded, color: Color(0xFFEA580C),
    preview: 'Página de diário guiado com humor, gratidão, aprendizagens e intenções.',
    html: '''<h1>Entrada do Diário</h1>
<p><strong>Data:</strong> ___________&nbsp;&nbsp;<strong>Hora:</strong> ___________</p>
<p><strong>Humor:</strong> 😊 Feliz &nbsp; 😌 Tranquilo &nbsp; 😔 Triste &nbsp; 😤 Stressado &nbsp; 🤔 Pensativo</p>
<p><strong>Energia:</strong> ⚡⚡⚡⚡⚡ (1–5)</p>
<hr/>

<h2>O que aconteceu hoje</h2>
<p>Descreve os eventos mais marcantes do dia — trabalho, relações, situações inesperadas...</p>

<h2>Como me senti</h2>
<p>O que as emoções de hoje tentaram comunicar-te? O que estava por baixo do que sentiste?</p>

<h2>O que aprendi hoje</h2>
<p>Pode ser uma lição pequena, uma nova perspectiva ou algo que viste de forma diferente...</p>
<ul>
<li></li>
<li></li>
</ul>

<h2>3 coisas pelas quais sou grato/a hoje</h2>
<ol>
<li></li>
<li></li>
<li></li>
</ol>

<h2>Desafio do dia</h2>
<p>Qual foi o momento mais difícil? Como reagiste? Como poderias reagir diferente da próxima vez?</p>

<h2>Para amanhã</h2>
<p>A <strong>única coisa mais importante</strong> que quero fazer amanhã: ___________</p>
<p>Intenção do dia: ___________</p>

<h2>Frase / Pensamento do dia</h2>
<blockquote>Escreve aqui uma citação que te inspirou, ou um pensamento teu que queres guardar.</blockquote>''',
  ),

  _Tpl(
    category: 'Pessoal', title: 'Plano de Objetivos', icon: Icons.flag_outlined, color: Color(0xFF16A34A),
    preview: 'Sistema de metas SMART com curto, médio e longo prazo e plano de ação.',
    html: '''<h1>Os Meus Objetivos</h1>
<p><em>Definido em: ___________&nbsp;&nbsp;Revisão: ___________</em></p>
<hr/>

<h2>A minha visão de vida (5–10 anos)</h2>
<blockquote>Quem quero ser? Como quero viver? O que quero ter construído? Escreve em presente, como se já fosse realidade.</blockquote>

<h2>Curto Prazo — 1 a 3 meses</h2>
<h3>Objetivo 1</h3>
<p><strong>O quê:</strong> ___________</p>
<p><strong>Por quê importa:</strong> ___________</p>
<p><strong>Como vou medir:</strong> ___________</p>
<p><strong>Prazo:</strong> ___________</p>
<p><strong>Próxima ação (esta semana):</strong> ___________</p>

<h3>Objetivo 2</h3>
<p><strong>O quê:</strong> ___________</p>
<p><strong>Por quê importa:</strong> ___________</p>
<p><strong>Próxima ação:</strong> ___________</p>

<h2>Médio Prazo — 3 a 12 meses</h2>
<ul>
<li><strong>Meta 1:</strong> ___________ — Prazo: ___________</li>
<li><strong>Meta 2:</strong> ___________ — Prazo: ___________</li>
<li><strong>Meta 3:</strong> ___________ — Prazo: ___________</li>
</ul>

<h2>Longo Prazo — 1 a 5 anos</h2>
<ul>
<li><strong>Visão 1:</strong> ___________</li>
<li><strong>Visão 2:</strong> ___________</li>
<li><strong>Visão 3:</strong> ___________</li>
</ul>

<h2>Áreas de vida</h2>
<table>
<tr><th>Área</th><th>Satisfação atual (0–10)</th><th>Onde quero chegar</th></tr>
<tr><td>Saúde &amp; Bem-estar</td><td></td><td></td></tr>
<tr><td>Carreira &amp; Finanças</td><td></td><td></td></tr>
<tr><td>Relações</td><td></td><td></td></tr>
<tr><td>Crescimento pessoal</td><td></td><td></td></tr>
<tr><td>Lazer &amp; Criatividade</td><td></td><td></td></tr>
</table>

<h2>Hábitos para suportar os objetivos</h2>
<ul>
<li>Hábito 1 — diário/semanal</li>
<li>Hábito 2 — diário/semanal</li>
<li>Hábito 3 — diário/semanal</li>
</ul>''',
  ),

  // ── Criativo ──────────────────────────────────────
  _Tpl(
    category: 'Criativo', title: 'Conto / Narrativa', icon: Icons.auto_stories_outlined, color: Color(0xFFDC2626),
    preview: 'Estrutura narrativa com ficha de personagens, cenário, conflito e arcos.',
    html: '''<h1>Título da História</h1>
<p><em>Género: ___________&nbsp;&nbsp;Público-alvo: ___________&nbsp;&nbsp;Tom: ___________</em></p>
<hr/>

<h2>Sinopse</h2>
<p>Em 2–3 frases, descreve o que acontece na história e o que está em jogo.</p>

<h2>Personagens Principais</h2>
<h3>Protagonista</h3>
<p><strong>Nome:</strong> ___________&nbsp;&nbsp;<strong>Idade:</strong> ___________</p>
<p><strong>Desejo central:</strong> O que quer desesperadamente?</p>
<p><strong>Medo central:</strong> O que mais teme?</p>
<p><strong>Arco de transformação:</strong> Quem é no início → Quem se torna no final.</p>

<h3>Antagonista / Obstáculo</h3>
<p><strong>Nome:</strong> ___________</p>
<p><strong>Motivação:</strong> Por que faz o que faz? (O antagonista acredita que está certo.)</p>

<h2>Mundo e Cenário</h2>
<p><strong>Época:</strong> ___________&nbsp;&nbsp;<strong>Local:</strong> ___________</p>
<p>Descreve o ambiente, as regras do mundo e o que o torna único.</p>

<h2>Acto I — O Mundo Ordinário e Gancho</h2>
<p>Apresenta o protagonista no seu mundo habitual. Qual é o evento que quebra a normalidade?</p>
<blockquote>Cena de abertura — a primeira linha que vai prender o leitor.</blockquote>

<h2>Acto II — O Conflito Central</h2>
<p>O protagonista tenta atingir o seu objectivo mas enfrenta obstáculos crescentes:</p>
<ul>
<li>Obstáculo 1: ___________</li>
<li>Ponto de virada: ___________</li>
<li>Crise (tudo parece perdido): ___________</li>
</ul>

<h2>Acto III — Clímax e Resolução</h2>
<p>Como o protagonista resolve (ou não) o conflito? O que muda nele/a?</p>
<p><strong>Última linha:</strong> ___________</p>

<h2>Temas e Mensagem</h2>
<p>Qual é a verdade profunda que esta história quer comunicar?</p>''',
  ),

  _Tpl(
    category: 'Criativo', title: 'Roteiro de Vídeo / Podcast', icon: Icons.videocam_outlined, color: Color(0xFF9333EA),
    preview: 'Script profissional com cenas, diálogos, chamadas à ação e notas de produção.',
    html: '''<h1>TÍTULO DO VÍDEO / EPISÓDIO</h1>
<p><strong>Duração estimada:</strong> ___&nbsp;&nbsp;<strong>Plataforma:</strong> ___________&nbsp;&nbsp;<strong>Formato:</strong> ___________</p>
<p><strong>Audiência-alvo:</strong> ___________</p>
<p><strong>Objetivo do conteúdo:</strong> O que o espectador vai aprender/sentir/fazer após ver?</p>
<hr/>

<h2>GANCHO — 0:00 a 0:30</h2>
<p><strong>[CÂMERA: Close-up | Corte direto | B-roll]</strong></p>
<p><strong>VOZ / NARRAÇÃO:</strong><br/>
"Pergunta provocadora ou afirmação surpreendente que prende o espectador nos primeiros segundos..."</p>
<p><strong>[NOTA DE PRODUÇÃO:</strong> Música de intro. Mostrar thumbnail animada.]</p>

<h2>INTRODUÇÃO — 0:30 a 1:30</h2>
<p><strong>[CÂMERA: Plano médio]</strong></p>
<p><strong>VOZ:</strong><br/>
"Hoje vamos falar sobre ___________. No final deste vídeo, vais saber exactamente como ___________."</p>
<p><strong>[NOTA:</strong> Mostrar sumário gráfico com os 3 pontos principais.]</p>

<h2>PONTO 1 — ___________</h2>
<p><em>Duração estimada: ___</em></p>
<p><strong>[CÂMERA: Plano médio + B-roll]</strong></p>
<p><strong>VOZ:</strong><br/>
Conteúdo do ponto 1. Explica o conceito, dá exemplos, usa analogias.</p>
<p><strong>[NOTA:</strong> Inserir gráfico / animação explicativa.]</p>

<h2>PONTO 2 — ___________</h2>
<p><em>Duração estimada: ___</em></p>
<p><strong>VOZ:</strong><br/>
Conteúdo do ponto 2.</p>

<h2>PONTO 3 — ___________</h2>
<p><em>Duração estimada: ___</em></p>
<p><strong>VOZ:</strong><br/>
Conteúdo do ponto 3.</p>

<h2>ENCERRAMENTO E CTA</h2>
<p><strong>[CÂMERA: Plano médio com chamada à ação visual]</strong></p>
<p><strong>VOZ:</strong><br/>
"Em resumo, vimos que ___________. Se este vídeo foi útil, deixa um like e subscreve para mais conteúdo sobre ___________. Comenta abaixo: ___________?"</p>
<p><strong>[NOTA:</strong> End screen 20 segundos. Mostrar vídeos sugeridos.]</p>

<h2>NOTAS DE PRODUÇÃO</h2>
<ul>
<li>Thumbnail: ___________</li>
<li>Descrição SEO: ___________</li>
<li>Tags: ___________</li>
<li>Equipamento: ___________</li>
</ul>''',
  ),
];

// ─── Custom Dialog ────────────────────────────────────
Future<bool?> _ariaDialog(BuildContext ctx, {
  required String title,
  required String body,
  required String confirmLabel,
  Color confirmColor = const Color(0xFFE0185E),
}) => showDialog<bool>(
  context: ctx,
  barrierColor: Colors.black54,
  builder: (_) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final tp = isDark ? Colors.white : Colors.black;
    final ts = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24,24,24,16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(_kCard)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(body, style: GoogleFonts.roboto(color: ts, fontSize: 14)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx, false),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: ts.withOpacity(.3)), borderRadius: BorderRadius.circular(_kPill)),
                child: Text('Cancelar', style: GoogleFonts.roboto(color: ts, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => Navigator.pop(ctx, true),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: confirmColor, borderRadius: BorderRadius.circular(_kPill)),
                child: Text(confirmLabel, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ]),
        ]),
      ),
    );
  },
);

// ─── SVG helpers ──────────────────────────────────────
const _backSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';
const _searchSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ─── Screen ───────────────────────────────────────────
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
  void dispose() { themeNotifier.removeListener(_onTheme); super.dispose(); }
  void _onTheme() => setState(() {});

  List<_Tpl> get _filtered {
    var list = _kTemplates.toList();
    if (_cat != null) list = list.where((t) => t.category == _cat).toList();
    if (_filter.isNotEmpty) {
      list = list.where((t) =>
          t.title.toLowerCase().contains(_filter.toLowerCase()) ||
          t.preview.toLowerCase().contains(_filter.toLowerCase())).toList();
    }
    return list;
  }

  List<String> get _categories => _kTemplates.map((t) => t.category).toSet().toList();

  void _open(_Tpl tpl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(
      docType: DocType.document,
      importHtml: tpl.html,
      importTitle: tpl.title,
    )));
  }

  void _showPreview(_Tpl tpl) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? const Color(0xFF1E1E1E) : Colors.white;
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
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal)),
          ),
          child: Column(children: [
            // Handle
            Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
              child: Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
            // Header
            Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: tpl.color.withOpacity(.13), shape: BoxShape.circle),
                  child: Icon(tpl.icon, color: tpl.color, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tpl.title, style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text(tpl.category, style: GoogleFonts.roboto(color: tpl.color, fontSize: 11, fontWeight: FontWeight.w700)),
                ])),
              ])),
            Padding(padding: const EdgeInsets.fromLTRB(20,12,20,0),
              child: Text(tpl.preview, style: GoogleFonts.roboto(color: ts, fontSize: 14, height: 1.5))),
            const SizedBox(height: 20),
            // Separador
            Container(height: 0.5, color: div),
            // Estrutura do template
            Expanded(child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20,16,20,100),
              children: [
                Text('ESTRUTURA DO TEMPLATE', style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                const SizedBox(height: 12),
                // Extrai headings do HTML
                ..._extractHeadings(tpl.html).map((h) => Padding(
                  padding: EdgeInsets.only(bottom: 8, left: h.level == 3 ? 16 : 0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 3, height: 18,
                        margin: const EdgeInsets.only(right: 10, top: 2),
                        decoration: BoxDecoration(
                            color: h.level == 1 ? tpl.color : h.level == 2 ? tpl.color.withOpacity(.6) : tpl.color.withOpacity(.3),
                            borderRadius: BorderRadius.circular(_kPill))),
                    Expanded(child: Text(h.text,
                        style: GoogleFonts.roboto(
                            color: h.level == 1 ? tp : h.level == 2 ? tp.withOpacity(.8) : ts,
                            fontSize: h.level == 1 ? 14 : h.level == 2 ? 13 : 12,
                            fontWeight: h.level <= 2 ? FontWeight.w700 : FontWeight.w500))),
                  ]),
                )),
              ],
            )),
            // Bottom actions
            Container(
              color: bg,
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
              child: Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () { Navigator.pop(context); _open(tpl); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: tpl.color, borderRadius: BorderRadius.circular(_kPill)),
                    child: Text('Usar este template', textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  List<_Heading> _extractHeadings(String html) {
    final result = <_Heading>[];
    final re = RegExp(r'<h([123])>(.*?)<\/h[123]>', dotAll: true);
    for (final m in re.allMatches(html)) {
      final level = int.tryParse(m.group(1)??'2')??2;
      final raw = m.group(2)??'';
      final clean = raw.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (clean.isNotEmpty) result.add(_Heading(level, clean));
    }
    return result;
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
    final card = isDark ? const Color(0xFF2A2A2A)     : Colors.white;

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
        // ── Search ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(_kPill)),
            child: Row(children: [
              Padding(padding: const EdgeInsets.only(left: 14, right: 8),
                  child: _svgW(_searchSvg, ts, s: 16)),
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

        // ── Category chips ──
        SizedBox(height: 46,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16,10,16,0),
            scrollDirection: Axis.horizontal,
            children: [
              _CatChip(label: 'Todos', selected: _cat == null, acc: acc, ts: ts, onTap: () => setState(() => _cat = null)),
              ..._categories.map((c) => _CatChip(label: c, selected: _cat == c, acc: acc, ts: ts, onTap: () => setState(() => _cat = _cat == c ? null : c))),
            ],
          ),
        ),

        Container(height: 0.5, color: div, margin: const EdgeInsets.only(top: 6)),

        // ── Grid ──
        Expanded(
          child: filtered.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search_off_rounded, size: 48, color: ts.withOpacity(.3)),
                const SizedBox(height: 12),
                Text('Sem resultados', style: GoogleFonts.roboto(color: ts, fontSize: 14)),
              ]))
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16,16,16,100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _TplCard(
                  tpl: filtered[i], isDark: isDark, tp: tp, ts: ts, card: card, div: div,
                  onTap: () => _showPreview(filtered[i]),
                ),
              ),
        ),
      ]),
    );
  }
}

class _Heading {
  final int level;
  final String text;
  const _Heading(this.level, this.text);
}

// ─── Category chip ────────────────────────────────────
class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color acc, ts;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.selected, required this.acc, required this.ts, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

// ─── Template Card ────────────────────────────────────
class _TplCard extends StatelessWidget {
  final _Tpl tpl;
  final bool isDark;
  final Color tp, ts, card, div;
  final VoidCallback onTap;
  const _TplCard({required this.tpl, required this.isDark, required this.tp, required this.ts, required this.card, required this.div, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(_kCard),
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .25 : .05), blurRadius: 10, offset: const Offset(0,3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Preview visual
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(_kCard), topRight: Radius.circular(_kCard)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [tpl.color.withOpacity(.05), tpl.color.withOpacity(.12)]),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Icon circle
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: tpl.color.withOpacity(.15), shape: BoxShape.circle),
                child: Icon(tpl.icon, color: tpl.color, size: 18)),
              const SizedBox(height: 10),
              // Skeleton lines
              Container(height: 6, width: double.infinity,
                  decoration: BoxDecoration(color: tpl.color.withOpacity(.35), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 6),
              ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 4),
                child: Container(height: 4.5,
                    width: i==3 ? 60 : i==1 ? double.infinity : i==2 ? 110 : double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.08), borderRadius: BorderRadius.circular(3))))),
              const SizedBox(height: 6),
              Container(height: 5, width: 80,
                  decoration: BoxDecoration(color: tpl.color.withOpacity(.25), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 4),
              ...List.generate(3, (i) => Padding(padding: const EdgeInsets.only(bottom: 4),
                child: Container(height: 4.5,
                    width: i==2 ? 50 : double.infinity,
                    decoration: BoxDecoration(color: Colors.black.withOpacity(.07), borderRadius: BorderRadius.circular(3))))),
            ]),
          ),
        ),
        // Info
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tpl.title, style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w800, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: tpl.color.withOpacity(.12), borderRadius: BorderRadius.circular(_kPill)),
                child: Text(tpl.category, style: GoogleFonts.roboto(color: tpl.color, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ),
      ]),
    ),
  );
}
