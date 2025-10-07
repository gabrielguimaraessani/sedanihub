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
- [Especialidades](#especialidades)
- [Procedimentos](#procedimentos)
- [Complicações](#complicações)
- [Hábitos](#hábitos)
- [Revisão de sistemas](#revisão-de-sistemas)
- [Medicamento / Medicamentos](#medicamento--medicamentos)
- [Riscos](#riscos)
- [Exames complementares](#exames-complementares)
- [Avaliação anestésica](#avaliação-anestésica)
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

**Subcoleções usuais (opcional):**
- `/pacientes/{pacienteId}/alergias` (se for necessário granularidade por item)

---

## Médicos
**Coleção:** `/medicos/{medicoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `nomeCompleto` | string | Obrigatório. |
| `crm` | string | Obrigatório. Usar string (mantém zeros à esquerda). |
| `estadoCrm` | string | Obrigatório. Sigla UF (`AC`..`TO`). |
| `especialidades` | array<ref:`/especialidades/{especialidadeId}`> | 0..N referências a **Especialidades**. |

---

## Especialidades
**Coleção:** `/especialidades/{especialidadeId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. Única por convenção. |

---

## Procedimentos
**Coleção:** `/procedimentos/{procedimentoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `codigoTuss` | string | *(opcional)* Código TUSS. |
| `porteAnestesico` | string | *(opcional)* Texto livre ou tabela controlada. |
| `especialidades` | array<ref:`/especialidades/{especialidadeId}`> | 0..N referências a **Especialidades**. |

---

## Complicações
**Coleção:** `/complicacoes/{complicacaoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `gravidade` | string | Enum: {`nenhuma`,`risco_potencial`,`dano_leve`,`dano_moderado`,`dano_grave`,`dano_catastrofico`} |
| `grupo` | string | *(opcional)* Texto livre (ex.: respiratória, cardiovascular). |

---

## Hábitos
**Coleção:** `/habitos/{habitoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Livre **ou** enum: {`tabagismo`,`etilismo`,`cocaina`,`cannabis_sativa`} |
| `frequencia` | string | *(opcional)* Texto livre. |
| `parouHaQuantoTempo` | string | *(opcional)* Texto livre. |

> Alternativa: transformar `descricao` em enum e colocar variações em `frequencia`/`tipo`/`detalhe`.

---

## Revisão de sistemas
**Coleção:** `/revisaoSistemas/{itemId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `sistema` | string | Enum: {`Cardiovascular`,`Respiratorio`,`GenitoUrinario`,`Endocrinologico`,`Hematopoetico`,`NervosoCentral`,`InfectoContagioso`,`Digestivo`,`OcularAuditivo`,`MusculoEsqueletico`,`Psiquiatrico`} |
| `diagnostico` | string | Texto livre. |
| `haQuantoTempo` | string | *(opcional)* Texto livre. |

---

## Medicamento / Medicamentos
### Medicamento (catálogo)
**Coleção:** `/medicamentosCatalogo/{medicamentoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `descricao` | string | Obrigatório. |
| `classes` | array<string> | *(opcional)* |
| `principiosAtivos` | array<string> | *(opcional)* |

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

---

## Riscos
**Subcoleção:** `/avaliacoesAnestesicas/{avaliacaoId}/riscos/{riscoId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `tipoFerramenta` | ref:`/ferramentasRisco/{ferramentaId}` | Obrigatório. |
| `parametros` | string | Texto livre. |
| `resultado` | string | Texto livre. |

*(Criar a coleção de catálogo)* **`/ferramentasRisco/{ferramentaId}`**: nome, referência bibliográfica, versão.

---

## Exames complementares
**Subcoleção:** `/avaliacoesAnestesicas/{avaliacaoId}/exames/{exameId}`

| Campo | Tipo | Restrições / Observações |
|---|---|---|
| `tipo` | string | Enum: {`Laboratorial`,`Imagem`} |
| `dataExame` | date (Timestamp) | *(opcional)* |
| `laudo` | string | *(opcional)* Texto livre. |
| `anexoArquivoUrl` | string | *(opcional)* URL GCS/Storage (assinado). |

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
| `status` | string | `RASCUNHO`\|`ASSINADO`\|`INVALIDADO` |
| `dataAssinatura` | Timestamp \| null | Preenchido somente pelo backend. |
| `hashConteudo` | string \| null | SHA-256 calculado no momento da assinatura. |
| `hashAvaliacaoAnterior` | string \| null | SHA-256 do registro anterior. |
| `versaoAnteriorId` | string \| null | Link lógico para correção/versionamento. |

**Subcoleções diretas da Avaliação:**
- `/medicamentos` (uso pelo paciente) — ver seção **Medicamentos (uso)**  
- `/riscos` — ver seção **Riscos**  
- `/exames` — ver seção **Exames complementares**

---

## Regras de segurança (sugestão)

### Gate corporativo (domínio obrigatório)
```javascript
match /{document=**} {
  allow read, write: if request.auth != null
    && request.auth.token.email.matches('.*@sedanimed\.br$');
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

> **Importante:** validar *schema* nas regras (ex.: faixas de `pesoKg`, `alturaCm`, enums) e mover toda assinatura/hashing para **Cloud Functions**.

---

## Índices recomendados
- `avaliacoesAnestesicas`: `pacienteId + dataCriacao (desc)`
- `avaliacoesAnestesicas`: `status + medicoResponsavelId`
- `pacientes`: `cpf` (unicidade lógica por Cloud Function e subcoleção `/cpf_index/{cpf}`)
- `medicos`: `crm + estadoCrm`
- `exames`: `tipo + dataExame` (índice composto na subcoleção, se necessário)

---

## Boas práticas de escrita
- **Server Timestamps**: sempre use `FieldValue.serverTimestamp()` para `dataCriacao`/`dataAssinatura`.
- **Normalização**: catálogos em coleções próprias (`procedimentos`, `especialidades`, `medicamentosCatalogo`, `ferramentasRisco`). Use `ref` nas avaliações.
- **Enums**: padronize valores (snake_case) para evitar variação de grafia.
- **Padrões de Jejum**: considere salvar também como **minutos restantes** calculados no backend para alertas.
- **Uploads**: anexos de exames via **Storage** com URLs assinadas e **rótulos de confidencialidade**.
- **LGPD**: minimizar dados pessoais na raiz das coleções; preferir `ref` e escopo por paciente quando necessário.
