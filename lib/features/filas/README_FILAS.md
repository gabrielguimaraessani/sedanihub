# 🚽🍽️ Sistema de Filas de Atendimento - SedaniHub

Sistema completo para gerenciar filas de banheiro e alimentação com registro histórico no Firebase e visibilidade para todos os usuários.

## 📋 Visão Geral

O sistema permite que qualquer usuário:
- **Crie solicitações** de fila de banheiro ou alimentação
- **Visualize todas as solicitações ativas** em tempo real
- **Marque solicitações como concluídas** independente de quem criou
- **Acompanhe o histórico** de todas as solicitações

### Características Principais

✅ Registro permanente no Firebase (histórico completo)  
✅ Visível para todos os usuários autenticados  
✅ Qualquer um pode concluir solicitações  
✅ Notificações automáticas ao criar solicitação  
✅ Expiração automática após 2 horas  
✅ Indicadores visuais de urgência  
✅ Interface responsiva com tabs

## 🏗️ Arquitetura

### Modelos (`core/models/fila_solicitacao.dart`)
- `FilaSolicitacao`: Modelo principal da solicitação
- `TipoFila`: Enum com tipos (banheiro, alimentação)
- Campos de rastreabilidade completa (quem criou, quando, quem concluiu)

### Serviço (`core/services/filas_service.dart`)
- `FilasService`: Singleton para gerenciar todas as operações
- Integração com Firestore
- Integração com `NotificationsService`
- Métodos para CRUD completo

### Providers (`core/providers/filas_provider.dart`)
- `solicitacoesAtivasProvider`: Stream de todas as solicitações ativas
- `solicitacoesBanheiroProvider`: Stream filtrado por banheiro
- `solicitacoesAlimentacaoProvider`: Stream filtrado por alimentação
- `totalSolicitacoesAtivasProvider`: Contagem total
- `contagemPorTipoProvider`: Contagem agrupada por tipo
- `solicitacoesCriticasProvider`: Solicitações com <30 min restantes

### UI
- `FilasPage`: Página principal com tabs
- `FilaSolicitacaoCard`: Card individual de solicitação
- `CriarSolicitacaoDialog`: Diálogo para nova solicitação

## 📊 Collection no Firestore

### `/filas_solicitacoes/{solicitacaoId}`

```javascript
{
  tipo: "banheiro" | "alimentacao",
  servicoId: string,              // ID do serviço relacionado
  pacienteNome: string,           // Nome do paciente
  pacienteId: string | null,      // ID do paciente (opcional)
  solicitadoPor: string,          // Email de quem solicitou
  solicitadoPorNome: string,      // Nome de quem solicitou
  dataSolicitacao: Timestamp,     // Quando foi solicitado
  dataConclusao: Timestamp | null, // Quando foi concluído
  concluida: boolean,             // Se está concluída
  concluidaPor: string | null,    // Email de quem concluiu
  concluidaPorNome: string | null, // Nome de quem concluiu
  observacoes: string | null,     // Observações adicionais
  dataExpiracao: Timestamp        // Expira 2h após solicitação
}
```

### Índices Recomendados

```javascript
// Solicitações ativas
- concluida + dataExpiracao + dataSolicitacao

// Por tipo
- tipo + concluida + dataExpiracao + dataSolicitacao

// Histórico
- dataSolicitacao (desc)
- tipo + dataSolicitacao (desc)

// Solicitado por usuário
- solicitadoPor + dataSolicitacao (desc)
```

## 🔒 Regras de Segurança (Firestore)

```javascript
match /filas_solicitacoes/{solicitacaoId} {
  // Todos podem ler
  allow read: if request.auth != null;
  
  // Todos podem criar
  allow create: if request.auth != null 
    && request.resource.data.solicitadoPor == request.auth.token.email
    && request.resource.data.concluida == false;
  
  // Todos podem marcar como concluída
  allow update: if request.auth != null 
    && (
      // Marcar como concluída
      (request.resource.data.concluida == true 
        && resource.data.concluida == false
        && request.resource.data.concluidaPor == request.auth.token.email)
      ||
      // Ou apenas quem criou pode editar (antes de concluir)
      (resource.data.solicitadoPor == request.auth.token.email
        && resource.data.concluida == false)
    );
  
  // Ninguém pode deletar
  allow delete: if false;
}
```

## 🚀 Uso no App

### 1. Criar Solicitação

```dart
final service = ref.read(filasServiceProvider);

await service.criarSolicitacao(
  tipo: TipoFila.banheiro,
  servicoId: 'servico123',
  pacienteNome: 'João Silva',
  pacienteId: 'paciente123', // opcional
  observacoes: 'Urgente', // opcional
);
```

### 2. Marcar como Concluída

```dart
final service = ref.read(filasServiceProvider);

await service.marcarComoConcluida(
  'solicitacaoId',
  observacoes: 'Concluído com sucesso', // opcional
);
```

### 3. Monitorar Solicitações Ativas

```dart
// Todas as solicitações
final solicitacoesAsync = ref.watch(solicitacoesAtivasProvider);

// Apenas banheiro
final banheiroAsync = ref.watch(solicitacoesBanheiroProvider);

// Apenas alimentação
final alimentacaoAsync = ref.watch(solicitacoesAlimentacaoProvider);

solicitacoesAsync.when(
  data: (solicitacoes) => ListView(
    children: solicitacoes.map((s) => 
      FilaSolicitacaoCard(solicitacao: s)
    ).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Erro: $e'),
);
```

### 4. Ver Contagem

```dart
final contagem = ref.watch(contagemPorTipoProvider);
final totalBanheiro = contagem[TipoFila.banheiro] ?? 0;
final totalAlimentacao = contagem[TipoFila.alimentacao] ?? 0;
```

## 🎨 Indicadores de Urgência

As solicitações são categorizadas por urgência baseado no tempo restante:

| Urgência | Tempo Restante | Cor |
|----------|----------------|-----|
| 🚨 Crítica | < 30 min | Vermelho |
| ⚠️ Urgente | 30-60 min | Laranja |
| ⏰ Atenção | 60-90 min | Amarelo |
| ✅ Normal | > 90 min | Verde |

## 📱 Interface do Usuário

### Página de Filas

A página principal possui 3 tabs:

1. **Todas**: Lista todas as solicitações ativas
2. **Banheiro** 🚽: Apenas solicitações de banheiro
3. **Alimentação** 🍽️: Apenas solicitações de alimentação

Cada tab agrupa as solicitações por urgência e exibe:
- Emoji indicador de urgência
- Contador de solicitações por categoria
- Cards ordenados por tempo de expiração

### Card de Solicitação

Cada card exibe:
- Tipo (ícone e nome)
- Tempo solicitado
- Tempo restante até expiração
- Nome do paciente
- Quem solicitou
- Observações (se houver)
- Botão "Marcar como Concluída"

### Criar Nova Solicitação

Diálogo com:
- Seleção do tipo (banheiro/alimentação)
- Nome do paciente (obrigatório)
- ID do serviço (obrigatório)
- Observações (opcional)
- Info sobre expiração em 2h

## 🔔 Integração com Notificações

### Ao Criar Solicitação

O sistema **automaticamente**:

1. ✅ Salva no Firestore em `/filas_solicitacoes`
2. ✅ Cria notificação para todos os usuários
3. ✅ Define expiração em 2h (mesma regra da fila)

### Ao Concluir Solicitação

O sistema **automaticamente**:

1. ✅ Marca solicitação como concluída no Firestore
2. ✅ **Desativa todas as notificações relacionadas** (via `desativarNotificacoesPorReferencia`)
3. ✅ Remove do badge de notificações
4. ✅ Remove da lista de notificações ativas

### Validade da Notificação

A notificação é válida até:
- ✅ **Sair da fila** (cancelar ou remover)
- ✅ **Marcada como concluída** (desativa automaticamente)
- ✅ **Tempo >2h** (expiração automática)

### Tipos de Notificação

- **Fila de Banheiro**: `TipoNotificacao.filaBanheiro`
- **Fila de Alimentação**: `TipoNotificacao.filaAlimentacao`

### Onde Aparecem

As notificações aparecem:
- No ícone de notificações do AppBar (com badge)
- Na página de notificações
- Como notificação local (se habilitado)
- **Somem automaticamente quando concluída** ✅

## 📈 Estatísticas

### Buscar Estatísticas de um Período

```dart
final service = ref.read(filasServiceProvider);

final stats = await service.getEstatisticas(
  dataInicio: DateTime(2025, 10, 1),
  dataFim: DateTime(2025, 10, 31),
);

print('Total de banheiro: ${stats['totalBanheiro']}');
print('Total de alimentação: ${stats['totalAlimentacao']}');
print('Total concluídas: ${stats['totalConcluidas']}');
print('Total expiradas: ${stats['totalExpiradas']}');
```

## 🧹 Manutenção

### Limpar Solicitações Expiradas

Job automático para marcar solicitações expiradas como concluídas:

```dart
final service = ref.read(filasServiceProvider);
await service.limparSolicitacoesExpiradas();
```

**Recomendação**: Agendar este job para rodar a cada hora usando:
- Cloud Functions (Firebase)
- Scheduled task no backend
- Cron job

Exemplo com Cloud Functions:

```javascript
exports.limparFilasExpiradas = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    const snapshot = await admin.firestore()
      .collection('filas_solicitacoes')
      .where('concluida', '==', false)
      .where('dataExpiracao', '<', now)
      .get();
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        concluida: true,
        dataConclusao: now,
        concluidaPor: 'system',
        concluidaPorNome: 'Sistema (Expirado)',
        observacoes: 'Solicitação expirada automaticamente após 2 horas'
      });
    });
    
    await batch.commit();
    console.log(`${snapshot.docs.length} solicitações expiradas foram limpas`);
  });
```

## 🎯 Fluxo Completo

### 1. Criar Solicitação
```
Usuário → Clicar "Nova Solicitação" → Preencher form → Criar
    ↓
Firebase cria documento em /filas_solicitacoes
    ↓
NotificationsService cria notificação
    ↓
Todos os usuários veem nova solicitação em tempo real
    ↓
Badge de notificações é atualizado
```

### 2. Visualizar Filas
```
Usuário → Abrir "Filas de Atendimento"
    ↓
Sistema carrega solicitações ativas via Stream
    ↓
Agrupa por urgência (crítica, urgente, atenção, normal)
    ↓
Exibe em tabs (Todas, Banheiro, Alimentação)
```

### 3. Concluir Solicitação
```
Qualquer Usuário → Clicar "Marcar como Concluída"
    ↓
Sistema busca a solicitação do Firestore
    ↓
Atualiza documento com dados de conclusão
    ↓
Desativa TODAS as notificações do tipo correspondente e servicoId
    ↓
Solicitação desaparece da lista de ativas
    ↓
Notificações desaparecem automaticamente
    ↓
Badge é atualizado
    ↓
Histórico preservado com quem concluiu e quando
```

### 4. Expiração Automática
```
Após 2 horas sem conclusão
    ↓
Job de manutenção (ou filtro de query) marca como expirada
    ↓
Solicitação sai da lista de ativas
    ↓
Notificação expira automaticamente
```

## 🐛 Troubleshooting

### Solicitações não aparecem
- Verificar regras de segurança do Firestore
- Confirmar que usuário está autenticado
- Verificar se há índices criados

### Notificações não são criadas
- Verificar logs no console
- Confirmar integração entre `FilasService` e `NotificationsService`
- Verificar collection `/notificacoes` no Firestore

### Tempo restante incorreto
- Verificar timezone do dispositivo
- Confirmar que `dataExpiracao` está sendo salva corretamente
- Verificar se o servidor tem timestamp correto

### Performance com muitas solicitações
- Implementar paginação no histórico
- Criar índices compostos otimizados
- Considerar limpar histórico antigo periodicamente (>90 dias)

## 🔄 Próximas Melhorias

1. **Priorização**: Campo de prioridade (baixa, normal, alta, crítica)
2. **Atribuição**: Permitir atribuir responsável específico
3. **Chat**: Comentários/chat por solicitação
4. **Analytics**: Dashboard com métricas e gráficos
5. **Exportação**: Exportar relatórios em Excel/PDF
6. **Filtros Avançados**: Filtrar por data, usuário, status
7. **Notificações Push**: Avisos mesmo com app fechado
8. **Sons**: Alerta sonoro para solicitações críticas
9. **Geolocalização**: Indicar local/sala do paciente
10. **Templates**: Templates de observações rápidas

## 📚 Referências

- [Firestore Queries](https://firebase.google.com/docs/firestore/query-data/queries)
- [Riverpod State Management](https://riverpod.dev/)
- [Material Design - Cards](https://m3.material.io/components/cards)

