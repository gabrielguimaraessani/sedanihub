/// Prompts estruturados para Gemini - Guiam a geração correta de JSON
class GeminiPrompts {
  /// Prompt para processamento de texto livre
  static String textoParaJSON({
    required String textoUsuario,
    Map<String, dynamic>? contextoAnonimo,
  }) {
    return '''
Você é um assistente médico especializado em anestesiologia e medicina clínica.

IMPORTANTE - PRIVACIDADE:
- Os dados fornecidos JÁ FORAM ANONIMIZADOS
- Você NÃO deve pedir ou mencionar dados pessoais (nome, CPF, endereço, etc)
- Foque apenas em dados clínicos relevantes

TAREFA:
Analise o texto médico fornecido e extraia informações clínicas relevantes.
Retorne APENAS um JSON válido, sem texto adicional antes ou depois.

CONTEXTO ANÔNIMO DO PACIENTE:
${contextoAnonimo != null ? _formatarContexto(contextoAnonimo) : 'Não disponível'}

TEXTO PARA ANÁLISE:
$textoUsuario

FORMATO DE RESPOSTA (retorne APENAS o JSON):
{
  "categoria": "dadosFisicos|historiaMedica|medicamentos|examesComplementares|avaliacaoPreAnestesica|observacoes",
  "confianca": 0.0-1.0,
  "dados": {
    // Dados estruturados extraídos do texto
    // Use subcategorias apropriadas
  },
  "alertas": [
    // Array com alertas clínicos importantes, se houver
  ]
}

CATEGORIAS DISPONÍVEIS:
- dadosFisicos: Sinais vitais, medidas antropométricas
- historiaMedica: Doenças, cirurgias prévias, história familiar
- medicamentos: Medicações em uso, alergias medicamentosas
- examesComplementares: Resultados de exames lab/imagem
- avaliacaoPreAnestesica: Classificação ASA, risco cirúrgico
- observacoes: Outras informações clínicas relevantes

REGRAS:
1. Retorne APENAS o JSON, sem explicações
2. Use valores numéricos com unidades (ex: "120/80 mmHg")
3. Seja preciso e objetivo
4. Inclua alertas se identificar riscos
5. Use terminologia médica padrão
''';
  }

  /// Prompt para análise de imagem médica
  static String imagemParaJSON({
    required String tipoEsperado,
    Map<String, dynamic>? contextoAnonimo,
  }) {
    return '''
Você é um assistente médico especializado em análise de imagens e documentos médicos.

IMPORTANTE - PRIVACIDADE:
- NÃO extraia ou mencione dados pessoais (nome, CPF, endereço)
- Foque APENAS em informações clínicas
- Se encontrar dados pessoais na imagem, IGNORE-OS

TAREFA:
Analise a imagem médica e extraia informações clínicas relevantes.

TIPO ESPERADO: $tipoEsperado

CONTEXTO ANÔNIMO DO PACIENTE:
${contextoAnonimo != null ? _formatarContexto(contextoAnonimo) : 'Não disponível'}

FORMATO DE RESPOSTA (JSON):
{
  "tipoImagem": "exame_laboratorial|exame_imagem|documento|outro",
  "confianca": 0.0-1.0,
  "dados": {
    "descricao": "Descrição da imagem",
    "achados": ["Lista de achados principais"],
    "valores": {
      // Para exames lab: valores extraídos
    },
    "impressao": "Impressão diagnóstica se aplicável"
  },
  "alertas": [
    // Valores críticos ou achados importantes
  ],
  "legibilidade": "alta|media|baixa"
}

REGRAS:
1. Retorne APENAS JSON
2. Se não conseguir ler, indique legibilidade: baixa
3. Para exames laboratoriais, extraia todos os valores
4. Para imagens (RX, TC, RM), descreva achados principais
5. Indique valores críticos nos alertas
''';
  }

  /// Prompt para transcrição e análise de áudio
  static String audioParaJSON({
    required String transcricao,
    Map<String, dynamic>? contextoAnonimo,
  }) {
    return '''
Você é um assistente médico especializado em documentação clínica.

IMPORTANTE - PRIVACIDADE:
- A transcrição já foi sanitizada
- Foque em informações clínicas
- Ignore referências a dados pessoais

TAREFA:
Analise a transcrição do áudio médico e estruture as informações.

CONTEXTO ANÔNIMO DO PACIENTE:
${contextoAnonimo != null ? _formatarContexto(contextoAnonimo) : 'Não disponível'}

TRANSCRIÇÃO:
$transcricao

FORMATO DE RESPOSTA (JSON):
{
  "categorias": {
    "queixaPrincipal": "...",
    "historiaMedica": {...},
    "exameFisico": {...},
    "hipoteseDiagnostica": "...",
    "conduta": {...}
  },
  "alertas": [
    // Informações críticas mencionadas
  ],
  "confianca": 0.0-1.0
}

REGRAS:
1. Retorne APENAS JSON
2. Organize por seções clínicas padrão
3. Mantenha terminologia médica
4. Destaque informações urgentes em alertas
''';
  }

  /// Prompt para cálculo de escore de risco
  static String calcularEscoreRisco(Map<String, dynamic> contextoAnonimo) {
    return '''
Você é um especialista em avaliação de risco cardiovascular e cirúrgico.

TAREFA:
Calcule escores de risco baseado nos dados clínicos fornecidos.

DADOS ANÔNIMOS DO PACIENTE:
${_formatarContexto(contextoAnonimo)}

FORMATO DE RESPOSTA (JSON):
{
  "framingham": {
    "risco10anos": "X%",
    "classificacao": "baixo|moderado|alto|muito_alto",
    "fatoresRisco": ["fator1", "fator2"]
  },
  "asa": {
    "classificacao": "ASA I|II|III|IV|V|VI",
    "justificativa": "..."
  },
  "riscoCircurgico": {
    "classificacao": "baixo|moderado|alto",
    "recomendacoes": ["rec1", "rec2"]
  },
  "alertas": [
    // Alertas importantes
  ]
}

CRITÉRIOS ASA:
- ASA I: Paciente saudável
- ASA II: Doença sistêmica leve
- ASA III: Doença sistêmica grave
- ASA IV: Doença sistêmica grave, ameaça constante à vida
- ASA V: Moribundo, não esperado sobreviver sem cirurgia

REGRAS:
1. Use critérios médicos validados
2. Seja conservador na avaliação
3. Justifique a classificação
4. Inclua recomendações práticas
''';
  }

  /// Prompt para revisão de medicamentos
  static String revisarMedicamentos(Map<String, dynamic> contextoAnonimo) {
    return '''
Você é um farmacêutico clínico especializado em interações medicamentosas.

TAREFA:
Analise os medicamentos em uso e identifique interações, contraindicações e sugestões.

DADOS ANÔNIMOS DO PACIENTE:
${_formatarContexto(contextoAnonimo)}

FORMATO DE RESPOSTA (JSON):
{
  "interacoes": [
    {
      "medicamentos": ["med1", "med2"],
      "severidade": "leve|moderada|grave",
      "descricao": "...",
      "recomendacao": "..."
    }
  ],
  "contraindicacoes": [
    {
      "medicamento": "...",
      "condicao": "...",
      "recomendacao": "..."
    }
  ],
  "ajustesDose": [
    {
      "medicamento": "...",
      "motivo": "...",
      "sugestao": "..."
    }
  ],
  "alertas": [
    // Alertas críticos
  ]
}

REGRAS:
1. Considere idade, peso, função renal/hepática
2. Verifique alergias e contraindicações
3. Indique severidade das interações
4. Sugira alternativas quando apropriado
''';
  }

  /// Prompt para verificação de protocolos
  static String verificarProtocolos(Map<String, dynamic> contextoAnonimo) {
    return '''
Você é um auditor médico especializado em protocolos e diretrizes clínicas.

TAREFA:
Verifique a conformidade com protocolos institucionais e diretrizes clínicas.

DADOS ANÔNIMOS DO PACIENTE:
${_formatarContexto(contextoAnonimo)}

FORMATO DE RESPOSTA (JSON):
{
  "protocolos": [
    {
      "nome": "Nome do protocolo",
      "status": "conforme|nao_conforme|parcial|nao_aplicavel",
      "itensVerificados": [
        {
          "item": "...",
          "status": "ok|pendente|nao_conforme",
          "observacao": "..."
        }
      ]
    }
  ],
  "checklistPreOperatorio": {
    "identificacao": "ok|pendente",
    "consentimento": "ok|pendente",
    "jejum": "ok|pendente",
    "profilaxiaAntibiotica": "ok|pendente|nao_aplicavel",
    "outrosItens": [...]
  },
  "alertas": [
    // Itens críticos pendentes
  ],
  "recomendacoes": [
    // Ações recomendadas
  ]
}

PROTOCOLOS A VERIFICAR:
- Hipertensão arterial (Diretriz Brasileira)
- Diabetes mellitus (SBD)
- Checklist cirúrgico seguro (OMS)
- Profilaxia antibiótica
- Profilaxia TEV

REGRAS:
1. Seja rigoroso na verificação
2. Indique claramente pendências
3. Priorize segurança do paciente
''';
  }

  static String _formatarContexto(Map<String, dynamic> contexto) {
    final buffer = StringBuffer();
    
    contexto.forEach((chave, valor) {
      if (valor != null) {
        buffer.writeln('- $chave: ${_formatarValor(valor)}');
      }
    });
    
    return buffer.toString();
  }

  static String _formatarValor(dynamic valor) {
    if (valor is Map) {
      return '\n  ${valor.entries.map((e) => '${e.key}: ${e.value}').join('\n  ')}';
    } else if (valor is List) {
      return '\n  - ${valor.join('\n  - ')}';
    }
    return valor.toString();
  }
}

