# Sistema de Gestão Financeira com Machine Learning

Sistema completo de gestão financeira pessoal desenvolvido como Trabalho de Conclusão de Curso (TCC), incluindo aplicativo móvel Flutter e backend FastAPI com funcionalidades de Machine Learning para análise preditiva e alertas inteligentes.

## Tecnologias Utilizadas

### Backend
- **Python 3.11**
- **FastAPI** - Framework web moderno e rápido
- **SQLAlchemy** - ORM para PostgreSQL
- **PostgreSQL** - Banco de dados relacional
- **Pydantic** - Validação de dados
- **Machine Learning** - Análise preditiva e alertas inteligentes

### Frontend
- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **HTTP** - Comunicação com API

## Funcionalidades

### Gestão Financeira
- Cadastro e autenticação de usuários
- Gerenciamento de transações (receitas e despesas)
- Categorização automática de transações
- Múltiplas contas bancárias
- Definição e acompanhamento de metas financeiras
- Orçamentos por categoria

### Machine Learning e Inteligência Artificial
- **Previsão de Gastos**: Análise de histórico para prever gastos futuros
- **Alertas Inteligentes**: 
  - Gasto acima da média
  - Saldo baixo
  - Metas em risco
- **Análise de Tendências**: Identificação de padrões crescentes, decrescentes ou estáveis
- **Insights Personalizados**: Recomendações baseadas no comportamento financeiro
- **Dashboard ML**: Visão consolidada de previsões e alertas

### Relatórios
- Resumo de receitas e despesas por período
- Despesas por categoria com visualização gráfica
- Análise de consumo detalhada
- Histórico de análises de ML

## Estrutura do Projeto

```
.
├── backend_financeiro/          # Backend FastAPI
│   ├── app/
│   │   ├── models/             # Modelos SQLAlchemy e Schemas Pydantic
│   │   ├── routes/             # Rotas da API
│   │   └── services/           # Serviços de autenticação
│   ├── ml_service.py           # Serviço de Machine Learning
│   ├── main.py                 # Ponto de entrada da aplicação
│   └── requirements.txt        # Dependências Python
│
├── app_financeiro_flutter/      # App Flutter
│   ├── lib/
│   │   ├── core/               # Configurações e serviços
│   │   ├── models/             # Modelos de dados
│   │   ├── providers/          # Gerenciamento de estado
│   │   ├── screens/            # Telas do aplicativo
│   │   │   ├── auth/           # Autenticação
│   │   │   ├── home/           # Tela principal
│   │   │   ├── transacoes/     # Gerenciamento de transações
│   │   │   ├── relatorios/     # Relatórios
│   │   │   ├── metas/          # Metas financeiras
│   │   │   └── insights/       # Insights de ML
│   │   └── services/           # Serviços de API
│   └── pubspec.yaml            # Dependências Flutter
│
└── database/                    # Scripts SQL
    ├── 001_create_tables.sql   # Criação de tabelas
    └── 002_insert_data.sql     # Dados iniciais
```

## Instalação e Configuração

### Pré-requisitos

- Python 3.11+
- PostgreSQL 12+
- Flutter 3.0+
- Git

### 1. Configurar Banco de Dados

```bash
# Criar banco de dados
createdb app_financeiro

# Criar usuário
psql -c "CREATE USER app_user WITH PASSWORD '123';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE app_financeiro TO app_user;"

# Executar scripts SQL
psql -U app_user -d app_financeiro -f database/001_create_tables.sql
psql -U app_user -d app_financeiro -f database/002_insert_data.sql
```

### 2. Configurar Backend

```bash
cd backend_financeiro

# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # No Windows: venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt

# Iniciar servidor
python main.py
```

O backend estará disponível em `http://127.0.0.1:8000`

Documentação da API: `http://127.0.0.1:8000/docs`

### 3. Configurar Flutter

```bash
cd app_financeiro_flutter

# Instalar dependências
flutter pub get

# Executar aplicativo
flutter run
```

## Endpoints da API

### Autenticação
- `POST /api/auth/login` - Login de usuário
- `POST /api/auth/register` - Registro de novo usuário

### Transações
- `GET /api/transacoes` - Listar transações
- `POST /api/transacoes` - Criar transação
- `PUT /api/transacoes/{id}` - Atualizar transação
- `DELETE /api/transacoes/{id}` - Deletar transação

### Categorias
- `GET /api/categorias` - Listar categorias

### Machine Learning
- `GET /ml/previsoes` - Obter previsões de gastos
- `GET /ml/alertas` - Obter alertas inteligentes
- `GET /ml/dashboard` - Dashboard consolidado de ML
- `GET /ml/historico-analises` - Histórico de análises

## Funcionalidades de Machine Learning

### Previsão de Gastos

O sistema analisa o histórico de transações dos últimos 90 dias para:
- Prever gastos totais dos próximos 30 dias
- Calcular confiança da previsão (0-100%)
- Identificar tendências (crescente, decrescente, estável)
- Prever gastos por categoria

### Alertas Inteligentes

**Gasto Acima da Média**
- Detecta quando gastos do mês atual excedem significativamente a média histórica
- Severidade baseada no percentual de diferença

**Saldo Baixo**
- Compara saldo total com gastos previstos
- Alerta quando saldo é insuficiente para cobrir despesas previstas

**Metas em Risco**
- Identifica metas difíceis de atingir
- Calcula economia diária necessária vs capacidade estimada

## Credenciais Padrão

**Usuário de teste:**
- Email: `teste@exemplo.com`
- Senha: `senha123`

**Banco de dados:**
- Usuário: `app_user`
- Senha: `123`
- Database: `app_financeiro`

## Desenvolvimento

### Estrutura de Commits

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `refactor:` Refatoração de código
- `test:` Testes

### Testes

```bash
# Backend
cd backend_financeiro
pytest

# Flutter
cd app_financeiro_flutter
flutter test
```

## Licença

Este projeto foi desenvolvido como Trabalho de Conclusão de Curso (TCC).

## Autores

Desenvolvido como projeto acadêmico.

## Agradecimentos

- Orientadores e professores
- Comunidade Flutter e FastAPI
- Bibliotecas e frameworks open source utilizados

