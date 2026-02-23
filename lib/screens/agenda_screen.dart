import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';

// ── SVGs ─────────────────────────────────────────────────────────────────────
const _backSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';
const _prevSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15.707,4.293a1,1,0,0,0-1.414,0l-7,7a1,1,0,0,0,0,1.414l7,7a1,1,0,0,0,1.414-1.414L9.414,12l6.293-6.293A1,1,0,0,0,15.707,4.293Z"/></svg>';
const _nextSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M8.293,19.707a1,1,0,0,0,1.414,0l7-7a1,1,0,0,0,0-1.414l-7-7A1,1,0,0,0,8.293,5.707L14.586,12l-6.293,6.293A1,1,0,0,0,8.293,19.707Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 18}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ── Categorias de evento ──────────────────────────────────────────────────────
enum _Cat { trabalho, reuniao, pessoal, saude, estudo, outro }

const _catLabel = {
  _Cat.trabalho: 'Trabalho', _Cat.reuniao: 'Reunião',
  _Cat.pessoal: 'Pessoal',  _Cat.saude:   'Saúde',
  _Cat.estudo:  'Estudo',   _Cat.outro:    'Outro',
};
const _catColor = {
  _Cat.trabalho: Color(0xFF2563EB), _Cat.reuniao: Color(0xFF9333EA),
  _Cat.pessoal:  Color(0xFF16A34A), _Cat.saude:   Color(0xFFDC2626),
  _Cat.estudo:   Color(0xFFEA580C), _Cat.outro:   Color(0xFF6B7280),
};
const _catIcon = {
  _Cat.trabalho: Icons.work_outline_rounded,    _Cat.reuniao: Icons.people_outline_rounded,
  _Cat.pessoal:  Icons.person_outline_rounded,  _Cat.saude:   Icons.favorite_outline_rounded,
  _Cat.estudo:   Icons.school_outlined,         _Cat.outro:   Icons.label_outline_rounded,
};

// ── Modelo de evento ──────────────────────────────────────────────────────────
class _Event {
  final String id;
  final String title;
  final String? note;
  final String startTime;
  final String? endTime;
  final String? location;
  final _Cat category;
  final bool allDay;
  final int priority; // 1=baixa 2=normal 3=alta

  _Event({
    required this.id, required this.title, this.note,
    required this.startTime, this.endTime, this.location,
    this.category = _Cat.trabalho, this.allDay = false, this.priority = 2,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'note': note,
    'startTime': startTime, 'endTime': endTime, 'location': location,
    'cat': category.index, 'allDay': allDay, 'priority': priority,
  };

  factory _Event.fromJson(Map<String, dynamic> j) => _Event(
    id: j['id'] ?? '', title: j['title'] ?? '',
    note: j['note'], startTime: j['startTime'] ?? '09:00',
    endTime: j['endTime'], location: j['location'],
    category: _Cat.values[j['cat'] ?? 0],
    allDay: j['allDay'] ?? false, priority: j['priority'] ?? 2,
  );
}

// ── Horário de trabalho ───────────────────────────────────────────────────────
class _WorkSchedule {
  String name;
  String startTime;
  String endTime;
  List<int> days; // 1=Seg … 7=Dom
  int goalHoursPerMonth;

  _WorkSchedule({
    required this.name, required this.startTime, required this.endTime,
    required this.days, this.goalHoursPerMonth = 160,
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'startTime': startTime, 'endTime': endTime,
    'days': days, 'goalHours': goalHoursPerMonth,
  };

  factory _WorkSchedule.fromJson(Map<String, dynamic> j) => _WorkSchedule(
    name: j['name'] ?? 'Trabalho', startTime: j['startTime'] ?? '09:00',
    endTime: j['endTime'] ?? '18:00',
    days: List<int>.from(j['days'] ?? [1,2,3,4,5]),
    goalHoursPerMonth: j['goalHours'] ?? 160,
  );

  // Horas por dia do schedule
  double get hoursPerDay {
    final s = _parseTime(startTime), e = _parseTime(endTime);
    final mins = (e.hour * 60 + e.minute) - (s.hour * 60 + s.minute);
    return mins > 0 ? mins / 60.0 : 0;
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }
}

// ════════════════════════════════════════════════════════════════════════════════
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});
  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  DateTime _selectedDay = DateTime.now();
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<String, List<_Event>> _events = {};
  Set<String> _appUsageDays = {};
  _WorkSchedule? _schedule;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _tabs = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _tabs.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() {});

  // ── Persistência ─────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    // Eventos
    final rawEv = prefs.getString('agenda_events_v2') ?? '{}';
    final mapEv = jsonDecode(rawEv) as Map<String, dynamic>;
    final events = <String, List<_Event>>{};
    mapEv.forEach((k, v) => events[k] = (v as List).map((e) => _Event.fromJson(e)).toList());

    // Horário de trabalho
    final rawSch = prefs.getString('agenda_schedule');
    _WorkSchedule? schedule;
    if (rawSch != null) schedule = _WorkSchedule.fromJson(jsonDecode(rawSch));

    // Dias de uso da app (documentos)
    await DocumentService.instance.load();
    final docs = DocumentService.instance.documents;
    final usageDays = <String>{};
    for (final d in docs) {
      usageDays.add(_key(d.updatedAt));
      usageDays.add(_key(d.createdAt));
    }

    if (mounted) setState(() { _events = events; _appUsageDays = usageDays; _schedule = schedule; });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    _events.forEach((k, v) => map[k] = v.map((e) => e.toJson()).toList());
    await prefs.setString('agenda_events_v2', jsonEncode(map));
  }

  Future<void> _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    if (_schedule != null) await prefs.setString('agenda_schedule', jsonEncode(_schedule!.toJson()));
    else await prefs.remove('agenda_schedule');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  List<_Event> _dayEvents(DateTime d) => _events[_key(d)] ?? [];

  int _monthUsedDays() {
    int count = 0;
    final dm = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    for (int i = 1; i <= dm; i++) {
      if (_appUsageDays.contains(_key(DateTime(_visibleMonth.year, _visibleMonth.month, i)))) count++;
    }
    return count;
  }

  int _monthWorkDays() {
    if (_schedule == null) return 0;
    int count = 0;
    final dm = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    for (int i = 1; i <= dm; i++) {
      final d = DateTime(_visibleMonth.year, _visibleMonth.month, i);
      if (_schedule!.days.contains(d.weekday) &&
          _appUsageDays.contains(_key(d))) count++;
    }
    return count;
  }

  // ── Adicionar evento ──────────────────────────────────────────────────────────
  void _addEvent([DateTime? forDay]) {
    final day = forDay ?? _selectedDay;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent, useSafeArea: true,
      builder: (_) => _AddEventSheet(
        selectedDay: day,
        onAdd: (ev) {
          final k = _key(day);
          setState(() => _events[k] = [...(_events[k] ?? []), ev]);
          _saveEvents();
        },
      ),
    );
  }

  void _deleteEvent(DateTime day, _Event ev) {
    final k = _key(day);
    setState(() {
      _events[k] = (_events[k] ?? []).where((e) => e.id != ev.id).toList();
      if (_events[k]!.isEmpty) _events.remove(k);
    });
    _saveEvents();
  }

  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? AppColors.darkBackground    : AppColors.background;
    final tp  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc = accColor(isDark);
    final card= isDark ? const Color(0xFF2E2E2E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: _svgW(_backSvg, tp, s: 20),
        ),
        title: Text('Agenda',
            style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          // Botão de horário de trabalho
          IconButton(
            tooltip: 'Horário de trabalho',
            icon: Icon(Icons.work_outline_rounded, color: ts, size: 22),
            onPressed: () => _openScheduleSheet(isDark, bg, tp, ts, div, acc),
          ),
          // Botão de adicionar evento
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _addEvent(),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF363636) : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: card, borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 4)],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: tp, unselectedLabelColor: ts,
                  labelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w400),
                  tabs: const [Tab(text: 'Mês', height: 36), Tab(text: 'Dia', height: 36), Tab(text: 'Horário', height: 36)],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MonthView(screen: this, isDark: isDark, bg: bg, tp: tp, ts: ts, div: div, acc: acc, card: card),
          _DayView(screen: this, isDark: isDark, bg: bg, tp: tp, ts: ts, div: div, acc: acc, card: card),
          _ScheduleTimelineView(screen: this, isDark: isDark, bg: bg, tp: tp, ts: ts, div: div, acc: acc, card: card),
        ],
      ),
    );
  }

  // ── Sheet: horário de trabalho ────────────────────────────────────────────
  void _openScheduleSheet(bool isDark, Color bg, Color tp, Color ts, Color div, Color acc) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent, useSafeArea: true,
      builder: (_) => _ScheduleSheet(
        schedule: _schedule,
        isDark: isDark, tp: tp, ts: ts, div: div, acc: acc,
        onSave: (s) { setState(() => _schedule = s); _saveSchedule(); },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── VISTA MÊS ─────────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _MonthView extends StatelessWidget {
  final _AgendaScreenState screen;
  final bool isDark;
  final Color bg, tp, ts, div, acc, card;
  const _MonthView({required this.screen, required this.isDark, required this.bg,
    required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final vm = screen._visibleMonth;
    final firstDay = DateTime(vm.year, vm.month, 1);
    final lastDay  = DateTime(vm.year, vm.month + 1, 0);
    // Começa na segunda (weekday=1). Coluna 0 = Seg.
    final startCol = (firstDay.weekday - 1) % 7;
    final totalCells = startCol + lastDay.day;
    // Número de semanas = linhas do grid
    final rowCount = (totalCells / 7).ceil();

    final usedDays = screen._monthUsedDays();
    final workDays = screen._monthWorkDays();
    final sch = screen._schedule;
    final pct = sch != null && workDays > 0
        ? (workDays / (sch.days.length * 4)).clamp(0.0, 1.0)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // ── Cabeçalho: navegação de mês ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(children: [
            IconButton(
              onPressed: () => screen.setState(() => screen._visibleMonth =
                  DateTime(vm.year, vm.month - 1)),
              icon: _svgW(_prevSvg, ts, s: 18), padding: EdgeInsets.zero,
            ),
            Expanded(child: Text(
              DateFormat('MMMM yyyy', 'pt').format(vm),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w800),
            )),
            IconButton(
              onPressed: () => screen.setState(() => screen._visibleMonth =
                  DateTime(vm.year, vm.month + 1)),
              icon: _svgW(_nextSvg, ts, s: 18), padding: EdgeInsets.zero,
            ),
          ]),
        ),

        // ── Estatísticas do mês ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            _statBox('$usedDays', 'Dias\nde uso', acc, isDark, card),
            const SizedBox(width: 10),
            if (sch != null) ...[
              _statBox('$workDays', 'Dias\ntrabalhados', const Color(0xFF2563EB), isDark, card),
              const SizedBox(width: 10),
              _statBox('${(workDays * sch.hoursPerDay).toStringAsFixed(0)}h',
                  'Horas\nestimadas', const Color(0xFF16A34A), isDark, card),
            ] else
              Expanded(child: GestureDetector(
                onTap: () => screen._openScheduleSheet(isDark, bg, tp, ts, div, acc),
                child: Container(
                  height: 64, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: acc.withOpacity(.3), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: acc.withOpacity(.05),
                  ),
                  child: Text('+ Definir horário de trabalho',
                      style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              )),
          ]),
        ),

        if (sch != null) Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${(pct * 100).round()}% — ${sch.name}',
                style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct, minHeight: 5,
                backgroundColor: acc.withOpacity(.12),
                valueColor: AlwaysStoppedAnimation<Color>(acc),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // ── Grid do mês estilo habit-tracker ────────────────────────────────
        // Colunas = semanas (4-5), Linhas = dias da semana (Seg-Dom)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Labels dos dias da semana (linhas)
            Column(
              children: ['S','T','Q','Q','S','S','D'].map((l) =>
                SizedBox(height: 32, child: Center(
                  child: Text(l, style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w700)),
                )),
              ).toList(),
            ),
            const SizedBox(width: 6),
            // Grid: colunas = semanas
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(rowCount, (col) {
                  return Expanded(
                    child: Column(
                      children: List.generate(7, (row) {
                        final cellIdx = col * 7 + row;
                        final dayNum  = cellIdx - startCol + 1;
                        if (dayNum < 1 || dayNum > lastDay.day) {
                          return const SizedBox(height: 32);
                        }
                        final date = DateTime(vm.year, vm.month, dayNum);
                        final k = screen._key(date);
                        final wasUsed = screen._appUsageDays.contains(k);
                        final isWorkDay = screen._schedule?.days.contains(date.weekday) ?? false;
                        final hasEv = (screen._events[k] ?? []).isNotEmpty;
                        final isToday = k == screen._key(now);
                        final isSel = k == screen._key(screen._selectedDay);

                        return GestureDetector(
                          onTap: () {
                            screen.setState(() => screen._selectedDay = date);
                            screen._tabs.animateTo(1);
                          },
                          child: SizedBox(
                            height: 32,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 26, height: 26,
                                decoration: BoxDecoration(
                                  // Amarelo/acento se foi dia de uso (como na imagem)
                                  color: isSel
                                      ? acc
                                      : wasUsed && isWorkDay
                                          ? acc.withOpacity(isDark ? 0.85 : 0.8)
                                          : wasUsed
                                              ? acc.withOpacity(isDark ? 0.45 : 0.35)
                                              : isWorkDay
                                                  ? (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0))
                                                  : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF5F5F5)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: isToday && !isSel
                                      ? Border.all(color: acc, width: 1.5) : null,
                                ),
                                child: Stack(alignment: Alignment.center, children: [
                                  Text('$dayNum',
                                      style: GoogleFonts.roboto(
                                        color: isSel ? Colors.white
                                            : wasUsed ? (isDark ? Colors.black : Colors.white)
                                            : isToday ? acc : tp,
                                        fontSize: 10,
                                        fontWeight: (isToday || wasUsed || isSel)
                                            ? FontWeight.w800 : FontWeight.w400,
                                      )),
                                  if (hasEv && !isSel)
                                    Positioned(
                                      bottom: 1,
                                      child: Container(
                                        width: 4, height: 4,
                                        decoration: BoxDecoration(
                                          color: wasUsed ? Colors.white.withOpacity(.8) : acc,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ]),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),

        // ── Legenda ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(spacing: 14, children: [
            _legend(acc.withOpacity(.85), 'Dia trabalhado'),
            _legend(acc.withOpacity(.4), 'Dia de uso'),
            if (screen._schedule != null)
              _legend(isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF0F0F0), 'Dia laboral'),
          ]),
        ),

        // ── Próximos eventos ─────────────────────────────────────────────────
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('PRÓXIMOS EVENTOS',
              style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ),
        ..._upcomingEvents(7).map((pair) {
          final date = pair.$1; final ev = pair.$2;
          return _EventTile(ev: ev, day: date, isDark: isDark, tp: tp, ts: ts,
              card: card, onDelete: () { screen._deleteEvent(date, ev); screen.setState(() {}); });
        }),
        if (_upcomingEvents(7).isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Text('Sem eventos nos próximos 7 dias',
                style: GoogleFonts.roboto(color: ts, fontSize: 13))),
          ),
      ],
    );
  }

  Widget _statBox(String val, String label, Color color, bool isDark, Color card) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.2))),
      child: Column(children: [
        Text(val, style: GoogleFonts.roboto(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: color.withOpacity(.7), fontSize: 9, fontWeight: FontWeight.w700)),
      ]),
    ),
  );

  Widget _legend(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 10)),
  ]);

  List<(DateTime, _Event)> _upcomingEvents(int days) {
    final now = DateTime.now();
    final result = <(DateTime, _Event)>[];
    for (int i = 0; i <= days; i++) {
      final d = now.add(Duration(days: i));
      for (final ev in screen._dayEvents(d)) result.add((d, ev));
    }
    result.sort((a, b) => a.$1.compareTo(b.$1));
    return result.take(10).toList();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── VISTA DIA ─────────────────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _DayView extends StatelessWidget {
  final _AgendaScreenState screen;
  final bool isDark;
  final Color bg, tp, ts, div, acc, card;
  const _DayView({required this.screen, required this.isDark, required this.bg,
    required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final events = screen._dayEvents(screen._selectedDay);
    final isToday = screen._key(screen._selectedDay) == screen._key(DateTime.now());

    return Column(children: [
      // ── Seletor de dia ──────────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: card,
          border: Border(bottom: BorderSide(color: div, width: 0.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => screen.setState(() => screen._selectedDay =
                screen._selectedDay.subtract(const Duration(days: 1))),
            icon: _svgW(_prevSvg, ts, s: 18),
          ),
          const SizedBox(width: 12),
          Column(children: [
            Text(
              isToday ? 'Hoje' : DateFormat('EEEE', 'pt').format(screen._selectedDay),
              style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              DateFormat('d MMMM yyyy', 'pt').format(screen._selectedDay),
              style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ]),
          const SizedBox(width: 12),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => screen.setState(() => screen._selectedDay =
                screen._selectedDay.add(const Duration(days: 1))),
            icon: _svgW(_nextSvg, ts, s: 18),
          ),
        ]),
      ),

      // ── Eventos ─────────────────────────────────────────────────────────────
      Expanded(
        child: events.isEmpty
            ? _empty(tp, ts, acc, context)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: events.length,
                itemBuilder: (_, i) => _EventTile(
                  ev: events[i], day: screen._selectedDay,
                  isDark: isDark, tp: tp, ts: ts, card: card,
                  showDate: false,
                  onDelete: () { screen._deleteEvent(screen._selectedDay, events[i]); screen.setState(() {}); },
                ),
              ),
      ),
    ]);
  }

  Widget _empty(Color tp, Color ts, Color acc, BuildContext ctx) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.event_note_rounded, size: 52, color: ts.withOpacity(.3)),
      const SizedBox(height: 16),
      Text('Sem eventos', style: GoogleFonts.roboto(color: tp, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => screen._addEvent(),
        child: Text('+ Adicionar evento',
            style: GoogleFonts.roboto(color: acc, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ── VISTA HORÁRIO SEMANAL ──────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _ScheduleTimelineView extends StatelessWidget {
  final _AgendaScreenState screen;
  final bool isDark;
  final Color bg, tp, ts, div, acc, card;
  const _ScheduleTimelineView({required this.screen, required this.isDark, required this.bg,
    required this.tp, required this.ts, required this.div, required this.acc, required this.card});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Semana: Seg a Dom com o dia seleccionado dentro
    final sel = screen._selectedDay;
    final weekStart = sel.subtract(Duration(days: sel.weekday - 1));
    final weekDays  = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(children: [
      // ── Cabeçalho semanal ────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: card,
          border: Border(bottom: BorderSide(color: div, width: 0.5)),
        ),
        child: Row(children: [
          IconButton(
            padding: EdgeInsets.zero, iconSize: 20,
            onPressed: () => screen.setState(() =>
                screen._selectedDay = sel.subtract(const Duration(days: 7))),
            icon: _svgW(_prevSvg, ts, s: 16),
          ),
          ...weekDays.map((d) {
            final k = screen._key(d);
            final isToday = k == screen._key(now);
            final isSel   = k == screen._key(sel);
            final wasUsed = screen._appUsageDays.contains(k);
            final hasEv   = (screen._events[k] ?? []).isNotEmpty;
            return Expanded(
              child: GestureDetector(
                onTap: () => screen.setState(() => screen._selectedDay = d),
                child: Column(children: [
                  Text(DateFormat('E', 'pt').format(d).substring(0, 1),
                      style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: isSel ? acc : wasUsed ? acc.withOpacity(.3) : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSel ? Border.all(color: acc, width: 1.5) : null,
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      Text('${d.day}', style: GoogleFonts.roboto(
                          color: isSel ? Colors.white : isToday ? acc : tp,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                      if (hasEv && !isSel) Positioned(bottom: 2,
                          child: Container(width: 4, height: 4,
                              decoration: BoxDecoration(color: acc, shape: BoxShape.circle))),
                    ]),
                  ),
                ]),
              ),
            );
          }),
          IconButton(
            padding: EdgeInsets.zero, iconSize: 20,
            onPressed: () => screen.setState(() =>
                screen._selectedDay = sel.add(const Duration(days: 7))),
            icon: _svgW(_nextSvg, ts, s: 16),
          ),
        ]),
      ),

      // ── Timeline ─────────────────────────────────────────────────────────
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Stack(children: [
            // Linhas de hora
            ...List.generate(24, (h) => Positioned(
              top: h * 56.0,
              left: 0, right: 0,
              child: Row(children: [
                SizedBox(width: 44,
                    child: Text('${h.toString().padLeft(2,'0')}:00',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.roboto(color: ts.withOpacity(.6), fontSize: 9))),
                const SizedBox(width: 6),
                Expanded(child: Container(height: 0.5, color: div.withOpacity(.4))),
              ]),
            )),
            // Placeholder para o stack ter altura
            Container(height: 24 * 56.0),

            // Bloco de horário de trabalho
            if (screen._schedule != null && screen._schedule!.days.contains(sel.weekday)) ...[
              Positioned(
                top: _timeToTop(screen._schedule!.startTime),
                left: 52, right: 12,
                child: Container(
                  height: _timeRange(screen._schedule!.startTime, screen._schedule!.endTime),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(.2)),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Align(alignment: Alignment.topLeft,
                    child: Text('${screen._schedule!.name} · ${screen._schedule!.startTime}–${screen._schedule!.endTime}',
                        style: GoogleFonts.roboto(color: const Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.w700))),
                ),
              ),
            ],

            // Eventos do dia seleccionado
            ...screen._dayEvents(sel).map((ev) {
              final top = _timeToTop(ev.startTime);
              final h   = ev.endTime != null ? _timeRange(ev.startTime, ev.endTime!) : 48.0;
              final col = _catColor[ev.category] ?? acc;
              return Positioned(
                top: top, left: 52, right: 12,
                child: GestureDetector(
                  onLongPress: () => screen._deleteEvent(sel, ev),
                  child: Container(
                    height: h.clamp(32.0, double.infinity),
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: col.withOpacity(.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: col, width: 3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ev.title, style: GoogleFonts.roboto(color: col, fontSize: 11, fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (ev.endTime != null)
                        Text('${ev.startTime} – ${ev.endTime}',
                            style: GoogleFonts.roboto(color: col.withOpacity(.7), fontSize: 9)),
                    ]),
                  ),
                ),
              );
            }),

            // Linha de hora actual
            if (screen._key(sel) == screen._key(now))
              Positioned(
                top: now.hour * 56.0 + now.minute * 56 / 60,
                left: 0, right: 0,
                child: Row(children: [
                  SizedBox(width: 44, child: Text(DateFormat('HH:mm').format(now),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.roboto(color: acc, fontSize: 8, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 3),
                  Expanded(child: Container(height: 1.5, color: acc)),
                  Container(width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: acc, shape: BoxShape.circle)),
                ]),
              ),
          ]),
        ),
      ),
    ]);
  }

  double _timeToTop(String t) {
    final p = t.split(':');
    final h = int.tryParse(p[0]) ?? 0, m = int.tryParse(p.length > 1 ? p[1] : '0') ?? 0;
    return h * 56.0 + m * 56 / 60;
  }

  double _timeRange(String start, String end) {
    final ps = start.split(':'), pe = end.split(':');
    final sm = (int.tryParse(ps[0]) ?? 0) * 60 + (int.tryParse(ps.length > 1 ? ps[1] : '0') ?? 0);
    final em = (int.tryParse(pe[0]) ?? 0) * 60 + (int.tryParse(pe.length > 1 ? pe[1] : '0') ?? 0);
    final diff = em - sm;
    return (diff > 0 ? diff : 30) * 56.0 / 60;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── TILE DE EVENTO (reutilizável) ─────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _EventTile extends StatelessWidget {
  final _Event ev;
  final DateTime day;
  final bool isDark, showDate;
  final Color tp, ts, card;
  final VoidCallback onDelete;
  const _EventTile({required this.ev, required this.day, required this.isDark,
    required this.tp, required this.ts, required this.card, required this.onDelete,
    this.showDate = true});

  @override
  Widget build(BuildContext context) {
    final col = _catColor[ev.category] ?? const Color(0xFF2563EB);
    final prioColors = [Colors.transparent, const Color(0xFF8E8E93), const Color(0xFFEA580C), const Color(0xFFDC2626)];

    return Dismissible(
      key: Key(ev.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        ),
        child: Row(children: [
          Container(width: 3.5, height: 52,
              decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(ev.title, style: GoogleFonts.roboto(
                  color: tp, fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (ev.priority > 1) Container(width: 7, height: 7, margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(color: prioColors[ev.priority], shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 5),
            Row(children: [
              Icon(_catIcon[ev.category], size: 11, color: col),
              const SizedBox(width: 4),
              Text(_catLabel[ev.category] ?? '', style: GoogleFonts.roboto(
                  color: col, fontSize: 10, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Icon(Icons.access_time_rounded, size: 11, color: ts),
              const SizedBox(width: 3),
              Text(ev.allDay ? 'Dia inteiro' : '${ev.startTime}${ev.endTime != null ? " – ${ev.endTime}" : ""}',
                  style: GoogleFonts.roboto(color: ts, fontSize: 11)),
            ]),
            if (showDate) Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(DateFormat('d MMM', 'pt').format(day),
                  style: GoogleFonts.roboto(color: ts, fontSize: 10)),
            ),
            if (ev.location != null) Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(children: [
                Icon(Icons.location_on_outlined, size: 11, color: ts),
                const SizedBox(width: 3),
                Text(ev.location!, style: GoogleFonts.roboto(color: ts, fontSize: 11)),
              ]),
            ),
            if (ev.note != null && ev.note!.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(ev.note!, style: GoogleFonts.roboto(color: ts, fontSize: 11),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ])),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── SHEET: ADICIONAR EVENTO ────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _AddEventSheet extends StatefulWidget {
  final DateTime selectedDay;
  final void Function(_Event ev) onAdd;
  const _AddEventSheet({required this.selectedDay, required this.onAdd});
  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  final _locCtrl   = TextEditingController();
  String _start = '09:00', _end = '10:00';
  _Cat _cat = _Cat.trabalho;
  int  _prio = 2;
  bool _allDay = false;

  @override
  void dispose() { _titleCtrl.dispose(); _noteCtrl.dispose(); _locCtrl.dispose(); super.dispose(); }

  TimeOfDay _parse(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: _parse(isStart ? _start : _end));
    if (picked != null) {
      final s = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
      setState(() { if (isStart) _start = s; else _end = s; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final tp  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Novo evento',
              style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800))),
          Text(DateFormat('d MMM', 'pt').format(widget.selectedDay),
              style: GoogleFonts.roboto(color: ts, fontSize: 13)),
        ]),
        const SizedBox(height: 16),

        // Título
        _tf(_titleCtrl, 'Título *', tp, ts, div, acc),
        const SizedBox(height: 10),

        // Categoria — chips
        _label('CATEGORIA', ts),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: _Cat.values.map((c) {
          final sel = c == _cat;
          final col = _catColor[c] ?? acc;
          return GestureDetector(
            onTap: () => setState(() => _cat = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? col.withOpacity(.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: sel ? col : div, width: sel ? 1.5 : 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_catIcon[c], size: 11, color: sel ? col : ts),
                const SizedBox(width: 4),
                Text(_catLabel[c]!, style: GoogleFonts.roboto(
                    color: sel ? col : ts, fontSize: 12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
              ]),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),

        // Dia inteiro
        Row(children: [
          Text('Dia inteiro', style: GoogleFonts.roboto(color: tp, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          Switch.adaptive(value: _allDay, onChanged: (v) => setState(() => _allDay = v), activeColor: acc),
        ]),

        if (!_allDay) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _timeBtn('Início', _start, tp, ts, div, isDark, () => _pickTime(true))),
            const SizedBox(width: 10),
            Expanded(child: _timeBtn('Fim', _end, tp, ts, div, isDark, () => _pickTime(false))),
          ]),
        ],
        const SizedBox(height: 10),

        // Local
        _tf(_locCtrl, 'Local (opcional)', tp, ts, div, acc,
            prefix: const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF8E8E93))),
        const SizedBox(height: 10),

        // Nota
        _tf(_noteCtrl, 'Notas (opcional)', tp, ts, div, acc, maxLines: 2),
        const SizedBox(height: 14),

        // Prioridade
        _label('PRIORIDADE', ts),
        const SizedBox(height: 8),
        Row(children: [
          _prioChip(1, 'Baixa',  const Color(0xFF8E8E93), ts, div),
          const SizedBox(width: 8),
          _prioChip(2, 'Normal', const Color(0xFFEA580C), ts, div),
          const SizedBox(width: 8),
          _prioChip(3, 'Alta',   const Color(0xFFDC2626), ts, div),
        ]),
        const SizedBox(height: 20),

        // Botão
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: acc, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0,
            ),
            onPressed: () {
              if (_titleCtrl.text.trim().isEmpty) return;
              widget.onAdd(_Event(
                id: '${DateTime.now().millisecondsSinceEpoch}',
                title: _titleCtrl.text.trim(),
                note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                startTime: _start, endTime: _allDay ? null : _end,
                location: _locCtrl.text.trim().isEmpty ? null : _locCtrl.text.trim(),
                category: _cat, allDay: _allDay, priority: _prio,
              ));
              Navigator.pop(context);
            },
            child: Text('Adicionar evento',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ])),
    );
  }

  Widget _label(String t, Color ts) => Text(t, style: GoogleFonts.roboto(
      color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2));

  Widget _timeBtn(String label, String time, Color tp, Color ts, Color div, bool isDark, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: div), borderRadius: BorderRadius.circular(10),
          color: isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(time, style: GoogleFonts.roboto(color: tp, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
      ),
    );

  Widget _prioChip(int p, String label, Color color, Color ts, Color div) {
    final sel = _prio == p;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _prio = p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? color : div, width: sel ? 1.5 : 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.roboto(
              color: sel ? color : ts, fontSize: 12,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    ));
  }

  Widget _tf(TextEditingController ctrl, String hint, Color tp, Color ts, Color div, Color acc,
      {int maxLines = 1, Widget? prefix}) =>
    TextField(
      controller: ctrl, maxLines: maxLines,
      style: GoogleFonts.roboto(color: tp, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.roboto(color: ts, fontSize: 14),
        prefixIcon: prefix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: div)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: acc, width: 1.5)),
        filled: true, fillColor: themeNotifier.isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
      ),
    );
}

// ══════════════════════════════════════════════════════════════════════════════
// ── SHEET: HORÁRIO DE TRABALHO ────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
class _ScheduleSheet extends StatefulWidget {
  final _WorkSchedule? schedule;
  final bool isDark;
  final Color tp, ts, div, acc;
  final void Function(_WorkSchedule? s) onSave;
  const _ScheduleSheet({required this.schedule, required this.isDark, required this.tp,
    required this.ts, required this.div, required this.acc, required this.onSave});
  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  final _nameCtrl = TextEditingController();
  String _start = '09:00', _end = '18:00';
  List<int> _days = [1,2,3,4,5]; // Seg-Sex por defeito
  int _goalH = 160;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    if (s != null) {
      _nameCtrl.text = s.name;
      _start = s.startTime; _end = s.endTime;
      _days = List.from(s.days); _goalH = s.goalHoursPerMonth;
    } else {
      _nameCtrl.text = 'Trabalho';
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pickTime(bool isStart) async {
    final p = _start.split(':');
    final initial = isStart
        ? TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: 0)
        : TimeOfDay(hour: int.tryParse(_end.split(':')[0]) ?? 18, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final s = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
      setState(() { if (isStart) _start = s; else _end = s; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final tp  = widget.tp; final ts = widget.ts;
    final div = widget.div; final acc = widget.acc;
    final dayLabels = ['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('Horário de trabalho',
              style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800))),
          if (widget.schedule != null) TextButton(
            onPressed: () { widget.onSave(null); Navigator.pop(context); },
            child: Text('Remover', style: GoogleFonts.roboto(color: const Color(0xFFDC2626), fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 16),

        // Nome
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.roboto(color: tp, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Nome do horário',
            labelStyle: GoogleFonts.roboto(color: ts),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: div)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: acc, width: 1.5)),
            filled: true, fillColor: widget.isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
          ),
        ),
        const SizedBox(height: 14),

        // Horário
        Text('HORÁRIO', style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _timeBtn2('Entrada', _start, tp, ts, div, () => _pickTime(true))),
          const SizedBox(width: 10),
          Expanded(child: _timeBtn2('Saída', _end, tp, ts, div, () => _pickTime(false))),
        ]),
        const SizedBox(height: 14),

        // Dias da semana
        Text('DIAS DE TRABALHO', style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final day = i + 1; // 1=Seg
            final sel = _days.contains(day);
            return GestureDetector(
              onTap: () => setState(() => sel ? _days.remove(day) : _days.add(day)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: sel ? acc : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sel ? acc : div),
                ),
                child: Center(child: Text(dayLabels[i].substring(0,2),
                    style: GoogleFonts.roboto(
                      color: sel ? Colors.white : ts,
                      fontSize: 11, fontWeight: sel ? FontWeight.w800 : FontWeight.w400))),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),

        // Meta mensal
        Text('META MENSAL (horas)', style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Slider(
            value: _goalH.toDouble(), min: 40, max: 220, divisions: 18,
            activeColor: acc, inactiveColor: acc.withOpacity(.2),
            onChanged: (v) => setState(() => _goalH = v.round()),
          )),
          SizedBox(width: 50, child: Text('$_goalH h',
              style: GoogleFonts.roboto(color: tp, fontSize: 14, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: acc, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0,
            ),
            onPressed: () {
              final name = _nameCtrl.text.trim().isEmpty ? 'Trabalho' : _nameCtrl.text.trim();
              widget.onSave(_WorkSchedule(
                  name: name, startTime: _start, endTime: _end,
                  days: _days.toList()..sort(), goalHoursPerMonth: _goalH));
              Navigator.pop(context);
            },
            child: Text('Guardar horário',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ])),
    );
  }

  Widget _timeBtn2(String label, String time, Color tp, Color ts, Color div, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: div), borderRadius: BorderRadius.circular(10),
          color: widget.isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(time, style: GoogleFonts.roboto(color: tp, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
}
