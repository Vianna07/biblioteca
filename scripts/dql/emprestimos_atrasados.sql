USE biblioteca;

-- Empréstimos atrasados (data_devolucao_prevista < hoje e sem devolução)
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_saida,
    e.data_devolucao_prevista,
    DATEDIFF(CURDATE(), e.data_devolucao_prevista) AS dias_atraso
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'atrasado'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista < CURDATE()
ORDER BY dias_atraso DESC;
