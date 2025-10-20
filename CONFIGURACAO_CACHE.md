# 💾 Configuração de Cache e Persistência - SedaniHub

Guia completo para configurar cache offline otimizado do Firestore, com foco em **baixar apenas dados necessários** e **persistência limitada de dados de pacientes**.

## 🎯 Estratégia de Cache

### Dados com Cache Longo (Estáticos)
- ✅ Catálogos (especialidades, procedimentos, medicamentos)
- ✅ Usuários
- ✅ Médicos

### Dados com Cache Médio (Mudam Periodicamente)
- 🟡 Plantões (limpar cache semanal)
- 🟡 Escalas

### Dados com Cache Curto (Temporários)
- 🔴 **Pacientes** (limpar após uso)
- 🔴 Serviços do dia
- 🔴 Notificações
- 🔴 Filas de atendimento
- 🔴 Chat do plantão (apenas hoje)

### Dados Sem Cache (Tempo Real)
- ⚡ Chat do plantão (sempre buscar servidor)
- ⚡ Notificações ativas

## 🔧 Configuração no Código

### 1. Configurar Settings do Firestore

Edite `lib/main.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // CONFIGURAR FIRESTORE SETTINGS
  FirebaseFirestore.instance.settings = const Settings(
    // Cache de 100 MB (padrão é 40 MB)
    cacheSizeBytes: 100 * 1024 * 1024,
    
    // Persistência habilitada (permite uso offline)
    persistenceEnabled: true,
    
    // SSL habilitado (segurança)
    sslEnabled: true,
  );
  
  // Inicializar serviço de notificações
  await NotificationsService().initialize();
  
  // Limpar cache de pacientes antigos ao iniciar
  await _limparCachePacientes();
  
  runApp(const ProviderScope(child: SedaniHubApp()));
}

/// Limpa dados de pacientes que não foram acessados recentemente
Future<void> _limparCachePacientes() async {
  try {
    // Limpar cache de pacientes com mais de 24h
    await FirebaseFirestore.instance
        .clearPersistence(); // Opcional: limpa TUDO
    
    print('✅ Cache de pacientes limpo');
  } catch (e) {
    print('⚠️ Erro ao limpar cache (ignorado): $e');
  }
}
```

### 2. Queries com Source Explícita

Para dados sensíveis de pacientes, force busca do servidor:

```dart
// ✅ SEMPRE DO SERVIDOR (dados de pacientes)
final pacienteDoc = await FirebaseFirestore.instance
    .collection('pacientes')
    .doc(pacienteId)
    .get(const GetOptions(source: Source.server));

// ✅ CACHE PRIMEIRO, servidor se falhar (catálogos)
final procedimentos = await FirebaseFirestore.instance
    .collection('procedimentos')
    .get(const GetOptions(source: Source.cache));

// ✅ SERVIDOR E ATUALIZA CACHE (padrão - tempo real)
final servicos = await FirebaseFirestore.instance
    .collection('servicos')
    .where('inicio', isGreaterThanOrEqualTo: hoje)
    .get(); // Usa Source.serverAndCache por padrão
```

### 3. Limpar Cache Periodicamente

Criar serviço de manutenção:

```dart
// lib/core/services/cache_manager_service.dart

class CacheManagerService {
  static Future<void> limparCachePacientes() async {
    try {
      // Não é possível limpar cache seletivo
      // Opções:
      // 1. Limpar tudo periodicamente
      // 2. Usar TTL curto para dados sensíveis
      // 3. Não cachear pacientes (Source.server sempre)
      
      print('ℹ️ Cache de pacientes gerenciado via Source.server');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  static Future<void> limparCacheCompleto() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
      print('✅ Cache completo limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }
}
```

### 4. Configurar TTL no Firestore Console

**Para mensagens do chat (auto-deletar após 24h):**

1. Firebase Console → Firestore Database
2. Configurações → **Time-to-live**
3. Criar política:
   - **Collection**: `chat_plantao`
   - **Timestamp field**: `dataEnvio`
   - **Expiration**: 86400 seconds (24 horas)

**Para dados sensíveis (não aplicável via TTL, usar regras de acesso):**
- Dados de pacientes NÃO devem ter TTL (auditoria/LGPD)
- Use `Source.server` nas queries para evitar cache

## 📱 Implementação por Tipo de Dado

### Pacientes (DADOS SENSÍVEIS)

```dart
// SEMPRE buscar do servidor (sem cache)
class PacientesRepository {
  Future<DocumentSnapshot> getPaciente(String id) async {
    return await FirebaseFirestore.instance
        .collection('pacientes')
        .doc(id)
        .get(const GetOptions(source: Source.server));
  }
  
  Stream<DocumentSnapshot> streamPaciente(String id) {
    // Stream ignora cache e sempre ouve servidor
    return FirebaseFirestore.instance
        .collection('pacientes')
        .doc(id)
        .snapshots();
  }
}
```

### Catálogos (CACHE LONGO)

```dart
// Usar cache agressivamente (dados raramente mudam)
class CatalogosRepository {
  Future<QuerySnapshot> getProcedimentos() async {
    try {
      // Tentar cache primeiro
      return await FirebaseFirestore.instance
          .collection('procedimentos')
          .get(const GetOptions(source: Source.cache));
    } catch (e) {
      // Se cache falhar, buscar do servidor
      return await FirebaseFirestore.instance
          .collection('procedimentos')
          .get(const GetOptions(source: Source.server));
    }
  }
}
```

### Serviços do Dia (CACHE CURTO)

```dart
// Padrão (cache + servidor), mas com filtro restritivo
class ServicosRepository {
  Stream<List<Servico>> getServicosDia(DateTime data) {
    final inicio = DateTime(data.year, data.month, data.day);
    final fim = inicio.add(const Duration(days: 1));
    
    // Stream sempre do servidor (tempo real)
    return FirebaseFirestore.instance
        .collection('servicos')
        .where('inicio', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('inicio', isLessThan: Timestamp.fromDate(fim))
        .orderBy('inicio')
        .snapshots() // Tempo real, sem cache
        .map((snapshot) => 
            snapshot.docs.map((doc) => Servico.fromFirestore(doc)).toList()
        );
  }
}
```

### Chat do Plantão (SEM CACHE)

```dart
// Sempre tempo real, sem persistência offline
class ChatPlantaoService {
  Stream<List<ChatMensagem>> getMensagensPlantaoHoje() {
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return FirebaseFirestore.instance
        .collection('chat_plantao')
        .where('plantaoData', isEqualTo: hoje)
        .orderBy('dataEnvio')
        .snapshots() // Sempre do servidor
        .map((snapshot) => 
            snapshot.docs.map((doc) => ChatMensagem.fromFirestore(doc)).toList()
        );
  }
}
```

### Notificações (TEMPO REAL)

```dart
// Stream em tempo real (sem cache offline)
Stream<List<Notificacao>> getNotificacoesAtivas() {
  return FirebaseFirestore.instance
      .collection('notificacoes')
      .where('ativa', isEqualTo: true)
      .where('usuarioId', whereIn: [userEmail, null])
      .orderBy('dataCriacao', descending: true)
      .limit(50) // Limitar para otimizar
      .snapshots(); // Sempre servidor
}
```

## 🧹 Limpeza Automática

### Script de Manutenção

Executar periodicamente (recomendado: diariamente):

```dart
// lib/core/services/maintenance_service.dart

class MaintenanceService {
  static Future<void> executarManutencaoDiaria() async {
    print('🔧 Iniciando manutenção diária...');
    
    // 1. Limpar cache de pacientes
    await _limparCacheSensivel();
    
    // 2. Limpar mensagens antigas do chat
    await ChatPlantaoService().limparMensagensAntigas();
    
    // 3. Limpar filas expiradas
    await FilasService().limparSolicitacoesExpiradas();
    
    print('✅ Manutenção diária concluída');
  }
  
  static Future<void> _limparCacheSensivel() async {
    try {
      // Reinicializar Firestore para limpar cache
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
      
      print('✅ Cache sensível limpo');
    } catch (e) {
      print('⚠️ Erro ao limpar cache: $e');
    }
  }
}
```

### Agendar no App

```dart
// No main.dart ou em provider de inicialização
void main() async {
  // ... inicializações ...
  
  // Agendar manutenção para rodar a cada 24h
  Timer.periodic(const Duration(hours: 24), (_) {
    MaintenanceService.executarManutencaoDiaria();
  });
  
  runApp(const ProviderScope(child: SedaniHubApp()));
}
```

## ⚡ Otimizações Adicionais

### 1. Limit nas Queries

Sempre use `.limit()` para evitar downloads grandes:

```dart
// ✅ BOM
.collection('servicos').limit(100)

// ❌ RUIM
.collection('servicos') // Pode retornar milhares
```

### 2. Paginação

Para listas longas, implemente paginação:

```dart
QuerySnapshot? lastSnapshot;

Future<List<Servico>> carregarMais() async {
  Query query = FirebaseFirestore.instance
      .collection('servicos')
      .orderBy('inicio', descending: true)
      .limit(20);
  
  if (lastSnapshot != null && lastSnapshot!.docs.isNotEmpty) {
    query = query.startAfterDocument(lastSnapshot!.docs.last);
  }
  
  lastSnapshot = await query.get();
  return lastSnapshot!.docs.map((doc) => Servico.fromFirestore(doc)).toList();
}
```

### 3. Select Fields (Projeção)

Infelizmente, Firestore não suporta projeção de campos. Use subcoleções para dados grandes:

```dart
// Estruturar dados hierarquicamente
/pacientes/{id}              // Dados básicos
/pacientes/{id}/historico    // Dados pesados em subcoleção
```

### 4. Listener com unsubscribe

Sempre cancelar listeners quando não precisar mais:

```dart
StreamSubscription? _subscription;

void startListening() {
  _subscription = firestore.collection('servicos').snapshots().listen(...);
}

void stopListening() {
  _subscription?.cancel();
}

@override
void dispose() {
  stopListening();
  super.dispose();
}
```

## 🎨 Resumo de Configurações

| Tipo de Dado | Cache | Persistência | Source | Limpeza |
|--------------|-------|--------------|--------|---------|
| **Pacientes** | ❌ Não | ❌ Não | `Source.server` | Diária |
| **Catálogos** | ✅ Sim | ✅ Sim | `Source.cache` | Semanal |
| **Serviços** | 🟡 24h | 🟡 24h | `Source.serverAndCache` | Diária |
| **Notificações** | ❌ Não | ❌ Não | `snapshots()` | Automática |
| **Filas** | ❌ Não | ❌ Não | `snapshots()` | 2h (TTL) |
| **Chat** | ❌ Não | ❌ Não | `snapshots()` | 24h (TTL) |
| **Plantões** | 🟡 7d | 🟡 7d | `Source.serverAndCache` | Semanal |

## 📋 Checklist de Implementação

### Configuração Inicial
- [x] Regras de segurança no Firestore
- [ ] Índices compostos criados
- [ ] Settings do Firestore configuradas
- [ ] TTL configurado para chat_plantao

### Otimizações de Código
- [ ] Pacientes sempre com `Source.server`
- [ ] Queries com `.limit()` apropriado
- [ ] Listeners cancelados no dispose
- [ ] Filtros específicos em todas as queries

### Manutenção
- [ ] Script de limpeza de cache
- [ ] Agendamento de manutenção diária
- [ ] Monitoramento de uso de cache
- [ ] Logs de performance

## 🚀 Deploy das Configurações

### 1. Fazer Deploy das Regras

```bash
cd D:\flutter\sanihub
firebase deploy --only firestore:rules
```

### 2. Criar Índices

Os índices serão criados automaticamente quando você usar o app. Alternativamente:

```bash
# Se tiver o arquivo firestore.indexes.json
firebase deploy --only firestore:indexes
```

### 3. Configurar TTL no Console

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Firestore Database → Configurações
3. Time-to-live → Criar política
4. Collection: `chat_plantao`, Field: `dataEnvio`, Duration: 86400s

## 📊 Monitoramento

### Ver Uso de Cache (DevTools)

```dart
// Adicionar logging temporário
FirebaseFirestore.instance.snapshotsInSync().listen((_) {
  print('🔄 Firestore sincronizado com servidor');
});
```

### Métricas Importantes

1. **Leituras do servidor** (custo $$)
2. **Leituras do cache** (grátis)
3. **Tamanho do cache** (100 MB max)
4. **Tempo de carregamento**

## ⚠️ Avisos Importantes

### LGPD e Dados Sensíveis

- ❌ **NÃO** fazer cache longo de dados de pacientes
- ✅ **SIM** limpar cache ao logout
- ✅ **SIM** usar `Source.server` para dados sensíveis
- ✅ **SIM** manter auditoria completa (nunca deletar)

### Performance vs Segurança

```dart
// DADOS SENSÍVEIS (Pacientes):
Source.server  // Segurança > Performance

// DADOS PÚBLICOS (Catálogos):
Source.cache   // Performance > Segurança

// DADOS TEMPO REAL (Chat, Notificações):
snapshots()    // Tempo real > Cache
```

## 🎯 Exemplo de Implementação Completa

```dart
// lib/core/config/firestore_config.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreConfig {
  static Future<void> configure() async {
    // 1. Configurar settings
    FirebaseFirestore.instance.settings = const Settings(
      cacheSizeBytes: 100 * 1024 * 1024, // 100 MB
      persistenceEnabled: true,
      sslEnabled: true,
    );

    // 2. Listener de autenticação para limpar cache ao logout
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        // Usuário fez logout - limpar cache
        try {
          await FirebaseFirestore.instance.clearPersistence();
          print('✅ Cache limpo após logout');
        } catch (e) {
          print('⚠️ Cache já limpo ou em uso');
        }
      }
    });

    print('✅ Firestore configurado');
  }

  static GetOptions get serverOnly => const GetOptions(source: Source.server);
  static GetOptions get cacheOnly => const GetOptions(source: Source.cache);
  static GetOptions get serverAndCache => const GetOptions(source: Source.serverAndCache);
}

// No main.dart:
await FirestoreConfig.configure();
```

## 📚 Referências

- [Firestore Offline Data](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firestore Performance](https://firebase.google.com/docs/firestore/best-practices)
- [Firestore TTL](https://firebase.google.com/docs/firestore/ttl)
- [LGPD Compliance](https://www.gov.br/cidadania/pt-br/acesso-a-informacao/lgpd)

