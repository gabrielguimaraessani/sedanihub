# 💬 Chat Multimodal com IA Assistente

## 🎯 Visão Geral

Sistema de chat avançado com suporte a múltiplos tipos de entrada (texto, imagem, áudio) e integração segura com IA, garantindo privacidade e anonimização de dados.

## ✨ Funcionalidades

### 1. **Input Multimodal**
- ✅ **Texto**: Mensagens de texto livre
- ✅ **Imagens**: Captura via câmera ou galeria (em desenvolvimento)
- ✅ **Áudio**: Gravação de ditados médicos (em desenvolvimento)

### 2. **Segurança e Privacidade** 🔒
- ✅ Detecção automática de dados pessoais (CPF, RG, telefone, etc)
- ✅ Sanitização automática de mensagens
- ✅ Alerta visual quando dados sensíveis são removidos
- ✅ Anonimização obrigatória antes de enviar à IA
- ✅ Conformidade com LGPD/HIPAA

### 3. **Dois Tipos de IA**

#### Google Gemini
- Modelo de linguagem geral
- Consultas sobre medicina
- Explicações de procedimentos
- Suporte educacional
- Análise de textos médicos

#### Vertex AI (Corporativo)
- Acesso a protocolos institucionais
- Conhecimento específico da organização
- Procedimentos personalizados
- Diretrizes corporativas
- Dados da empresa

### 4. **Interface Inteligente**
- ✅ Mensagens em formato de chat (bolhas)
- ✅ Indicador de confiança da resposta
- ✅ Alertas clínicos destacados
- ✅ Timestamp relativo
- ✅ Loading state durante processamento
- ✅ Scroll automático para última mensagem
- ✅ Opção de limpar conversa

## 🔐 Fluxo de Segurança

```
Entrada do Usuário
       ↓
[1. Detectar Dados Pessoais]
       ↓ (se encontrados)
[2. Sanitizar Automaticamente]
       ↓
[3. Mostrar Alerta ao Usuário]
       ↓
[4. Adicionar à Conversa]
       ↓
[5. Processar com IA]
       ↓
[6. Exibir Resposta]
```

## 📝 Exemplos de Uso

### Pergunta sobre Protocolos
```
Usuário: "Qual o protocolo de jejum pré-operatório?"

IA: "Com base nos protocolos institucionais:
• Sólidos: 6-8 horas
• Líquidos claros: 2 horas
• Leite materno: 4 horas
• Leite não materno: 6 horas

Exceções aplicam-se em emergências."

[Confiança: 95%]
```

### Classificação ASA
```
Usuário: "Explique a classificação ASA"

IA: "A classificação ASA avalia estado físico:
• ASA I: Paciente saudável
• ASA II: Doença sistêmica leve
• ASA III: Doença sistêmica grave
• ASA IV: Ameaça constante à vida
• ASA V: Moribundo
• ASA VI: Morte cerebral

Adicione 'E' se emergência."

[Confiança: 98%]
```

### Com Alerta de Segurança
```
Usuário: "O paciente João Silva, CPF 123.456.789-00..."

[⚠️ Alerta] Dados pessoais detectados e removidos

Usuário: "O paciente [NOME REMOVIDO], CPF [CPF REMOVIDO]..."

IA: "Recebi a informação clínica. Como posso ajudar?"
```

## 🎨 Componentes Visuais

### Mensagem do Usuário
```
┌─────────────────────────────────┐
│                  [👤] João       │
│  ┌──────────────────────────┐   │
│  │ Qual o protocolo de      │   │
│  │ jejum pré-operatório?    │   │
│  │                          │   │
│  │ Agora                    │   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

### Mensagem da IA
```
┌─────────────────────────────────┐
│ [🤖] Gemini                      │
│  ┌──────────────────────────┐   │
│  │ Com base nos protocolos: │   │
│  │ • Sólidos: 6-8h          │   │
│  │ • Líquidos: 2h           │   │
│  │                          │   │
│  │ ⚠️ Alertas:              │   │
│  │ • Verificar exceções     │   │
│  │                          │   │
│  │ 2m ✓ 95%                 │   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

### Indicador de Processamento
```
┌─────────────────────────────────┐
│ ⏳ IA está processando...        │
└─────────────────────────────────┘
```

## 🛠️ Uso no Código

### Exemplo Básico
```dart
import 'package:sanihub/features/ai/presentation/widgets/ai_chat_multimodal_widget.dart';

class MinhaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IA Assistente')),
      body: AiChatMultimodalWidget(
        aiType: AiType.gemini,
        permitirAnexos: true,
      ),
    );
  }
}
```

### Com Contexto Inicial
```dart
AiChatMultimodalWidget(
  aiType: AiType.vertexAi,
  permitirAnexos: true,
  contextoInicial: {
    'instituicao': 'Hospital XYZ',
    'especialidade': 'Anestesiologia',
    'protocolosAtivos': ['jejum', 'profilaxia'],
  },
)
```

### Sem Anexos (Apenas Texto)
```dart
AiChatMultimodalWidget(
  aiType: AiType.gemini,
  permitirAnexos: false, // Remove botões de imagem/áudio
)
```

## 🔧 Configuração

### 1. Importar Dependências
```dart
import '../widgets/ai_chat_multimodal_widget.dart';
import '../../../pacientes/domain/services/anonimizacao_service.dart';
```

### 2. Adicionar à Página
```dart
Expanded(
  child: AiChatMultimodalWidget(
    aiType: _selectedAI,
    permitirAnexos: true,
  ),
)
```

## 📱 Ações Disponíveis

### Barra de Ferramentas
- 🖼️ **Adicionar Imagem**: Captura ou seleciona foto
- 🎤 **Gravar Áudio**: Grava ditado médico
- 🗑️ **Limpar**: Remove toda a conversa

### Campo de Entrada
- ⌨️ Digite mensagem
- ↵ Enter ou botão enviar
- 🔒 Sanitização automática

## ⚠️ Alertas de Segurança

### Quando Detectado Dados Pessoais
```
┌─────────────────────────────────────────┐
│ 🛡️ Dados pessoais detectados e         │
│    removidos por segurança              │
│                          [Entendi]      │
└─────────────────────────────────────────┘
```

### Alerta ao Enviar Imagem
```
⚠️ IMPORTANTE: Certifique-se de que a imagem 
não contém dados pessoais identificáveis 
(nome, CPF, etc).
```

## 📊 Indicadores de Qualidade

### Confiança da Resposta
- **Alta (90-100%)**: ✓ Verde
- **Média (70-89%)**: ✓ Amarelo  
- **Baixa (<70%)**: ✓ Laranja

Exibido como: `✓ 95%`

### Alertas Clínicos
```
⚠️ Alertas:
• Valor crítico detectado
• Requer atenção médica
```

## 🎯 Casos de Uso

### 1. Consulta Rápida
**Médico:** "Qual a dose de propofol para indução?"
**IA:** "Dose usual: 1.5-2.5 mg/kg IV. Ajustar conforme idade e condição."

### 2. Verificação de Protocolo
**Médico:** "Protocolo de profilaxia antibiótica"
**IA:** "Cefazolina 2g IV 30-60min antes da incisão..."

### 3. Cálculo de Risco
**Médico:** "Como calcular o escore de Framingham?"
**IA:** "Considera: idade, sexo, CT, HDL, PA, diabetes, tabagismo..."

### 4. Suporte Educacional
**Residente:** "Diferença entre raquianestesia e peridural?"
**IA:** "Raqui: espaço subaracnóideo, início rápido. Peri: espaço peridural..."

## 📈 Melhorias Futuras

### Em Desenvolvimento
- [ ] Upload real de imagens
- [ ] Gravação de áudio
- [ ] Transcrição speech-to-text
- [ ] OCR para documentos
- [ ] Histórico de conversas salvo
- [ ] Exportar conversa como PDF
- [ ] Compartilhar com colegas
- [ ] Favoritar mensagens importantes

### Planejado
- [ ] Sugestões contextuais
- [ ] Auto-complete de perguntas comuns
- [ ] Busca no histórico
- [ ] Temas personalizáveis
- [ ] Modo offline com cache
- [ ] Integração com prontuário
- [ ] Citações de guidelines
- [ ] Links para protocolos

## 🔗 Integrações

### Com Prontuário
```dart
// Passar contexto do paciente (anonimizado)
AiChatMultimodalWidget(
  aiType: AiType.gemini,
  contextoInicial: anonimizacao.criarContextoAnonimo(prontuario),
)
```

### Com Protocolos Institucionais (Vertex AI)
```dart
AiChatMultimodalWidget(
  aiType: AiType.vertexAi, // Usa RAG com protocolos
  permitirAnexos: true,
)
```

## 🧪 Testes

### Teste de Segurança
```dart
test('Deve sanitizar CPF da mensagem', () {
  final service = AnonimizacaoService();
  final texto = "Paciente CPF 123.456.789-00";
  final resultado = service.sanitizarTexto(texto);
  
  expect(resultado, contains('[CPF REMOVIDO]'));
  expect(resultado, isNot(contains('123.456.789-00')));
});
```

### Teste de Chat
```dart
testWidgets('Deve enviar mensagem ao clicar no botão', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AiChatMultimodalWidget(aiType: AiType.gemini),
    ),
  );
  
  // Digitar mensagem
  await tester.enterText(find.byType(TextField), 'Olá');
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();
  
  // Verificar mensagem exibida
  expect(find.text('Olá'), findsOneWidget);
});
```

## 📝 Notas de Implementação

### Estrutura de Dados
```dart
class ChatMessage {
  String id;              // UUID
  String content;         // Conteúdo da mensagem
  bool isUser;           // true = usuário, false = IA
  DateTime timestamp;    // Quando foi enviada
  MessageType type;      // text, image, audio
  String? imageUrl;      // URL da imagem (se aplicável)
  double? confianca;     // 0.0 a 1.0
  List<String>? alertas; // Alertas clínicos
}
```

### Estados do Widget
```dart
_messages: List<ChatMessage>     // Histórico de mensagens
_isProcessing: bool             // IA processando?
_messageController: TextEditingController
_scrollController: ScrollController
_anonimizacao: AnonimizacaoService
```

---

**Versão:** 1.0  
**Data:** 15/10/2024  
**Status:** ✅ Implementado com segurança integrada

