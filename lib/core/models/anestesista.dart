import 'package:cloud_firestore/cloud_firestore.dart';
import 'servico.dart';

/// Modelo de Anestesista atribuído a um serviço
class Anestesista {
  final String id;
  final String servicoId;
  final DateTime inicio;
  final DateTime? fim;
  final String medicoId;
  final DateTime? dataCriacao;
  final String? criadoPor;
  final DateTime? ultimaModificacao;
  final String? modificadoPor;

  Anestesista({
    required this.id,
    required this.servicoId,
    required this.inicio,
    this.fim,
    required this.medicoId,
    this.dataCriacao,
    this.criadoPor,
    this.ultimaModificacao,
    this.modificadoPor,
  });

  factory Anestesista.fromFirestore(DocumentSnapshot doc, String servicoId) {
    final data = doc.data() as Map<String, dynamic>;
    return Anestesista(
      id: doc.id,
      servicoId: servicoId,
      inicio: (data['inicio'] as Timestamp).toDate(),
      fim: (data['fim'] as Timestamp?)?.toDate(),
      medicoId: data['medico'] is DocumentReference
          ? (data['medico'] as DocumentReference).id
          : data['medico'].toString(),
      dataCriacao: (data['dataCriacao'] as Timestamp?)?.toDate(),
      criadoPor: data['criadoPor'],
      ultimaModificacao: (data['ultimaModificacao'] as Timestamp?)?.toDate(),
      modificadoPor: data['modificadoPor'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'inicio': Timestamp.fromDate(inicio),
      'fim': fim != null ? Timestamp.fromDate(fim!) : null,
      'medico': FirebaseFirestore.instance.doc('usuarios/$medicoId'),
      'dataCriacao': dataCriacao != null ? Timestamp.fromDate(dataCriacao!) : FieldValue.serverTimestamp(),
      'criadoPor': criadoPor,
      'ultimaModificacao': FieldValue.serverTimestamp(),
      'modificadoPor': modificadoPor,
    };
  }

  /// Verifica se há sobreposição com outro período
  bool hasConflict(DateTime outroInicio, DateTime? outroFim) {
    final meuFim = fim ?? DateTime.now().add(const Duration(days: 1));
    final oFim = outroFim ?? DateTime.now().add(const Duration(days: 1));

    // Sobreposição se:
    // - meu início está entre o outro início e fim OU
    // - meu fim está entre o outro início e fim OU
    // - eu contenho completamente o outro período
    return (inicio.isBefore(oFim) && meuFim.isAfter(outroInicio));
  }
}

/// Classe auxiliar para representar um conflito de horário
class ConflictoHorario {
  final Servico servicoExistente;
  final Anestesista anestesistaExistente;
  final DateTime inicioConflito;
  final DateTime fimConflito;

  ConflictoHorario({
    required this.servicoExistente,
    required this.anestesistaExistente,
    required this.inicioConflito,
    required this.fimConflito,
  });

  String get descricao {
    final duracao = fimConflito.difference(inicioConflito);
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes % 60;
    return 'Conflito de ${horas}h${minutos}min com serviço das ${_formatHora(servicoExistente.inicio)}';
  }

  String _formatHora(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

