from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from ..database import get_db
from ..models.models import Usuario
from ..config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        if len(plain_password) > 72:
            plain_password = plain_password[:72]
        return pwd_context.verify(plain_password, hashed_password)
    except Exception as e:
        print(f"Erro ao verificar senha: {e}")
        return False



def get_password_hash(password: str) -> str:
    if len(password) > 72:
        password = password[:72]
    return pwd_context.hash(password)



def get_usuario_by_email(db: Session, email: str) -> Optional[Usuario]:
    """Busca um usuário pelo email"""
    return db.query(Usuario).filter(Usuario.email == email).first()


def authenticate_usuario(db: Session, email: str, senha: str) -> Optional[Usuario]:
    print(f"DEBUG: Tentando autenticar: {email}")
    usuario = get_usuario_by_email(db, email)
    if not usuario:
        print("DEBUG: Usuario nao encontrado")
        return None
    print(f"DEBUG: Usuario encontrado: {usuario.email}")
    if not usuario.senha_hash:
        print("DEBUG: Senha hash vazia")
        return None
    print("DEBUG: Verificando senha...")
    try:
        if not verify_password(senha, str(usuario.senha_hash)):
            print("DEBUG: Senha incorreta")
            return None
    except Exception as e:
        print(f"DEBUG: Erro ao verificar senha: {e}")
        return None
    print("DEBUG: Autenticacao bem-sucedida")
    return usuario



def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Cria um token JWT de acesso"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.secret_key, 
        algorithm=settings.algorithm
    )
    return encoded_jwt


async def get_current_usuario(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> Usuario:
    """Obtém o usuário atual a partir do token JWT"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Não foi possível validar as credenciais",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(
            token, 
            settings.secret_key, 
            algorithms=[settings.algorithm]
        )
        email: Optional[str] = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    usuario = get_usuario_by_email(db, email)
    if usuario is None:
        raise credentials_exception
    
    if not usuario.ativo:
        raise HTTPException(
            status_code=400, 
            detail="Usuário inativo"
        )
    
    return usuario