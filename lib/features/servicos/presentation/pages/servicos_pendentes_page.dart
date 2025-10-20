import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ServicosPendentesPage extends ConsumerStatefulWidget {
  const ServicosPendentesPage({super.key});

  @override
  ConsumerState<ServicosPendentesPage> createState() => _ServicosPendentesPageState();
}

class _ServicosPendentesPageState extends ConsumerState<ServicosPendentesPage> with SingleTickerProviderStateMixin {
  DateTime _dataSelecionada = DateTime.now();
  late TabController _tabController;
  
  // Dados de exemplo dos médicos disponíveis
  final List<Medico> _medicosDisponiveis = [
    Medico(id: '1', nome: 'Dr. Gabriel', especialidade: 'Anestesiologista', status: 'Disponível'),
    Medico(id: '2', nome: 'Dr. Carlos', especialidade: 'Anestesiologista', status: 'Ocupado'),
    Medico(id: '3', nome: 'Dra. Ana', especialidade: 'Anestesiologista', status: 'Disponível'),
    Medico(id: '4', nome: 'Dr. Paulo', especialidade: 'Anestesiologista', status: 'Disponível'),
  ];
  
  final List<ServicoTarefa> _todasTarefas = [
    // Tarefas de hoje
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
    // Tarefas de amanhã
    ServicoTarefa(
      id: '4',
      paciente: 'Ana Oliveira',
      procedimento: 'Cirurgia Oftalmológica',
      sala: 'Sala 1',
      anestesiologista: 'Dr. Gabriel',
      status: 'Aguardando',
      tempoEstimado: 45,
      prioridade: 'Média',
      observacoes: 'Cirurgia de catarata',
      horaPrevistaInicio: DateTime.now().add(const Duration(days: 1, hours: 8)),
    ),
    ServicoTarefa(
      id: '5',
      paciente: 'Carlos Mendes',
      procedimento: 'Cirurgia Neurológica',
      sala: 'Sala 2',
      anestesiologista: 'Dr. Carlos',
      status: 'Aguardando',
      tempoEstimado: 180,
      prioridade: 'Alta',
      observacoes: 'Procedimento delicado, atenção especial',
      horaPrevistaInicio: DateTime.now().add(const Duration(days: 1, hours: 10)),
    ),
    // Tarefas de ontem
    ServicoTarefa(
      id: '6',
      paciente: 'Laura Ferreira',
      procedimento: 'Cirurgia Vascular',
      sala: 'Sala 3',
      anestesiologista: 'Dr. Gabriel',
      status: 'Concluída',
      tempoEstimado: 90,
      prioridade: 'Média',
      observacoes: 'Cirurgia realizada com sucesso',
      horaPrevistaInicio: DateTime.now().subtract(const Duration(days: 1, hours: -9)),
    ),
  ];
  
  List<ServicoTarefa> get _tarefasFiltradas {
    return _todasTarefas.where((tarefa) {
      final dataInicio = tarefa.horaPrevistaInicio;
      return dataInicio.year == _dataSelecionada.year &&
             dataInicio.month == _dataSelecionada.month &&
             dataInicio.day == _dataSelecionada.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Pendentes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Minhas Tarefas'),
            Tab(icon: Icon(Icons.dashboard), text: 'Visão Geral'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMinhasTarefas(),
          _buildVisaoGeral(),
        ],
      ),
    );
  }

  // Visão das minhas tarefas (visão do médico)
  Widget _buildMinhasTarefas() {
    return Column(
      children: [
        // Seletor de data com navegação
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Botão dia anterior
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1));
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Data atual com botão de seleção
                  Expanded(
                    child: InkWell(
                      onTap: _selecionarData,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatarDataCompleta(_dataSelecionada),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  _getDiaDaSemana(_dataSelecionada),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão próximo dia
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _dataSelecionada = _dataSelecionada.add(const Duration(days: 1));
                      });
                    },
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Botão "Hoje"
              if (!_isHoje(_dataSelecionada))
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _dataSelecionada = DateTime.now();
                      });
                    },
                    icon: const Icon(Icons.today, size: 16),
                    label: const Text('Voltar para Hoje'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Subtítulo e filtros
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
                child: Row(
                  children: [
                    Text(
                      'Suas tarefas em destaque',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _tarefasFiltradas.isEmpty 
                            ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_tarefasFiltradas.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _tarefasFiltradas.isEmpty
                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
          child: _tarefasFiltradas.isEmpty
              ? _buildMensagemVazia()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = _tarefasFiltradas[index];
                    return _buildTarefaCard(context, tarefa);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMensagemVazia() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma tarefa encontrada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há serviços pendentes para ${_formatarDataCompleta(_dataSelecionada)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isHoje(_dataSelecionada))
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _dataSelecionada = DateTime.now();
                  });
                },
                icon: const Icon(Icons.today),
                label: const Text('Ver tarefas de hoje'),
              ),
          ],
        ),
      ),
    );
  }

  // Visão Geral do Coordenador
  Widget _buildVisaoGeral() {
    return Column(
      children: [
        // Seletor de data
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              // Botão dia anterior
              IconButton(
                onPressed: () {
                  setState(() {
                    _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Data atual com botão de seleção
              Expanded(
                child: InkWell(
                  onTap: _selecionarData,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatarDataCompleta(_dataSelecionada),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Botão próximo dia
              IconButton(
                onPressed: () {
                  setState(() {
                    _dataSelecionada = _dataSelecionada.add(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
        
        // Painel de médicos disponíveis
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Médicos Disponíveis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _medicosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final medico = _medicosDisponiveis[index];
                    return _buildMedicoChip(medico);
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Lista de procedimentos com distribuição
        Expanded(
          child: _tarefasFiltradas.isEmpty
              ? _buildMensagemVazia()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tarefasFiltradas.length,
                  itemBuilder: (context, index) {
                    final tarefa = _tarefasFiltradas[index];
                    return _buildTarefaCardCoordenador(context, tarefa);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMedicoChip(Medico medico) {
    final isDisponivel = medico.status == 'Disponível';
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: isDisponivel ? Colors.green : Colors.orange,
          child: Text(
            medico.nome.split(' ').map((n) => n[0]).take(2).join(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        label: Text(medico.nome),
        backgroundColor: isDisponivel 
            ? Colors.green.shade50 
            : Colors.orange.shade50,
      ),
    );
  }

  Widget _buildTarefaCardCoordenador(BuildContext context, ServicoTarefa tarefa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com paciente e procedimento
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
                        ),
                      ),
                      Text(
                        tarefa.procedimento,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(tarefa.horaPrevistaInicio),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informações adicionais
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.meeting_room, tarefa.sala, context),
                _buildInfoChip(Icons.access_time, '${tarefa.tempoEstimado} min', context),
                _buildInfoChip(
                  Icons.priority_high, 
                  tarefa.prioridade, 
                  context, 
                  color: _getPrioridadeColor(tarefa.prioridade),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Seleção de médico
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Anestesiologista:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: tarefa.anestesiologista,
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    items: _medicosDisponiveis.map((medico) {
                      return DropdownMenuItem<String>(
                        value: medico.nome,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: medico.status == 'Disponível' 
                                    ? Colors.green 
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(medico.nome),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (novoMedico) {
                      if (novoMedico != null) {
                        setState(() {
                          tarefa.anestesiologista = novoMedico;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$novoMedico atribuído(a) a ${tarefa.paciente}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, BuildContext context, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
          ),
        ),
      ],
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

  // Funções auxiliares para o seletor de data
  String _formatarDataCompleta(DateTime data) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(data);
  }

  String _getDiaDaSemana(DateTime data) {
    final diasSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    return diasSemana[data.weekday - 1];
  }

  bool _isHoje(DateTime data) {
    final hoje = DateTime.now();
    return data.year == hoje.year && 
           data.month == hoje.month && 
           data.day == hoje.day;
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataSelecionada = dataSelecionada;
      });
    }
  }
}

class ServicoTarefa {
  final String id;
  final String paciente;
  final String procedimento;
  final String sala;
  String anestesiologista;
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

class Medico {
  final String id;
  final String nome;
  final String especialidade;
  final String status;

  Medico({
    required this.id,
    required this.nome,
    required this.especialidade,
    required this.status,
  });
}
