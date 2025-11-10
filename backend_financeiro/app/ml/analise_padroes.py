import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import List, Dict, Tuple
from sqlalchemy.orm import Session
from ..models.models import Transacao, Categoria

class AnalisePadroes:
    def __init__(self, db: Session, usuario_id: int):
        self.db = db
        self.usuario_id = usuario_id
    
    def obter_transacoes_periodo(self, data_inicio: datetime, data_fim: datetime) -> pd.DataFrame:
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
                'id': t.id,
                'tipo': t.tipo,
                'valor': float(t.valor),
                'data': t.data_transacao,
                'categoria_id': t.categoria_id,
                'descricao': t.descricao,
                'dia_semana': t.data_transacao.weekday(),
                'dia_mes': t.data_transacao.day,
                'mes': t.data_transacao.month,
                'ano': t.data_transacao.year
            })
        
        df = pd.DataFrame(data)
        return df
    
    def analisar_gastos_por_categoria(self, periodo_dias: int = 30) -> Dict:
        data_fim = datetime.now().date()
        data_inicio = data_fim - timedelta(days=periodo_dias)
        
        df = self.obter_transacoes_periodo(data_inicio, data_fim)
        
        if df.empty:
            return {
                'periodo': {'inicio': str(data_inicio), 'fim': str(data_fim)},
                'categorias': [],
                'total_despesas': 0,
                'total_receitas': 0
            }
        
        despesas = df[df['tipo'] == 'despesa']
        receitas = df[df['tipo'] == 'receita']
        
        gastos_categoria = despesas.groupby('categoria_id').agg({
            'valor': ['sum', 'mean', 'count']
        }).reset_index()
        
        categorias_info = []
        for _, row in gastos_categoria.iterrows():
            categoria_id = int(row['categoria_id'])
            categoria = self.db.query(Categoria).filter(Categoria.id == categoria_id).first()
            
            total = float(row[('valor', 'sum')])
            media = float(row[('valor', 'mean')])
            quantidade = int(row[('valor', 'count')])
            
            percentual = (total / despesas['valor'].sum() * 100) if not despesas.empty else 0
            
            categorias_info.append({
                'categoria_id': categoria_id,
                'categoria_nome': categoria.nome if categoria else 'Desconhecida',
                'total': round(total, 2),
                'media': round(media, 2),
                'quantidade': quantidade,
                'percentual': round(percentual, 2)
            })
        
        categorias_info.sort(key=lambda x: x['total'], reverse=True)
        
        return {
            'periodo': {'inicio': str(data_inicio), 'fim': str(data_fim)},
            'categorias': categorias_info,
            'total_despesas': round(float(despesas['valor'].sum()), 2) if not despesas.empty else 0,
            'total_receitas': round(float(receitas['valor'].sum()), 2) if not receitas.empty else 0
        }
    
    def detectar_anomalias(self, periodo_dias: int = 90) -> Dict:
        data_fim = datetime.now().date()
        data_inicio = data_fim - timedelta(days=periodo_dias)
        
        df = self.obter_transacoes_periodo(data_inicio, data_fim)
        
        if df.empty or len(df) < 10:
            return {
                'anomalias_detectadas': [],
                'total_anomalias': 0,
                'mensagem': 'Dados insuficientes para análise de anomalias'
            }
        
        despesas = df[df['tipo'] == 'despesa']
        
        anomalias = []
        
        for categoria_id in despesas['categoria_id'].unique():
            cat_data = despesas[despesas['categoria_id'] == categoria_id]
            
            if len(cat_data) < 5:
                continue
            
            media = cat_data['valor'].mean()
            desvio = cat_data['valor'].std()
            
            if desvio == 0:
                continue
            
            limite_superior = media + (2 * desvio)
            
            anomalias_cat = cat_data[cat_data['valor'] > limite_superior]
            
            for _, row in anomalias_cat.iterrows():
                categoria = self.db.query(Categoria).filter(Categoria.id == categoria_id).first()
                
                anomalias.append({
                    'transacao_id': int(row['id']),
                    'data': str(row['data']),
                    'valor': round(float(row['valor']), 2),
                    'categoria': categoria.nome if categoria else 'Desconhecida',
                    'media_categoria': round(float(media), 2),
                    'desvio_percentual': round(((row['valor'] - media) / media * 100), 2),
                    'descricao': row['descricao']
                })
        
        anomalias.sort(key=lambda x: x['desvio_percentual'], reverse=True)
        
        return {
            'anomalias_detectadas': anomalias,
            'total_anomalias': len(anomalias),
            'periodo_analise': {'inicio': str(data_inicio), 'fim': str(data_fim)}
        }
    
    def analisar_tendencias(self, periodo_meses: int = 6) -> Dict:
        data_fim = datetime.now().date()
        data_inicio = data_fim - timedelta(days=periodo_meses * 30)
        
        df = self.obter_transacoes_periodo(data_inicio, data_fim)
        
        if df.empty:
            return {
                'tendencias': [],
                'mensagem': 'Sem dados para análise de tendências'
            }
        
        df['ano_mes'] = df['ano'].astype(str) + '-' + df['mes'].astype(str).str.zfill(2)
        
        tendencias_mensal = df.groupby(['ano_mes', 'tipo']).agg({
            'valor': 'sum'
        }).reset_index()
        
        tendencias = []
        for tipo in ['receita', 'despesa']:
            dados_tipo = tendencias_mensal[tendencias_mensal['tipo'] == tipo]
            
            if len(dados_tipo) >= 2:
                valores = dados_tipo['valor'].values
                primeira_metade = valores[:len(valores)//2].mean()
                segunda_metade = valores[len(valores)//2:].mean()
                
                if primeira_metade > 0:
                    variacao = ((segunda_metade - primeira_metade) / primeira_metade) * 100
                else:
                    variacao = 0
                
                tendencias.append({
                    'tipo': tipo,
                    'media_inicial': round(float(primeira_metade), 2),
                    'media_recente': round(float(segunda_metade), 2),
                    'variacao_percentual': round(float(variacao), 2),
                    'tendencia': 'crescente' if variacao > 5 else 'decrescente' if variacao < -5 else 'estável'
                })
        
        return {
            'tendencias': tendencias,
            'periodo_analise': {'inicio': str(data_inicio), 'fim': str(data_fim)}
        }
    
    def gerar_insights(self) -> List[str]:
        insights = []
        
        analise_categoria = self.analisar_gastos_por_categoria(30)
        
        if analise_categoria['categorias']:
            maior_gasto = analise_categoria['categorias'][0]
            insights.append(
                f"Sua maior despesa é com {maior_gasto['categoria_nome']}, "
                f"representando {maior_gasto['percentual']:.1f}% do total."
            )
            
            if maior_gasto['percentual'] > 40:
                insights.append(
                    f"Atenção: {maior_gasto['categoria_nome']} está consumindo mais de 40% do seu orçamento. "
                    "Considere revisar esses gastos."
                )
        
        if analise_categoria['total_despesas'] > 0 and analise_categoria['total_receitas'] > 0:
            taxa_poupanca = ((analise_categoria['total_receitas'] - analise_categoria['total_despesas']) / 
                           analise_categoria['total_receitas']) * 100
            
            if taxa_poupanca > 20:
                insights.append(
                    f"Parabéns! Você está poupando {taxa_poupanca:.1f}% da sua renda. "
                    "Continue assim!"
                )
            elif taxa_poupanca < 0:
                insights.append(
                    "Atenção: Suas despesas estão maiores que suas receitas. "
                    "Revise seu orçamento para evitar endividamento."
                )
        
        anomalias = self.detectar_anomalias(90)
        if anomalias['total_anomalias'] > 0:
            insights.append(
                f"Detectamos {anomalias['total_anomalias']} transações com valores acima do normal. "
                "Verifique se são gastos esperados."
            )
        
        tendencias = self.analisar_tendencias(6)
        for tend in tendencias.get('tendencias', []):
            if tend['tipo'] == 'despesa' and tend['tendencia'] == 'crescente':
                insights.append(
                    f"Suas despesas estão crescendo ({tend['variacao_percentual']:.1f}%). "
                    "Fique atento ao seu orçamento."
                )
        
        return insights
    
    def gerar_recomendacoes(self) -> List[str]:
        recomendacoes = []
        
        analise_categoria = self.analisar_gastos_por_categoria(30)
        
        if analise_categoria['total_despesas'] > 0:
            for cat in analise_categoria['categorias'][:3]:
                if cat['percentual'] > 30:
                    recomendacoes.append(
                        f"Tente reduzir gastos com {cat['categoria_nome']} em 10-15%. "
                        f"Isso pode economizar R$ {cat['total'] * 0.1:.2f} por mês."
                    )
        
        if analise_categoria['total_receitas'] > 0:
            taxa_poupanca = ((analise_categoria['total_receitas'] - analise_categoria['total_despesas']) / 
                           analise_categoria['total_receitas']) * 100
            
            if taxa_poupanca < 10:
                recomendacoes.append(
                    "Tente poupar pelo menos 10% da sua renda mensal. "
                    "Comece com pequenas economias diárias."
                )
        
        recomendacoes.append(
            "Defina metas financeiras claras e acompanhe seu progresso mensalmente."
        )
        
        recomendacoes.append(
            "Revise seus gastos recorrentes e cancele assinaturas que não utiliza."
        )
        
        return recomendacoes

