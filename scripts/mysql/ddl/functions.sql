-- ================================================================
-- functions.sql -- Functions do 3 bimestre (MySQL)
-- ================================================================
USE biblioteca;

DELIMITER $$

-- fn_calcular_multa
-- Objetivo: calcular o valor da multa por atraso de um emprestimo.
-- Parametro: p_id_emprestimo (CHAR 36)
-- Retorno: DECIMAL(8,2) -- valor da multa em reais (R$ 1,50 por dia)
CREATE FUNCTION fn_calcular_multa(p_id_emprestimo CHAR(36))
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status    ENUM('pendente','atrasado','devolvido');
    DECLARE v_prevista  DATE;
    DECLARE v_real      DATE;
    DECLARE v_dias      INT DEFAULT 0;
    DECLARE c_valor_dia DECIMAL(8,2) DEFAULT 1.50;

    SELECT status, data_devolucao_prevista, data_devolucao_real
      INTO v_status, v_prevista, v_real
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status = 'devolvido' THEN
        SET v_dias = GREATEST(DATEDIFF(v_real, v_prevista), 0);
    ELSEIF v_status = 'atrasado' THEN
        SET v_dias = GREATEST(DATEDIFF(CURDATE(), v_prevista), 0);
    ELSE
        SET v_dias = 0;
    END IF;

    RETURN v_dias * c_valor_dia;
END$$

-- fn_classificar_situacao
-- Objetivo: classificar a situacao atual de um emprestimo, reavaliando
-- inclusive emprestimos "pendente" cujo prazo ja passou (nao
-- reclassificados ainda no status armazenado).
-- Parametro: p_id_emprestimo (CHAR 36)
-- Retorno: VARCHAR(30)
CREATE FUNCTION fn_classificar_situacao(p_id_emprestimo CHAR(36))
RETURNS VARCHAR(30)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status   ENUM('pendente','atrasado','devolvido');
    DECLARE v_prevista DATE;
    DECLARE v_real     DATE;
    DECLARE v_situacao VARCHAR(30);

    SELECT status, data_devolucao_prevista, data_devolucao_real
      INTO v_status, v_prevista, v_real
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status = 'devolvido' THEN
        IF v_real > v_prevista THEN
            SET v_situacao = 'Devolvido com atraso';
        ELSE
            SET v_situacao = 'Devolvido no prazo';
        END IF;
    ELSEIF v_status = 'atrasado' THEN
        SET v_situacao = 'Atrasado';
    ELSEIF CURDATE() > v_prevista THEN
        SET v_situacao = 'Atrasado (a regularizar)';
    ELSE
        SET v_situacao = 'No prazo';
    END IF;

    RETURN v_situacao;
END$$

DELIMITER ;
