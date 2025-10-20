import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fila_solicitacao.dart';
import '../services/filas_service.dart';

/// Provider do serviço de filas
final filasServiceProvider = Provider<FilasService>((ref) {
  return FilasService();
});

/// Provider para stream de todas as solicitações ativas
final solicitacoesAtivasProvider = StreamProvider<List<FilaSolicitacao>>((ref) {
  final service = ref.watch(filasServiceProvider);
  return service.getSolicitacoesAtivas();
});

/// Provider para stream de solicitações de banheiro
final solicitacoesBanheiroProvider = StreamProvider<List<FilaSolicitacao>>((ref) {
  final service = ref.watch(filasServiceProvider);
  return service.getSolicitacoesPorTipo(TipoFila.banheiro);
});

/// Provider para stream de solicitações de alimentação
final solicitacoesAlimentacaoProvider = StreamProvider<List<FilaSolicitacao>>((ref) {
  final service = ref.watch(filasServiceProvider);
  return service.getSolicitacoesPorTipo(TipoFila.alimentacao);
});

/// Provider para contagem total de solicitações ativas
final totalSolicitacoesAtivasProvider = Provider<int>((ref) {
  final solicitacoesAsync = ref.watch(solicitacoesAtivasProvider);
  
  return solicitacoesAsync.when(
    data: (solicitacoes) => solicitacoes.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para contagem de solicitações por tipo
final contagemPorTipoProvider = Provider<Map<TipoFila, int>>((ref) {
  final solicitacoesAsync = ref.watch(solicitacoesAtivasProvider);
  
  return solicitacoesAsync.when(
    data: (solicitacoes) {
      final Map<TipoFila, int> contagem = {
        TipoFila.banheiro: 0,
        TipoFila.alimentacao: 0,
      };
      
      for (final solicitacao in solicitacoes) {
        contagem[solicitacao.tipo] = (contagem[solicitacao.tipo] ?? 0) + 1;
      }
      
      return contagem;
    },
    loading: () => {TipoFila.banheiro: 0, TipoFila.alimentacao: 0},
    error: (_, __) => {TipoFila.banheiro: 0, TipoFila.alimentacao: 0},
  );
});

/// Provider para solicitações críticas (menos de 30 minutos restantes)
final solicitacoesCriticasProvider = Provider<List<FilaSolicitacao>>((ref) {
  final solicitacoesAsync = ref.watch(solicitacoesAtivasProvider);
  
  return solicitacoesAsync.when(
    data: (solicitacoes) {
      return solicitacoes.where((s) => s.urgencia == 'critico').toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para histórico de solicitações
final historicoSolicitacoesProvider = StreamProvider.family<List<FilaSolicitacao>, TipoFila?>(
  (ref, tipo) {
    final service = ref.watch(filasServiceProvider);
    return service.getHistoricoSolicitacoes(tipo: tipo);
  },
);

