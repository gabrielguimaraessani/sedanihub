# 🔐 Plano de Arquitetura de Segurança — SedaNiHub

## 1. Princípios Gerais
- Princípio do menor privilégio  
- Zero Trust Architecture  
- Segregação de funções  
- Criptografia ponta a ponta  

## 2. Autenticação e Autorização
- Firebase Authentication com 2FA  
- Domínio corporativo obrigatório (@sedanimed.br)  
- Tokens JWT com expiração curta  
- Sessões monitoradas via Cloud Logging  

## 3. Armazenamento Seguro
- Cloud Firestore (região southamerica-east1)  
- Regras de segurança baseadas em identidade  
- Validação de schema nas regras (`match /usuarios/{userId}/prontuarios/{docId}`)  

## 4. Criptografia
- **Em trânsito:** TLS 1.3  
- **Em repouso:** AES-256 (GCP-managed keys)  
- **Hashes:** SHA-256 (ledger clínico)  

## 5. Logs e Auditoria
- Cloud Logging para todas as operações CRUD  
- Ledger imutável em avaliações anestésicas  
- Retenção mínima: 10 anos (SBIS v5.2 §5.1.3)

## 6. Resposta a Incidentes
- Canal direto com TI SedaNiMed  
- Classificação de incidentes em 4 níveis  
- Comunicação ao DPO e à ANPD quando aplicável (LGPD Art. 48)
