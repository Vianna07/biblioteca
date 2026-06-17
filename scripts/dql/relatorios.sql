USE biblioteca;

-- ============================================================
-- Relatorios e Indicadores (funcoes de agregacao)
-- ============================================================

-- Total de usuarios cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- Total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- Total de emprestimos registrados
SELECT COUNT(*) AS total_emprestimos FROM emprestimos;

-- Quantidade de emprestimos por status
SELECT status,
       COUNT(*) AS quantidade
FROM emprestimos
GROUP BY status
ORDER BY quantidade DESC;

-- Valor total do acervo (SUM)
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- Maior preco no acervo (MAX)
SELECT MAX(preco) AS maior_preco FROM livros;

-- Livro mais caro (MAX com linha completa)
SELECT titulo, autor, preco AS maior_preco
FROM livros
WHERE preco = (SELECT MAX(preco) FROM livros);

-- Menor preco no acervo (MIN)
SELECT MIN(preco) AS menor_preco FROM livros;

-- Livro mais barato (MIN com linha completa)
SELECT titulo, autor, preco AS menor_preco
FROM livros
WHERE preco = (SELECT MIN(preco) FROM livros);

-- Preco medio dos livros (AVG)
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- Maior atraso ja registrado (em dias)
SELECT u.nome        AS usuario,
       l.titulo      AS livro,
       DATEDIFF(e.data_devolucao_real, e.data_devolucao_prevista) AS dias_atraso
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros   l ON e.id_livro   = l.id_livro
WHERE e.status = 'devolvido'
  AND e.data_devolucao_real > e.data_devolucao_prevista
ORDER BY dias_atraso DESC
LIMIT 1;

-- Media de dias de atraso nas devolucoes tardias (AVG)
SELECT ROUND(AVG(DATEDIFF(data_devolucao_real, data_devolucao_prevista)), 1) AS media_dias_atraso
FROM emprestimos
WHERE status = 'devolvido'
  AND data_devolucao_real > data_devolucao_prevista;

-- Valor total dos livros atualmente emprestados (SUM)
SELECT ROUND(SUM(l.preco), 2) AS valor_em_circulacao
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status IN ('pendente', 'atrasado');
