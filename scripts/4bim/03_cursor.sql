-- ================================================================
-- 03_cursor.sql -- Procedure com CURSOR (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================

USE biblioteca;

DROP PROCEDURE IF EXISTS sp_atualizar_atrasos;

DELIMITER $$

-- ----------------------------------------------------------------
-- Procedure: sp_atualizar_atrasos (cursor) | Responsavel: Rafael de Almeida
-- Objetivo: rotina diaria da biblioteca. Percorre, um a um, os
-- emprestimos 'pendente' cujo prazo ja venceu, marca cada um como
-- 'atrasado', calcula a multa acumulada ate a data de referencia e
-- monta um relatorio do que foi processado.
-- Por que cursor: cada linha recebe um tratamento individual
-- (UPDATE proprio -> dispara a trigger de auditoria por registro,
-- calculo da multa e linha no relatorio).
-- Parametros: IN p_data_referencia (NULL = hoje),
--             OUT p_qtd_atualizados, OUT p_multa_total
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_atualizar_atrasos(
    IN  p_data_referencia DATE,
    OUT p_qtd_atualizados INT,
    OUT p_multa_total     DECIMAL(10, 2)
)
BEGIN
    DECLARE v_fim         BOOLEAN DEFAULT FALSE;
    DECLARE v_id          CHAR(36);
    DECLARE v_prevista    DATE;
    DECLARE v_titulo      VARCHAR(255);
    DECLARE v_usuario     VARCHAR(100);
    DECLARE v_dias        INT;
    DECLARE v_multa       DECIMAL(8, 2);
    DECLARE v_data_ref    DATE;

    -- 1) Declaracao do cursor: o conjunto de linhas a percorrer
    DECLARE cur_vencidos CURSOR FOR
        SELECT e.id_emprestimo, e.data_devolucao_prevista, l.titulo, u.nome
        FROM emprestimos e
        JOIN livros   l ON l.id_livro   = e.id_livro
        JOIN usuarios u ON u.id_usuario = e.id_usuario
        WHERE e.status = 'pendente'
          AND e.data_devolucao_prevista < v_data_ref
        ORDER BY e.data_devolucao_prevista;

    -- 2) Handler: quando o FETCH nao encontrar mais linhas, liga v_fim
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim = TRUE;

    SET v_data_ref = IFNULL(p_data_referencia, CURDATE());

    IF v_data_ref > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de referencia nao pode estar no futuro';
    END IF;

    SET p_qtd_atualizados = 0;
    SET p_multa_total     = 0;

    DROP TEMPORARY TABLE IF EXISTS tmp_atrasos_processados;
    CREATE TEMPORARY TABLE tmp_atrasos_processados (
        usuario      VARCHAR(100),
        livro        VARCHAR(255),
        prevista     DATE,
        dias_atraso  INT,
        multa        DECIMAL(8, 2)
    );

    -- 3) Abertura: executa o SELECT do cursor
    OPEN cur_vencidos;

    leitura: LOOP
        -- 4) Leitura de uma linha por vez
        FETCH cur_vencidos INTO v_id, v_prevista, v_titulo, v_usuario;

        -- 5) Saida do laco quando acabaram as linhas
        IF v_fim THEN
            LEAVE leitura;
        END IF;

        SET v_dias  = DATEDIFF(v_data_ref, v_prevista);
        SET v_multa = LEAST(v_dias, 30) * 1.50;

        UPDATE emprestimos
        SET status = 'atrasado'
        WHERE id_emprestimo = v_id;

        INSERT INTO tmp_atrasos_processados
        VALUES (v_usuario, v_titulo, v_prevista, v_dias, v_multa);

        SET p_qtd_atualizados = p_qtd_atualizados + 1;
        SET p_multa_total     = p_multa_total + v_multa;
    END LOOP leitura;

    -- 6) Fechamento: libera o cursor
    CLOSE cur_vencidos;

    SELECT * FROM tmp_atrasos_processados;
END$$

DELIMITER ;
