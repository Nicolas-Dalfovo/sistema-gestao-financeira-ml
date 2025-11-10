import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List
from sqlalchemy.orm import Session
from sklearn.linear_model import LinearRegression
from ..models.models import Transacao

class PrevisaoGastos:
    def __init__(self, db: Session, usuario_id: int):
        self.db = db
        self.usuario_id = usuario_id
    
    def obter_historico_mensal(self, meses: int = 12) -> pd.DataFrame:
        data_fim = datetime.now().date()
        data_inicio = data_fim - timedelta(days=meses * 30)
        
        transacoes = self.db.query(Transacao).filter(
            Transacao.usuario_id == self.usuario_id,
            Transacao.data_transacao >= data_inicio,
            Transacao.data_transacao <= data_fim,
            Transacao.efetivada == True
        ).all()
        
        if not transacoes:
            return pd.DataFrame()
        
        data = []
        for t in transacoes:
            data.append({
                'tipo': t.tipo,
                'valor': float(t.valor),
                'data': t.data_transacao,
                'mes': t.data_transacao.month,
                'ano': t.data_transacao.year,
                'categoria_id': t.categoria_id
            })
        
        df = pd.DataFrame(data)
        df['ano_mes'] = df['ano'].astype(str) + '-' + df['mes'].astype(str).str.zfill(2)
        
        return df
    
    def prever_gastos_proximo_mes(self) -> Dict:
        df = self.obter_historico_mensal(12)
        
        if df.empty or len(df) < 30:
            return {
                'previsao_total': 0,
                'confianca': 0,
                'mensagem': 'Dados insuficientes para previsão',
                'detalhes': {}
            }
        
        despesas = df[df['tipo'] == 'despesa']
        
        if despesas.empty:
            return {
                'previsao_total': 0,
                'confianca': 0,
                'mensagem': 'Sem histórico de despesas',
                'detalhes': {}
            }
        
        mensal = despesas.groupby('ano_mes')['valor'].sum().reset_index()
        mensal = mensal.sort_values('ano_mes')
        
        if len(mensal) < 3:
            media_simples = mensal['valor'].mean()
            return {
                'previsao_total': round(float(media_simples), 2),
                'confianca': 50,
                'mensagem': 'Previsão baseada em média simples',
                'detalhes': {
                    'metodo': 'media_simples',
                    'meses_analisados': len(mensal)
                }
            }
        
        X = np.array(range(len(mensal))).reshape(-1, 1)
        y = mensal['valor'].values
        
        modelo = LinearRegression()
        modelo.fit(X, y)
        
        proximo_mes = len(mensal)
        previsao = modelo.predict([[proximo_mes]])[0]
        
        score = modelo.score(X, y)
        confianca = int(score * 100)
        
        ultimos_3_meses = mensal.tail(3)['valor'].mean()
        
        if abs(previsao - ultimos_3_meses) / ultimos_3_meses > 0.5:
            previsao = ultimos_3_meses
            confianca = max(confianca - 20, 30)
        
        return {
            'previsao_total': round(float(previsao), 2),
            'confianca': confianca,
            'mensagem': 'Previsão baseada em regressão linear',
            'detalhes': {
                'metodo': 'regressao_linear',
                'meses_analisados': len(mensal),
                'tendencia': 'crescente' if modelo.coef_[0] > 0 else 'decrescente',
                'variacao_mensal': round(float(modelo.coef_[0]), 2)
            }
        }
    
    def prever_por_categoria(self, categoria_id: int, meses_futuro: int = 1) -> Dict:
        df = self.obter_historico_mensal(12)
        
        if df.empty:
            return {
                'categoria_id': categoria_id,
                'previsao': 0,
                'confianca': 0,
                'mensagem': 'Sem dados históricos'
            }
        
        cat_data = df[(df['categoria_id'] == categoria_id) & (df['tipo'] == 'despesa')]
        
        if cat_data.empty:
            return {
                'categoria_id': categoria_id,
                'previsao': 0,
                'confianca': 0,
                'mensagem': 'Sem histórico para esta categoria'
            }
        
        mensal = cat_data.groupby('ano_mes')['valor'].sum().reset_index()
        
        if len(mensal) < 2:
            return {
                'categoria_id': categoria_id,
                'previsao': round(float(mensal['valor'].iloc[0]), 2),
                'confianca': 40,
                'mensagem': 'Previsão baseada em único mês'
            }
        
        media = mensal['valor'].mean()
        desvio = mensal['valor'].std()
        
        confianca = 70 if desvio / media < 0.3 else 50 if desvio / media < 0.5 else 30
        
        return {
            'categoria_id': categoria_id,
            'previsao': round(float(media), 2),
            'confianca': confianca,
            'mensagem': 'Previsão baseada em média histórica',
            'detalhes': {
                'media': round(float(media), 2),
                'desvio_padrao': round(float(desvio), 2),
                'meses_analisados': len(mensal)
            }
        }
    
    def analisar_sazonalidade(self) -> Dict:
        df = self.obter_historico_mensal(12)
        
        if df.empty:
            return {
                'sazonalidade_detectada': False,
                'mensagem': 'Dados insuficientes'
            }
        
        despesas = df[df['tipo'] == 'despesa']
        
        if despesas.empty:
            return {
                'sazonalidade_detectada': False,
                'mensagem': 'Sem histórico de despesas'
            }
        
        por_mes = despesas.groupby('mes')['valor'].agg(['mean', 'count']).reset_index()
        
        if len(por_mes) < 3:
            return {
                'sazonalidade_detectada': False,
                'mensagem': 'Período muito curto para análise'
            }
        
        media_geral = por_mes['mean'].mean()
        desvio = por_mes['mean'].std()
        
        meses_alto = por_mes[por_mes['mean'] > media_geral + desvio]
        meses_baixo = por_mes[por_mes['mean'] < media_geral - desvio]
        
        sazonalidade_detectada = len(meses_alto) > 0 or len(meses_baixo) > 0
        
        meses_nome = {
            1: 'Janeiro', 2: 'Fevereiro', 3: 'Março', 4: 'Abril',
            5: 'Maio', 6: 'Junho', 7: 'Julho', 8: 'Agosto',
            9: 'Setembro', 10: 'Outubro', 11: 'Novembro', 12: 'Dezembro'
        }
        
        return {
            'sazonalidade_detectada': sazonalidade_detectada,
            'meses_maior_gasto': [
                {
                    'mes': meses_nome[int(row['mes'])],
                    'valor_medio': round(float(row['mean']), 2)
                }
                for _, row in meses_alto.iterrows()
            ],
            'meses_menor_gasto': [
                {
                    'mes': meses_nome[int(row['mes'])],
                    'valor_medio': round(float(row['mean']), 2)
                }
                for _, row in meses_baixo.iterrows()
            ],
            'media_geral': round(float(media_geral), 2)
        }
    
    def calcular_orcamento_sugerido(self) -> Dict:
        previsao = self.prever_gastos_proximo_mes()
        
        if previsao['previsao_total'] == 0:
            return {
                'orcamento_sugerido': 0,
                'mensagem': 'Dados insuficientes para sugestão'
            }
        
        margem_seguranca = 1.1
        orcamento_sugerido = previsao['previsao_total'] * margem_seguranca
        
        return {
            'orcamento_sugerido': round(orcamento_sugerido, 2),
            'previsao_base': previsao['previsao_total'],
            'margem_seguranca': '10%',
            'confianca': previsao['confianca'],
            'recomendacao': (
                'Sugerimos um orçamento com 10% de margem de segurança '
                'para cobrir imprevistos.'
            )
        }

