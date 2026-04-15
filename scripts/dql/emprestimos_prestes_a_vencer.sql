USE biblioteca;

-- Empréstimos que vencem hoje ou amanhã
SELECT
    u.nome AS usuario,
    u.email,
    l.titulo AS livro,
    e.data_devolucao_prevista
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 1 DAY)
ORDER BY e.data_devolucao_prevista;
