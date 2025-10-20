import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/servico.dart';
import '../../../../core/models/usuario.dart';
import '../../../../core/models/anestesista.dart';
import '../../domain/services/distribuicao_service.dart';
import '../widgets/servico_card.dart';
import '../widgets/timeline_anestesista.dart';

/// Página de Distribuição de Serviços (apenas para coordenadores)
class DistribuicaoServicosPage extends StatefulWidget {
  const DistribuicaoServicosPage({super.key});

  @override
  State<DistribuicaoServicosPage> createState() =>
      _DistribuicaoServicosPageState();
}

class _DistribuicaoServicosPageState extends State<DistribuicaoServicosPage>
    with SingleTickerProviderStateMixin {
  final DistribuicaoService _service = DistribuicaoService();
  late TabController _tabController;

  DateTime _dataSelecionada = DateTime.now();
  List<Servico> _servicosSemAtribuicao = [];
  List<Servico> _todosServicos = [];
  List<Usuario> _plantonistas = [];
  Map<String, int> _posicoesPlantao = {}; // userId -> posição (1-20)
  Map<String, List<MapEntry<Servico, Anestesista>>> _servicosPorAnestesista =
      {};
  // Mapa local de atribuições para não depender do Firestore
  Map<String, String> _atribuicoesLocais = {}; // servicoId -> userId
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);

    try {
      // TODO: Substituir por dados reais do Firestore
      // Por enquanto, usando dados mockados para desenvolvimento
      await _carregarDadosMockados();
      
      setState(() => _carregando = false);
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _carregarDadosMockados() async {
    // Simular delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    final hoje = DateTime.now();
    final dataSelecionadaSemHora = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    
    // Só mostra dados se for hoje
    if (dataSelecionadaSemHora != hojeSemHora) {
      _servicosSemAtribuicao = [];
      _todosServicos = [];
      _plantonistas = [];
      _servicosPorAnestesista.clear();
      return;
    }

    // Dados mockados de usuários/plantonistas
    _plantonistas = [
      Usuario(
        id: 'user1',
        nomeCompleto: 'Dr. Gabriel Silva',
        email: 'gabriel@sani.med.br',
        funcaoAtual: FuncaoAtual.senior,
        gerencias: [],
      ),
      Usuario(
        id: 'user2',
        nomeCompleto: 'Dr. Carlos Mendes',
        email: 'carlos@sani.med.br',
        funcaoAtual: FuncaoAtual.pleno2,
        gerencias: [],
      ),
      Usuario(
        id: 'user3',
        nomeCompleto: 'Dra. Ana Oliveira',
        email: 'ana@sani.med.br',
        funcaoAtual: FuncaoAtual.pleno1,
        gerencias: [],
      ),
      Usuario(
        id: 'user4',
        nomeCompleto: 'Dr. Paulo Souza',
        email: 'paulo@sani.med.br',
        funcaoAtual: FuncaoAtual.assistente,
        gerencias: [],
      ),
    ];

    // Posições na escala (1 = coordenador, 2+ = plantonistas por ordem de convocação)
    _posicoesPlantao = {
      'user1': 1, // Coordenador (não escalar a priori)
      'user2': 2, // Primeira prioridade
      'user3': 3, // Segunda prioridade  
      'user4': 4, // Terceira prioridade
    };

    // Dados mockados de serviços
    final servico1 = Servico(
      id: 'serv1',
      pacienteId: 'pac1', // João Silva
      procedimentosIds: ['proc1'], // Cirurgia Cardíaca
      inicio: DateTime.now().add(const Duration(hours: 1)),
      duracao: 120,
      local: LocalServico.centroCirurgico,
      leito: 'Sala 1',
      cirurgioesIds: [],
      finalizado: false,
    );

    final servico2 = Servico(
      id: 'serv2',
      pacienteId: 'pac2', // Maria Santos
      procedimentosIds: ['proc2'], // Cirurgia Ortopédica
      inicio: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      duracao: 90,
      local: LocalServico.centroCirurgico,
      leito: 'Sala 3',
      cirurgioesIds: [],
      finalizado: false,
    );

    final servico3 = Servico(
      id: 'serv3',
      pacienteId: 'pac3', // Pedro Costa
      procedimentosIds: ['proc3'], // Cirurgia Plástica
      inicio: DateTime.now().add(const Duration(minutes: 45)),
      duracao: 60,
      local: LocalServico.centroCirurgico,
      leito: 'Sala 2',
      cirurgioesIds: [],
      finalizado: false,
    );

    _todosServicos = [servico1, servico2, servico3];

    // Atribuições iniciais locais
    _atribuicoesLocais = {
      'serv1': 'user2', // Dr. Carlos
      'serv3': 'user2', // Dr. Carlos
      // serv2 sem atribuição
    };

    // Serviço sem atribuição (servico2)
    _servicosSemAtribuicao = [servico2];

    // Distribuição de serviços por anestesista
    _servicosPorAnestesista = {
      'user1': [], // Coordenador, não atribui a priori
      'user2': [
        MapEntry(
          servico1,
          Anestesista(
            id: 'anest1',
            servicoId: 'serv1',
            inicio: servico1.inicio,
            fim: servico1.fimPrevisto,
            medicoId: 'user2',
            criadoPor: 'admin',
            modificadoPor: 'admin',
          ),
        ),
        MapEntry(
          servico3,
          Anestesista(
            id: 'anest3',
            servicoId: 'serv3',
            inicio: servico3.inicio,
            fim: servico3.fimPrevisto,
            medicoId: 'user2',
            criadoPor: 'admin',
            modificadoPor: 'admin',
          ),
        ),
      ],
      'user3': [],
      'user4': [],
    };
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null && data != _dataSelecionada) {
      setState(() => _dataSelecionada = data);
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isHoje = _isHoje(_dataSelecionada);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuição de Serviços'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.warning_amber), text: 'Sem Atribuição'),
            Tab(icon: Icon(Icons.people), text: 'Anestesistas'),
            Tab(icon: Icon(Icons.list_alt), text: 'Todos'),
          ],
        ),
        actions: [
          // Botão de atualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregarDados,
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de data
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHoje
                        ? 'Hoje - ${dateFormat.format(_dataSelecionada)}'
                        : dateFormat.format(_dataSelecionada),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: const Text('Alterar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildServicosSemAtribuicao(),
                      _buildAnestesistas(),
                      _buildTodosServicos(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicosSemAtribuicao() {
    if (_servicosSemAtribuicao.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Todos os serviços estão atribuídos!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _servicosSemAtribuicao.length,
        itemBuilder: (context, index) {
          final servico = _servicosSemAtribuicao[index];
          return ServicoCard(
            servico: servico,
            semAtribuicao: true,
            onTap: () => _mostrarDialogoAtribuicao(servico),
          );
        },
      ),
    );
  }

  Widget _buildAnestesistas() {
    if (_plantonistas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum plantonista escalado para esta data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Ordenar por posição
    final plantonistasSorted = List<Usuario>.from(_plantonistas);
    plantonistasSorted.sort((a, b) {
      final posA = _posicoesPlantao[a.id] ?? 99;
      final posB = _posicoesPlantao[b.id] ?? 99;
      return posA.compareTo(posB);
    });

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: plantonistasSorted.length,
        itemBuilder: (context, index) {
          final plantonista = plantonistasSorted[index];
          final servicos = _servicosPorAnestesista[plantonista.id] ?? [];
          final posicao = _posicoesPlantao[plantonista.id] ?? 0;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: posicao == 1 ? Colors.orange : Colors.blue,
                child: Text(
                  '$posicao',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    plantonista.nomeCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (posicao == 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COORDENADOR',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                servicos.isEmpty
                    ? 'Sem serviços atribuídos'
                    : '${servicos.length} serviço(s) atribuído(s)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarDetalhesAnestesista(plantonista, servicos),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodosServicos() {
    if (_todosServicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum serviço agendado para esta data',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _todosServicos.length,
        itemBuilder: (context, index) {
          final servico = _todosServicos[index];
          final atribuidoPara = _atribuicoesLocais[servico.id];
          final semAtribuicao = atribuidoPara == null;
          
          final nomeAtribuido = atribuidoPara != null 
              ? _getNomeAnestesista(atribuidoPara)
              : null;
          
          final posicaoAtribuido = atribuidoPara != null
              ? _posicoesPlantao[atribuidoPara]
              : null;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: semAtribuicao ? Colors.orange.shade50 : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: semAtribuicao ? Colors.orange : Colors.green,
                child: Icon(
                  semAtribuicao ? Icons.warning : Icons.check,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Paciente: ${servico.pacienteId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sala: ${servico.leito ?? "N/A"}'),
                  Text('Hora: ${DateFormat('HH:mm').format(servico.inicio)}'),
                  if (nomeAtribuido != null)
                    Row(
                      children: [
                        if (posicaoAtribuido != null) ...[
                          Container(
                            margin: const EdgeInsets.only(right: 4, top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: posicaoAtribuido == 1 ? Colors.orange : Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$posicaoAtribuido',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            'Atribuído: $nomeAtribuido',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'SEM ATRIBUIÇÃO',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _mostrarDialogoAtribuicao(servico),
            ),
          );
        },
      ),
    );
  }

  String? _getNomeAnestesista(String id) {
    try {
      return _plantonistas.firstWhere((p) => p.id == id).nomeCompleto;
    } catch (e) {
      return null;
    }
  }

  void _mostrarDetalhesAnestesista(
    Usuario usuario,
    List<MapEntry<Servico, Anestesista>> servicos,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      _getIniciais(usuario.nomeCompleto),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nomeCompleto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          usuario.funcaoAtual.value,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            // Lista de serviços
            Expanded(
              child: servicos.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum serviço atribuído',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: servicos.length,
                      itemBuilder: (context, index) {
                        final entry = servicos[index];
                        return ServicoCard(
                          servico: entry.key,
                          onTap: () => _mostrarDialogoAtribuicao(entry.key),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoAtribuicao(Servico servico) async {
    // Ordenar por posição
    final plantonistasSorted = List<Usuario>.from(_plantonistas);
    plantonistasSorted.sort((a, b) {
      final posA = _posicoesPlantao[a.id] ?? 99;
      final posB = _posicoesPlantao[b.id] ?? 99;
      return posA.compareTo(posB);
    });

    final anestesistaSelecionado = await showDialog<Usuario>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atribuir Anestesista'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Serviço: ${servico.pacienteId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: plantonistasSorted.length,
                itemBuilder: (context, index) {
                  final plantonista = plantonistasSorted[index];
                  final posicao = _posicoesPlantao[plantonista.id] ?? 0;
                  final isCoordenador = posicao == 1;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCoordenador ? Colors.orange : Colors.blue,
                      child: Text(
                        '$posicao',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(plantonista.nomeCompleto),
                    subtitle: Text(
                      isCoordenador 
                          ? 'Coordenador - ${plantonista.funcaoAtual.value}'
                          : plantonista.funcaoAtual.value,
                    ),
                    onTap: () => Navigator.of(context).pop(plantonista),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (anestesistaSelecionado != null) {
      await _atribuirAnestesista(servico, anestesistaSelecionado);
    }
  }

  Future<void> _atribuirAnestesista(
    Servico servico,
    Usuario anestesista,
  ) async {
    // TODO: Verificar conflitos de horário (implementar depois)
    
    // Atribuir localmente
    setState(() {
      // Atualizar atribuições locais
      _atribuicoesLocais[servico.id] = anestesista.id;
      
      // Criar anestesista para o serviço
      final novoAnestesista = Anestesista(
        id: 'anest_${servico.id}',
        servicoId: servico.id,
        inicio: servico.inicio,
        fim: servico.fimPrevisto,
        medicoId: anestesista.id,
        criadoPor: 'admin',
        modificadoPor: 'admin',
      );
      
      // Atualizar lista de serviços por anestesista
      final servicosAtuais = _servicosPorAnestesista[anestesista.id] ?? [];
      
      // Remover se já existe
      servicosAtuais.removeWhere((entry) => entry.key.id == servico.id);
      
      // Adicionar novo
      servicosAtuais.add(MapEntry(servico, novoAnestesista));
      _servicosPorAnestesista[anestesista.id] = servicosAtuais;
      
      // Atualizar lista de serviços sem atribuição
      _servicosSemAtribuicao.removeWhere((s) => s.id == servico.id);
    });

    if (mounted) {
      final posicao = _posicoesPlantao[anestesista.id] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Serviço atribuído a ${anestesista.nomeCompleto} (Posição $posicao)',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getIniciais(String nomeCompleto) {
    final partes = nomeCompleto.trim().split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  bool _isHoje(DateTime data) {
    final hoje = DateTime.now();
    return data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
  }
}

