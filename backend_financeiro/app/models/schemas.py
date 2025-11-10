from pydantic import BaseModel, Field, EmailStr, ConfigDict, field_validator, field_serializer
from typing import Optional, List
from datetime import datetime, date
from decimal import Decimal


class UserCreate(BaseModel):
    nome: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    senha: str = Field(..., min_length=6, max_length=72)
    moeda_padrao: Optional[str] = "BRL"


class UserLogin(BaseModel):
    email: EmailStr
    senha: str


class User(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    nome: str
    email: str
    moeda_padrao: str
    ativo: bool
    data_criacao: Optional[datetime] = None
    data_atualizacao: Optional[datetime] = None


class UserUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[EmailStr] = None
    telefone: Optional[str] = None
    moeda_padrao: Optional[str] = None


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    usuario: User


class TokenData(BaseModel):
    email: Optional[str] = None


class CategoriaBase(BaseModel):
    nome: str = Field(..., min_length=1, max_length=50)
    tipo: str = Field(..., pattern="^(receita|despesa)$")
    icone: Optional[str] = None
    cor: Optional[str] = None


class CategoriaCreate(CategoriaBase):
    pass


class CategoriaUpdate(BaseModel):
    nome: Optional[str] = None
    icone: Optional[str] = None
    cor: Optional[str] = None
    ativo: Optional[bool] = None


class Categoria(CategoriaBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    usuario_id: Optional[int] = None
    ativo: bool
    created_at: datetime
    updated_at: Optional[datetime] = None


class ContaBancariaBase(BaseModel):
    nome: str = Field(..., min_length=1, max_length=100)
    tipo: str = Field(..., pattern="^(corrente|poupanca|carteira|investimento|credito)$")
    banco: Optional[str] = None
    saldo_inicial: Optional[Decimal] = Field(default=Decimal("0.00"))
    cor: Optional[str] = None
    
    @field_validator('saldo_inicial', mode='before')
    @classmethod
    def convert_saldo(cls, v):
        if v is None:
            return Decimal("0.00")
        if isinstance(v, str):
            return Decimal(v)
        return v


class ContaBancariaCreate(ContaBancariaBase):
    pass


class ContaBancariaUpdate(BaseModel):
    nome: Optional[str] = None
    tipo: Optional[str] = None
    banco: Optional[str] = None
    cor: Optional[str] = None
    ativa: Optional[bool] = None


class ContaBancaria(ContaBancariaBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    usuario_id: int
    saldo_atual: Decimal
    ativa: bool
    data_criacao: datetime
    
    @field_serializer('saldo_inicial', 'saldo_atual')
    def serialize_decimal(self, valor: Decimal, _info):
        return float(valor) if valor is not None else None


class TransacaoBase(BaseModel):
    descricao: str
    valor: Decimal = Field(..., gt=0)
    tipo: str = Field(..., pattern="^(receita|despesa)$")
    data: date
    categoria_id: int
    efetivada: bool = True
    observacoes: Optional[str] = None
    
    @field_validator('valor', mode='before')
    @classmethod
    def convert_valor(cls, v):
        if isinstance(v, str):
            return Decimal(v)
        return v


class TransacaoCreate(TransacaoBase):
    pass


class TransacaoUpdate(BaseModel):
    descricao: Optional[str] = None
    valor: Optional[Decimal] = None
    tipo: Optional[str] = None
    data: Optional[date] = None
    categoria_id: Optional[int] = None
    efetivada: Optional[bool] = None
    observacoes: Optional[str] = None


class Transacao(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    usuario_id: int
    categoria_id: int
    conta_id: int
    tipo: str
    valor: Decimal
    descricao: Optional[str] = None
    data_transacao: date  
    efetivada: bool
    observacoes: Optional[str] = None
    data_criacao: Optional[datetime] = None
    recorrente: Optional[bool] = False
    
    @field_serializer('valor')
    def serialize_valor(self, valor: Decimal, _info):
        return float(valor)


class MetaBase(BaseModel):
    nome: str = Field(..., min_length=1, max_length=100)
    descricao: Optional[str] = None
    valor_alvo: Decimal = Field(..., gt=0)
    data_inicio: date
    data_fim: date
    prioridade: Optional[int] = Field(default=1, ge=1, le=5)
    
    @field_validator('valor_alvo', mode='before')
    @classmethod
    def convert_valor_alvo(cls, v):
        if isinstance(v, str):
            return Decimal(v)
        return v


class MetaCreate(MetaBase):
    pass


class MetaUpdate(BaseModel):
    nome: Optional[str] = None
    descricao: Optional[str] = None
    valor_alvo: Optional[Decimal] = None
    data_fim: Optional[date] = None
    status: Optional[str] = None
    prioridade: Optional[int] = None


class Meta(MetaBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    usuario_id: int
    valor_atual: Decimal
    status: str
    icone: Optional[str] = None
    cor: Optional[str] = None
    data_criacao: datetime
    
    @field_serializer('valor_alvo', 'valor_atual')
    def serialize_decimal(self, valor: Decimal, _info):
        return float(valor) if valor is not None else None