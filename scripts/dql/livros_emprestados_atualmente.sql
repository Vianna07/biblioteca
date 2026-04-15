USE biblioteca;

-- Livros emprestados no momento (não devolvidos)
SELECT
    l.titulo,
    l.autor,
    u.nome AS emprestado_para,
    e.data_saida,
    e.data_devolucao_prevista,
    e.status
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.data_devolucao_real IS NULL
ORDER BY e.data_devolucao_prevista;
