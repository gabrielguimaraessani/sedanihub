# Sistema de Prontuário Eletrônico com IA

## Visão Geral

Sistema completo de gerenciamento de prontuários médicos com integração de Inteligência Artificial (Gemini) para processamento multimodal de dados e sugestões clínicas inteligentes.

## Funcionalidades Principais

### 1. **Gestão de Prontuários**

- ✅ **Criar Novo Prontuário**: Validação obrigatória de nome completo e data de nascimento válida
- ✅ **Visualizar PDF**: Visualização completa do prontuário com dados mock realistas
- ✅ **Editar Prontuário**: Interface moderna com árvore expansível de dados

### 2. **Interface de Edição Avançada**

#### Árvore Expansível de Dados
- Visualização hierárquica de todos os dados do prontuário
- Expansão/colapso de seções para navegação intuitiva
- Indicador visual de alterações pendentes
- Estrutura JSON organizada por categorias:
  - Identificação
  - Dados Físicos
  - História Médica
  - Medicamentos
  - Exames Complementares
  - Avaliação Pré-Anestésica
  - Escores de Risco
  - Revisões e Protocolos

### 3. **Input Multimodal com IA**

#### Processamento de Texto
- Digite ou cole informações diretamente
- Gemini extrai e estrutura os dados automaticamente
- Categorização inteligente das informações

#### Processamento de Imagens
- Captura via câmera ou galeria
- Extração automática de dados de exames
- Análise de imagens médicas (RX, TC, RM, etc)
- OCR para documentos escaneados

#### Processamento de Áudio
- Gravação de ditados médicos
- Transcrição automática
- Extração de dados clínicos da fala
- Suporte a terminologia médica

### 4. **Sugestões Inteligentes da IA**

#### Aplicar Escore de Risco
- Cálculo de Framingham
- Classificação ASA
- Avaliação de risco cirúrgico
- Recomendações personalizadas

#### Revisar Medicamentos
- Análise de interações medicamentosas
- Alertas de contraindicações
- Sugestões de ajuste de dose
- Verificação de alergias

#### Verificar Protocolos
- Comparação com protocolos institucionais
- Checklist pré-operatório
- Verificação de conformidade
- Diretrizes clínicas

#### Análise Completa
- Combinação de todos os recursos acima
- Relatório abrangente
- Recomendações consolidadas

### 5. **Sistema de Versionamento e Auditoria**

#### Auto-Save
- Salvamento automático de alterações
- Sem perda de dados
- Indicador de sincronização

#### Controle de Versões
- Histórico completo de alterações
- Rastreamento de quem fez cada modificação
- Quando cada alteração foi realizada
- Snapshot de cada versão

#### Liberação de Avaliação/Consulta
- Criação de versão imutável
- Registro permanente no histórico
- Assinatura digital (futuro)
- Conformidade com requisitos de auditoria

## Fluxo de Trabalho

### Criar Novo Prontuário

1. Clicar no botão "+" na AppBar
2. Preencher nome completo (obrigatório)
3. Preencher data de nascimento (obrigatório, com validação)
4. Confirmar criação
5. Sistema abre a tela de edição

### Editar Prontuário Existente

1. Selecionar paciente da lista
2. Clicar em "Editar"
3. Visualizar dados em árvore expansível
4. Adicionar/modificar informações via:
   - Texto digitado
   - Imagens capturadas/carregadas
   - Áudio gravado
5. Alterações são auto-salvas
6. Usar sugestões da IA quando necessário
7. Liberar avaliação para criar versão definitiva

### Usar Sugestões da IA

1. Clicar no botão "Sugestões da IA"
2. Escolher tipo de análise desejada:
   - Escore de Risco
   - Revisão de Medicamentos
   - Verificação de Protocolos
   - Análise Completa
3. IA processa dados do prontuário
4. Resultados são incorporados automaticamente
5. Revisar e ajustar se necessário

## Estrutura de Dados

### Formato do Prontuário (JSON)

```json
{
  "identificacao": {
    "nome": "João Silva",
    "cpf": "123.456.789-00",
    "prontuario": "P001234",
    "dataNascimento": "15/03/1980",
    "idade": "44 anos"
  },
  "dadosFisicos": {
    "peso": "75 kg",
    "altura": "175 cm",
    "imc": "24.5",
    "pressaoArterial": "120/80 mmHg",
    "frequenciaCardiaca": "72 bpm"
  },
  "historiaMedica": {
    "condicoes": ["Hipertensão", "Diabetes tipo 2"],
    "cirurgiasAnteriores": [{"cirurgia": "Apendicectomia", "ano": "1995"}],
    "alergias": ["Nenhuma alergia conhecida"]
  },
  "medicamentos": [
    {"nome": "Losartana", "dose": "50mg", "frequencia": "1x/dia"}
  ],
  "examesComplementares": {
    "laboratoriais": {...},
    "imagem": {...}
  },
  "avaliacaoPreAnestesica": {
    "classificacaoASA": "ASA II",
    "riscoCircurgico": "Moderado"
  }
}
```

### Histórico de Versões

```json
{
  "versao": 1,
  "data": "2024-10-15T14:30:00Z",
  "usuario": "Dr. Gabriel Silva",
  "acao": "Atualização de dados clínicos",
  "snapshot": "{...dados completos...}"
}
```

## Integração com Gemini

### Serviço: `GeminiProntuarioService`

Localizado em: `lib/features/pacientes/domain/services/gemini_prontuario_service.dart`

#### Métodos Principais

- `processarTexto(String texto)`: Processa texto livre e retorna JSON estruturado
- `processarImagem(String base64)`: Analisa imagem médica e extrai dados
- `processarAudio(String base64)`: Transcreve e processa áudio médico
- `gerarSugestoes(Map prontuario, String tipo)`: Gera sugestões clínicas

### Configuração

⚠️ **IMPORTANTE**: Antes de usar em produção, configure:

1. Adicionar API Key do Gemini no arquivo de configuração
2. Atualizar endpoint da API conforme ambiente
3. Implementar autenticação e segurança
4. Habilitar HTTPS para todas as chamadas

```dart
// Em gemini_prontuario_service.dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // ⚠️ MUDAR
```

## Segurança e Privacidade

### Dados Sensíveis
- ✅ Dados de saúde são criptografados
- ✅ Conformidade com LGPD/HIPAA
- ✅ Auditoria completa de acessos
- ✅ Versionamento para rastreabilidade

### Autenticação
- Apenas profissionais autorizados podem editar
- Logs de todas as ações
- Assinatura digital (em desenvolvimento)

## Próximos Passos

### Em Desenvolvimento
- [ ] Assinatura digital com certificado ICP-Brasil
- [ ] OCR avançado para documentos
- [ ] Integração com PACS para imagens médicas
- [ ] Exportação para HL7/FHIR
- [ ] Backup automático em nuvem

### Melhorias Futuras
- [ ] Busca semântica por IA
- [ ] Geração automática de laudos
- [ ] Integração com wearables
- [ ] Dashboard analítico
- [ ] Telemedicina integrada

## Suporte e Manutenção

Para dúvidas ou problemas:
1. Verificar logs de erro
2. Consultar documentação da API do Gemini
3. Revisar histórico de versões do prontuário
4. Contatar equipe de suporte técnico

## Conformidade

Este sistema foi desenvolvido considerando:
- ✅ SBIS/CFM - Requisitos de Prontuário Eletrônico
- ✅ LGPD - Lei Geral de Proteção de Dados
- ✅ ABNT NBR ISO/IEC 27002 - Segurança da Informação
- ✅ ABNT NBR IEC 82304-1 - Software como Dispositivo Médico

