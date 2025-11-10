# Banco de Dados - Aplicativo Financeiro

## Visão Geral

Este diretório contém todos os scripts SQL necessários para criar e configurar o banco de dados PostgreSQL do aplicativo de gerenciamento financeiro pessoal.

## Pré-requisitos

- PostgreSQL 12 ou superior
- pgAdmin 4 (opcional, para gerenciamento visual)
- Permissões de superusuário para criar banco de dados

## Estrutura de Arquivos

```
database/
├── README.md                    # Este arquivo
├── 001_create_tables.sql        # Criação de tabelas e índices
├── 002_create_triggers.sql      # Triggers e funções
└── 003_seed_data.sql            # Dados iniciais (categorias e usuário teste)
```

## Instalação do PostgreSQL

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Windows

Baixe o instalador em: https://www.postgresql.org/download/windows/

### macOS

```bash
brew install postgresql
brew services start postgresql
```

## Configuração Inicial

### 1. Acessar o PostgreSQL

```bash
sudo -u postgres psql
```

### 2. Criar o Banco de Dados

```sql
CREATE DATABASE app_financeiro;
```

### 3. Criar Usuário (Opcional)

```sql
CREATE USER app_user WITH ENCRYPTED PASSWORD 'sua_senha_segura';
GRANT ALL PRIVILEGES ON DATABASE app_financeiro TO app_user;
```

### 4. Conectar ao Banco de Dados

```sql
\c app_financeiro
```

## Executar Scripts SQL

### Método 1: Via psql (Linha de Comando)

```bash
# Conectar ao banco de dados
psql -U postgres -d app_financeiro

# Executar scripts na ordem
\i 001_create_tables.sql
\i 002_create_triggers.sql
\i 003_seed_data.sql
```

### Método 2: Via arquivo único

```bash
cd database
psql -U postgres -d app_financeiro -f 001_create_tables.sql
psql -U postgres -d app_financeiro -f 002_create_triggers.sql
psql -U postgres -d app_financeiro -f 003_seed_data.sql
```

### Método 3: Via pgAdmin

1. Abra o pgAdmin
2. Conecte-se ao servidor PostgreSQL
3. Clique com botão direito no banco `app_financeiro`
4. Selecione "Query Tool"
5. Abra cada arquivo SQL (File > Open)
6. Execute na ordem: 001, 002, 003

## Verificação da Instalação

### Verificar tabelas criadas

```sql
\dt
```

Deve listar todas as tabelas:
- usuario
- categoria
- conta_bancaria
- transacao
- meta
- orcamento
- orcamento_categoria
- notificacao
- analise_consumo
- configuracao_usuario
- transferencia

### Verificar views criadas

```sql
\dv
```

Deve listar:
- v_resumo_mensal
- v_gastos_categoria
- v_progresso_metas
- v_saldo_contas
- v_status_orcamento

### Verificar funções criadas

```sql
\df
```

### Verificar triggers

```sql
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_schema = 'public';
```

### Verificar dados iniciais

```sql
-- Contar categorias padrão
SELECT COUNT(*) FROM categoria WHERE usuario_id IS NULL;

-- Verificar usuário teste
SELECT * FROM usuario WHERE email = 'teste@exemplo.com';
```

## Configuração de Conexão

### String de Conexão

```
postgresql://usuario:senha@localhost:5432/app_financeiro
```

### Variáveis de Ambiente (Recomendado)

Crie um arquivo `.env` no backend:

```env
DATABASE_URL=postgresql://app_user:sua_senha@localhost:5432/app_financeiro
DB_HOST=localhost
DB_PORT=5432
DB_NAME=app_financeiro
DB_USER=app_user
DB_PASSWORD=sua_senha
```

## Estrutura do Banco de Dados

### Tabelas Principais

| Tabela | Descrição |
|--------|-----------|
| usuario | Dados dos usuários |
| categoria | Categorias de transações |
| conta_bancaria | Contas e carteiras |
| transacao | Receitas e despesas |
| meta | Metas financeiras |
| orcamento | Orçamentos mensais |
| notificacao | Notificações do sistema |
| analise_consumo | Análises de ML |

### Relacionamentos

- Um usuário possui múltiplas contas, transações, metas e orçamentos
- Uma transação pertence a uma categoria e uma conta
- Um orçamento pode ter limites para múltiplas categorias
- Análises são geradas por usuário e período

## Triggers Automáticos

### Atualização de Saldos

Quando uma transação é criada, atualizada ou deletada, o saldo da conta é automaticamente atualizado.

### Atualização de Orçamentos

Quando uma despesa é registrada, o valor gasto no orçamento do mês é atualizado automaticamente.

### Alertas de Orçamento

Quando o gasto em uma categoria atinge o percentual de alerta (padrão 80%), uma notificação é criada.

### Progresso de Metas

Quando uma receita é registrada, o progresso das metas ativas é atualizado.

### Configuração Padrão

Quando um usuário é criado, suas configurações padrão são criadas automaticamente.

## Funções Úteis

### Calcular totais

```sql
-- Total de receitas em um período
SELECT total_receitas(1, '2025-01-01', '2025-01-31');

-- Total de despesas em um período
SELECT total_despesas(1, '2025-01-01', '2025-01-31');

-- Saldo em um período
SELECT saldo_periodo(1, '2025-01-01', '2025-01-31');
```

### Percentual de meta

```sql
SELECT calcular_percentual_meta(1);
```

## Consultas Úteis

### Dashboard do usuário

```sql
SELECT * FROM v_resumo_mensal 
WHERE usuario_id = 1 
ORDER BY ano DESC, mes DESC 
LIMIT 12;
```

### Gastos por categoria no mês

```sql
SELECT * FROM v_gastos_categoria
WHERE usuario_id = 1 
  AND ano = 2025 
  AND mes = 1
ORDER BY total DESC;
```

### Status das metas

```sql
SELECT * FROM v_progresso_metas
WHERE usuario_id = 1
ORDER BY prioridade DESC;
```

### Status do orçamento atual

```sql
SELECT * FROM v_status_orcamento
WHERE usuario_id = 1
  AND mes = EXTRACT(MONTH FROM CURRENT_DATE)
  AND ano = EXTRACT(YEAR FROM CURRENT_DATE);
```

## Backup e Restauração

### Criar backup

```bash
pg_dump -U postgres app_financeiro > backup_$(date +%Y%m%d).sql
```

### Restaurar backup

```bash
psql -U postgres app_financeiro < backup_20250113.sql
```

### Backup automático (cron)

```bash
# Adicionar ao crontab
0 2 * * * pg_dump -U postgres app_financeiro > /backups/app_financeiro_$(date +\%Y\%m\%d).sql
```

## Manutenção

### Limpar dados antigos

```sql
-- Deletar notificações lidas com mais de 30 dias
DELETE FROM notificacao 
WHERE lida = TRUE 
  AND data_leitura < CURRENT_DATE - INTERVAL '30 days';

-- Deletar análises antigas (mais de 1 ano)
DELETE FROM analise_consumo 
WHERE data_criacao < CURRENT_DATE - INTERVAL '1 year';
```

### Reindexar tabelas

```sql
REINDEX TABLE transacao;
REINDEX TABLE usuario;
```

### Analisar performance

```sql
ANALYZE transacao;
EXPLAIN ANALYZE SELECT * FROM transacao WHERE usuario_id = 1;
```

## Segurança

### Recomendações

1. **Nunca** use o usuário `postgres` em produção
2. Crie usuários específicos com permissões limitadas
3. Use senhas fortes e complexas
4. Habilite SSL para conexões remotas
5. Configure firewall para permitir apenas IPs confiáveis
6. Faça backups regulares
7. Mantenha o PostgreSQL atualizado

### Configurar SSL (Produção)

Edite `postgresql.conf`:

```
ssl = on
ssl_cert_file = '/path/to/server.crt'
ssl_key_file = '/path/to/server.key'
```

### Configurar pg_hba.conf

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
host    app_financeiro  app_user        127.0.0.1/32           md5
host    app_financeiro  app_user        ::1/128                md5
```

## Troubleshooting

### Erro de permissão

```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;
```

### Resetar sequências

```sql
SELECT setval('usuario_id_seq', (SELECT MAX(id) FROM usuario));
SELECT setval('transacao_id_seq', (SELECT MAX(id) FROM transacao));
```

### Ver conexões ativas

```sql
SELECT * FROM pg_stat_activity WHERE datname = 'app_financeiro';
```

### Encerrar conexões

```sql
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'app_financeiro' AND pid <> pg_backend_pid();
```

## Suporte

Para problemas ou dúvidas:
- Documentação PostgreSQL: https://www.postgresql.org/docs/
- pgAdmin: https://www.pgadmin.org/docs/

