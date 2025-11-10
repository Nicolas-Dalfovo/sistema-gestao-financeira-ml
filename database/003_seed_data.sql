-- Categorias padrão do sistema (usuario_id = NULL indica categoria global)

-- Categorias de Despesas
INSERT INTO categoria (usuario_id, nome, tipo, icone, cor, descricao, ativa) VALUES
(NULL, 'Alimentação', 'despesa', 'restaurant', '#FF5722', 'Gastos com alimentação, restaurantes e delivery', TRUE),
(NULL, 'Transporte', 'despesa', 'directions_car', '#2196F3', 'Combustível, transporte público, aplicativos de transporte', TRUE),
(NULL, 'Moradia', 'despesa', 'home', '#9C27B0', 'Aluguel, condomínio, IPTU, manutenção', TRUE),
(NULL, 'Saúde', 'despesa', 'local_hospital', '#4CAF50', 'Plano de saúde, medicamentos, consultas', TRUE),
(NULL, 'Educação', 'despesa', 'school', '#FF9800', 'Mensalidades, cursos, livros, material escolar', TRUE),
(NULL, 'Lazer', 'despesa', 'sports_esports', '#E91E63', 'Cinema, shows, viagens, hobbies', TRUE),
(NULL, 'Vestuário', 'despesa', 'checkroom', '#00BCD4', 'Roupas, calçados, acessórios', TRUE),
(NULL, 'Beleza', 'despesa', 'face', '#F44336', 'Salão, cosméticos, cuidados pessoais', TRUE),
(NULL, 'Contas', 'despesa', 'receipt', '#607D8B', 'Água, luz, internet, telefone, streaming', TRUE),
(NULL, 'Mercado', 'despesa', 'shopping_cart', '#8BC34A', 'Compras de supermercado', TRUE),
(NULL, 'Pets', 'despesa', 'pets', '#795548', 'Ração, veterinário, produtos para pets', TRUE),
(NULL, 'Investimentos', 'despesa', 'trending_up', '#3F51B5', 'Aplicações financeiras, ações, fundos', TRUE),
(NULL, 'Seguros', 'despesa', 'security', '#009688', 'Seguro de vida, carro, residência', TRUE),
(NULL, 'Impostos', 'despesa', 'account_balance', '#FF5252', 'IPVA, IR, taxas governamentais', TRUE),
(NULL, 'Doações', 'despesa', 'volunteer_activism', '#673AB7', 'Doações e contribuições', TRUE),
(NULL, 'Outros', 'despesa', 'more_horiz', '#9E9E9E', 'Despesas diversas não categorizadas', TRUE);

-- Categorias de Receitas
INSERT INTO categoria (usuario_id, nome, tipo, icone, cor, descricao, ativa) VALUES
(NULL, 'Salário', 'receita', 'payments', '#4CAF50', 'Salário mensal', TRUE),
(NULL, 'Freelance', 'receita', 'work', '#2196F3', 'Trabalhos freelance e projetos', TRUE),
(NULL, 'Investimentos', 'receita', 'account_balance_wallet', '#FF9800', 'Rendimentos de investimentos', TRUE),
(NULL, 'Aluguel', 'receita', 'apartment', '#9C27B0', 'Receita de aluguéis', TRUE),
(NULL, 'Vendas', 'receita', 'store', '#00BCD4', 'Vendas de produtos ou serviços', TRUE),
(NULL, 'Prêmios', 'receita', 'emoji_events', '#FFC107', 'Prêmios e bonificações', TRUE),
(NULL, 'Restituição', 'receita', 'assignment_return', '#8BC34A', 'Restituição de impostos', TRUE),
(NULL, 'Presente', 'receita', 'card_giftcard', '#E91E63', 'Presentes recebidos em dinheiro', TRUE),
(NULL, 'Outros', 'receita', 'more_horiz', '#9E9E9E', 'Receitas diversas não categorizadas', TRUE);

-- Usuário de exemplo para testes (senha: senha123)
-- Hash bcrypt de 'senha123': $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYr8P8zRm
INSERT INTO usuario (nome, email, senha_hash, data_nascimento, moeda_padrao, ativo) VALUES
('Usuário Teste', 'teste@exemplo.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYr8P8zRm', '1990-01-01', 'BRL', TRUE);

-- Obter o ID do usuário criado
DO $$
DECLARE
    v_usuario_id INTEGER;
BEGIN
    SELECT id INTO v_usuario_id FROM usuario WHERE email = 'teste@exemplo.com';
    
    -- Criar conta bancária de exemplo
    INSERT INTO conta_bancaria (usuario_id, nome, tipo, banco, saldo_inicial, saldo_atual, cor, ativa) VALUES
    (v_usuario_id, 'Conta Corrente', 'corrente', 'Banco do Brasil', 1000.00, 1000.00, '#FFC107', TRUE),
    (v_usuario_id, 'Poupança', 'poupanca', 'Banco do Brasil', 5000.00, 5000.00, '#4CAF50', TRUE),
    (v_usuario_id, 'Carteira', 'carteira', NULL, 200.00, 200.00, '#9C27B0', TRUE);
    
    -- Criar meta de exemplo
    INSERT INTO meta (usuario_id, nome, descricao, valor_alvo, valor_atual, data_inicio, data_fim, status, prioridade, icone, cor) VALUES
    (v_usuario_id, 'Viagem de Férias', 'Juntar dinheiro para viagem de férias', 5000.00, 0.00, CURRENT_DATE, CURRENT_DATE + INTERVAL '6 months', 'ativa', 3, 'flight', '#2196F3'),
    (v_usuario_id, 'Reserva de Emergência', 'Criar fundo de emergência', 10000.00, 0.00, CURRENT_DATE, CURRENT_DATE + INTERVAL '12 months', 'ativa', 5, 'security', '#F44336');
    
    -- Criar orçamento do mês atual
    INSERT INTO orcamento (usuario_id, nome, mes, ano, valor_total, valor_gasto, ativo) VALUES
    (v_usuario_id, 'Orçamento ' || TO_CHAR(CURRENT_DATE, 'Month YYYY'), 
     EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER, 
     EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER, 
     3000.00, 0.00, TRUE);
    
END $$;

-- Views úteis para relatórios

-- View de resumo mensal por usuário
CREATE OR REPLACE VIEW v_resumo_mensal AS
SELECT 
    t.usuario_id,
    EXTRACT(YEAR FROM t.data_transacao) AS ano,
    EXTRACT(MONTH FROM t.data_transacao) AS mes,
    SUM(CASE WHEN t.tipo = 'receita' THEN t.valor ELSE 0 END) AS total_receitas,
    SUM(CASE WHEN t.tipo = 'despesa' THEN t.valor ELSE 0 END) AS total_despesas,
    SUM(CASE WHEN t.tipo = 'receita' THEN t.valor ELSE -t.valor END) AS saldo
FROM transacao t
WHERE t.efetivada = TRUE
GROUP BY t.usuario_id, EXTRACT(YEAR FROM t.data_transacao), EXTRACT(MONTH FROM t.data_transacao);

-- View de gastos por categoria
CREATE OR REPLACE VIEW v_gastos_categoria AS
SELECT 
    t.usuario_id,
    c.id AS categoria_id,
    c.nome AS categoria_nome,
    c.tipo AS categoria_tipo,
    c.cor AS categoria_cor,
    EXTRACT(YEAR FROM t.data_transacao) AS ano,
    EXTRACT(MONTH FROM t.data_transacao) AS mes,
    COUNT(t.id) AS quantidade_transacoes,
    SUM(t.valor) AS total
FROM transacao t
INNER JOIN categoria c ON t.categoria_id = c.id
WHERE t.efetivada = TRUE
GROUP BY t.usuario_id, c.id, c.nome, c.tipo, c.cor, 
         EXTRACT(YEAR FROM t.data_transacao), EXTRACT(MONTH FROM t.data_transacao);

-- View de progresso de metas
CREATE OR REPLACE VIEW v_progresso_metas AS
SELECT 
    m.id,
    m.usuario_id,
    m.nome,
    m.valor_alvo,
    m.valor_atual,
    m.data_inicio,
    m.data_fim,
    m.status,
    m.prioridade,
    ROUND((m.valor_atual / m.valor_alvo) * 100, 2) AS percentual_completo,
    m.valor_alvo - m.valor_atual AS valor_faltante,
    CURRENT_DATE - m.data_inicio AS dias_decorridos,
    m.data_fim - CURRENT_DATE AS dias_restantes
FROM meta m;

-- View de saldo por conta
CREATE OR REPLACE VIEW v_saldo_contas AS
SELECT 
    cb.id,
    cb.usuario_id,
    cb.nome,
    cb.tipo,
    cb.banco,
    cb.saldo_inicial,
    cb.saldo_atual,
    cb.saldo_atual - cb.saldo_inicial AS variacao,
    cb.cor,
    cb.ativa
FROM conta_bancaria cb;

-- View de status de orçamento
CREATE OR REPLACE VIEW v_status_orcamento AS
SELECT 
    o.id,
    o.usuario_id,
    o.nome,
    o.mes,
    o.ano,
    o.valor_total,
    o.valor_gasto,
    o.valor_total - o.valor_gasto AS valor_disponivel,
    ROUND((o.valor_gasto / o.valor_total) * 100, 2) AS percentual_gasto,
    CASE 
        WHEN o.valor_gasto > o.valor_total THEN 'excedido'
        WHEN o.valor_gasto >= o.valor_total * 0.9 THEN 'critico'
        WHEN o.valor_gasto >= o.valor_total * 0.7 THEN 'atencao'
        ELSE 'normal'
    END AS status
FROM orcamento o
WHERE o.ativo = TRUE;

-- Comentários nas views
COMMENT ON VIEW v_resumo_mensal IS 'Resumo mensal de receitas, despesas e saldo por usuário';
COMMENT ON VIEW v_gastos_categoria IS 'Total de gastos agrupados por categoria e período';
COMMENT ON VIEW v_progresso_metas IS 'Progresso e status das metas financeiras';
COMMENT ON VIEW v_saldo_contas IS 'Saldo e variação das contas bancárias';
COMMENT ON VIEW v_status_orcamento IS 'Status e percentual de utilização dos orçamentos';

