import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/servicos/presentation/pages/servicos_pendentes_page.dart';
import '../../features/servicos/presentation/pages/distribuicao_servicos_page.dart';
import '../../features/pacientes/presentation/pages/avaliacao_pacientes_page.dart';
import '../../features/pacientes/presentation/pages/avaliacao_paciente_ia_page.dart';
import '../../features/solicitacoes/presentation/pages/solicitacoes_page.dart';
import '../../features/ai/presentation/pages/ia_assistente_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/filas/presentation/pages/filas_page.dart';
import '../../features/chat/presentation/pages/chat_plantao_page.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      final isLoggingIn = state.matchedLocation == '/login';
      
      print('🧭 Router redirect - isLoggedIn: $isLoggedIn, isLoggingIn: $isLoggingIn, location: ${state.matchedLocation}');
      
      if (!isLoggedIn && !isLoggingIn) {
        print('🧭 Redirecionando para login');
        return '/login';
      }
      
      if (isLoggedIn && isLoggingIn) {
        print('🧭 Redirecionando para dashboard');
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
        routes: [
          GoRoute(
            path: '/servicos-pendentes',
            name: 'servicos-pendentes',
            builder: (context, state) => const ServicosPendentesPage(),
          ),
          GoRoute(
            path: '/distribuicao-servicos',
            name: 'distribuicao-servicos',
            builder: (context, state) => const DistribuicaoServicosPage(),
          ),
          GoRoute(
            path: '/avaliacao-pacientes',
            name: 'avaliacao-pacientes',
            builder: (context, state) => const AvaliacaoPacientesPage(),
          ),
          GoRoute(
            path: '/avaliacao-paciente-ia',
            name: 'avaliacao-paciente-ia',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return AvaliacaoPacienteIAPage(
                pacienteNome: args?['paciente'],
                procedimento: args?['procedimento'],
              );
            },
          ),
          GoRoute(
            path: '/solicitacoes',
            name: 'solicitacoes',
            builder: (context, state) => const SolicitacoesPage(),
          ),
          GoRoute(
            path: '/ia-assistente',
            name: 'ia-assistente',
            builder: (context, state) => const IAAssistentePage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/filas',
        name: 'filas',
        builder: (context, state) => const FilasPage(),
      ),
      GoRoute(
        path: '/chat-plantao',
        name: 'chat-plantao',
        builder: (context, state) => const ChatPlantaoPage(),
      ),
    ],
  );
});