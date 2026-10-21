-- ================================================================
-- 00_base.sql -- Base do projeto (NAO faz parte da entrega do 4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================
-- Recria o banco "biblioteca" do zero, igual ao 3 bimestre:
-- tabelas, procedure de cadastro, constraints, DCL e dados.
-- Datas dos emprestimos sao RELATIVAS a CURDATE(), entao o banco
-- fica coerente em qualquer dia em que for executado.
--
-- Ordem de execucao no MySQL Workbench:
--   00_base.sql -> 01_estrutura.sql -> 02_procedures.sql
--   -> 03_cursor.sql -> 04_triggers.sql -> 05..09 (testes)
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

-- Grupo E -- Pendentes com prazo JA vencido, ainda nao reclassificados
-- como 'atrasado' (3). Sao estes registros que o cursor do 4 bimestre
-- (sp_atualizar_atrasos) encontra e corrige.
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'O Cortico'),         (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),  DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 5 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitaes da Areia'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'), DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'),           (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),  DATE_SUB(CURDATE(), INTERVAL 18 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 'pendente');
