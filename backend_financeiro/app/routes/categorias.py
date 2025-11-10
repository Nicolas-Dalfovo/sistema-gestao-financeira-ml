from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db, engine
from ..models.models import Usuario, Categoria
from ..models import schemas
from ..services.auth import get_current_usuario

router = APIRouter()

@router.get("/categorias", response_model=List[schemas.Categoria])
def listar_categorias(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    # DEBUG: Mostrar URL do banco
    print(f"🔍 ENGINE URL: {engine.url}")
    print(f"🔍 DATABASE: {engine.url.database}")
    print(f"🔍 HOST: {engine.url.host}")
    print(f"🔍 PORT: {engine.url.port}")
    
    categorias = db.query(Categoria).filter(
        (Categoria.usuario_id == current_user.id) |
        (Categoria.usuario_id == None)
    ).all()
    
    print(f"🔍 Total categorias: {len(categorias)}")
    
    return categorias
