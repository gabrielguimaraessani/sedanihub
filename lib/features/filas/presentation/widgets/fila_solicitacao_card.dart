import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/fila_solicitacao.dart';
import '../../../../core/providers/filas_provider.dart';

/// Card para exibir uma solicitação de fila
class FilaSolicitacaoCard extends ConsumerStatefulWidget {
  final FilaSolicitacao solicitacao;

  const FilaSolicitacaoCard({
    super.key,
    required this.solicitacao,
  });

  @override
  ConsumerState<FilaSolicitacaoCard> createState() => _FilaSolicitacaoCardState();
}

class _FilaSolicitacaoCardState extends ConsumerState<FilaSolicitacaoCard> {
  bool _processando = false;

  Color _getCorUrgencia() {
    switch (widget.solicitacao.urgencia) {
      case 'critico':
        return Colors.red;
      case 'urgente':
        return Colors.orange;
      case 'atencao':
        return Colors.yellow[700]!;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconTipo() {
    return widget.solicitacao.tipo == TipoFila.banheiro
        ? Icons.wc
        : Icons.restaurant;
  }

  String _formatarTempo(DateTime data) {
    return DateFormat('HH:mm').format(data);
  }

  String _formatarTempoRestante(Duration duracao) {
    if (duracao.isNegative) return 'Expirado';
    
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    }
    return '${minutos}min';
  }

  Future<void> _marcarComoConcluida() async {
    setState(() => _processando = true);

    try {
      final service = ref.read(filasServiceProvider);
      await service.marcarComoConcluida(widget.solicitacao.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação concluída com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao concluir solicitação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  void _confirmarConclusao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Conclusão'),
        content: Text(
          'Deseja marcar a solicitação de ${widget.solicitacao.tipo.label.toLowerCase()} '
          'de ${widget.solicitacao.solicitadoPorNome} como concluída?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _marcarComoConcluida();
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cor = _getCorUrgencia();
    final tempoRestante = widget.solicitacao.tempoRestante;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cor, width: 2),
      ),
      child: InkWell(
        onTap: _processando ? null : _confirmarConclusao,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com tipo e tempo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconTipo(),
                      color: cor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.solicitacao.tipo.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cor,
                          ),
                        ),
                        Text(
                          'Solicitado às ${_formatarTempo(widget.solicitacao.dataSolicitacao)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatarTempoRestante(tempoRestante),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Solicitado por (agora é a informação principal)
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.solicitacao.solicitadoPorNome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Email do solicitante
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.solicitacao.solicitadoPor,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (widget.solicitacao.observacoes != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.solicitacao.observacoes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Botão de ação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _processando ? null : _confirmarConclusao,
                  icon: _processando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(_processando ? 'Concluindo...' : 'Marcar como Concluída'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

