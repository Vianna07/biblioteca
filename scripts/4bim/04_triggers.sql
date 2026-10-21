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
