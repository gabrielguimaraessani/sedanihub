import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'visualizar_pdf_page.dart';
import 'avaliacao_paciente_ia_page.dart';
import 'editar_prontuario_page.dart';

class AvaliacaoPacientesPage extends ConsumerStatefulWidget {
  const AvaliacaoPacientesPage({super.key});

  @override
  ConsumerState<AvaliacaoPacientesPage> createState() => _AvaliacaoPacientesPageState();
}

class _AvaliacaoPacientesPageState extends ConsumerState<AvaliacaoPacientesPage> {
  final TextEditingController _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prontuários de Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          // Botão para criar novo prontuário
          IconButton(
            onPressed: _criarNovoProntuario,
            icon: const Icon(Icons.add_circle),
            tooltip: 'Novo Prontuário',
          ),
        ],
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
      body: _buildProntuariosPage(),
    );
  }

  void _criarNovoProntuario() {
    final nomeController = TextEditingController();
    final dataNascimentoController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Prontuário'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'Informe nome completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'DD/MM/AAAA',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data de nascimento é obrigatória';
                  }
                  // Validação básica de formato
                  final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                  if (!regex.hasMatch(value)) {
                    return 'Formato inválido (DD/MM/AAAA)';
                  }
                  // Validação de data válida
                  try {
                    final parts = value.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    final date = DateTime(year, month, day);
                    
                    if (date.isAfter(DateTime.now())) {
                      return 'Data não pode ser futura';
                    }
                    if (year < 1900) {
                      return 'Ano inválido';
                    }
                  } catch (e) {
                    return 'Data inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                '* Campos obrigatórios',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                // Navegar para a página de edição
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarProntuarioPage(
                      paciente: Paciente(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nome: nomeController.text.trim(),
                        cpf: '',
                        prontuario: 'P${DateTime.now().millisecondsSinceEpoch}',
                        dataNascimento: dataNascimentoController.text,
                        ultimaAtualizacao: 'Agora',
                      ),
                      isNovo: true,
                    ),
                  ),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
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
        builder: (context) => EditarProntuarioPage(paciente: paciente, isNovo: false),
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

