import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/notificacao.dart';
import '../../../../core/providers/notifications_provider.dart';

/// Página de notificações
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacoesAsync = ref.watch(notificacoesAtivasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          // Marcar todas como lidas
          notificacoesAsync.when(
            data: (notificacoes) {
              final temNaoLidas = notificacoes.any((n) => !n.lida);
              if (!temNaoLidas) return const SizedBox.shrink();
              
              return TextButton(
                onPressed: () async {
                  final service = ref.read(notificationsServiceProvider);
                  for (final notif in notificacoes.where((n) => !n.lida)) {
                    await service.marcarComoLida(notif.id);
                  }
                },
                child: const Text(
                  'Marcar todas como lidas',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificacoesAsync.when(
        data: (notificacoes) {
          if (notificacoes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma notificação',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notificacoes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notificacao = notificacoes[index];
              return _NotificacaoTile(notificacao: notificacao);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar notificações: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile de notificação individual
class _NotificacaoTile extends ConsumerWidget {
  final Notificacao notificacao;

  const _NotificacaoTile({required this.notificacao});

  IconData _getIconForTipo(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.filaBanheiro:
        return Icons.wc;
      case TipoNotificacao.filaAlimentacao:
        return Icons.restaurant;
      case TipoNotificacao.demandaRpa:
        return Icons.medical_services;
      case TipoNotificacao.termoConsentimento:
        return Icons.description;
      case TipoNotificacao.tarefaAtribuida:
        return Icons.assignment;
      case TipoNotificacao.quizEducativo:
        return Icons.quiz;
      case TipoNotificacao.confirmacaoProducao:
        return Icons.check_circle_outline;
    }
  }

  Color _getColorForTipo(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.filaBanheiro:
        return Colors.blue;
      case TipoNotificacao.filaAlimentacao:
        return Colors.orange;
      case TipoNotificacao.demandaRpa:
        return Colors.red;
      case TipoNotificacao.termoConsentimento:
        return Colors.purple;
      case TipoNotificacao.tarefaAtribuida:
        return Colors.green;
      case TipoNotificacao.quizEducativo:
        return Colors.teal;
      case TipoNotificacao.confirmacaoProducao:
        return Colors.indigo;
    }
  }

  String _formatarTempo(DateTime data) {
    final now = DateTime.now();
    final diff = now.difference(data);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}min atrás';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h atrás';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(data);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getColorForTipo(notificacao.tipo);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForTipo(notificacao.tipo),
          color: color,
        ),
      ),
      title: Text(
        notificacao.titulo,
        style: TextStyle(
          fontWeight: notificacao.lida ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notificacao.mensagem),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatarTempo(notificacao.dataCriacao),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (notificacao.dataExpiracao != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.timer, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Expira em ${_formatarTempo(notificacao.dataExpiracao!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: !notificacao.lida
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () async {
        // Marcar como lida
        if (!notificacao.lida) {
          final service = ref.read(notificationsServiceProvider);
          await service.marcarComoLida(notificacao.id);
        }

        // TODO: Navegar para a tela apropriada baseado no tipo
        _handleNotificationTap(context, notificacao);
      },
    );
  }

  void _handleNotificationTap(BuildContext context, Notificacao notificacao) {
    // Implementar navegação baseada no tipo de notificação
    switch (notificacao.tipo) {
      case TipoNotificacao.tarefaAtribuida:
        // Navegar para detalhes do serviço
        if (notificacao.referenciaId != null) {
          // context.push('/servicos/${notificacao.referenciaId}');
        }
        break;
      case TipoNotificacao.quizEducativo:
        // Navegar para quiz
        if (notificacao.referenciaId != null) {
          // context.push('/quiz/${notificacao.referenciaId}');
        }
        break;
      default:
        // Outras notificações podem ter ações específicas
        break;
    }
  }
}

