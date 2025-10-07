import 'package:flutter/material.dart';
import 'avaliacao_pacientes_page.dart';
import 'avaliacao_paciente_ia_page.dart';

class VisualizarPDFPage extends StatefulWidget {
  final Paciente paciente;

  const VisualizarPDFPage({super.key, required this.paciente});

  @override
  State<VisualizarPDFPage> createState() => _VisualizarPDFPageState();
}

class _VisualizarPDFPageState extends State<VisualizarPDFPage> {
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _carregarPDF();
  }

  void _carregarPDF() {
    // Simular carregamento do PDF
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prontuário - ${widget.paciente.nome}'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download do PDF iniciado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compartilhar PDF'),
                ),
              );
            },
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando prontuário...'),
                ],
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar PDF',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = '';
                          });
                          _carregarPDF();
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header do PDF
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
                          Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prontuário - ${widget.paciente.nome}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Prontuário: ${widget.paciente.prontuario} | CPF: ${widget.paciente.cpf}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AvaliacaoPacienteIAPage(
                                    pacienteNome: widget.paciente.nome,
                                    procedimento: 'Cirurgia',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Área de visualização do PDF (simulada)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Toolbar do PDF
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.zoom_out),
                                    iconSize: 20,
                                  ),
                                  Text(
                                    '100%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.zoom_in),
                                    iconSize: 20,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Página 1 de 5',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.navigate_before),
                                    iconSize: 20,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.navigate_next),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Conteúdo do PDF (simulado)
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            'PRONTUÁRIO MÉDICO',
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            widget.paciente.nome,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Prontuário: ${widget.paciente.prontuario}',
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                          Text(
                                            'CPF: ${widget.paciente.cpf}',
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    
                                    // Dados do paciente simulados
                                    _buildSecaoPDF('DADOS PESSOAIS', [
                                      'Nome: ${widget.paciente.nome}',
                                      'CPF: ${widget.paciente.cpf}',
                                      'Data de Nascimento: 15/03/1980',
                                      'Idade: 44 anos',
                                      'Peso: 75 kg',
                                      'Altura: 175 cm',
                                    ]),
                                    
                                    _buildSecaoPDF('HISTÓRIA MÉDICA', [
                                      'Hipertensão arterial sistêmica',
                                      'Diabetes mellitus tipo 2',
                                      'Nenhuma alergia conhecida',
                                      'Cirurgia de apendicectomia em 1995',
                                    ]),
                                    
                                    _buildSecaoPDF('MEDICAÇÕES ATUAIS', [
                                      'Losartana 50mg - 1x/dia',
                                      'Metformina 850mg - 2x/dia',
                                      'AAS 100mg - 1x/dia',
                                    ]),
                                    
                                    _buildSecaoPDF('EXAMES COMPLEMENTARES', [
                                      'ECG: Ritmo sinusal normal',
                                      'Hemograma: Dentro da normalidade',
                                      'Glicemia de jejum: 120 mg/dL',
                                      'Creatinina: 1.1 mg/dL',
                                    ]),
                                    
                                    _buildSecaoPDF('AVALIAÇÃO PRÉ-ANESTÉSICA', [
                                      'Paciente com bom estado geral',
                                      'ASA II (risco moderado)',
                                      'Aptidão para procedimento cirúrgico',
                                      'Recomendações: Monitoramento glicêmico',
                                    ]),
                                    
                                    const SizedBox(height: 40),
                                    
                                    // Assinatura
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Dr. Gabriel Silva',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const Text(
                                              'CRM 123456',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            const Text(
                                              'Anestesiologista',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              width: 200,
                                              height: 2,
                                              color: Colors.black,
                                            ),
                                            const Text(
                                              'Assinatura Digital',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSecaoPDF(String titulo, List<String> itens) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          ...itens.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(color: Colors.black),
            ),
          )),
        ],
      ),
    );
  }
}
