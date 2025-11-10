## Backend - API Financeiro

API REST desenvolvida com FastAPI para gerenciamento financeiro pessoal com análise de dados e machine learning.

## Tecnologias Utilizadas

- **FastAPI**: Framework web moderno e rápido
- **SQLAlchemy**: ORM para banco de dados
- **PostgreSQL**: Banco de dados relacional
- **Pydantic**: Validação de dados
- **JWT**: Autenticação
- **Pandas**: Manipulação de dados
- **Scikit-learn**: Machine Learning
- **NumPy**: Computação numérica

## Pré-requisitos

- Python 3.11+
- PostgreSQL 12+
- pip

## Instalação

### 1. Criar ambiente virtual

```bash
python3.11 -m venv venv
source venv/bin/activate
```

### 2. Instalar dependências

```bash
pip install -r requirements.txt
```

### 3. Configurar variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
DATABASE_URL=postgresql://app_user:sua_senha@localhost:5432/app_financeiro
SECRET_KEY=sua_chave_secreta_super_segura_aqui
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### 4. Configurar banco de dados

Execute os scripts SQL na pasta `database/`:

```bash
psql -U postgres -d app_financeiro -f ../database/001_create_tables.sql
psql -U postgres -d app_financeiro -f ../database/002_create_triggers.sql
psql -U postgres -d app_financeiro -f ../database/003_seed_data.sql
```

## Executar o Servidor

### Desenvolvimento

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Produção

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Documentação da API

Após iniciar o servidor, acesse:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## Estrutura do Projeto

```
backend_financeiro/
├── main.py                      # Aplicação principal FastAPI
├── requirements.txt             # Dependências Python
├── .env                         # Variáveis de ambiente (não versionado)
├── app/
│   ├── config.py                # Configurações da aplicação
│   ├── database.py              # Configuração do banco de dados
│   ├── models/
│   │   ├── models.py            # Modelos SQLAlchemy
│   │   └── schemas.py           # Schemas Pydantic
│   ├── services/
│   │   └── auth.py              # Serviço de autenticação
│   ├── ml/
│   │   ├── analise_padroes.py   # Análise de padrões de consumo
│   │   └── previsao_gastos.py   # Previsão de gastos
│   └── utils/
└── tests/
```

## Endpoints Principais

### Autenticação

```
POST   /api/auth/register        # Registrar novo usuário
POST   /api/auth/login           # Login
GET    /api/usuarios/me          # Dados do usuário atual
```

### Transações

```
GET    /api/transacoes           # Listar transações
POST   /api/transacoes           # Criar transação
GET    /api/transacoes/{id}      # Obter transação
PUT    /api/transacoes/{id}      # Atualizar transação
DELETE /api/transacoes/{id}      # Deletar transação
```

### Categorias

```
GET    /api/categorias           # Listar categorias
POST   /api/categorias           # Criar categoria
```

### Análises

```
GET    /api/analises/padroes     # Análise de padrões de consumo
GET    /api/analises/anomalias   # Detecção de anomalias
GET    /api/analises/tendencias  # Análise de tendências
GET    /api/analises/previsoes   # Previsão de gastos
```

### Relatórios

```
GET    /api/relatorios/dashboard # Dados do dashboard
```

## Funcionalidades de Machine Learning

### 1. Análise de Padrões de Consumo

Analisa os gastos do usuário por categoria, identificando:
- Categorias com maior gasto
- Percentual de cada categoria no total
- Média e quantidade de transações por categoria

**Endpoint**: `GET /api/analises/padroes?periodo_dias=30`

### 2. Detecção de Anomalias

Identifica transações com valores significativamente acima da média usando análise estatística:
- Calcula média e desvio padrão por categoria
- Detecta valores acima de 2 desvios padrões
- Retorna lista de transações anômalas

**Endpoint**: `GET /api/analises/anomalias?periodo_dias=90`

### 3. Análise de Tendências

Analisa a evolução de receitas e despesas ao longo do tempo:
- Compara primeira e segunda metade do período
- Identifica tendências crescentes, decrescentes ou estáveis
- Calcula variação percentual

**Endpoint**: `GET /api/analises/tendencias?periodo_meses=6`

### 4. Previsão de Gastos

Prevê gastos futuros usando regressão linear:
- Analisa histórico mensal
- Aplica modelo de regressão linear
- Retorna previsão com score de confiança
- Identifica sazonalidade nos gastos

**Endpoint**: `GET /api/analises/previsoes`

### 5. Geração de Insights

Gera insights personalizados baseados nos dados do usuário:
- Identifica categorias com gastos elevados
- Calcula taxa de poupança
- Alerta sobre anomalias
- Notifica sobre tendências preocupantes

### 6. Recomendações Inteligentes

Fornece recomendações personalizadas:
- Sugestões de redução de gastos
- Metas de poupança
- Revisão de gastos recorrentes
- Otimização de orçamento

## Autenticação

A API usa JWT (JSON Web Tokens) para autenticação.

### Obter Token

```bash
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=teste@exemplo.com&password=senha123"
```

### Usar Token

```bash
curl -X GET "http://localhost:8000/api/transacoes" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## Exemplos de Uso

### Registrar Usuário

```bash
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@exemplo.com",
    "senha": "senha123",
    "moeda_padrao": "BRL"
  }'
```

### Criar Transação

```bash
curl -X POST "http://localhost:8000/api/transacoes" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "categoria_id": 1,
    "conta_id": 1,
    "tipo": "despesa",
    "valor": 150.00,
    "descricao": "Compras no supermercado",
    "data_transacao": "2025-01-13",
    "efetivada": true
  }'
```

### Obter Análise de Padrões

```bash
curl -X GET "http://localhost:8000/api/analises/padroes?periodo_dias=30" \
  -H "Authorization: Bearer SEU_TOKEN"
```

## Testes

```bash
pytest tests/
```

## Performance

### Otimizações Implementadas

- Connection pooling no banco de dados
- Índices em campos frequentemente consultados
- Paginação em listagens
- Cache de configurações
- Queries otimizadas com JOINs eficientes

### Monitoramento

Para monitorar a performance:

```bash
uvicorn main:app --log-level debug
```

## Segurança

### Boas Práticas Implementadas

- Senhas com hash bcrypt
- JWT com expiração configurável
- Validação de entrada com Pydantic
- SQL Injection prevenido pelo SQLAlchemy
- CORS configurado
- Rate limiting (recomendado para produção)

### Configuração de Produção

Para produção, configure:

1. **HTTPS**: Use certificado SSL
2. **Firewall**: Restrinja acesso ao banco
3. **Secrets**: Use variáveis de ambiente seguras
4. **Logging**: Configure logs estruturados
5. **Backup**: Configure backup automático do banco

## Troubleshooting

### Erro de conexão com banco de dados

Verifique:
1. PostgreSQL está rodando
2. Credenciais no `.env` estão corretas
3. Banco de dados foi criado
4. Tabelas foram criadas com os scripts SQL

### Erro de importação

```bash
pip install --upgrade -r requirements.txt
```

### Erro de CORS

Adicione a origem do frontend em `app/config.py`:

```python
cors_origins: list = [
    "http://localhost:3000",
    "http://seu-dominio.com",
]
```

## Deploy

### Docker

Crie um `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build e execute:

```bash
docker build -t api-financeiro .
docker run -p 8000:8000 api-financeiro
```

### Heroku

```bash
heroku create api-financeiro
git push heroku main
```

### AWS / DigitalOcean

Use Gunicorn com Uvicorn workers:

```bash
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## Licença

Este projeto foi desenvolvido como Trabalho de Conclusão de Curso.

## Autor

Nicolas Marquez Dalfovo
Centro Universitário para o Desenvolvimento do Alto Vale do Itajaí - UNIDAVI
2025

