CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabela de usuários
CREATE TABLE usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(20),
    foto_perfil TEXT,
    moeda_padrao VARCHAR(3) DEFAULT 'BRL',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de categorias
CREATE TABLE categoria (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuario(id) ON DELETE CASCADE,
    nome VARCHAR(50) NOT NULL,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('receita', 'despesa')),
    icone VARCHAR(50),
    cor VARCHAR(7),
    descricao TEXT,
    ativa BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_categoria_usuario UNIQUE (usuario_id, nome, tipo)
);

-- Tabela de contas bancárias
CREATE TABLE conta_bancaria (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('corrente', 'poupanca', 'carteira', 'investimento', 'credito')),
    banco VARCHAR(100),
    saldo_inicial DECIMAL(15,2) DEFAULT 0.00,
    saldo_atual DECIMAL(15,2) DEFAULT 0.00,
    cor VARCHAR(7),
    ativa BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de transações
CREATE TABLE transacao (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    categoria_id INTEGER NOT NULL REFERENCES categoria(id) ON DELETE RESTRICT,
    conta_id INTEGER NOT NULL REFERENCES conta_bancaria(id) ON DELETE RESTRICT,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('receita', 'despesa', 'transferencia')),
    valor DECIMAL(15,2) NOT NULL CHECK (valor > 0),
    descricao TEXT,
    data_transacao DATE NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recorrente BOOLEAN DEFAULT FALSE,
    frequencia VARCHAR(20) CHECK (frequencia IN ('diaria', 'semanal', 'quinzenal', 'mensal', 'bimestral', 'trimestral', 'semestral', 'anual')),
    parcelas INTEGER CHECK (parcelas > 0),
    parcela_atual INTEGER CHECK (parcela_atual > 0 AND parcela_atual <= parcelas),
    transacao_pai_id INTEGER REFERENCES transacao(id) ON DELETE CASCADE,
    tags TEXT[],
    anexo TEXT,
    observacoes TEXT,
    efetivada BOOLEAN DEFAULT TRUE
);

-- Tabela de metas financeiras
CREATE TABLE meta (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    valor_alvo DECIMAL(15,2) NOT NULL CHECK (valor_alvo > 0),
    valor_atual DECIMAL(15,2) DEFAULT 0.00 CHECK (valor_atual >= 0),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ativa' CHECK (status IN ('ativa', 'concluida', 'cancelada', 'pausada')),
    prioridade INTEGER DEFAULT 1 CHECK (prioridade BETWEEN 1 AND 5),
    icone VARCHAR(50),
    cor VARCHAR(7),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_data_meta CHECK (data_fim > data_inicio),
    CONSTRAINT check_valor_meta CHECK (valor_atual <= valor_alvo)
);

-- Tabela de orçamentos
CREATE TABLE orcamento (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    ano INTEGER NOT NULL CHECK (ano >= 2000),
    valor_total DECIMAL(15,2) NOT NULL CHECK (valor_total > 0),
    valor_gasto DECIMAL(15,2) DEFAULT 0.00 CHECK (valor_gasto >= 0),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_orcamento_periodo UNIQUE (usuario_id, mes, ano)
);

-- Tabela de relacionamento orçamento-categoria
CREATE TABLE orcamento_categoria (
    id SERIAL PRIMARY KEY,
    orcamento_id INTEGER NOT NULL REFERENCES orcamento(id) ON DELETE CASCADE,
    categoria_id INTEGER NOT NULL REFERENCES categoria(id) ON DELETE CASCADE,
    valor_limite DECIMAL(15,2) NOT NULL CHECK (valor_limite > 0),
    valor_gasto DECIMAL(15,2) DEFAULT 0.00 CHECK (valor_gasto >= 0),
    alerta_percentual INTEGER DEFAULT 80 CHECK (alerta_percentual BETWEEN 0 AND 100),
    CONSTRAINT unique_orcamento_categoria UNIQUE (orcamento_id, categoria_id)
);

-- Tabela de notificações
CREATE TABLE notificacao (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('alerta', 'lembrete', 'insight', 'meta', 'orcamento', 'sistema')),
    titulo VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_leitura TIMESTAMP
);

-- Tabela de análises de consumo
CREATE TABLE analise_consumo (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    periodo_inicio DATE NOT NULL,
    periodo_fim DATE NOT NULL,
    tipo_analise VARCHAR(50) NOT NULL CHECK (tipo_analise IN ('padrao_consumo', 'previsao', 'anomalia', 'tendencia', 'comparativo')),
    categoria_id INTEGER REFERENCES categoria(id) ON DELETE SET NULL,
    dados_analise JSONB NOT NULL,
    insights TEXT[],
    recomendacoes TEXT[],
    score_confianca DECIMAL(5,2) CHECK (score_confianca BETWEEN 0 AND 100),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_periodo_analise CHECK (periodo_fim >= periodo_inicio)
);

-- Tabela de configurações do usuário
CREATE TABLE configuracao_usuario (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL UNIQUE REFERENCES usuario(id) ON DELETE CASCADE,
    notificacoes_ativas BOOLEAN DEFAULT TRUE,
    notificacao_email BOOLEAN DEFAULT TRUE,
    notificacao_push BOOLEAN DEFAULT TRUE,
    tema VARCHAR(20) DEFAULT 'claro' CHECK (tema IN ('claro', 'escuro', 'auto')),
    idioma VARCHAR(5) DEFAULT 'pt-BR',
    dia_fechamento INTEGER DEFAULT 1 CHECK (dia_fechamento BETWEEN 1 AND 31),
    backup_automatico BOOLEAN DEFAULT TRUE,
    sincronizacao_automatica BOOLEAN DEFAULT TRUE,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de transferências entre contas
CREATE TABLE transferencia (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(id) ON DELETE CASCADE,
    conta_origem_id INTEGER NOT NULL REFERENCES conta_bancaria(id) ON DELETE RESTRICT,
    conta_destino_id INTEGER NOT NULL REFERENCES conta_bancaria(id) ON DELETE RESTRICT,
    valor DECIMAL(15,2) NOT NULL CHECK (valor > 0),
    descricao TEXT,
    data_transferencia DATE NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_contas_diferentes CHECK (conta_origem_id != conta_destino_id)
);

-- Índices para otimização de consultas
CREATE INDEX idx_transacao_usuario ON transacao(usuario_id);
CREATE INDEX idx_transacao_data ON transacao(data_transacao DESC);
CREATE INDEX idx_transacao_categoria ON transacao(categoria_id);
CREATE INDEX idx_transacao_conta ON transacao(conta_id);
CREATE INDEX idx_transacao_tipo ON transacao(tipo);
CREATE INDEX idx_transacao_data_usuario ON transacao(usuario_id, data_transacao DESC);

CREATE INDEX idx_categoria_usuario ON categoria(usuario_id);
CREATE INDEX idx_categoria_tipo ON categoria(tipo);

CREATE INDEX idx_conta_usuario ON conta_bancaria(usuario_id);
CREATE INDEX idx_conta_ativa ON conta_bancaria(ativa);

CREATE INDEX idx_meta_usuario ON meta(usuario_id);
CREATE INDEX idx_meta_status ON meta(status);
CREATE INDEX idx_meta_data_fim ON meta(data_fim);

CREATE INDEX idx_orcamento_usuario ON orcamento(usuario_id);
CREATE INDEX idx_orcamento_periodo ON orcamento(ano, mes);
CREATE INDEX idx_orcamento_ativo ON orcamento(ativo);

CREATE INDEX idx_notificacao_usuario ON notificacao(usuario_id);
CREATE INDEX idx_notificacao_lida ON notificacao(lida);
CREATE INDEX idx_notificacao_data ON notificacao(data_criacao DESC);

CREATE INDEX idx_analise_usuario ON analise_consumo(usuario_id);
CREATE INDEX idx_analise_periodo ON analise_consumo(periodo_inicio, periodo_fim);
CREATE INDEX idx_analise_tipo ON analise_consumo(tipo_analise);

CREATE INDEX idx_transferencia_usuario ON transferencia(usuario_id);
CREATE INDEX idx_transferencia_data ON transferencia(data_transferencia DESC);

-- Comentários nas tabelas
COMMENT ON TABLE usuario IS 'Armazena informações dos usuários do aplicativo';
COMMENT ON TABLE categoria IS 'Categorias para classificação de transações';
COMMENT ON TABLE conta_bancaria IS 'Contas bancárias e carteiras dos usuários';
COMMENT ON TABLE transacao IS 'Registros de receitas e despesas';
COMMENT ON TABLE meta IS 'Metas financeiras dos usuários';
COMMENT ON TABLE orcamento IS 'Orçamentos mensais dos usuários';
COMMENT ON TABLE orcamento_categoria IS 'Limites de gastos por categoria em cada orçamento';
COMMENT ON TABLE notificacao IS 'Notificações enviadas aos usuários';
COMMENT ON TABLE analise_consumo IS 'Análises geradas pelo sistema de machine learning';
COMMENT ON TABLE configuracao_usuario IS 'Configurações e preferências dos usuários';
COMMENT ON TABLE transferencia IS 'Transferências entre contas do mesmo usuário';