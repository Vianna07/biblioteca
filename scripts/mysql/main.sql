-- ================================================================
-- main.sql (MySQL) -- Orquestrador compativel com MySQL 8.0
-- Unica diferenca em relacao ao MariaDB: tabelas usam CHAR(36)
-- em vez do tipo UUID nativo.
-- ================================================================

SOURCE /scripts/ddl/database.sql;

-- Tabelas MySQL-especificas (CHAR(36) em vez de UUID)
SOURCE /scripts/mysql/ddl/tables.sql;

-- Os demais scripts sao compativeis com MySQL sem alteracao
SOURCE /scripts/ddl/procedures.sql;

SOURCE /scripts/constraints/check.sql;
SOURCE /scripts/constraints/fk.sql;

SOURCE /scripts/dcl/user.sql;
SOURCE /scripts/dcl/grant.sql;
SOURCE /scripts/dcl/revoke.sql;
SOURCE /scripts/dcl/flush.sql;

SOURCE /scripts/dml/usuarios.sql;
SOURCE /scripts/dml/livros.sql;
SOURCE /scripts/dml/emprestimos.sql;

-- Indices, views e functions do 3o bimestre (MySQL-especificos: CHAR(36))
SOURCE /scripts/mysql/ddl/indexes.sql;
SOURCE /scripts/mysql/ddl/views.sql;
SOURCE /scripts/mysql/ddl/functions.sql;
