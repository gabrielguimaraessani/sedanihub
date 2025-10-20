# 🔥 Guia de Configuração do Firebase - SedaniHub

Guia completo e otimizado para configurar o Firebase com foco em **segurança**, **performance** e **conformidade LGPD**.

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Regras de Segurança](#regras-de-segurança)
4. [Índices Compostos](#índices-compostos)
5. [Configuração de Cache](#configuração-de-cache)
6. [TTL (Time-to-Live)](#ttl-time-to-live)
7. [Deploy](#deploy)
8. [Verificação](#verificação)

---

## 1. Pré-requisitos

✅ Conta Google/Firebase  
✅ Projeto Firebase criado  
✅ Flutter instalado  
✅ Firebase CLI instalada (`npm install -g firebase-tools`)  
✅ Login no Firebase (`firebase login`)

---

## 2. Configuração Inicial

### 2.1. Criar Projeto Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em **"Adicionar projeto"**
3. Nome: **SedaniHub** (ou seu nome preferido)
4. Desabilitar Google Analytics (opcional para app corporativo)
5. Criar projeto

### 2.2. Habilitar Serviços

No Console do Firebase:

**Authentication:**
1. Ir em **Authentication** → **Sign-in method**
2. Habilitar **Email/Password**
3. Configurar domínio autorizado: `sani.med.br`

**Firestore Database:**
1. Ir em **Firestore Database**
2. **Criar banco de dados**
3. Modo: **Produção** (regras personalizadas)
4. Localização: **southamerica-east1** (São Paulo)

**Storage:**
1. Ir em **Storage**
2. **Começar**
3. Modo: **Produção**
4. Mesma localização do Firestore

**Cloud Messaging (Opcional):**
1. Ir em **Cloud Messaging**
2. Seguir wizard de configuração

### 2.3. Configurar App Flutter

```bash
cd D:\flutter\sanihub

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase no projeto
flutterfire configure
```

Selecionar:
- Projeto: SedaniHub
- Plataformas: Android, iOS, Web
- Sobrescrever `lib/firebase_options.dart`

---

## 3. Regras de Segurança

### 3.1. Deploy das Regras

As regras já estão em `security/firestore.rules`. Para aplicá-las:

```bash
cd D:\flutter\sanihub
firebase deploy --only firestore:rules
```

### 3.2. Verificar Regras

No Firebase Console:
1. **Firestore Database** → **Regras**
2. Verificar se as regras foram aplicadas
3. Clicar em **Publicar** se necessário

### 3.3. Principais Regras Implementadas

✅ **Gate Corporativo**: Apenas emails `@sani.med.br` e `@sedanimed.br`  
✅ **Pacientes**: Apenas médicos e admins  
✅ **Notificações**: Apenas destinatário pode ler  
✅ **Chat**: Apenas plantonistas do dia  
✅ **Filas**: Todos podem ler e concluir  
✅ **Avaliações**: Imutáveis após assinatura  

---

## 4. Índices Compostos

### 4.1. Criação Automática (Recomendado)

Execute o app e use as funcionalidades. Quando uma query precisar de índice, você verá um erro com um **link clicável** para criar o índice automaticamente.

Exemplo:
```
The query requires an index. You can create it here:
https://console.firebase.google.com/project/sedanihub/firestore/indexes?create_composite=...
```

Clique no link e o Firebase criará o índice automaticamente.

### 4.2. Índices Prioritários para Criar Manualmente

No Firebase Console → **Firestore Database** → **Índices** → **Criar índice**

#### Índice 1: Notificações Ativas
- **Collection ID**: `notificacoes`
- **Campos**:
  1. `ativa` - Ascending
  2. `usuarioId` - Ascending
  3. `dataCriacao` - Descending

#### Índice 2: Filas Ativas
- **Collection ID**: `filas_solicitacoes`
- **Campos**:
  1. `concluida` - Ascending
  2. `dataExpiracao` - Ascending
  3. `dataSolicitacao` - Ascending

#### Índice 3: Chat do Dia
- **Collection ID**: `chat_plantao`
- **Campos**:
  1. `plantaoData` - Ascending
  2. `dataEnvio` - Ascending

#### Índice 4: Serviços do Dia
- **Collection ID**: `servicos`
- **Campos**:
  1. `inicio` - Ascending
  2. `finalizado` - Ascending

### 4.3. Ver Índices Criados

```bash
firebase firestore:indexes
```

Lista completa de índices recomendados em: `security/firestore_indexes.md`

---

## 5. Configuração de Cache

### 5.1. Já Implementado no Código ✅

A configuração de cache está em:
- `lib/core/config/firestore_config.dart`
- Inicializado automaticamente em `lib/main.dart`

### 5.2. Estratégia de Cache

| Tipo de Dado | Estratégia | Persistência |
|--------------|-----------|--------------|
| **Pacientes** | `Source.server` | ❌ Não cachear |
| **Catálogos** | `Source.cache` | ✅ Cache longo |
| **Serviços** | `Source.serverAndCache` | 🟡 24h |
| **Notificações** | `snapshots()` | ❌ Tempo real |
| **Chat** | `snapshots()` | ❌ Tempo real |
| **Filas** | `snapshots()` | ❌ Tempo real |

### 5.3. Limpeza Automática

✅ **Ao Logout**: Cache é completamente limpo (LGPD)  
✅ **Mensagens do Chat**: TTL de 24 horas  
✅ **Filas**: Expiração automática em 2 horas  

---

## 6. TTL (Time-to-Live)

### 6.1. Configurar TTL para Chat

No Firebase Console:

1. **Firestore Database** → **⚙️ Configurações**
2. **Time-to-live** → **Criar política**
3. Preencher:
   - **Nome da política**: Chat Plantão Cleanup
   - **Collection**: `chat_plantao`
   - **Timestamp field**: `dataEnvio`
   - **Expiration**: `86400` segundos (24 horas)
4. **Criar**

### 6.2. Verificar TTL

```bash
# Ver políticas de TTL ativas
firebase firestore:ttl:list
```

### 6.3. TTL Configurado

✅ `chat_plantao`: Mensagens deletadas após 24h  
⏳ `filas_solicitacoes`: Gerenciado via lógica de app (não TTL)  
⏳ `notificacoes`: Gerenciado via campo `ativa`  

---

## 7. Deploy

### 7.1. Deploy Completo

```bash
cd D:\flutter\sanihub

# Deploy de regras e índices
firebase deploy --only firestore
```

### 7.2. Deploy Seletivo

```bash
# Apenas regras
firebase deploy --only firestore:rules

# Apenas índices (se tiver firestore.indexes.json)
firebase deploy --only firestore:indexes
```

### 7.3. Verificar Deploy

```bash
firebase deploy:list
```

---

## 8. Verificação

### 8.1. Checklist Pós-Configuração

- [ ] Regras de segurança aplicadas
- [ ] Índice de notificações criado
- [ ] Índice de filas criado
- [ ] Índice de chat criado
- [ ] Índice de serviços criado
- [ ] TTL configurado para chat_plantao
- [ ] App conecta ao Firestore sem erros
- [ ] Logout limpa cache corretamente

### 8.2. Testar Regras de Segurança

No Firebase Console → **Firestore Database** → **Regras** → **Playground**

**Teste 1: Usuário não autorizado**
```javascript
// Tipo de operação: get
// Localização: /pacientes/teste123
// Auth: não autenticado

// Resultado esperado: ❌ Acesso negado
```

**Teste 2: Usuário @sani.med.br**
```javascript
// Tipo de operação: get
// Localização: /notificacoes/teste123
// Auth: autenticado como usuario@sani.med.br

// Resultado esperado: ✅ Permitido
```

**Teste 3: Chat sem plantão**
```javascript
// Tipo de operação: get
// Localização: /chat_plantao/msg123
// Auth: autenticado mas não no plantão

// Resultado esperado: ❌ Acesso negado
```

### 8.3. Monitorar Uso

Firebase Console → **Firestore Database** → **Uso**

Acompanhar:
- 📊 Leituras de documentos
- 💰 Custo estimado
- 📈 Tendências de uso

---

## 🔐 Segurança LGPD

### Implementado

✅ **Cache de pacientes limpo ao logout**  
✅ **Regras restritivas para dados sensíveis**  
✅ **Auditoria completa** (campos `criadoPor`, `modificadoPor`)  
✅ **Nunca deletar** documentos (histórico completo)  
✅ **TTL para dados temporários** (chat, filas)  

### Conformidade

- ✅ Dados sensíveis sempre do servidor
- ✅ Cache limitado a 100 MB
- ✅ Limpeza automática ao logout
- ✅ Acesso restrito por domínio
- ✅ Logs de auditoria preservados

---

## 📊 Collections Configuradas

| Collection | Regras | Índices | TTL | Cache |
|------------|--------|---------|-----|-------|
| `usuarios` | ✅ | - | - | Longo |
| `pacientes` | ✅ | ✅ | - | ❌ Não |
| `medicos` | ✅ | - | - | Longo |
| `avaliacoesAnestesicas` | ✅ | ✅ | - | Médio |
| `plantoes` | ✅ | ✅ | - | Médio |
| `servicos` | ✅ | ✅ | - | Curto |
| `notificacoes` | ✅ | ✅ | - | Não |
| `filas_solicitacoes` | ✅ | ✅ | - | Não |
| `chat_plantao` | ✅ | ✅ | **24h** | Não |

---

## 🚀 Comandos Úteis

```bash
# Ver projeto atual
firebase projects:list

# Logar no Firebase
firebase login

# Configurar projeto
firebase use <project-id>

# Deploy completo
firebase deploy

# Ver regras atuais
firebase firestore:rules

# Ver índices
firebase firestore:indexes

# Logs em tempo real
firebase functions:log --only firestore
```

---

## 🐛 Troubleshooting

### Erro: "Missing or insufficient permissions"
- Verificar regras de segurança
- Confirmar que usuário tem email @sani.med.br
- Verificar autenticação no app

### Erro: "The query requires an index"
- Clicar no link fornecido no erro
- Ou criar índice manualmente no Console
- Aguardar 2-3 minutos para índice ficar disponível

### Cache não limpa ao logout
- Verificar implementação em `FirestoreConfig.configure()`
- Testar manualmente: `FirestoreConfig.limparCacheCompleto()`

### Performance lenta
- Verificar se índices estão criados
- Usar `.limit()` nas queries
- Verificar filtros específicos (não buscar tudo)

---

## 📚 Próximos Passos

1. ✅ Deploy das regras de segurança
2. ✅ Criar índices principais
3. ✅ Configurar TTL do chat
4. ⏳ Testar app completo
5. ⏳ Monitorar uso e custos
6. ⏳ Ajustar limites conforme necessário

---

## 📞 Suporte

- [Documentação Firebase](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [LGPD Brasil](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)
- [Suporte Firebase](https://firebase.google.com/support)

---

## ✅ Status da Configuração

- [x] Regras de segurança criadas
- [x] Configuração de cache implementada
- [x] Documentação de índices criada
- [ ] Regras deployed (execute: `firebase deploy --only firestore:rules`)
- [ ] Índices criados (criar conforme necessário)
- [ ] TTL configurado para chat (configurar no Console)
- [ ] App testado em produção

---

**Última atualização**: 20/10/2025

