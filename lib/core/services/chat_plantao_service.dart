import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/chat_mensagem.dart';

/// Serviço para gerenciar o chat do plantão
class ChatPlantaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton
  static final ChatPlantaoService _instance = ChatPlantaoService._internal();
  factory ChatPlantaoService() => _instance;
  ChatPlantaoService._internal();

  /// Verifica se o usuário está no plantão de hoje
  Future<bool> usuarioEstaNoPlantaoHoje() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final inicioHoje = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
      final fimHoje = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

      // Buscar plantões do usuário para hoje
      final plantaoSnapshot = await _firestore
          .collection('plantoes')
          .where('usuario', isEqualTo: _firestore.doc('usuarios/${user.email}'))
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoje))
          .where('data', isLessThanOrEqualTo: Timestamp.fromDate(fimHoje))
          .limit(1)
          .get();

      return plantaoSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar plantão: $e');
      // Em caso de erro, permitir acesso (modo permissivo)
      return true;
    }
  }

  /// Stream de mensagens do plantão atual (apenas de hoje)
  Stream<List<ChatMensagem>> getMensagensPlantaoHoje() {
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return _firestore
        .collection('chat_plantao')
        .where('plantaoData', isEqualTo: hoje)
        .orderBy('dataEnvio', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMensagem.fromFirestore(doc))
          .toList();
    });
  }

  /// Envia uma mensagem para o chat do plantão
  Future<void> enviarMensagem(String texto) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verificar se está no plantão
      final estaNoPlantao = await usuarioEstaNoPlantaoHoje();
      if (!estaNoPlantao) {
        throw Exception('Você não está no plantão de hoje');
      }

      // Buscar nome do usuário
      final userDoc = await _firestore.collection('usuarios').doc(user.email).get();
      final userName = userDoc.exists 
          ? (userDoc.data()?['nomeCompleto'] as String?) ?? user.email!.split('@').first
          : user.email!.split('@').first;

      final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final mensagem = ChatMensagem(
        id: '',
        texto: texto.trim(),
        remetenteId: user.email!,
        remetenteNome: userName,
        dataEnvio: DateTime.now(),
        plantaoData: hoje,
      );

      await _firestore
          .collection('chat_plantao')
          .add(mensagem.toFirestore());

      print('✅ Mensagem enviada ao chat do plantão');
    } catch (e) {
      print('❌ Erro ao enviar mensagem: $e');
      rethrow;
    }
  }

  /// Limpa mensagens antigas (mais de 24h)
  Future<void> limparMensagensAntigas() async {
    try {
      final ontem = DateTime.now().subtract(const Duration(hours: 24));
      final dataOntem = DateFormat('yyyy-MM-dd').format(ontem);
      
      final snapshot = await _firestore
          .collection('chat_plantao')
          .where('plantaoData', isLessThan: dataOntem)
          .get();

      // Deletar em batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      print('✅ ${snapshot.docs.length} mensagens antigas foram removidas');
    } catch (e) {
      print('❌ Erro ao limpar mensagens antigas: $e');
    }
  }

  /// Obtém informações do plantão de hoje
  Future<Map<String, dynamic>> getInfoPlantaoHoje() async {
    try {
      final inicioHoje = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
      final fimHoje = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);

      final snapshot = await _firestore
          .collection('plantoes')
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioHoje))
          .where('data', isLessThanOrEqualTo: Timestamp.fromDate(fimHoje))
          .orderBy('data')
          .orderBy('posicao')
          .get();

      final plantonistas = <Map<String, dynamic>>[];
      String? coordenador;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final usuarioRef = data['usuario'] as DocumentReference?;
        
        if (usuarioRef != null) {
          final usuarioDoc = await usuarioRef.get();
          final usuarioData = usuarioDoc.data() as Map<String, dynamic>?;
          final nome = usuarioData?['nomeCompleto'] ?? usuarioDoc.id;
          final posicao = data['posicao'] as int?;

          if (posicao == 1) {
            coordenador = nome;
          }

          plantonistas.add({
            'nome': nome,
            'email': usuarioDoc.id,
            'posicao': posicao,
            'turnos': data['turnos'] ?? [],
          });
        }
      }

      return {
        'coordenador': coordenador,
        'plantonistas': plantonistas,
        'total': plantonistas.length,
      };
    } catch (e) {
      print('❌ Erro ao buscar info do plantão: $e');
      return {
        'coordenador': null,
        'plantonistas': [],
        'total': 0,
      };
    }
  }
}

