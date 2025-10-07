import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicosPendentesPage extends ConsumerStatefulWidget {
  const ServicosPendentesPage({super.key});

  @override
  ConsumerState<ServicosPendentesPage> createState() => _ServicosPendentesPageState();
}

class _ServicosPendentesPageState extends ConsumerState<ServicosPendentesPage> {
  final List<ServicoTarefa> _tarefas = [
    ServicoTarefa(
      id: '1',
      paciente: 'João Silva',
      procedimento: 'Cirurgia Cardíaca',
      sala: 'Sala 1',
      anestesiologista: 'Dr. Gabriel',
      status: 'Em andamento',
      tempoEstimado: 120,
      prioridade: 'Alta',
      observacoes: 'Paciente com histórico de hipertensão',
      horaPrevistaInicio: DateTime.now().add(const Duration(hours: 1)),
    ),
    ServicoTarefa(
      id: '2',
      paciente: 'Maria Santos',
      procedimento: 'Cirurgia Ortopédica',
      sala: 'Sala 3',
      anestesiologista: 'Dr. Carlos',
      status: 'Aguardando',
      tempoEstimado: 90,
      prioridade: 'Média',
      observacoes: 'Primeira cirurgia do paciente',
      horaPrevistaInicio: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
    ),
    ServicoTarefa(
      id: '3',
      paciente: 'Pedro Costa',
      procedimento: 'Cirurgia Plástica',
      sala: 'Sala 2',
      anestesiologista: 'Dr. Gabriel',
      status: 'Em andamento',
      tempoEstimado: 60,
      prioridade: 'Baixa',
      observacoes: 'Procedimento eletivo',
      horaPrevistaInicio: DateTime.now().add(const Duration(minutes: 45)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Pendentes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros e ações
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Suas tarefas em destaque',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _mostrarFiltros,
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          
          // Lista de tarefas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];
                return _buildTarefaCard(context, tarefa);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarefaCard(BuildContext context, ServicoTarefa tarefa) {
    final isMinhaTarefa = tarefa.anestesiologista == 'Dr. Gabriel'; // Simulação do usuário logado
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isMinhaTarefa ? 4 : 2,
      color: isMinhaTarefa 
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _abrirAvaliacaoPaciente(tarefa),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da tarefa
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarefa.paciente,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isMinhaTarefa 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                      Text(
                        '${tarefa.procedimento} - ${tarefa.sala}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(tarefa.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tarefa.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informações da tarefa
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tarefa.anestesiologista,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Início: ${_formatTime(tarefa.horaPrevistaInicio)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tarefa.tempoEstimado} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 16,
                      color: _getPrioridadeColor(tarefa.prioridade),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tarefa.prioridade,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getPrioridadeColor(tarefa.prioridade),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (tarefa.observacoes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                tarefa.observacoes,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Ações
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editarTempoEstimado(tarefa),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Atualizar Previsão'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _marcarConcluida(tarefa),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Concluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _abrirAvaliacaoPaciente(ServicoTarefa tarefa) {
    Navigator.pushNamed(
      context,
      '/dashboard/avaliacao-paciente-ia',
      arguments: {'paciente': tarefa.paciente, 'procedimento': tarefa.procedimento},
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Em andamento':
        return Colors.blue;
      case 'Aguardando':
        return Colors.orange;
      case 'Concluída':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPrioridadeColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return Colors.red;
      case 'Média':
        return Colors.orange;
      case 'Baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _mostrarFiltros() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: const Text('Filtros em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _editarTempoEstimado(ServicoTarefa tarefa) {
    final controller = TextEditingController(text: tarefa.tempoEstimado.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Previsão da Duração'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Paciente: ${tarefa.paciente}'),
            Text('Procedimento: ${tarefa.procedimento}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duração prevista (minutos)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novoValor = int.tryParse(controller.text);
              if (novoValor != null && novoValor > 0) {
                setState(() {
                  tarefa.tempoEstimado = novoValor;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Previsão da duração atualizada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _marcarConcluida(ServicoTarefa tarefa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Conclusão'),
        content: Text('Deseja marcar a tarefa de ${tarefa.paciente} como concluída?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tarefa.status = 'Concluída';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarefa marcada como concluída!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class ServicoTarefa {
  final String id;
  final String paciente;
  final String procedimento;
  final String sala;
  final String anestesiologista;
  String status;
  int tempoEstimado;
  final String prioridade;
  final String observacoes;
  final DateTime horaPrevistaInicio;

  ServicoTarefa({
    required this.id,
    required this.paciente,
    required this.procedimento,
    required this.sala,
    required this.anestesiologista,
    required this.status,
    required this.tempoEstimado,
    required this.prioridade,
    required this.observacoes,
    required this.horaPrevistaInicio,
  });
}
