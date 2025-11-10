from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

from ..database import get_db
from ..models.models import Usuario, Transacao, ContaBancaria
from ..models import schemas
from ..services.auth import get_current_usuario

router = APIRouter()


@router.get("/transacoes", response_model=List[schemas.Transacao])
def listar_transacoes(
    skip: int = 0,
    limit: int = 100,
    data_inicio: Optional[date] = None,
    data_fim: Optional[date] = None,
    tipo: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    """Lista todas as transações do usuário com filtros opcionais"""
    query = db.query(Transacao).filter(
        Transacao.usuario_id == current_user.id
    )
    
    if data_inicio:
        query = query.filter(Transacao.data_transacao >= data_inicio)
    if data_fim:
        query = query.filter(Transacao.data_transacao <= data_fim)
    if tipo:
        query = query.filter(Transacao.tipo == tipo)
    
    transacoes = query.order_by(
        Transacao.data_transacao.desc()
    ).offset(skip).limit(limit).all()
    
    return transacoes


@router.post("/transacoes", response_model=schemas.Transacao, status_code=status.HTTP_201_CREATED)
def criar_transacao(
    transacao: schemas.TransacaoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    """Cria uma nova transação"""
    
    conta_padrao = db.query(ContaBancaria).filter(
        ContaBancaria.usuario_id == current_user.id,
        ContaBancaria.ativa == True
    ).first()
    
    if not conta_padrao:
        conta_padrao = ContaBancaria(
            usuario_id=current_user.id,
            nome="Conta Principal",
            tipo="carteira",
            saldo_inicial=0.00,
            saldo_atual=0.00,
            ativa=True
        )
        db.add(conta_padrao)
        db.commit()
        db.refresh(conta_padrao)
    
    db_transacao = Transacao(
        usuario_id=current_user.id,
        categoria_id=transacao.categoria_id,
        conta_id=conta_padrao.id,
        tipo=transacao.tipo,
        valor=transacao.valor,
        descricao=transacao.descricao,
        data_transacao=transacao.data,
        efetivada=transacao.efetivada,
        observacoes=transacao.observacoes,
        recorrente=False
    )
    
    db.add(db_transacao)
    db.commit()
    db.refresh(db_transacao)
    
    return db_transacao


@router.get("/transacoes/{transacao_id}", response_model=schemas.Transacao)
def obter_transacao(
    transacao_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    """Obtém uma transação específica"""
    transacao = db.query(Transacao).filter(
        Transacao.id == transacao_id,
        Transacao.usuario_id == current_user.id
    ).first()
    
    if not transacao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transacao nao encontrada"
        )
    
    return transacao


@router.put("/transacoes/{transacao_id}", response_model=schemas.Transacao)
def atualizar_transacao(
    transacao_id: int,
    transacao_update: schemas.TransacaoUpdate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    """Atualiza uma transação existente"""
    transacao = db.query(Transacao).filter(
        Transacao.id == transacao_id,
        Transacao.usuario_id == current_user.id
    ).first()
    
    if not transacao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transacao nao encontrada"
        )
    
    update_data = transacao_update.dict(exclude_unset=True)
    
    if 'data' in update_data:
        update_data['data_transacao'] = update_data.pop('data')
    
    for key, value in update_data.items():
        setattr(transacao, key, value)
    
    db.commit()
    db.refresh(transacao)
    
    return transacao


@router.delete("/transacoes/{transacao_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_transacao(
    transacao_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    """Deleta uma transação permanentemente"""
    transacao = db.query(Transacao).filter(
        Transacao.id == transacao_id,
        Transacao.usuario_id == current_user.id
    ).first()
    
    if not transacao:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Transacao nao encontrada"
        )
    
    db.delete(transacao)
    db.commit()
    
    return None