# 🔒 Segurança e Privacidade - Sistema de Prontuário

## ⚠️ CRÍTICO: Proteção de Dados Pessoais

### Princípio Fundamental
**NUNCA enviar dados identificáveis para APIs externas (Gemini, etc)**

### Dados que NUNCA devem ser enviados
- ❌ Nome completo
- ❌ CPF
- ❌ RG
- ❌ CNS (Cartão Nacional de Saúde)
- ❌ Número de prontuário
- ❌ Endereço
- ❌ Telefone
- ❌ Email
- ❌ Data de nascimento (pode identificar)
- ❌ Nome da mãe/pai
- ❌ Qualquer documento de identificação

### Dados que PODEM ser enviados (anonimizados)
- ✅ Idade (sem data de nascimento)
- ✅ Sexo
- ✅ Peso e altura
- ✅ Sinais vitais
- ✅ Histórico médico (sem nomes)
- ✅ Medicamentos em uso
- ✅ Resultados de exames (valores)
- ✅ Observações clínicas

## 🛡️ Implementação de Segurança

### 1. Serviço de Anonimização

```dart
// lib/features/pacientes/domain/services/anonimizacao_service.dart
final anonimizacao = AnonimizacaoService();

// Anonimizar prontuário antes de enviar
final contextoAnonimo = anonimizacao.criarContextoAnonimo(prontuario);

// Verificar se texto contém dados pessoais
if (anonimizacao.contemDadosIdentificaveis(texto)) {
  texto = anonimizacao.sanitizarTexto(texto);
}
```

### 2. Fluxo de Processamento Seguro

```
Dados do Usuário
      ↓
[Anonimização]  ← Remove TODOS os dados identificáveis
      ↓
Contexto Anônimo
      ↓
[Gemini API]  ← Processa apenas dados clínicos
      ↓
Resposta JSON
      ↓
[Validação]
      ↓
Incorporação ao Prontuário
```

### 3. Exemplos de Anonimização

#### ANTES (NÃO SEGURO):
```json
{
  "nome": "João da Silva",
  "cpf": "123.456.789-00",
  "endereco": "Rua das Flores, 123",
  "idade": "44 anos",
  "peso": "75 kg"
}
```

#### DEPOIS (SEGURO):
```json
{
  "idade": "44 anos",
  "peso": "75 kg",
  "altura": "175 cm",
  "historiaMedica": {...}
}
```

## 🔍 Validações Automáticas

### Detecção de Padrões Perigosos

```dart
// CPF
RegExp(r'\b\d{3}\.\d{3}\.\d{3}-\d{2}\b')

// RG
RegExp(r'\b\d{2}\.\d{3}\.\d{3}-\d{1}\b')

// Telefone
RegExp(r'\(\d{2}\)\s*\d{4,5}-\d{4}')

// Email
RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b')

// Endereço
RegExp(r'rua\s+[A-Za-z\s]+,?\s*\d+', caseSensitive: false)
```

### Sanitização Automática

```dart
// Entrada do usuário
"Paciente João Silva, CPF 123.456.789-00, relata dor torácica"

// Após sanitização
"Paciente [NOME REMOVIDO], CPF [CPF REMOVIDO], relata dor torácica"
```

## 📋 Checklist de Segurança

Antes de enviar QUALQUER dado para API externa:

- [ ] Dados foram anonimizados?
- [ ] Contexto foi criado com `criarContextoAnonimo()`?
- [ ] Texto foi validado com `contemDadosIdentificaveis()`?
- [ ] Se necessário, texto foi sanitizado com `sanitizarTexto()`?
- [ ] Resposta da API será validada antes de usar?
- [ ] Logs não expõem dados sensíveis?
- [ ] Erros não retornam dados pessoais?

## 🔐 Boas Práticas de Implementação

### ✅ FAÇA:

```dart
// 1. Sempre anonimize primeiro
final contextoAnonimo = anonimizacao.criarContextoAnonimo(prontuario);

// 2. Use prompts estruturados
final prompt = GeminiPrompts.textoParaJSON(
  textoUsuario: textoSanitizado,
  contextoAnonimo: contextoAnonimo,
);

// 3. Valide resposta
final response = await geminiService.processarTexto(...);
if (response['confianca'] < 0.7) {
  // Revisar manualmente
}
```

### ❌ NÃO FAÇA:

```dart
// ERRADO: Enviar prontuário completo
await geminiAPI.send(prontuario); // ❌

// ERRADO: Enviar nome do paciente
final prompt = "Analise o prontuário de $nomePaciente"; // ❌

// ERRADO: Não validar entrada
await geminiAPI.send(textoUsuario); // ❌
```

## 📊 Monitoramento e Auditoria

### Registros de Segurança

```dart
// Log de chamadas à API (SEM dados sensíveis)
{
  "timestamp": "2024-10-15T14:30:00Z",
  "usuario": "user_id_hash",
  "acao": "processar_texto",
  "sucesso": true,
  "confianca": 0.85,
  "tempoProcessamento": "1.2s"
  // NÃO incluir: dados do paciente, texto enviado, etc
}
```

### Alertas de Segurança

```dart
// Se detectar dados pessoais sendo enviados
if (anonimizacao.contemDadosIdentificaveis(texto)) {
  logger.warning(
    'Tentativa de envio de dados identificáveis bloqueada',
    userId: currentUser.id,
    timestamp: DateTime.now(),
  );
  
  // Notificar administrador
  SecurityAlert.notify(
    level: SecurityLevel.HIGH,
    message: 'Dados pessoais quase enviados para API',
  );
}
```

## 🌐 Conformidade Legal

### LGPD (Lei Geral de Proteção de Dados)
- ✅ Minimização de dados
- ✅ Consentimento informado
- ✅ Transparência no processamento
- ✅ Direito ao esquecimento
- ✅ Portabilidade de dados
- ✅ Auditoria completa

### HIPAA (Health Insurance Portability and Accountability Act)
- ✅ PHI (Protected Health Information) não é transmitida
- ✅ Dados em trânsito criptografados (HTTPS)
- ✅ Logs de acesso e modificações
- ✅ Controle de acesso baseado em função

### CFM/SBIS (Conselho Federal de Medicina)
- ✅ Prontuário eletrônico certificado
- ✅ Assinatura digital (em desenvolvimento)
- ✅ Rastreabilidade total
- ✅ Backup e recuperação

## ⚙️ Configuração em Produção

### Variáveis de Ambiente

```bash
# .env
GEMINI_API_KEY=your_api_key_here
ENABLE_GEMINI=true
GEMINI_TIMEOUT=30000
GEMINI_MAX_RETRIES=3

# Segurança
ENABLE_ANONIMIZACAO=true  # SEMPRE true em produção
LOG_SENSITIVE_DATA=false  # SEMPRE false em produção
ENABLE_SECURITY_ALERTS=true
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /prontuarios/{id} {
      // Logs de acesso à API NÃO devem incluir dados sensíveis
      match /api_logs/{logId} {
        allow write: if !request.resource.data.keys().hasAny([
          'nome', 'cpf', 'rg', 'endereco', 'telefone'
        ]);
      }
    }
  }
}
```

## 🔔 Notificações ao Usuário

### Consentimento Informado

```dart
// Antes de usar IA pela primeira vez
await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Uso de Inteligência Artificial'),
    content: Text('''
Este sistema utiliza IA (Google Gemini) para processar dados clínicos.

IMPORTANTE:
• Apenas dados clínicos são enviados
• Dados pessoais (nome, CPF, etc) NÃO são compartilhados
• A IA é um assistente, não substitui julgamento médico
• Sempre revise as sugestões da IA

Você concorda com o uso da IA nestes termos?
    '''),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Não'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Concordo'),
      ),
    ],
  ),
);
```

## 📝 Documentação para Auditoria

### Relatório de Conformidade

```markdown
# Relatório de Conformidade - Uso de IA

## Dados Processados
- Tipo: Apenas dados clínicos anonimizados
- Anonimização: Automática via AnonimizacaoService
- Validação: Dupla (pré e pós processamento)

## Medidas de Segurança
1. Anonimização automática obrigatória
2. Validação de entrada (detecção de PII)
3. Sanitização de texto
4. Prompts estruturados
5. Validação de resposta
6. Logs sem dados sensíveis
7. Alertas de segurança

## Conformidade
- LGPD: ✅ Conforme
- HIPAA: ✅ Conforme
- CFM: ✅ Conforme
```

## 🚨 Resposta a Incidentes

### Se dados pessoais forem acidentalmente enviados:

1. **Imediato:**
   - Interromper processamento
   - Notificar administrador
   - Registrar incidente

2. **Investigação:**
   - Identificar causa raiz
   - Verificar extensão do vazamento
   - Revisar logs

3. **Mitigação:**
   - Corrigir vulnerabilidade
   - Notificar afetados (se necessário)
   - Atualizar procedimentos

4. **Prevenção:**
   - Adicionar validação extra
   - Treinar equipe
   - Revisar código

---

**LEMBRE-SE:** A privacidade do paciente é SAGRADA. 
Em caso de dúvida, NÃO envie para API externa.

**Versão:** 1.0  
**Data:** 15/10/2024  
**Responsável:** Equipe de Segurança SaniHub

