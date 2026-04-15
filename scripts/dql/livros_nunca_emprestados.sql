USE biblioteca;

-- Livros que nunca foram emprestados
SELECT
    l.titulo,
    l.autor
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
WHERE e.id_emprestimo IS NULL
ORDER BY l.titulo;
