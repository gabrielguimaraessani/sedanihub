# 📘 Exemplo de Integração - Sistema de Notificações

Este documento mostra exemplos práticos de como integrar o sistema de notificações com as funcionalidades existentes do app.

## 1. Notificação ao Atribuir Anestesista a Serviço

### Cenário
Quando um anestesista é atribuído a um serviço na página de Distribuição de Serviços, criar uma notificação para ele.

### Implementação

```dart
// Em: lib/features/servicos/domain/services/distribuicao_service.dart

import '../../../core/services/notifications_service.dart';

class DistribuicaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsService _notificationsService = NotificationsService();
  
  Future<void> atribuirAnestesista({
    required String servicoId,
    required String anestesistaId,
    required String anestesistaEmail,
    required DateTime inicioServico,
    required String procedimentoNome,
  }) async {
    try {
      // 1. Criar subcoleção de anestesistas no serviço
      await _firestore
          .collection('servicos')
          .doc(servicoId)
          .collection('anestesistas')
          .doc(anestesistaId)
          .set({
        'inicio': Timestamp.fromDate(inicioServico),
        'fim': null,
        'medico': _firestore.doc('usuarios/$anestesistaEmail'),
        'dataCriacao': FieldValue.serverTimestamp(),
        'criadoPor': _firestore.doc('usuarios/${FirebaseAuth.instance.currentUser?.email}'),
      });

      // 2. Criar notificação para o anestesista
      await _notificationsService.criarNotificacaoTarefaAtribuida(
        usuarioId: anestesistaEmail,
        servicoId: servicoId,
        horarioProcedimento: inicioServico,
        procedimentoNome: procedimentoNome,
      );

      print('✅ Anestesista atribuído e notificação enviada');
    } catch (e) {
      print('❌ Erro ao atribuir anestesista: $e');
      rethrow;
    }
  }
}
```

## 2. Notificação de Fila de Banheiro

### Cenário
Quando um paciente entra na fila de banheiro, notificar todos os usuários.

### Implementação

```dart
// Em: lib/features/servicos/presentation/pages/servicos_pendentes_page.dart

Future<void> _adicionarFilaBanheiro(String servicoId, String pacienteNome) async {
  try {
    // 1. Atualizar status do serviço
    await FirebaseFirestore.instance
        .collection('servicos')
        .doc(servicoId)
        .update({
      'filaBanheiro': true,
      'dataEntradaFilaBanheiro': FieldValue.serverTimestamp(),
    });

    // 2. Criar notificação
    await ref.read(notificationsServiceProvider).criarNotificacaoFilaBanheiro(
      solicitanteNome: pacienteNome,
      servicoId: servicoId,
    );

    // 3. Mostrar feedback ao usuário
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$pacienteNome adicionado à fila de banheiro'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print('❌ Erro ao adicionar à fila: $e');
  }
}
```

## 3. Limpar Notificações ao Concluir Serviço

### Cenário
Quando um serviço é concluído, desativar todas as notificações relacionadas a ele.

### Implementação

```dart
// Em: lib/features/servicos/presentation/pages/servicos_pendentes_page.dart

Future<void> _concluirServico(String servicoId) async {
  try {
    // 1. Marcar serviço como finalizado
    await FirebaseFirestore.instance
        .collection('servicos')
        .doc(servicoId)
        .update({
      'finalizado': true,
      'dataFinalizacao': FieldValue.serverTimestamp(),
    });

    // 2. Limpar todas as notificações do serviço
    await ref.read(notificationsServiceProvider).limparNotificacoesServico(servicoId);

    // 3. Feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço concluído e notificações limpas'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print('❌ Erro ao concluir serviço: $e');
  }
}
```

## 4. Notificação de Termo de Consentimento

### Cenário
Quando um termo de consentimento precisa ser aplicado.

### Implementação

```dart
// Em: lib/features/servicos/presentation/pages/servicos_pendentes_page.dart

Future<void> _solicitarTermoConsentimento(
  String servicoId,
  String procedimentoNome,
) async {
  try {
    // 1. Atualizar status do serviço
    await FirebaseFirestore.instance
        .collection('servicos')
        .doc(servicoId)
        .update({
      'termoConsentimentoPendente': true,
      'dataSolicitacaoTermo': FieldValue.serverTimestamp(),
    });

    // 2. Criar notificação
    await ref.read(notificationsServiceProvider).criarNotificacaoTermoConsentimento(
      procedimentoNome: procedimentoNome,
      servicoId: servicoId,
    );

    print('✅ Notificação de termo de consentimento criada');
  } catch (e) {
    print('❌ Erro ao solicitar termo: $e');
  }
}
```

## 5. Notificação de Quiz Educativo

### Cenário
Time de qualidade disponibiliza um novo quiz para usuários específicos.

### Implementação

```dart
// Em: lib/features/qualidade/presentation/pages/criar_quiz_page.dart

Future<void> _publicarQuiz({
  required String quizId,
  required String quizTitulo,
  required List<String> destinatarios,
}) async {
  try {
    // 1. Publicar quiz no Firestore
    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(quizId)
        .update({
      'publicado': true,
      'dataPublicacao': FieldValue.serverTimestamp(),
    });

    // 2. Criar notificações para os destinatários
    await ref.read(notificationsServiceProvider).criarNotificacaoQuizEducativo(
      usuariosIds: destinatarios,
      quizId: quizId,
      quizTitulo: quizTitulo,
    );

    // 3. Feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz publicado para ${destinatarios.length} usuários'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    print('❌ Erro ao publicar quiz: $e');
  }
}
```

## 6. Notificação de Confirmação de Produção

### Cenário
No início de cada mês, notificar usuários para confirmar produção do mês anterior.

### Implementação

```dart
// Em: lib/core/services/producao_mensal_service.dart

class ProducaoMensalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsService _notificationsService = NotificationsService();

  /// Envia notificações de confirmação de produção para todos os usuários
  Future<void> enviarNotificacoesConfirmacaoProducao({
    required int mes,
    required int ano,
  }) async {
    try {
      // 1. Buscar todos os usuários ativos
      final usuariosSnapshot = await _firestore
          .collection('usuarios')
          .where('ativo', isEqualTo: true)
          .get();

      // 2. Criar notificação para cada usuário
      for (final doc in usuariosSnapshot.docs) {
        final email = doc.id;
        await _notificationsService.criarNotificacaoConfirmacaoProducao(
          usuarioId: email,
          mes: _getNomeMes(mes),
          ano: ano,
        );
      }

      print('✅ Notificações de produção enviadas para ${usuariosSnapshot.docs.length} usuários');
    } catch (e) {
      print('❌ Erro ao enviar notificações de produção: $e');
    }
  }

  String _getNomeMes(int mes) {
    const meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return meses[mes - 1];
  }
}

// Agendar job mensal (Cloud Functions ou scheduled task)
// Executar no dia 1 de cada mês às 8h
```

## 7. Widget de Resumo de Notificações no Dashboard

### Cenário
Mostrar um card com resumo das notificações no dashboard.

### Implementação

```dart
// Em: lib/features/dashboard/presentation/widgets/notifications_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/notifications_provider.dart';

class NotificationsSummaryCard extends ConsumerWidget {
  const NotificationsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificacoesAgrupadas = ref.watch(notificacoesAgrupadasProvider);
    final totalNaoLidas = ref.watch(notificacoesNaoLidasCountProvider);

    if (totalNaoLidas == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/notifications'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Você tem $totalNaoLidas notificações não lidas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Resumo por tipo
              ...notificacoesAgrupadas.entries
                  .where((entry) => entry.value.isNotEmpty)
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${entry.key.label}: ${entry.value.length}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      )),
              const SizedBox(height: 8),
              const Text(
                'Toque para ver detalhes',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 8. Listener de Notificações para Ações Automáticas

### Cenário
Monitorar notificações e realizar ações automáticas (ex: logging, analytics).

### Implementação

```dart
// Em: lib/core/services/notifications_listener_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/notificacao.dart';

class NotificationsListenerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance';
  
  StreamSubscription<QuerySnapshot>? _subscription;

  /// Inicia monitoramento de notificações
  void startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription = _firestore
        .collection('notificacoes')
        .where('usuarioId', whereIn: [user.email, null])
        .where('ativa', isEqualTo: true)
        .where('lida', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notificacao = Notificacao.fromFirestore(change.doc);
          _handleNewNotification(notificacao);
        }
      }
    });
  }

  void _handleNewNotification(Notificacao notificacao) {
    print('🔔 Nova notificação: ${notificacao.titulo}');
    
    // Analytics
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'notification_received',
    //   parameters: {
    //     'tipo': notificacao.tipo.value,
    //     'titulo': notificacao.titulo,
    //   },
    // );

    // Outras ações automáticas baseadas no tipo
    switch (notificacao.tipo) {
      case TipoNotificacao.tarefaAtribuida:
        // Ex: vibrar o dispositivo
        // Haptic.vibrate();
        break;
      case TipoNotificacao.demandaRpa:
        // Ex: tocar som de urgência
        // AudioPlayer().play('urgente.mp3');
        break;
      default:
        break;
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
```

## 🎯 Resumo de Integração

1. **Sempre criar notificação** quando houver uma ação que outros usuários precisam saber
2. **Sempre limpar notificações** quando a ação relacionada for concluída ou cancelada
3. **Use os providers** para monitorar notificações em tempo real na UI
4. **Marque como lida** quando o usuário visualizar
5. **Respeite as regras de expiração** de cada tipo de notificação

## 📝 Checklist de Integração

- [ ] Identificar pontos onde notificações devem ser criadas
- [ ] Implementar criação de notificações nesses pontos
- [ ] Implementar limpeza de notificações ao concluir/cancelar
- [ ] Testar criação e expiração de notificações
- [ ] Testar badge no ícone do app
- [ ] Testar marcação como lida
- [ ] Configurar índices no Firestore
- [ ] Configurar regras de segurança
- [ ] Documentar comportamento específico

