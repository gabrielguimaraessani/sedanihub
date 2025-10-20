import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de notificação no sistema
enum TipoNotificacao {
  filaBanheiro('fila_banheiro', 'Fila de Banheiro'),
  filaAlimentacao('fila_alimentacao', 'Fila de Alimentação'),
  demandaRpa('demanda_rpa', 'Demanda RPA'),
  termoConsentimento('termo_consentimento', 'Termo de Consentimento'),
  tarefaAtribuida('tarefa_atribuida', 'Tarefa Atribuída'),
  quizEducativo('quiz_educativo', 'Quiz Educativo'),
  confirmacaoProducao('confirmacao_producao', 'Confirmação de Produção');

  final String value;
  final String label;
  const TipoNotificacao(this.value, this.label);

  static TipoNotificacao fromString(String? value) {
    if (value == null) return TipoNotificacao.filaBanheiro;
    return TipoNotificacao.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoNotificacao.filaBanheiro,
    );
  }
}

/// Modelo de Notificação
class Notificacao {
  final String id;
  final TipoNotificacao tipo;
  final String titulo;
  final String mensagem;
  final String? usuarioId; // null = notificação para todos
  final String? referenciaId; // ID do serviço, tarefa, quiz, etc
  final DateTime dataCriacao;
  final DateTime? dataExpiracao;
  final bool lida;
  final bool ativa; // se ainda é válida baseado nas regras
  final Map<String, dynamic>? dados; // dados adicionais

  Notificacao({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    this.usuarioId,
    this.referenciaId,
    required this.dataCriacao,
    this.dataExpiracao,
    this.lida = false,
    this.ativa = true,
    this.dados,
  });

  factory Notificacao.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notificacao(
      id: doc.id,
      tipo: TipoNotificacao.fromString(data['tipo']),
      titulo: data['titulo'] ?? '',
      mensagem: data['mensagem'] ?? '',
      usuarioId: data['usuarioId'],
      referenciaId: data['referenciaId'],
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      dataExpiracao: (data['dataExpiracao'] as Timestamp?)?.toDate(),
      lida: data['lida'] ?? false,
      ativa: data['ativa'] ?? true,
      dados: data['dados'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo.value,
      'titulo': titulo,
      'mensagem': mensagem,
      'usuarioId': usuarioId,
      'referenciaId': referenciaId,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataExpiracao': dataExpiracao != null ? Timestamp.fromDate(dataExpiracao!) : null,
      'lida': lida,
      'ativa': ativa,
      'dados': dados,
    };
  }

  Notificacao copyWith({
    String? id,
    TipoNotificacao? tipo,
    String? titulo,
    String? mensagem,
    String? usuarioId,
    String? referenciaId,
    DateTime? dataCriacao,
    DateTime? dataExpiracao,
    bool? lida,
    bool? ativa,
    Map<String, dynamic>? dados,
  }) {
    return Notificacao(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      mensagem: mensagem ?? this.mensagem,
      usuarioId: usuarioId ?? this.usuarioId,
      referenciaId: referenciaId ?? this.referenciaId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataExpiracao: dataExpiracao ?? this.dataExpiracao,
      lida: lida ?? this.lida,
      ativa: ativa ?? this.ativa,
      dados: dados ?? this.dados,
    );
  }

  /// Verifica se a notificação ainda é válida baseado na data de expiração
  bool get isValida {
    if (!ativa) return false;
    if (dataExpiracao == null) return true;
    return DateTime.now().isBefore(dataExpiracao!);
  }
}

/// Dados para notificação de fila de banheiro/alimentação
class DadosFilaNotificacao {
  final String solicitanteNome;
  final String servicoId;
  final DateTime dataSolicitacao;

  DadosFilaNotificacao({
    required this.solicitanteNome,
    required this.servicoId,
    required this.dataSolicitacao,
  });

  factory DadosFilaNotificacao.fromMap(Map<String, dynamic> map) {
    return DadosFilaNotificacao(
      solicitanteNome: map['solicitanteNome'] ?? '',
      servicoId: map['servicoId'] ?? '',
      dataSolicitacao: (map['dataSolicitacao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'solicitanteNome': solicitanteNome,
      'servicoId': servicoId,
      'dataSolicitacao': Timestamp.fromDate(dataSolicitacao),
    };
  }
}

/// Dados para notificação de termo de consentimento
class DadosTermoNotificacao {
  final String procedimentoNome;
  final String servicoId;
  final DateTime dataSolicitacao;

  DadosTermoNotificacao({
    required this.procedimentoNome,
    required this.servicoId,
    required this.dataSolicitacao,
  });

  factory DadosTermoNotificacao.fromMap(Map<String, dynamic> map) {
    return DadosTermoNotificacao(
      procedimentoNome: map['procedimentoNome'] ?? '',
      servicoId: map['servicoId'] ?? '',
      dataSolicitacao: (map['dataSolicitacao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'procedimentoNome': procedimentoNome,
      'servicoId': servicoId,
      'dataSolicitacao': Timestamp.fromDate(dataSolicitacao),
    };
  }
}

/// Dados para notificação de tarefa atribuída
class DadosTarefaNotificacao {
  final String servicoId;
  final DateTime horarioProcedimento;
  final String procedimentoNome;

  DadosTarefaNotificacao({
    required this.servicoId,
    required this.horarioProcedimento,
    required this.procedimentoNome,
  });

  factory DadosTarefaNotificacao.fromMap(Map<String, dynamic> map) {
    return DadosTarefaNotificacao(
      servicoId: map['servicoId'] ?? '',
      horarioProcedimento: (map['horarioProcedimento'] as Timestamp).toDate(),
      procedimentoNome: map['procedimentoNome'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'servicoId': servicoId,
      'horarioProcedimento': Timestamp.fromDate(horarioProcedimento),
      'procedimentoNome': procedimentoNome,
    };
  }
}

/// Dados para notificação de quiz
class DadosQuizNotificacao {
  final String quizId;
  final String quizTitulo;
  final DateTime dataDisponibilizacao;

  DadosQuizNotificacao({
    required this.quizId,
    required this.quizTitulo,
    required this.dataDisponibilizacao,
  });

  factory DadosQuizNotificacao.fromMap(Map<String, dynamic> map) {
    return DadosQuizNotificacao(
      quizId: map['quizId'] ?? '',
      quizTitulo: map['quizTitulo'] ?? '',
      dataDisponibilizacao: (map['dataDisponibilizacao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizTitulo': quizTitulo,
      'dataDisponibilizacao': Timestamp.fromDate(dataDisponibilizacao),
    };
  }
}

