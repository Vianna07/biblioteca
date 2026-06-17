USE biblioteca;

-- ============================================================
-- Relatórios e Indicadores (funções de agregação)
-- ============================================================

-- Total de usuários cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- Total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- Total de empréstimos registrados
SELECT COUNT(*) AS total_emprestimos FROM emprestimos;

-- Quantidade de empréstimos por status
SELECT status,
       COUNT(*) AS quantidade
FROM emprestimos
GROUP BY status
ORDER BY quantidade DESC;

-- Valor total do acervo (SUM)
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- Livro mais caro (MAX)
SELECT titulo, autor, preco AS maior_preco
FROM livros
ORDER BY preco DESC
LIMIT 1;

-- Livro mais barato (MIN)
SELECT titulo, autor, preco AS menor_preco
FROM livros
ORDER BY preco ASC
LIMIT 1;

-- Preço médio dos livros (AVG)
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- Maior atraso já registrado (em dias)
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

-- Média de dias de atraso nas devoluções tardias (AVG)
SELECT ROUND(AVG(DATEDIFF(data_devolucao_real, data_devolucao_prevista)), 1) AS media_dias_atraso
FROM emprestimos
WHERE status = 'devolvido'
  AND data_devolucao_real > data_devolucao_prevista;

-- Valor total dos livros atualmente emprestados (pendentes + atrasados)
SELECT ROUND(SUM(l.preco), 2) AS valor_em_circulacao
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status IN ('pendente', 'atrasado');
