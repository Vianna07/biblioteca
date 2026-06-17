-- ================================================================
-- test.sql -- Teste simples de conectividade MySQL 8.0
-- ================================================================

CREATE DATABASE IF NOT EXISTS teste_mysql;
USE teste_mysql;

CREATE TABLE hello_world (
    id         INT          AUTO_INCREMENT PRIMARY KEY,
    mensagem   VARCHAR(100) NOT NULL,
    criado_em  TIMESTAMP    DEFAULT NOW()
);

INSERT INTO hello_world (mensagem) VALUES
    ('MySQL 8.0 funcionando!'),
    ('SHA2 funcionando!'),
    ('UUID funcionando!');

SELECT id,
       mensagem,
       DATE_FORMAT(criado_em, '%d/%m/%Y %H:%i:%s') AS criado_em
FROM hello_world;

-- Testar funcoes que serao usadas no projeto
SELECT SHA2('senha_teste', 256) AS hash_sha256;
SELECT UUID()                   AS novo_uuid;
SELECT NOW()                    AS data_hora_atual;

DROP DATABASE teste_mysql;
