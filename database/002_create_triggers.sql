-- Função para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION atualizar_data_modificacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar data_atualizacao na tabela usuario
CREATE TRIGGER trigger_usuario_atualizacao
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_data_modificacao();

-- Trigger para atualizar data_atualizacao na tabela configuracao_usuario
CREATE TRIGGER trigger_config_atualizacao
    BEFORE UPDATE ON configuracao_usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_data_modificacao();

-- Função para atualizar saldo da conta após inserção de transação
CREATE OR REPLACE FUNCTION atualizar_saldo_conta_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.efetivada = TRUE THEN
        IF NEW.tipo = 'receita' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual + NEW.valor
            WHERE id = NEW.conta_id;
        ELSIF NEW.tipo = 'despesa' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual - NEW.valor
            WHERE id = NEW.conta_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar saldo da conta após atualização de transação
CREATE OR REPLACE FUNCTION atualizar_saldo_conta_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.efetivada = TRUE THEN
        IF OLD.tipo = 'receita' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual - OLD.valor
            WHERE id = OLD.conta_id;
        ELSIF OLD.tipo = 'despesa' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual + OLD.valor
            WHERE id = OLD.conta_id;
        END IF;
    END IF;
    
    IF NEW.efetivada = TRUE THEN
        IF NEW.tipo = 'receita' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual + NEW.valor
            WHERE id = NEW.conta_id;
        ELSIF NEW.tipo = 'despesa' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual - NEW.valor
            WHERE id = NEW.conta_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar saldo da conta após exclusão de transação
CREATE OR REPLACE FUNCTION atualizar_saldo_conta_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.efetivada = TRUE THEN
        IF OLD.tipo = 'receita' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual - OLD.valor
            WHERE id = OLD.conta_id;
        ELSIF OLD.tipo = 'despesa' THEN
            UPDATE conta_bancaria
            SET saldo_atual = saldo_atual + OLD.valor
            WHERE id = OLD.conta_id;
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar saldo da conta
CREATE TRIGGER trigger_transacao_insert_saldo
    AFTER INSERT ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_saldo_conta_insert();

CREATE TRIGGER trigger_transacao_update_saldo
    AFTER UPDATE ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_saldo_conta_update();

CREATE TRIGGER trigger_transacao_delete_saldo
    AFTER DELETE ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_saldo_conta_delete();

-- Função para atualizar valor gasto no orçamento
CREATE OR REPLACE FUNCTION atualizar_orcamento_gasto()
RETURNS TRIGGER AS $$
DECLARE
    v_orcamento_id INTEGER;
    v_mes INTEGER;
    v_ano INTEGER;
BEGIN
    IF NEW.tipo = 'despesa' AND NEW.efetivada = TRUE THEN
        v_mes := EXTRACT(MONTH FROM NEW.data_transacao);
        v_ano := EXTRACT(YEAR FROM NEW.data_transacao);
        
        SELECT id INTO v_orcamento_id
        FROM orcamento
        WHERE usuario_id = NEW.usuario_id
          AND mes = v_mes
          AND ano = v_ano
          AND ativo = TRUE
        LIMIT 1;
        
        IF v_orcamento_id IS NOT NULL THEN
            UPDATE orcamento
            SET valor_gasto = valor_gasto + NEW.valor
            WHERE id = v_orcamento_id;
            
            UPDATE orcamento_categoria
            SET valor_gasto = valor_gasto + NEW.valor
            WHERE orcamento_id = v_orcamento_id
              AND categoria_id = NEW.categoria_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_transacao_orcamento
    AFTER INSERT ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_orcamento_gasto();

-- Função para verificar limite de orçamento e gerar notificação
CREATE OR REPLACE FUNCTION verificar_limite_orcamento()
RETURNS TRIGGER AS $$
DECLARE
    v_percentual_gasto DECIMAL;
    v_categoria_nome VARCHAR(50);
BEGIN
    v_percentual_gasto := (NEW.valor_gasto / NEW.valor_limite) * 100;
    
    IF v_percentual_gasto >= NEW.alerta_percentual THEN
        SELECT nome INTO v_categoria_nome
        FROM categoria
        WHERE id = NEW.categoria_id;
        
        INSERT INTO notificacao (usuario_id, tipo, titulo, mensagem)
        SELECT o.usuario_id, 'orcamento',
               'Alerta de Orçamento',
               'Você atingiu ' || ROUND(v_percentual_gasto, 0) || '% do limite da categoria "' || v_categoria_nome || '"'
        FROM orcamento o
        WHERE o.id = NEW.orcamento_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_alerta_orcamento
    AFTER UPDATE OF valor_gasto ON orcamento_categoria
    FOR EACH ROW
    WHEN (NEW.valor_gasto > OLD.valor_gasto)
    EXECUTE FUNCTION verificar_limite_orcamento();

-- Função para processar transferências entre contas
CREATE OR REPLACE FUNCTION processar_transferencia()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conta_bancaria
    SET saldo_atual = saldo_atual - NEW.valor
    WHERE id = NEW.conta_origem_id;
    
    UPDATE conta_bancaria
    SET saldo_atual = saldo_atual + NEW.valor
    WHERE id = NEW.conta_destino_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_transferencia_insert
    AFTER INSERT ON transferencia
    FOR EACH ROW
    EXECUTE FUNCTION processar_transferencia();

-- Função para criar configuração padrão ao criar usuário
CREATE OR REPLACE FUNCTION criar_configuracao_padrao()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO configuracao_usuario (usuario_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_usuario_config
    AFTER INSERT ON usuario
    FOR EACH ROW
    EXECUTE FUNCTION criar_configuracao_padrao();

-- Função para validar categoria antes de inserir transação
CREATE OR REPLACE FUNCTION validar_categoria_transacao()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_categoria VARCHAR(10);
BEGIN
    SELECT tipo INTO v_tipo_categoria
    FROM categoria
    WHERE id = NEW.categoria_id;
    
    IF v_tipo_categoria != NEW.tipo THEN
        RAISE EXCEPTION 'Tipo da transação (%) não corresponde ao tipo da categoria (%)', NEW.tipo, v_tipo_categoria;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_categoria
    BEFORE INSERT OR UPDATE ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION validar_categoria_transacao();

-- Função para atualizar progresso de metas
CREATE OR REPLACE FUNCTION atualizar_progresso_meta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'receita' AND NEW.efetivada = TRUE THEN
        UPDATE meta
        SET valor_atual = valor_atual + NEW.valor
        WHERE usuario_id = NEW.usuario_id
          AND status = 'ativa'
          AND data_inicio <= NEW.data_transacao
          AND data_fim >= NEW.data_transacao;
    END IF;
    
    UPDATE meta
    SET status = 'concluida'
    WHERE usuario_id = NEW.usuario_id
      AND status = 'ativa'
      AND valor_atual >= valor_alvo;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_meta_progresso
    AFTER INSERT ON transacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_progresso_meta();

-- Função para marcar notificação como lida
CREATE OR REPLACE FUNCTION marcar_notificacao_lida()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.lida = TRUE AND OLD.lida = FALSE THEN
        NEW.data_leitura = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notificacao_lida
    BEFORE UPDATE ON notificacao
    FOR EACH ROW
    EXECUTE FUNCTION marcar_notificacao_lida();

-- Função para calcular percentual de progresso da meta
CREATE OR REPLACE FUNCTION calcular_percentual_meta(p_meta_id INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    v_percentual DECIMAL;
BEGIN
    SELECT (valor_atual / valor_alvo) * 100 INTO v_percentual
    FROM meta
    WHERE id = p_meta_id;
    
    RETURN COALESCE(v_percentual, 0);
END;
$$ LANGUAGE plpgsql;

-- Função para obter total de receitas em um período
CREATE OR REPLACE FUNCTION total_receitas(p_usuario_id INTEGER, p_data_inicio DATE, p_data_fim DATE)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(valor), 0) INTO v_total
    FROM transacao
    WHERE usuario_id = p_usuario_id
      AND tipo = 'receita'
      AND efetivada = TRUE
      AND data_transacao BETWEEN p_data_inicio AND p_data_fim;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Função para obter total de despesas em um período
CREATE OR REPLACE FUNCTION total_despesas(p_usuario_id INTEGER, p_data_inicio DATE, p_data_fim DATE)
RETURNS DECIMAL AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(valor), 0) INTO v_total
    FROM transacao
    WHERE usuario_id = p_usuario_id
      AND tipo = 'despesa'
      AND efetivada = TRUE
      AND data_transacao BETWEEN p_data_inicio AND p_data_fim;
    
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Função para obter saldo em um período
CREATE OR REPLACE FUNCTION saldo_periodo(p_usuario_id INTEGER, p_data_inicio DATE, p_data_fim DATE)
RETURNS DECIMAL AS $$
BEGIN
    RETURN total_receitas(p_usuario_id, p_data_inicio, p_data_fim) - 
           total_despesas(p_usuario_id, p_data_inicio, p_data_fim);
END;
$$ LANGUAGE plpgsql;

