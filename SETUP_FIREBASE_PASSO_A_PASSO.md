# 🚀 Setup Firebase - Passo a Passo

Guia completo para configurar o Firebase Authentication e Firestore para o SedaniHub.

## 📋 Checklist Geral

- [ ] Criar projeto no Firebase
- [ ] Configurar Authentication
- [ ] Criar primeiro usuário
- [ ] Configurar Firestore Database
- [ ] Fazer deploy das regras de segurança
- [ ] Criar índices
- [ ] Configurar TTL
- [ ] Testar conexão no app

---

## 1️⃣ Criar Projeto Firebase

### No Firebase Console

1. Acesse https://console.firebase.google.com
2. Clique em **"Adicionar projeto"** ou **"Create a project"**
3. Preencha:
   - **Nome do projeto**: `sedanihub` (ou seu nome preferido)
   - **Google Analytics**: Desabilitar (opcional para app corporativo)
4. Clique em **"Criar projeto"**
5. Aguarde a criação (~1-2 minutos)

---

## 2️⃣ Configurar Authentication

### 2.1. Habilitar Email/Password

1. No Console do projeto, vá em **Authentication**
2. Clique em **"Começar"** ou **"Get started"**
3. Vá na aba **"Sign-in method"**
4. Clique em **"Email/Password"**
5. Habilite **"Email/Password"** (primeira opção)
6. **NÃO** habilite "Email link" (segunda opção)
7. Clique em **"Salvar"**

### 2.2. Criar Primeiro Usuário (VOCÊ)

Na aba **"Users"**:

1. Clique em **"Adicionar usuário"** / **"Add user"**
2. Preencha:
   - **Email**: `seu.email@sani.med.br`
   - **Senha**: Escolha uma senha forte (mín. 6 caracteres)
   - **User ID**: Será gerado automaticamente
3. Clique em **"Adicionar usuário"**

✅ **Este é o usuário que você usará para fazer login no app!**

### 2.3. Configurar Domínios Autorizados (Importante para Web)

1. Authentication → **Settings** → **Authorized domains**
2. Já deve ter:
   - `localhost` (para desenvolvimento)
   - `seu-projeto.firebaseapp.com`
   - `seu-projeto.web.app`
3. Se for hospedar em domínio próprio, adicionar aqui

---

## 3️⃣ Configurar Firestore Database

### 3.1. Criar Database

1. No Console, vá em **Firestore Database**
2. Clique em **"Criar banco de dados"** / **"Create database"**
3. Escolha:
   - **Modo**: **Produção** (Production mode)
   - **Localização**: **southamerica-east1 (São Paulo)** ⭐ Recomendado
   - Ou: **us-central1** (mais barato, mas mais longe)
4. Clique em **"Ativar"**

### 3.2. Collections Necessárias

O Firestore criará as collections automaticamente quando você usar o app. Mas você pode pré-criar:

**Collections principais:**
- `usuarios` (usuários do sistema)
- `pacientes` (dados de pacientes)
- `medicos` (cadastro de médicos)
- `servicos` (procedimentos/cirurgias)
- `plantoes` (escala de plantões)
- `notificacoes` (sistema de notificações)
- `filas_solicitacoes` (filas de banheiro/alimentação)
- `chat_plantao` (chat do plantão)

**Collections de catálogo:**
- `especialidades`
- `procedimentos`
- `complicacoes`
- `habitos`
- `medicamentosCatalogo`

---

## 4️⃣ Deploy das Regras de Segurança

### Opção 1: Via Firebase CLI (Recomendado)

```bash
# 1. Fazer login (se ainda não fez)
firebase login

# 2. Inicializar projeto (se ainda não fez)
cd D:\flutter\sanihub
firebase init firestore

# Selecionar:
# - Use existing project → Seu projeto
# - Firestore rules: security/firestore.rules
# - Firestore indexes: firestore.indexes.json (criar se solicitado)

# 3. Fazer deploy
firebase deploy --only firestore:rules
```

### Opção 2: Via Console (Manual)

1. Firebase Console → **Firestore Database** → **Regras**
2. Copiar todo o conteúdo de `security/firestore.rules`
3. Colar no editor de regras
4. Clicar em **"Publicar"**

### Verificar Deploy

Após deploy, você deve ver no console:
```
✔  Deploy complete!
```

---

## 5️⃣ Criar Índices Compostos

### Método 1: Automático (Mais Fácil)

1. Execute o app
2. Navegue pelas funcionalidades
3. Quando aparecer erro de "índice necessário", haverá um **link clicável**
4. Clique no link → Firebase cria o índice automaticamente
5. Aguarde 2-3 minutos para índice ficar pronto
6. Recarregue o app

### Método 2: Manual (Console)

Firebase Console → **Firestore Database** → **Índices** → **Criar índice**

**Criar estes índices prioritários:**

#### Índice 1: Notificações
- Collection: `notificacoes`
- Campos:
  1. `ativa` - Ascending
  2. `usuarioId` - Ascending  
  3. `dataCriacao` - Descending

#### Índice 2: Filas
- Collection: `filas_solicitacoes`
- Campos:
  1. `concluida` - Ascending
  2. `dataExpiracao` - Ascending
  3. `dataSolicitacao` - Ascending

#### Índice 3: Chat
- Collection: `chat_plantao`
- Campos:
  1. `plantaoData` - Ascending
  2. `dataEnvio` - Ascending

#### Índice 4: Serviços
- Collection: `servicos`
- Campos:
  1. `inicio` - Ascending
  2. `finalizado` - Ascending

**Lista completa em**: `security/firestore_indexes.md`

---

## 6️⃣ Configurar TTL (Time-to-Live)

### Para Mensagens do Chat (Auto-deletar após 24h)

Firebase Console → **Firestore Database** → ⚙️ **Configurações** → **Time-to-live**

1. Clicar em **"Criar política"** / **"Create policy"**
2. Preencher:
   - **Policy name**: `chat_plantao_cleanup`
   - **Collection**: `chat_plantao`
   - **Timestamp field**: `dataEnvio`
   - **Expiration**: `86400` (segundos = 24 horas)
3. Clicar em **"Criar"**

✅ Agora mensagens do chat serão automaticamente deletadas após 24h!

---

## 7️⃣ Criar Documento de Usuário no Firestore

### Importante: Sincronizar com Authentication

Quando criar usuário no Authentication, criar também documento em `/usuarios`:

1. Firestore Database → Coleção **"usuarios"**
2. **Adicionar documento**
3. **ID do documento**: `seu.email@sani.med.br` (mesmo email do Auth)
4. Campos:
```javascript
{
  nomeCompleto: "Seu Nome Completo",
  crmDf: 12345,
  email: "seu.email@sani.med.br",
  funcaoAtual: "Senior",
  gerencia: ["CEO"],
  dataCriacao: (timestamp atual),
  criadoPor: "system"
}
```

### Ou criar via script (futuro):

```dart
// Após criar usuário no Authentication
await FirebaseFirestore.instance
    .collection('usuarios')
    .doc(user.email)
    .set({
  'nomeCompleto': 'Nome do Usuário',
  'email': user.email,
  'funcaoAtual': 'Senior',
  'dataCriacao': FieldValue.serverTimestamp(),
  'criadoPor': 'system',
});
```

---

## 8️⃣ Testar Conexão

### 8.1. No App

```bash
cd D:\flutter\sanihub
flutter clean
flutter pub get
flutter run -d chrome --web-port 52206
```

### 8.2. Fazer Login

1. App abre → Tela de login
2. Digite:
   - **Email**: `seu.email@sani.med.br`
   - **Senha**: A senha que você criou no Firebase
3. Clicar em **"Entrar"**

### 8.3. O que Deve Acontecer

✅ **Se der certo:**
- Login bem-sucedido
- Redirecionado para Dashboard
- Console mostra: `🎉 Login bem-sucedido: seu.email@sani.med.br`

❌ **Se der erro:**
- Verificar se usuário foi criado no Authentication
- Verificar se email/senha estão corretos
- Ver logs no console do navegador (F12)

---

## 9️⃣ Verificar no Firebase Console

### Authentication → Users

Deve mostrar:
- ✅ Seu usuário criado
- ✅ Último login (após você fazer login no app)

### Firestore Database → Data

Após usar o app, deve mostrar:
- ✅ Collection `usuarios` com seu documento
- ✅ Collections criadas conforme uso (notificacoes, chat_plantao, etc)

### Firestore Database → Regras

Deve mostrar:
- ✅ Regras customizadas (não as padrões)
- ✅ Última publicação: hoje

### Firestore Database → Índices

Conforme você usar o app, índices aparecerão aqui.

---

## 🎯 Resumo Rápido

### O que PRECISA fazer no Console:

1. ✅ **Criar projeto**
2. ✅ **Authentication** → Habilitar Email/Password
3. ✅ **Authentication** → Criar seu usuário
4. ✅ **Firestore** → Criar database (modo produção)
5. ✅ **Firestore** → Deploy das regras (via CLI ou manual)
6. ✅ **Firestore** → Configurar TTL para chat (opcional mas recomendado)
7. ✅ **Firestore** → Criar documento em `/usuarios/{seu.email}`

### O que é AUTOMÁTICO:

- ✅ Collections criadas conforme uso
- ✅ Índices sugeridos via links (clicar quando aparecer)
- ✅ Cache configurado no código
- ✅ Limpeza de cache ao logout

---

## 🔧 Configuração via CLI (Método Completo)

Se preferir fazer tudo via terminal:

```bash
# 1. Login
firebase login

# 2. Criar projeto (ou usar existente)
firebase projects:create sedanihub

# 3. Inicializar no diretório
cd D:\flutter\sanihub
firebase init

# Selecionar:
# - Firestore (regras e índices)
# - Authentication (opcional)
# - Storage (se usar)
# - Hosting (se hospedar web)

# 4. Configurar Flutter app
flutterfire configure

# 5. Deploy
firebase deploy
```

---

## ❓ FAQ

### Preciso configurar algo no código do app?

**NÃO!** ✅ O código já está pronto com:
- Firebase Authentication integrado
- Firestore configurado com cache otimizado
- Regras de segurança prontas
- Toda a lógica implementada

### O que muda do login fake para o real?

**NADA na UI!** ✅ Apenas internamente:
- Antes: Simulava login
- Agora: Conecta no Firebase de verdade
- Mensagens de erro mais específicas
- Dados reais salvos no Firestore

### Consigo testar sem criar usuários?

**NÃO** ❌ Você precisa criar pelo menos 1 usuário no Firebase Console para fazer login.

### Como adicionar mais usuários?

**Via Console** (Manual):
- Authentication → Users → Add user

**Via Admin SDK** (Futuro):
- Criar função de administração
- Permitir coordenador criar usuários

### Preciso ir ao Console para tudo?

**Apenas configuração inicial:**
- ✅ Criar projeto (1 vez)
- ✅ Habilitar Authentication (1 vez)
- ✅ Criar database (1 vez)
- ✅ Deploy de regras (1 vez, depois pode ser via CLI)
- ✅ Criar primeiro usuário (1 vez)

**Depois disso:**
- ✅ Criar mais usuários → Via Console ou Admin SDK
- ✅ Ver dados → Via Console (read-only)
- ✅ Monitorar → Via Console
- ❌ Desenvolvimento → Tudo no código!

---

## 🎯 Ordem Recomendada

### Passo 1: Firebase Console (15 minutos)
```
1. Criar projeto
2. Authentication → Email/Password
3. Authentication → Criar seu usuário
4. Firestore → Criar database (produção, São Paulo)
5. Firestore → Criar documento em /usuarios/{seu.email}
```

### Passo 2: Terminal (5 minutos)
```bash
firebase login
cd D:\flutter\sanihub
firebase init firestore
firebase deploy --only firestore:rules
```

### Passo 3: App (2 minutos)
```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port 52206
```

### Passo 4: Testar (2 minutos)
```
1. Login com email/senha criados
2. Navegar pelo app
3. Criar índices ao aparecer erros (clicar nos links)
```

### Passo 5: Finalizar (5 minutos)
```
1. Configurar TTL no Console
2. Verificar todas as funcionalidades
3. Criar mais usuários se necessário
```

**Total**: ~30 minutos

---

## 📝 Template: Documento de Usuário

Sempre que criar um usuário no Authentication, criar este documento no Firestore:

### Collection: `/usuarios/{email@sani.med.br}`

```json
{
  "nomeCompleto": "Dr. João Silva",
  "crmDf": 12345,
  "email": "joao.silva@sani.med.br",
  "funcaoAtual": "Senior",
  "gerencia": ["Nenhuma"],
  "dataCriacao": "2025-10-20T10:00:00Z",
  "criadoPor": "system",
  "ultimaModificacao": "2025-10-20T10:00:00Z",
  "modificadoPor": "system"
}
```

**Valores de `funcaoAtual`:**
- `Senior`
- `Pleno 2`
- `Pleno 1`
- `Assistente`
- `Analista de qualidade`
- `Administrativo`

**Valores de `gerencia`** (array):
- `Nenhuma`
- `CEO`
- `CFO`
- `COO`
- `Diretor de Qualidade`
- `Diretor de Marketing`
- (etc - ver `documentation/data/colecoes_sedanihub.md`)

---

## 🔐 Segurança

### Emails Permitidos

As regras só permitem:
- ✅ `*@sani.med.br`
- ✅ `*@sedanimed.br`

Outros domínios serão **bloqueados** pelas regras de segurança.

### Custom Claims (Futuro)

Para adicionar roles (admin, medico, etc):

```javascript
// Via Firebase Admin SDK ou Cloud Functions
admin.auth().setCustomUserClaims(uid, {
  roles: ['medico', 'admin']
});
```

Por enquanto, todos os usuários `@sani.med.br` têm acesso total.

---

## ✅ Verificação Final

### No Firebase Console:

- [ ] Projeto criado
- [ ] Authentication habilitado
- [ ] Pelo menos 1 usuário criado
- [ ] Firestore database criado
- [ ] Regras customizadas publicadas
- [ ] Documento em `/usuarios/{email}` criado

### No App:

- [ ] Consegue fazer login
- [ ] Vê dashboard
- [ ] Notificações funcionam
- [ ] Chat do plantão acessível
- [ ] Filas funcionam
- [ ] Logout funciona

### Logs Esperados (Console do App):

```
✅ Firestore configurado com cache otimizado
📱 Badge suportado: false (Web não suporta)
🔐 Tentativa de login iniciada para: seu.email@sani.med.br
✅ Email válido, autenticando no Firebase...
🎉 Login bem-sucedido: seu.email@sani.med.br
🧭 Redirecionando para dashboard
```

---

## 🆘 Problemas Comuns

### "Email inválido" ao fazer login
- Verificar se email termina com `@sani.med.br`
- Verificar se digitou corretamente

### "Usuário não encontrado"
- Criar usuário no Firebase Console → Authentication → Users

### "Erro de permissão" ao acessar Firestore
- Verificar se regras foram deployed
- Verificar se email do usuário é `@sani.med.br`
- Ver regras em Firestore → Regras

### "Query requires an index"
- Clicar no link fornecido no erro
- Ou criar índice manualmente no Console
- Aguardar 2-3 minutos

### App não conecta ao Firebase
- Verificar arquivo `lib/firebase_options.dart` existe
- Executar: `flutterfire configure`
- Verificar conexão com internet

---

## 🎉 Pronto!

Após seguir todos os passos, seu app estará:

✅ Conectado ao Firebase real  
✅ Autenticação funcionando  
✅ Firestore configurado e seguro  
✅ Cache otimizado  
✅ Regras de segurança aplicadas  
✅ LGPD compliant  

**Agora é só usar!** 🚀

