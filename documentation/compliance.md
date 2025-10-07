# 🔒 Compliance e Segurança de Dados (Cloud Firestore/Firebase)

Este documento formaliza as decisões de arquitetura e segurança tomadas para garantir a conformidade regulatória e a proteção de dados da aplicação, com foco em padrões como SBIS e LGPD.

---

## 1. Escolha do Banco de Dados e Nível Gratuito

**Decisão:** Utilização do **Cloud Firestore** no **Spark Plan (Nível Gratuito)**.

### Racional
* **Escalabilidade e Complexidade:** O Firestore oferece o modelo de dados de Coleções/Documentos, ideal para lidar com a complexidade de dados de saúde (prontuários, agendamentos, etc.) e escalável para crescimento futuro.
* **Custo:** Para um volume inicial de 7-12 usuários pouco ativos por dia, o uso permanecerá *abaixo* dos limites do Nível Gratuito (**50.000 leituras/dia**, **20.000 escritas/dia**, **1 GiB de armazenamento**), garantindo custo zero na fase de desenvolvimento e MVP.
* **Disponibilidade:** Será configurado o **Blaze Plan (Pago por Uso)** com **alertas de orçamento** para evitar a interrupção do serviço em caso de pico de tráfego, garantindo a continuidade do acesso ao sistema (exigência de DR/continuidade).

---

## 2. Conformidade e Localização de Dados

| Padrão | Requisito de Compliance | Implementação / Ação de Planejamento |
| :--- | :--- | :--- |
| **LGPD** | Soberania e proteção de dados pessoais (dados de saúde são dados sensíveis). | **Localização de Dados (Data Locality):** O Cloud Firestore será provisionado na região **southamerica-east1 (São Paulo)** ou outra região estratégica para garantir que o armazenamento primário ocorra o mais próximo possível dos usuários e em jurisdição compatível. |
| **SBIS/Rastreabilidade** | Exigência de logs de auditoria detalhados e imutáveis para operações em prontuários eletrônicos. | **Cloud Logging:** Todas as operações críticas de CRUD (Create, Read, Update, Delete) no Firestore serão rastreadas via **Cloud Logging**. A arquitetura garantirá que as operações mais sensíveis passem pelo backend (Cloud Functions) para registro completo de quem, o que e quando foi acessado. |

---

## 3. Segurança do Banco de Dados (Principal Linha de Defesa)

### 3.1. Regras de Segurança do Firestore

A segurança será implementada usando o **Princípio do Menor Privilégio**.

* **Proibição de Acesso Aberto:** A regra de segurança padrão (`allow read, write: if false;`) será aplicada, e as permissões serão concedidas explicitamente.
* **Controle de Acesso por Usuário:** Um usuário (`$uid`) só poderá ler, escrever ou atualizar documentos em sua própria coleção, como:
    ```
    match /usuarios/{userId}/prontuarios/{documentId} {
      allow read, write: if request.auth.uid == userId;
    }
    ```
* **Validação de Schema/Dados:** As regras de segurança serão usadas para validar o *formato e o tipo* dos dados antes da escrita, evitando a inserção de dados maliciosos ou incorretos.

### 3.2. Autenticação (Firebase Authentication)

* **Identidade Forte:** A autenticação de usuários será configurada para suportar **Autenticação de Dois Fatores (2FA)** para todos os profissionais de saúde e usuários com acesso a dados sensíveis.
* **Gerenciamento de Sessão:** O Firebase Auth é utilizado para gerenciar tokens de sessão seguros e com validade controlada.

### 3.3. Criptografia

* **Criptografia em Trânsito:** Todo o tráfego de dados entre o cliente (aplicativo) e o Firestore é criptografado por padrão usando **TLS/HTTPS**.
* **Criptografia em Repouso:** Os dados armazenados no Cloud Firestore são **criptografados automaticamente** pelo Google Cloud Platform (GCP) sem a necessidade de intervenção do desenvolvedor.

---

## 4. Arquitetura de Processamento e Recuperação

### 4.1. Lógica de Negócios (Backend)

* **Mover Lógica Sensível para o Servidor:** Toda a lógica de negócios que envolve validação de dados sensíveis, cálculos críticos e emissão de logs de auditoria **será executada em Cloud Functions (Firebase Functions)**.
* **Vantagem de Segurança:** Isso garante que o código do cliente não exponha chaves secretas ou lógica crítica, além de permitir uma única fonte de verdade para a escrita de dados no Firestore.

### 4.2. Plano de Recuperação de Desastres (DR - Disaster Recovery)

* **Backups:** Serão implementados **Backups Gerenciados** usando a funcionalidade de **Exportação de Dados** do Firestore para um bucket do Cloud Storage.
* **Frequência:** Os backups serão configurados com frequência diária para atender aos requisitos de retenção de dados de saúde.
* **Recuperação (PITR):** O recurso **Point-in-Time Recovery (PITR)** será avaliado e ativado, se necessário, para permitir a recuperação de dados em um momento exato no passado, crucial para correções rápidas de erros humanos (disponível no plano Blaze).