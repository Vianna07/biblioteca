USE biblioteca;

-- Quantidade de empréstimos por usuário
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
