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
