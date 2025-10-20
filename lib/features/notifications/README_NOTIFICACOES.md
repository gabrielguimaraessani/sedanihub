# 🔔 Sistema de Notificações - SedaniHub

Sistema completo de notificações com badges no ícone do app e notificações push.

## 📋 Tipos de Notificações

### 1. Fila de Banheiro
- **Válida até:** Sair da fila, marcar como concluído ou >2h
- **Destinatários:** Todos os usuários
- **Dados:** Nome do solicitante, ID do serviço

```dart
await NotificationsService().criarNotificacaoFilaBanheiro(
  solicitanteNome: 'Dr. João Silva',
  servicoId: 'servico123',
);
```

### 2. Fila de Alimentação
- **Válida até:** Sair da fila, marcar como concluído ou >2h
- **Destinatários:** Todos os usuários
- **Dados:** Nome do solicitante, ID do serviço

```dart
await NotificationsService().criarNotificacaoFilaAlimentacao(
  solicitanteNome: 'Dr. Maria Santos',
  servicoId: 'servico123',
);
```

### 3. Demanda RPA
- **Válida até:** Marcar como concluído ou >2h
- **Destinatários:** Todos os usuários
- **Dados:** Descrição da demanda, ID do serviço

```dart
await NotificationsService().criarNotificacaoDemandaRpa(
  servicoId: 'servico123',
  descricao: 'Paciente necessita cuidados pós-anestésicos',
);
```

### 4. Termo de Consentimento
- **Válida até:** Sair da fila, marcar como concluído ou >4h
- **Destinatários:** Todos os usuários
- **Dados:** Nome do procedimento, ID do serviço

```dart
await NotificationsService().criarNotificacaoTermoConsentimento(
  procedimentoNome: 'Anestesia Geral',
  servicoId: 'servico123',
);
```

### 5. Tarefa Atribuída
- **Válida até:** 1h após o procedimento
- **Destinatários:** Usuário específico ao qual a tarefa foi atribuída
- **Dados:** ID do serviço, horário do procedimento, nome do procedimento
- **Especial:** Envia notificação local imediata

```dart
await NotificationsService().criarNotificacaoTarefaAtribuida(
  usuarioId: 'usuario@sani.med.br',
  servicoId: 'servico123',
  horarioProcedimento: DateTime(2025, 10, 20, 14, 30),
  procedimentoNome: 'Anestesia Geral para Cirurgia',
);
```

### 6. Quiz Educativo
- **Válida até:** Usuário fazer o quiz (sem expiração temporal)
- **Destinatários:** Usuários específicos determinados pelo time de qualidade
- **Dados:** ID do quiz, título do quiz

```dart
await NotificationsService().criarNotificacaoQuizEducativo(
  usuariosIds: ['usuario1@sani.med.br', 'usuario2@sani.med.br'],
  quizId: 'quiz123',
  quizTitulo: 'Quiz: Segurança em Anestesia',
);
```

### 7. Confirmação de Produção
- **Válida até:** 10 dias
- **Destinatários:** Usuário específico
- **Dados:** Mês, ano

```dart
await NotificationsService().criarNotificacaoConfirmacaoProducao(
  usuarioId: 'usuario@sani.med.br',
  mes: 'Outubro',
  ano: 2025,
);
```

## 🏗️ Arquitetura

### Modelos (`core/models/notificacao.dart`)
- `Notificacao`: Modelo principal de notificação
- `TipoNotificacao`: Enum com os 7 tipos
- Classes de dados específicas para cada tipo

### Serviço (`core/services/notifications_service.dart`)
- Singleton para gerenciar todas as notificações
- Integração com Firebase Cloud Firestore
- Integração com `flutter_local_notifications`
- Gerenciamento de badge do app com `flutter_app_badger`

### Providers (`core/providers/notifications_provider.dart`)
- `notificationsServiceProvider`: Acesso ao serviço
- `notificacoesAtivasProvider`: Stream de notificações ativas
- `notificacoesNaoLidasCountProvider`: Contagem de não lidas
- `notificacoesAgrupadasProvider`: Notificações agrupadas por tipo

### UI
- `NotificationsIconButton`: Botão com badge no AppBar
- `NotificationsPage`: Página listando todas as notificações

## 📊 Collection no Firestore

### `/notificacoes/{notificacaoId}`

```javascript
{
  tipo: string,                    // Tipo da notificação
  titulo: string,                  // Título da notificação
  mensagem: string,                // Mensagem descritiva
  usuarioId: string | null,        // null = para todos
  referenciaId: string | null,     // ID relacionado (serviço, quiz, etc)
  dataCriacao: Timestamp,          // Data de criação
  dataExpiracao: Timestamp | null, // null = sem expiração
  lida: boolean,                   // Se foi lida pelo usuário
  ativa: boolean,                  // Se ainda é válida
  dados: map | null                // Dados adicionais específicos do tipo
}
```

### Índices Recomendados
```
- ativa + usuarioId + dataCriacao (desc)
- tipo + ativa + dataCriacao (desc)
- referenciaId + ativa
```

## 🔒 Regras de Segurança (Firestore)

```javascript
match /notificacoes/{notificacaoId} {
  allow read: if request.auth != null 
    && (resource.data.usuarioId == request.auth.token.email 
        || resource.data.usuarioId == null);
  
  allow create: if request.auth != null;
  
  allow update: if request.auth != null 
    && resource.data.usuarioId == request.auth.token.email
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lida']);
  
  allow delete: if false; // Nunca permitir exclusão
}
```

## 🚀 Uso no App

### 1. No Dashboard

O botão de notificações já está integrado no AppBar do Dashboard:

```dart
// Já implementado em dashboard_page.dart
appBar: AppBar(
  actions: [
    const NotificationsIconButton(), // Badge automático
    // outros botões...
  ],
)
```

### 2. Criar Notificação

```dart
final service = ref.read(notificationsServiceProvider);

// Exemplo: ao atribuir tarefa
await service.criarNotificacaoTarefaAtribuida(
  usuarioId: anestesista.email,
  servicoId: servico.id,
  horarioProcedimento: servico.inicio,
  procedimentoNome: procedimento.descricao,
);
```

### 3. Marcar como Lida

```dart
final service = ref.read(notificationsServiceProvider);
await service.marcarComoLida(notificacaoId);
```

### 4. Limpar Notificações de um Serviço

```dart
// Quando serviço é concluído ou cancelado
final service = ref.read(notificationsServiceProvider);
await service.limparNotificacoesServico(servicoId);
```

### 5. Desativar Notificações por Tipo e Referência

```dart
// Desativa notificações específicas (usado pelas filas)
final service = ref.read(notificationsServiceProvider);
await service.desativarNotificacoesPorReferencia(
  referenciaId: servicoId,
  tipo: TipoNotificacao.filaBanheiro, // opcional
);
```

### 6. Monitorar Notificações

```dart
// Usa o provider para monitorar automaticamente
final notificacoesAsync = ref.watch(notificacoesAtivasProvider);

notificacoesAsync.when(
  data: (notificacoes) => Text('${notificacoes.length} notificações'),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Erro: $e'),
);
```

## 🎨 Personalização

### Cores por Tipo

Cada tipo de notificação tem uma cor específica definida em `_NotificacaoTile`:

- Fila de Banheiro: Azul
- Fila de Alimentação: Laranja
- Demanda RPA: Vermelho
- Termo de Consentimento: Roxo
- Tarefa Atribuída: Verde
- Quiz Educativo: Teal
- Confirmação de Produção: Índigo

### Ícones por Tipo

Cada tipo também tem um ícone específico:
- Fila de Banheiro: `Icons.wc`
- Fila de Alimentação: `Icons.restaurant`
- Demanda RPA: `Icons.medical_services`
- Termo de Consentimento: `Icons.description`
- Tarefa Atribuída: `Icons.assignment`
- Quiz Educativo: `Icons.quiz`
- Confirmação de Produção: `Icons.check_circle_outline`

## 📱 Badge no Ícone do App

O badge é atualizado automaticamente sempre que o stream de notificações é atualizado:

- **Android:** Suporta nativamente com `flutter_app_badger`
- **iOS:** Suporta nativamente com `flutter_app_badger`
- **Web:** Não suportado (limitação do navegador)

## 🔧 Configuração Adicional

### Android

Nenhuma configuração adicional necessária. As permissões já estão incluídas no plugin.

### iOS

Adicionar no `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 📈 Próximas Melhorias

1. **Firebase Cloud Messaging (FCM)**: Notificações push mesmo com app fechado
2. **Agrupamento**: Agrupar notificações similares
3. **Actions**: Ações rápidas nas notificações (aprovar, rejeitar, etc)
4. **Som personalizado**: Som diferente por tipo de notificação
5. **Preferências**: Usuário escolher quais notificações receber
6. **Histórico**: Manter histórico de notificações antigas
7. **Analytics**: Rastrear taxa de visualização e interação

## 🐛 Troubleshooting

### Badge não aparece no Android
- Verificar se o launcher suporta badges
- Testar em dispositivo físico (não funciona bem no emulador)

### Notificações não aparecem
- Verificar regras de segurança do Firestore
- Confirmar que o usuário está autenticado
- Verificar logs no console: `flutter logs`

### Badge não zera
- Forçar leitura: `await service.updateBadge(0)`
- Verificar se notificações estão sendo marcadas como lidas

## 📚 Referências

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [flutter_app_badger](https://pub.dev/packages/flutter_app_badger)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

