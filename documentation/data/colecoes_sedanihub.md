# 📚 Modelo de Dados — SedaNiHub (Firestore)

Este documento especifica as **coleções**, **subcoleções**, **campos**, **restrições** e **regras** sugeridas para o banco de dados do **SedaNiHub** (Cloud Firestore). O foco é garantir **normalização clínica**, **rastreabilidade** e **conformidade** (SBIS v5.2, ISO 82304-1, LGPD/HIPAA).

> Convenções
> - `id` = identificador do documento (string UUID).
> - Datas em UTC com `Timestamp` do Firestore.
> - Campos opcionais indicados como *(opcional)*.
> - Campos de referência usam `ref:` para indicar relação com outra coleção.

---

## Sumário
- [Pacientes](#pacientes)
- [Médicos](#médicos)
- [Usuários](#usuários)
- [Especialidades](#especialidades)
- [Procedimentos](#procedimentos)
- [Complicações](#complicações)
- [Hábitos](#hábitos)
- [Revisão de sistemas](#revisão-de-sistemas)
- [Medicamento / Medicamentos](#medicamento--medicamentos)
- [Riscos](#riscos)
- [Exames complementares](#exames-complementares)
- [Avaliação anestésica](#avaliação-anestésica)
- [Escala](#escala)
- [Plantão](#plantão)
- [Anestesista](#anestesista)
- [Serviço](#serviço)
- [Campos de auditoria](#campos-de-auditoria)
- [Funcionalidades por tipo de usuário](#funcionalidades-por-tipo-de-usuário)
- [Regras de segurança (sugestão)](#regras-de-segurança-sugestão)
- [Índices recomendados](#índices-recomendados)
- [Boas práticas de escrita](#boas-práticas-de-escrita)

---

## Pacientes
**Coleção:** `/pacientes/{pacienteId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `nomeCompleto` | string | Obrigatório. Texto normalizado (NFKC), `trim`. |
| `dataNascimento` | date (Timestamp) | Obrigatório. Sem time-zone do cliente (usar UTC). |
| `cpf` | string | Obrigatório (formato `XXX.XXX.XXX-YY` ou `XXXXXXXXXXX`). Índice único lógico (via Function). |
| `medicosAssistentes` | array<ref:`/medicos/{medicoId}`> | 0..N referências a **Médicos**. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

**Subcoleções usuais (opcional):**
- `/pacientes/{pacienteId}/alergias` (se for necessário granularidade por item)

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Médicos
**Coleção:** `/medicos/{medicoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `nomeCompleto` | string | Obrigatório. |
| `crm` | string | Obrigatório. Usar string (mantém zeros à esquerda). |
| `estadoCrm` | string | Obrigatório. Sigla UF (`AC`..`TO`). |
| `especialidades` | array<ref:`/especialidades/{especialidadeId}`> | 0..N referências a **Especialidades**. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Usuários
**Coleção:** `/usuarios/{usuarioId}`

> **ID do documento:** usar o e-mail do usuário como identificador único.

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `nomeCompleto` | string | Obrigatório. |
| `crmDf` | number | CRM-DF (número). |
| `email` | string | Obrigatório. Formato e-mail válido. Usado como ID do documento. |
| `funcaoAtual` | string | Enum: {`Senior`,`Pleno 2`,`Pleno 1`,`Assistente`,`Analista de qualidade`,`Administrativo`} |
| `gerencia` | array<string> | Enum múltipla: {`Nenhuma`,`CEO`,`CFO`,`COO`,`Diretor de Qualidade`,`Diretor de Marketing`,`Diretor de compras`,`Diretor de Auditoria`,`Diretor de atendimento fora do centro cirúrgico`,`Diretor de ensino`,`Diretor de relacionamentos`,`Diretoria de gestão de funcionários`,`Diretor do consultorio pre-anestesico`} |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Especialidades
**Coleção:** `/especialidades/{especialidadeId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. Única por convenção. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Procedimentos
**Coleção:** `/procedimentos/{procedimentoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `codigoTuss` | string | *(opcional)* Código TUSS. |
| `porteAnestesico` | string | *(opcional)* Texto livre ou tabela controlada. |
| `especialidades` | array<ref:`/especialidades/{especialidadeId}`> | 0..N referências a **Especialidades**. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Complicações
**Coleção:** `/complicacoes/{complicacaoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `gravidade` | string | Enum: {`nenhuma`,`risco_potencial`,`dano_leve`,`dano_moderado`,`dano_grave`,`dano_catastrofico`} |
| `grupo` | string | *(opcional)* Texto livre (ex.: respiratória, cardiovascular). |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Hábitos
**Coleção:** `/habitos/{habitoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Livre **ou** enum: {`tabagismo`,`etilismo`,`cocaina`,`cannabis_sativa`} |
| `frequencia` | string | *(opcional)* Texto livre. |
| `parouHaQuantoTempo` | string | *(opcional)* Texto livre. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> Alternativa: transformar `descricao` em enum e colocar variações em `frequencia`/`tipo`/`detalhe`.

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Revisão de sistemas
**Coleção:** `/revisaoSistemas/{itemId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `sistema` | string | Enum: {`Cardiovascular`,`Respiratorio`,`GenitoUrinario`,`Endocrinologico`,`Hematopoetico`,`NervosoCentral`,`InfectoContagioso`,`Digestivo`,`OcularAuditivo`,`MusculoEsqueletico`,`Psiquiatrico`} |
| `diagnostico` | string | Texto livre. |
| `haQuantoTempo` | string | *(opcional)* Texto livre. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Medicamento / Medicamentos
### Medicamento (catálogo)
**Coleção:** `/medicamentosCatalogo/{medicamentoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `classes` | array<string> | *(opcional)* |
| `principiosAtivos` | array<string> | *(opcional)* |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

### Medicamentos (uso pelo paciente)
**Subcoleção por Avaliação:** `/avaliacoesAnestesicas/{avaliacaoId}/medicamentos/{medicamentoUsoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `refMedicamento` | ref:`/medicamentosCatalogo/{medicamentoId}` | Obrigatório. |
| `nomeGenerico` | string | *(opcional)* |
| `dose` | string | *(opcional)* |
| `frequencia` | string | *(opcional)* |
| `ultimaDose` | string | *(opcional)* |
| `orientacoesPreAnestesicas` | string | *(opcional)* |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Riscos
**Subcoleção:** `/avaliacoesAnestesicas/{avaliacaoId}/riscos/{riscoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `tipoFerramenta` | ref:`/ferramentasRisco/{ferramentaId}` | Obrigatório. |
| `parametros` | string | Texto livre. |
| `resultado` | string | Texto livre. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

*(Criar a coleção de catálogo)* **`/ferramentasRisco/{ferramentaId}`**: nome, referência bibliográfica, versão, campos de auditoria.

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Exames complementares
**Subcoleção:** `/avaliacoesAnestesicas/{avaliacaoId}/exames/{exameId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `tipo` | string | Enum: {`Laboratorial`,`Imagem`} |
| `dataExame` | date (Timestamp) | *(opcional)* |
| `laudo` | string | *(opcional)* Texto livre. |
| `anexoArquivoUrl` | string | *(opcional)* URL GCS/Storage (assinado). |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Avaliação anestésica
**Coleção:** `/avaliacoesAnestesicas/{avaliacaoId}`

> **Imutável após assinatura** (ver regras de imutabilidade/ledger).
> Recomenda-se criar por **paciente**, por exemplo: `/pacientes/{pacienteId}/avaliacoes/{avaliacaoId}` se preferir escopo por paciente. Abaixo usa-se raiz para simplificar os paths.

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `pacienteId` | ref:`/pacientes/{pacienteId}` | Obrigatório. |
| `medicoResponsavelId` | ref:`/medicos/{medicoId}` | Obrigatório. |
| `procedimentosPropostos` | array<ref:`/procedimentos/{procedimentoId}`> | 0..N |
| `ladoOuNivel` | string | Enum: {`nao_se_aplica`,`bilateral`,`esquerdo`,`direito`,`cervical`,`toracico`,`lombar`} |
| `pesoKg` | number | >0 e <400 |
| `alturaCm` | number | >=50 e <250 |
| `habitos` | array<ref:`/habitos/{habitoId}`> | 0..N |
| `acessoVenosoDificil` | boolean | `true`/`false` |
| `diagnosticos` | array<ref:`/revisaoSistemas/{itemId}`> | 0..N |
| `complicacoesAnestesicasPrevias` | array<ref:`/complicacoes/{complicacaoId}`> | 0..N |
| `antecedentesAnestesicos` | array<ref:`/procedimentos/{procedimentoId}`> | 0..N |
| `preditoresViaAereaDificil` | array<string> | Enum múltipla: {`Pendente (não avaliar em teleconsulta)`,`Impossível avaliar ou avaliação prejudicada`,`Pescoço curto`,`Pescoço largo`,`Retrognatismo`,`Extensão limitada`,`Outras alterações anatomicas indicando risco elevado de via aérea difícil`,`Mallampati III`,`Mallampati IV`} |
| `jejumSolidosGordura` | Timestamp \| string | Timestamp **ou** "NAO_ESTABELECIDO". |
| `jejumLiquidosClaros` | Timestamp \| string | Timestamp **ou** "NAO_ESTABELECIDO". |
| `exameFisicoComplementar` | array<string> | Lista de textos livres. |
| `observacoes` | string | Multilinhas. |
| `alergiasMedicamentosas` | array<ref:`/medicamentosCatalogo/{medicamentoId}`> | 0..N |
| `outrasAlergias` | string | Texto livre. |
| `anestesiaCombinada` | array<string> | Enum múltipla: {`Nada combinado no momento`,`Assistência clínica`,`Sedação consciente`,`Sedação profunda`,`Anestesia Geral`,`Anestesia subaracnoide`,`Anestesia Peridural`,`Plexo Braquial`,`Bloqueios de nervos periféricos`} |
| `orientacoesPaciente` | array<string> | Textos livres **ou** chaves de catálogo. |
| `dataCriacao` | Timestamp | Preenchido na criação (server time). |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `status` | string | `RASCUNHO`\|`ASSINADO`\|`INVALIDADO` |
| `dataAssinatura` | Timestamp \| null | Preenchido somente pelo backend. |
| `hashConteudo` | string \| null | SHA-256 calculado no momento da assinatura. |
| `hashAvaliacaoAnterior` | string \| null | SHA-256 do registro anterior. |
| `versaoAnteriorId` | string \| null | Link lógico para correção/versionamento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele. Avaliações assinadas são imutáveis.

**Subcoleções diretas da Avaliação:**
- `/medicamentos` (uso pelo paciente) — ver seção **Medicamentos (uso)**  
- `/riscos` — ver seção **Riscos**  
- `/exames` — ver seção **Exames complementares**

---

## Escala
**Coleção:** `/escalas/{escalaId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `nome` | string | *(opcional)* Nome descritivo da escala. |
| `dataInicio` | date (Timestamp) | Data de início da escala. |
| `dataFim` | date (Timestamp) | Data de término da escala. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

**Subcoleção:**
- `/escalas/{escalaId}/plantoes/{plantaoId}` — ver seção **Plantão**

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Plantão
**Subcoleção:** `/escalas/{escalaId}/plantoes/{plantaoId}`

> Também pode ser acessado diretamente via coleção raiz: `/plantoes/{plantaoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `usuario` | ref:`/usuarios/{usuarioId}` | Obrigatório. Referência ao usuário escalado. |
| `data` | date (Timestamp) | Obrigatório. Data do plantão (apenas data, sem hora). |
| `turnos` | array<string> | Enum múltipla: {`Manha`,`Tarde`,`Noite`}. Um ou mais turnos. |
| `posicao` | number | Obrigatório. Valor mínimo = 1, máximo = 20. Posição 1 = Coordenador. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Importante:** Posição = 1 indica o **Coordenador** do plantão. Posições > 1 são plantonistas regulares.

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Anestesista
**Subcoleção:** `/servicos/{servicoId}/anestesistas/{anestesistaId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `inicio` | Timestamp | Obrigatório. Data e hora de início da participação do anestesista. |
| `fim` | Timestamp | Data e hora de término da participação do anestesista. |
| `medico` | ref:`/usuarios/{usuarioId}` | Obrigatório. Referência ao usuário/médico anestesista. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Serviço
**Coleção:** `/servicos/{servicoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `procedimentos` | array<ref:`/procedimentos/{procedimentoId}`> | 0..N referências a **Procedimentos**. |
| `paciente` | ref:`/pacientes/{pacienteId}` | Obrigatório. Referência ao paciente. |
| `cirurgioes` | array<ref:`/medicos/{medicoId}`> | 0..N referências a **Médicos** cirurgiões. |
| `inicio` | Timestamp | Obrigatório. Data e hora prevista de início do serviço. |
| `duracao` | number | *(opcional)* Duração prevista em minutos. |
| `local` | string | Enum: {`Centro Cirúrgico`,`Endoscopia`,`Ressonancia magnética da Unidade IV`,`Ressonancia magnética da Unidade 3`,`Centro de oncologia`,`Tomografia da Unidade IV`,`Ultrassom Unidade IV`} |
| `leito` | string | Texto livre. Identificação do leito/sala. |
| `tcle` | string | Termo de Consentimento Livre e Esclarecido (texto ou referência). |
| `finalizado` | boolean | Enum: {`Sim` (true),`Não` (false)}. Indica se o serviço foi concluído. |
| `dataCriacao` | Timestamp | Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que criou o documento. |
| `ultimaModificacao` | Timestamp | Data e hora da última modificação. |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Usuário que realizou a última modificação. |

**Subcoleção:**
- `/servicos/{servicoId}/anestesistas/{anestesistaId}` — ver seção **Anestesista**

> **Nota:** Nunca apagar um item. Sempre usar a versão mais nova dele.

---

## Campos de auditoria

Todas as coleções do sistema devem incluir os seguintes campos de auditoria para rastreabilidade:

| Campo | Tipo | Descrição |
|---|---|---|
| `ultimaModificacao` | Timestamp | Data e hora da última modificação (usar `FieldValue.serverTimestamp()`). |
| `modificadoPor` | ref:`/usuarios/{usuarioId}` | Referência ao usuário que realizou a última modificação. |
| `dataCriacao` | Timestamp | *(recomendado)* Data e hora de criação do documento. |
| `criadoPor` | ref:`/usuarios/{usuarioId}` | *(recomendado)* Referência ao usuário que criou o documento. |

> **Política de versionamento:** Nunca apagar documentos. Sempre criar uma nova versão e manter histórico completo para auditoria e conformidade com SBIS/LGPD.

---

## Funcionalidades por tipo de usuário

### Todos os Usuários Autenticados

Todos os usuários têm acesso às seguintes funcionalidades:
- Visualizar serviços atribuídos a eles
- Atualizar status de serviços
- Registrar avaliações anestésicas
- Consultar informações de pacientes
- Visualizar escala de plantões
- **Acessar ferramenta de Distribuição de Serviços** (ver abaixo)

### Funcionalidade Especial: Distribuição de Serviços

> **Nota:** Por enquanto, disponível para todos. Pode ser restrita a coordenadores (posição = 1) futuramente.

Coordenadores tradicionalmente gerenciam a escala, mas a ferramenta está aberta a todos:

#### 1. Distribuição de Serviços
**Objetivo:** Atribuir plantonistas aos serviços programados do dia.

**Características:**
- **Data padrão:** Hoje (possível alterar para outras datas)
- **Interface otimizada para smartphones:** Visualização clara e intuitiva
- **Visualizações disponíveis:**
  - Lista de serviços sem atribuição
  - Tarefas/serviços de cada anestesista na data selecionada
  - Timeline visual com horários
  
**Funcionalidades:**
- **Atribuição de anestesista:** 
  - Ao selecionar um anestesista para um serviço, o sistema calcula automaticamente a hora prevista de término (início + duração)
  - Sistema verifica conflitos de horário com outros serviços já atribuídos ao mesmo anestesista
  - Em caso de conflito/sobreposição, exibe alerta informando o conflito e pergunta se deseja atribuir mesmo assim
  - Permite reatribuição de serviços entre anestesistas

**Validações automáticas:**
- Detecção de sobreposição de horários: 
  - Compara início + duração de cada serviço do anestesista
  - Verifica se novo serviço causará conflito temporal
  - Apresenta aviso visual claro sobre conflitos

**Regras de negócio:**
- Todos os usuários autenticados têm acesso à visualização e modificação
- Todas as alterações são auditadas (campos `ultimaModificacao` e `modificadoPor`)
- Sistema mantém histórico de atribuições para análise posterior
- Opcionalmente, pode-se restringir **modificações** apenas para coordenadores mantendo **visualização** para todos

**Implementação de Restrição (Opcional):**
```dart
// Na página, verificar se é coordenador
final podeModificar = await verificarSeCoordenador(usuarioId, data);

// Desabilitar botões de atribuição se !podeModificar
// Manter visualização sempre disponível
```

> **Nota:** Ferramentas adicionais para coordenadores serão documentadas posteriormente.

---

## Regras de segurança (sugestão)

### Gate corporativo (domínio obrigatório)
```javascript
match /{document=**} {
  allow read, write: if request.auth != null
    && (request.auth.token.email.matches('.*@sedanimed\\.br$') ||
        request.auth.token.email.matches('.*@sani\\.med\\.br$'));
}
```

### Pacientes (apenas médico autenticado com permissão)
> Sugere-se RBAC por *custom claims* (`roles: ['medico','admin']`).
```javascript
match /pacientes/{pacienteId} {
  allow read, write: if request.auth != null
    && ( 'admin' in request.auth.token.roles || 'medico' in request.auth.token.roles );
}
```

### Avaliação anestésica — imutabilidade após assinatura
```javascript
match /avaliacoesAnestesicas/{avaliacaoId} {
  function isAssinado() { return resource.data.dataAssinatura != null; }

  allow create: if request.auth != null;
  allow update: if request.auth != null && !isAssinado();
  allow delete: if false;
}
```

### Subcoleções com herança de permissão
```javascript
match /avaliacoesAnestesicas/{avaliacaoId}/medicamentos/{docId} {
  allow read, write: if request.auth != null;
}
match /avaliacoesAnestesicas/{avaliacaoId}/riscos/{docId} {
  allow read, write: if request.auth != null;
}
match /avaliacoesAnestesicas/{avaliacaoId}/exames/{docId} {
  allow read, write: if request.auth != null;
}
```

### Usuários
```javascript
match /usuarios/{usuarioId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 'admin' in request.auth.token.roles;
}
```

### Escalas e Plantões
```javascript
match /escalas/{escalaId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && isCoordenador();
}

match /escalas/{escalaId}/plantoes/{plantaoId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && isCoordenador();
}

match /plantoes/{plantaoId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && isCoordenador();
}

function isCoordenador() {
  // Verifica se o usuário é coordenador (posição = 1) na data atual
  return exists(/databases/$(database)/documents/plantoes/$(request.auth.uid)) 
    && get(/databases/$(database)/documents/plantoes/$(request.auth.uid)).data.posicao == 1;
}
```

### Serviços
```javascript
match /servicos/{servicoId} {
  allow read: if request.auth != null;
  allow create: if request.auth != null && ('admin' in request.auth.token.roles || isCoordenador());
  allow update: if request.auth != null;
  allow delete: if false; // Nunca permitir exclusão
}

match /servicos/{servicoId}/anestesistas/{anestesistaId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && (isCoordenador() || isAnestesistaNoServico(servicoId));
}

function isAnestesistaNoServico(servicoId) {
  // Verifica se o usuário está atribuído ao serviço
  return exists(/databases/$(database)/documents/servicos/$(servicoId)/anestesistas/$(request.auth.uid));
}
```

> **Importante:** 
> - Validar *schema* nas regras (ex.: faixas de `pesoKg`, `alturaCm`, enums) e mover toda assinatura/hashing para **Cloud Functions**.
> - Implementar campos de auditoria (`ultimaModificacao`, `modificadoPor`) automaticamente via Cloud Functions.
> - A função `isCoordenador()` deve ser refinada para verificar a data específica do plantão.
> - Nunca permitir exclusão física de documentos (delete: false).

---

## Índices recomendados
- `avaliacoesAnestesicas`: `pacienteId + dataCriacao (desc)`
- `avaliacoesAnestesicas`: `status + medicoResponsavelId`
- `pacientes`: `cpf` (unicidade lógica por Cloud Function e subcoleção `/cpf_index/{cpf}`)
- `medicos`: `crm + estadoCrm`
- `usuarios`: `email` (usado como ID do documento)
- `usuarios`: `funcaoAtual`
- `plantoes`: `data + posicao`
- `plantoes`: `usuario + data`
- `servicos`: `inicio + local`
- `servicos`: `inicio + finalizado`
- `servicos`: `paciente + inicio`
- `anestesistas` (subcoleção): `medico + inicio`
- `exames`: `tipo + dataExame` (índice composto na subcoleção, se necessário)

---

## Boas práticas de escrita
- **Server Timestamps**: sempre use `FieldValue.serverTimestamp()` para `dataCriacao`/`dataAssinatura`/`ultimaModificacao`.
- **Campos de Auditoria**: todas as coleções devem incluir `dataCriacao`, `criadoPor`, `ultimaModificacao` e `modificadoPor` para rastreabilidade e conformidade.
- **Política de Exclusão**: NUNCA apagar documentos. Sempre criar nova versão e manter histórico completo para auditoria SBIS/LGPD.
- **Normalização**: catálogos em coleções próprias (`procedimentos`, `especialidades`, `medicamentosCatalogo`, `ferramentasRisco`). Use `ref` nas avaliações.
- **Enums**: padronize valores (snake_case) para evitar variação de grafia.
- **Padrões de Jejum**: considere salvar também como **minutos restantes** calculados no backend para alertas.
- **Uploads**: anexos de exames via **Storage** com URLs assinadas e **rótulos de confidencialidade**.
- **LGPD**: minimizar dados pessoais na raiz das coleções; preferir `ref` e escopo por paciente quando necessário.
- **Controle de Acesso**: implementar verificação de posição no plantão (coordenador vs plantonista) para funcionalidades específicas.
