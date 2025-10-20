import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notificacao.dart';
import '../services/notifications_service.dart';

/// Provider do serviço de notificações
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  return NotificationsService();
});

/// Provider para stream de notificações ativas
final notificacoesAtivasProvider = StreamProvider<List<Notificacao>>((ref) {
  final service = ref.watch(notificationsServiceProvider);
  return service.getNotificacoesAtivas();
});

/// Provider para contagem de notificações não lidas
final notificacoesNaoLidasCountProvider = Provider<int>((ref) {
  final notificacoesAsync = ref.watch(notificacoesAtivasProvider);
  
  return notificacoesAsync.when(
    data: (notificacoes) => notificacoes.where((n) => !n.lida).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para notificações agrupadas por tipo
final notificacoesAgrupadasProvider = Provider<Map<TipoNotificacao, List<Notificacao>>>((ref) {
  final notificacoesAsync = ref.watch(notificacoesAtivasProvider);
  
  return notificacoesAsync.when(
    data: (notificacoes) {
      final Map<TipoNotificacao, List<Notificacao>> agrupadas = {};
      
      for (final tipo in TipoNotificacao.values) {
        agrupadas[tipo] = notificacoes.where((n) => n.tipo == tipo).toList();
      }
      
      return agrupadas;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider para inicializar o serviço de notificações
final initializeNotificationsProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationsServiceProvider);
  await service.initialize();
});

