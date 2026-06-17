-- ================================================================
-- APRESENTAÇÃO — Banco de Dados 2º Bimestre
-- Sistema: Biblioteca Digital
-- ================================================================
-- Estrutura:
--   Seção 2  – Modelagem do Banco de Dados
--   Seção 3  – Segurança dos Dados (Hash)
--   Seção 4  – Funções SQL (Texto, Numéricas, Data)
--   Seção 5  – Relacionamento entre Tabelas
--   Seção 6  – Consultas com JOIN
--   Seção 7  – Relatórios e Indicadores
-- ================================================================

USE biblioteca;

-- ================================================================
-- SEÇÃO 2 — MODELAGEM DO BANCO DE DADOS
-- ================================================================

-- Entidades do sistema:
--   livros     – acervo da biblioteca
--   usuarios   – leitores cadastrados
--   emprestimos – operação que une livro e usuário

-- Exibe a estrutura de cada tabela (chaves primárias e tipos)
DESCRIBE livros;
DESCRIBE usuarios;
DESCRIBE emprestimos;

-- Relacionamentos e cardinalidades:
--   1 usuario  →  N emprestimos   (um usuário faz vários empréstimos)
--   1 livro    →  N emprestimos   (um livro pode ser emprestado várias vezes)
--   N emprestimos ← 1 livro       (cada empréstimo tem um único livro)
--   N emprestimos ← 1 usuario     (cada empréstimo tem um único usuário)

-- Chaves estrangeiras definidas:
--   emprestimos.id_livro   → livros.id_livro
--   emprestimos.id_usuario → usuarios.id_usuario
-- (com ON DELETE RESTRICT para preservar integridade referencial)

-- Visualizar as FK definidas no banco
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'biblioteca'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ================================================================
-- SEÇÃO 3 — SEGURANÇA DOS DADOS (HASH DE SENHAS)
-- ================================================================
-- Por que NÃO armazenar senha em texto puro?
--   • Se o banco for comprometido, todas as senhas ficam expostas
--   • Usuários costumam reusar senhas em outros serviços
--   • Legislações como LGPD exigem proteção adequada dos dados

-- ────────────────────────────────────────────────────────────────
-- NÍVEL 1 — SHA2-256 simples (sem proteção extra)
-- ────────────────────────────────────────────────────────────────
-- Problema: igual para todos que usam a mesma senha ("senha123").
-- Vulnerável a ataques de rainbow table.
SELECT
    'senha123'                  AS senha_original,
    SHA2('senha123', 256)       AS hash_nivel1_sem_salt;

-- ────────────────────────────────────────────────────────────────
-- NÍVEL 2 — SHA2-256 com salt (salt = SHA2 do id + created_at)
-- ────────────────────────────────────────────────────────────────
-- O salt é único por usuário: SHA2(id_usuario || created_at, 256)
-- Mesmo que dois usuários tenham a mesma senha, os hashes serão
-- diferentes, eliminando a vulnerabilidade de rainbow table.
SELECT
    'senha123'                                               AS senha_original,
    SHA2('uuid-exemplo-2026-06-17 10:00:00', 256)           AS salt_gerado,
    SHA2(
        CONCAT('senha123',
               SHA2('uuid-exemplo-2026-06-17 10:00:00', 256)),
        256)                                                 AS hash_nivel2_com_salt;

-- ────────────────────────────────────────────────────────────────
-- NÍVEL 3 — SHA2-256 com salt + 3 iterações (key stretching)
-- ────────────────────────────────────────────────────────────────
-- Cada iteração extra aumenta o custo de um ataque de força bruta.
-- 3 rodadas → o atacante precisa calcular o hash 3 vezes por tentativa.
-- Em produção usa-se bcrypt/Argon2 com centenas de iterações,
-- mas este exemplo ilustra o conceito de forma clara em SQL puro.
SELECT
    'senha123'                                                   AS senha_original,
    SHA2(
        SHA2(
            SHA2(CONCAT('senha123',
                        SHA2('uuid-exemplo-2026-06-17 10:00:00', 256)),
                 256),
        256),
    256)                                                         AS hash_nivel3_com_3_iteracoes;

-- Comparação dos três níveis lado a lado
SELECT
    SHA2('senha123', 256)                                        AS nivel1_sem_salt,
    SHA2(CONCAT('senha123', SHA2('uuid-2026', 256)), 256)        AS nivel2_com_salt,
    SHA2(SHA2(SHA2(CONCAT('senha123', SHA2('uuid-2026', 256)),
                   256), 256), 256)                              AS nivel3_salt_3x;

-- Exemplo real: ver senha armazenada de um usuário (hash + salt)
SELECT nome,
       email,
       salt,
       senha AS senha_hash_armazenada,
       DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') AS cadastrado_em
FROM usuarios
LIMIT 3;

-- Como a procedure gera o hash na prática:
--   SET v_salt       = SHA2(CONCAT(v_id, v_now), 256);         -- nível 1
--   SET v_senha_hash = SHA2(SHA2(SHA2(CONCAT(senha, v_salt),   -- nível 2 + 3
--                                     256), 256), 256);
-- Cada usuário tem um salt diferente → hashes sempre únicos.


-- ================================================================
-- SEÇÃO 4 — FUNÇÕES SQL
-- ================================================================

-- ── Funções de Texto ────────────────────────────────────────────

-- UPPER: títulos em maiúsculas
SELECT UPPER(titulo) AS titulo_maiusculo
FROM livros
ORDER BY titulo
LIMIT 5;

-- LOWER: normalizar e-mails
SELECT LOWER(email) AS email_normalizado
FROM usuarios
ORDER BY email
LIMIT 5;

-- CONCAT: montar linha de contato
SELECT CONCAT(nome, ' <', email, '>') AS contato
FROM usuarios
ORDER BY nome
LIMIT 5;

-- LENGTH: títulos mais longos do acervo
SELECT titulo, LENGTH(titulo) AS caracteres
FROM livros
ORDER BY caracteres DESC
LIMIT 5;

-- REPLACE: abreviar editoras na exibição
SELECT titulo,
       REPLACE(editora, 'José Olympio', 'J. Olympio') AS editora_abrev
FROM livros
WHERE editora = 'José Olympio'
LIMIT 5;

-- SUBSTR: primeiros 25 caracteres do título
SELECT SUBSTR(titulo, 1, 25) AS titulo_curto, autor
FROM livros
ORDER BY titulo
LIMIT 5;

-- ── Funções Numéricas ───────────────────────────────────────────

-- COUNT: total de registros
SELECT COUNT(*) AS total_livros    FROM livros;
SELECT COUNT(*) AS total_usuarios  FROM usuarios;
SELECT COUNT(*) AS total_emprestimos FROM emprestimos;

-- SUM: valor total do acervo
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- AVG: preço médio dos livros
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- MAX: livro mais caro
SELECT titulo, autor, preco AS maior_preco
FROM livros
ORDER BY preco DESC
LIMIT 1;

-- MIN: livro mais barato
SELECT titulo, autor, preco AS menor_preco
FROM livros
ORDER BY preco ASC
LIMIT 1;

-- ── Funções de Data ─────────────────────────────────────────────

-- NOW: data e hora do servidor
SELECT NOW() AS data_hora_atual;

-- CURDATE: somente a data de hoje
SELECT CURDATE() AS data_hoje;

-- DATE_FORMAT: formato brasileiro
SELECT nome,
       DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') AS cadastrado_em
FROM usuarios
ORDER BY created_at
LIMIT 5;

-- DATE_ADD: devolução = saída + 14 dias
SELECT l.titulo,
       e.data_saida,
       DATE_ADD(e.data_saida, INTERVAL 14 DAY) AS devolucao_calculada
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
LIMIT 5;

-- DATEDIFF: dias em aberto para empréstimos pendentes
SELECT l.titulo,
       DATEDIFF(CURDATE(), e.data_saida) AS dias_em_aberto
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
ORDER BY dias_em_aberto DESC
LIMIT 5;


-- ================================================================
-- SEÇÃO 5 — RELACIONAMENTO ENTRE TABELAS
-- ================================================================

-- Integridade referencial em ação:
-- Tentativa de deletar um livro com empréstimo → erro (RESTRICT)
-- DELETE FROM livros WHERE titulo = 'Dom Casmurro';
-- Erro: "Cannot delete or update a parent row: a foreign key constraint fails"

-- Regras de exclusão definidas:
--   ON DELETE RESTRICT  → bloqueia exclusão se houver registros filhos
--   ON UPDATE CASCADE   → atualiza FK nos filhos se o PK pai mudar

-- Listar FK ativas
SELECT
    CONSTRAINT_NAME,
    TABLE_NAME          AS tabela_filha,
    COLUMN_NAME         AS coluna_fk,
    REFERENCED_TABLE_NAME  AS tabela_pai,
    REFERENCED_COLUMN_NAME AS coluna_pk
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'biblioteca'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ================================================================
-- SEÇÃO 6 — CONSULTAS COM JOIN
-- ================================================================

-- INNER JOIN: empréstimos com dados de usuário e livro
-- (apenas registros com correspondência nos dois lados)
SELECT u.nome        AS usuario,
       l.titulo      AS livro,
       e.data_saida,
       e.data_devolucao_prevista,
       e.status
FROM emprestimos e
INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
INNER JOIN livros   l ON e.id_livro   = l.id_livro
ORDER BY e.data_saida DESC
LIMIT 10;

-- LEFT JOIN: todos os livros, inclusive os nunca emprestados
-- (livros sem empréstimo aparecem com NULL)
SELECT l.titulo,
       l.autor,
       e.data_saida,
       e.status
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
ORDER BY l.titulo
LIMIT 10;

-- LEFT JOIN filtrado: livros que NUNCA foram emprestados
SELECT l.titulo,
       l.autor,
       l.preco
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
WHERE e.id_emprestimo IS NULL
ORDER BY l.titulo;

-- RIGHT JOIN: todos os usuários, inclusive sem empréstimo algum
-- (usuários sem empréstimo aparecem com NULL)
SELECT u.nome   AS usuario,
       u.email,
       e.data_saida,
       e.status
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
ORDER BY u.nome;

-- RIGHT JOIN filtrado: usuários que NUNCA fizeram empréstimo
SELECT u.nome  AS usuario,
       u.email,
       DATE_FORMAT(u.created_at, '%d/%m/%Y') AS cadastrado_em
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.id_emprestimo IS NULL
ORDER BY u.nome;


-- ================================================================
-- SEÇÃO 7 — RELATÓRIOS E INDICADORES
-- ================================================================

-- Total de usuários cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- Total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- Total de empréstimos por status
SELECT status, COUNT(*) AS quantidade
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

-- Valor dos livros atualmente em circulação (SUM)
SELECT ROUND(SUM(l.preco), 2) AS valor_em_circulacao
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status IN ('pendente', 'atrasado');

-- Média de dias de atraso nas devoluções tardias (AVG)
SELECT ROUND(
    AVG(DATEDIFF(data_devolucao_real, data_devolucao_prevista)), 1
) AS media_dias_atraso
FROM emprestimos
WHERE status = 'devolvido'
  AND data_devolucao_real > data_devolucao_prevista;

-- Usuários com mais empréstimos (COUNT + GROUP BY)
SELECT u.nome        AS usuario,
       COUNT(*)      AS total_emprestimos
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY total_emprestimos DESC
LIMIT 5;

-- Livros mais emprestados (COUNT + GROUP BY)
SELECT l.titulo      AS livro,
       l.autor,
       COUNT(*)      AS vezes_emprestado
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
GROUP BY l.id_livro, l.titulo, l.autor
ORDER BY vezes_emprestado DESC
LIMIT 5;
