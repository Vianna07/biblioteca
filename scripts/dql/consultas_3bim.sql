-- ================================================================
-- consultas_3bim.sql -- Consultas do 3 bimestre (documento consolidado)
-- ================================================================
-- Pressupoe o banco ja criado e populado (rode scripts/apresentacao_3bim.sql
-- ou scripts/mysql/main.sql antes). Contem apenas as consultas das
-- secoes 2 a 5 e 10 do trabalho -- indices/views/functions estao em
-- scripts/mysql/ddl/indexes.sql, views.sql e functions.sql.
USE biblioteca;

-- ----------------------------------------------------------------
-- Funcoes de agregacao (COUNT, SUM, MAX, MIN, AVG)
-- ----------------------------------------------------------------

SELECT COUNT(*) AS total_usuarios FROM usuarios;

SELECT COUNT(*) AS total_livros FROM livros;

SELECT SUM(preco) AS valor_total_acervo FROM livros;

SELECT titulo, autor, preco AS maior_preco
FROM livros
WHERE preco = (SELECT MAX(preco) FROM livros);

SELECT titulo, autor, preco AS menor_preco
FROM livros
WHERE preco = (SELECT MIN(preco) FROM livros);

SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

SELECT ROUND(AVG(DATEDIFF(data_devolucao_prevista, data_saida)), 1) AS prazo_medio_dias
FROM emprestimos;

SELECT MAX(DATEDIFF(data_devolucao_real, data_devolucao_prevista)) AS maior_atraso_dias
FROM emprestimos
WHERE status = 'devolvido' AND data_devolucao_real > data_devolucao_prevista;

-- ----------------------------------------------------------------
-- GROUP BY e HAVING
-- ----------------------------------------------------------------

SELECT autor, COUNT(*) AS qtd_livros
FROM livros
GROUP BY autor
ORDER BY qtd_livros DESC, autor;

SELECT status, COUNT(*) AS qtd_emprestimos
FROM emprestimos
GROUP BY status
ORDER BY qtd_emprestimos DESC;

SELECT editora,
       COUNT(*)              AS qtd_livros,
       SUM(preco)             AS valor_total,
       ROUND(AVG(preco), 2)   AS preco_medio
FROM livros
WHERE editora IS NOT NULL
GROUP BY editora
ORDER BY valor_total DESC;

SELECT autor, COUNT(*) AS qtd_livros
FROM livros
GROUP BY autor
HAVING COUNT(*) > 1
ORDER BY qtd_livros DESC;

SELECT u.nome, u.email, COUNT(*) AS qtd_emprestimos
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
GROUP BY u.id_usuario, u.nome, u.email
HAVING COUNT(*) > 4
ORDER BY qtd_emprestimos DESC;

SELECT u.nome,
       COUNT(*)      AS qtd_emprestimos,
       SUM(l.preco)  AS valor_total_emprestado
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
GROUP BY u.id_usuario, u.nome
ORDER BY valor_total_emprestado DESC
LIMIT 10;

-- ----------------------------------------------------------------
-- Operadores de conjunto (UNION, UNION ALL, EXCEPT, INTERSECT)
-- ----------------------------------------------------------------
-- EXCEPT/INTERSECT exigem MySQL >= 8.0.31.

SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
UNION
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'pendente'
  AND e.data_devolucao_prevista <= DATE_ADD(CURDATE(), INTERVAL 4 DAY);

SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
UNION ALL
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'pendente'
  AND e.data_devolucao_prevista <= DATE_ADD(CURDATE(), INTERVAL 4 DAY);

SELECT id_usuario, nome, email FROM usuarios
EXCEPT
SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario;

SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'devolvido' AND e.data_devolucao_real <= e.data_devolucao_prevista
INTERSECT
SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
   OR (e.status = 'devolvido' AND e.data_devolucao_real > e.data_devolucao_prevista);

-- ----------------------------------------------------------------
-- DISTINCT, IN, EXISTS, NOT EXISTS
-- ----------------------------------------------------------------

SELECT DISTINCT editora
FROM livros
WHERE editora IS NOT NULL
ORDER BY editora;

SELECT titulo, autor, preco
FROM livros
WHERE id_livro IN (SELECT id_livro FROM emprestimos)
ORDER BY titulo;

SELECT nome, email
FROM usuarios u
WHERE EXISTS (
    SELECT 1 FROM emprestimos e
    WHERE e.id_usuario = u.id_usuario AND e.status = 'atrasado'
)
ORDER BY nome;

SELECT titulo, autor, preco
FROM livros l
WHERE NOT EXISTS (
    SELECT 1 FROM emprestimos e WHERE e.id_livro = l.id_livro
)
ORDER BY titulo;

-- ----------------------------------------------------------------
-- Relatorio avancado (JOIN + agregacao + GROUP BY + HAVING + ORDER BY + subconsulta)
-- ----------------------------------------------------------------

SELECT u.nome AS usuario,
       u.email,
       COUNT(*)                                                      AS qtd_emprestimos_atrasados,
       SUM(l.preco)                                                  AS valor_total_em_risco,
       ROUND(AVG(DATEDIFF(CURDATE(), e.data_devolucao_prevista)), 1) AS media_dias_atraso
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE e.status = 'atrasado'
  AND l.preco > (SELECT AVG(preco) FROM livros)
GROUP BY u.id_usuario, u.nome, u.email
HAVING COUNT(*) >= 1
ORDER BY valor_total_em_risco DESC;
