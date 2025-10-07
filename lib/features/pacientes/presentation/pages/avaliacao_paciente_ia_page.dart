import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvaliacaoPacienteIAPage extends ConsumerStatefulWidget {
  final String? pacienteNome;
  final String? procedimento;

  const AvaliacaoPacienteIAPage({
    super.key,
    this.pacienteNome,
    this.procedimento,
  });

  @override
  ConsumerState<AvaliacaoPacienteIAPage> createState() => _AvaliacaoPacienteIAPageState();
}

class _AvaliacaoPacienteIAPageState extends ConsumerState<AvaliacaoPacienteIAPage> {
  final TextEditingController _inputController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Dados da avaliação
  final Map<String, dynamic> _avaliacaoData = {
    'nome': '',
    'cpf': '',
    'prontuario': '',
    'idade': '',
    'peso': '',
    'altura': '',
    'historia_medica': '',
    'medicamentos': '',
    'alergias': '',
    'exames_complementares': '',
    'avaliacao_pre_anestesica': '',
    'risco_cirurgico': '',
    'observacoes': '',
  };

  // Teleprompter da IA
  final List<String> _proximasPerguntas = [
    'Por favor, informe o nome completo do paciente.',
    'Qual é o CPF do paciente?',
    'Informe a idade do paciente.',
    'Qual é o peso e altura do paciente?',
    'Há algum histórico médico relevante?',
    'O paciente está usando alguma medicação?',
    'Existem alergias conhecidas?',
    'Há exames complementares disponíveis?',
    'Realize a avaliação pré-anestésica.',
    'Avalie o risco cirúrgico.',
    'Adicione observações finais.'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.pacienteNome != null) {
      _avaliacaoData['nome'] = widget.pacienteNome!;
    }
    if (widget.procedimento != null) {
      _avaliacaoData['procedimento'] = widget.procedimento!;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliação - ${widget.pacienteNome ?? 'Paciente'}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _salvarAvaliacao,
            icon: const Icon(Icons.save),
            tooltip: 'Salvar Avaliação',
          ),
          IconButton(
            onPressed: _finalizarAvaliacao,
            icon: const Icon(Icons.check_circle),
            tooltip: 'Finalizar e Gerar PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Teleprompter da IA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IA Assistente',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentStep < _proximasPerguntas.length 
                            ? _proximasPerguntas[_currentStep]
                            : 'Avaliação completa! Revise os dados e finalize.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Área de entrada de dados
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Campo de entrada multimodal
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Botões de mídia
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _adicionarFoto,
                              icon: const Icon(Icons.camera_alt),
                              tooltip: 'Adicionar Foto',
                            ),
                            IconButton(
                              onPressed: _adicionarAudio,
                              icon: const Icon(Icons.mic),
                              tooltip: 'Gravar Áudio',
                            ),
                            IconButton(
                              onPressed: _adicionarDocumento,
                              icon: const Icon(Icons.attach_file),
                              tooltip: 'Anexar Documento',
                            ),
                            const Spacer(),
                            Text(
                              'IA processará automaticamente',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Campo de texto
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Digite informações ou descreva o que observou...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            onPressed: _processarEntrada,
                            icon: const Icon(Icons.send),
                          ),
                        ),
                        maxLines: 3,
                        onSubmitted: (_) => _processarEntrada(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Indicador de progresso
                LinearProgressIndicator(
                  value: _currentStep / _proximasPerguntas.length,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Etapa ${_currentStep + 1} de ${_proximasPerguntas.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Área de dados estruturados
          Expanded(
            child: _buildDadosEstruturados(),
          ),

          // Ações
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _salvarAvaliacao,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Avaliação'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _finalizarAvaliacao,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Finalizar e Gerar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDadosEstruturados() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados da Avaliação',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCampoEstruturado('Nome Completo', 'nome'),
          _buildCampoEstruturado('CPF', 'cpf'),
          _buildCampoEstruturado('Prontuário', 'prontuario'),
          _buildCampoEstruturado('Idade', 'idade'),
          _buildCampoEstruturado('Peso (kg)', 'peso'),
          _buildCampoEstruturado('Altura (cm)', 'altura'),
          _buildCampoEstruturado('História Médica', 'historia_medica', maxLines: 3),
          _buildCampoEstruturado('Medicamentos em Uso', 'medicamentos', maxLines: 2),
          _buildCampoEstruturado('Alergias', 'alergias'),
          _buildCampoEstruturado('Exames Complementares', 'exames_complementares', maxLines: 2),
          _buildCampoEstruturado('Avaliação Pré-Anestésica', 'avaliacao_pre_anestesica', maxLines: 3),
          _buildCampoEstruturado('Risco Cirúrgico', 'risco_cirurgico'),
          _buildCampoEstruturado('Observações', 'observacoes', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildCampoEstruturado(String label, String key, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              _avaliacaoData[key]?.toString().isNotEmpty == true 
                  ? _avaliacaoData[key].toString()
                  : 'Não informado',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _avaliacaoData[key]?.toString().isNotEmpty == true
                    ? null
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontStyle: _avaliacaoData[key]?.toString().isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processarEntrada() {
    final texto = _inputController.text.trim();
    if (texto.isEmpty) return;

    // Simular processamento da IA
    _processarComIA(texto);
    
    _inputController.clear();
    
    // Avançar para próxima etapa
    if (_currentStep < _proximasPerguntas.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _processarComIA(String entrada) {
    // Simular processamento inteligente da IA
    String campo = '';
    String valor = entrada;

    // Lógica simples para determinar qual campo preencher
    if (_currentStep < _proximasPerguntas.length) {
      switch (_currentStep) {
        case 0:
          campo = 'nome';
          break;
        case 1:
          campo = 'cpf';
          break;
        case 2:
          campo = 'idade';
          break;
        case 3:
          campo = 'peso';
          // Simular extração de peso e altura
          final match = RegExp(r'(\d+)\s*(kg|kilos?).*?(\d+)\s*(cm|centimetros?)').firstMatch(entrada.toLowerCase());
          if (match != null) {
            setState(() {
              _avaliacaoData['peso'] = '${match.group(1)} kg';
              _avaliacaoData['altura'] = '${match.group(3)} cm';
            });
            return;
          }
          break;
        case 4:
          campo = 'historia_medica';
          break;
        case 5:
          campo = 'medicamentos';
          break;
        case 6:
          campo = 'alergias';
          break;
        case 7:
          campo = 'exames_complementares';
          break;
        case 8:
          campo = 'avaliacao_pre_anestesica';
          break;
        case 9:
          campo = 'risco_cirurgico';
          // Simular cálculo de risco
          if (entrada.toLowerCase().contains('alto') || entrada.toLowerCase().contains('elevado')) {
            valor = 'ALTO RISCO - Requer atenção especial';
          } else if (entrada.toLowerCase().contains('médio') || entrada.toLowerCase().contains('moderado')) {
            valor = 'RISCO MÉDIO - Monitoramento padrão';
          } else {
            valor = 'BAIXO RISCO - Procedimento rotineiro';
          }
          break;
        case 10:
          campo = 'observacoes';
          break;
      }
    }

    if (campo.isNotEmpty) {
      setState(() {
        _avaliacaoData[campo] = valor;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informação processada e adicionada ao campo: $campo'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _adicionarFoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de câmera em desenvolvimento'),
      ),
    );
  }

  void _adicionarAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de gravação de áudio em desenvolvimento'),
      ),
    );
  }

  void _adicionarDocumento() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de anexo de documentos em desenvolvimento'),
      ),
    );
  }

  void _salvarAvaliacao() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avaliação salva com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _finalizarAvaliacao() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Avaliação'),
        content: const Text(
          'Deseja finalizar a avaliação e gerar o PDF assinado para o prontuário?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF gerado e adicionado ao prontuário com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Volta para a página anterior
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
