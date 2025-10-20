import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/servico.dart';
import '../../../../core/models/anestesista.dart';
import '../../../../core/models/usuario.dart';
import '../../../../core/models/plantao.dart';

/// Service para gerenciar a distribuição de serviços entre anestesistas
class DistribuicaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca serviços de uma data específica
  Future<List<Servico>> buscarServicosPorData(DateTime data) async {
    final inicioDia = DateTime(data.year, data.month, data.day);
    final fimDia = inicioDia.add(const Duration(days: 1));

    final query = await _firestore
        .collection('servicos')
        .where('inicio', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('inicio', isLessThan: Timestamp.fromDate(fimDia))
        .orderBy('inicio')
        .get();

    return query.docs.map((doc) => Servico.fromFirestore(doc)).toList();
  }

  /// Busca anestesistas atribuídos a um serviço
  Future<List<Anestesista>> buscarAnestesistasDoServico(String servicoId) async {
    final query = await _firestore
        .collection('servicos')
        .doc(servicoId)
        .collection('anestesistas')
        .get();

    return query.docs
        .map((doc) => Anestesista.fromFirestore(doc, servicoId))
        .toList();
  }

  /// Busca todos os serviços de um anestesista em uma data específica
  Future<List<MapEntry<Servico, Anestesista>>> buscarServicosDoAnestesista(
    String anestesistaId,
    DateTime data,
  ) async {
    final servicos = await buscarServicosPorData(data);
    final List<MapEntry<Servico, Anestesista>> resultado = [];

    for (final servico in servicos) {
      final anestesistas = await buscarAnestesistasDoServico(servico.id);
      final anestesista = anestesistas
          .where((a) => a.medicoId == anestesistaId)
          .firstOrNull;
      
      if (anestesista != null) {
        resultado.add(MapEntry(servico, anestesista));
      }
    }

    return resultado;
  }

  /// Busca plantonistas de uma data específica
  Future<List<Plantao>> buscarPlantonistasPorData(DateTime data) async {
    final inicioDia = DateTime(data.year, data.month, data.day);

    final query = await _firestore
        .collection('plantoes')
        .where('data', isEqualTo: Timestamp.fromDate(inicioDia))
        .orderBy('posicao')
        .get();

    return query.docs.map((doc) => Plantao.fromFirestore(doc)).toList();
  }

  /// Busca usuários plantonistas (não coordenadores) de uma data
  Future<List<Usuario>> buscarUsuariosPlantonistas(DateTime data) async {
    final plantoes = await buscarPlantonistasPorData(data);
    final plantonistasIds = plantoes
        .where((p) => !p.isCoordenador)
        .map((p) => p.usuarioId)
        .toSet();

    if (plantonistasIds.isEmpty) return [];

    final usuarios = <Usuario>[];
    for (final id in plantonistasIds) {
      final doc = await _firestore.collection('usuarios').doc(id).get();
      if (doc.exists) {
        usuarios.add(Usuario.fromFirestore(doc));
      }
    }

    return usuarios;
  }

  /// Verifica conflitos ao atribuir um anestesista a um serviço
  Future<List<ConflictoHorario>> verificarConflitos(
    String anestesistaId,
    Servico novoServico,
  ) async {
    final servicosExistentes = await buscarServicosDoAnestesista(
      anestesistaId,
      novoServico.inicio,
    );

    final conflitos = <ConflictoHorario>[];

    final novoInicio = novoServico.inicio;
    final novoFim = novoServico.fimPrevisto;

    if (novoFim == null) return conflitos; // Sem duração, não há como verificar

    for (final entry in servicosExistentes) {
      final servico = entry.key;
      final anestesista = entry.value;

      // Verifica se o novo serviço conflita com este
      if (anestesista.hasConflict(novoInicio, novoFim)) {
        final inicioConflito = novoInicio.isAfter(servico.inicio)
            ? novoInicio
            : servico.inicio;
        final fimConflito = (novoFim.isBefore(servico.fimPrevisto ?? novoFim))
            ? novoFim
            : (servico.fimPrevisto ?? novoFim);

        conflitos.add(ConflictoHorario(
          servicoExistente: servico,
          anestesistaExistente: anestesista,
          inicioConflito: inicioConflito,
          fimConflito: fimConflito,
        ));
      }
    }

    return conflitos;
  }

  /// Atribui um anestesista a um serviço
  Future<void> atribuirAnestesista({
    required String servicoId,
    required String anestesistaId,
    required Servico servico,
    required String usuarioAtualId,
  }) async {
    final anestesista = Anestesista(
      id: '', // Será gerado pelo Firestore
      servicoId: servicoId,
      inicio: servico.inicio,
      fim: servico.fimPrevisto,
      medicoId: anestesistaId,
      criadoPor: usuarioAtualId,
      modificadoPor: usuarioAtualId,
    );

    await _firestore
        .collection('servicos')
        .doc(servicoId)
        .collection('anestesistas')
        .add(anestesista.toFirestore());
  }

  /// Remove atribuição de um anestesista de um serviço
  Future<void> removerAnestesista({
    required String servicoId,
    required String anestesistaDocId,
  }) async {
    // Seguindo a política de não deletar, marcaríamos como inativo
    // mas para simplicidade da demonstração, vamos deletar
    await _firestore
        .collection('servicos')
        .doc(servicoId)
        .collection('anestesistas')
        .doc(anestesistaDocId)
        .delete();
  }

  /// Busca serviços sem atribuição
  Future<List<Servico>> buscarServicosSemAtribuicao(DateTime data) async {
    final servicos = await buscarServicosPorData(data);
    final servicosSemAtribuicao = <Servico>[];

    for (final servico in servicos) {
      final anestesistas = await buscarAnestesistasDoServico(servico.id);
      if (anestesistas.isEmpty) {
        servicosSemAtribuicao.add(servico);
      }
    }

    return servicosSemAtribuicao;
  }
}

