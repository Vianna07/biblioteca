USE biblioteca;

-- ============================================================
-- Funções Numéricas
-- ============================================================

-- COUNT: total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- COUNT: total de usuários cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- COUNT: total de empréstimos por status
SELECT status, COUNT(*) AS total
FROM emprestimos
GROUP BY status
ORDER BY total DESC;

-- SUM: valor total do acervo
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- AVG: preço médio dos livros
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- MAX: livro mais caro do acervo
SELECT titulo, autor, preco AS preco_mais_alto
FROM livros
ORDER BY preco DESC
LIMIT 1;

-- MIN: livro mais barato do acervo
SELECT titulo, autor, preco AS preco_mais_baixo
FROM livros
ORDER BY preco ASC
LIMIT 1;
