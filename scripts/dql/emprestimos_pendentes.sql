USE biblioteca;

-- Empréstimos pendentes dentro do prazo
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_saida,
    e.data_devolucao_prevista,
    DATEDIFF(e.data_devolucao_prevista, CURDATE()) AS dias_restantes
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista >= CURDATE()
ORDER BY dias_restantes ASC;
