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
