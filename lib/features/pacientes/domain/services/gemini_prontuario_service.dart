import 'dart:convert';
import 'anonimizacao_service.dart';
import 'gemini_prompts.dart';

/// Serviço para integração com Gemini API para processamento de prontuários
/// 
/// SEGURANÇA E PRIVACIDADE:
/// - NUNCA envia dados identificáveis (nome, CPF, etc) para a API
/// - Todos os dados são anonimizados antes do envio
/// - Usa prompts estruturados para guiar geração correta de JSON
/// - Valida resposta antes de incorporar ao prontuário
class GeminiProntuarioService {
  final AnonimizacaoService _anonimizacao = AnonimizacaoService();
  
  // TODO: Configurar com as credenciais do projeto
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _apiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _visionEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';
  
  /// Processa texto livre e extrai dados estruturados para o prontuário
  /// 
  /// SEGURANÇA: Anonimiza o contexto antes de enviar para Gemini
  Future<Map<String, dynamic>> processarTexto(
    String texto, {
    Map<String, dynamic>? contexto,
  }) async {
    try {
      // 1. VALIDAR SE TEXTO CONTÉM DADOS IDENTIFICÁVEIS
      if (_anonimizacao.contemDadosIdentificaveis(texto)) {
        // Sanitizar automaticamente
        texto = _anonimizacao.sanitizarTexto(texto);
      }
      
      // 2. ANONIMIZAR CONTEXTO
      Map<String, dynamic>? contextoAnonimo;
      if (contexto != null) {
        contextoAnonimo = _anonimizacao.criarContextoAnonimo(contexto);
      }
      
      // 3. CONSTRUIR PROMPT ESTRUTURADO
      final prompt = GeminiPrompts.textoParaJSON(
        textoUsuario: texto,
        contextoAnonimo: contextoAnonimo,
      );
      
      // 4. ENVIAR PARA GEMINI
      // TODO: Implementar chamada real
      // final response = await _chamarGeminiAPI(prompt);
      
      // Por enquanto, simular
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock de resposta estruturada
      return _extrairDadosDeTexto(texto);
    } catch (e) {
      throw Exception('Erro ao processar texto: $e');
    }
  }
  
  /// Processa imagem e extrai informações médicas
  /// 
  /// SEGURANÇA: Anonimiza contexto antes de enviar
  /// IMPORTANTE: A imagem em si pode conter dados identificáveis.
  /// Em produção, considere:
  /// 1. OCR para detectar e remover dados pessoais
  /// 2. Recortar áreas com informações identificáveis
  /// 3. Avisar usuário sobre privacidade
  Future<Map<String, dynamic>> processarImagem(
    String imagemBase64, {
    Map<String, dynamic>? contexto,
    String tipoEsperado = 'exame',
  }) async {
    try {
      // 1. ANONIMIZAR CONTEXTO
      Map<String, dynamic>? contextoAnonimo;
      if (contexto != null) {
        contextoAnonimo = _anonimizacao.criarContextoAnonimo(contexto);
      }
      
      // 2. CONSTRUIR PROMPT PARA ANÁLISE DE IMAGEM
      final prompt = GeminiPrompts.imagemParaJSON(
        tipoEsperado: tipoEsperado,
        contextoAnonimo: contextoAnonimo,
      );
      
      // 3. ENVIAR PARA GEMINI VISION
      // TODO: Implementar chamada real com imagem base64
      // final response = await _chamarGeminiVision(prompt, imagemBase64);
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock de resposta
      return {
        'categoria': 'examesComplementares',
        'confianca': 0.85,
        'dados': {
          'imagem': {
            'tipo': 'Exame de imagem',
            'descricao': 'Raio-X de tórax - análise preliminar sem alterações significativas',
            'processadoPor': 'Gemini Vision',
            'legibilidade': 'alta',
          },
        },
        'alertas': [],
      };
    } catch (e) {
      throw Exception('Erro ao processar imagem: $e');
    }
  }
  
  /// Processa áudio transcrito e extrai dados
  /// 
  /// SEGURANÇA: 
  /// 1. Primeiro transcreve o áudio (Speech-to-Text)
  /// 2. Sanitiza a transcrição removendo dados identificáveis
  /// 3. Envia para Gemini com contexto anonimizado
  Future<Map<String, dynamic>> processarAudio(
    String audioBase64, {
    Map<String, dynamic>? contexto,
  }) async {
    try {
      // 1. TRANSCREVER ÁUDIO
      // TODO: Usar Speech-to-Text API
      // final transcricao = await _transcricaoAudio(audioBase64);
      
      // Mock de transcrição
      await Future.delayed(const Duration(seconds: 2));
      final transcricao = 'Paciente relata dor torácica ocasional, com irradiação para braço esquerdo. Histórico familiar de cardiopatia.';
      
      // 2. SANITIZAR TRANSCRIÇÃO
      final transcricaoSegura = _anonimizacao.sanitizarTexto(transcricao);
      
      // 3. ANONIMIZAR CONTEXTO
      Map<String, dynamic>? contextoAnonimo;
      if (contexto != null) {
        contextoAnonimo = _anonimizacao.criarContextoAnonimo(contexto);
      }
      
      // 4. CONSTRUIR PROMPT
      final prompt = GeminiPrompts.audioParaJSON(
        transcricao: transcricaoSegura,
        contextoAnonimo: contextoAnonimo,
      );
      
      // 5. PROCESSAR COM GEMINI
      // TODO: Chamar API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock de resposta
      return {
        'transcricao': transcricaoSegura,
        'confianca': 0.92,
        'dados': {
          'categoria': 'historiaMedica',
          'dados': {
            'queixaPrincipal': 'Dor torácica ocasional',
            'caracteristicas': 'Irradiação para braço esquerdo',
            'historicoFamiliar': 'Cardiopatia',
          },
        },
        'alertas': [
          'Dor torácica com irradiação - considerar avaliação cardiológica',
        ],
      };
    } catch (e) {
      throw Exception('Erro ao processar áudio: $e');
    }
  }
  
  /// Gera sugestões baseadas nos dados do prontuário
  /// 
  /// SEGURANÇA: Anonimiza dados do prontuário antes de enviar
  Future<Map<String, dynamic>> gerarSugestoes(
    Map<String, dynamic> prontuarioData,
    String tipoSugestao,
  ) async {
    try {
      // 1. CRIAR CONTEXTO ANONIMIZADO
      final contextoAnonimo = _anonimizacao.criarContextoAnonimo(prontuarioData);
      
      // 2. SELECIONAR PROMPT APROPRIADO
      String prompt;
      switch (tipoSugestao) {
        case 'escore_risco':
          prompt = GeminiPrompts.calcularEscoreRisco(contextoAnonimo);
          break;
        case 'revisao_medicamentos':
          prompt = GeminiPrompts.revisarMedicamentos(contextoAnonimo);
          break;
        case 'protocolos':
          prompt = GeminiPrompts.verificarProtocolos(contextoAnonimo);
          break;
        case 'analise_completa':
          // Executar todas as análises
          return await _analiseCompleta(contextoAnonimo);
        default:
          throw Exception('Tipo de sugestão inválido: $tipoSugestao');
      }
      
      // 3. ENVIAR PARA GEMINI
      // TODO: Implementar chamada real
      // final response = await _chamarGeminiAPI(prompt);
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock baseado no tipo
      switch (tipoSugestao) {
        case 'escore_risco':
          return _calcularEscoreRisco(prontuarioData);
        case 'revisao_medicamentos':
          return _revisarMedicamentos(prontuarioData);
        case 'protocolos':
          return _verificarProtocolos(prontuarioData);
        default:
          return {};
      }
    } catch (e) {
      throw Exception('Erro ao gerar sugestões: $e');
    }
  }
  
  /// Chamada real para Gemini API (a ser implementada)
  Future<String> _chamarGeminiAPI(String prompt) async {
    // TODO: Implementar
    // final response = await http.post(
    //   Uri.parse(_apiEndpoint),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'x-goog-api-key': _apiKey,
    //   },
    //   body: jsonEncode({
    //     'contents': [
    //       {'parts': [{'text': prompt}]}
    //     ],
    //     'generationConfig': {
    //       'temperature': 0.2,
    //       'topK': 40,
    //       'topP': 0.95,
    //       'maxOutputTokens': 2048,
    //     },
    //   }),
    // );
    
    throw UnimplementedError('Implementar integração real com Gemini');
  }
  
  /// Chamada para Gemini Vision (a ser implementada)
  Future<String> _chamarGeminiVision(String prompt, String imagemBase64) async {
    // TODO: Implementar
    throw UnimplementedError('Implementar integração real com Gemini Vision');
  }
  
  Map<String, dynamic> _extrairDadosDeTexto(String texto) {
    // Lógica simplificada de extração (em produção, usar resposta do Gemini)
    final textoLower = texto.toLowerCase();
    
    if (textoLower.contains('pressão') || textoLower.contains('pa:')) {
      return {
        'categoria': 'dadosFisicos',
        'dados': {
          'pressaoArterial': texto,
        },
      };
    }
    
    if (textoLower.contains('medicamento') || textoLower.contains('remédio')) {
      return {
        'categoria': 'medicamentos',
        'dados': {
          'descricao': texto,
        },
      };
    }
    
    // Padrão genérico
    return {
      'categoria': 'observacoes',
      'dados': {
        'texto': texto,
        'dataHora': DateTime.now().toIso8601String(),
      },
    };
  }
  
  Map<String, dynamic> _calcularEscoreRisco(Map<String, dynamic> prontuario) {
    return {
      'escoreRisco': {
        'framingham': '15% em 10 anos',
        'classificacao': 'Risco Moderado',
        'fatoresRisco': [
          'Idade > 40 anos',
          'Hipertensão arterial',
          'Diabetes mellitus',
        ],
        'recomendacoes': [
          'Manter controle glicêmico rigoroso',
          'Monitorar pressão arterial regularmente',
          'Considerar início de estatina',
          'Estimular atividade física regular',
        ],
        'calculadoPor': 'IA - Gemini',
        'dataCalculo': DateTime.now().toIso8601String(),
      },
    };
  }
  
  Map<String, dynamic> _revisarMedicamentos(Map<String, dynamic> prontuario) {
    return {
      'revisaoMedicamentosa': {
        'medicamentosAnalisados': 3,
        'interacoes': [
          {
            'medicamentos': ['Losartana', 'AAS'],
            'severidade': 'Leve',
            'descricao': 'Possível aumento do risco de sangramento. Monitorar sinais.',
          },
        ],
        'alertas': [
          'Ajustar dose de Metformina se função renal comprometida (ClCr < 60)',
          'Verificar adesão ao tratamento anti-hipertensivo',
        ],
        'sugestoes': [
          'Manter AAS para prevenção cardiovascular secundária',
          'Considerar adicionar estatina ao regime terapêutico',
        ],
        'analisadoPor': 'IA - Gemini',
        'dataAnalise': DateTime.now().toIso8601String(),
      },
    };
  }
  
  Map<String, dynamic> _verificarProtocolos(Map<String, dynamic> prontuario) {
    return {
      'conformidadeProtocolos': {
        'protocolosVerificados': [
          {
            'nome': 'Protocolo de Hipertensão',
            'status': 'Conforme',
            'detalhes': 'Medicação adequada, controle pressórico em meta',
          },
          {
            'nome': 'Protocolo de Diabetes',
            'status': 'Conforme',
            'detalhes': 'HbA1c em meta, ajuste de dose conforme protocolo',
          },
          {
            'nome': 'Checklist Pré-Operatório',
            'status': 'Pendente',
            'detalhes': 'Itens pendentes: consentimento informado, marcação de sítio cirúrgico',
          },
        ],
        'alertas': [
          'Completar checklist pré-operatório antes do procedimento',
          'Documentar jejum pré-operatório',
        ],
        'recomendacoes': [
          'Seguir protocolo de suspensão de anticoagulantes se aplicável',
          'Garantir profilaxia antibiótica conforme protocolo institucional',
        ],
        'verificadoPor': 'IA - Gemini',
        'dataVerificacao': DateTime.now().toIso8601String(),
      },
    };
  }
  
  Future<Map<String, dynamic>> _analiseCompleta(Map<String, dynamic> contextoAnonimo) async {
    // Executar todas as análises em paralelo
    final results = await Future.wait([
      gerarSugestoes(contextoAnonimo, 'escore_risco'),
      gerarSugestoes(contextoAnonimo, 'revisao_medicamentos'),
      gerarSugestoes(contextoAnonimo, 'protocolos'),
    ]);
    
    return {
      'analiseCompleta': {
        'resumo': 'Paciente com comorbidades controladas, risco cirúrgico moderado',
        ...results[0], // escore de risco
        ...results[1], // revisão medicamentosa
        ...results[2], // verificação de protocolos
        'recomendacoesGerais': [
          'Manter controle glicêmico pré e pós-operatório',
          'Atenção especial ao manejo hemodinâmico',
          'Considerar monitorização invasiva se cirurgia de grande porte',
        ],
        'geradoEm': DateTime.now().toIso8601String(),
      },
    };
  }
}

