import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de mensagem do chat do plantão
class ChatMensagem {
  final String id;
  final String texto;
  final String remetenteId; // email do usuário
  final String remetenteNome;
  final DateTime dataEnvio;
  final String plantaoData; // Data do plantão no formato 'yyyy-MM-dd'

  ChatMensagem({
    required this.id,
    required this.texto,
    required this.remetenteId,
    required this.remetenteNome,
    required this.dataEnvio,
    required this.plantaoData,
  });

  factory ChatMensagem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMensagem(
      id: doc.id,
      texto: data['texto'] ?? '',
      remetenteId: data['remetenteId'] ?? '',
      remetenteNome: data['remetenteNome'] ?? '',
      dataEnvio: (data['dataEnvio'] as Timestamp).toDate(),
      plantaoData: data['plantaoData'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'texto': texto,
      'remetenteId': remetenteId,
      'remetenteNome': remetenteNome,
      'dataEnvio': Timestamp.fromDate(dataEnvio),
      'plantaoData': plantaoData,
    };
  }

  /// Verifica se a mensagem é do usuário atual
  bool isMinhamensagem(String userEmail) {
    return remetenteId == userEmail;
  }
}

