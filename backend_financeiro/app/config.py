from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    database_url: str = "postgresql://app_user:123@localhost:5432/app_financeiro"
    secret_key: str = "sua_chave_secreta_jwt_aqui_mude_em_producao"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    cors_origins: List[str] = ["*"]
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
