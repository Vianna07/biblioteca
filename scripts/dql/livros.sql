USE biblioteca;

-- Listar todos os livros cadastrados
SELECT titulo, autor, editora, ano_lancamento
FROM livros
ORDER BY titulo;
