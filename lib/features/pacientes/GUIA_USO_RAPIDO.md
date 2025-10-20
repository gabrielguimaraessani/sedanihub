# Guia de Uso Rápido - Sistema de Prontuário com IA

## 🚀 Início Rápido

### Para Médicos e Profissionais de Saúde

#### 1. Acessar Lista de Prontuários
- No dashboard, clique em "Prontuários de Pacientes"
- Use a busca para localizar pacientes por nome, CPF ou número de prontuário

#### 2. Criar Novo Prontuário
```
1. Clique no botão "+" no canto superior direito
2. Digite o NOME COMPLETO do paciente (obrigatório)
3. Digite a DATA DE NASCIMENTO no formato DD/MM/AAAA (obrigatório)
4. Clique em "Criar"
5. O sistema abrirá automaticamente a tela de edição
```

**Validações Automáticas:**
- ✅ Nome deve ter pelo menos 2 palavras
- ✅ Data de nascimento não pode ser futura
- ✅ Data deve estar no formato DD/MM/AAAA
- ✅ Ano deve ser maior que 1900

#### 3. Editar Prontuário Existente

**Método 1 - Via Lista:**
```
1. Localize o paciente na lista
2. Clique no ícone de "Editar" (lápis)
3. Tela de edição será aberta com todos os dados
```

**Método 2 - Via Visualização PDF:**
```
1. Clique em "Visualizar PDF"
2. No canto superior direito, clique em "Editar"
```

### 4. Adicionar Informações ao Prontuário

#### 📝 Via Texto
```
1. Digite ou cole as informações no campo de entrada
2. A IA do Gemini processará automaticamente
3. Dados serão organizados e categorizados
4. Visualize na árvore expansível abaixo
```

**Exemplos de entradas de texto:**
```
"PA: 120/80 mmHg, FC: 72 bpm, Temp: 36.5°C"
→ Será categorizado em Dados Físicos

"Paciente relata dor torácica ocasional há 3 meses"
→ Será categorizado em História Médica

"Usando Losartana 50mg 1x/dia, AAS 100mg 1x/dia"
→ Será categorizado em Medicamentos
```

#### 📸 Via Imagem
```
1. Clique no ícone de imagem
2. Escolha entre:
   - 📷 Câmera: Tirar foto agora
   - 🖼️ Galeria: Selecionar imagem existente
3. IA processará e extrairá informações
4. Dados aparecerão na árvore
```

**Tipos de imagens aceitas:**
- Exames de imagem (RX, TC, RM)
- Documentos escaneados
- Resultados de exames impressos
- Fotos de lesões/feridas

#### 🎤 Via Áudio
```
1. Clique no ícone de microfone
2. Grave seu ditado médico
3. Clique em "Parar e Processar"
4. IA transcreverá e organizará
5. Revise os dados extraídos
```

**Dicas para gravação:**
- Fale claramente e pausadamente
- Use terminologia médica padrão
- Indique seções (ex: "História médica:", "Exame físico:")

### 5. Usar Sugestões da IA 🤖

```
1. Clique no botão "Sugestões da IA"
2. Escolha o tipo de análise:
```

#### 📊 Aplicar Escore de Risco
- Calcula risco cardiovascular (Framingham)
- Classificação ASA
- Risco cirúrgico estimado
- Recomendações personalizadas

**Quando usar:**
- Antes de cirurgias
- Avaliação pré-anestésica
- Consultas de risco cardiovascular

#### 💊 Revisar Medicamentos
- Detecta interações medicamentosas
- Alerta sobre contraindicações
- Sugere ajustes de dose
- Verifica alergias cruzadas

**Quando usar:**
- Prescrição de novos medicamentos
- Polimedicação
- Mudança de esquema terapêutico

#### ✅ Verificar Protocolos
- Compara com protocolos institucionais
- Checklists de segurança
- Conformidade com diretrizes
- Alertas de itens pendentes

**Quando usar:**
- Antes de procedimentos
- Auditorias internas
- Garantia de qualidade

#### 🎯 Análise Completa
- Combina todas as análises acima
- Relatório abrangente
- Visão 360° do caso

**Quando usar:**
- Casos complexos
- Múltiplas comorbidades
- Segunda opinião automatizada

### 6. Navegar pelos Dados (Árvore Expansível)

```
📁 Identificação
  └─ Nome: João Silva
  └─ CPF: 123.456.789-00
  └─ Data de Nascimento: 15/03/1980

📁 Dados Físicos
  └─ Peso: 75 kg
  └─ Altura: 175 cm
  └─ IMC: 24.5

📁 História Médica
  └─ 📋 Condições
      └─ Hipertensão arterial
      └─ Diabetes tipo 2
```

**Como usar:**
- Clique na seta para expandir/colapsar seções
- 🟠 Bolinha laranja = seção com alterações pendentes
- Scroll para navegar por todas as informações

### 7. Salvar e Liberar Avaliação

#### Auto-Save (Automático)
```
✅ Todas as alterações são salvas automaticamente
✅ Não é necessário clicar em "Salvar"
✅ Alterações ficam pendentes até liberação
```

#### Liberar Avaliação/Consulta
```
1. Revise todos os dados na árvore
2. Clique em "Liberar Avaliação / Consulta"
3. Confirme a ação
4. Uma nova VERSÃO será criada no histórico
```

**⚠️ IMPORTANTE:**
- Versão liberada é IMUTÁVEL (não pode ser alterada)
- Ficará permanentemente no histórico de auditoria
- Use apenas quando finalizar a avaliação

### 8. Visualizar Histórico de Versões

```
1. Na tela de edição, clique no ícone de relógio (histórico)
2. Veja todas as versões anteriores:
   - Versão 1: Criação do prontuário - Dr. Carlos
   - Versão 2: Atualização de exames - Dra. Ana
   - Versão 3: Avaliação pré-anestésica - Dr. Gabriel
```

## 💡 Dicas e Boas Práticas

### ✅ Faça
- ✅ Revise sempre os dados extraídos pela IA
- ✅ Use terminologia médica padrão
- ✅ Libere avaliação apenas quando finalizar
- ✅ Aproveite as sugestões da IA como auxílio
- ✅ Mantenha dados atualizados

### ❌ Não Faça
- ❌ Não confie cegamente na IA - sempre revise
- ❌ Não libere avaliação com dados incompletos
- ❌ Não pule validações obrigatórias
- ❌ Não ignore alertas de segurança
- ❌ Não compartilhe dados sensíveis

## 🔒 Segurança e Privacidade

### Dados Protegidos
- 🔐 Criptografia end-to-end
- 🔐 Acesso apenas para profissionais autorizados
- 🔐 Auditoria completa de acessos
- 🔐 Conformidade com LGPD

### Rastreabilidade
```
Toda ação é registrada:
- Quem acessou
- Quando acessou
- O que modificou
- Versão anterior e atual
```

## 📱 Atalhos e Dicas Rápidas

| Ação | Atalho |
|------|--------|
| Enviar texto | `Enter` no campo |
| Expandir/Colapsar seção | Clique na seta |
| Ver histórico | Ícone ⏰ no AppBar |
| Adicionar imagem | Ícone 📷 |
| Gravar áudio | Ícone 🎤 |
| Sugestões IA | Botão azul na barra superior |

## ❓ Perguntas Frequentes

### Como a IA processa meus dados?
A IA do Gemini analisa o conteúdo (texto, imagem, áudio) e extrai informações médicas relevantes, categorizando-as automaticamente na estrutura do prontuário.

### As alterações são salvas automaticamente?
Sim! Não se preocupe em clicar em "Salvar". Todas as alterações são auto-salvas, mas ficam como "pendentes" até você liberar a avaliação.

### Posso desfazer uma liberação de avaliação?
Não. Uma vez liberada, a versão fica imutável no histórico. Por isso, revise bem antes de liberar.

### A IA pode errar?
Sim. A IA é um ASSISTENTE, não substitui o julgamento clínico. Sempre revise e valide as informações extraídas.

### Como funciona o versionamento?
Cada vez que você libera uma avaliação, uma nova versão é criada. O histórico mantém todas as versões anteriores para auditoria.

### Posso usar offline?
Atualmente não. O processamento da IA requer conexão com internet.

## 🆘 Suporte

### Problemas Comuns

**"A IA não está processando"**
- Verifique conexão com internet
- Aguarde alguns segundos
- Tente novamente

**"Não consigo liberar avaliação"**
- Verifique se há alterações pendentes (bolinha laranja)
- Preencha campos obrigatórios
- Revise dados inseridos

**"Dados não aparecem na árvore"**
- Aguarde processamento da IA
- Recarregue a página
- Verifique se houve erro

### Contato
- 📧 Email: suporte@sanihub.com.br
- 📞 Telefone: (11) 1234-5678
- 💬 Chat: Disponível no sistema

---

**Versão do Guia:** 1.0  
**Última Atualização:** 15/10/2024  
**Desenvolvido por:** Equipe SaniHub

