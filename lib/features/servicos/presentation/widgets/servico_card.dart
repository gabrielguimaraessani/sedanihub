import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/servico.dart';

/// Card visual para exibir um serviço
class ServicoCard extends StatelessWidget {
  final Servico servico;
  final bool semAtribuicao;
  final VoidCallback? onTap;
  final List<String>? anestesistasNomes;

  const ServicoCard({
    super.key,
    required this.servico,
    this.semAtribuicao = false,
    this.onTap,
    this.anestesistasNomes,
  });

  @override
  Widget build(BuildContext context) {
    final horaFormat = DateFormat('HH:mm');
    final horaInicio = horaFormat.format(servico.inicio);
    final horaFim = servico.fimPrevisto != null
        ? horaFormat.format(servico.fimPrevisto!)
        : '?';

    return Card(
      elevation: semAtribuicao ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: semAtribuicao
          ? Colors.orange.shade50
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: semAtribuicao
            ? BorderSide(color: Colors.orange.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Horário e Local
              Row(
                children: [
                  // Horário
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCorLocal(servico.local),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$horaInicio - $horaFim',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Duração
                  if (servico.duracao != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${servico.duracao}min',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Ícone de alerta para sem atribuição
                  if (semAtribuicao)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Local
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      servico.local.value,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              // Leito (se houver)
              if (servico.leito != null && servico.leito!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.bed,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Leito: ${servico.leito}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              // Anestesistas atribuídos
              if (anestesistasNomes != null && anestesistasNomes!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          anestesistasNomes!.join(', '),
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCorLocal(LocalServico local) {
    switch (local) {
      case LocalServico.centroCirurgico:
        return Colors.blue.shade600;
      case LocalServico.endoscopia:
        return Colors.purple.shade600;
      case LocalServico.ressonanciaMagneticaUnidade3:
      case LocalServico.ressonanciaMagneticaUnidade4:
        return Colors.teal.shade600;
      case LocalServico.centroOncologia:
        return Colors.pink.shade600;
      case LocalServico.tomografiaUnidade4:
        return Colors.indigo.shade600;
      case LocalServico.ultrassomUnidade4:
        return Colors.cyan.shade600;
    }
  }
}

