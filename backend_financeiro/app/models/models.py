from sqlalchemy import Column, Integer, String, Numeric, Date, DateTime, Boolean, ForeignKey, Text, ARRAY, CheckConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base

class Usuario(Base):
    __tablename__ = "usuario"
    
    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=False, index=True)
    senha_hash = Column(String(255), nullable=False)
    data_nascimento = Column(Date, nullable=True)
    telefone = Column(String(20), nullable=True)
    foto_perfil = Column(Text, nullable=True)
    moeda_padrao = Column(String(3), default='BRL')
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    data_atualizacao = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    ativo = Column(Boolean, default=True)
    
    transacoes = relationship("Transacao", back_populates="usuario")
    categorias = relationship("Categoria", back_populates="usuario")
    contas = relationship("ContaBancaria", back_populates="usuario")
    metas = relationship("Meta", back_populates="usuario")
    orcamentos = relationship("Orcamento", back_populates="usuario")

class Categoria(Base):
    __tablename__ = "categorias"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=True)
    nome = Column(String(50), nullable=False)
    tipo = Column(String(10), nullable=False)
    icone = Column(String(50), nullable=True)
    cor = Column(String(7), nullable=True)
    ativo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    usuario = relationship("Usuario", back_populates="categorias")
    transacoes = relationship("Transacao", back_populates="categoria")
    
    __table_args__ = (
        CheckConstraint(tipo.in_(['receita', 'despesa']), name='check_tipo_categoria'),
    )

class ContaBancaria(Base):
    __tablename__ = "conta_bancaria"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=False)
    nome = Column(String(100), nullable=False)
    tipo = Column(String(20), nullable=False)
    banco = Column(String(100), nullable=True)
    saldo_inicial = Column(Numeric(15, 2), default=0.00)
    saldo_atual = Column(Numeric(15, 2), default=0.00)
    cor = Column(String(7), nullable=True)
    ativa = Column(Boolean, default=True)
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    
    usuario = relationship("Usuario", back_populates="contas")
    transacoes = relationship("Transacao", back_populates="conta")
    
    __table_args__ = (
        CheckConstraint(tipo.in_(['corrente', 'poupanca', 'carteira', 'investimento', 'credito']), name='check_tipo_conta'),
    )

class Transacao(Base):
    __tablename__ = "transacao"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=False, index=True)
    categoria_id = Column(Integer, ForeignKey("categorias.id", ondelete="RESTRICT"), nullable=False)
    conta_id = Column(Integer, ForeignKey("conta_bancaria.id", ondelete="RESTRICT"), nullable=False)
    tipo = Column(String(10), nullable=False)
    valor = Column(Numeric(15, 2), nullable=False)
    descricao = Column(Text, nullable=True)
    data_transacao = Column(Date, nullable=False, index=True)
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    recorrente = Column(Boolean, default=False)
    frequencia = Column(String(20), nullable=True)
    parcelas = Column(Integer, nullable=True)
    parcela_atual = Column(Integer, nullable=True)
    transacao_pai_id = Column(Integer, ForeignKey("transacao.id", ondelete="CASCADE"), nullable=True)
    tags = Column(ARRAY(Text), nullable=True)
    anexo = Column(Text, nullable=True)
    observacoes = Column(Text, nullable=True)
    efetivada = Column(Boolean, default=True)
    
    usuario = relationship("Usuario", back_populates="transacoes")
    categoria = relationship("Categoria", back_populates="transacoes")
    conta = relationship("ContaBancaria", back_populates="transacoes")
    
    __table_args__ = (
        CheckConstraint(tipo.in_(['receita', 'despesa', 'transferencia']), name='check_tipo_transacao'),
        CheckConstraint('valor > 0', name='check_valor_positivo'),
    )

class Meta(Base):
    __tablename__ = "meta"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=False)
    nome = Column(String(100), nullable=False)
    descricao = Column(Text, nullable=True)
    valor_alvo = Column(Numeric(15, 2), nullable=False)
    valor_atual = Column(Numeric(15, 2), default=0.00)
    data_inicio = Column(Date, nullable=False)
    data_fim = Column(Date, nullable=False)
    status = Column(String(20), default='ativa')
    prioridade = Column(Integer, default=1)
    icone = Column(String(50), nullable=True)
    cor = Column(String(7), nullable=True)
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    
    usuario = relationship("Usuario", back_populates="metas")
    
    __table_args__ = (
        CheckConstraint(status.in_(['ativa', 'concluida', 'cancelada', 'pausada']), name='check_status_meta'),
        CheckConstraint('valor_alvo > 0', name='check_valor_alvo_positivo'),
        CheckConstraint('data_fim > data_inicio', name='check_datas_meta'),
    )

class Orcamento(Base):
    __tablename__ = "orcamento"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=False)
    nome = Column(String(100), nullable=False)
    mes = Column(Integer, nullable=False)
    ano = Column(Integer, nullable=False)
    valor_total = Column(Numeric(15, 2), nullable=False)
    valor_gasto = Column(Numeric(15, 2), default=0.00)
    ativo = Column(Boolean, default=True)
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    
    usuario = relationship("Usuario", back_populates="orcamentos")
    categorias = relationship("OrcamentoCategoria", back_populates="orcamento")
    
    __table_args__ = (
        CheckConstraint('mes BETWEEN 1 AND 12', name='check_mes_valido'),
        CheckConstraint('ano >= 2000', name='check_ano_valido'),
        CheckConstraint('valor_total > 0', name='check_valor_total_positivo'),
    )

class OrcamentoCategoria(Base):
    __tablename__ = "orcamento_categoria"
    
    id = Column(Integer, primary_key=True, index=True)
    orcamento_id = Column(Integer, ForeignKey("orcamento.id", ondelete="CASCADE"), nullable=False)
    categoria_id = Column(Integer, ForeignKey("categorias.id", ondelete="CASCADE"), nullable=False)
    valor_limite = Column(Numeric(15, 2), nullable=False)
    valor_gasto = Column(Numeric(15, 2), default=0.00)
    alerta_percentual = Column(Integer, default=80)
    
    orcamento = relationship("Orcamento", back_populates="categorias")

class AnaliseConsumo(Base):
    __tablename__ = "analise_consumo"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuario.id", ondelete="CASCADE"), nullable=False)
    periodo_inicio = Column(Date, nullable=False)
    periodo_fim = Column(Date, nullable=False)
    tipo_analise = Column(String(50), nullable=False)
    categoria_id = Column(Integer, ForeignKey("categorias.id", ondelete="SET NULL"), nullable=True)
    dados_analise = Column(JSONB, nullable=False)
    insights = Column(ARRAY(Text), nullable=True)
    recomendacoes = Column(ARRAY(Text), nullable=True)
    score_confianca = Column(Numeric(5, 2), nullable=True)
    data_criacao = Column(DateTime(timezone=True), server_default=func.now())
    
    __table_args__ = (
        CheckConstraint(tipo_analise.in_(['padrao_consumo', 'previsao', 'anomalia', 'tendencia', 'comparativo']), name='check_tipo_analise'),
        CheckConstraint('periodo_fim >= periodo_inicio', name='check_periodo_analise'),
    )