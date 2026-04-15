USE biblioteca;

-- Livros mais emprestados
SELECT
    l.titulo,
    l.autor,
    COUNT(*) AS vezes_emprestado
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
GROUP BY l.id_livro, l.titulo, l.autor
ORDER BY vezes_emprestado DESC
LIMIT 10;
