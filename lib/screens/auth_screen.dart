import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

// ── SVGs ──────────────────────────────────────────────────────────────────────
const _svgEmail = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,1H5A5.006,5.006,0,0,0,0,6V18a5.006,5.006,0,0,0,5,5H19a5.006,5.006,0,0,0,5-5V6A5.006,5.006,0,0,0,19,1ZM5,3H19a3,3,0,0,1,2.78,1.887l-7.658,7.659a3.007,3.007,0,0,1-4.244,0L2.22,4.887A3,3,0,0,1,5,3ZM19,21H5a3,3,0,0,1-3-3V7.5L8.464,13.96a5.007,5.007,0,0,0,7.072,0L22,7.5V18A3,3,0,0,1,19,21Z"/></svg>''';
const _svgPhone = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19.981,7.023v-6a1,1,0,0,1,2,0v6A1,1,0,0,1,19.981,7.023Zm-3,1a1,1,0,0,0,1-1v-6a1,1,0,0,0-2,0v6A1,1,0,0,0,16.981,8.023Zm6.095,13.116-.912,1.05c-8.19,7.84-28.12-12.084-20.4-20.3l1.15-1A3.08,3.08,0,0,1,7.242.93c.031.03,1.882,2.437,1.882,2.437a3.1,3.1,0,0,1-.005,4.281L7.959,9.1a12.783,12.783,0,0,0,6.932,6.947l1.464-1.165a3.1,3.1,0,0,1,4.282-.007s2.407,1.853,2.438,1.884A3.1,3.1,0,0,1,23.076,21.139ZM21.7,18.216s-2.4-1.842-2.425-1.872a1.121,1.121,0,0,0-1.549,0c-.026.027-2.044,1.635-2.044,1.635a1,1,0,0,1-.979.151A15,15,0,0,1,5.88,9.318a1,1,0,0,1,.146-.995S7.633,6.306,7.661,6.279a1.1,1.1,0,0,0,0-1.55C7.629,4.7,5.788,2.306,5.788,2.306a1.1,1.1,0,0,0-1.51.038L3.127,3.349C-2.513,10.128,14.758,26.442,20.7,20.826l.912-1.05A1.122,1.122,0,0,0,21.7,18.216Z"/></svg>''';
const _svgLock = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,8.424V7A7,7,0,0,0,5,7V8.424A5,5,0,0,0,2,13v6a5.006,5.006,0,0,0,5,5H17a5.006,5.006,0,0,0,5-5V13A5,5,0,0,0,19,8.424ZM7,7A5,5,0,0,1,17,7V8H7ZM20,19a3,3,0,0,1-3,3H7a3,3,0,0,1-3-3V13a3,3,0,0,1,3-3H17a3,3,0,0,1,3,3Z"/><path d="M12,14a1,1,0,0,0-1,1v2a1,1,0,0,0,2,0V15A1,1,0,0,0,12,14Z"/></svg>''';
const _svgEyeOn = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.271,9.419C21.72,6.893,18.192,2.655,12,2.655S2.28,6.893.729,9.419a4.908,4.908,0,0,0,0,5.162C2.28,17.107,5.808,21.345,12,21.345s9.72-4.238,11.271-6.764A4.908,4.908,0,0,0,23.271,9.419Zm-1.705,4.115C20.234,15.7,17.219,19.345,12,19.345S3.766,15.7,2.434,13.534a2.918,2.918,0,0,1,0-3.068C3.766,8.3,6.781,4.655,12,4.655s8.234,3.641,9.566,5.811A2.918,2.918,0,0,1,21.566,13.534Z"/><path d="M12,7a5,5,0,1,0,5,5A5.006,5.006,0,0,0,12,7Zm0,8a3,3,0,1,1,3-3A3,3,0,0,1,12,15Z"/></svg>''';
const _svgEyeOff = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.271,9.419A15.866,15.866,0,0,0,19.9,5.51l2.8-2.8a1,1,0,0,0-1.414-1.414L18.241,4.345A12.054,12.054,0,0,0,12,2.655C5.809,2.655,2.281,6.893.729,9.419a4.908,4.908,0,0,0,0,5.162A15.866,15.866,0,0,0,4.1,18.49l-2.8,2.8a1,1,0,1,0,1.414,1.414l3.052-3.052A12.054,12.054,0,0,0,12,21.345c6.191,0,9.719-4.238,11.271-6.764A4.908,4.908,0,0,0,23.271,9.419ZM2.433,13.534a2.918,2.918,0,0,1,0-3.068C3.767,8.3,6.782,4.655,12,4.655A10.1,10.1,0,0,1,16.766,5.82L14.753,7.833a4.992,4.992,0,0,0-6.92,6.92l-2.31,2.31A13.723,13.723,0,0,1,2.433,13.534ZM15,12a3,3,0,0,1-3,3,2.951,2.951,0,0,1-1.285-.3L14.7,10.715A2.951,2.951,0,0,1,15,12ZM9,12a3,3,0,0,1,3-3,2.951,2.951,0,0,1,1.285.3L9.3,13.285A2.951,2.951,0,0,1,9,12Zm12.567,1.534C20.233,15.7,17.218,19.345,12,19.345A10.1,10.1,0,0,1,7.234,18.18l2.013-2.013a4.992,4.992,0,0,0,6.92-6.92l2.31-2.31a13.723,13.723,0,0,1,3.09,3.529A2.918,2.918,0,0,1,21.567,13.534Z"/></svg>''';

const _svgChevronFwd = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="48" d="M184 112l144 144-144 144"/></svg>''';

Widget _svgIcon(String data, Color color, {double size = 18}) => SvgPicture.string(
  data, width: size, height: size,
  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
);

// ── Cores fixas ───────────────────────────────────────────────────────────────
const _btnLoginBg    = Color(0xFFD9D9D9);
const _btnLoginText  = Color(0xFF3F3F3F);
const _btnRegBg      = Color(0xFF545454);
const _btnRegText    = Color(0xFFD9D9D9);

// ════════════════════════════════════════════════════════════════════════════
// AUTH SCREEN — só fundo + dois botões
// ════════════════════════════════════════════════════════════════════════════
class AuthScreen extends StatelessWidget {
  final VoidCallback onDone;
  const AuthScreen({super.key, required this.onDone});

  void _openLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LoginModal(onDone: onDone),
    );
  }

  void _openRegister(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterModal(onDone: onDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Imagem de fundo ──────────────────────────────────
          Image.asset(
            'assets/images/background1.png',
            fit: BoxFit.cover,
          ),

          // ── Gradiente sobre a imagem (escurece em baixo) ─────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE5000000)],
                stops: [0.55, 1.0],
              ),
            ),
          ),

          // ── Botões na parte inferior ─────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Botão Login
                    _MainButton(
                      label: 'Fazer login com telemóvel ou email',
                      bg: _btnLoginBg,
                      textColor: _btnLoginText,
                      onTap: () => _openLogin(context),
                    ),
                    const SizedBox(height: 12),
                    // Botão Registar
                    _MainButton(
                      label: 'Cadastrar',
                      bg: _btnRegBg,
                      textColor: _btnRegText,
                      onTap: () => _openRegister(context),
                    ),
                    const SizedBox(height: 20),
                    // Iniciar sem login
                    GestureDetector(
                      onTap: onDone,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Iniciar sem login',
                            style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.28),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // chevron-forward ionicon via unicode (Ionicons usa Material-like fallback)
                          // Usamos HtmlElementView ou widget de texto com o caracter do ionicon
                          SvgPicture.string(
                            _svgChevronFwd,
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.28),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botão principal da tela inicial ──────────────────────────────────────────
class _MainButton extends StatelessWidget {
  final String label;
  final Color bg, textColor;
  final VoidCallback onTap;
  const _MainButton({
    required this.label, required this.bg,
    required this.textColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// MODAL DE LOGIN
// ════════════════════════════════════════════════════════════════════════════
class _LoginModal extends StatefulWidget {
  final VoidCallback onDone;
  const _LoginModal({required this.onDone});

  @override
  State<_LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<_LoginModal> {
  bool _useEmail = true;
  bool _showPw   = false;
  String? _errMsg;

  final _formKey = GlobalKey<FormState>();
  final _cEmail  = TextEditingController();
  final _cPhone  = TextEditingController();
  final _cPw     = TextEditingController();

  @override
  void dispose() {
    _cEmail.dispose(); _cPhone.dispose(); _cPw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _errMsg = null);
    FocusScope.of(context).unfocus();

    final auth = AuthService.instance;
    final res = _useEmail
        ? await auth.loginEmail(email: _cEmail.text, password: _cPw.text)
        : await auth.loginPhone(phone: _cPhone.text, password: _cPw.text);

    if (!mounted) return;
    if (res.ok) { Navigator.pop(context); widget.onDone(); }
    else        { setState(() => _errMsg = res.error); }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFDDDDDD),
                      borderRadius: BorderRadius.circular(99))),
              const SizedBox(height: 28),

              // Toggle email / telemóvel
              _ToggleContactRow(
                useEmail: _useEmail,
                onChanged: (v) => setState(() { _useEmail = v; _errMsg = null; }),
              ),
              const SizedBox(height: 20),

              // Campo email ou telemóvel
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _useEmail
                    ? _AuthField(
                        key: const ValueKey('login_email'),
                        ctrl: _cEmail, hint: 'Email',
                        prefixSvg: _svgEmail,
                        keyboard: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Email inválido' : null,
                      )
                    : _AuthField(
                        key: const ValueKey('login_phone'),
                        ctrl: _cPhone, hint: 'Número de telemóvel',
                        prefixSvg: _svgPhone,
                        keyboard: TextInputType.phone,
                        formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
                        validator: (v) =>
                            (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                                ? 'Número inválido' : null,
                      ),
              ),
              const SizedBox(height: 14),

              // Campo password
              _AuthField(
                ctrl: _cPw, hint: 'Palavra-passe',
                prefixSvg: _svgLock,
                obscure: !_showPw,
                suffix: _EyeToggle(
                  show: _showPw,
                  onTap: () => setState(() => _showPw = !_showPw),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),

              // Erro
              if (_errMsg != null) ...[
                const SizedBox(height: 12),
                _ErrorRow(msg: _errMsg!),
              ],

              const SizedBox(height: 24),

              // Botão entrar
              _ModalButton(
                label: 'Entrar',
                loading: AuthService.instance.loading,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// MODAL DE REGISTO — 90% da altura
// ════════════════════════════════════════════════════════════════════════════
class _RegisterModal extends StatefulWidget {
  final VoidCallback onDone;
  const _RegisterModal({required this.onDone});

  @override
  State<_RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<_RegisterModal> {
  bool _useEmail = true;
  bool _showPw   = false;
  bool _showPw2  = false;
  String? _errMsg;

  final _formKey = GlobalKey<FormState>();
  final _cName   = TextEditingController();
  final _cEmail  = TextEditingController();
  final _cPhone  = TextEditingController();
  final _cPw     = TextEditingController();
  final _cPw2    = TextEditingController();

  @override
  void dispose() {
    for (final c in [_cName, _cEmail, _cPhone, _cPw, _cPw2]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_cPw.text != _cPw2.text) {
      setState(() => _errMsg = 'As palavras-passe não coincidem.');
      return;
    }
    setState(() => _errMsg = null);
    FocusScope.of(context).unfocus();

    final auth = AuthService.instance;
    final res = _useEmail
        ? await auth.registerEmail(name: _cName.text, email: _cEmail.text, password: _cPw.text)
        : await auth.registerPhone(name: _cName.text, phone: _cPhone.text, password: _cPw.text);

    if (!mounted) return;
    if (res.ok) { Navigator.pop(context); widget.onDone(); }
    else        { setState(() => _errMsg = res.error); }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: screenH * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(99))),
                const SizedBox(height: 28),

                // Toggle email / telemóvel
                _ToggleContactRow(
                  useEmail: _useEmail,
                  onChanged: (v) => setState(() { _useEmail = v; _errMsg = null; }),
                ),
                const SizedBox(height: 20),

                // Nome
                _AuthField(
                  ctrl: _cName, hint: 'Nome completo',
                  prefixSvg: _svgPhone, // usa o de pessoa se tiveres, senão qualquer
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Insere o teu nome' : null,
                ),
                const SizedBox(height: 14),

                // Email ou telemóvel
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _useEmail
                      ? _AuthField(
                          key: const ValueKey('reg_email'),
                          ctrl: _cEmail, hint: 'Email',
                          prefixSvg: _svgEmail,
                          keyboard: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || !v.contains('@')) ? 'Email inválido' : null,
                        )
                      : _AuthField(
                          key: const ValueKey('reg_phone'),
                          ctrl: _cPhone, hint: 'Número de telemóvel',
                          prefixSvg: _svgPhone,
                          keyboard: TextInputType.phone,
                          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
                          validator: (v) =>
                              (v == null || v.replaceAll(RegExp(r'\D'), '').length < 9)
                                  ? 'Número inválido' : null,
                        ),
                ),
                const SizedBox(height: 14),

                // Password
                _AuthField(
                  ctrl: _cPw, hint: 'Palavra-passe',
                  prefixSvg: _svgLock,
                  obscure: !_showPw,
                  suffix: _EyeToggle(
                    show: _showPw,
                    onTap: () => setState(() => _showPw = !_showPw),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 14),

                // Confirmar password
                _AuthField(
                  ctrl: _cPw2, hint: 'Confirmar palavra-passe',
                  prefixSvg: _svgLock,
                  obscure: !_showPw2,
                  suffix: _EyeToggle(
                    show: _showPw2,
                    onTap: () => setState(() => _showPw2 = !_showPw2),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Confirma a palavra-passe' : null,
                ),

                // Erro
                if (_errMsg != null) ...[
                  const SizedBox(height: 12),
                  _ErrorRow(msg: _errMsg!),
                ],

                const SizedBox(height: 28),

                // Botão criar conta
                _ModalButton(
                  label: 'Criar conta',
                  loading: AuthService.instance.loading,
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS REUTILIZÁVEIS
// ════════════════════════════════════════════════════════════════════════════

// ── Toggle Email / Telemóvel ─────────────────────────────────────────────────
class _ToggleContactRow extends StatelessWidget {
  final bool useEmail;
  final void Function(bool) onChanged;
  const _ToggleContactRow({required this.useEmail, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    _ToggleChip(
      label: 'Email', svg: _svgEmail,
      active: useEmail, onTap: () => onChanged(true),
    ),
    const SizedBox(width: 10),
    _ToggleChip(
      label: 'Telemóvel', svg: _svgPhone,
      active: !useEmail, onTap: () => onChanged(false),
    ),
  ]);
}

class _ToggleChip extends StatelessWidget {
  final String label, svg;
  final bool active;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.svg,
      required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF545454).withOpacity(.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFF545454) : const Color(0xFFDDDDDD),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _svgIcon(svg, active ? const Color(0xFF545454) : const Color(0xFF999999), size: 15),
        const SizedBox(width: 7),
        Text(label, style: GoogleFonts.roboto(
          fontSize: 13.5, fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF545454) : const Color(0xFF999999),
        )),
      ]),
    ),
  );
}

// ── Campo de texto ───────────────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint, prefixSvg;
  final bool obscure;
  final TextInputType keyboard;
  final List<TextInputFormatter> formatters;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _AuthField({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.prefixSvg,
    this.obscure = false,
    this.keyboard = TextInputType.text,
    this.formatters = const [],
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: keyboard,
    inputFormatters: formatters,
    validator: validator,
    style: GoogleFonts.roboto(color: const Color(0xFF1A1A1A), fontSize: 15),
    cursorColor: const Color(0xFF545454),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.roboto(color: const Color(0xFFAAAAAA), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
        child: _svgIcon(prefixSvg, const Color(0xFF999999)),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffix,
      border:             _border(const Color(0xFFE0E0E0)),
      enabledBorder:      _border(const Color(0xFFE0E0E0)),
      focusedBorder:      _border(const Color(0xFF545454), w: 1.5),
      errorBorder:        _border(const Color(0xFFDC2626), w: 1.5),
      focusedErrorBorder: _border(const Color(0xFFDC2626), w: 1.5),
      errorStyle: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFFDC2626)),
    ),
  );

  OutlineInputBorder _border(Color c, {double w = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );
}

// ── Botão olho ───────────────────────────────────────────────────────────────
class _EyeToggle extends StatelessWidget {
  final bool show;
  final VoidCallback onTap;
  const _EyeToggle({required this.show, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: _svgIcon(show ? _svgEyeOff : _svgEyeOn, const Color(0xFF999999)),
    ),
  );
}

// ── Linha de erro ────────────────────────────────────────────────────────────
class _ErrorRow extends StatelessWidget {
  final String msg;
  const _ErrorRow({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFDC2626).withOpacity(.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFDC2626).withOpacity(.25)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 17),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.roboto(
        fontSize: 13, color: const Color(0xFFDC2626), fontWeight: FontWeight.w500,
      ))),
    ]),
  );
}

// ── Botão principal do modal ─────────────────────────────────────────────────
class _ModalButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _ModalButton({required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: loading ? const Color(0xFF545454).withOpacity(.6) : const Color(0xFF545454),
        borderRadius: BorderRadius.circular(14),
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