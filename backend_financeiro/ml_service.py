from datetime import datetime, timedelta, date
from decimal import Decimal
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, extract
import statistics
import json


class PrevisaoGastosService:
    
    def __init__(self, db: Session, usuario_id: int):
        self.db = db
        self.usuario_id = usuario_id
    
    def prever_gastos_proximos_30_dias(self) -> Dict:
        hoje = date.today()
        inicio_periodo = hoje - timedelta(days=90)
        
        from app.models.models import Transacao, Categoria
        
        transacoes = self.db.query(Transacao).filter(
            and_(
                Transacao.usuario_id == self.usuario_id,
                Transacao.tipo == 'despesa',
                Transacao.data_transacao >= inicio_periodo,
                Transacao.data_transacao < hoje,
                Transacao.efetivada == True
            )
        ).all()
        
        if len(transacoes) < 5:
            return {
                "previsao_total": 0,
                "confianca": 0,
                "detalhes": "Dados insuficientes para previsão (mínimo 5 transações)",
                "por_categoria": []
            }
        
        gastos_por_mes = {}
        gastos_por_categoria = {}
        
        for t in transacoes:
            mes_ano = f"{t.data_transacao.year}-{t.data_transacao.month:02d}"
            valor = float(getattr(t, 'valor', 0) if not hasattr(t.valor, 'type') else 0)
            
            if mes_ano not in gastos_por_mes:
                gastos_por_mes[mes_ano] = 0
            gastos_por_mes[mes_ano] += valor
            
            if t.categoria_id not in gastos_por_categoria:
                gastos_por_categoria[t.categoria_id] = []
            gastos_por_categoria[t.categoria_id].append(valor)
        
        valores_mensais = list(gastos_por_mes.values())
        media_mensal = statistics.mean(valores_mensais)
        
        if len(valores_mensais) > 1:
            desvio_padrao = statistics.stdev(valores_mensais)
            coef_variacao = (desvio_padrao / media_mensal) * 100 if media_mensal > 0 else 100
            confianca = max(0, min(100, 100 - coef_variacao))
        else:
            confianca = 50
        
        previsao_categorias = []
        for cat_id, valores in gastos_por_categoria.items():
            categoria = self.db.query(Categoria).filter(Categoria.id == cat_id).first()
            if categoria:
                media_cat = statistics.mean(valores)
                previsao_categorias.append({
                    "categoria_id": cat_id,
                    "categoria_nome": categoria.nome,
                    "previsao": round(media_cat, 2),
                    "historico_transacoes": len(valores)
                })
        
        previsao_categorias.sort(key=lambda x: x['previsao'], reverse=True)
        
        return {
            "previsao_total": round(media_mensal, 2),
            "confianca": round(confianca, 2),
            "periodo_analise_dias": 90,
            "transacoes_analisadas": len(transacoes),
            "por_categoria": previsao_categorias[:10],
            "tendencia": self._calcular_tendencia(valores_mensais)
        }
    
    def _calcular_tendencia(self, valores: List[float]) -> str:
        if len(valores) < 2:
            return "estavel"
        
        primeira_metade = valores[:len(valores)//2]
        segunda_metade = valores[len(valores)//2:]
        
        media_primeira = statistics.mean(primeira_metade)
        media_segunda = statistics.mean(segunda_metade)
        
        diferenca_percentual = ((media_segunda - media_primeira) / media_primeira * 100) if media_primeira > 0 else 0
        
        if diferenca_percentual > 10:
            return "crescente"
        elif diferenca_percentual < -10:
            return "decrescente"
        else:
            return "estavel"
    
    def gerar_alertas(self) -> List[Dict]:
        alertas = []
        hoje = date.today()
        
        alerta_gasto_acima_media = self._verificar_gasto_acima_media()
        if alerta_gasto_acima_media:
            alertas.append(alerta_gasto_acima_media)
        
        alerta_saldo_baixo = self._verificar_saldo_baixo()
        if alerta_saldo_baixo:
            alertas.append(alerta_saldo_baixo)
        
        alerta_meta_risco = self._verificar_metas_em_risco()
        if alerta_meta_risco:
            alertas.extend(alerta_meta_risco)
        
        return alertas
    
    def _verificar_gasto_acima_media(self) -> Optional[Dict]:
        hoje = date.today()
        inicio_mes = hoje.replace(day=1)
        
        from app.models.models import Transacao
        
        gasto_mes_atual = self.db.query(func.sum(Transacao.valor)).filter(
            and_(
                Transacao.usuario_id == self.usuario_id,
                Transacao.tipo == 'despesa',
                Transacao.data_transacao >= inicio_mes,
                Transacao.efetivada == True
            )
        ).scalar() or Decimal(0)
        
        inicio_periodo = hoje - timedelta(days=90)
        transacoes_historico = self.db.query(Transacao).filter(
            and_(
                Transacao.usuario_id == self.usuario_id,
                Transacao.tipo == 'despesa',
                Transacao.data_transacao >= inicio_periodo,
                Transacao.data_transacao < inicio_mes,
                Transacao.efetivada == True
            )
        ).all()
        
        if len(transacoes_historico) < 5:
            return None
        
        gastos_por_mes = {}
        for t in transacoes_historico:
            mes_ano = f"{t.data_transacao.year}-{t.data_transacao.month:02d}"
            if mes_ano not in gastos_por_mes:
                gastos_por_mes[mes_ano] = 0
            valor = float(getattr(t, 'valor', 0) if not hasattr(t.valor, 'type') else 0)
            gastos_por_mes[mes_ano] += valor
        
        if not gastos_por_mes:
            return None
        
        media_mensal = statistics.mean(gastos_por_mes.values())
        gasto_atual = float(gasto_mes_atual)
        
        if gasto_atual > media_mensal * 1.2:
            percentual = ((gasto_atual - media_mensal) / media_mensal * 100)
            return {
                "tipo": "gasto_acima_media",
                "severidade": "alta" if percentual > 50 else "media",
                "titulo": "Gastos acima da média",
                "mensagem": f"Seus gastos este mês (R$ {gasto_atual:.2f}) estão {percentual:.1f}% acima da média (R$ {media_mensal:.2f})",
                "valor_atual": round(gasto_atual, 2),
                "valor_referencia": round(media_mensal, 2),
                "percentual_diferenca": round(percentual, 2)
            }
        
        return None
    
    def _verificar_saldo_baixo(self) -> Optional[Dict]:
        from app.models.models import ContaBancaria
        
        contas = self.db.query(ContaBancaria).filter(
            and_(
                ContaBancaria.usuario_id == self.usuario_id,
                ContaBancaria.ativa == True
            )
        ).all()
        
        saldo_total = sum(float(getattr(c, 'saldo_atual', 0)) for c in contas)
        
        previsao = self.prever_gastos_proximos_30_dias()
        gasto_previsto = previsao.get('previsao_total', 0)
        
        if saldo_total < gasto_previsto:
            deficit = gasto_previsto - saldo_total
            return {
                "tipo": "saldo_baixo",
                "severidade": "alta",
                "titulo": "Saldo insuficiente",
                "mensagem": f"Seu saldo atual (R$ {saldo_total:.2f}) pode não ser suficiente para os gastos previstos (R$ {gasto_previsto:.2f})",
                "saldo_atual": round(saldo_total, 2),
                "gasto_previsto": round(gasto_previsto, 2),
                "deficit": round(deficit, 2)
            }
        
        return None
    
    def _verificar_metas_em_risco(self) -> List[Dict]:
        from app.models.models import Meta
        
        alertas = []
        hoje = date.today()
        
        metas = self.db.query(Meta).filter(
            and_(
                Meta.usuario_id == self.usuario_id,
                Meta.status == 'ativa',
                Meta.data_fim >= hoje
            )
        ).all()
        
        for meta in metas:
            dias_restantes = (meta.data_fim - hoje).days
            if dias_restantes <= 0:
                continue
            
            valor_faltante = float(float(getattr(meta, 'valor_alvo', 0)) - float(getattr(meta, 'valor_atual', 0)))
            if valor_faltante <= 0:
                continue
            
            valor_diario_necessario = valor_faltante / dias_restantes
            
            previsao = self.prever_gastos_proximos_30_dias()
            gasto_previsto_mensal = previsao.get('previsao_total', 0)
            
            economia_diaria_estimada = max(0, (3000 - gasto_previsto_mensal) / 30)
            
            if valor_diario_necessario > economia_diaria_estimada * 1.5:
                alertas.append({
                    "tipo": "meta_em_risco",
                    "severidade": "media",
                    "titulo": f"Meta '{meta.nome}' em risco",
                    "mensagem": f"Você precisa economizar R$ {valor_diario_necessario:.2f}/dia para atingir esta meta, mas sua capacidade estimada é R$ {economia_diaria_estimada:.2f}/dia",
                    "meta_id": meta.id,
                    "meta_nome": meta.nome,
                    "valor_faltante": round(valor_faltante, 2),
                    "dias_restantes": dias_restantes,
                    "economia_diaria_necessaria": round(valor_diario_necessario, 2)
                })
        
        return alertas
    
    def salvar_analise(self, tipo_analise: str, dados: Dict, insights: List[str], recomendacoes: List[str], score: float):
        from app.models.models import AnaliseConsumo
        
        hoje = date.today()
        inicio_periodo = hoje - timedelta(days=90)
        
        analise = AnaliseConsumo(
            usuario_id=self.usuario_id,
            periodo_inicio=inicio_periodo,
            periodo_fim=hoje,
            tipo_analise=tipo_analise,
            dados_analise=dados,
            insights=insights,
            recomendacoes=recomendacoes,
            score_confianca=Decimal(str(score))
        )
        
        self.db.add(analise)
        self.db.commit()
        self.db.refresh(analise)
        
        return analise

