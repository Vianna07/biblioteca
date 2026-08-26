-- ================================================================
-- APRESENTACAO -- Banco de Dados 3 Bimestre
-- Sistema: Biblioteca Digital
-- ================================================================
-- Continuidade do projeto do 2 bimestre (mesmas 3 tabelas: livros,
-- usuarios, emprestimos). O modelo relacional NAO mudou -- todos os
-- recursos do 3 bimestre (indices, views, functions, consultas
-- avancadas) foram construidos em cima da estrutura ja existente,
-- entao o DER/Modelo Relacional entregue no 2 bimestre continua
-- valido e e reapresentado sem alteracoes de entidades.
--
-- Diferenca importante em relacao ao script do 2 bimestre: as datas
-- de emprestimo aqui sao geradas de forma RELATIVA a CURDATE() (com
-- DATE_SUB/DATE_ADD), em vez de datas fixas. Isso corrige o problema
-- que tivemos antes (datas fixas em 2026-06 ficaram "no passado" e
-- pararam de fazer sentido) e garante que a apresentacao funcione
-- corretamente em qualquer dia que for executada.
--
-- Estrutura:
--   Setup     -- DDL, Procedure, Constraints, DCL (igual ao 2 bim)
--   Insercao  -- DML (dados novos, datas relativas a hoje)
--   Secao 1   -- Apresentacao do Projeto
--   Secao 2   -- Funcoes de Agregacao (COUNT, SUM, MAX, MIN, AVG)
--   Secao 3   -- GROUP BY e HAVING
--   Secao 4   -- Operadores de Conjunto (UNION, UNION ALL, EXCEPT, INTERSECT)
--   Secao 5   -- DISTINCT, IN, EXISTS, NOT EXISTS
--   Secao 6   -- Indices
--   Secao 7   -- EXPLAIN
--   Secao 8   -- Views
--   Secao 9   -- Functions
--   Secao 10  -- Relatorio Avancado
--   Secao 11  -- Roteiro de demonstracao (MySQL Workbench)
--   Secao 12  -- Analise dos resultados
--   Secao 13  -- Conclusao
-- ================================================================


-- ================================================================
-- SETUP -- Recriar banco do zero para apresentacao limpa
-- ================================================================

DROP DATABASE IF EXISTS biblioteca;

DROP USER IF EXISTS 'admin_biblioteca'@'localhost';
DROP USER IF EXISTS 'atendente_biblioteca'@'localhost';
DROP USER IF EXISTS 'estagiario_biblioteca'@'localhost';

CREATE DATABASE biblioteca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE biblioteca;

-- ----------------------------------------------------------------
-- Tabelas (identicas ao 2 bimestre -- nenhuma entidade nova)
-- ----------------------------------------------------------------

CREATE TABLE livros (
    id_livro       CHAR(36)      PRIMARY KEY DEFAULT (UUID()),
    titulo         VARCHAR(255)  NOT NULL,
    autor          VARCHAR(100)  NOT NULL,
    editora        VARCHAR(100),
    ano_lancamento INT,
    preco          DECIMAL(8, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE usuarios (
    id_usuario CHAR(36)     PRIMARY KEY DEFAULT (UUID()),
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    senha      VARCHAR(64)  NOT NULL,
    salt       VARCHAR(64)  NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE emprestimos (
    id_emprestimo           CHAR(36)                                  PRIMARY KEY DEFAULT (UUID()),
    id_livro                CHAR(36)                                  NOT NULL,
    id_usuario              CHAR(36)                                  NOT NULL,
    data_saida              DATE                                      NOT NULL,
    data_devolucao_prevista DATE                                      NOT NULL,
    data_devolucao_real     DATE,
    status                  ENUM('pendente', 'atrasado', 'devolvido') NOT NULL DEFAULT 'pendente'
);

-- ----------------------------------------------------------------
-- Procedure de cadastro com hash em 3 camadas (2 bimestre)
-- ----------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE cadastrar_usuario(
    IN p_nome  VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255)
)
BEGIN
    DECLARE v_id         CHAR(36);
    DECLARE v_now        TIMESTAMP;
    DECLARE v_salt       VARCHAR(64);
    DECLARE v_senha_hash VARCHAR(64);

    SET v_id  = UUID();
    SET v_now = NOW();

    SET v_salt = SHA2(CONCAT(v_id, v_now), 256);

    SET v_senha_hash = SHA2(
                           SHA2(
                               SHA2(CONCAT(p_senha, v_salt), 256),
                           256),
                       256);

    INSERT INTO usuarios (id_usuario, nome, email, senha, salt, created_at)
    VALUES (v_id, p_nome, p_email, v_senha_hash, v_salt, v_now);
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- Constraints
-- ----------------------------------------------------------------

ALTER TABLE emprestimos ADD CONSTRAINT check_datas
    CHECK (data_devolucao_prevista >= data_saida);

ALTER TABLE emprestimos ADD CONSTRAINT fk_emprestimo_livro
    FOREIGN KEY (id_livro)   REFERENCES livros(id_livro)    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE emprestimos ADD CONSTRAINT fk_emprestimo_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE;

-- ----------------------------------------------------------------
-- DCL -- Usuarios do banco e permissoes (igual ao 2 bimestre)
-- ----------------------------------------------------------------

CREATE USER IF NOT EXISTS 'admin_biblioteca'@'localhost'      IDENTIFIED BY 'admin_senha';
CREATE USER IF NOT EXISTS 'atendente_biblioteca'@'localhost'  IDENTIFIED BY 'atendente_senha';
CREATE USER IF NOT EXISTS 'estagiario_biblioteca'@'localhost' IDENTIFIED BY 'estagiario_senha';

GRANT ALL PRIVILEGES ON biblioteca.* TO 'admin_biblioteca'@'localhost' WITH GRANT OPTION;

GRANT SELECT, INSERT, UPDATE ON biblioteca.livros      TO 'atendente_biblioteca'@'localhost';
GRANT SELECT, INSERT, UPDATE ON biblioteca.emprestimos TO 'atendente_biblioteca'@'localhost';
GRANT SELECT                 ON biblioteca.usuarios    TO 'atendente_biblioteca'@'localhost';

GRANT SELECT ON biblioteca.* TO 'estagiario_biblioteca'@'localhost';

REVOKE UPDATE ON biblioteca.livros FROM 'atendente_biblioteca'@'localhost';

FLUSH PRIVILEGES;


-- ================================================================
-- INSERCAO DE DADOS (DML)
-- ================================================================

-- ----------------------------------------------------------------
-- Usuarios
-- ----------------------------------------------------------------
-- Rafael e Sofia ficam SEM nenhum emprestimo de proposito: servem
-- de exemplo real para as consultas EXCEPT e "usuarios que nunca
-- pegaram livro emprestado" mais adiante.

INSERT INTO usuarios (id_usuario, nome, email, senha, salt, created_at) VALUES
    (UUID(), 'Rafael Nascimento', 'rafael.nascimento@email.com', SHA2('senha123', 256), '', NOW()),
    (UUID(), 'Sofia Cardoso',     'sofia.cardoso@email.com',     SHA2('senha123', 256), '', NOW());

CALL cadastrar_usuario('Ana Clara Silva',   'ana.silva@email.com',       'senha123');
CALL cadastrar_usuario('Bruno Oliveira',    'bruno.oliveira@email.com',  'senha123');
CALL cadastrar_usuario('Carla Mendes',      'carla.mendes@email.com',    'senha123');
CALL cadastrar_usuario('Daniel Souza',      'daniel.souza@email.com',    'senha123');
CALL cadastrar_usuario('Elena Ferreira',    'elena.ferreira@email.com',  'senha123');
CALL cadastrar_usuario('Felipe Santos',     'felipe.santos@email.com',   'senha123');
CALL cadastrar_usuario('Gabriela Lima',     'gabriela.lima@email.com',   'senha123');
CALL cadastrar_usuario('Hugo Pereira',      'hugo.pereira@email.com',    'senha123');
CALL cadastrar_usuario('Isabela Costa',     'isabela.costa@email.com',   'senha123');
CALL cadastrar_usuario('Joao Almeida',      'joao.almeida@email.com',    'senha123');

-- ----------------------------------------------------------------
-- Livros (acervo com preco)
-- ----------------------------------------------------------------
-- Os 3 ultimos titulos (Olhai os Lirios do Campo, Noite na Taverna,
-- Dois Irmaos) nunca aparecem em nenhum emprestimo de proposito:
-- servem de exemplo real para NOT EXISTS / "livros nunca emprestados".

INSERT INTO livros (titulo, autor, editora, ano_lancamento, preco) VALUES
('Dom Casmurro',                        'Machado de Assis',          'Garnier',              1899, 29.90),
('Grande Sertao: Veredas',              'Guimaraes Rosa',            'Jose Olympio',         1956, 54.90),
('Memorias Postumas de Bras Cubas',     'Machado de Assis',          'Tipografia Nacional',  1881, 24.90),
('O Cortico',                           'Aluisio Azevedo',           'B. L. Garnier',        1890, 22.50),
('Capitaes da Areia',                   'Jorge Amado',               'Jose Olympio',         1937, 34.90),
('Vidas Secas',                         'Graciliano Ramos',          'Jose Olympio',         1938, 27.90),
('A Hora da Estrela',                   'Clarice Lispector',         'Jose Olympio',         1977, 39.90),
('O Alienista',                         'Machado de Assis',          'Garnier',              1882, 19.90),
('Iracema',                             'Jose de Alencar',           'Tipografia Viana',     1865, 18.50),
('Macunaima',                           'Mario de Andrade',          'Oficinas Graficas',    1928, 32.90),
('O Tempo e o Vento',                   'Erico Verissimo',           'Globo',                1949, 69.90),
('Quincas Borba',                       'Machado de Assis',          'Garnier',              1891, 26.90),
('Menino de Engenho',                   'Jose Lins do Rego',         'Jose Olympio',         1932, 28.50),
('Gabriela, Cravo e Canela',            'Jorge Amado',               'Martins',              1958, 42.90),
('Sao Bernardo',                        'Graciliano Ramos',          'Ariel',                1934, 31.00),
('A Moreninha',                         'Joaquim Manuel de Macedo',  'Tipografia Francesa',  1844, 17.90),
('O Guarani',                           'Jose de Alencar',           'Empresa Nacional',     1857, 21.50),
('Clara dos Anjos',                     'Lima Barreto',              'Merito',               1948, 23.90),
('Triste Fim de Policarpo Quaresma',    'Lima Barreto',              'Tipografia do Jornal', 1915, 25.90),
('A Paixao Segundo G.H.',               'Clarice Lispector',         'Editora do Autor',     1964, 44.90),
('Lavoura Arcaica',                     'Raduan Nassar',             'Jose Olympio',         1975, 48.50),
('Angustia',                            'Graciliano Ramos',          'Jose Olympio',         1936, 29.00),
('Memorias de um Sargento de Milicias', 'Manuel Antonio de Almeida', 'Tipografia Nacional',  1854, 20.90),
('O Quinze',                            'Rachel de Queiroz',         'Editora Olympio',      1930, 26.50),
('Sagarana',                            'Guimaraes Rosa',            'Universal',            1946, 37.90),
('Fogo Morto',                          'Jose Lins do Rego',         'Jose Olympio',         1943, 33.50),
('Dona Flor e Seus Dois Maridos',       'Jorge Amado',               'Martins',              1966, 45.90),
('Olhai os Lirios do Campo',            'Erico Verissimo',           'Globo',                1938, 35.90),
('Noite na Taverna',                    'Alvares de Azevedo',        'Garnier',              1855, 16.90),
('Dois Irmaos',                         'Milton Hatoum',             'Companhia das Letras', 2000, 52.90);

-- ----------------------------------------------------------------
-- Emprestimos -- todas as datas relativas a CURDATE()
-- ----------------------------------------------------------------

-- Grupo A -- Devolvidos no prazo (5)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),                     (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 48 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'),           (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), DATE_SUB(CURDATE(), INTERVAL 55 DAY), DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 43 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias Postumas de Bras Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),    DATE_SUB(CURDATE(), INTERVAL 50 DAY), DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 38 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Cortico'),                        (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 33 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitaes da Areia'),                (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 28 DAY), 'devolvido');

-- Grupo B -- Devolvidos com atraso (5)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),       (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  DATE_SUB(CURDATE(), INTERVAL 32 DAY), DATE_SUB(CURDATE(), INTERVAL 17 DAY), DATE_SUB(CURDATE(), INTERVAL  9 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Alienista'),       (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL  5 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'),           (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  DATE_SUB(CURDATE(), INTERVAL 28 DAY), DATE_SUB(CURDATE(), INTERVAL 13 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Macunaima'),         (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL  4 DAY), 'devolvido');

-- Grupo C -- Pendentes dentro do prazo (10)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'O Tempo e o Vento'),                (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      DATE_SUB(CURDATE(), INTERVAL  1 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Quincas Borba'),                    (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), DATE_SUB(CURDATE(), INTERVAL  2 DAY), DATE_ADD(CURDATE(), INTERVAL 19 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Menino de Engenho'),                (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   DATE_SUB(CURDATE(), INTERVAL  3 DAY), DATE_ADD(CURDATE(), INTERVAL 18 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Gabriela, Cravo e Canela'),         (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   DATE_SUB(CURDATE(), INTERVAL  4 DAY), DATE_ADD(CURDATE(), INTERVAL 17 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Sao Bernardo'),                     (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), DATE_SUB(CURDATE(), INTERVAL  5 DAY), DATE_ADD(CURDATE(), INTERVAL 16 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Moreninha'),                      (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  DATE_SUB(CURDATE(), INTERVAL  6 DAY), DATE_ADD(CURDATE(), INTERVAL 15 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'O Guarani'),                        (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  DATE_SUB(CURDATE(), INTERVAL  7 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Clara dos Anjos'),                  (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   DATE_SUB(CURDATE(), INTERVAL  8 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Triste Fim de Policarpo Quaresma'), (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  DATE_SUB(CURDATE(), INTERVAL  9 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Paixao Segundo G.H.'),            (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 11 DAY), NULL, 'pendente');

-- Grupo D -- Atrasados, prazo vencido sem devolucao (10)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Lavoura Arcaica'),                      (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 26 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Angustia'),                             (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), DATE_SUB(CURDATE(), INTERVAL 38 DAY), DATE_SUB(CURDATE(), INTERVAL 24 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias de um Sargento de Milicias'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   DATE_SUB(CURDATE(), INTERVAL 36 DAY), DATE_SUB(CURDATE(), INTERVAL 22 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Quinze'),                             (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   DATE_SUB(CURDATE(), INTERVAL 34 DAY), DATE_SUB(CURDATE(), INTERVAL 20 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'),                             (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), DATE_SUB(CURDATE(), INTERVAL 32 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'),                           (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  DATE_SUB(CURDATE(), INTERVAL 29 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'),        (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  DATE_SUB(CURDATE(), INTERVAL 26 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),                         (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   DATE_SUB(CURDATE(), INTERVAL 23 DAY), DATE_SUB(CURDATE(), INTERVAL  9 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'),               (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL  6 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias Postumas de Bras Cubas'),      (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   DATE_SUB(CURDATE(), INTERVAL 17 DAY), DATE_SUB(CURDATE(), INTERVAL  3 DAY), NULL, 'atrasado');

-- Grupo E -- Pendentes prestes a vencer, prazo nos proximos dias (5)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),                     (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'),           (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  DATE_SUB(CURDATE(), INTERVAL 11 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias Postumas de Bras Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   DATE_SUB(CURDATE(), INTERVAL 13 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'O Cortico'),                        (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  DATE_SUB(CURDATE(), INTERVAL 12 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitaes da Areia'),                (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), NULL, 'pendente');

-- Grupo F -- Historico mais antigo, devolvidos no prazo (5)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),       (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      DATE_SUB(CURDATE(), INTERVAL 100 DAY), DATE_SUB(CURDATE(), INTERVAL 86 DAY), DATE_SUB(CURDATE(), INTERVAL 87 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'), (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), DATE_SUB(CURDATE(), INTERVAL  95 DAY), DATE_SUB(CURDATE(), INTERVAL 81 DAY), DATE_SUB(CURDATE(), INTERVAL 82 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Alienista'),       (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   DATE_SUB(CURDATE(), INTERVAL  90 DAY), DATE_SUB(CURDATE(), INTERVAL 76 DAY), DATE_SUB(CURDATE(), INTERVAL 77 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'),           (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   DATE_SUB(CURDATE(), INTERVAL  85 DAY), DATE_SUB(CURDATE(), INTERVAL 71 DAY), DATE_SUB(CURDATE(), INTERVAL 72 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Macunaima'),         (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), DATE_SUB(CURDATE(), INTERVAL  80 DAY), DATE_SUB(CURDATE(), INTERVAL 66 DAY), DATE_SUB(CURDATE(), INTERVAL 67 DAY), 'devolvido');

-- Extras -- criam variacao real de volume por usuario (para o HAVING
-- da secao 3 destacar "quem pegou mais livros emprestados")
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),           (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),     DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL  6 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),            (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),     DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_SUB(CURDATE(), INTERVAL  4 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'),      (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), DATE_SUB(CURDATE(), INTERVAL 22 DAY), DATE_SUB(CURDATE(), INTERVAL  8 DAY), NULL, 'atrasado');


-- ================================================================
-- SECAO 1 -- APRESENTACAO DO PROJETO
-- ================================================================
-- Sistema: Biblioteca Digital
-- 3 tabelas: livros, usuarios, emprestimos (1:N a partir de livros
-- e usuarios; emprestimos e a tabela associativa com os dados do
-- ciclo de emprestimo/devolucao).
-- No 2 bimestre: modelagem, seguranca de senha (hash+salt) e funcoes
-- basicas de texto/numero/data.
-- No 3 bimestre: consultas avancadas sobre os MESMOS dados -- o
-- objetivo nao e crescer o modelo, e extrair mais valor dele.

SELECT 'Biblioteca Digital -- 3 Bimestre' AS sistema,
       (SELECT COUNT(*) FROM livros)      AS total_livros,
       (SELECT COUNT(*) FROM usuarios)    AS total_usuarios,
       (SELECT COUNT(*) FROM emprestimos) AS total_emprestimos;


-- ================================================================
-- SECAO 2 -- FUNCOES DE AGREGACAO
-- ================================================================

-- [COUNT] Quantidade total de usuarios cadastrados
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- [COUNT] Quantidade total de livros no acervo
SELECT COUNT(*) AS total_livros FROM livros;

-- [SUM] Valor total do acervo (soma do preco de todos os livros)
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- [MAX] Livro mais caro do acervo (com os dados completos da linha)
SELECT titulo, autor, preco AS maior_preco
FROM livros
WHERE preco = (SELECT MAX(preco) FROM livros);

-- [MIN] Livro mais barato do acervo (com os dados completos da linha)
SELECT titulo, autor, preco AS menor_preco
FROM livros
WHERE preco = (SELECT MIN(preco) FROM livros);

-- [AVG] Preco medio dos livros do acervo
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- [AVG] Prazo medio concedido por emprestimo (dias entre saida e devolucao prevista)
SELECT ROUND(AVG(DATEDIFF(data_devolucao_prevista, data_saida)), 1) AS prazo_medio_dias
FROM emprestimos;

-- [MAX] Maior atraso ja registrado entre os emprestimos ja devolvidos
SELECT MAX(DATEDIFF(data_devolucao_real, data_devolucao_prevista)) AS maior_atraso_dias
FROM emprestimos
WHERE status = 'devolvido' AND data_devolucao_real > data_devolucao_prevista;

-- ANALISE: as 5 funcoes (COUNT, SUM, MAX, MIN, AVG) resumem o acervo
-- e o comportamento dos emprestimos em numeros unicos -- sao a base
-- de qualquer indicador/dashboard que o sistema venha a exibir.


-- ================================================================
-- SECAO 3 -- GROUP BY E HAVING
-- ================================================================

-- [GROUP BY] Quantidade de livros por autor
SELECT autor, COUNT(*) AS qtd_livros
FROM livros
GROUP BY autor
ORDER BY qtd_livros DESC, autor;

-- [GROUP BY] Quantidade de emprestimos por status
SELECT status, COUNT(*) AS qtd_emprestimos
FROM emprestimos
GROUP BY status
ORDER BY qtd_emprestimos DESC;

-- [GROUP BY + SUM/AVG] Valor total e preco medio do acervo por editora
SELECT editora,
       COUNT(*)              AS qtd_livros,
       SUM(preco)             AS valor_total,
       ROUND(AVG(preco), 2)   AS preco_medio
FROM livros
WHERE editora IS NOT NULL
GROUP BY editora
ORDER BY valor_total DESC;

-- [GROUP BY + HAVING] Autores com mais de 1 livro publicado no acervo
SELECT autor, COUNT(*) AS qtd_livros
FROM livros
GROUP BY autor
HAVING COUNT(*) > 1
ORDER BY qtd_livros DESC;

-- [GROUP BY + HAVING] Usuarios que ja pegaram mais de 4 livros emprestados
SELECT u.nome, u.email, COUNT(*) AS qtd_emprestimos
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
GROUP BY u.id_usuario, u.nome, u.email
HAVING COUNT(*) > 4
ORDER BY qtd_emprestimos DESC;

-- [GROUP BY bonus] Valor total (em preco de capa) ja emprestado por usuario
SELECT u.nome,
       COUNT(*)      AS qtd_emprestimos,
       SUM(l.preco)  AS valor_total_emprestado
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
GROUP BY u.id_usuario, u.nome
ORDER BY valor_total_emprestado DESC
LIMIT 10;

-- ANALISE: GROUP BY agrupa (por autor, status, editora, usuario);
-- HAVING filtra os GRUPOS depois de agregados -- diferente de WHERE,
-- que filtraria linha a linha ANTES de agrupar. Por isso "autor com
-- mais de 1 livro" so e possivel com HAVING, nunca com WHERE.


-- ================================================================
-- SECAO 4 -- OPERADORES DE CONJUNTO
-- ================================================================
-- EXCEPT e INTERSECT exigem MySQL 8.0.31 ou superior (compose.yaml
-- usa a tag mysql:8.0, que ja traz uma versao recente o suficiente).

-- [UNION] Lista de contato (nome, email) de quem precisa de atencao:
-- usuarios com emprestimo atrasado OU com emprestimo prestes a vencer.
-- Quem esta nas duas situacoes ao mesmo tempo aparece UMA UNICA VEZ.
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
UNION
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'pendente'
  AND e.data_devolucao_prevista <= DATE_ADD(CURDATE(), INTERVAL 4 DAY);

-- [UNION ALL] Mesma consulta, mas SEM eliminar duplicados -- serve para
-- contar quantas "situacoes de alerta" cada usuario acumula no momento.
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
UNION ALL
SELECT u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'pendente'
  AND e.data_devolucao_prevista <= DATE_ADD(CURDATE(), INTERVAL 4 DAY);

-- [EXCEPT] Usuarios cadastrados que NUNCA fizeram nenhum emprestimo
SELECT id_usuario, nome, email FROM usuarios
EXCEPT
SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario;

-- [INTERSECT] Usuarios que ja devolveram um livro dentro do prazo
-- E que, em outro emprestimo, ja atrasaram (bom pagador que tambem
-- ja atrasou -- util para politicas de tolerancia/multa)
SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'devolvido' AND e.data_devolucao_real <= e.data_devolucao_prevista
INTERSECT
SELECT u.id_usuario, u.nome, u.email
FROM usuarios u
JOIN emprestimos e ON e.id_usuario = u.id_usuario
WHERE e.status = 'atrasado'
   OR (e.status = 'devolvido' AND e.data_devolucao_real > e.data_devolucao_prevista);

-- ANALISE: UNION elimina duplicados (custo extra de ordenacao/dedup);
-- UNION ALL preserva tudo e e mais barato quando sabemos que nao ha
-- sobreposicao ou quando duplicados sao informacao util (contagem de
-- alertas). EXCEPT resolve "quem esta em A mas nao em B" e INTERSECT
-- "quem esta nos dois" sem precisar de LEFT JOIN + IS NULL.


-- ================================================================
-- SECAO 5 -- DISTINCT, IN, EXISTS, NOT EXISTS
-- ================================================================

-- [DISTINCT] Editoras distintas presentes no acervo
SELECT DISTINCT editora
FROM livros
WHERE editora IS NOT NULL
ORDER BY editora;

-- [IN] Livros que ja foram emprestados pelo menos uma vez
SELECT titulo, autor, preco
FROM livros
WHERE id_livro IN (SELECT id_livro FROM emprestimos)
ORDER BY titulo;

-- [EXISTS] Usuarios que possuem pelo menos um emprestimo em atraso
SELECT nome, email
FROM usuarios u
WHERE EXISTS (
    SELECT 1 FROM emprestimos e
    WHERE e.id_usuario = u.id_usuario AND e.status = 'atrasado'
)
ORDER BY nome;

-- [NOT EXISTS] Livros que NUNCA foram emprestados
SELECT titulo, autor, preco
FROM livros l
WHERE NOT EXISTS (
    SELECT 1 FROM emprestimos e WHERE e.id_livro = l.id_livro
)
ORDER BY titulo;

-- ANALISE: DISTINCT remove repeticoes do resultado final; IN compara
-- contra uma lista/subconsulta; EXISTS/NOT EXISTS apenas checam se a
-- subconsulta correlacionada retorna alguma linha (param, sem precisar
-- trazer os dados) -- geralmente mais eficiente que IN em tabelas grandes
-- porque o MySQL pode parar no primeiro match.


-- ================================================================
-- SECAO 6 -- INDICES
-- ================================================================
-- O que e: uma estrutura auxiliar (B-tree) que o MySQL mantem ao lado
-- da tabela para localizar linhas sem precisar varrer todas elas.
-- Finalidade: acelerar buscas (WHERE), junções (JOIN), ordenação
-- (ORDER BY) e agrupamento (GROUP BY) em colunas muito consultadas.

-- Indice em emprestimos.status -- coluna usada em praticamente todo
-- relatorio de atraso/pendencia (WHERE status = ... e GROUP BY status)
CREATE INDEX idx_emprestimos_status ON emprestimos(status);

-- Indice em livros.autor -- coluna usada nos agrupamentos da secao 3
-- e em buscas de catalogo (WHERE autor = ...)
CREATE INDEX idx_livros_autor ON livros(autor);

-- Demonstracao dos indices criados
SHOW INDEX FROM emprestimos;
SHOW INDEX FROM livros;

-- usuarios.email ja possui indice automatico por causa do UNIQUE
SHOW INDEX FROM usuarios;

-- ANALISE: escolhemos status e autor porque aparecem em WHERE e GROUP
-- BY em quase todas as consultas de relatorio deste script. Beneficio
-- esperado: o MySQL passa de uma varredura completa da tabela (type
-- ALL no EXPLAIN) para uma busca direta pelo indice (type ref).


-- ================================================================
-- SECAO 7 -- ANALISE DE CONSULTA COM EXPLAIN
-- ================================================================

-- Consulta sobre coluna COM indice (idx_emprestimos_status)
EXPLAIN SELECT * FROM emprestimos WHERE status = 'atrasado';

-- Consulta sobre coluna COM indice (idx_livros_autor)
EXPLAIN SELECT * FROM livros WHERE autor = 'Machado de Assis';

-- Contraste: consulta sobre coluna SEM indice (titulo) -- forca
-- varredura completa da tabela (type = ALL), mesmo com poucas linhas
EXPLAIN SELECT * FROM livros WHERE titulo = 'Dom Casmurro';

-- ANALISE: nas duas primeiras consultas o EXPLAIN mostra
-- possible_keys/key apontando para o indice criado na secao 6 e
-- type = ref (busca direta). Na terceira, sem indice em titulo, o
-- type cai para ALL (varredura completa) -- com o volume atual de
-- dados (dezenas de linhas) o tempo de resposta e igual, mas o plano
-- de execucao ja revela que essa consulta NAO escalaria bem se o
-- acervo crescesse para milhares de livros.


-- ================================================================
-- SECAO 8 -- VIEW (VISOES)
-- ================================================================
-- Uma VIEW e uma tabela virtual baseada em uma consulta SQL. Ela nao
-- guarda dados proprios -- toda vez que e consultada, a consulta por
-- tras dela e reexecutada contra as tabelas reais.

-- View 1: vw_emprestimos_detalhados
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

SELECT * FROM vw_emprestimos_detalhados
WHERE status = 'atrasado'
ORDER BY data_devolucao_prevista;

-- View 2: vw_usuarios_publico
-- Objetivo: oculta senha e salt -- qualquer consulta ou integracao que
-- so precise exibir/listar usuarios usa esta view, sem risco de vazar
-- dados sensiveis de autenticacao.
CREATE VIEW vw_usuarios_publico AS
SELECT id_usuario, nome, email, created_at
FROM usuarios;

SELECT * FROM vw_usuarios_publico ORDER BY nome;

-- View 3: vw_relatorio_financeiro_editora
-- Objetivo: relatorio financeiro pronto (quantidade, valor total e
-- preco medio do acervo por editora), sem repetir GROUP BY toda vez.
CREATE VIEW vw_relatorio_financeiro_editora AS
SELECT editora,
       COUNT(*)             AS qtd_livros,
       SUM(preco)            AS valor_total,
       ROUND(AVG(preco), 2)  AS preco_medio
FROM livros
WHERE editora IS NOT NULL
GROUP BY editora;

SELECT * FROM vw_relatorio_financeiro_editora ORDER BY valor_total DESC;

-- ANALISE: as views simplificam consultas complexas (JOIN de 3
-- tabelas vira um SELECT simples) e reforcam seguranca por
-- ocultamento (vw_usuarios_publico nunca expoe senha/salt).


-- ================================================================
-- SECAO 9 -- FUNCTION (FUNCOES SQL)
-- ================================================================
-- Uma FUNCTION recebe parametros, processa e retorna OBRIGATORIAMENTE
-- um valor -- pode ser usada dentro de um SELECT como se fosse uma
-- coluna calculada.

DELIMITER $$

-- Function 1: fn_calcular_multa
-- Objetivo: calcular o valor da multa por atraso de um emprestimo.
-- Parametro: p_id_emprestimo (CHAR 36)
-- Retorno: DECIMAL(8,2) -- valor da multa em reais (R$ 1,50 por dia)
CREATE FUNCTION fn_calcular_multa(p_id_emprestimo CHAR(36))
RETURNS DECIMAL(8,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status    ENUM('pendente','atrasado','devolvido');
    DECLARE v_prevista  DATE;
    DECLARE v_real      DATE;
    DECLARE v_dias      INT DEFAULT 0;
    DECLARE c_valor_dia DECIMAL(8,2) DEFAULT 1.50;

    SELECT status, data_devolucao_prevista, data_devolucao_real
      INTO v_status, v_prevista, v_real
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status = 'devolvido' THEN
        SET v_dias = GREATEST(DATEDIFF(v_real, v_prevista), 0);
    ELSEIF v_status = 'atrasado' THEN
        SET v_dias = GREATEST(DATEDIFF(CURDATE(), v_prevista), 0);
    ELSE
        SET v_dias = 0;
    END IF;

    RETURN v_dias * c_valor_dia;
END$$

-- Function 2: fn_classificar_situacao
-- Objetivo: classificar a situacao atual de um emprestimo, reavaliando
-- inclusive emprestimos "pendente" cujo prazo ja passou (nao reclassificados
-- ainda no status armazenado).
-- Parametro: p_id_emprestimo (CHAR 36)
-- Retorno: VARCHAR(30)
CREATE FUNCTION fn_classificar_situacao(p_id_emprestimo CHAR(36))
RETURNS VARCHAR(30)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status   ENUM('pendente','atrasado','devolvido');
    DECLARE v_prevista DATE;
    DECLARE v_real     DATE;
    DECLARE v_situacao VARCHAR(30);

    SELECT status, data_devolucao_prevista, data_devolucao_real
      INTO v_status, v_prevista, v_real
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status = 'devolvido' THEN
        IF v_real > v_prevista THEN
            SET v_situacao = 'Devolvido com atraso';
        ELSE
            SET v_situacao = 'Devolvido no prazo';
        END IF;
    ELSEIF v_status = 'atrasado' THEN
        SET v_situacao = 'Atrasado';
    ELSEIF CURDATE() > v_prevista THEN
        SET v_situacao = 'Atrasado (a regularizar)';
    ELSE
        SET v_situacao = 'No prazo';
    END IF;

    RETURN v_situacao;
END$$

DELIMITER ;

-- Exemplo de execucao -- fn_calcular_multa
SELECT id_emprestimo,
       status,
       fn_calcular_multa(id_emprestimo) AS multa_estimada
FROM emprestimos
WHERE status IN ('atrasado', 'devolvido')
ORDER BY multa_estimada DESC
LIMIT 10;

-- Exemplo de execucao -- fn_classificar_situacao, usada dentro da view
-- de emprestimos detalhados para dar um diagnostico legivel
SELECT usuario, livro, status AS status_armazenado,
       fn_classificar_situacao(id_emprestimo) AS situacao_atual,
       fn_calcular_multa(id_emprestimo)       AS multa_estimada
FROM vw_emprestimos_detalhados
ORDER BY multa_estimada DESC
LIMIT 10;

-- ANALISE: as functions centralizam regra de negocio (calculo de
-- multa, classificacao de situacao) dentro do banco -- qualquer
-- consulta ou aplicacao que precise dessas informacoes usa o mesmo
-- calculo, sem duplicar a logica em varios lugares.


-- ================================================================
-- SECAO 10 -- RELATORIO AVANCADO DO SISTEMA
-- ================================================================
-- Combina JOIN + funcoes de agregacao + GROUP BY + HAVING + ORDER BY
-- + subconsulta: usuarios com emprestimo atrasado de livros ACIMA do
-- preco medio do acervo -- quem representa o maior valor de acervo
-- em risco no momento.

SELECT u.nome AS usuario,
       u.email,
       COUNT(*)                                                            AS qtd_emprestimos_atrasados,
       SUM(l.preco)                                                        AS valor_total_em_risco,
       ROUND(AVG(DATEDIFF(CURDATE(), e.data_devolucao_prevista)), 1)       AS media_dias_atraso
FROM emprestimos e
JOIN usuarios u ON u.id_usuario = e.id_usuario
JOIN livros   l ON l.id_livro   = e.id_livro
WHERE e.status = 'atrasado'
  AND l.preco > (SELECT AVG(preco) FROM livros)  -- subconsulta: so livros acima do preco medio
GROUP BY u.id_usuario, u.nome, u.email
HAVING COUNT(*) >= 1
ORDER BY valor_total_em_risco DESC;

-- ANALISE: este relatorio simula uma situacao real de gestao -- "quais
-- usuarios concentram o maior valor de acervo em atraso, considerando
-- apenas os livros mais caros?" -- e so e possivel combinando todos os
-- recursos do 3 bimestre em uma unica consulta.


-- ================================================================
-- SECAO 11 -- ROTEIRO DE DEMONSTRACAO (MySQL Workbench)
-- ================================================================
-- Ordem sugerida para a apresentacao ao vivo:
--   1. USE biblioteca; -- mostrar as 3 tabelas (DESCRIBE livros/usuarios/emprestimos)
--   2. SELECT * de cada tabela (poucos registros, mostrar os dados reais)
--   3. Secao 2 -- rodar as 8 consultas de agregacao
--   4. Secao 3 -- GROUP BY simples, depois GROUP BY + HAVING
--   5. Secao 4 -- UNION x UNION ALL lado a lado (contar as linhas!),
--      depois EXCEPT e INTERSECT
--   6. Secao 5 -- DISTINCT, IN, EXISTS, NOT EXISTS
--   7. Secao 6 -- CREATE INDEX + SHOW INDEX
--   8. Secao 7 -- EXPLAIN antes/depois de indice (mostrar a coluna "type")
--   9. Secao 8 -- SELECT * FROM cada view criada
--  10. Secao 9 -- executar as functions dentro de um SELECT
--  11. Secao 10 -- relatorio avancado final


-- ================================================================
-- SECAO 12 -- ANALISE DOS RESULTADOS
-- ================================================================
-- Resumo do "problema / por que / resultado / importancia" de cada
-- recurso (os detalhes especificos ja estao nos comentarios -- ANALISE:
-- de cada secao acima):
--
-- Agregacao (Secao 2)     -> Problema: extrair indicadores do acervo e
--   dos emprestimos sem processar linha a linha na aplicacao. Resultado:
--   numeros unicos (totais, medias, extremos). Importancia: base de
--   qualquer dashboard/relatorio gerencial.
--
-- GROUP BY/HAVING (Secao 3) -> Problema: comparar grupos (autores,
--   usuarios, editoras) entre si. Resultado: rankings e filtros pos-
--   agregacao. Importancia: identifica concentracao (autor com mais
--   titulos, usuario com mais emprestimos).
--
-- Operadores de conjunto (Secao 4) -> Problema: combinar/comparar
--   resultados de duas consultas sem JOIN complexo. Resultado: listas
--   de contato unificadas, usuarios nunca atendidos, usuarios em duas
--   situacoes ao mesmo tempo. Importancia: substitui logica que, em
--   SQL puro sem esses operadores, exigiria LEFT JOIN + IS NULL.
--
-- DISTINCT/IN/EXISTS (Secao 5) -> Problema: eliminar repeticao e checar
--   pertencimento/existencia de forma eficiente. Resultado: catalogo de
--   editoras unico, livros em circulacao, usuarios inadimplentes, acervo
--   parado. Importancia: EXISTS evita trazer dados desnecessarios so
--   para checar se "existe pelo menos um".
--
-- Indices/EXPLAIN (Secoes 6-7) -> Problema: consultas de relatorio
--   repetidas sobre status/autor. Resultado: EXPLAIN confirma o uso do
--   indice (type=ref) contra a varredura completa (type=ALL). Importancia:
--   sustenta desempenho quando o volume de dados crescer.
--
-- Views (Secao 8) -> Problema: reescrever o mesmo JOIN de 3 tabelas em
--   toda consulta, e expor senha/salt sem necessidade. Resultado: consultas
--   reduzidas a um SELECT simples. Importancia: organizacao e seguranca
--   de acesso aos dados.
--
-- Functions (Secao 9) -> Problema: calculo de multa e classificacao de
--   situacao espalhados pela aplicacao. Resultado: logica centralizada no
--   banco, reaproveitavel em qualquer SELECT. Importancia: uma unica fonte
--   de verdade para regra de negocio.


-- ================================================================
-- SECAO 13 -- CONCLUSAO
-- ================================================================

-- ----------------------------------------------------------------
-- Principais dificuldades encontradas
-- ----------------------------------------------------------------
-- 1. Datas de teste fixas (2 bimestre)
--    O script anterior usava datas fixas em 2026-06; com o tempo elas
--    "ficaram no passado" e pararam de representar corretamente
--    emprestimos "pendentes" ou "prestes a vencer". Neste bimestre, a
--    massa de dados foi reconstruida usando DATE_SUB/DATE_ADD a partir
--    de CURDATE(), tornando a apresentacao valida em qualquer data.
--
-- 2. Compatibilidade do EXCEPT/INTERSECT
--    Esses operadores so existem no MySQL a partir da versao 8.0.31 --
--    foi preciso confirmar a versao antes de depender deles no script.
--
-- 3. Logica condicional dentro de FUNCTION
--    Calcular multa/situacao exige tratar 3 status diferentes
--    (pendente, atrasado, devolvido) e casos de data em aberto (sem
--    data_devolucao_real). Resolvido com IF/ELSEIF dentro da function,
--    reaproveitando o mesmo raciocinio usado nas consultas manuais.
--
-- 4. Dados de teste com interseccao real
--    Para o UNION/UNION ALL mostrarem diferenca de fato (e para o
--    INTERSECT nao retornar vazio), foi preciso planejar deliberadamente
--    quais usuarios apareceriam em mais de uma situacao ao mesmo tempo.
--
-- ----------------------------------------------------------------
-- Principais conhecimentos adquiridos
-- ----------------------------------------------------------------
-- - Diferenca pratica entre UNION (elimina duplicatas) e UNION ALL
--   (mantem), e quando EXCEPT/INTERSECT substituem um LEFT JOIN + IS
--   NULL com uma sintaxe mais direta.
-- - Como o MySQL escolhe indices e como o EXPLAIN revela isso na
--   pratica (colunas type, possible_keys, key, rows).
-- - VIEWS como camada de simplificacao e de seguranca (ocultar
--   colunas sensiveis) sem duplicar dados.
-- - FUNCTIONS com retorno obrigatorio, uso de DETERMINISTIC/READS SQL
--   DATA, e como usa-las como coluna calculada dentro de um SELECT.
-- - EXISTS/NOT EXISTS como alternativa mais eficiente ao IN quando a
--   subconsulta e correlacionada.
--
-- ----------------------------------------------------------------
-- Recursos SQL mais importantes para o projeto
-- ----------------------------------------------------------------
-- - Indices + EXPLAIN, por resolverem um problema real de desempenho
--   de forma mensuravel (nao e so teoria).
-- - Views, por simplificarem o acesso aos dados sem duplicar JOINs.
--
-- ----------------------------------------------------------------
-- Melhorias realizadas no banco de dados
-- ----------------------------------------------------------------
-- - Indices em emprestimos.status e livros.autor.
-- - 3 views de leitura (detalhada, publica sem dados sensiveis, e
--   relatorio financeiro por editora).
-- - 2 functions que centralizam regra de negocio (multa e situacao).
-- - Massa de dados relativa a data atual, tornando a demonstracao
--   reproduzivel em qualquer dia.
--
-- ----------------------------------------------------------------
-- Melhorias futuras que poderiam ser implementadas
-- ----------------------------------------------------------------
-- 1. Tabela de categorias para os livros (N:N), permitindo GROUP BY
--    categoria de fato, alem de autor/editora.
-- 2. Trigger ou EVENT agendado para migrar automaticamente emprestimos
--    de 'pendente' para 'atrasado' quando o prazo vencer, eliminando a
--    necessidade da reclassificacao dinamica feita hoje em
--    fn_classificar_situacao.
-- 3. Indice composto (status, data_devolucao_prevista) para acelerar
--    especificamente a consulta de "prestes a vencer".
-- 4. Persistir o valor da multa (coluna ou tabela historica) em vez de
--    recalcula-la a cada SELECT via function.
--
-- ----------------------------------------------------------------
-- Consideracoes sobre desempenho das consultas
-- ----------------------------------------------------------------
-- Com o volume atual (dezenas de linhas), a diferenca de tempo entre
-- consultas com e sem indice e imperceptivel -- mas o EXPLAIN ja mostra
-- a mudanca de plano de execucao (type ALL -> type ref), que se tornaria
-- significativa em escala de producao, com milhares de emprestimos.
