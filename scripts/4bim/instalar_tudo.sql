-- ================================================================
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- INSTALACAO COMPLETA: recria o banco do zero e cria tabela de log,
-- procedures, cursor e triggers. Nao tem testes, entao roda inteiro
-- com o botao do raio (Ctrl+Shift+Enter). Conecte como root.
-- Depois rode os testes (05..09) bloco a bloco.
-- Gerado por docs/4bim/gerar_documento.py a partir de 00..04.
-- ================================================================


-- ################################################################
-- 00_base.sql
-- ################################################################

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


-- ################################################################
-- 01_estrutura.sql
-- ################################################################

-- ================================================================
-- 01_estrutura.sql -- Ajustes de estrutura e tabela de log (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Pre-requisito: 00_base.sql executado (banco recem-criado).
-- ================================================================

USE biblioteca;

-- O MySQL Workbench vem com "safe updates" ligado, que bloqueia
-- UPDATE/DELETE sem WHERE por chave (Error 1175).
SET SQL_SAFE_UPDATES = 0;

-- ----------------------------------------------------------------
-- Tabela: livros (ajuste) | Responsavel: Gustavo Vianna
-- Objetivo: controlar quantos exemplares fisicos cada titulo tem e
-- quantos estao disponiveis na estante. E o "estoque" da biblioteca,
-- mantido automaticamente pelas triggers de emprestimo/devolucao.
-- ----------------------------------------------------------------

ALTER TABLE livros
    ADD COLUMN qtd_exemplares INT NOT NULL DEFAULT 1,
    ADD COLUMN qtd_disponivel INT NOT NULL DEFAULT 1;

-- Acervo: classicos mais procurados tem 3 exemplares, os titulos
-- raros apenas 1, o restante 2.
UPDATE livros
SET qtd_exemplares = CASE
        WHEN titulo IN ('Dom Casmurro', 'Vidas Secas', 'Grande Sertao: Veredas') THEN 3
        WHEN titulo IN ('Lavoura Arcaica', 'Dois Irmaos')                       THEN 1
        ELSE 2
    END;

-- Disponivel = exemplares - emprestimos ainda nao devolvidos
UPDATE livros l
SET qtd_disponivel = l.qtd_exemplares - (
        SELECT COUNT(*)
        FROM emprestimos e
        WHERE e.id_livro = l.id_livro
          AND e.status <> 'devolvido'
    );

-- ----------------------------------------------------------------
-- Tabela: log_auditoria | Responsavel: Rafael de Almeida
-- Objetivo: historico de todas as operacoes registradas pelas
-- triggers de auditoria (quem, o que, quando, valor antes/depois).
-- ----------------------------------------------------------------

CREATE TABLE log_auditoria (
    id_log       INT                               AUTO_INCREMENT PRIMARY KEY,
    tabela       VARCHAR(30)                       NOT NULL,
    id_registro  CHAR(36)                          NOT NULL,
    operacao     ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    valor_antigo VARCHAR(500),
    valor_novo   VARCHAR(500),
    usuario_bd   VARCHAR(100)                      NOT NULL,
    data_hora    DATETIME                          NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Conferencia
SELECT titulo, qtd_exemplares, qtd_disponivel FROM livros ORDER BY titulo;
DESCRIBE log_auditoria;


-- ################################################################
-- 02_procedures.sql
-- ################################################################

-- ================================================================
-- 02_procedures.sql -- Stored Procedures (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Regra de multa usada em todo o sistema: R$ 1,50 por dia de atraso,
-- limitada a 30 dias (teto de R$ 45,00).
-- Todas as mensagens de erro usam SQLSTATE '45000' (erro definido
-- pelo usuario) -- no Workbench aparecem como "Error Code: 1644".
-- ================================================================

USE biblioteca;

DROP PROCEDURE IF EXISTS sp_registrar_emprestimo;
DROP PROCEDURE IF EXISTS sp_registrar_devolucao;
DROP PROCEDURE IF EXISTS sp_relatorio_emprestimos_usuario;
DROP PROCEDURE IF EXISTS sp_resumo_usuario;
DROP PROCEDURE IF EXISTS sp_renovar_emprestimo;

DELIMITER $$

-- ----------------------------------------------------------------
-- Procedure: sp_registrar_emprestimo | Responsavel: Gustavo Vianna
-- Tipo: cadastro com validacao (obrigatorio "a")
-- Objetivo: registrar um novo emprestimo a partir do e-mail do
-- usuario e do titulo do livro.
-- Regras: usuario e livro precisam existir; prazo entre 1 e 30 dias;
-- usuario com emprestimo em atraso fica bloqueado; maximo de 3
-- emprestimos ativos por usuario. A disponibilidade do exemplar e
-- validada pela trigger trg_emprestimos_before_insert.
-- Parametros: IN p_email, IN p_titulo, IN p_dias_prazo,
--             OUT p_id_emprestimo (id gerado)
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_registrar_emprestimo(
    IN  p_email         VARCHAR(100),
    IN  p_titulo        VARCHAR(255),
    IN  p_dias_prazo    INT,
    OUT p_id_emprestimo CHAR(36)
)
BEGIN
    DECLARE v_id_usuario CHAR(36);
    DECLARE v_id_livro   CHAR(36);
    DECLARE v_ativos     INT DEFAULT 0;
    DECLARE v_atrasados  INT DEFAULT 0;
    DECLARE v_id_novo    CHAR(36);
    DECLARE v_msg        VARCHAR(255);
    DECLARE c_limite     INT DEFAULT 3;

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    SELECT id_livro INTO v_id_livro
    FROM livros
    WHERE titulo = p_titulo;

    -- Atrasado = status 'atrasado' OU pendente com prazo ja vencido
    SELECT COUNT(*),
           COALESCE(SUM(status = 'atrasado'
                        OR data_devolucao_prevista < CURDATE()), 0)
      INTO v_ativos, v_atrasados
    FROM emprestimos
    WHERE id_usuario = v_id_usuario
      AND status <> 'devolvido';

    IF v_id_usuario IS NULL THEN
        SET v_msg = CONCAT('Usuario nao encontrado: ', IFNULL(p_email, 'NULL'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF v_id_livro IS NULL THEN
        SET v_msg = CONCAT('Livro nao encontrado: ', IFNULL(p_titulo, 'NULL'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF p_dias_prazo IS NULL OR p_dias_prazo NOT BETWEEN 1 AND 30 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo invalido: informe de 1 a 30 dias';
    ELSEIF v_atrasados > 0 THEN
        SET v_msg = CONCAT('Usuario bloqueado: possui ', v_atrasados,
                           ' emprestimo(s) em atraso');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    ELSEIF v_ativos >= c_limite THEN
        SET v_msg = CONCAT('Limite de ', c_limite, ' emprestimos ativos atingido');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    SET v_id_novo = UUID();

    INSERT INTO emprestimos (id_emprestimo, id_livro, id_usuario, data_saida,
                             data_devolucao_prevista, status)
    VALUES (v_id_novo, v_id_livro, v_id_usuario, CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL p_dias_prazo DAY), 'pendente');

    SET p_id_emprestimo = v_id_novo;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_registrar_devolucao | Responsavel: Gabriel Cardoso
-- Tipo: alteracao com validacao + parametro OUT (obrigatorio "c")
-- Objetivo: dar baixa em um emprestimo e devolver a multa devida.
-- Regras: o emprestimo precisa existir e nao pode ja estar devolvido;
-- multa de R$ 1,50 por dia de atraso com teto de 30 dias (CASE).
-- Parametros: IN p_id_emprestimo, OUT p_multa
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_registrar_devolucao(
    IN  p_id_emprestimo CHAR(36),
    OUT p_multa         DECIMAL(8, 2)
)
BEGIN
    DECLARE v_status      VARCHAR(10);
    DECLARE v_prevista    DATE;
    DECLARE v_dias_atraso INT DEFAULT 0;
    DECLARE c_valor_dia   DECIMAL(8, 2) DEFAULT 1.50;

    SELECT status, data_devolucao_prevista
      INTO v_status, v_prevista
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emprestimo nao encontrado';
    ELSEIF v_status = 'devolvido' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este emprestimo ja foi devolvido';
    END IF;

    SET v_dias_atraso = GREATEST(DATEDIFF(CURDATE(), v_prevista), 0);

    SET p_multa = CASE
                      WHEN v_dias_atraso = 0  THEN 0
                      WHEN v_dias_atraso <= 30 THEN v_dias_atraso * c_valor_dia
                      ELSE 30 * c_valor_dia
                  END;

    -- data_devolucao_real e preenchida pela trigger BEFORE UPDATE
    UPDATE emprestimos
    SET status = 'devolvido'
    WHERE id_emprestimo = p_id_emprestimo;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_relatorio_emprestimos_usuario | Responsavel: Rafael de Almeida
-- Tipo: consulta/relatorio com parametros (obrigatorio "b")
-- Objetivo: listar os emprestimos de um usuario em um periodo, com a
-- situacao de cada um e a multa calculada.
-- Regras: usuario precisa existir; data inicial <= data final.
-- Parametros: IN p_email, IN p_data_inicio, IN p_data_fim
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_relatorio_emprestimos_usuario(
    IN p_email       VARCHAR(100),
    IN p_data_inicio DATE,
    IN p_data_fim    DATE
)
BEGIN
    DECLARE v_id_usuario CHAR(36);

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario nao encontrado';
    ELSEIF p_data_inicio IS NULL OR p_data_fim IS NULL OR p_data_inicio > p_data_fim THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Periodo invalido: data inicial deve ser menor ou igual a final';
    END IF;

    SELECT l.titulo,
           e.data_saida,
           e.data_devolucao_prevista AS prevista,
           e.data_devolucao_real     AS devolvido_em,
           CASE
               WHEN e.status = 'devolvido' AND e.data_devolucao_real > e.data_devolucao_prevista
                   THEN 'Devolvido com atraso'
               WHEN e.status = 'devolvido'                      THEN 'Devolvido no prazo'
               WHEN e.data_devolucao_prevista < CURDATE()       THEN 'Em atraso'
               ELSE 'No prazo'
           END AS situacao,
           LEAST(GREATEST(DATEDIFF(IFNULL(e.data_devolucao_real, CURDATE()),
                                   e.data_devolucao_prevista), 0), 30) * 1.50 AS multa
    FROM emprestimos e
    JOIN livros l ON l.id_livro = e.id_livro
    WHERE e.id_usuario = v_id_usuario
      AND e.data_saida BETWEEN p_data_inicio AND p_data_fim
    ORDER BY e.data_saida;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_resumo_usuario | Responsavel: Gustavo Vianna
-- Tipo: retorno por parametros OUT (obrigatorio "c")
-- Objetivo: devolver, em variaveis, a situacao de um usuario para o
-- balcao de atendimento decidir se ele pode pegar livro.
-- Regras: classificacao por CASE -- BLOQUEADO (tem atraso),
-- LIMITE ATINGIDO (3 ativos), LIBERADO (demais).
-- Parametros: IN p_email, OUT p_qtd_ativos, OUT p_qtd_atrasados,
--             OUT p_situacao
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_resumo_usuario(
    IN  p_email         VARCHAR(100),
    OUT p_qtd_ativos    INT,
    OUT p_qtd_atrasados INT,
    OUT p_situacao      VARCHAR(20)
)
BEGIN
    DECLARE v_id_usuario CHAR(36);

    SELECT id_usuario INTO v_id_usuario
    FROM usuarios
    WHERE email = p_email;

    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario nao encontrado';
    END IF;

    SELECT COUNT(*),
           COALESCE(SUM(status = 'atrasado'
                        OR data_devolucao_prevista < CURDATE()), 0)
      INTO p_qtd_ativos, p_qtd_atrasados
    FROM emprestimos
    WHERE id_usuario = v_id_usuario
      AND status <> 'devolvido';

    SET p_situacao = CASE
                         WHEN p_qtd_atrasados > 0 THEN 'BLOQUEADO'
                         WHEN p_qtd_ativos >= 3   THEN 'LIMITE ATINGIDO'
                         ELSE 'LIBERADO'
                     END;
END$$

-- ----------------------------------------------------------------
-- Procedure: sp_renovar_emprestimo | Responsavel: Gabriel Cardoso
-- Tipo: alteracao com parametro INOUT
-- Objetivo: prorrogar a data de devolucao de um emprestimo.
-- Regras: so renova emprestimo pendente e ainda dentro do prazo;
-- a renovacao e de no maximo 14 dias. O INOUT entra com os dias
-- pedidos e sai com os dias realmente concedidos.
-- Parametros: IN p_id_emprestimo, INOUT p_dias
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_renovar_emprestimo(
    IN    p_id_emprestimo CHAR(36),
    INOUT p_dias          INT
)
BEGIN
    DECLARE v_status   VARCHAR(10);
    DECLARE v_prevista DATE;
    DECLARE c_max_dias INT DEFAULT 14;

    SELECT status, data_devolucao_prevista
      INTO v_status, v_prevista
    FROM emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emprestimo nao encontrado';
    ELSEIF v_status <> 'pendente' OR v_prevista < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Renovacao negada: emprestimo devolvido ou em atraso';
    ELSEIF p_dias IS NULL OR p_dias <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Informe uma quantidade de dias positiva';
    ELSEIF p_dias > c_max_dias THEN
        SET p_dias = c_max_dias;
    END IF;

    UPDATE emprestimos
    SET data_devolucao_prevista = DATE_ADD(v_prevista, INTERVAL p_dias DAY)
    WHERE id_emprestimo = p_id_emprestimo;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'biblioteca';


-- ################################################################
-- 03_cursor.sql
-- ################################################################

-- ================================================================
-- 03_cursor.sql -- Procedure com CURSOR (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================

USE biblioteca;

DROP PROCEDURE IF EXISTS sp_atualizar_atrasos;

DELIMITER $$

-- ----------------------------------------------------------------
-- Procedure: sp_atualizar_atrasos (cursor) | Responsavel: Rafael de Almeida
-- Objetivo: rotina diaria da biblioteca. Percorre, um a um, os
-- emprestimos 'pendente' cujo prazo ja venceu, marca cada um como
-- 'atrasado', calcula a multa acumulada ate a data de referencia e
-- monta um relatorio do que foi processado.
-- Por que cursor: cada linha recebe um tratamento individual
-- (UPDATE proprio -> dispara a trigger de auditoria por registro,
-- calculo da multa e linha no relatorio).
-- Parametros: IN p_data_referencia (NULL = hoje),
--             OUT p_qtd_atualizados, OUT p_multa_total
-- ----------------------------------------------------------------
CREATE PROCEDURE sp_atualizar_atrasos(
    IN  p_data_referencia DATE,
    OUT p_qtd_atualizados INT,
    OUT p_multa_total     DECIMAL(10, 2)
)
BEGIN
    DECLARE v_fim         BOOLEAN DEFAULT FALSE;
    DECLARE v_id          CHAR(36);
    DECLARE v_prevista    DATE;
    DECLARE v_titulo      VARCHAR(255);
    DECLARE v_usuario     VARCHAR(100);
    DECLARE v_dias        INT;
    DECLARE v_multa       DECIMAL(8, 2);
    DECLARE v_data_ref    DATE;

    -- 1) Declaracao do cursor: o conjunto de linhas a percorrer
    DECLARE cur_vencidos CURSOR FOR
        SELECT e.id_emprestimo, e.data_devolucao_prevista, l.titulo, u.nome
        FROM emprestimos e
        JOIN livros   l ON l.id_livro   = e.id_livro
        JOIN usuarios u ON u.id_usuario = e.id_usuario
        WHERE e.status = 'pendente'
          AND e.data_devolucao_prevista < v_data_ref
        ORDER BY e.data_devolucao_prevista;

    -- 2) Handler: quando o FETCH nao encontrar mais linhas, liga v_fim
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fim = TRUE;

    SET v_data_ref = IFNULL(p_data_referencia, CURDATE());

    IF v_data_ref > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de referencia nao pode estar no futuro';
    END IF;

    SET p_qtd_atualizados = 0;
    SET p_multa_total     = 0;

    DROP TEMPORARY TABLE IF EXISTS tmp_atrasos_processados;
    CREATE TEMPORARY TABLE tmp_atrasos_processados (
        usuario      VARCHAR(100),
        livro        VARCHAR(255),
        prevista     DATE,
        dias_atraso  INT,
        multa        DECIMAL(8, 2)
    );

    -- 3) Abertura: executa o SELECT do cursor
    OPEN cur_vencidos;

    leitura: LOOP
        -- 4) Leitura de uma linha por vez
        FETCH cur_vencidos INTO v_id, v_prevista, v_titulo, v_usuario;

        -- 5) Saida do laco quando acabaram as linhas
        IF v_fim THEN
            LEAVE leitura;
        END IF;

        SET v_dias  = DATEDIFF(v_data_ref, v_prevista);
        SET v_multa = LEAST(v_dias, 30) * 1.50;

        UPDATE emprestimos
        SET status = 'atrasado'
        WHERE id_emprestimo = v_id;

        INSERT INTO tmp_atrasos_processados
        VALUES (v_usuario, v_titulo, v_prevista, v_dias, v_multa);

        SET p_qtd_atualizados = p_qtd_atualizados + 1;
        SET p_multa_total     = p_multa_total + v_multa;
    END LOOP leitura;

    -- 6) Fechamento: libera o cursor
    CLOSE cur_vencidos;

    SELECT * FROM tmp_atrasos_processados;
END$$

DELIMITER ;


-- ################################################################
-- 04_triggers.sql
-- ################################################################

-- ================================================================
-- 04_triggers.sql -- Triggers (4 bim)
-- Projeto: Biblioteca Digital
-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida
-- ================================================================
-- Organizacao:
--   BEFORE (validacao)   -> trg_emprestimos_before_insert
--                           trg_emprestimos_before_update
--                           trg_emprestimos_before_delete
--                           trg_livros_before_update
--   AFTER  (atualizacao) -> trg_emprestimos_after_insert
--                           trg_emprestimos_after_update
--   AFTER  (auditoria)   -> trg_auditoria_emprestimos_insert
--                           trg_auditoria_emprestimos_update
--                           trg_auditoria_emprestimos_delete
--                           trg_auditoria_livros_update
-- ================================================================

USE biblioteca;

DROP TRIGGER IF EXISTS trg_emprestimos_before_insert;
DROP TRIGGER IF EXISTS trg_emprestimos_before_update;
DROP TRIGGER IF EXISTS trg_emprestimos_before_delete;
DROP TRIGGER IF EXISTS trg_livros_before_update;
DROP TRIGGER IF EXISTS trg_emprestimos_after_insert;
DROP TRIGGER IF EXISTS trg_emprestimos_after_update;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_insert;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_update;
DROP TRIGGER IF EXISTS trg_auditoria_emprestimos_delete;
DROP TRIGGER IF EXISTS trg_auditoria_livros_update;

DELIMITER $$

-- ================================================================
-- BEFORE -- validacao (obrigatorio "a")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: BEFORE
-- Objetivo: barrar emprestimos invalidos antes de serem gravados,
-- venham eles da procedure ou de um INSERT direto.
-- Regras: prazo entre 1 e 30 dias; precisa haver exemplar disponivel.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_insert
BEFORE INSERT ON emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_disponivel INT;
    DECLARE v_titulo     VARCHAR(255);
    DECLARE v_msg        VARCHAR(255);

    SELECT qtd_disponivel, titulo
      INTO v_disponivel, v_titulo
    FROM livros
    WHERE id_livro = NEW.id_livro;

    IF NEW.data_devolucao_prevista <= NEW.data_saida THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A devolucao prevista deve ser posterior a data de saida';
    ELSEIF DATEDIFF(NEW.data_devolucao_prevista, NEW.data_saida) > 30 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Prazo maximo de emprestimo e de 30 dias';
    ELSEIF NEW.status <> 'devolvido' AND v_disponivel <= 0 THEN
        SET v_msg = CONCAT('Nao ha exemplares disponiveis de "', v_titulo, '"');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: BEFORE
-- Objetivo: impedir que um emprestimo devolvido seja reaberto e
-- preencher automaticamente a data de devolucao (altera o NEW).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_update
BEFORE UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status = 'devolvido' AND NEW.status <> 'devolvido' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Emprestimo ja devolvido nao pode ser reaberto';
    END IF;

    IF NEW.status = 'devolvido' AND NEW.data_devolucao_real IS NULL THEN
        SET NEW.data_devolucao_real = CURDATE();
    END IF;

    IF NEW.data_devolucao_real < NEW.data_saida THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de devolucao anterior a data de saida';
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_before_delete | Responsavel: Rafael de Almeida
-- Tabela: emprestimos | Evento: DELETE | Momento: BEFORE
-- Objetivo: so permite excluir emprestimos ja devolvidos; apagar um
-- emprestimo em aberto faria o livro "sumir" do controle.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_before_delete
BEFORE DELETE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status <> 'devolvido' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nao e permitido excluir emprestimo em aberto';
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_livros_before_update | Responsavel: Rafael de Almeida
-- Tabela: livros | Evento: UPDATE | Momento: BEFORE
-- Objetivo: impedir preco negativo e estoque fora do intervalo
-- 0..qtd_exemplares (protege tambem contra erro nas outras triggers).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_livros_before_update
BEFORE UPDATE ON livros
FOR EACH ROW
BEGIN
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O preco nao pode ser negativo';
    ELSEIF NEW.qtd_disponivel < 0 OR NEW.qtd_disponivel > NEW.qtd_exemplares THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantidade disponivel deve ficar entre 0 e o total de exemplares';
    END IF;
END$$

-- ================================================================
-- AFTER -- atualizacao automatica de outra tabela (obrigatorio "b")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_after_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: AFTER
-- Objetivo: dar baixa de 1 exemplar em livros.qtd_disponivel quando
-- um emprestimo e registrado.
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_after_insert
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    IF NEW.status <> 'devolvido' THEN
        UPDATE livros
        SET qtd_disponivel = qtd_disponivel - 1
        WHERE id_livro = NEW.id_livro;
    END IF;
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_emprestimos_after_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: AFTER
-- Objetivo: devolver 1 exemplar ao estoque quando o emprestimo passa
-- para 'devolvido' (compara OLD x NEW para agir so na transicao).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_emprestimos_after_update
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    IF OLD.status <> 'devolvido' AND NEW.status = 'devolvido' THEN
        UPDATE livros
        SET qtd_disponivel = qtd_disponivel + 1
        WHERE id_livro = NEW.id_livro;
    END IF;
END$$

-- ================================================================
-- AFTER -- auditoria em log_auditoria (obrigatorio "c")
-- ================================================================

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_insert | Responsavel: Gustavo Vianna
-- Tabela: emprestimos | Evento: INSERT | Momento: AFTER
-- Objetivo: registrar no log todo emprestimo criado (valor novo).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_insert
AFTER INSERT ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', NEW.id_emprestimo, 'INSERT', NULL,
            CONCAT('status=', NEW.status, '; prevista=', NEW.data_devolucao_prevista),
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_update | Responsavel: Gabriel Cardoso
-- Tabela: emprestimos | Evento: UPDATE | Momento: AFTER
-- Objetivo: registrar no log o antes (OLD) e o depois (NEW) de toda
-- alteracao de emprestimo (devolucao, renovacao, atraso).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_update
AFTER UPDATE ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', NEW.id_emprestimo, 'UPDATE',
            CONCAT('status=', OLD.status, '; prevista=', OLD.data_devolucao_prevista,
                   '; devolucao=', IFNULL(OLD.data_devolucao_real, '-')),
            CONCAT('status=', NEW.status, '; prevista=', NEW.data_devolucao_prevista,
                   '; devolucao=', IFNULL(NEW.data_devolucao_real, '-')),
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_emprestimos_delete | Responsavel: Rafael de Almeida
-- Tabela: emprestimos | Evento: DELETE | Momento: AFTER
-- Objetivo: registrar no log o registro excluido (valor antigo).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_emprestimos_delete
AFTER DELETE ON emprestimos
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
    VALUES ('emprestimos', OLD.id_emprestimo, 'DELETE',
            CONCAT('status=', OLD.status, '; saida=', OLD.data_saida,
                   '; devolucao=', IFNULL(OLD.data_devolucao_real, '-')),
            NULL,
            USER());
END$$

-- ----------------------------------------------------------------
-- Trigger: trg_auditoria_livros_update | Responsavel: Gabriel Cardoso
-- Tabela: livros | Evento: UPDATE | Momento: AFTER
-- Objetivo: historico de alteracao de preco. So grava quando o preco
-- realmente mudou (as baixas de estoque nao poluem o log).
-- ----------------------------------------------------------------
CREATE TRIGGER trg_auditoria_livros_update
AFTER UPDATE ON livros
FOR EACH ROW
BEGIN
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO log_auditoria (tabela, id_registro, operacao, valor_antigo, valor_novo, usuario_bd)
        VALUES ('livros', NEW.id_livro, 'UPDATE',
                CONCAT('preco=', OLD.preco),
                CONCAT('preco=', NEW.preco),
                USER());
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM biblioteca;
