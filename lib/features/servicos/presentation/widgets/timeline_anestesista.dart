import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/servico.dart';
import '../../../../core/models/anestesista.dart';
import '../../../../core/models/usuario.dart';

/// Widget de timeline mostrando serviços de um anestesista
class TimelineAnestesista extends StatelessWidget {
  final Usuario usuario;
  final List<MapEntry<Servico, Anestesista>> servicos;
  final VoidCallback? onTap;

  const TimelineAnestesista({
    Key? key,
    required this.usuario,
    required this.servicos,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horaFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do anestesista
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCorFuncao(usuario.funcaoAtual),
                    child: Text(
                      _getIniciais(usuario.nomeCompleto),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nomeCompleto,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          usuario.funcaoAtual.value,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contador de serviços
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: servicos.isEmpty
                          ? Colors.grey.shade200
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${servicos.length} serviços',
                      style: TextStyle(
                        color: servicos.isEmpty
                            ? Colors.grey.shade600
                            : Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              // Timeline dos serviços
              if (servicos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                ...servicos.map((entry) {
                  final servico = entry.key;
                  final anestesista = entry.value;
                  return _buildServicoItem(
                    servico,
                    anestesista,
                    horaFormat,
                  );
                }),
              ] else ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Nenhum serviço atribuído',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicoItem(
    Servico servico,
    Anestesista anestesista,
    DateFormat horaFormat,
  ) {
    final inicio = horaFormat.format(servico.inicio);
    final fim = servico.fimPrevisto != null
        ? horaFormat.format(servico.fimPrevisto!)
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Timeline visual
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getCorLocal(servico.local),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Informações do serviço
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$inicio - $fim',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (servico.duracao != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${servico.duracao}min)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  servico.local.value,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getIniciais(String nomeCompleto) {
    final partes = nomeCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  Color _getCorFuncao(FuncaoAtual funcao) {
    switch (funcao) {
      case FuncaoAtual.senior:
        return Colors.purple.shade700;
      case FuncaoAtual.pleno2:
        return Colors.blue.shade700;
      case FuncaoAtual.pleno1:
        return Colors.teal.shade700;
      case FuncaoAtual.assistente:
        return Colors.green.shade700;
      case FuncaoAtual.analistaQualidade:
        return Colors.orange.shade700;
      case FuncaoAtual.administrativo:
        return Colors.grey.shade700;
    }
  }

  Color _getCorLocal(LocalServico local) {
    switch (local) {
      case LocalServico.centroCirurgico:
        return Colors.blue.shade400;
      case LocalServico.endoscopia:
        return Colors.purple.shade400;
      case LocalServico.ressonanciaMagneticaUnidade3:
      case LocalServico.ressonanciaMagneticaUnidade4:
        return Colors.teal.shade400;
      case LocalServico.centroOncologia:
        return Colors.pink.shade400;
      case LocalServico.tomografiaUnidade4:
        return Colors.indigo.shade400;
      case LocalServico.ultrassomUnidade4:
        return Colors.cyan.shade400;
    }
  }
}

