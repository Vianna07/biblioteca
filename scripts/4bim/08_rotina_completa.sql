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
