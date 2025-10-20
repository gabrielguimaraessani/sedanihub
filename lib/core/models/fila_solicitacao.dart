import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de fila
enum TipoFila {
  banheiro('banheiro', 'Banheiro', '🚽'),
  alimentacao('alimentacao', 'Alimentação', '🍽️');

  final String value;
  final String label;
  final String emoji;
  
  const TipoFila(this.value, this.label, this.emoji);

  static TipoFila fromString(String? value) {
    if (value == null) return TipoFila.banheiro;
    return TipoFila.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoFila.banheiro,
    );
  }
}

/// Modelo de solicitação de fila (banheiro ou alimentação)
class FilaSolicitacao {
  final String id;
  final TipoFila tipo;
  final String? servicoId; // Opcional - apenas para referência se houver
  final String solicitadoPor; // email do usuário que solicitou
  final String solicitadoPorNome; // Nome de quem está solicitando
  final DateTime dataSolicitacao;
  final DateTime? dataConclusao;
  final bool concluida;
  final String? concluidaPor; // email do usuário que concluiu
  final String? concluidaPorNome;
  final String? observacoes;
  final DateTime? dataExpiracao; // 2h após solicitação

  FilaSolicitacao({
    required this.id,
    required this.tipo,
    this.servicoId,
    required this.solicitadoPor,
    required this.solicitadoPorNome,
    required this.dataSolicitacao,
    this.dataConclusao,
    this.concluida = false,
    this.concluidaPor,
    this.concluidaPorNome,
    this.observacoes,
    DateTime? dataExpiracao,
  }) : dataExpiracao = dataExpiracao ?? dataSolicitacao.add(const Duration(hours: 2));

  factory FilaSolicitacao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FilaSolicitacao(
      id: doc.id,
      tipo: TipoFila.fromString(data['tipo']),
      servicoId: data['servicoId'],
      solicitadoPor: data['solicitadoPor'] ?? '',
      solicitadoPorNome: data['solicitadoPorNome'] ?? '',
      dataSolicitacao: (data['dataSolicitacao'] as Timestamp).toDate(),
      dataConclusao: (data['dataConclusao'] as Timestamp?)?.toDate(),
      concluida: data['concluida'] ?? false,
      concluidaPor: data['concluidaPor'],
      concluidaPorNome: data['concluidaPorNome'],
      observacoes: data['observacoes'],
      dataExpiracao: (data['dataExpiracao'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo.value,
      'servicoId': servicoId,
      'solicitadoPor': solicitadoPor,
      'solicitadoPorNome': solicitadoPorNome,
      'dataSolicitacao': Timestamp.fromDate(dataSolicitacao),
      'dataConclusao': dataConclusao != null ? Timestamp.fromDate(dataConclusao!) : null,
      'concluida': concluida,
      'concluidaPor': concluidaPor,
      'concluidaPorNome': concluidaPorNome,
      'observacoes': observacoes,
      'dataExpiracao': Timestamp.fromDate(dataExpiracao!),
    };
  }

  FilaSolicitacao copyWith({
    String? id,
    TipoFila? tipo,
    String? servicoId,
    String? solicitadoPor,
    String? solicitadoPorNome,
    DateTime? dataSolicitacao,
    DateTime? dataConclusao,
    bool? concluida,
    String? concluidaPor,
    String? concluidaPorNome,
    String? observacoes,
    DateTime? dataExpiracao,
  }) {
    return FilaSolicitacao(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      servicoId: servicoId ?? this.servicoId,
      solicitadoPor: solicitadoPor ?? this.solicitadoPor,
      solicitadoPorNome: solicitadoPorNome ?? this.solicitadoPorNome,
      dataSolicitacao: dataSolicitacao ?? this.dataSolicitacao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      concluida: concluida ?? this.concluida,
      concluidaPor: concluidaPor ?? this.concluidaPor,
      concluidaPorNome: concluidaPorNome ?? this.concluidaPorNome,
      observacoes: observacoes ?? this.observacoes,
      dataExpiracao: dataExpiracao ?? this.dataExpiracao,
    );
  }

  /// Verifica se a solicitação ainda é válida (não expirou)
  bool get isValida {
    if (concluida) return false;
    if (dataExpiracao == null) return false;
    return DateTime.now().isBefore(dataExpiracao!);
  }

  /// Tempo decorrido desde a solicitação
  Duration get tempoDecorrido {
    return DateTime.now().difference(dataSolicitacao);
  }

  /// Tempo restante até expiração
  Duration get tempoRestante {
    if (!isValida || dataExpiracao == null) return Duration.zero;
    return dataExpiracao!.difference(DateTime.now());
  }

  /// Cor de urgência baseada no tempo restante
  String get urgencia {
    if (concluida) return 'concluida';
    if (!isValida) return 'expirada';
    
    final minutos = tempoRestante.inMinutes;
    if (minutos > 90) return 'normal'; // >1h30
    if (minutos > 60) return 'atencao'; // >1h
    if (minutos > 30) return 'urgente'; // >30min
    return 'critico'; // <30min
  }
}

