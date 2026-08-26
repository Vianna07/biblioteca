-- ================================================================
-- views.sql -- Views do 3 bimestre (MySQL)
-- ================================================================
USE biblioteca;

-- vw_emprestimos_detalhados
-- Objetivo: evitar repetir o JOIN entre emprestimos, livros e usuarios
-- toda vez que alguem precisa de um relatorio legivel de emprestimos.
CREATE VIEW vw_emprestimos_detalhados AS
SELECT e.id_emprestimo,
       u.nome   AS usuario,
       u.email  AS email_usuario,
       l.titulo AS livro,
       l.autor,
       e.data_saida,
       e.data_devolucao_prevista,
       e.data_devolucao_real,
       e.status
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro;

-- vw_usuarios_publico
-- Objetivo: oculta senha e salt -- qualquer consulta ou integracao que
-- so precise exibir/listar usuarios usa esta view.
CREATE VIEW vw_usuarios_publico AS
SELECT id_usuario, nome, email, created_at
FROM usuarios;

-- vw_relatorio_financeiro_editora
-- Objetivo: relatorio financeiro pronto (quantidade, valor total e
-- preco medio do acervo por editora).
CREATE VIEW vw_relatorio_financeiro_editora AS
SELECT editora,
       COUNT(*)             AS qtd_livros,
       SUM(preco)            AS valor_total,
       ROUND(AVG(preco), 2)  AS preco_medio
FROM livros
WHERE editora IS NOT NULL
GROUP BY editora;
