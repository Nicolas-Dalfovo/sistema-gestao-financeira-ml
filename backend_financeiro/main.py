from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import auth, categorias, transacoes
from app.database import engine, Base
from app.routes import ml_routes

app = FastAPI(
    title="API Financeiro",
    description="API para gerenciamento financeiro pessoal com analise de dados",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.include_router(ml_routes.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router, prefix="/api", tags=["Autenticacao"])
app.include_router(categorias.router, prefix="/api", tags=["Categorias"])
app.include_router(transacoes.router, prefix="/api", tags=["Transacoes"])


@app.on_event("startup")
async def startup_event():
    print("Iniciando API Financeiro...")
    print("Criando tabelas no banco de dados...")
    Base.metadata.create_all(bind=engine)
    print("Tabelas criadas com sucesso!")


@app.on_event("shutdown")
async def shutdown_event():
    print("Encerrando API Financeiro...")


@app.get("/")
def root():
    return {
        "app": "API Financeiro",
        "version": "1.0.0",
        "status": "online",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "message": "API esta funcionando corretamente"
    }
