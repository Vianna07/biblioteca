-- ================================================================
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- Script do 4 bimestre: tabela de log, procedures, cursor,
-- triggers e comandos de teste. Pre-requisito: 00_base.sql.
-- Gerado por docs/4bim/gerar_documento.py a partir de 01..09.
-- ================================================================


-- ################################################################
-- 01_estrutura.sql
-- ################################################################

-- ================================================================
-- 01_estrutura.sql -- Ajustes de estrutura e tabela de log (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Pre-requisito: 00_base.sql executado (banco recem-criado).
-- ================================================================

USE biblioteca;

-- O MySQL Workbench vem com "safe updates" ligado, que bloqueia
-- UPDATE/DELETE sem WHERE por chave (Error 1175).
SET SQL_SAFE_UPDATES = 0;

-- ----------------------------------------------------------------
-- Tabela: livros (ajuste) | Responsavel: Gustavo Vianna
-- Objetivo: controlar quantos exemplares fisicos cada titulo tem e
-- quantos estao disponiveis na estante. E o "estoque" da biblioteca,
-- mantido automaticamente pelas triggers de emprestimo/devolucao.
-- ----------------------------------------------------------------

ALTER TABLE livros
    ADD COLUMN qtd_exemplares INT NOT NULL DEFAULT 1,
    ADD COLUMN qtd_disponivel INT NOT NULL DEFAULT 1;

-- Acervo: classicos mais procurados tem 3 exemplares, os titulos
-- raros apenas 1, o restante 2.
UPDATE livros
SET qtd_exemplares = CASE
        WHEN titulo IN ('Dom Casmurro', 'Vidas Secas', 'Grande Sertao: Veredas') THEN 3
        WHEN titulo IN ('Lavoura Arcaica', 'Dois Irmaos')                       THEN 1
        ELSE 2
    END;

-- Disponivel = exemplares - emprestimos ainda nao devolvidos
UPDATE livros l
SET qtd_disponivel = l.qtd_exemplares - (
        SELECT COUNT(*)
        FROM emprestimos e
        WHERE e.id_livro = l.id_livro
          AND e.status <> 'devolvido'
    );

-- ----------------------------------------------------------------
-- Tabela: log_auditoria | Responsavel: Rafael de Almeida
-- Objetivo: historico de todas as operacoes registradas pelas
-- triggers de auditoria (quem, o que, quando, valor antes/depois).
-- ----------------------------------------------------------------

CREATE TABLE log_auditoria (
    id_log       INT                               AUTO_INCREMENT PRIMARY KEY,
    tabela       VARCHAR(30)                       NOT NULL,
    id_registro  CHAR(36)                          NOT NULL,
    operacao     ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    valor_antigo VARCHAR(500),
    valor_novo   VARCHAR(500),
    usuario_bd   VARCHAR(100)                      NOT NULL,
    data_hora    DATETIME                          NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Conferencia
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros ORDER BY titulo;
DESCRIBE log_auditoria;


-- ################################################################
-- 02_procedures.sql
-- ################################################################

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


-- ################################################################
-- 03_cursor.sql
-- ################################################################

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


-- ################################################################
-- 04_triggers.sql
-- ################################################################

-- ================================================================
-- 04_triggers.sql -- Triggers (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Organizacao:
--   BEFORE (validacao)   -> trg_emprestimos_before_insert
--                           trg_emprestimos_before_update
--                           trg_emprestimos_before_delete
--                           trg_livros_before_update
--   AFTER  (atualizacao) -> trg_emprestimos_after_insert
--                           trg_emprestimos_after_update
--   AFTER  (auditoria)   -> trg_auditoria_emprestimos_insert
--                           trg_auditoria_emprestimos_update
--                           trg_auditoria_emprestimos_delete
--                           trg_auditoria_livros_update
-- ================================================================

USE biblioteca;

DROP TRIGGER IF EXISTS trg_emprestimos_before_insert;
DROP TRIGGER IF EXISTS trg_emprestimos_before_update;
DROP TRIGGER IF EXISTS trg_emprestimos_before_delete;
DROP TRIGGER IF EXISTS trg_livros_before_update;
DROP TRIGGER IF EXISTS trg_emprestimos_after_insert;
DROP TRIGGER IF EXISTS trg_emprestimos_after_update;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_insert;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_update;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_delete;
DROP TRIGGER IF EXISTS trg_auditoria_livros_update;

DELIMITER $$

-- ================================================================
-- BEFORE -- validacao (obrigatorio "a")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: BEFORE
-- Objetivo: barrar emprestimos invalidos antes de serem gravados,
-- venham eles da procedure ou de um INSERT direto.
-- Regras: prazo entre 1 e 30 dias; precisa haver exemplar disponivel.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_insert
BEFORE INSERT ON emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_disponivel INT;
    DECLARE v_titulo     VARCHAR(255);
    DECLARE v_msg        VARCHAR(255);

    SELECT qtd_disponivel, titulo
      INTO v_disponivel, v_titulo
    FROM livros
    WHERE id_livro = NEW.id_livro;

    IF NEW.data_devolucao_prevista <= NEW.data_saida THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A devolucao prevista deve ser posterior a data de saida';
    ELSEIF DATEDIFF(NEW.data_devolucao_prevista, NEW.data_saida) > 30 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo maximo de emprestimo e de 30 dias';
    ELSEIF NEW.status <> 'devolvido' AND v_disponivel <= 0 THEN
        SET v_msg = CONCAT('Nao ha exemplares disponiveis de "', v_titulo, '"');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: BEFORE
-- Objetivo: impedir que um emprestimo devolvido seja reaberto e
-- preencher automaticamente a data de devolucao (altera o NEW).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_update
BEFORE UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status = 'devolvido' AND NEW.status <> 'devolvido' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Emprestimo ja devolvido nao pode ser reaberto';
    END IF;

    IF NEW.status = 'devolvido' AND NEW.data_devolucao_real IS NULL THEN
        SET NEW.data_devolucao_real = CURDATE();
    END IF;

    IF NEW.data_devolucao_real < NEW.data_saida THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de devolucao anterior a data de saida';
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_delete | Responsavel: Rafael de Almeida
-- Tabela: emprestimos | Evento: DELETE | Momento: BEFORE
-- Objetivo: so permite excluir emprestimos ja devolvidos; apagar um
-- emprestimo em aberto faria o livro "sumir" do controle.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_delete
BEFORE DELETE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status <> 'devolvido' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nao e permitido excluir emprestimo em aberto';
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_livros_before_update | Responsavel: Rafael de Almeida
-- Tabela: livros | Evento: UPDATE | Momento: BEFORE
-- Objetivo: impedir preco negativo e estoque fora do intervalo
-- 0..qtd_exemplares (protege tambem contra erro nas outras triggers).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_livros_before_update
BEFORE UPDATE ON livros
FOR EACH ROW
BEGIN
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O preco nao pode ser negativo';
    ELSEIF NEW.qtd_disponivel < 0 OR NEW.qtd_disponivel > NEW.qtd_exemplares THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantidade disponivel deve ficar entre 0 e o total de exemplares';
    END IF;
END$$

-- ================================================================
-- AFTER -- atualizacao automatica de outra tabela (obrigatorio "b")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_after_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: AFTER
-- Objetivo: dar baixa de 1 exemplar em livros.qtd_disponivel quando
-- um emprestimo e registrado.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_after_insert
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    IF NEW.status <> 'devolvido' THEN
        UPDATE livros
        SET qtd_disponivel = qtd_disponivel - 1
        WHERE id_livro = NEW.id_livro;
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_after_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: AFTER
-- Objetivo: devolver 1 exemplar ao estoque quando o emprestimo passa
-- para 'devolvido' (compara OLD x NEW para agir so na transicao).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_after_update
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status <> 'devolvido' AND NEW.status = 'devolvido' THEN
        UPDATE livros
        SET qtd_disponivel = qtd_disponivel + 1
        WHERE id_livro = NEW.id_livro;
    END IF;
END$$

-- ================================================================
-- AFTER -- auditoria em log_auditoria (obrigatorio "c")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: AFTER
-- Objetivo: registrar no log todo emprestimo criado (valor novo).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_insert
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', NEW.id_emprestimo, 'INSERT', NULL,
            CONCAT('status=', NEW.status, '; prevista=', NEW.data_devolucao_prevista),
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: AFTER
-- Objetivo: registrar no log o antes (OLD) e o depois (NEW) de toda
-- alteracao de emprestimo (devolucao, renovacao, atraso).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_update
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', NEW.id_emprestimo, 'UPDATE',
            CONCAT('status=', OLD.status, '; prevista=', OLD.data_devolucao_prevista,
                   '; devolucao=', IFNULL(OLD.data_devolucao_real, '-')),
            CONCAT('status=', NEW.status, '; prevista=', NEW.data_devolucao_prevista,
                   '; devolucao=', IFNULL(NEW.data_devolucao_real, '-')),
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_delete | Responsavel: Rafael de Almeida
-- Tabela: emprestimos | Evento: DELETE | Momento: AFTER
-- Objetivo: registrar no log o registro excluido (valor antigo).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_delete
AFTER DELETE ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', OLD.id_emprestimo, 'DELETE',
            CONCAT('status=', OLD.status, '; saida=', OLD.data_saida,
                   '; devolucao=', IFNULL(OLD.data_devolucao_real, '-')),
            NULL,
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_livros_update | Responsavel: Gabriel Cardoso
-- Tabela: livros | Evento: UPDATE | Momento: AFTER
-- Objetivo: historico de alteracao de preco. So grava quando o preco
-- realmente mudou (as baixas de estoque nao poluem o log).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_livros_update
AFTER UPDATE ON livros
FOR EACH ROW
BEGIN
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
        VALUES ('livros', NEW.id_livro, 'UPDATE',
                CONCAT('preco=', OLD.preco),
                CONCAT('preco=', NEW.preco),
                USER());
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM biblioteca;


-- ################################################################
-- 05_teste_procedures.sql
-- ################################################################

-- ================================================================
-- 05_teste_procedures.sql -- Testes das procedures (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================
-- Testes com dados INVALIDOS terminam em erro de proposito. No
-- Workbench, execute bloco a bloco (selecione + Ctrl+Shift+Enter)
-- ou ligue "Continue SQL script execution on errors".
-- ================================================================

USE biblioteca;
SET SQL_SAFE_UPDATES = 0;

-- ================================================================
-- sp_registrar_emprestimo
-- ================================================================

-- >> P1-antes | Antes: estoque de "Dom Casmurro" e emprestimos da Sofia
SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Dom Casmurro';

SELECT l.titulo, e.data_saida, e.data_devolucao_prevista, e.status
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE u.email = 'sofia.cardoso@email.com';

-- >> P1-valido | Valido: Sofia pega "Dom Casmurro" por 14 dias
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Dom Casmurro', 14, @id_emp);
SELECT @id_emp AS id_emprestimo_gerado;

-- >> P1-depois | Depois: emprestimo criado e estoque baixado pela trigger
SELECT l.titulo, e.data_saida, e.data_devolucao_prevista, e.status
FROM emprestimos e
JOIN livros l ON l.id_livro = e.id_livro
WHERE e.id_emprestimo = @id_emp;

SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Dom Casmurro';

-- >> P1-inv-usuario | Invalido: e-mail que nao existe
CALL sp_registrar_emprestimo('fantasma@email.com', 'Dom Casmurro', 14, @id_emp2);

-- >> P1-inv-livro | Invalido: livro que nao existe
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Harry Potter', 14, @id_emp2);

-- >> P1-inv-prazo | Invalido: prazo de 45 dias
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Quincas Borba', 45, @id_emp2);

-- >> P1-inv-bloqueado | Invalido: Ana tem emprestimos em atraso
CALL sp_registrar_emprestimo('ana.silva@email.com', 'Quincas Borba', 14, @id_emp2);

-- ================================================================
-- sp_registrar_devolucao (parametro OUT)
-- ================================================================

-- >> P2-antes | Antes: emprestimo atrasado do Bruno ("Angustia")
SET @id_bruno = (SELECT e.id_emprestimo
                 FROM emprestimos e
                 JOIN usuarios u ON u.id_usuario = e.id_usuario
                 JOIN livros   l ON l.id_livro   = e.id_livro
                 WHERE u.email = 'bruno.oliveira@email.com'
                   AND l.titulo = 'Angustia');

SELECT data_saida, data_devolucao_prevista, data_devolucao_real, status,
       DATEDIFF(CURDATE(), data_devolucao_prevista) AS dias_atraso
FROM emprestimos WHERE id_emprestimo = @id_bruno;

SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Angustia';

-- >> P2-valido | Valido: registrar a devolucao e ler a multa pelo OUT
CALL sp_registrar_devolucao(@id_bruno, @multa);
SELECT @multa AS multa_a_pagar;

-- >> P2-depois | Depois: status, data de devolucao e estoque atualizados
SELECT data_saida, data_devolucao_prevista, data_devolucao_real, status
FROM emprestimos WHERE id_emprestimo = @id_bruno;

SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Angustia';

-- >> P2-inv-repetido | Invalido: devolver o mesmo emprestimo de novo
CALL sp_registrar_devolucao(@id_bruno, @multa);

-- >> P2-inv-id | Invalido: emprestimo inexistente
CALL sp_registrar_devolucao('00000000-0000-0000-0000-000000000000', @multa);

-- ================================================================
-- sp_relatorio_emprestimos_usuario (consulta com parametros)
-- ================================================================

-- >> P3-valido | Valido: historico da Ana nos ultimos 120 dias
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com',
                                      DATE_SUB(CURDATE(), INTERVAL 120 DAY),
                                      CURDATE());

-- >> P3-valido-periodo | Valido: mesmo usuario, periodo menor (ultimos 30 dias)
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com',
                                      DATE_SUB(CURDATE(), INTERVAL 30 DAY),
                                      CURDATE());

-- >> P3-inv-periodo | Invalido: data inicial maior que a final
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com', CURDATE(),
                                      DATE_SUB(CURDATE(), INTERVAL 30 DAY));

-- ================================================================
-- sp_resumo_usuario (varios parametros OUT)
-- ================================================================

-- >> P4-valido | Valido: situacao da Sofia e da Ana
CALL sp_resumo_usuario('sofia.cardoso@email.com', @ativos, @atrasados, @situacao);
SELECT 'Sofia' AS usuario, @ativos AS ativos, @atrasados AS atrasados, @situacao AS situacao;

CALL sp_resumo_usuario('ana.silva@email.com', @ativos, @atrasados, @situacao);
SELECT 'Ana' AS usuario, @ativos AS ativos, @atrasados AS atrasados, @situacao AS situacao;

-- >> P4-inv-usuario | Invalido: usuario inexistente
CALL sp_resumo_usuario('fantasma@email.com', @ativos, @atrasados, @situacao);

-- ================================================================
-- sp_renovar_emprestimo (parametro INOUT)
-- ================================================================

-- >> P5-antes | Antes: prazo atual do emprestimo da Sofia
SELECT data_devolucao_prevista FROM emprestimos WHERE id_emprestimo = @id_emp;

-- >> P5-valido | Valido: pede 20 dias, o limite e 14 (INOUT devolve 14)
SET @dias = 20;
CALL sp_renovar_emprestimo(@id_emp, @dias);
SELECT @dias AS dias_concedidos;

-- >> P5-depois | Depois: data prevista prorrogada
SELECT data_devolucao_prevista FROM emprestimos WHERE id_emprestimo = @id_emp;

-- >> P5-inv-atrasado | Invalido: renovar emprestimo em atraso (Ana, "Lavoura Arcaica")
SET @id_ana = (SELECT e.id_emprestimo
               FROM emprestimos e
               JOIN usuarios u ON u.id_usuario = e.id_usuario
               JOIN livros   l ON l.id_livro   = e.id_livro
               WHERE u.email = 'ana.silva@email.com'
                 AND l.titulo = 'Lavoura Arcaica');
SET @dias = 7;
CALL sp_renovar_emprestimo(@id_ana, @dias);


-- ################################################################
-- 06_teste_cursor.sql
-- ################################################################

-- ================================================================
-- 06_teste_cursor.sql -- Testes da procedure com cursor (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================

USE biblioteca;
SET SQL_SAFE_UPDATES = 0;

-- >> C1-antes | Antes: pendentes com prazo vencido (o que o cursor vai percorrer)
SELECT u.nome AS usuario, l.titulo, e.data_devolucao_prevista, e.status
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE e.status = 'pendente'
  AND e.data_devolucao_prevista < CURDATE()
ORDER BY e.data_devolucao_prevista;

SELECT status, COUNT(*) AS qtd FROM emprestimos GROUP BY status ORDER BY status;

SELECT COUNT(*) AS registros_no_log FROM log_auditoria;

-- >> C1-valido | Valido: executar a rotina com a data de hoje
CALL sp_atualizar_atrasos(NULL, @qtd, @multa_total);
SELECT @qtd AS emprestimos_atualizados, @multa_total AS multa_total_estimada;

-- >> C1-depois | Depois: nenhum pendente vencido; atrasados aumentaram; log por linha
SELECT COUNT(*) AS pendentes_vencidos
FROM emprestimos
WHERE status = 'pendente'
  AND data_devolucao_prevista < CURDATE();

SELECT status, COUNT(*) AS qtd FROM emprestimos GROUP BY status ORDER BY status;

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_antigo, valor_novo
FROM log_auditoria
ORDER BY id_log DESC
LIMIT 3;

-- >> C1-reexecucao | Reexecucao: nada mais a processar (rotina idempotente)
CALL sp_atualizar_atrasos(NULL, @qtd, @multa_total);
SELECT @qtd AS emprestimos_atualizados, @multa_total AS multa_total_estimada;

-- >> C1-inv-data | Invalido: data de referencia no futuro
CALL sp_atualizar_atrasos(DATE_ADD(CURDATE(), INTERVAL 10 DAY), @qtd, @multa_total);


-- ################################################################
-- 07_teste_triggers.sql
-- ################################################################

-- ================================================================
-- 07_teste_triggers.sql -- Testes das triggers e da tabela de log
-- Projeto: Biblioteca Digital
-- ================================================================
-- Aqui as triggers sao disparadas por comandos DIRETOS (INSERT,
-- UPDATE, DELETE), sem passar pelas procedures, para mostrar que a
-- regra vale para qualquer origem.
--
-- Atencao: os ids de livro/usuario sao buscados ANTES, em variaveis.
-- Um INSERT INTO emprestimos ... VALUES ((SELECT ... FROM livros))
-- falha com Error 1442, porque a trigger AFTER INSERT atualiza a
-- tabela livros, que ja esta sendo lida pelo proprio comando.
-- ================================================================

USE biblioteca;
SET SQL_SAFE_UPDATES = 0;

-- >> T0-antes | Estado inicial: estoque de "Olhai os Lirios do Campo" e tamanho do log
SET @livro_olhai   = (SELECT id_livro   FROM livros   WHERE titulo = 'Olhai os Lirios do Campo');
SET @livro_lavoura = (SELECT id_livro   FROM livros   WHERE titulo = 'Lavoura Arcaica');
SET @rafael        = (SELECT id_usuario FROM usuarios WHERE email  = 'rafael.nascimento@email.com');

SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Olhai os Lirios do Campo';

SELECT COUNT(*) AS registros_no_log FROM log_auditoria;

-- ================================================================
-- trg_emprestimos_before_insert
-- ================================================================

-- >> T1-inv-datas | Invalido: devolucao prevista antes da saida
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista)
VALUES (@livro_olhai, @rafael,
        CURDATE(), DATE_SUB(CURDATE(), INTERVAL 3 DAY));

-- >> T1-inv-prazo | Invalido: prazo de 60 dias
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista)
VALUES (@livro_olhai, @rafael,
        CURDATE(), DATE_ADD(CURDATE(), INTERVAL 60 DAY));

-- >> T1-inv-estoque | Invalido: "Lavoura Arcaica" (1 exemplar, ja emprestado)
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Lavoura Arcaica';

INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista)
VALUES (@livro_lavoura, @rafael,
        CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY));

-- ================================================================
-- trg_emprestimos_after_insert + trg_auditoria_emprestimos_insert
-- ================================================================

-- >> T2-valido | Valido: INSERT direto -> estoque baixa e log registra
SET @id_teste = UUID();

INSERT INTO emprestimos (id_emprestimo, id_livro, id_usuario, data_saida, data_devolucao_prevista)
VALUES (@id_teste, @livro_olhai, @rafael, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY));

SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Olhai os Lirios do Campo';

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_antigo, valor_novo
FROM log_auditoria ORDER BY id_log DESC LIMIT 1;

-- ================================================================
-- trg_emprestimos_before_update + trg_emprestimos_after_update
-- + trg_auditoria_emprestimos_update
-- ================================================================

-- >> T3-valido | Valido: devolucao sem informar a data -> BEFORE preenche, AFTER devolve estoque
UPDATE emprestimos SET status = 'devolvido' WHERE id_emprestimo = @id_teste;

SELECT data_saida, data_devolucao_real, status
FROM emprestimos WHERE id_emprestimo = @id_teste;

SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Olhai os Lirios do Campo';

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_antigo, valor_novo
FROM log_auditoria ORDER BY id_log DESC LIMIT 1;

-- >> T3-inv-reabrir | Invalido: reabrir emprestimo devolvido
UPDATE emprestimos SET status = 'pendente' WHERE id_emprestimo = @id_teste;

-- ================================================================
-- trg_emprestimos_before_delete + trg_auditoria_emprestimos_delete
-- ================================================================

-- >> T4-inv-aberto | Invalido: excluir emprestimo em aberto (Ana, "Lavoura Arcaica")
SET @id_aberto = (SELECT e.id_emprestimo
                  FROM emprestimos e
                  JOIN livros l ON l.id_livro = e.id_livro
                  WHERE l.titulo = 'Lavoura Arcaica' AND e.status <> 'devolvido');

DELETE FROM emprestimos WHERE id_emprestimo = @id_aberto;

-- >> T4-valido | Valido: excluir o emprestimo de teste (ja devolvido) -> log DELETE
DELETE FROM emprestimos WHERE id_emprestimo = @id_teste;

SELECT COUNT(*) AS ainda_existe FROM emprestimos WHERE id_emprestimo = @id_teste;

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_antigo, valor_novo
FROM log_auditoria ORDER BY id_log DESC LIMIT 1;

-- ================================================================
-- trg_livros_before_update + trg_auditoria_livros_update
-- ================================================================

-- >> T5-inv-preco | Invalido: preco negativo
UPDATE livros SET preco = -10.00 WHERE titulo = 'Dom Casmurro';

-- >> T5-inv-estoque | Invalido: mais disponiveis do que exemplares
UPDATE livros SET qtd_disponivel = 99 WHERE titulo = 'Dom Casmurro';

-- >> T5-valido | Valido: reajuste de preco gera historico no log
SELECT titulo, preco FROM livros WHERE titulo = 'Dom Casmurro';

UPDATE livros SET preco = 34.90 WHERE titulo = 'Dom Casmurro';

SELECT titulo, preco FROM livros WHERE titulo = 'Dom Casmurro';

SELECT id_log, tabela, operacao, valor_antigo, valor_novo
FROM log_auditoria ORDER BY id_log DESC LIMIT 1;

-- ================================================================
-- Tabela de log -- depois de todos os testes
-- ================================================================

-- >> T6-log | Log de auditoria completo
SELECT id_log, tabela, LEFT(id_registro, 8) AS id_registro, operacao,
       valor_antigo, valor_novo, DATE_FORMAT(data_hora, '%d/%m %H:%i') AS data_hora
FROM log_auditoria
ORDER BY id_log;


-- ################################################################
-- 08_rotina_completa.sql
-- ################################################################

-- ================================================================
-- 08_rotina_completa.sql -- Rotina completa do sistema (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================
-- Situacao real: o leitor Rafael chega ao balcao para pegar "Dois
-- Irmaos" (a biblioteca tem 1 exemplar). Logo depois a Sofia tenta
-- pegar o mesmo livro. Rafael devolve dias depois.
--
--   CALL sp_resumo_usuario        -> balcao confere se Rafael esta liberado
--   CALL sp_registrar_emprestimo  -> procedure valida usuario/prazo
--     trg_emprestimos_before_insert    -> trigger valida o exemplar
--     trg_emprestimos_after_insert     -> trigger baixa o estoque
--     trg_auditoria_emprestimos_insert -> trigger grava o log
--   CALL sp_registrar_emprestimo (Sofia) -> bloqueado: sem exemplar
--   CALL sp_registrar_devolucao   -> OUT devolve a multa
--     trg_emprestimos_before_update    -> preenche data de devolucao
--     trg_emprestimos_after_update     -> devolve o exemplar
--     trg_auditoria_emprestimos_update -> grava o log
--   SELECT final                  -> estoque e log atualizados
-- ================================================================

USE biblioteca;
SET SQL_SAFE_UPDATES = 0;

-- >> R1 | Passo 1 -- Estado inicial do livro e do log
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Dois Irmaos';
SELECT COUNT(*) AS registros_no_log FROM log_auditoria;

-- >> R2 | Passo 2 -- Balcao consulta a situacao do Rafael (OUT)
CALL sp_resumo_usuario('rafael.nascimento@email.com', @ativos, @atrasados, @situacao);
SELECT @ativos AS ativos, @atrasados AS atrasados, @situacao AS situacao;

-- >> R3 | Passo 3 -- Rafael pega o livro (procedure + 3 triggers)
CALL sp_registrar_emprestimo('rafael.nascimento@email.com', 'Dois Irmaos', 10, @id_rafael);
SELECT @id_rafael AS id_emprestimo;

-- >> R4 | Passo 4 -- Estoque baixou e o log registrou o INSERT
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Dois Irmaos';

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_novo
FROM log_auditoria ORDER BY id_log DESC LIMIT 1;

-- >> R5 | Passo 5 -- Sofia tenta pegar o mesmo livro: a trigger bloqueia
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Dois Irmaos', 10, @id_sofia);

-- >> R6 | Passo 6 -- Rafael devolve (OUT com a multa)
CALL sp_registrar_devolucao(@id_rafael, @multa);
SELECT @multa AS multa;

-- >> R7 | Passo 7 -- Resultado final: emprestimo, estoque e log
SELECT u.nome, l.titulo, e.data_saida, e.data_devolucao_real, e.status
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE e.id_emprestimo = @id_rafael;

SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Dois Irmaos';

SELECT id_log, LEFT(id_registro, 8) AS id_registro, operacao, valor_antigo, valor_novo
FROM log_auditoria
WHERE id_registro = @id_rafael
ORDER BY id_log;

-- >> R8 | Passo 8 -- Agora o exemplar voltou: Sofia consegue pegar
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Dois Irmaos', 10, @id_sofia);
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Dois Irmaos';


-- ################################################################
-- 09_demonstracao.sql
-- ################################################################

-- ================================================================
-- 09_demonstracao.sql -- Objetos criados no banco (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================

USE biblioteca;

-- >> S1 | Procedures criadas
SHOW PROCEDURE STATUS WHERE Db = 'biblioteca';

-- >> S2 | Triggers criadas
SHOW TRIGGERS FROM biblioteca;

-- >> S3 | Estrutura da tabela de log
DESCRIBE log_auditoria;
