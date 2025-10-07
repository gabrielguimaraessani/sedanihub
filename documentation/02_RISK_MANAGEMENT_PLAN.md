# ⚠️ Plano de Gestão de Riscos — SedaNiHub

## 1. Objetivo
Estabelecer diretrizes para identificação, avaliação, tratamento e monitoramento de riscos de segurança, privacidade e uso clínico.

## 2. Metodologia
A gestão de riscos seguirá:
- **ISO 31000:2018** — Gestão de Riscos
- **ISO/IEC 27005** — Riscos de Segurança da Informação
- **ISO 14971** — Aplicável a software de saúde

## 3. Categorias de Risco
| Categoria | Exemplo | Controle Associado |
|------------|----------|--------------------|
| Segurança da informação | Acesso não autorizado a registros | RBAC + 2FA + logs imutáveis |
| Privacidade (LGPD/HIPAA) | Vazamento de dados sensíveis | Criptografia e segregação |
| Confiabilidade clínica | Perda de dados médicos | Backups diários + PITR |
| Integridade técnica | Alteração indevida de registros | Ledger criptográfico |
| Continuidade de serviço | Interrupção do Firebase | DR e redundância |

## 4. Processo de Tratamento
1. Identificação do risco  
2. Análise de probabilidade e impacto  
3. Adoção de medidas preventivas e corretivas  
4. Revisão semestral dos controles

## 5. Responsabilidades
- **DPO (Encarregado LGPD)**: coordenação de riscos de privacidade  
- **TI SedaNiMed**: implementação de controles técnicos  
- **Gestão clínica**: revisão de riscos operacionais e éticos

## 6. Evidências
- Matriz de riscos documentada  
- Registro de revisões trimestrais  
- Logs de incidentes e lições aprendidas
