import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Usuário do sistema
class Usuario {
  final String id; // email como ID
  final String nomeCompleto;
  final int? crmDf;
  final String email;
  final FuncaoAtual funcaoAtual;
  final List<Gerencia> gerencias;
  final DateTime? dataCriacao;
  final String? criadoPor;
  final DateTime? ultimaModificacao;
  final String? modificadoPor;

  Usuario({
    required this.id,
    required this.nomeCompleto,
    this.crmDf,
    required this.email,
    required this.funcaoAtual,
    this.gerencias = const [],
    this.dataCriacao,
    this.criadoPor,
    this.ultimaModificacao,
    this.modificadoPor,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nomeCompleto: data['nomeCompleto'] ?? '',
      crmDf: data['crmDf'],
      email: data['email'] ?? '',
      funcaoAtual: FuncaoAtual.fromString(data['funcaoAtual']),
      gerencias: (data['gerencia'] as List<dynamic>?)
              ?.map((e) => Gerencia.fromString(e.toString()))
              .toList() ??
          [],
      dataCriacao: (data['dataCriacao'] as Timestamp?)?.toDate(),
      criadoPor: data['criadoPor'],
      ultimaModificacao: (data['ultimaModificacao'] as Timestamp?)?.toDate(),
      modificadoPor: data['modificadoPor'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nomeCompleto': nomeCompleto,
      'crmDf': crmDf,
      'email': email,
      'funcaoAtual': funcaoAtual.value,
      'gerencia': gerencias.map((e) => e.value).toList(),
      'dataCriacao': dataCriacao != null ? Timestamp.fromDate(dataCriacao!) : FieldValue.serverTimestamp(),
      'criadoPor': criadoPor,
      'ultimaModificacao': FieldValue.serverTimestamp(),
      'modificadoPor': modificadoPor,
    };
  }
}

enum FuncaoAtual {
  senior('Senior'),
  pleno2('Pleno 2'),
  pleno1('Pleno 1'),
  assistente('Assistente'),
  analistaQualidade('Analista de qualidade'),
  administrativo('Administrativo');

  final String value;
  const FuncaoAtual(this.value);

  static FuncaoAtual fromString(String? value) {
    if (value == null) return FuncaoAtual.assistente;
    return FuncaoAtual.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FuncaoAtual.assistente,
    );
  }
}

enum Gerencia {
  nenhuma('Nenhuma'),
  ceo('CEO'),
  cfo('CFO'),
  coo('COO'),
  diretorQualidade('Diretor de Qualidade'),
  diretorMarketing('Diretor de Marketing'),
  diretorCompras('Diretor de compras'),
  diretorAuditoria('Diretor de Auditoria'),
  diretorAtendimentoForaCc('Diretor de atendimento fora do centro cirúrgico'),
  diretorEnsino('Diretor de ensino'),
  diretorRelacionamentos('Diretor de relacionamentos'),
  diretoriaGestaoFuncionarios('Diretoria de gestão de funcionários'),
  diretorConsultorioPreAnestesico('Diretor do consultorio pre-anestesico');

  final String value;
  const Gerencia(this.value);

  static Gerencia fromString(String? value) {
    if (value == null) return Gerencia.nenhuma;
    return Gerencia.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Gerencia.nenhuma,
    );
  }
}

