-- ================================================================
-- 05_teste_procedures.sql -- Testes das procedures (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================
-- Testes com dados INVALIDOS terminam em erro de proposito. No
-- Workbench, execute bloco a bloco (selecione + Ctrl+Shift+Enter)
-- ou ligue "Continue SQL script execution on errors".
-- ================================================================

USE biblioteca;
SET SQL_SAFE_UPDATES = 0;

-- ================================================================
-- sp_registrar_emprestimo
-- ================================================================

-- >> P1-antes | Antes: estoque de "Dom Casmurro" e emprestimos da Sofia
SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Dom Casmurro';

SELECT l.titulo, e.data_saida, e.data_devolucao_prevista, e.status
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE u.email = 'sofia.cardoso@email.com';

-- >> P1-valido | Valido: Sofia pega "Dom Casmurro" por 14 dias
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Dom Casmurro', 14, @id_emp);
SELECT @id_emp AS id_emprestimo_gerado;

-- >> P1-depois | Depois: emprestimo criado e estoque baixado pela trigger
SELECT l.titulo, e.data_saida, e.data_devolucao_prevista, e.status
FROM emprestimos e
JOIN livros l ON l.id_livro = e.id_livro
WHERE e.id_emprestimo = @id_emp;

SELECT titulo, qtd_exemplares, qtd_disponivel
FROM livros WHERE titulo = 'Dom Casmurro';

-- >> P1-inv-usuario | Invalido: e-mail que nao existe
CALL sp_registrar_emprestimo('fantasma@email.com', 'Dom Casmurro', 14, @id_emp2);

-- >> P1-inv-livro | Invalido: livro que nao existe
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Harry Potter', 14, @id_emp2);

-- >> P1-inv-prazo | Invalido: prazo de 45 dias
CALL sp_registrar_emprestimo('sofia.cardoso@email.com', 'Quincas Borba', 45, @id_emp2);

-- >> P1-inv-bloqueado | Invalido: Ana tem emprestimos em atraso
CALL sp_registrar_emprestimo('ana.silva@email.com', 'Quincas Borba', 14, @id_emp2);

-- ================================================================
-- sp_registrar_devolucao (parametro OUT)
-- ================================================================

-- >> P2-antes | Antes: emprestimo atrasado do Bruno ("Angustia")
SET @id_bruno = (SELECT e.id_emprestimo
                 FROM emprestimos e
                 JOIN usuarios u ON u.id_usuario = e.id_usuario
                 JOIN livros   l ON l.id_livro   = e.id_livro
                 WHERE u.email = 'bruno.oliveira@email.com'
                   AND l.titulo = 'Angustia');

SELECT data_saida, data_devolucao_prevista, data_devolucao_real, status,
       DATEDIFF(CURDATE(), data_devolucao_prevista) AS dias_atraso
FROM emprestimos WHERE id_emprestimo = @id_bruno;

SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Angustia';

-- >> P2-valido | Valido: registrar a devolucao e ler a multa pelo OUT
CALL sp_registrar_devolucao(@id_bruno, @multa);
SELECT @multa AS multa_a_pagar;

-- >> P2-depois | Depois: status, data de devolucao e estoque atualizados
SELECT data_saida, data_devolucao_prevista, data_devolucao_real, status
FROM emprestimos WHERE id_emprestimo = @id_bruno;

SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros WHERE titulo = 'Angustia';

-- >> P2-inv-repetido | Invalido: devolver o mesmo emprestimo de novo
CALL sp_registrar_devolucao(@id_bruno, @multa);

-- >> P2-inv-id | Invalido: emprestimo inexistente
CALL sp_registrar_devolucao('00000000-0000-0000-0000-000000000000', @multa);

-- ================================================================
-- sp_relatorio_emprestimos_usuario (consulta com parametros)
-- ================================================================

-- >> P3-valido | Valido: historico da Ana nos ultimos 120 dias
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com',
                                      DATE_SUB(CURDATE(), INTERVAL 120 DAY),
                                      CURDATE());

-- >> P3-valido-periodo | Valido: mesmo usuario, periodo menor (ultimos 30 dias)
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com',
                                      DATE_SUB(CURDATE(), INTERVAL 30 DAY),
                                      CURDATE());

-- >> P3-inv-periodo | Invalido: data inicial maior que a final
CALL sp_relatorio_emprestimos_usuario('ana.silva@email.com', CURDATE(),
                                      DATE_SUB(CURDATE(), INTERVAL 30 DAY));

-- ================================================================
-- sp_resumo_usuario (varios parametros OUT)
-- ================================================================

-- >> P4-valido | Valido: situacao da Sofia e da Ana
CALL sp_resumo_usuario('sofia.cardoso@email.com', @ativos, @atrasados, @situacao);
SELECT 'Sofia' AS usuario, @ativos AS ativos, @atrasados AS atrasados, @situacao AS situacao;

CALL sp_resumo_usuario('ana.silva@email.com', @ativos, @atrasados, @situacao);
SELECT 'Ana' AS usuario, @ativos AS ativos, @atrasados AS atrasados, @situacao AS situacao;

-- >> P4-inv-usuario | Invalido: usuario inexistente
CALL sp_resumo_usuario('fantasma@email.com', @ativos, @atrasados, @situacao);

-- ================================================================
-- sp_renovar_emprestimo (parametro INOUT)
-- ================================================================

-- >> P5-antes | Antes: prazo atual do emprestimo da Sofia
SELECT data_devolucao_prevista FROM emprestimos WHERE id_emprestimo = @id_emp;

-- >> P5-valido | Valido: pede 20 dias, o limite e 14 (INOUT devolve 14)
SET @dias = 20;
CALL sp_renovar_emprestimo(@id_emp, @dias);
SELECT @dias AS dias_concedidos;

-- >> P5-depois | Depois: data prevista prorrogada
SELECT data_devolucao_prevista FROM emprestimos WHERE id_emprestimo = @id_emp;

-- >> P5-inv-atrasado | Invalido: renovar emprestimo em atraso (Ana, "Lavoura Arcaica")
SET @id_ana = (SELECT e.id_emprestimo
               FROM emprestimos e
               JOIN usuarios u ON u.id_usuario = e.id_usuario
               JOIN livros   l ON l.id_livro   = e.id_livro
               WHERE u.email = 'ana.silva@email.com'
                 AND l.titulo = 'Lavoura Arcaica');
SET @dias = 7;
CALL sp_renovar_emprestimo(@id_ana, @dias);
