from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models.models import Usuario, Categoria
from ..models import schemas
from ..services.auth import get_current_usuario

router = APIRouter()

@router.get("/categorias", response_model=List[schemas.Categoria])
def listar_categorias(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    categorias = db.query(Categoria).filter(
        (Categoria.usuario_id == current_user.id) |
        (Categoria.usuario_id == None)
    ).all()
    
    # DEBUG: Imprimir IDs reais do banco
    print(f"?? Total categorias do banco: {len(categorias)}")
    for cat in categorias[:5]:
        print(f"  ID: {cat.id}, Nome: {cat.nome}, usuario_id: {cat.usuario_id}")
    
    return categorias
