USE biblioteca;

-- Usuários com mais atrasos
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
