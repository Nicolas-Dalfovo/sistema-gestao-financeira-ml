from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

from ..database import get_db
from ..models.models import Usuario
from ..models import schemas
from ..services.auth import (
    authenticate_usuario,
    create_access_token,
    get_password_hash,
    get_current_usuario,
    get_usuario_by_email,
)
from ..config import settings

router = APIRouter()


@router.post("/auth/register")
def register(user_data: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = get_usuario_by_email(db, user_data.email)
    
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="Email ja cadastrado"
        )
    
    if len(user_data.senha) > 72:
        raise HTTPException(
            status_code=400,
            detail="Senha muito longa. Maximo 72 caracteres."
        )
    
    hashed_password = get_password_hash(user_data.senha)
    
    new_user = Usuario(
        nome=user_data.nome,
        email=user_data.email,
        senha_hash=hashed_password,
        moeda_padrao=user_data.moeda_padrao or "BRL",
        ativo=True
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": new_user.email}, 
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "usuario": {
            "id": new_user.id,
            "nome": new_user.nome,
            "email": new_user.email,
            "moeda_padrao": new_user.moeda_padrao,
            "ativo": new_user.ativo
        }
    }


@router.post("/auth/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = authenticate_usuario(db, form_data.username, form_data.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou senha incorretos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": user.email}, 
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "usuario": {
            "id": user.id,
            "nome": user.nome,
            "email": user.email,
            "moeda_padrao": user.moeda_padrao,
            "ativo": user.ativo
        }
    }


@router.get("/auth/me")
async def get_me(current_user: Usuario = Depends(get_current_usuario)):
    return {
        "id": current_user.id,
        "nome": current_user.nome,
        "email": current_user.email,
        "moeda_padrao": current_user.moeda_padrao,
        "ativo": current_user.ativo
    }