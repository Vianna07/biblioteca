USE biblioteca;

-- Listar todos os livros cadastrados
SELECT titulo, autor, editora, ano_lancamento, isbn
FROM livros
ORDER BY titulo;
