/// Serviço para anonimização de dados antes de enviar para IA
/// CRÍTICO: Nunca enviar dados identificáveis (nome, CPF, endereço, etc) para Gemini
class AnonimizacaoService {
  /// Lista de campos que devem ser removidos antes de enviar para IA
  static const Set<String> camposIdentificaveis = {
    'nome',
    'cpf',
    'rg',
    'cns', // Cartão Nacional de Saúde
    'prontuario',
    'endereco',
    'telefone',
    'email',
    'nomeMae',
    'nomePai',
    'dataNascimento', // Pode ser usado para identificação
    'numeroDocumento',
    'cartaoSus',
    'tituloEleitor',
  };

  /// Remove dados identificáveis de um Map antes de enviar para IA
  Map<String, dynamic> anonimizar(Map<String, dynamic> dados) {
    final dadosAnonimos = Map<String, dynamic>.from(dados);
    
    _removerCamposRecursivo(dadosAnonimos);
    
    return dadosAnonimos;
  }
  
  void _removerCamposRecursivo(dynamic dados) {
    if (dados is Map<String, dynamic>) {
      // Remover campos identificáveis
      dados.removeWhere((key, value) => 
        camposIdentificaveis.contains(key.toLowerCase())
      );
      
      // Processar recursivamente
      dados.forEach((key, value) {
        _removerCamposRecursivo(value);
      });
    } else if (dados is List) {
      for (var item in dados) {
        _removerCamposRecursivo(item);
      }
    }
  }
  
  /// Cria um contexto anonimizado para enviar à IA
  Map<String, dynamic> criarContextoAnonimo(Map<String, dynamic> prontuario) {
    return {
      'idade': _calcularIdade(prontuario),
      'sexo': prontuario['identificacao']?['sexo'],
      'peso': prontuario['dadosFisicos']?['peso'],
      'altura': prontuario['dadosFisicos']?['altura'],
      'historiaMedica': prontuario['historiaMedica'],
      'medicamentos': prontuario['medicamentos'],
      'exames': _anonimizarExames(prontuario['examesComplementares']),
      'avaliacaoPrevia': prontuario['avaliacaoPreAnestesica'],
    };
  }
  
  String? _calcularIdade(Map<String, dynamic> prontuario) {
    final dataNasc = prontuario['identificacao']?['dataNascimento'];
    if (dataNasc == null) return null;
    
    try {
      final parts = dataNasc.split('/');
      final nascimento = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final idade = DateTime.now().year - nascimento.year;
      return '$idade anos';
    } catch (e) {
      return null;
    }
  }
  
  Map<String, dynamic>? _anonimizarExames(dynamic exames) {
    if (exames == null) return null;
    
    final examesAnonimos = Map<String, dynamic>.from(exames);
    
    // Remover metadados que possam identificar
    examesAnonimos.remove('laboratorio');
    examesAnonimos.remove('medico');
    examesAnonimos.remove('local');
    
    return examesAnonimos;
  }
  
  /// Valida se o texto contém dados identificáveis antes de enviar
  bool contemDadosIdentificaveis(String texto) {
    final textoLower = texto.toLowerCase();
    
    // Padrões que indicam dados pessoais
    final padroes = [
      RegExp(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b'), // CPF
      RegExp(r'\b\d{2}\.\d{3}\.\d{3}-\d{1}\b'), // RG
      RegExp(r'\b[A-Za-z\s]+\s+da\s+Silva\b', caseSensitive: false), // Nomes comuns
      RegExp(r'\b\d{11}\b'), // CNS sem formatação
      RegExp(r'rua\s+[A-Za-z\s]+,?\s*\d+', caseSensitive: false), // Endereço
      RegExp(r'\(\d{2}\)\s*\d{4,5}-\d{4}'), // Telefone
      RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b'), // Email
    ];
    
    for (var padrao in padroes) {
      if (padrao.hasMatch(texto)) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Sanitiza texto removendo possíveis dados pessoais
  String sanitizarTexto(String texto) {
    var textoSanitizado = texto;
    
    // Remover CPF
    textoSanitizado = textoSanitizado.replaceAll(
      RegExp(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b'),
      '[CPF REMOVIDO]',
    );
    
    // Remover RG
    textoSanitizado = textoSanitizado.replaceAll(
      RegExp(r'\b\d{2}\.\d{3}\.\d{3}-\d{1}\b'),
      '[RG REMOVIDO]',
    );
    
    // Remover telefones
    textoSanitizado = textoSanitizado.replaceAll(
      RegExp(r'\(\d{2}\)\s*\d{4,5}-\d{4}'),
      '[TELEFONE REMOVIDO]',
    );
    
    // Remover emails
    textoSanitizado = textoSanitizado.replaceAll(
      RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b'),
      '[EMAIL REMOVIDO]',
    );
    
    return textoSanitizado;
  }
}

