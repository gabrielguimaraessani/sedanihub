# 🧭 Escopo e Contexto do Sistema — SedaNiHub

## 1. Propósito
Descrever o escopo, o propósito clínico e os limites do sistema SedaNiHub, assegurando alinhamento com normas de software em saúde (ABNT NBR IEC 82304-1) e gestão da segurança da informação (ABNT NBR ISO/IEC 27001).

## 2. Contexto Organizacional
- **Organização:** SedaNiMed – Serviço de Anestesiologia Integrada  
- **Responsável técnico:** Gabriel Magalhães Nunes Guimarães, médico anestesiologista  
- **Domínio operacional:** @sedanimed.br  
- **Ambiente tecnológico:** Flutter (frontend), Firebase + Google Cloud (backend)

## 3. Escopo do Sistema
O SedaNiHub é uma plataforma corporativa voltada à gestão e registro de informações clínicas e administrativas de anestesiologistas, incluindo:
- Registro e consulta de dados clínicos (prontuário eletrônico)
- Comunicação segura e rastreável entre médico e sistema
- Armazenamento de dados de saúde com logs imutáveis

## 4. Partes Interessadas
| Grupo | Função | Responsabilidade |
|--------|--------|------------------|
| Usuários médicos | Inserção e assinatura de dados clínicos | Uso e validação dos registros |
| TI / Dev | Manutenção e monitoramento da segurança | Implementação de controles |
| Gestão | Definição de políticas de acesso e auditoria | Governança e compliance |
| Pacientes | Titulares de dados pessoais e sensíveis | Consentimento e direitos LGPD |

## 5. Escopo da Segurança
O SGSI (Sistema de Gestão de Segurança da Informação) abrange:
- Todos os dados armazenados e processados no Firestore
- Credenciais de usuários e logs de auditoria
- Ambientes de desenvolvimento, homologação e produção

## 6. Referências Normativas
- ABNT NBR ISO/IEC 27001:2022 (§4.1–4.3)
- ABNT NBR IEC 82304-1:2024 (§1)
- LGPD (Lei 13.709/2018)
- HIPAA (45 CFR Part 164)
