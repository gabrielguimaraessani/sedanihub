import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    // Verificar autenticação após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuthState() {
    final authState = ref.read(authNotifierProvider);
    print('🔍 Splash: Verificando estado de autenticação...');
    authState.when(
      data: (user) {
        print('🔍 Splash: Usuário encontrado: ${user?.email ?? 'null'}');
        if (user != null) {
          print('🔍 Splash: Redirecionando para dashboard');
          context.go('/dashboard');
        } else {
          print('🔍 Splash: Redirecionando para login');
          context.go('/login');
        }
      },
      loading: () {
        print('🔍 Splash: Estado de loading, aguardando...');
        // Continuar na splash até carregar
      },
      error: (error, stackTrace) {
        print('🔍 Splash: Erro na autenticação: $error');
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo da aplicação
              SvgPicture.asset(
                'assets/icons/logo.svg',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'SedaniHub',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistema Corporativo SedaniMed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
