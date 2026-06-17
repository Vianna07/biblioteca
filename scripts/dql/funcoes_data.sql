USE biblioteca;

-- ============================================================
-- Funções de Data
-- ============================================================

-- NOW: data e hora exata do servidor no momento da consulta
SELECT NOW() AS data_hora_atual;

-- CURDATE: somente a data de hoje (sem hora)
SELECT CURDATE() AS data_hoje;

-- DATE_FORMAT: exibir created_at no formato brasileiro dd/mm/aaaa hh:mm
SELECT nome,
       DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') AS cadastrado_em
FROM usuarios
ORDER BY created_at;

-- DATE_ADD: projetar a data de devolução (data_saida + 14 dias)
SELECT l.titulo,
       e.data_saida,
       DATE_ADD(e.data_saida, INTERVAL 14 DAY) AS devolucao_calculada,
       e.data_devolucao_prevista               AS devolucao_real_prevista
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
LIMIT 5;

-- DATEDIFF: dias em aberto para empréstimos pendentes
SELECT l.titulo,
       u.nome AS usuario,
       e.data_saida,
       DATEDIFF(CURDATE(), e.data_saida) AS dias_em_aberto
FROM emprestimos e
JOIN livros   l ON e.id_livro   = l.id_livro
JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.status = 'pendente'
ORDER BY dias_em_aberto DESC;
