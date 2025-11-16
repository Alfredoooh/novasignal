// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/deriv_auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar listener de deep links do Deriv
  final derivAuthService = DerivAuthService();
  await derivAuthService.initDeepLinkListener();
  
  // Verificar se há token Deriv salvo e conectar automaticamente
  final hasAutoConnected = await derivAuthService.autoConnect();
  
  runApp(NovaSignalApp(hasAutoConnected: hasAutoConnected));
}

class NovaSignalApp extends StatelessWidget {
  final bool hasAutoConnected;

  const NovaSignalApp({
    super.key,
    required this.hasAutoConnected,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaSignal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF6A2F),
          secondary: const Color(0xFFE8451C),
          surface: const Color(0xFF1C1C1E),
          background: const Color(0xFF0A0A0A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E),
          elevation: 0,
        ),
      ),
      
      // Verificar autenticação Firebase e Deriv
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          
          // Se usuário está logado no Firebase
          if (snapshot.hasData) {
            // Se também conectou ao Deriv, ir para home
            if (hasAutoConnected) {
              return const HomeScreen();
            }
            // Se não conectou ao Deriv, ir para home mesmo assim
            // O usuário pode conectar depois
            return const HomeScreen();
          }
          
          // Se não está logado no Firebase, mostrar tela de login
          return const LoginScreen();
        },
      ),
      
      // Rotas nomeadas
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/deriv-callback': (context) => const DerivCallbackScreen(),
      },
      
      // Handler para rotas desconhecidas
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}

/// Splash Screen com logo animado
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6A2F).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.show_chart,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
              ).createShader(bounds),
              child: const Text(
                'NovaSignal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFFFF6A2F),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela intermediária para processar callback do OAuth Deriv (Web)
class DerivCallbackScreen extends StatefulWidget {
  const DerivCallbackScreen({super.key});

  @override
  State<DerivCallbackScreen> createState() => _DerivCallbackScreenState();
}

class _DerivCallbackScreenState extends State<DerivCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    if (kIsWeb) {
      // Para web, processar tokens da URL ou sessionStorage
      final uri = Uri.base;
      final params = uri.queryParameters;
      
      String? token;
      
      // Tentar pegar da URL
      if (params.containsKey('token1')) {
        token = params['token1'];
      }
      
      if (token != null) {
        // Conectar com o token
        final derivAuthService = DerivAuthService();
        final success = await derivAuthService.connectWithApiToken(token);
        
        if (success && mounted) {
          // Redirecionar para home
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (mounted) {
          // Erro ao conectar
          Navigator.of(context).pushReplacementNamed('/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao conectar com Deriv'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      } else if (mounted) {
        // Sem token, voltar para home
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Para Android, o deep link já foi processado
      // Apenas redirecionar para home
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6A2F), Color(0xFFE8451C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6A2F).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.show_chart,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFFFF6A2F),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Conectando ao Deriv...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aguarde um momento',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}