import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'avaliacao_pacientes_page.dart';

// Modelo de dados do prontuário com estrutura JSON
class ProntuarioData {
  Map<String, dynamic> dados;
  List<Map<String, dynamic>> historico;
  bool temAlteracoesPendentes;
  
  ProntuarioData({
    required this.dados,
    List<Map<String, dynamic>>? historico,
    this.temAlteracoesPendentes = false,
  }) : historico = historico ?? [];
  
  // Mock data completo
  factory ProntuarioData.mockCompleto(Paciente paciente) {
    return ProntuarioData(
      dados: {
        'identificacao': {
          'nome': paciente.nome,
          'cpf': paciente.cpf.isNotEmpty ? paciente.cpf : '123.456.789-00',
          'prontuario': paciente.prontuario,
          'dataNascimento': paciente.dataNascimento,
          'idade': _calcularIdade(paciente.dataNascimento),
        },
        'dadosFisicos': {
          'peso': '75 kg',
          'altura': '175 cm',
          'imc': '24.5',
          'pressaoArterial': '120/80 mmHg',
          'frequenciaCardiaca': '72 bpm',
        },
        'historiaMedica': {
          'condicoes': [
            'Hipertensão arterial sistêmica',
            'Diabetes mellitus tipo 2',
          ],
          'cirurgiasAnteriores': [
            {'cirurgia': 'Apendicectomia', 'ano': '1995'},
          ],
          'alergias': ['Nenhuma alergia conhecida'],
        },
        'medicamentos': [
          {'nome': 'Losartana', 'dose': '50mg', 'frequencia': '1x/dia'},
          {'nome': 'Metformina', 'dose': '850mg', 'frequencia': '2x/dia'},
          {'nome': 'AAS', 'dose': '100mg', 'frequencia': '1x/dia'},
        ],
        'examesComplementares': {
          'laboratoriais': {
            'hemograma': 'Dentro da normalidade',
            'glicemiaJejum': '120 mg/dL',
            'creatinina': '1.1 mg/dL',
            'ureia': '35 mg/dL',
          },
          'imagem': {
            'ecg': 'Ritmo sinusal normal',
            'raioXTorax': 'Sem alterações',
          },
        },
        'avaliacaoPreAnestesica': {
          'classificacaoASA': 'ASA II',
          'riscoCircurgico': 'Moderado',
          'recomendacoes': [
            'Monitoramento glicêmico',
            'Atenção a pressão arterial',
          ],
          'observacoes': 'Paciente com bom estado geral. Aptidão para procedimento cirúrgico confirmada.',
        },
      },
      historico: [
        {
          'versao': 1,
          'data': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'usuario': 'Dr. Carlos Silva',
          'acao': 'Criação do prontuário',
        },
        {
          'versao': 2,
          'data': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'usuario': 'Dra. Ana Santos',
          'acao': 'Atualização de exames complementares',
        },
      ],
    );
  }
  
  static String _calcularIdade(String dataNascimento) {
    try {
      final parts = dataNascimento.split('/');
      final nascimento = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final idade = DateTime.now().year - nascimento.year;
      return '$idade anos';
    } catch (e) {
      return 'N/A';
    }
  }
}

class EditarProntuarioPage extends ConsumerStatefulWidget {
  final Paciente paciente;
  final bool isNovo;
  
  const EditarProntuarioPage({
    super.key,
    required this.paciente,
    this.isNovo = false,
  });

  @override
  ConsumerState<EditarProntuarioPage> createState() => _EditarProntuarioPageState();
}

class _EditarProntuarioPageState extends ConsumerState<EditarProntuarioPage> {
  late ProntuarioData _prontuarioData;
  final TextEditingController _inputController = TextEditingController();
  final Set<String> _expandedNodes = {};
  bool _isProcessandoIA = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.isNovo) {
      _prontuarioData = ProntuarioData(dados: {
        'identificacao': {
          'nome': widget.paciente.nome,
          'dataNascimento': widget.paciente.dataNascimento,
          'prontuario': widget.paciente.prontuario,
        }
      });
    } else {
      _prontuarioData = ProntuarioData.mockCompleto(widget.paciente);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNovo ? 'Novo Prontuário' : 'Editar Prontuário'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_prontuarioData.temAlteracoesPendentes)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Alterações não liberadas', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange,
                avatar: const Icon(Icons.warning, size: 16, color: Colors.white),
              ),
            ),
          IconButton(
            onPressed: _mostrarHistorico,
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Versões',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de entrada multimodal
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
                // Input multimodal
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Barra de ferramentas
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              onPressed: _adicionarImagem,
                              icon: const Icon(Icons.image, size: 20),
                              tooltip: 'Adicionar Imagem',
                            ),
                            IconButton(
                              onPressed: _adicionarAudio,
                              icon: const Icon(Icons.mic, size: 20),
                              tooltip: 'Gravar Áudio',
                            ),
                            IconButton(
                              onPressed: _adicionarAnexo,
                              icon: const Icon(Icons.attach_file, size: 20),
                              tooltip: 'Anexar Documento',
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Gemini processará automaticamente',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            if (_isProcessandoIA)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                      // Campo de texto
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Digite ou cole informações, envie imagens/áudio...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            onPressed: _processarComGemini,
                            icon: const Icon(Icons.send),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        maxLines: 3,
                        onSubmitted: (_) => _processarComGemini(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Botão de IA
                ElevatedButton.icon(
                  onPressed: _abrirSugestoesIA,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Sugestões da IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Árvore de dados
          Expanded(
            child: _buildArvoreExpandivel(),
          ),
          
          // Botão de liberar avaliação
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _prontuarioData.temAlteracoesPendentes ? _liberarAvaliacao : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Liberar Avaliação / Consulta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArvoreExpandivel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Dados do Prontuário',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildNosPrincipais(_prontuarioData.dados),
      ],
    );
  }

  List<Widget> _buildNosPrincipais(Map<String, dynamic> dados) {
    final widgets = <Widget>[];
    
    dados.forEach((chave, valor) {
      widgets.add(_buildNo(chave, valor, 0));
    });
    
    return widgets;
  }

  Widget _buildNo(String chave, dynamic valor, int nivel) {
    final chaveCompleta = '$nivel-$chave';
    final isExpanded = _expandedNodes.contains(chaveCompleta);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            if (valor is Map || valor is List) {
              setState(() {
                if (isExpanded) {
                  _expandedNodes.remove(chaveCompleta);
                } else {
                  _expandedNodes.add(chaveCompleta);
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 * nivel,
              top: 8,
              bottom: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              color: nivel == 0 
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (valor is Map || valor is List) ...[
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ] else
                  const SizedBox(width: 28),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatarChave(chave),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (valor is! Map && valor is! List) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatarValor(valor),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (_prontuarioData.temAlteracoesPendentes)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        if (isExpanded) ...[
          if (valor is Map)
            ...valor.entries.map((entry) => _buildNo(entry.key, entry.value, nivel + 1))
          else if (valor is List)
            ...valor.asMap().entries.map((entry) => _buildNo('Item ${entry.key + 1}', entry.value, nivel + 1)),
        ],
        
        const SizedBox(height: 4),
      ],
    );
  }

  String _formatarChave(String chave) {
    // Converter camelCase para título legível
    final palavras = chave.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).split(' ');
    
    return palavras
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ')
        .trim();
  }

  String _formatarValor(dynamic valor) {
    if (valor == null) return 'Não informado';
    return valor.toString();
  }

  Future<void> _processarComGemini() async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty) return;
    
    setState(() {
      _isProcessandoIA = true;
    });
    
    // Simular processamento do Gemini
    await Future.delayed(const Duration(seconds: 2));
    
    // Simular resposta JSON do Gemini
    final jsonResposta = {
      'categoria': 'examesComplementares',
      'dados': {
        'laboratoriais': {
          'hemograma': texto,
        },
      },
    };
    
    // Incorporar ao prontuário
    setState(() {
      _incorporarDadosGemini(jsonResposta);
      _prontuarioData.temAlteracoesPendentes = true;
      _isProcessandoIA = false;
      _inputController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados processados e incorporados com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Auto-save
    _autoSalvar();
  }

  void _incorporarDadosGemini(Map<String, dynamic> jsonResposta) {
    final categoria = jsonResposta['categoria'] as String?;
    final dados = jsonResposta['dados'] as Map<String, dynamic>?;
    
    if (categoria != null && dados != null) {
      if (_prontuarioData.dados.containsKey(categoria)) {
        _mesclarDados(_prontuarioData.dados[categoria], dados);
      } else {
        _prontuarioData.dados[categoria] = dados;
      }
    }
  }

  void _mesclarDados(dynamic destino, dynamic origem) {
    if (destino is Map && origem is Map) {
      origem.forEach((chave, valor) {
        if (destino.containsKey(chave) && destino[chave] is Map && valor is Map) {
          _mesclarDados(destino[chave], valor);
        } else {
          destino[chave] = valor;
        }
      });
    }
  }

  Future<void> _autoSalvar() async {
    // Simular auto-save
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Implementar salvamento no backend
  }

  void _adicionarImagem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _simularProcessamentoImagem('câmera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _simularProcessamentoImagem('galeria');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simularProcessamentoImagem(String origem) async {
    setState(() {
      _isProcessandoIA = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Processando imagem da $origem...')),
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Simular extração de dados da imagem pelo Gemini
    final dadosExtraidos = {
      'categoria': 'examesComplementares',
      'dados': {
        'imagem': {
          'descricao': 'Exame de imagem processado',
          'data': DateFormat('dd/MM/yyyy').format(DateTime.now()),
        },
      },
    };
    
    setState(() {
      _incorporarDadosGemini(dadosExtraidos);
      _prontuarioData.temAlteracoesPendentes = true;
      _isProcessandoIA = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagem processada e dados extraídos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    
    _autoSalvar();
  }

  void _adicionarAudio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gravar Áudio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gravação de áudio'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _simularProcessamentoAudio();
              },
              icon: const Icon(Icons.stop),
              label: const Text('Parar e Processar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simularProcessamentoAudio() async {
    setState(() {
      _isProcessandoIA = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transcrevendo e processando áudio...')),
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Simular transcrição e extração pelo Gemini
    final dadosExtraidos = {
      'categoria': 'historiaMedica',
      'dados': {
        'observacoes': 'Paciente relata dor no peito ocasional. Histórico de hipertensão controlada.',
      },
    };
    
    setState(() {
      _incorporarDadosGemini(dadosExtraidos);
      _prontuarioData.temAlteracoesPendentes = true;
      _isProcessandoIA = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Áudio transcrito e processado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    
    _autoSalvar();
  }

  void _adicionarAnexo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seletor de arquivos em desenvolvimento')),
    );
  }

  void _abrirSugestoesIA() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'Sugestões da IA',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSugestaoCard(
                      'Aplicar Escore de Risco',
                      'Calcular escore de risco cardiovascular baseado nos dados atuais',
                      Icons.calculate,
                      Colors.orange,
                      () => _aplicarEscoreRisco(),
                    ),
                    _buildSugestaoCard(
                      'Revisar Medicamentos',
                      'Análise de interações medicamentosas e sugestões de ajustes',
                      Icons.medication,
                      Colors.purple,
                      () => _revisarMedicamentos(),
                    ),
                    _buildSugestaoCard(
                      'Verificar Protocolos',
                      'Comparar com protocolos institucionais e diretrizes',
                      Icons.checklist,
                      Colors.green,
                      () => _verificarProtocolos(),
                    ),
                    _buildSugestaoCard(
                      'Análise Completa',
                      'Análise abrangente com todas as sugestões disponíveis',
                      Icons.auto_awesome,
                      Colors.blue,
                      () => _analiseCompleta(),
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

  Widget _buildSugestaoCard(
    String titulo,
    String descricao,
    IconData icone,
    Color cor,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(icone, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(descricao),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Future<void> _aplicarEscoreRisco() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('IA calculando escore de risco...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    Navigator.pop(context);
    
    setState(() {
      _prontuarioData.dados['escoreRisco'] = {
        'framingham': '15% em 10 anos',
        'classificacao': 'Risco Moderado',
        'recomendacoes': [
          'Manter controle glicêmico',
          'Monitorar pressão arterial',
          'Considerar estatina',
        ],
        'calculadoPor': 'IA - Gemini',
        'data': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      };
      _prontuarioData.temAlteracoesPendentes = true;
    });
    
    _autoSalvar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escore de risco calculado e adicionado ao prontuário!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _revisarMedicamentos() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('IA analisando medicamentos...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    Navigator.pop(context);
    
    setState(() {
      _prontuarioData.dados['revisaoMedicamentosa'] = {
        'interacoes': [
          {
            'medicamentos': ['Losartana', 'AAS'],
            'severidade': 'Leve',
            'descricao': 'Possível aumento do risco de sangramento',
          },
        ],
        'sugestoes': [
          'Considerar ajuste de dose de Metformina se ClCr < 60',
          'Manter AAS para prevenção cardiovascular',
        ],
        'analisadoPor': 'IA - Gemini',
        'data': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      };
      _prontuarioData.temAlteracoesPendentes = true;
    });
    
    _autoSalvar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revisão medicamentosa concluída!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _verificarProtocolos() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('IA verificando protocolos...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    Navigator.pop(context);
    
    setState(() {
      _prontuarioData.dados['conformidadeProtocolos'] = {
        'protocolosVerificados': [
          'Protocolo de hipertensão - Conforme',
          'Protocolo de diabetes - Conforme',
          'Checklist pré-operatório - Pendente',
        ],
        'alertas': [
          'Completar checklist pré-operatório',
        ],
        'verificadoPor': 'IA - Gemini',
        'data': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      };
      _prontuarioData.temAlteracoesPendentes = true;
    });
    
    _autoSalvar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verificação de protocolos concluída!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _analiseCompleta() async {
    await _aplicarEscoreRisco();
    await Future.delayed(const Duration(milliseconds: 500));
    await _revisarMedicamentos();
    await Future.delayed(const Duration(milliseconds: 500));
    await _verificarProtocolos();
  }

  void _mostrarHistorico() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Versões'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _prontuarioData.historico.length,
            itemBuilder: (context, index) {
              final versao = _prontuarioData.historico[index];
              final data = DateTime.parse(versao['data'] as String);
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${versao['versao']}'),
                ),
                title: Text(versao['acao'] as String),
                subtitle: Text(
                  '${versao['usuario']}\n${DateFormat('dd/MM/yyyy HH:mm').format(data)}',
                ),
                isThreeLine: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _liberarAvaliacao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liberar Avaliação'),
        content: const Text(
          'Ao liberar a avaliação, uma nova versão do prontuário será criada e ficará permanentemente registrada no histórico de auditoria. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );
    
    if (confirmar == true) {
      // Criar nova versão no histórico
      final novaVersao = {
        'versao': _prontuarioData.historico.length + 1,
        'data': DateTime.now().toIso8601String(),
        'usuario': 'Dr. Gabriel Silva', // TODO: Pegar do usuário logado
        'acao': 'Atualização de dados clínicos',
        'snapshot': jsonEncode(_prontuarioData.dados),
      };
      
      setState(() {
        _prontuarioData.historico.add(novaVersao);
        _prontuarioData.temAlteracoesPendentes = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avaliação liberada com sucesso! Nova versão criada.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Voltar para a lista
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}

