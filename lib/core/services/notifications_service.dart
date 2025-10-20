import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notificacao.dart';

/// Serviço centralizado para gerenciar notificações
class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Singleton
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      // Configuração de notificações locais
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Verificar suporte a badge (apenas em plataformas nativas)
      try {
        final supported = await FlutterAppBadger.isAppBadgeSupported();
        print('📱 Badge suportado: $supported');
      } catch (e) {
        print('ℹ️ Badge não suportado nesta plataforma (provavelmente Web)');
      }
    } catch (e) {
      print('❌ Erro ao inicializar notificações: $e');
    }
  }

  /// Callback quando notificação é tocada
  void _onNotificationTap(NotificationResponse response) {
    print('📬 Notificação tocada: ${response.payload}');
    // TODO: Navegar para a tela apropriada baseado no payload
  }

  /// Atualiza o badge do app com o número de notificações não lidas
  Future<void> updateBadge(int count) async {
    try {
      // Verificar se a plataforma suporta badges
      final supported = await FlutterAppBadger.isAppBadgeSupported();
      if (!supported) return;
      
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    } catch (e) {
      // Silenciosamente ignora erro em plataformas não suportadas (Web)
      // print('ℹ️ Badge não disponível nesta plataforma');
    }
  }

  /// Stream de notificações ativas para o usuário atual
  Stream<List<Notificacao>> getNotificacoesAtivas() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notificacoes')
        .where('ativa', isEqualTo: true)
        .where('usuarioId', whereIn: [user.email, null]) // Para o usuário ou para todos
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) {
      final notificacoes = snapshot.docs
          .map((doc) => Notificacao.fromFirestore(doc))
          .where((n) => n.isValida)
          .toList();

      // Atualizar badge
      final naoLidas = notificacoes.where((n) => !n.lida).length;
      updateBadge(naoLidas);

      return notificacoes;
    });
  }

  /// Marca notificação como lida
  Future<void> marcarComoLida(String notificacaoId) async {
    try {
      await _firestore
          .collection('notificacoes')
          .doc(notificacaoId)
          .update({'lida': true});
    } catch (e) {
      print('❌ Erro ao marcar notificação como lida: $e');
    }
  }

  /// Marca notificação como inativa
  Future<void> desativarNotificacao(String notificacaoId) async {
    try {
      await _firestore
          .collection('notificacoes')
          .doc(notificacaoId)
          .update({'ativa': false});
    } catch (e) {
      print('❌ Erro ao desativar notificação: $e');
    }
  }

  /// Cria notificação de fila de banheiro
  Future<void> criarNotificacaoFilaBanheiro({
    required String solicitanteNome,
    required String servicoId,
  }) async {
    final now = DateTime.now();
    final expiracao = now.add(const Duration(hours: 2));

    final dados = DadosFilaNotificacao(
      solicitanteNome: solicitanteNome,
      servicoId: servicoId,
      dataSolicitacao: now,
    );

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.filaBanheiro,
      titulo: 'Fila de Banheiro',
      mensagem: '$solicitanteNome solicitou entrada na fila de banheiro',
      referenciaId: servicoId,
      dataCriacao: now,
      dataExpiracao: expiracao,
      dados: dados.toMap(),
    );

    await _criarNotificacao(notificacao);
  }

  /// Cria notificação de fila de alimentação
  Future<void> criarNotificacaoFilaAlimentacao({
    required String solicitanteNome,
    required String servicoId,
  }) async {
    final now = DateTime.now();
    final expiracao = now.add(const Duration(hours: 2));

    final dados = DadosFilaNotificacao(
      solicitanteNome: solicitanteNome,
      servicoId: servicoId,
      dataSolicitacao: now,
    );

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.filaAlimentacao,
      titulo: 'Fila de Alimentação',
      mensagem: '$solicitanteNome solicitou entrada na fila de alimentação',
      referenciaId: servicoId,
      dataCriacao: now,
      dataExpiracao: expiracao,
      dados: dados.toMap(),
    );

    await _criarNotificacao(notificacao);
  }

  /// Cria notificação de demanda RPA
  Future<void> criarNotificacaoDemandaRpa({
    required String servicoId,
    required String descricao,
  }) async {
    final now = DateTime.now();
    final expiracao = now.add(const Duration(hours: 2));

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.demandaRpa,
      titulo: 'Demanda RPA',
      mensagem: descricao,
      referenciaId: servicoId,
      dataCriacao: now,
      dataExpiracao: expiracao,
    );

    await _criarNotificacao(notificacao);
  }

  /// Cria notificação de termo de consentimento
  Future<void> criarNotificacaoTermoConsentimento({
    required String procedimentoNome,
    required String servicoId,
  }) async {
    final now = DateTime.now();
    final expiracao = now.add(const Duration(hours: 4));

    final dados = DadosTermoNotificacao(
      procedimentoNome: procedimentoNome,
      servicoId: servicoId,
      dataSolicitacao: now,
    );

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.termoConsentimento,
      titulo: 'Termo de Consentimento',
      mensagem: 'Aplicação de termo necessária: $procedimentoNome',
      referenciaId: servicoId,
      dataCriacao: now,
      dataExpiracao: expiracao,
      dados: dados.toMap(),
    );

    await _criarNotificacao(notificacao);
  }

  /// Cria notificação de tarefa atribuída
  Future<void> criarNotificacaoTarefaAtribuida({
    required String usuarioId,
    required String servicoId,
    required DateTime horarioProcedimento,
    required String procedimentoNome,
  }) async {
    final now = DateTime.now();
    final expiracao = horarioProcedimento.add(const Duration(hours: 1));

    final dados = DadosTarefaNotificacao(
      servicoId: servicoId,
      horarioProcedimento: horarioProcedimento,
      procedimentoNome: procedimentoNome,
    );

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.tarefaAtribuida,
      titulo: 'Tarefa Atribuída',
      mensagem: 'Você foi atribuído ao procedimento: $procedimentoNome',
      usuarioId: usuarioId,
      referenciaId: servicoId,
      dataCriacao: now,
      dataExpiracao: expiracao,
      dados: dados.toMap(),
    );

    await _criarNotificacao(notificacao);
    await _showLocalNotification(notificacao);
  }

  /// Cria notificação de quiz educativo
  Future<void> criarNotificacaoQuizEducativo({
    required List<String> usuariosIds,
    required String quizId,
    required String quizTitulo,
  }) async {
    final now = DateTime.now();

    final dados = DadosQuizNotificacao(
      quizId: quizId,
      quizTitulo: quizTitulo,
      dataDisponibilizacao: now,
    );

    // Criar uma notificação para cada usuário
    for (final usuarioId in usuariosIds) {
      final notificacao = Notificacao(
        id: '',
        tipo: TipoNotificacao.quizEducativo,
        titulo: 'Quiz Educativo Disponível',
        mensagem: quizTitulo,
        usuarioId: usuarioId,
        referenciaId: quizId,
        dataCriacao: now,
        dataExpiracao: null, // Sem expiração, válido até fazer o quiz
        dados: dados.toMap(),
      );

      await _criarNotificacao(notificacao);
    }
  }

  /// Cria notificação de confirmação de produção
  Future<void> criarNotificacaoConfirmacaoProducao({
    required String usuarioId,
    required String mes,
    required int ano,
  }) async {
    final now = DateTime.now();
    final expiracao = now.add(const Duration(days: 10));

    final notificacao = Notificacao(
      id: '',
      tipo: TipoNotificacao.confirmacaoProducao,
      titulo: 'Confirmação de Produção',
      mensagem: 'Confirme sua produção de $mes/$ano',
      usuarioId: usuarioId,
      dataCriacao: now,
      dataExpiracao: expiracao,
      dados: {'mes': mes, 'ano': ano},
    );

    await _criarNotificacao(notificacao);
  }

  /// Cria notificação no Firestore
  Future<void> _criarNotificacao(Notificacao notificacao) async {
    try {
      await _firestore.collection('notificacoes').add(notificacao.toFirestore());
      print('✅ Notificação criada: ${notificacao.titulo}');
    } catch (e) {
      print('❌ Erro ao criar notificação: $e');
    }
  }

  /// Exibe notificação local
  Future<void> _showLocalNotification(Notificacao notificacao) async {
    const androidDetails = AndroidNotificationDetails(
      'sedanihub_channel',
      'SedaniHub Notificações',
      channelDescription: 'Notificações do sistema SedaniHub',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificacao.id.hashCode,
      notificacao.titulo,
      notificacao.mensagem,
      details,
      payload: notificacao.referenciaId,
    );
  }

  /// Remove notificações expiradas de um serviço
  Future<void> limparNotificacoesServico(String servicoId) async {
    try {
      final snapshot = await _firestore
          .collection('notificacoes')
          .where('referenciaId', isEqualTo: servicoId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'ativa': false});
      }
    } catch (e) {
      print('❌ Erro ao limpar notificações do serviço: $e');
    }
  }

  /// Desativa notificações por tipo e referência
  Future<void> desativarNotificacoesPorReferencia({
    required String referenciaId,
    TipoNotificacao? tipo,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('notificacoes')
          .where('referenciaId', isEqualTo: referenciaId)
          .where('ativa', isEqualTo: true);

      if (tipo != null) {
        query = query.where('tipo', isEqualTo: tipo.value);
      }

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'ativa': false});
      }

      print('✅ ${snapshot.docs.length} notificações desativadas para referência: $referenciaId');
    } catch (e) {
      print('❌ Erro ao desativar notificações: $e');
    }
  }
}

