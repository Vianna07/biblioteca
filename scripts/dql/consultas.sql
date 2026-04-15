USE biblioteca;

-- ==============================================
-- 1. Listar todos os livros cadastrados
-- ==============================================
SELECT '=== TODOS OS LIVROS ===' AS consulta;
SELECT titulo, autor, editora, ano_lancamento, isbn
FROM livros
ORDER BY titulo;

-- ==============================================
-- 2. Listar todos os usuários cadastrados
-- ==============================================
SELECT '=== TODOS OS USUÁRIOS ===' AS consulta;
SELECT nome, login
FROM usuarios
ORDER BY nome;

-- ==============================================
-- 3. Empréstimos atrasados (data_devolucao_prevista < hoje e sem devolução)
-- ==============================================
SELECT '=== EMPRÉSTIMOS ATRASADOS ===' AS consulta;
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_saida,
    e.data_devolucao_prevista,
    DATEDIFF(CURDATE(), e.data_devolucao_prevista) AS dias_atraso
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'atrasado'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista < CURDATE()
ORDER BY dias_atraso DESC;

-- ==============================================
-- 4. Empréstimos pendentes dentro do prazo
-- ==============================================
SELECT '=== EMPRÉSTIMOS PENDENTES (NO PRAZO) ===' AS consulta;
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_saida,
    e.data_devolucao_prevista,
    DATEDIFF(e.data_devolucao_prevista, CURDATE()) AS dias_restantes
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista >= CURDATE()
ORDER BY dias_restantes ASC;

-- ==============================================
-- 5. Empréstimos que vencem hoje ou amanhã
-- ==============================================
SELECT '=== EMPRÉSTIMOS PRESTES A VENCER (HOJE/AMANHÃ) ===' AS consulta;
SELECT
    u.nome AS usuario,
    u.login,
    l.titulo AS livro,
    e.data_devolucao_prevista
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
  AND e.data_devolucao_real IS NULL
  AND e.data_devolucao_prevista BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 1 DAY)
ORDER BY e.data_devolucao_prevista;

-- ==============================================
-- 6. Histórico de empréstimos devolvidos com atraso
-- ==============================================
SELECT '=== DEVOLVIDOS COM ATRASO ===' AS consulta;
SELECT
    u.nome AS usuario,
    l.titulo AS livro,
    e.data_devolucao_prevista,
    e.data_devolucao_real,
    DATEDIFF(e.data_devolucao_real, e.data_devolucao_prevista) AS dias_atraso
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'devolvido'
  AND e.data_devolucao_real > e.data_devolucao_prevista
ORDER BY dias_atraso DESC;

-- ==============================================
-- 7. Quantidade de empréstimos por usuário
-- ==============================================
SELECT '=== TOTAL DE EMPRÉSTIMOS POR USUÁRIO ===' AS consulta;
SELECT
    u.nome AS usuario,
    COUNT(*) AS total_emprestimos,
    SUM(CASE WHEN e.status = 'pendente' THEN 1 ELSE 0 END) AS pendentes,
    SUM(CASE WHEN e.status = 'atrasado' THEN 1 ELSE 0 END) AS atrasados,
    SUM(CASE WHEN e.status = 'devolvido' THEN 1 ELSE 0 END) AS devolvidos
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY total_emprestimos DESC;

-- ==============================================
-- 8. Livros mais emprestados
-- ==============================================
SELECT '=== LIVROS MAIS EMPRESTADOS ===' AS consulta;
SELECT
    l.titulo,
    l.autor,
    COUNT(*) AS vezes_emprestado
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
GROUP BY l.id_livro, l.titulo, l.autor
ORDER BY vezes_emprestado DESC
LIMIT 10;

-- ==============================================
-- 9. Livros que nunca foram emprestados
-- ==============================================
SELECT '=== LIVROS NUNCA EMPRESTADOS ===' AS consulta;
SELECT
    l.titulo,
    l.autor,
    l.isbn
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
WHERE e.id_emprestimo IS NULL
ORDER BY l.titulo;

-- ==============================================
-- 10. Usuários com mais atrasos
-- ==============================================
SELECT '=== USUÁRIOS COM MAIS ATRASOS ===' AS consulta;
SELECT
    u.nome AS usuario,
    u.login,
    COUNT(*) AS total_atrasos
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
   OR (e.status = 'devolvido' AND e.data_devolucao_real > e.data_devolucao_prevista)
GROUP BY u.id_usuario, u.nome, u.login
ORDER BY total_atrasos DESC;

-- ==============================================
-- 11. Livros emprestados no momento (não devolvidos)
-- ==============================================
SELECT '=== LIVROS EMPRESTADOS ATUALMENTE ===' AS consulta;
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

-- ==============================================
-- 12. Média de dias de empréstimo por livro devolvido
-- ==============================================
SELECT '=== MÉDIA DE DIAS DE EMPRÉSTIMO ===' AS consulta;
SELECT
    l.titulo,
    ROUND(AVG(DATEDIFF(e.data_devolucao_real, e.data_saida)), 1) AS media_dias
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'devolvido'
GROUP BY l.id_livro, l.titulo
ORDER BY media_dias DESC;
