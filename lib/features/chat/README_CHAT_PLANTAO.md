# 💬 Chat do Plantão - SedaniHub

Sistema de chat em tempo real exclusivo para plantonistas do dia. Mensagens temporárias com limpeza automática.

## 📋 Visão Geral

O Chat do Plantão permite comunicação em tempo real entre todos os usuários que estão no plantão do dia.

### Características Principais

✅ **Acesso restrito**: Apenas plantonistas de hoje podem ler e enviar mensagens  
✅ **Tempo real**: Mensagens aparecem instantaneamente via Firestore streams  
✅ **Temporário**: Mensagens são automaticamente removidas após 24 horas  
✅ **Simples**: Apenas texto, sem anexos ou recursos complexos  
✅ **Interface moderna**: Design tipo WhatsApp com bubbles  
✅ **Informações do plantão**: Lista de plantonistas e coordenador  

## 🏗️ Arquitetura

### Modelos (`core/models/chat_mensagem.dart`)
- `ChatMensagem`: Modelo de mensagem do chat
- Campos: id, texto, remetente, data de envio, data do plantão

### Serviço (`core/services/chat_plantao_service.dart`)
- `ChatPlantaoService`: Singleton para gerenciar o chat
- Verificação de acesso (está no plantão?)
- Stream de mensagens em tempo real
- Envio de mensagens
- Limpeza de mensagens antigas
- Informações do plantão (coordenador, plantonistas)

### Providers (`core/providers/chat_plantao_provider.dart`)
- `chatPlantaoServiceProvider`: Acesso ao serviço
- `mensagensPlantaoProvider`: Stream de mensagens do dia
- `usuarioNoPlantaoProvider`: Verifica se usuário está no plantão
- `infoPlantaoHojeProvider`: Informações do plantão de hoje
- `contagemMensagensProvider`: Total de mensagens

### UI (`features/chat/presentation/pages/chat_plantao_page.dart`)
- Interface de chat completa
- Bubbles de mensagem (estilo WhatsApp)
- Campo de input com botão de envio
- Auto-scroll para última mensagem
- Dialog com info do plantão

## 📊 Collection no Firestore

### `/chat_plantao/{mensagemId}`

```javascript
{
  texto: string,              // Conteúdo da mensagem
  remetenteId: string,        // Email do usuário que enviou
  remetenteNome: string,      // Nome do remetente
  dataEnvio: Timestamp,       // Quando foi enviada
  plantaoData: string         // Data do plantão (formato: 'yyyy-MM-dd')
}
```

### Índices Recomendados

```javascript
- plantaoData + dataEnvio
```

### TTL (Time To Live)

Configure no Firestore Console para deletar automaticamente mensagens antigas:

1. Acesse Firestore Console
2. Vá em "Time-to-live"
3. Configure para collection `chat_plantao`
4. Campo: `dataEnvio`
5. Duração: 24 horas

Ou use a função de limpeza manual:

```dart
await ChatPlantaoService().limparMensagensAntigas();
```

## 🔒 Regras de Segurança (Firestore)

```javascript
// Função helper para verificar se usuário está no plantão
function usuarioEstaNoPlantao() {
  let hoje = timestamp.date(request.time);
  let plantoes = firestore.collection('plantoes')
    .where('usuario', '==', /databases/$(database)/documents/usuarios/$(request.auth.token.email))
    .where('data', '>=', hoje)
    .where('data', '<', timestamp.date(request.time + duration.value(1, 'd')))
    .limit(1);
  
  return exists(plantoes);
}

match /chat_plantao/{mensagemId} {
  // Apenas plantonistas podem ler
  allow read: if request.auth != null && usuarioEstaNoPlantao();
  
  // Apenas plantonistas podem criar mensagens
  allow create: if request.auth != null 
    && usuarioEstaNoPlantao()
    && request.resource.data.remetenteId == request.auth.token.email;
  
  // Ninguém pode editar mensagens
  allow update: if false;
  
  // Apenas o sistema pode deletar (limpeza automática)
  allow delete: if false;
}
```

## 🚀 Uso no App

### 1. Acessar o Chat

No Dashboard, clicar no ícone de chat 💬 ao lado do sino de notificações.

### 2. Verificar Acesso

O sistema automaticamente verifica se o usuário está no plantão:

```dart
final estaNoPlantao = await ref.read(usuarioNoPlantaoProvider.future);

if (!estaNoPlantao) {
  // Mostrar mensagem de acesso negado
}
```

### 3. Enviar Mensagem

```dart
final service = ref.read(chatPlantaoServiceProvider);
await service.enviarMensagem('Olá, equipe!');
```

### 4. Monitorar Mensagens

```dart
final mensagensAsync = ref.watch(mensagensPlantaoProvider);

mensagensAsync.when(
  data: (mensagens) => ListView(
    children: mensagens.map((m) => MensagemBubble(m)).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Erro: $e'),
);
```

### 5. Ver Informações do Plantão

Clicar no ícone ℹ️ no AppBar para ver:
- Coordenador do plantão (posição 1)
- Lista de todos os plantonistas
- Turnos de cada um

## 🎨 Interface

### Chat

- **Mensagens próprias**: Bubbles bordô (cor primária), alinhadas à direita
- **Mensagens de outros**: Bubbles cinza, alinhadas à esquerda
- **Avatar**: Inicial do nome em círculo
- **Horário**: Exibido em cada mensagem (HH:mm)
- **Auto-scroll**: Rola automaticamente para última mensagem

### Input

- Campo de texto arredondado
- Botão de envio (ícone de avião)
- Placeholder: "Digite sua mensagem..."
- Submit ao pressionar Enter

### AppBar

- Título: "Chat do Plantão"
- Subtítulo: "X plantonistas hoje"
- Botão voltar
- Botão info (mostra lista de plantonistas)

## 📱 Funcionalidades

### Controle de Acesso

```dart
// Verificação automática ao tentar enviar mensagem
Future<void> enviarMensagem(String texto) async {
  // 1. Verifica se usuário está autenticado
  // 2. Verifica se está no plantão de hoje
  // 3. Se não estiver, lança exceção
  // 4. Se estiver, envia mensagem
}
```

### Limpeza Automática

**Opção 1: TTL do Firestore** (Recomendado)
- Configure no Console do Firestore
- Automático e sem custo extra
- Deletar mensagens com `dataEnvio` > 24h

**Opção 2: Cloud Function Scheduled**
```javascript
exports.limparChatPlantao = functions.pubsub
  .schedule('every 6 hours')
  .onRun(async (context) => {
    const ontem = new Date();
    ontem.setHours(ontem.getHours() - 24);
    
    const snapshot = await admin.firestore()
      .collection('chat_plantao')
      .where('dataEnvio', '<', admin.firestore.Timestamp.fromDate(ontem))
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    console.log(`${snapshot.docs.length} mensagens antigas removidas`);
  });
```

**Opção 3: Manual no App**
```dart
// Executar ao iniciar o app ou periodicamente
await ChatPlantaoService().limparMensagensAntigas();
```

## 🎯 Casos de Uso

### 1. Coordenador Avisar a Equipe

```
Coordenador entra no chat
    ↓
"Pessoal, reunião rápida em 10 minutos na sala 3"
    ↓
Todos os plantonistas recebem em tempo real
```

### 2. Solicitar Ajuda

```
Plantonista: "Alguém pode me auxiliar na sala 5?"
    ↓
Outro plantonista: "Estou indo!"
```

### 3. Informar Situação

```
"RPA com 3 pacientes, sem previsão de alta no momento"
"Sala 2 liberada para próximo procedimento"
"Estou disponível para novas atribuições"
```

## 🔧 Configuração

### 1. Criar Collection no Firestore

Já será criada automaticamente ao enviar a primeira mensagem.

### 2. Configurar Índice

No Firestore Console:
- Collection: `chat_plantao`
- Campos: `plantaoData` (Ascending) + `dataEnvio` (Ascending)

### 3. Configurar Regras de Segurança

Copiar as regras de segurança mostradas acima.

### 4. Configurar TTL (Opcional mas Recomendado)

No Firestore Console:
1. Settings → Time-to-live
2. Collection: `chat_plantao`
3. Timestamp field: `dataEnvio`
4. Expiration: 86400 seconds (24 horas)

## 📈 Melhorias Futuras

1. **Indicador de digitação**: "Fulano está digitando..."
2. **Mensagens não lidas**: Badge com contador
3. **Reações**: Emojis de reação rápida
4. **Menções**: @usuario para mencionar alguém
5. **Anexos**: Fotos/documentos (se necessário)
6. **Busca**: Buscar mensagens antigas
7. **Notificações push**: Avisar quando chegam mensagens
8. **Som**: Alerta sonoro para novas mensagens
9. **Status online**: Ver quem está online
10. **Mensagens fixadas**: Fixar mensagens importantes

## 🐛 Troubleshooting

### Não consigo acessar o chat
- Verificar se você está registrado no plantão de hoje
- Verificar regras de segurança do Firestore
- Ver logs no console

### Mensagens não aparecem
- Verificar índice no Firestore
- Confirmar que a query está correta
- Verificar se há mensagens na collection

### Mensagens antigas não são removidas
- Configurar TTL no Firestore Console
- Ou agendar Cloud Function de limpeza
- Ou executar manualmente `limparMensagensAntigas()`

## 📚 Referências

- [Firestore Real-time Updates](https://firebase.google.com/docs/firestore/query-data/listen)
- [Firestore TTL](https://firebase.google.com/docs/firestore/ttl)
- [Chat UI Best Practices](https://m3.material.io/components/conversation)

