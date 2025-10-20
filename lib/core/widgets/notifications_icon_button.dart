import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/notifications_provider.dart';

/// Botão de notificações com badge indicando quantidade não lida
class NotificationsIconButton extends ConsumerWidget {
  const NotificationsIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countNaoLidas = ref.watch(notificacoesNaoLidasCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Navegar para página de notificações
            context.push('/notifications');
          },
          tooltip: 'Notificações',
        ),
        if (countNaoLidas > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                countNaoLidas > 99 ? '99+' : countNaoLidas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

