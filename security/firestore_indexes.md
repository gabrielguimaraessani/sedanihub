# 📊 Índices Compostos do Firestore - SedaniHub

Este documento lista todos os índices compostos necessários para otimizar as queries do app e reduzir downloads desnecessários.

## 🎯 Estratégia de Otimização

1. **Índices específicos** para cada query comum
2. **Filtros restritivos** para baixar apenas dados necessários
3. **Ordenação eficiente** para paginação futura
4. **Cache inteligente** para dados estáticos

## 📋 Índices Necessários

### Collection: `avaliacoesAnestesicas`

#### Índice 1: Por paciente e data
```
pacienteId (Ascending) + dataCriacao (Descending)
```
**Uso**: Buscar avaliações de um paciente específico ordenadas por data

#### Índice 2: Por status e médico
```
status (Ascending) + medicoResponsavelId (Ascending)
```
**Uso**: Buscar rascunhos de um médico específico

---

### Collection: `plantoes`

#### Índice 1: Por data e posição
```
data (Ascending) + posicao (Ascending)
```
**Uso**: Buscar plantão do dia ordenado por posição (coordenador primeiro)

#### Índice 2: Por usuário e data
```
usuario (Ascending) + data (Descending)
```
**Uso**: Buscar histórico de plantões de um usuário

---

### Collection: `servicos`

#### Índice 1: Por data de início e local
```
inicio (Ascending) + local (Ascending)
```
**Uso**: Buscar serviços de um dia específico em um local

#### Índice 2: Por data e status de finalização
```
inicio (Ascending) + finalizado (Ascending)
```
**Uso**: Buscar apenas serviços pendentes de um dia

#### Índice 3: Por paciente e data
```
paciente (Ascending) + inicio (Descending)
```
**Uso**: Buscar serviços de um paciente específico

---

### Collection: `notificacoes`

#### Índice 1: Notificações ativas por usuário
```
ativa (Ascending) + usuarioId (Ascending) + dataCriacao (Descending)
```
**Uso**: Buscar notificações ativas de um usuário ordenadas por data

#### Índice 2: Notificações por tipo
```
tipo (Ascending) + ativa (Ascending) + dataCriacao (Descending)
```
**Uso**: Filtrar notificações por tipo específico

#### Índice 3: Por referência
```
referenciaId (Ascending) + ativa (Ascending)
```
**Uso**: Buscar notificações de um serviço/item específico

---

### Collection: `filas_solicitacoes`

#### Índice 1: Solicitações ativas
```
concluida (Ascending) + dataExpiracao (Ascending) + dataSolicitacao (Ascending)
```
**Uso**: Buscar solicitações ativas ordenadas por expiração

#### Índice 2: Por tipo e status
```
tipo (Ascending) + concluida (Ascending) + dataExpiracao (Ascending) + dataSolicitacao (Ascending)
```
**Uso**: Filtrar filas de banheiro ou alimentação separadamente

#### Índice 3: Histórico por data
```
dataSolicitacao (Descending)
```
**Uso**: Histórico geral de solicitações

#### Índice 4: Histórico por tipo
```
tipo (Ascending) + dataSolicitacao (Descending)
```
**Uso**: Histórico de um tipo específico

---

### Collection: `chat_plantao`

#### Índice 1: Mensagens do dia
```
plantaoData (Ascending) + dataEnvio (Ascending)
```
**Uso**: Buscar mensagens do plantão de hoje ordenadas cronologicamente

---

### Subcollection: `servicos/{servicoId}/anestesistas`

#### Índice 1: Por médico e data
```
medico (Ascending) + inicio (Ascending)
```
**Uso**: Buscar atribuições de um anestesista específico

---

## 🚀 Como Criar os Índices

### Opção 1: Automaticamente (Recomendado)

O Firebase criará índices automaticamente quando você fizer as queries no app. Quando aparecer erro dizendo que falta índice, o erro incluirá um link para criar automaticamente.

### Opção 2: Manualmente no Console

1. Acesse o [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em **Firestore Database** → **Índices**
4. Clique em **Criar índice**
5. Preencha:
   - **Collection ID**: (nome da collection)
   - **Campos**: adicionar cada campo com sua ordenação
   - **Escopo da consulta**: Collection
6. Criar índice

### Opção 3: Via Firebase CLI

```bash
# Criar arquivo firestore.indexes.json
firebase deploy --only firestore:indexes
```

## 📦 Arquivo firestore.indexes.json

Crie este arquivo na raiz do projeto:

```json
{
  "indexes": [
    {
      "collectionGroup": "avaliacoesAnestesicas",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "pacienteId", "order": "ASCENDING" },
        { "fieldPath": "dataCriacao", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "avaliacoesAnestesicas",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "medicoResponsavelId", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "plantoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "data", "order": "ASCENDING" },
        { "fieldPath": "posicao", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "plantoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "usuario", "order": "ASCENDING" },
        { "fieldPath": "data", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "servicos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "inicio", "order": "ASCENDING" },
        { "fieldPath": "local", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "servicos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "inicio", "order": "ASCENDING" },
        { "fieldPath": "finalizado", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "servicos",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "paciente", "order": "ASCENDING" },
        { "fieldPath": "inicio", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notificacoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ativa", "order": "ASCENDING" },
        { "fieldPath": "usuarioId", "order": "ASCENDING" },
        { "fieldPath": "dataCriacao", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notificacoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tipo", "order": "ASCENDING" },
        { "fieldPath": "ativa", "order": "ASCENDING" },
        { "fieldPath": "dataCriacao", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "notificacoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "referenciaId", "order": "ASCENDING" },
        { "fieldPath": "ativa", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "filas_solicitacoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "concluida", "order": "ASCENDING" },
        { "fieldPath": "dataExpiracao", "order": "ASCENDING" },
        { "fieldPath": "dataSolicitacao", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "filas_solicitacoes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "tipo", "order": "ASCENDING" },
        { "fieldPath": "concluida", "order": "ASCENDING" },
        { "fieldPath": "dataExpiracao", "order": "ASCENDING" },
        { "fieldPath": "dataSolicitacao", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "chat_plantao",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "plantaoData", "order": "ASCENDING" },
        { "fieldPath": "dataEnvio", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## 🔍 Queries Otimizadas

### Exemplo 1: Buscar apenas serviços de hoje
```dart
// ✅ BOM: Filtro específico por data
final hoje = DateTime.now();
final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
final fimHoje = inicioHoje.add(Duration(days: 1));

firestore
  .collection('servicos')
  .where('inicio', isGreaterThanOrEqualTo: inicioHoje)
  .where('inicio', isLessThan: fimHoje)
  .where('finalizado', isEqualTo: false)
  .get();

// ❌ RUIM: Busca tudo e filtra no cliente
firestore.collection('servicos').get();
```

### Exemplo 2: Buscar notificações ativas do usuário
```dart
// ✅ BOM: Filtros específicos
firestore
  .collection('notificacoes')
  .where('ativa', isEqualTo: true)
  .where('usuarioId', whereIn: [userEmail, null])
  .orderBy('dataCriacao', descending: true)
  .limit(50) // Limitar quantidade
  .get();
```

### Exemplo 3: Buscar chat do plantão de hoje
```dart
// ✅ BOM: Apenas mensagens de hoje
final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

firestore
  .collection('chat_plantao')
  .where('plantaoData', isEqualTo: hoje)
  .orderBy('dataEnvio')
  .get();

// ❌ RUIM: Busca todas as mensagens
firestore.collection('chat_plantao').get();
```

## 💾 Persistência de Cache

Ver arquivo `CONFIGURACAO_CACHE.md` para detalhes sobre configuração de cache offline.

## 🎯 Prioridades de Implementação

### Alta Prioridade (Implementar Agora)
1. ✅ Índice de notificações ativas por usuário
2. ✅ Índice de filas ativas
3. ✅ Índice de chat do plantão por data
4. ✅ Índice de serviços por data e status

### Média Prioridade (Implementar em 1 Semana)
1. Índices de avaliações por paciente
2. Índices de plantões por usuário
3. Índices de histórico

### Baixa Prioridade (Implementar Conforme Necessário)
1. Índices de catálogos (poucos dados, cache longo)
2. Índices de subcoleções raramente acessadas

## 📚 Referências

- [Firestore Query Optimization](https://firebase.google.com/docs/firestore/best-practices)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Composite Indexes](https://firebase.google.com/docs/firestore/query-data/index-overview#composite_indexes)

