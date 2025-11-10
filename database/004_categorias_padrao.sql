
-- Categorias de DESPESA
INSERT INTO categorias (nome, tipo, icone, cor, usuario_id) VALUES
('Alimentação', 'despesa', 'restaurant', '#FF5252', 1),
('Transporte', 'despesa', 'directions_car', '#FF9800', 1),
('Moradia', 'despesa', 'home', '#9C27B0', 1),
('Saúde', 'despesa', 'local_hospital', '#F44336', 1),
('Educação', 'despesa', 'school', '#2196F3', 1),
('Lazer', 'despesa', 'sports_esports', '#4CAF50', 1),
('Vestuário', 'despesa', 'shopping_bag', '#E91E63', 1),
('Contas', 'despesa', 'receipt', '#795548', 1),
('Outros', 'despesa', 'more_horiz', '#9E9E9E', 1);

-- Categorias de RECEITA
INSERT INTO categorias (nome, tipo, icone, cor, usuario_id) VALUES
('Salário', 'receita', 'attach_money', '#4CAF50', 1),
('Freelance', 'receita', 'work', '#2196F3', 1),
('Investimentos', 'receita', 'trending_up', '#00BCD4', 1),
('Vendas', 'receita', 'shopping_cart', '#8BC34A', 1),
('Outros', 'receita', 'more_horiz', '#607D8B', 1);