import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Serviço/Procedimento
class Servico {
  final String id;
  final List<String> procedimentosIds;
  final String pacienteId;
  final List<String> cirurgioesIds;
  final DateTime inicio;
  final int? duracao; // em minutos
  final LocalServico local;
  final String? leito;
  final String? tcle;
  final bool finalizado;
  final DateTime? dataCriacao;
  final String? criadoPor;
  final DateTime? ultimaModificacao;
  final String? modificadoPor;

  // Campos calculados
  DateTime? get fimPrevisto {
    if (duracao == null) return null;
    return inicio.add(Duration(minutes: duracao!));
  }

  Servico({
    required this.id,
    this.procedimentosIds = const [],
    required this.pacienteId,
    this.cirurgioesIds = const [],
    required this.inicio,
    this.duracao,
    required this.local,
    this.leito,
    this.tcle,
    this.finalizado = false,
    this.dataCriacao,
    this.criadoPor,
    this.ultimaModificacao,
    this.modificadoPor,
  });

  factory Servico.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Servico(
      id: doc.id,
      procedimentosIds: (data['procedimentos'] as List<dynamic>?)
              ?.map((e) {
                if (e is DocumentReference) return e.id;
                return e.toString();
              })
              .toList() ??
          [],
      pacienteId: data['paciente'] is DocumentReference
          ? (data['paciente'] as DocumentReference).id
          : data['paciente'].toString(),
      cirurgioesIds: (data['cirurgioes'] as List<dynamic>?)
              ?.map((e) {
                if (e is DocumentReference) return e.id;
                return e.toString();
              })
              .toList() ??
          [],
      inicio: (data['inicio'] as Timestamp).toDate(),
      duracao: data['duracao'],
      local: LocalServico.fromString(data['local']),
      leito: data['leito'],
      tcle: data['tcle'],
      finalizado: data['finalizado'] ?? false,
      dataCriacao: (data['dataCriacao'] as Timestamp?)?.toDate(),
      criadoPor: data['criadoPor'],
      ultimaModificacao: (data['ultimaModificacao'] as Timestamp?)?.toDate(),
      modificadoPor: data['modificadoPor'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'procedimentos': procedimentosIds
          .map((id) => FirebaseFirestore.instance.doc('procedimentos/$id'))
          .toList(),
      'paciente': FirebaseFirestore.instance.doc('pacientes/$pacienteId'),
      'cirurgioes': cirurgioesIds
          .map((id) => FirebaseFirestore.instance.doc('medicos/$id'))
          .toList(),
      'inicio': Timestamp.fromDate(inicio),
      'duracao': duracao,
      'local': local.value,
      'leito': leito,
      'tcle': tcle,
      'finalizado': finalizado,
      'dataCriacao': dataCriacao != null ? Timestamp.fromDate(dataCriacao!) : FieldValue.serverTimestamp(),
      'criadoPor': criadoPor,
      'ultimaModificacao': FieldValue.serverTimestamp(),
      'modificadoPor': modificadoPor,
    };
  }

  Servico copyWith({
    String? id,
    List<String>? procedimentosIds,
    String? pacienteId,
    List<String>? cirurgioesIds,
    DateTime? inicio,
    int? duracao,
    LocalServico? local,
    String? leito,
    String? tcle,
    bool? finalizado,
    DateTime? dataCriacao,
    String? criadoPor,
    DateTime? ultimaModificacao,
    String? modificadoPor,
  }) {
    return Servico(
      id: id ?? this.id,
      procedimentosIds: procedimentosIds ?? this.procedimentosIds,
      pacienteId: pacienteId ?? this.pacienteId,
      cirurgioesIds: cirurgioesIds ?? this.cirurgioesIds,
      inicio: inicio ?? this.inicio,
      duracao: duracao ?? this.duracao,
      local: local ?? this.local,
      leito: leito ?? this.leito,
      tcle: tcle ?? this.tcle,
      finalizado: finalizado ?? this.finalizado,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      criadoPor: criadoPor ?? this.criadoPor,
      ultimaModificacao: ultimaModificacao ?? this.ultimaModificacao,
      modificadoPor: modificadoPor ?? this.modificadoPor,
    );
  }
}

enum LocalServico {
  centroCirurgico('Centro Cirúrgico'),
  endoscopia('Endoscopia'),
  ressonanciaMagneticaUnidade4('Ressonancia magnética da Unidade IV'),
  ressonanciaMagneticaUnidade3('Ressonancia magnética da Unidade 3'),
  centroOncologia('Centro de oncologia'),
  tomografiaUnidade4('Tomografia da Unidade IV'),
  ultrassomUnidade4('Ultrassom Unidade IV');

  final String value;
  const LocalServico(this.value);

  static LocalServico fromString(String? value) {
    if (value == null) return LocalServico.centroCirurgico;
    return LocalServico.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LocalServico.centroCirurgico,
    );
  }
}

