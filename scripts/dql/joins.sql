USE biblioteca;

-- ============================================================
-- Consultas com JOIN
-- ============================================================

-- INNER JOIN: apenas registros com correspondência nos dois lados
-- Usuário + livro + dados do empréstimo (exclui usuários sem empréstimos)
SELECT u.nome            AS usuario,
       l.titulo          AS livro,
       e.data_saida,
       e.data_devolucao_prevista,
       e.status
FROM emprestimos e
INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
INNER JOIN livros   l ON e.id_livro   = l.id_livro
ORDER BY e.data_saida DESC;

-- LEFT JOIN: todos os livros, incluindo os que nunca foram emprestados
-- Livros sem empréstimo aparecem com NULL nas colunas de emprestimos
SELECT l.titulo,
       l.autor,
       e.data_saida,
       e.status
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
ORDER BY l.titulo;

-- LEFT JOIN restrito: somente os livros que NUNCA foram emprestados
SELECT l.titulo,
       l.autor,
       l.preco
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
WHERE e.id_emprestimo IS NULL
ORDER BY l.titulo;

-- RIGHT JOIN: todos os usuários, incluindo os que nunca fizeram empréstimo
-- Usuários sem empréstimo aparecem com NULL nas colunas de emprestimos
SELECT u.nome            AS usuario,
       u.email,
       e.data_saida,
       e.status
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
ORDER BY u.nome;

-- RIGHT JOIN restrito: somente usuários que NUNCA fizeram empréstimo
SELECT u.nome  AS usuario,
       u.email,
       DATE_FORMAT(u.created_at, '%d/%m/%Y') AS cadastrado_em
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.id_emprestimo IS NULL
ORDER BY u.nome;
