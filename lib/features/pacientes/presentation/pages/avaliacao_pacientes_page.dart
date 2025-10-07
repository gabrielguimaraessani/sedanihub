import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'visualizar_pdf_page.dart';
import 'avaliacao_paciente_ia_page.dart';

class AvaliacaoPacientesPage extends ConsumerStatefulWidget {
  const AvaliacaoPacientesPage({super.key});

  @override
  ConsumerState<AvaliacaoPacientesPage> createState() => _AvaliacaoPacientesPageState();
}

class _AvaliacaoPacientesPageState extends ConsumerState<AvaliacaoPacientesPage> {
  final TextEditingController _buscaController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _buscaController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação de Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar paciente por nome, CPF ou prontuário...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // TODO: Implementar busca
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs de navegação
          Container(
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
                _buildTab(0, 'Prontuários', Icons.folder),
                _buildTab(1, 'Avaliação', Icons.medical_information),
                _buildTab(2, 'IA Assistente', Icons.psychology),
              ],
            ),
          ),
          
          // Conteúdo das páginas
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildProntuariosPage(),
                _buildAvaliacaoPage(),
                _buildIAAssistentePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _currentPage == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProntuariosPage() {
    final pacientes = [
      Paciente(
        id: '1',
        nome: 'João Silva',
        cpf: '123.456.789-00',
        prontuario: 'P001234',
        dataNascimento: '15/03/1980',
        ultimaAtualizacao: 'Hoje, 14:30',
      ),
      Paciente(
        id: '2',
        nome: 'Maria Santos',
        cpf: '987.654.321-00',
        prontuario: 'P001235',
        dataNascimento: '22/07/1975',
        ultimaAtualizacao: 'Ontem, 16:45',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                paciente.nome.split(' ').first[0] + paciente.nome.split(' ').last[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              paciente.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CPF: ${paciente.cpf}'),
                Text('Prontuário: ${paciente.prontuario}'),
                Text('Última atualização: ${paciente.ultimaAtualizacao}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _visualizarProntuario(paciente),
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Visualizar PDF',
                ),
                IconButton(
                  onPressed: () => _editarPaciente(paciente),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildAvaliacaoPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avaliação de Paciente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Básicas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nome do Paciente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Prontuário',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Histórico Médico',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Medicações em Uso',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Alergias',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implementar salvamento
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar Rascunho'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implementar assinatura digital
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de assinatura digital em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note),
                          label: const Text('Assinar e Finalizar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIAAssistentePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IA Assistente para Avaliação',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faça perguntas sobre o paciente ou protocolos institucionais',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sua pergunta',
                      hintText: 'Ex: Qual o protocolo para paciente com hipertensão?',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.psychology),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implementar integração com IA
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Integração com IA em desenvolvimento'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar Pergunta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contexto Atual',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Paciente: João Silva\n• Prontuário: P001234\n• Protocolos institucionais carregados\n• Histórico médico disponível',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _visualizarProntuario(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarPDFPage(paciente: paciente),
      ),
    );
  }

  void _editarPaciente(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPacientePage(paciente: paciente),
      ),
    );
  }
}

class Paciente {
  final String id;
  final String nome;
  final String cpf;
  final String prontuario;
  final String dataNascimento;
  final String ultimaAtualizacao;

  Paciente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.prontuario,
    required this.dataNascimento,
    required this.ultimaAtualizacao,
  });
}

class EditarPacientePage extends StatefulWidget {
  final Paciente paciente;

  const EditarPacientePage({super.key, required this.paciente});

  @override
  State<EditarPacientePage> createState() => _EditarPacientePageState();
}

class _EditarPacientePageState extends State<EditarPacientePage> {
  late TextEditingController _nomeController;
  late TextEditingController _cpfController;
  late TextEditingController _prontuarioController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.paciente.nome);
    _cpfController = TextEditingController(text: widget.paciente.cpf);
    _prontuarioController = TextEditingController(text: widget.paciente.prontuario);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _prontuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar - ${widget.paciente.nome}'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alterações salvas com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cpfController,
              decoration: const InputDecoration(
                labelText: 'CPF',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prontuarioController,
              decoration: const InputDecoration(
                labelText: 'Prontuário',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assinatura digital em desenvolvimento'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note),
                label: const Text('Assinar e Finalizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
