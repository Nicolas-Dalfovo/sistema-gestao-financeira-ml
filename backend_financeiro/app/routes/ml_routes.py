from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from ..models.models import Usuario, AnaliseConsumo
from ..services.auth import get_current_usuario

router = APIRouter(prefix="/ml", tags=["Machine Learning"])


@router.get("/previsoes")
def obter_previsoes(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    from ml_service import PrevisaoGastosService
    
    service = PrevisaoGastosService(db, current_user.id)
    previsao = service.prever_gastos_proximos_30_dias()
    
    insights = []
    recomendacoes = []
    
    if previsao['confianca'] < 50:
        insights.append("Dados insuficientes para previsão precisa. Continue registrando suas transações.")
    else:
        insights.append(f"Com base em {previsao['transacoes_analisadas']} transações, prevemos gastos de R$ {previsao['previsao_total']:.2f} nos próximos 30 dias.")
    
    if previsao.get('tendencia') == 'crescente':
        insights.append("Seus gastos estão em tendência de crescimento.")
        recomendacoes.append("Revise suas despesas e identifique onde pode economizar.")
    elif previsao.get('tendencia') == 'decrescente':
        insights.append("Parabéns! Seus gastos estão diminuindo.")
    
    top_categorias = previsao.get('por_categoria', [])[:3]
    if top_categorias:
        nomes = ", ".join([c['categoria_nome'] for c in top_categorias])
        insights.append(f"Suas maiores despesas previstas: {nomes}")
    
    service.salvar_analise(
        tipo_analise='previsao',
        dados=previsao,
        insights=insights,
        recomendacoes=recomendacoes,
        score=previsao['confianca']
    )
    
    return {
        "previsao": previsao,
        "insights": insights,
        "recomendacoes": recomendacoes
    }


@router.get("/alertas")
def obter_alertas(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    from ml_service import PrevisaoGastosService
    
    service = PrevisaoGastosService(db, current_user.id)
    alertas = service.gerar_alertas()
    
    insights = [alerta['mensagem'] for alerta in alertas]
    recomendacoes = []
    
    for alerta in alertas:
        if alerta['tipo'] == 'gasto_acima_media':
            recomendacoes.append("Revise seus gastos recentes e identifique despesas desnecessárias.")
        elif alerta['tipo'] == 'saldo_baixo':
            recomendacoes.append("Considere reduzir gastos não essenciais ou buscar fontes de renda extra.")
        elif alerta['tipo'] == 'meta_em_risco':
            recomendacoes.append(f"Reavalie a meta '{alerta['meta_nome']}' ou aumente sua economia mensal.")
    
    if alertas:
        service.salvar_analise(
            tipo_analise='anomalia',
            dados={"alertas": alertas},
            insights=insights,
            recomendacoes=recomendacoes,
            score=100.0
        )
    
    return {
        "alertas": alertas,
        "total": len(alertas),
        "recomendacoes": recomendacoes
    }


@router.get("/dashboard")
def obter_dashboard_ml(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    from ml_service import PrevisaoGastosService
    
    service = PrevisaoGastosService(db, current_user.id)
    
    previsao = service.prever_gastos_proximos_30_dias()
    alertas = service.gerar_alertas()
    
    return {
        "previsao_gastos": previsao,
        "alertas": alertas,
        "resumo": {
            "total_alertas": len(alertas),
            "confianca_previsao": previsao.get('confianca', 0),
            "tendencia": previsao.get('tendencia', 'estavel')
        }
    }


@router.get("/historico-analises")
def obter_historico_analises(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_usuario)
):
    analises = db.query(AnaliseConsumo).filter(
        AnaliseConsumo.usuario_id == current_user.id
    ).order_by(AnaliseConsumo.data_criacao.desc()).limit(limit).all()
    
    return {
        "analises": [
            {
                "id": a.id,
                "tipo": a.tipo_analise,
                "periodo_inicio": a.periodo_inicio,
                "periodo_fim": a.periodo_fim,
                "insights": a.insights,
                "recomendacoes": a.recomendacoes,
                "confianca": float(a.score_confianca) if a.score_confianca else 0,
                "data_criacao": a.data_criacao
            }
            for a in analises
        ],
        "total": len(analises)
    }