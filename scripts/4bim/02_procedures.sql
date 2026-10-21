-- ================================================================
-- 02_procedures.sql -- Stored Procedures (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Regra de multa usada em todo o sistema: R$ 1,50 por dia de atraso,
-- limitada a 30 dias (teto de R$ 45,00).
-- Todas as mensagens de erro usam SQLSTATE '45000' (erro definido
-- pelo usuario) -- no Workbench aparecem como "Error Code: 1644".
-- ================================================================

USE biblioteca;

DROP PROCEDURE IF EXISTS sp_registrar_emprestimo;
DROP PROCEDURE IF EXISTS sp_registrar_devolucao;
DROP PROCEDURE IF EXISTS sp_relatorio_emprestimos_usuario;
DROP PROCEDURE IF EXISTS sp_resumo_usuario;
DROP PROCEDURE IF EXISTS sp_renovar_emprestimo;

DELIMITER $$

-- ----------------------------------------------------------------
-- Procedure: sp_registrar_emprestimo | Responsavel: Gustavo Vianna
-- Tipo: cadastro com validacao (obrigatorio "a")
-- Objetivo: registrar um novo emprestimo a partir do e-mail do
-- usuario e do titulo do livro.
-- Regras: usuario e livro precisam existir; prazo entre 1 e 30 dias;
-- usuario com emprestimo em atraso fica bloqueado; maximo de 3
-- emprestimos ativos por usuario. A disponibilidade do exemplar e
-- validada pela trigger trg_emprestimos_before_insert.
-- Parametros: IN p_email, IN p_titulo, IN p_dias_prazo,
--             OUT p_id_emprestimo (id gerado)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_registrar_emprestimo(
    IN  p_email         VARCHAR(100),
    IN  p_titulo        VARCHAR(255),
    IN  p_dias_prazo    INT,
    OUT p_id_emprestimo CHAR(36)
)
BEGIN
    DECLARE v_id_usuario CHAR(36);
    DECLARE v_id_livro   CHAR(36);
    DECLARE v_ativos     INT DEFAULT 0;
    DECLARE v_atrasados  INT DEFAULT 0;
    DECLARE v_id_novo    CHAR(36);
    DECLARE v_msg        VARCHAR(255);
    DECLARE c_limite     INT DEFAULT 3;

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    SELECT id_livro INTO v_id_livro
    FROM livros
    WHERE titulo = p_titulo;

    -- Atrasado = status 'atrasado' OU pendente com prazo ja vencido
    SELECT COUNT(*),
           COALESCE(SUM(status = 'atrasado'
                        OR data_devolucao_prevista < CURDATE()), 0)
      INTO v_ativos, v_atrasados
    FROM emprestimos
    WHERE id_usuario = v_id_usuario
      AND status <> 'devolvido';

    IF v_id_usuario IS NULL THEN
        SET v_msg = CONCAT('Usuario nao encontrado: ', IFNULL(p_email, 'NULL'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF v_id_livro IS NULL THEN
        SET v_msg = CONCAT('Livro nao encontrado: ', IFNULL(p_titulo, 'NULL'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF p_dias_prazo IS NULL OR p_dias_prazo NOT BETWEEN 1 AND 30 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo invalido: informe de 1 a 30 dias';
    ELSEIF v_atrasados > 0 THEN
        SET v_msg = CONCAT('Usuario bloqueado: possui ', v_atrasados,
                           ' emprestimo(s) em atraso');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF v_ativos >= c_limite THEN
        SET v_msg = CONCAT('Limite de ', c_limite, ' emprestimos ativos atingido');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    SET v_id_novo = UUID();

    INSERT INTO emprestimos (id_emprestimo, id_livro, id_usuario, data_saida,
                             data_devolucao_prevista, status)
    VALUES (v_id_novo, v_id_livro, v_id_usuario, CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL p_dias_prazo DAY), 'pendente');

    SET p_id_emprestimo = v_id_novo;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_registrar_devolucao | Responsavel: Gabriel Cardoso
-- Tipo: alteracao com validacao + parametro OUT (obrigatorio "c")
-- Objetivo: dar baixa em um emprestimo e devolver a multa devida.
-- Regras: o emprestimo precisa existir e nao pode ja estar devolvido;
-- multa de R$ 1,50 por dia de atraso com teto de 30 dias (CASE).
-- Parametros: IN p_id_emprestimo, OUT p_multa
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_registrar_devolucao(
    IN  p_id_emprestimo CHAR(36),
    OUT p_multa         DECIMAL(8, 2)
)
BEGIN
    DECLARE v_status      VARCHAR(10);
    DECLARE v_prevista    DATE;
    DECLARE v_dias_atraso INT DEFAULT 0;
    DECLARE c_valor_dia   DECIMAL(8, 2) DEFAULT 1.50;

    SELECT status, data_devolucao_prevista
      INTO v_status, v_prevista
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emprestimo nao encontrado';
    ELSEIF v_status = 'devolvido' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este emprestimo ja foi devolvido';
    END IF;

    SET v_dias_atraso = GREATEST(DATEDIFF(CURDATE(), v_prevista), 0);

    SET p_multa = CASE
                      WHEN v_dias_atraso = 0  THEN 0
                      WHEN v_dias_atraso <= 30 THEN v_dias_atraso * c_valor_dia
                      ELSE 30 * c_valor_dia
                  END;

    -- data_devolucao_real e preenchida pela trigger BEFORE UPDATE
    UPDATE emprestimos
    SET status = 'devolvido'
    WHERE id_emprestimo = p_id_emprestimo;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_relatorio_emprestimos_usuario | Responsavel: Rafael de Almeida
-- Tipo: consulta/relatorio com parametros (obrigatorio "b")
-- Objetivo: listar os emprestimos de um usuario em um periodo, com a
-- situacao de cada um e a multa calculada.
-- Regras: usuario precisa existir; data inicial <= data final.
-- Parametros: IN p_email, IN p_data_inicio, IN p_data_fim
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_relatorio_emprestimos_usuario(
    IN p_email       VARCHAR(100),
    IN p_data_inicio DATE,
    IN p_data_fim    DATE
)
BEGIN
    DECLARE v_id_usuario CHAR(36);

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario nao encontrado';
    ELSEIF p_data_inicio IS NULL OR p_data_fim IS NULL OR p_data_inicio > p_data_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Periodo invalido: data inicial deve ser menor ou igual a final';
    END IF;

    SELECT l.titulo,
           e.data_saida,
           e.data_devolucao_prevista AS prevista,
           e.data_devolucao_real     AS devolvido_em,
           CASE
               WHEN e.status = 'devolvido' AND e.data_devolucao_real > e.data_devolucao_prevista
                   THEN 'Devolvido com atraso'
               WHEN e.status = 'devolvido'                      THEN 'Devolvido no prazo'
               WHEN e.data_devolucao_prevista < CURDATE()       THEN 'Em atraso'
               ELSE 'No prazo'
           END AS situacao,
           LEAST(GREATEST(DATEDIFF(IFNULL(e.data_devolucao_real, CURDATE()),
                                   e.data_devolucao_prevista), 0), 30) * 1.50 AS multa
    FROM emprestimos e
    JOIN livros l ON l.id_livro = e.id_livro
    WHERE e.id_usuario = v_id_usuario
      AND e.data_saida BETWEEN p_data_inicio AND p_data_fim
    ORDER BY e.data_saida;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_resumo_usuario | Responsavel: Gustavo Vianna
-- Tipo: retorno por parametros OUT (obrigatorio "c")
-- Objetivo: devolver, em variaveis, a situacao de um usuario para o
-- balcao de atendimento decidir se ele pode pegar livro.
-- Regras: classificacao por CASE -- BLOQUEADO (tem atraso),
-- LIMITE ATINGIDO (3 ativos), LIBERADO (demais).
-- Parametros: IN p_email, OUT p_qtd_ativos, OUT p_qtd_atrasados,
--             OUT p_situacao
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_resumo_usuario(
    IN  p_email         VARCHAR(100),
    OUT p_qtd_ativos    INT,
    OUT p_qtd_atrasados INT,
    OUT p_situacao      VARCHAR(20)
)
BEGIN
    DECLARE v_id_usuario CHAR(36);

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario nao encontrado';
    END IF;

    SELECT COUNT(*),
           COALESCE(SUM(status = 'atrasado'
                        OR data_devolucao_prevista < CURDATE()), 0)
      INTO p_qtd_ativos, p_qtd_atrasados
    FROM emprestimos
    WHERE id_usuario = v_id_usuario
      AND status <> 'devolvido';

    SET p_situacao = CASE
                         WHEN p_qtd_atrasados > 0 THEN 'BLOQUEADO'
                         WHEN p_qtd_ativos >= 3   THEN 'LIMITE ATINGIDO'
                         ELSE 'LIBERADO'
                     END;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_renovar_emprestimo | Responsavel: Gabriel Cardoso
-- Tipo: alteracao com parametro INOUT
-- Objetivo: prorrogar a data de devolucao de um emprestimo.
-- Regras: so renova emprestimo pendente e ainda dentro do prazo;
-- a renovacao e de no maximo 14 dias. O INOUT entra com os dias
-- pedidos e sai com os dias realmente concedidos.
-- Parametros: IN p_id_emprestimo, INOUT p_dias
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_renovar_emprestimo(
    IN    p_id_emprestimo CHAR(36),
    INOUT p_dias          INT
)
BEGIN
    DECLARE v_status   VARCHAR(10);
    DECLARE v_prevista DATE;
    DECLARE c_max_dias INT DEFAULT 14;

    SELECT status, data_devolucao_prevista
      INTO v_status, v_prevista
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emprestimo nao encontrado';
    ELSEIF v_status <> 'pendente' OR v_prevista < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Renovacao negada: emprestimo devolvido ou em atraso';
    ELSEIF p_dias IS NULL OR p_dias <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe uma quantidade de dias positiva';
    ELSEIF p_dias > c_max_dias THEN
        SET p_dias = c_max_dias;
    END IF;

    UPDATE emprestimos
    SET data_devolucao_prevista = DATE_ADD(v_prevista, INTERVAL p_dias DAY)
    WHERE id_emprestimo = p_id_emprestimo;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'biblioteca';
