import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Plantão
class Plantao {
  final String id;
  final String usuarioId;
  final DateTime data;
  final List<Turno> turnos;
  final int posicao;
  final DateTime? dataCriacao;
  final String? criadoPor;
  final DateTime? ultimaModificacao;
  final String? modificadoPor;

  Plantao({
    required this.id,
    required this.usuarioId,
    required this.data,
    required this.turnos,
    required this.posicao,
    this.dataCriacao,
    this.criadoPor,
    this.ultimaModificacao,
    this.modificadoPor,
  });

  /// Verifica se é coordenador (posição = 1)
  bool get isCoordenador => posicao == 1;

  factory Plantao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plantao(
      id: doc.id,
      usuarioId: data['usuario'] is DocumentReference
          ? (data['usuario'] as DocumentReference).id
          : data['usuario'].toString(),
      data: (data['data'] as Timestamp).toDate(),
      turnos: (data['turnos'] as List<dynamic>)
          .map((e) => Turno.fromString(e.toString()))
          .toList(),
      posicao: data['posicao'] ?? 1,
      dataCriacao: (data['dataCriacao'] as Timestamp?)?.toDate(),
      criadoPor: data['criadoPor'],
      ultimaModificacao: (data['ultimaModificacao'] as Timestamp?)?.toDate(),
      modificadoPor: data['modificadoPor'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuario': FirebaseFirestore.instance.doc('usuarios/$usuarioId'),
      'data': Timestamp.fromDate(data),
      'turnos': turnos.map((e) => e.value).toList(),
      'posicao': posicao,
      'dataCriacao': dataCriacao != null ? Timestamp.fromDate(dataCriacao!) : FieldValue.serverTimestamp(),
      'criadoPor': criadoPor,
      'ultimaModificacao': FieldValue.serverTimestamp(),
      'modificadoPor': modificadoPor,
    };
  }
}

enum Turno {
  manha('Manha'),
  tarde('Tarde'),
  noite('Noite');

  final String value;
  const Turno(this.value);

  static Turno fromString(String? value) {
    if (value == null) return Turno.manha;
    return Turno.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Turno.manha,
    );
  }
}

