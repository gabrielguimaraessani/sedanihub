# 📝 Modelo de Dados: Avaliações Anestésicas (Ledger Imutável)

Este documento define a estrutura e as regras de segurança para a coleção de avaliações anestésicas, garantindo a integridade dos dados e o rastro de auditoria conforme exigido por normas como a SBIS.

---

## 1. Coleção Principal: `avaliacoesAnestesicas`

Cada documento nesta coleção representa uma **Avaliação/Consulta Única e Imutável**, que se encadeia criptograficamente com as anteriores para formar uma cadeia de auditoria (Ledger Imutável).

* **Localização:** `/avaliacoesAnestesicas/{avaliacaoId}`
* **Nomenclatura:** Adota o padrão `camelCase` e nomes específicos ao contexto de anestesia (melhorando a clareza para a equipe clínica).

### Campos de Rastreabilidade e Integridade (Criptográfica)

| Campo | Tipo de Dado | Finalidade para Auditoria e Segurança (SBIS) |
| :--- | :--- | :--- |
| **`dataAssinatura`** | Timestamp | Data e hora em que o registro foi finalizado e assinado. **O campo é a trava de imutabilidade.** |
| **`status`** | String | 'RASCUNHO', **'ASSINADO'**, 'INVALIDADO'. |
| **`hashConteudo`** | String (SHA-256) | **Integridade do Documento:** Hash criptográfico do conteúdo completo da avaliação. Gerado apenas pelo Cloud Function no momento da assinatura. |
| **`hashAvaliacaoAnterior`** | String (SHA-256) | **Integridade da Cadeia:** Hash (`hashConteudo`) do último documento inserido na coleção. **Detecta qualquer exclusão ou adulteração na sequência.** |
| **`versaoAnteriorId`** | String / Null | Relação lógica: ID do documento que este registro está "substituindo" ou corrigindo. |

### Campos de Metadados e Acesso

| Campo | Tipo de Dado | Detalhes |
| :--- | :--- | :--- |
| **`pacienteId`** | String | UID do paciente (para vincular ao registro em `/usuarios`). |
| **`medicoResponsavelId`** | String | UID do anestesiologista que realizou e assinou. |
| **`dataCriacao`** | Timestamp | Data e hora em que o documento foi iniciado (rascunho). |

### Campo de Dados Clínicos (Dados de Anestesia)

O campo `dadosClinicos` é um objeto/mapa que contém a estrutura de dados clínicos essenciais no contexto da anestesia.

| Campo (dentro de `dadosClinicos`) | Tipo de Dado | Equivalente Clínico / Notas |
| :--- | :--- | :--- |
| **`anamnesePreOp`** | String | Histórico e avaliação inicial do paciente. |
| **`riscoASA`** | String | Classificação de Risco Físico da ASA (American Society of Anesthesiologists). |
| **`condutaProposta`** | String | O plano de anestesia e a medicação proposta. |
| **`medicamentosUsados`** | Array/Map | Lista de medicamentos administrados (detalhes de dose/tempo). |
| **`complicacoes`** | String | Descrição de intercorrências ou observações relevantes. |

---

## 2. Regras de Imutabilidade e Fluxo de Auditoria

### A. Mecanismos de Segurança (Regras do Firestore)

1.  **Imutabilidade (Anti-Edição):**
    * A atualização de qualquer campo de dados é permitida **SOMENTE** se o campo `dataAssinatura` for `null`. Uma vez preenchido, o registro é considerado finalizado e não pode ser editado.
2.  **Imutabilidade (Anti-Exclusão):**
    * A operação de **`delete`** deve ser **proibida (if false)** a partir de qualquer cliente ou usuário nas Regras de Segurança. Isso impede a quebra da cadeia de hash.
3.  **Integridade do Hash:**
    * O campo `hashConteudo` não pode ser alterado após a sua primeira definição, garantindo que o registro assinado não possa ser adulterado.

### B. Fluxo de Trabalho (Cloud Functions - Backend)

O Cloud Function (ou outro backend seguro) é o **único responsável** por escrever documentos com `dataAssinatura` preenchida e os campos de hash.

| Ação do Usuário | Processo no Backend (Cloud Function) |
| :--- | :--- |
| **Assinar Avaliação (Novo Registro)** | 1. Lê o `hashConteudo` da última avaliação na coleção. 2. Calcula o `hashConteudo` da nova avaliação. 3. Escreve o novo documento, preenchendo `dataAssinatura`, `hashConteudo` e `hashAvaliacaoAnterior` (com o hash lido na etapa 1). |
| **Corrigir Avaliação (Nova Versão)** | 1. Cria um novo documento (Nova Avaliação). 2. Preenche o `versaoAnteriorId` com o ID da avaliação anterior. 3. Repete o processo de assinatura, garantindo a rastreabilidade e a integridade da cadeia de hash. |