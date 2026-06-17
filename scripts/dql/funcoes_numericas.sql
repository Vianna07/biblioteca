USE biblioteca;

-- ============================================================
-- Funcoes Numericas
-- ============================================================

-- COUNT: total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- COUNT: total de usuarios cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- COUNT: total de emprestimos por status
SELECT status, COUNT(*) AS total
FROM emprestimos
GROUP BY status
ORDER BY total DESC;

-- SUM: valor total do acervo
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- AVG: preco medio dos livros
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- MAX: maior preco no acervo
SELECT MAX(preco) AS maior_preco FROM livros;

-- MAX com titulo e autor: linha completa do livro mais caro
SELECT titulo, autor, preco AS maior_preco
FROM livros
WHERE preco = (SELECT MAX(preco) FROM livros);

-- MIN: menor preco no acervo
SELECT MIN(preco) AS menor_preco FROM livros;

-- MIN com titulo e autor: linha completa do livro mais barato
SELECT titulo, autor, preco AS menor_preco
FROM livros
WHERE preco = (SELECT MIN(preco) FROM livros);
