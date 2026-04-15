-- =============================================
-- main.sql - Script orquestrador da biblioteca
-- Executa todos os scripts na ordem correta
-- =============================================

-- 1. Criação do banco de dados
SOURCE /scripts/ddl/database.sql;

-- 2. Criação das tabelas
SOURCE /scripts/ddl/tables.sql;

-- 3. Constraints (checks e foreign keys)
SOURCE /scripts/constraints/check.sql;
SOURCE /scripts/constraints/fk.sql;

-- 4. DCL (usuários, permissões)
SOURCE /scripts/dcl/user.sql;
SOURCE /scripts/dcl/grant.sql;
SOURCE /scripts/dcl/revoke.sql;
SOURCE /scripts/dcl/flush.sql;

-- 5. DML (inserção de dados)
SOURCE /scripts/dml/usuarios.sql;
SOURCE /scripts/dml/livros.sql;
SOURCE /scripts/dml/emprestimos.sql;

-- 6. DQL (consultas)
SOURCE /scripts/dql/livros.sql;
SOURCE /scripts/dql/usuarios.sql;
SOURCE /scripts/dql/emprestimos_atrasados.sql;
SOURCE /scripts/dql/emprestimos_pendentes.sql;
SOURCE /scripts/dql/emprestimos_prestes_a_vencer.sql;
SOURCE /scripts/dql/devolvidos_com_atraso.sql;
SOURCE /scripts/dql/emprestimos_por_usuario.sql;
SOURCE /scripts/dql/livros_mais_emprestados.sql;
SOURCE /scripts/dql/livros_nunca_emprestados.sql;
SOURCE /scripts/dql/usuarios_mais_atrasos.sql;
SOURCE /scripts/dql/livros_emprestados_atualmente.sql;
SOURCE /scripts/dql/media_dias_emprestimo.sql;
