USE biblioteca;

-- Histórico de empréstimos devolvidos com atraso
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_devolucao_prevista,
    e.data_devolucao_real,
    DATEDIFF(e.data_devolucao_real, e.data_devolucao_prevista) AS dias_atraso
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'devolvido'
  AND e.data_devolucao_real > e.data_devolucao_prevista
ORDER BY dias_atraso DESC;
