import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';

// ── SVGs ─────────────────────────────────────────────────────────────────────
const _svgLogo  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,2A10,10,0,1,0,22,12,10,10,0,0,0,12,2Zm0,18a8,8,0,1,1,8-8A8,8,0,0,1,12,20Zm3-8a3,3,0,1,1-3-3A3,3,0,0,1,15,12Z"/></svg>';
const _svgEmail = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,1H5A5.006,5.006,0,0,0,0,6V18a5.006,5.006,0,0,0,5,5H19a5.006,5.006,0,0,0,5-5V6A5.006,5.006,0,0,0,19,1ZM5,3H19a3,3,0,0,1,2.78,1.887l-7.658,7.659a3.1,3.1,0,0,1-4.244,0L2.22,4.887A3,3,0,0,1,5,3ZM19,21H5a3,3,0,0,1-3-3V7.5L8.464,13.96a5.1,5.1,0,0,0,7.072,0L22,7.5V18A3,3,0,0,1,19,21Z"/></svg>';
const _svgPhone = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22.7,17.39l-3.74-2.69a2,2,0,0,0-2.64.33L15.1,16.38a14.17,14.17,0,0,1-7.47-7.47l1.35-1.22a2,2,0,0,0,.33-2.64L6.61,1.3A2,2,0,0,0,4,.88L1.31,2.4A2,2,0,0,0,.24,4.43a20.21,20.21,0,0,0,19.33,19.33,2,2,0,0,0,2-1.07L23.12,20A2,2,0,0,0,22.7,17.39Z"/></svg>';
const _svgLock  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,8H18V7A6,6,0,0,0,6,7V8H5a3,3,0,0,0-3,3v9a3,3,0,0,0,3,3H19a3,3,0,0,0,3-3V11A3,3,0,0,0,19,8ZM8,7a4,4,0,0,1,8,0V8H8Zm12,13a1,1,0,0,1-1,1H5a1,1,0,0,1-1-1V11a1,1,0,0,1,1-1H19a1,1,0,0,1,1,1Z"/></svg>';
const _svgUser  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,12A6,6,0,1,0,6,6,6.006,6.006,0,0,0,12,12ZM12,2a4,4,0,1,1-4,4A4,4,0,0,1,12,2ZM12,14a9.01,9.01,0,0,0-9,9,1,1,0,0,0,2,0,7,7,0,0,1,14,0,1,1,0,0,0,2,0A9.01,9.01,0,0,0,12,14Z"/></svg>';
const _svgEyeOn = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.271,9.419C21.72,6.893,18.192,2.655,12,2.655S2.28,6.893.729,9.419a4.908,4.908,0,0,0,0,5.162C2.28,17.107,5.808,21.345,12,21.345s9.72-4.238,11.271-6.764A4.908,4.908,0,0,0,23.271,9.419Zm-1.705,4.115C20.234,15.7,17.219,19.345,12,19.345S3.766,15.7,2.434,13.534a2.918,2.918,0,0,1,0-3.068C3.766,8.3,6.781,4.655,12,4.655s8.234,3.643,9.566,5.811A2.918,2.918,0,0,1,21.566,13.534ZM12,7a5,5,0,1,0,5,5A5.006,5.006,0,0,0,12,7Zm0,8a3,3,0,1,1,3-3A3,3,0,0,1,12,15Z"/></svg>';
const _svgEyeOff= '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M10.48,14.928A2.979,2.979,0,0,1,9,12a3,3,0,0,1,3-3,2.979,2.979,0,0,1,2.928,1.52ZM23.271,9.419a14.085,14.085,0,0,0-2.833-3.441l2.293-2.292L21.317,2.272,18.9,4.688A11.631,11.631,0,0,0,12,2.655C5.808,2.655,2.28,6.893.729,9.419a4.908,4.908,0,0,0,0,5.162,14.1,14.1,0,0,0,2.832,3.44L1.269,20.313l1.414,1.414,2.422-2.421A11.657,11.657,0,0,0,12,21.345c6.192,0,9.72-4.238,11.271-6.764A4.908,4.908,0,0,0,23.271,9.419ZM2.434,13.534a2.918,2.918,0,0,1,0-3.068C3.766,8.3,6.781,4.655,12,4.655a9.658,9.658,0,0,1,5.346,1.6L15.885,7.71A4.986,4.986,0,0,0,8.71,14.885L6.669,16.926A12.054,12.054,0,0,1,2.434,13.534Zm17.132,0C18.234,15.7,15.219,19.345,12,19.345a9.678,9.678,0,0,1-5.347-1.6L8.115,16.29a4.986,4.986,0,0,0,7.175-7.175l2.041-2.041a12.057,12.057,0,0,1,4.235,3.392A2.918,2.918,0,0,1,21.566,13.534Z"/></svg>';

Widget _svg(String d, Color c, {double s = 18}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ════════════════════════════════════════════════════════════════
// AUTH SCREEN
// ════════════════════════════════════════════════════════════════
class AuthScreen extends StatefulWidget {
  final VoidCallback onDone; // chamado após login/registo ou "pular"
  const AuthScreen({super.key, required this.onDone});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {

  // ── Modo ─────────────────────────────────────────────────────
  bool _isLogin  = true;   // true = entrar | false = criar conta
  bool _useEmail = true;   // true = email  | false = telemóvel
  bool _showPw   = false;
  bool _showPw2  = false;

  final _formKey  = GlobalKey<FormState>();
  final _cName    = TextEditingController();
  final _cEmail   = TextEditingController();
  final _cPhone   = TextEditingController();
  final _cPw      = TextEditingController();
  final _cPw2     = TextEditingController();
  String? _errMsg;

  late final AnimationController _aCtrl;
  late final Animation<double>    _fade;

  @override
  void initState() {
    super.initState();
    _aCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fade  = CurvedAnimation(parent: _aCtrl, curve: Curves.easeOut);
    _aCtrl.forward();
  }

  @override
  void dispose() {
    _aCtrl.dispose();
    for (final c in [_cName, _cEmail, _cPhone, _cPw, _cPw2]) c.dispose();
    super.dispose();
  }

  void _switchMode(bool toLogin) {
    setState(() { _isLogin = toLogin; _errMsg = null; });
    _aCtrl.forward(from: 0);
  }

  // ── Submit ───────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isLogin && _cPw.text != _cPw2.text) {
      setState(() => _errMsg = 'As palavras-passe não coincidem.');
      return;
    }
    setState(() => _errMsg = null);
    FocusScope.of(context).unfocus();

    final auth = AuthService.instance;
    AuthResult res;

    if (_isLogin) {
      res = _useEmail
          ? await auth.loginEmail(email: _cEmail.text, password: _cPw.text)
          : await auth.loginPhone(phone: _cPhone.text, password: _cPw.text);
    } else {
      res = _useEmail
          ? await auth.registerEmail(name: _cName.text, email: _cEmail.text, password: _cPw.text)
          : await auth.registerPhone(name: _cName.text, phone: _cPhone.text, password: _cPw.text);
    }

    if (!mounted) return;
    if (res.ok) { widget.onDone(); }
    else        { setState(() => _errMsg = res.error); }
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? AppColors.darkBackground    : AppColors.background;
    final card = isDark ? AppColors.darkSurface        : Colors.white;
    final tp   = isDark ? AppColors.darkTextPrimary    : AppColors.textPrimary;
    final ts   = isDark ? AppColors.darkTextSecondary  : AppColors.textSecondary;
    final div  = isDark ? AppColors.darkDivider        : AppColors.divider;
    final acc  = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 56),

                  // ── Brand ──────────────────────────────────
                  Center(child: Column(children: [
                    // Logotipo
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: acc.withOpacity(.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: acc.withOpacity(.28), width: 1.5),
                      ),
                      child: Center(
                        child: Text('✦',
                          style: TextStyle(fontSize: 34, color: acc, height: 1)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Aria', style: GoogleFonts.syne(
                      fontSize: 40, fontWeight: FontWeight.w800,
                      color: tp, height: 1,
                    )),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Bem-vindo de volta' : 'Cria a tua conta gratuita',
                      style: GoogleFonts.roboto(fontSize: 14.5, color: ts),
                    ),
                  ])),

                  const SizedBox(height: 40),

                  // ── Tabs Entrar / Criar conta ───────────────
                  _TabRow(
                    isLogin: _isLogin,
                    acc: acc,
                    tp: tp,
                    isDark: isDark,
                    onSwitch: _switchMode,
                  ),

                  const SizedBox(height: 28),

                  // ── Toggle Email / Telemóvel ────────────────
                  _ContactToggle(
                    useEmail: _useEmail,
                    acc: acc, div: div, ts: ts,
                    onTap: (v) => setState(() { _useEmail = v; _errMsg = null; }),
                  ),

                  const SizedBox(height: 22),

                  // ── Nome (só registo) ──────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: !_isLogin
                        ? Column(children: [
                            _Field(
                              ctrl: _cName, label: 'Nome completo',
                              hint: 'Alfredo Jonas', prefixSvg: _svgUser,
                              tp: tp, ts: ts, div: div, acc: acc, isDark: isDark,
                              validator: (v) =>
                                  (v == null || v.trim().length < 2) ? 'Insere o teu nome' : null,
                            ),
                            const SizedBox(height: 14),
                          ])
                        : const SizedBox.shrink(),
                  ),

                  // ── Email ou Telemóvel ─────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(.04, 0), end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _useEmail
                        ? _Field(
                            key: const ValueKey('email'),
                            ctrl: _cEmail, label: 'Email',
                            hint: 'email@exemplo.com', prefixSvg: _svgEmail,
                            tp: tp, ts: ts, div: div, acc: acc, isDark: isDark,
                            keyboard: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || !v.contains('@')) ? 'Email inválido' : null,
                          )
                        : _Field(
                            key: const ValueKey('phone'),
                            ctrl: _cPhone, label: 'Telemóvel',
                            hint: '+244 9XX XXX XXX', prefixSvg: _svgPhone,
                            tp: tp, ts: ts, div: div, acc: acc, isDark: isDark,
                            keyboard: TextInputType.phone,
                            formatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                            ],
                            validator: (v) =>
                                (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                                    ? 'Número inválido (mín. 9 dígitos)'
                                    : null,
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ── Password ───────────────────────────────
                  _Field(
                    ctrl: _cPw, label: 'Palavra-passe',
                    hint: '••••••••', prefixSvg: _svgLock,
                    tp: tp, ts: ts, div: div, acc: acc, isDark: isDark,
                    obscure: !_showPw,
                    suffix: _EyeBtn(
                      show: _showPw, ts: ts,
                      onTap: () => setState(() => _showPw = !_showPw),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  ),

                  // ── Confirmar password (só registo) ────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: !_isLogin
                        ? Column(children: [
                            const SizedBox(height: 14),
                            _Field(
                              ctrl: _cPw2, label: 'Confirmar palavra-passe',
                              hint: '••••••••', prefixSvg: _svgLock,
                              tp: tp, ts: ts, div: div, acc: acc, isDark: isDark,
                              obscure: !_showPw2,
                              suffix: _EyeBtn(
                                show: _showPw2, ts: ts,
                                onTap: () => setState(() => _showPw2 = !_showPw2),
                              ),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Confirma a palavra-passe' : null,
                            ),
                          ])
                        : const SizedBox.shrink(),
                  ),

                  // ── Erro ───────────────────────────────────
                  if (_errMsg != null) ...[
                    const SizedBox(height: 14),
                    _ErrorBox(msg: _errMsg!),
                  ],

                  const SizedBox(height: 28),

                  // ── Botão ──────────────────────────────────
                  _SubmitBtn(
                    label: _isLogin ? 'Entrar' : 'Criar conta',
                    acc: acc,
                    loading: AuthService.instance.loading,
                    onTap: _submit,
                  ),

                  const SizedBox(height: 20),

                  // ── Link toggle ────────────────────────────
                  GestureDetector(
                    onTap: () => _switchMode(!_isLogin),
                    child: Center(
                      child: RichText(text: TextSpan(
                        style: GoogleFonts.roboto(fontSize: 13.5, color: ts),
                        children: [
                          TextSpan(text: _isLogin ? 'Não tens conta? ' : 'Já tens conta? '),
                          TextSpan(
                            text: _isLogin ? 'Criar conta' : 'Entrar',
                            style: GoogleFonts.roboto(color: acc, fontWeight: FontWeight.w700),
                          ),
                        ],
                      )),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Continuar sem conta ────────────────────
                  TextButton(
                    onPressed: widget.onDone,
                    style: TextButton.styleFrom(foregroundColor: ts),
                    child: Text('Continuar sem conta →',
                        style: GoogleFonts.roboto(fontSize: 13, color: ts)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WIDGETS INTERNOS
// ════════════════════════════════════════════════════════════════

// ── Tab row (Entrar / Criar conta) ───────────────────────────────
class _TabRow extends StatelessWidget {
  final bool isLogin, isDark;
  final Color acc, tp;
  final void Function(bool) onSwitch;
  const _TabRow({required this.isLogin, required this.isDark,
      required this.acc, required this.tp, required this.onSwitch});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(children: [
      _Tab(label: 'Entrar',       active: isLogin,  acc: acc, tp: tp, isDark: isDark, onTap: () => onSwitch(true)),
      _Tab(label: 'Criar conta',  active: !isLogin, acc: acc, tp: tp, isDark: isDark, onTap: () => onSwitch(false)),
    ]),
  );
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active, isDark;
  final Color acc, tp;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.isDark,
      required this.acc, required this.tp, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? (isDark ? const Color(0xFF2C2C2E) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: active ? (isDark ? Colors.white : tp) : const Color(0xFF8E8E93),
        )),
      ),
    ),
  );
}

// ── Toggle Email / Telemóvel ─────────────────────────────────────
class _ContactToggle extends StatelessWidget {
  final bool useEmail;
  final Color acc, div, ts;
  final void Function(bool) onTap;
  const _ContactToggle({required this.useEmail, required this.acc,
      required this.div, required this.ts, required this.onTap});

  @override
  Widget build(BuildContext context) => Row(children: [
    _Chip(label: 'Email',      svg: _svgEmail, active: useEmail,   acc: acc, div: div, ts: ts, onTap: () => onTap(true)),
    const SizedBox(width: 10),
    _Chip(label: 'Telemóvel',  svg: _svgPhone, active: !useEmail,  acc: acc, div: div, ts: ts, onTap: () => onTap(false)),
  ]);
}

class _Chip extends StatelessWidget {
  final String label, svg;
  final bool active;
  final Color acc, div, ts;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.svg, required this.active,
      required this.acc, required this.div, required this.ts, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? acc.withOpacity(.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: active ? acc : div, width: active ? 1.5 : 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SvgPicture.string(svg, width: 15, height: 15,
            colorFilter: ColorFilter.mode(active ? acc : ts, BlendMode.srcIn)),
        const SizedBox(width: 7),
        Text(label, style: GoogleFonts.roboto(
          fontSize: 13.5, fontWeight: FontWeight.w600,
          color: active ? acc : ts,
        )),
      ]),
    ),
  );
}

// ── Campo de texto de autenticação ───────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint, prefixSvg;
  final bool obscure, isDark;
  final Color acc, div, tp, ts;
  final TextInputType keyboard;
  final List<TextInputFormatter> formatters;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _Field({
    super.key,
    required this.ctrl, required this.label, required this.hint,
    required this.prefixSvg, required this.tp, required this.ts,
    required this.div, required this.acc, required this.isDark,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.formatters = const [],
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9FAFB);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: GoogleFonts.roboto(
        fontSize: 10.5, fontWeight: FontWeight.w700,
        letterSpacing: .9, color: ts,
      )),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        inputFormatters: formatters,
        validator: validator,
        style: GoogleFonts.roboto(color: tp, fontSize: 15),
        cursorColor: acc,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(color: ts.withOpacity(.5), fontSize: 14),
          filled: true, fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
            child: SvgPicture.string(prefixSvg, width: 18, height: 18,
                colorFilter: ColorFilter.mode(ts, BlendMode.srcIn)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix,
          border:        _border(div),
          enabledBorder: _border(div),
          focusedBorder: _border(acc, w: 1.5),
          errorBorder:   _border(const Color(0xFFDC2626), w: 1.5),
          focusedErrorBorder: _border(const Color(0xFFDC2626), w: 1.5),
          errorStyle: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFFDC2626)),
        ),
      ),
    ]);
  }

  OutlineInputBorder _border(Color c, {double w = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );
}

// ── Botão olho (mostrar/ocultar password) ────────────────────────
class _EyeBtn extends StatelessWidget {
  final bool show;
  final Color ts;
  final VoidCallback onTap;
  const _EyeBtn({required this.show, required this.ts, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: _svg(show ? _svgEyeOff : _svgEyeOn, ts, s: 18),
    ),
  );
}

// ── Caixa de erro ────────────────────────────────────────────────
class _ErrorBox extends StatelessWidget {
  final String msg;
  const _ErrorBox({required this.msg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFDC2626).withOpacity(.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDC2626).withOpacity(.3)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: GoogleFonts.roboto(
        fontSize: 13.5, color: const Color(0xFFDC2626), fontWeight: FontWeight.w500,
      ))),
    ]),
  );
}

// ── Botão de submissão ───────────────────────────────────────────
class _SubmitBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final Color acc;
  final VoidCallback onTap;
  const _SubmitBtn({required this.label, required this.loading,
      required this.acc, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 54,
      decoration: BoxDecoration(
        color: loading ? acc.withOpacity(.7) : acc,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: acc.withOpacity(.32), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text(label, style: GoogleFonts.roboto(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
    ),
  );
}
