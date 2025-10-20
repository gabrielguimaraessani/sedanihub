import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/fila_solicitacao.dart';
import '../models/notificacao.dart';
import 'notifications_service.dart';

/// Serviço para gerenciar filas de banheiro e alimentação
class FilasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationsService _notificationsService = NotificationsService();

  // Singleton
  static final FilasService _instance = FilasService._internal();
  factory FilasService() => _instance;
  FilasService._internal();

  /// Stream de solicitações ativas (não concluídas e não expiradas)
  Stream<List<FilaSolicitacao>> getSolicitacoesAtivas() {
    final agora = Timestamp.now();
    
    return _firestore
        .collection('filas_solicitacoes')
        .where('concluida', isEqualTo: false)
        .where('dataExpiracao', isGreaterThan: agora)
        .orderBy('dataExpiracao')
        .orderBy('dataSolicitacao')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FilaSolicitacao.fromFirestore(doc))
          .where((s) => s.isValida)
          .toList();
    });
  }

  /// Stream de solicitações de um tipo específico
  Stream<List<FilaSolicitacao>> getSolicitacoesPorTipo(TipoFila tipo) {
    final agora = Timestamp.now();
    
    return _firestore
        .collection('filas_solicitacoes')
        .where('tipo', isEqualTo: tipo.value)
        .where('concluida', isEqualTo: false)
        .where('dataExpiracao', isGreaterThan: agora)
        .orderBy('dataExpiracao')
        .orderBy('dataSolicitacao')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FilaSolicitacao.fromFirestore(doc))
          .where((s) => s.isValida)
          .toList();
    });
  }

  /// Stream de histórico de solicitações (todas, incluindo concluídas)
  Stream<List<FilaSolicitacao>> getHistoricoSolicitacoes({
    TipoFila? tipo,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection('filas_solicitacoes')
        .orderBy('dataSolicitacao', descending: true)
        .limit(limit);

    if (tipo != null) {
      query = query.where('tipo', isEqualTo: tipo.value);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FilaSolicitacao.fromFirestore(doc))
          .toList();
    });
  }

  /// Cria uma solicitação de fila (simplificada - usa nome do usuário atual)
  Future<String> criarSolicitacao({
    required TipoFila tipo,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final agora = DateTime.now();
      final expiracao = agora.add(const Duration(hours: 2));

      // Buscar nome do usuário
      final userDoc = await _firestore.collection('usuarios').doc(user.email).get();
      final userName = userDoc.exists 
          ? (userDoc.data()?['nomeCompleto'] as String?) ?? user.email!.split('@').first
          : user.email!.split('@').first;

      final solicitacao = FilaSolicitacao(
        id: '',
        tipo: tipo,
        servicoId: null, // Não mais necessário
        solicitadoPor: user.email!,
        solicitadoPorNome: userName,
        dataSolicitacao: agora,
        dataExpiracao: expiracao,
      );

      // Salvar no Firestore
      final docRef = await _firestore
          .collection('filas_solicitacoes')
          .add(solicitacao.toFirestore());

      print('✅ Solicitação de ${tipo.label} criada: ${docRef.id}');

      // Criar notificação
      if (tipo == TipoFila.banheiro) {
        await _notificationsService.criarNotificacaoFilaBanheiro(
          solicitanteNome: userName,
          servicoId: docRef.id, // Usa o ID da solicitação como referência
        );
      } else if (tipo == TipoFila.alimentacao) {
        await _notificationsService.criarNotificacaoFilaAlimentacao(
          solicitanteNome: userName,
          servicoId: docRef.id, // Usa o ID da solicitação como referência
        );
      }

      return docRef.id;
    } catch (e) {
      print('❌ Erro ao criar solicitação de fila: $e');
      rethrow;
    }
  }

  /// Marca uma solicitação como concluída
  Future<void> marcarComoConcluida(
    String solicitacaoId, {
    String? observacoes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Buscar a solicitação para obter o servicoId e tipo
      final solicitacaoDoc = await _firestore
          .collection('filas_solicitacoes')
          .doc(solicitacaoId)
          .get();

      if (!solicitacaoDoc.exists) {
        throw Exception('Solicitação não encontrada');
      }

      final solicitacao = FilaSolicitacao.fromFirestore(solicitacaoDoc);

      // Buscar nome do usuário
      final userDoc = await _firestore.collection('usuarios').doc(user.email).get();
      final userName = userDoc.exists 
          ? (userDoc.data()?['nomeCompleto'] as String?) ?? user.email!.split('@').first
          : user.email!.split('@').first;

      // Atualizar solicitação
      await _firestore
          .collection('filas_solicitacoes')
          .doc(solicitacaoId)
          .update({
        'concluida': true,
        'dataConclusao': FieldValue.serverTimestamp(),
        'concluidaPor': user.email,
        'concluidaPorNome': userName,
        if (observacoes != null) 'observacoes': observacoes,
      });

      // Desativar notificações relacionadas à fila
      final tipoNotificacao = solicitacao.tipo == TipoFila.banheiro
          ? TipoNotificacao.filaBanheiro
          : TipoNotificacao.filaAlimentacao;

      // Usa o próprio ID da solicitação como referência
      await _notificationsService.desativarNotificacoesPorReferencia(
        referenciaId: solicitacaoId,
        tipo: tipoNotificacao,
      );
      
      print('✅ Solicitação marcada como concluída e notificações desativadas: $solicitacaoId');
    } catch (e) {
      print('❌ Erro ao marcar solicitação como concluída: $e');
      rethrow;
    }
  }

  /// Cancela uma solicitação (apenas quem criou pode cancelar)
  Future<void> cancelarSolicitacao(String solicitacaoId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final doc = await _firestore
          .collection('filas_solicitacoes')
          .doc(solicitacaoId)
          .get();

      if (!doc.exists) {
        throw Exception('Solicitação não encontrada');
      }

      final solicitacao = FilaSolicitacao.fromFirestore(doc);

      // Apenas quem criou pode cancelar
      if (solicitacao.solicitadoPor != user.email) {
        throw Exception('Apenas quem criou a solicitação pode cancelá-la');
      }

      // Marcar como concluída com observação de cancelamento
      await marcarComoConcluida(
        solicitacaoId,
        observacoes: 'Cancelada pelo solicitante',
      );

      print('✅ Solicitação cancelada: $solicitacaoId');
    } catch (e) {
      print('❌ Erro ao cancelar solicitação: $e');
      rethrow;
    }
  }

  /// Estatísticas de solicitações por tipo
  Future<Map<String, int>> getEstatisticas({
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('filas_solicitacoes')
          .where('dataSolicitacao', isGreaterThanOrEqualTo: Timestamp.fromDate(dataInicio))
          .where('dataSolicitacao', isLessThanOrEqualTo: Timestamp.fromDate(dataFim))
          .get();

      int totalBanheiro = 0;
      int totalAlimentacao = 0;
      int totalConcluidas = 0;
      int totalExpiradas = 0;

      for (final doc in snapshot.docs) {
        final solicitacao = FilaSolicitacao.fromFirestore(doc);
        
        if (solicitacao.tipo == TipoFila.banheiro) {
          totalBanheiro++;
        } else {
          totalAlimentacao++;
        }

        if (solicitacao.concluida) {
          totalConcluidas++;
        } else if (!solicitacao.isValida) {
          totalExpiradas++;
        }
      }

      return {
        'totalBanheiro': totalBanheiro,
        'totalAlimentacao': totalAlimentacao,
        'totalConcluidas': totalConcluidas,
        'totalExpiradas': totalExpiradas,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      print('❌ Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  /// Limpa solicitações expiradas (job de manutenção)
  Future<void> limparSolicitacoesExpiradas() async {
    try {
      final agora = Timestamp.now();
      
      final snapshot = await _firestore
          .collection('filas_solicitacoes')
          .where('concluida', isEqualTo: false)
          .where('dataExpiracao', isLessThan: agora)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'concluida': true,
          'dataConclusao': FieldValue.serverTimestamp(),
          'concluidaPor': 'system',
          'concluidaPorNome': 'Sistema (Expirado)',
          'observacoes': 'Solicitação expirada automaticamente após 2 horas',
        });
      }

      print('✅ ${snapshot.docs.length} solicitações expiradas foram limpas');
    } catch (e) {
      print('❌ Erro ao limpar solicitações expiradas: $e');
    }
  }
}

