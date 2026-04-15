USE biblioteca;

-- Média de dias de empréstimo por livro devolvido
SELECT
    l.titulo,
    ROUND(AVG(DATEDIFF(e.data_devolucao_real, e.data_saida)), 1) AS media_dias
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'devolvido'
GROUP BY l.id_livro, l.titulo
ORDER BY media_dias DESC;
