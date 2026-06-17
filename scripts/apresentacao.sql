-- ================================================================
-- APRESENTACAO -- Banco de Dados 2 Bimestre
-- Sistema: Biblioteca Digital
-- ================================================================
-- Estrutura:
--   Setup    -- DDL, Procedure, Constraints, DCL
--   Insercao -- DML com 3 niveis de hash demonstrados
--   Secao 2  -- Modelagem do Banco de Dados
--   Secao 3  -- Seguranca dos Dados (Hash / KDF)
--   Secao 4  -- Funcoes SQL (Texto, Numericas, Data)
--   Secao 5  -- Relacionamento entre Tabelas
--   Secao 6  -- Consultas com JOIN
--   Secao 7  -- Relatorios e Indicadores
--   Secao 9  -- Conclusao (dificuldades, aprendizados, melhorias)
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
-- Tabelas
-- ----------------------------------------------------------------

CREATE TABLE livros (
    id_livro       UUID          PRIMARY KEY DEFAULT UUID(),
    titulo         VARCHAR(255)  NOT NULL,
    autor          VARCHAR(100)  NOT NULL,
    editora        VARCHAR(100),
    ano_lancamento INT,
    preco          DECIMAL(8, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE usuarios (
    id_usuario UUID         PRIMARY KEY DEFAULT UUID(),
    nome       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    senha      VARCHAR(64)  NOT NULL,
    salt       VARCHAR(64)  NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE emprestimos (
    id_emprestimo           UUID                                      PRIMARY KEY DEFAULT UUID(),
    id_livro                UUID                                      NOT NULL,
    id_usuario              UUID                                      NOT NULL,
    data_saida              DATE                                      NOT NULL,
    data_devolucao_prevista DATE                                      NOT NULL,
    data_devolucao_real     DATE,
    status                  ENUM('pendente', 'atrasado', 'devolvido') NOT NULL DEFAULT 'pendente'
);

-- ----------------------------------------------------------------
-- Procedure de cadastro com hash em 3 camadas
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

    -- Nivel 1: salt = SHA2(id_usuario || created_at, 256)
    SET v_salt = SHA2(CONCAT(v_id, v_now), 256);

    -- Nivel 2 + 3: 3 rodadas de SHA2-256 com salt embutido
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
-- DCL -- Usuarios do banco e permissoes
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
-- Usuarios -- demonstracao dos 3 niveis de hash
-- ----------------------------------------------------------------

-- [NIVEL 1 -- LEGADO]
-- Forma antiga: SHA2 simples direto no INSERT, sem salt, sem iteracoes.
-- Vulneravel a rainbow table: dois usuarios com a mesma senha
-- geram exatamente o mesmo hash -- veja o resultado abaixo.
INSERT INTO usuarios (id_usuario, nome, email, senha, salt, created_at) VALUES
    (UUID(), 'Rafael Nascimento', 'rafael.nascimento@email.com', SHA2('senha123', 256), '', NOW()),
    (UUID(), 'Sofia Cardoso',     'sofia.cardoso@email.com',     SHA2('senha123', 256), '', NOW());

-- [NIVEL 3 -- ATUAL] Usuarios via procedure (salt unico + 3 iteracoes SHA2-256)
-- Cada CALL gera um UUID e timestamp unicos => salt diferente => hash diferente,
-- mesmo que a senha de entrada seja identica.
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
-- Emprestimos
-- ----------------------------------------------------------------

-- Devolvidos no prazo
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),               (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      '2026-01-10', '2026-01-24', '2026-01-20', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'),     (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-01-15', '2026-01-29', '2026-01-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias Postumas de Bras Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   '2026-02-01', '2026-02-15', '2026-02-10', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitaes da Areia'),          (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-02-05', '2026-02-19', '2026-02-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),                (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  '2026-02-10', '2026-02-24', '2026-02-22', 'devolvido');

-- Devolvidos com atraso
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), '2026-01-05', '2026-01-19', '2026-02-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Alienista'),       (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),  '2026-01-20', '2026-02-03', '2026-02-15', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'),           (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'), '2026-02-01', '2026-02-15', '2026-03-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Macunaima'),         (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),  '2026-02-10', '2026-02-24', '2026-03-05', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Tempo e o Vento'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),     '2026-02-15', '2026-03-01', '2026-03-10', 'devolvido');

-- Pendentes dentro do prazo
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Quincas Borba'),                   (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-06-01', '2026-06-22', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Menino de Engenho'),               (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   '2026-06-03', '2026-06-24', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Gabriela, Cravo e Canela'),        (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   '2026-06-04', '2026-06-25', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Sao Bernardo'),                    (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-06-05', '2026-06-26', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Moreninha'),                     (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  '2026-06-06', '2026-06-27', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'O Guarani'),                       (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  '2026-06-07', '2026-06-28', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Clara dos Anjos'),                 (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   '2026-06-08', '2026-06-29', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Triste Fim de Policarpo Quaresma'),(SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  '2026-06-09', '2026-06-30', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Paixao Segundo G.H.'),           (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   '2026-06-10', '2026-07-01', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Lavoura Arcaica'),                 (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      '2026-06-12', '2026-07-03', NULL, 'pendente');

-- Atrasados (prazo vencido, sem devolucao)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Angustia'),                        (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-04-15', '2026-04-29', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias de um Sargento de Milicias'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),  '2026-04-18', '2026-05-02', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Quinze'),                        (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   '2026-04-20', '2026-05-04', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'),                        (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-04-22', '2026-05-06', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'),                      (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  '2026-04-24', '2026-05-08', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'),   (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  '2026-04-28', '2026-05-12', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lirios do Campo'),        (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   '2026-05-01', '2026-05-15', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'),                (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  '2026-05-05', '2026-05-19', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dois Irmaos'),                     (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   '2026-05-08', '2026-05-22', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Cortico'),                       (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),      '2026-05-12', '2026-05-26', NULL, 'atrasado');

-- Prestes a vencer (devolucao nos proximos 2 dias)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),               (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),   '2026-06-03', '2026-06-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertao: Veredas'),     (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-06-04', '2026-06-18', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Memorias Postumas de Bras Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),  '2026-06-04', '2026-06-18', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitaes da Areia'),          (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  '2026-06-03', '2026-06-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),                (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   '2026-06-05', '2026-06-19', NULL, 'pendente');

-- Historico adicional (dezembro 2025)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'),                  (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  '2025-12-01', '2025-12-15', '2025-12-14', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'),                (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   '2025-12-05', '2025-12-19', '2025-12-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2025-12-10', '2025-12-24', '2025-12-23', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lirios do Campo'),  (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2025-12-15', '2025-12-29', '2025-12-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'),          (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   '2025-12-20', '2026-01-03', '2026-01-02', 'devolvido');


-- ================================================================
-- SECAO 3 -- SEGURANCA DOS DADOS (HASH DE SENHAS / KDF)
-- ================================================================
-- KDF (Key Derivation Function) e a abordagem correta para senhas.
-- Exemplos de KDF em producao:
--   PBKDF2  -- Python: hashlib.pbkdf2_hmac('sha256', b'senha', b'salt', 100000)
--   bcrypt  -- PHP:    password_hash('senha', PASSWORD_BCRYPT)
--   Argon2  -- vencedor do Password Hashing Competition (2015)
--
-- MariaDB/MySQL nao expoe KDF como funcao SQL nativa.
-- Em producao, o hash e feito na aplicacao; o banco so armazena o resultado.
-- Abaixo demonstramos o conceito equivalente com SHA2 puro em 3 niveis.
-- ================================================================

-- ----------------------------------------------------------------
-- NIVEL 1 -- SHA2-256 simples (sem protecao extra)
-- ----------------------------------------------------------------
-- Problema: qualquer usuario com a mesma senha produz o MESMO hash.
-- Um atacante com rainbow table quebra todas as contas de uma vez.
SELECT
    'senha123'            AS senha_original,
    SHA2('senha123', 256) AS hash_nivel1_sem_salt;

-- Prova no banco: Rafael e Sofia tem a mesma senha => hash identico (perigoso)
SELECT nome, senha AS hash_identico
FROM usuarios
WHERE salt = ''
ORDER BY nome;

-- ----------------------------------------------------------------
-- NIVEL 2 -- SHA2-256 com salt (salt = SHA2 do id + created_at)
-- ----------------------------------------------------------------
-- Salt unico por usuario: mesmo que a senha seja igual, o hash muda.
-- Cada usuario tem um salt diferente, eliminando rainbow tables.
SELECT
    'senha123'                                                    AS senha_original,
    SHA2('uuid-abc-20260617-100000', 256)                         AS salt_gerado,
    SHA2(CONCAT('senha123', SHA2('uuid-abc-20260617-100000', 256)), 256)
                                                                  AS hash_nivel2_com_salt;

-- ----------------------------------------------------------------
-- NIVEL 3 -- SHA2-256 com salt + 3 iteracoes (key stretching)
-- ----------------------------------------------------------------
-- Cada iteracao extra multiplica o custo de um ataque de forca bruta.
-- Conceito identico ao PBKDF2, que usa 100.000+ iteracoes.
SELECT
    'senha123'                                                    AS senha_original,
    SHA2(
        SHA2(
            SHA2(CONCAT('senha123', SHA2('uuid-abc-20260617-100000', 256)), 256),
        256),
    256)                                                          AS hash_nivel3_salt_3_iteracoes;

-- Comparacao dos tres niveis lado a lado
SELECT
    SHA2('senha123', 256)                                                       AS nivel1_sem_salt,
    SHA2(CONCAT('senha123', SHA2('uuid-2026', 256)), 256)                       AS nivel2_com_salt,
    SHA2(SHA2(SHA2(CONCAT('senha123', SHA2('uuid-2026', 256)), 256), 256), 256) AS nivel3_salt_3x;

-- Ver no banco: legados (nivel 1) vs seguros (nivel 3)
-- Rafael e Sofia: salt vazio, hash identico entre si
-- Demais usuarios: salt unico, hash unico mesmo com a mesma senha
SELECT nome,
       CASE WHEN salt = '' THEN 'LEGADO  -- apenas SHA2 simples'
            ELSE                 'SEGURO  -- salt unico + 3 iteracoes'
       END AS nivel_seguranca,
       LEFT(senha, 24) AS inicio_hash,
       LEFT(salt,  24) AS inicio_salt
FROM usuarios
ORDER BY nivel_seguranca DESC, nome;

-- Nota sobre migracao: usuarios legados teriam o hash atualizado
-- na proxima vez que fizessem login -- a aplicacao recalcula o hash
-- com a nova estrategia ao verificar a senha correta.


-- ================================================================
-- SECAO 2 -- MODELAGEM DO BANCO DE DADOS
-- ================================================================
-- Entidades: livros, usuarios, emprestimos
-- PK: id_livro (UUID), id_usuario (UUID), id_emprestimo (UUID)
-- FK: emprestimos.id_livro   -> livros.id_livro
--     emprestimos.id_usuario -> usuarios.id_usuario

-- Estrutura de cada tabela
DESCRIBE livros;
DESCRIBE usuarios;
DESCRIBE emprestimos;

-- FK ativas com tabelas pai e filho
SELECT
    TABLE_NAME           AS tabela_filha,
    COLUMN_NAME          AS coluna_fk,
    CONSTRAINT_NAME      AS nome_constraint,
    REFERENCED_TABLE_NAME  AS tabela_pai,
    REFERENCED_COLUMN_NAME AS coluna_pk
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'biblioteca'
  AND REFERENCED_TABLE_NAME IS NOT NULL;


-- ================================================================
-- SECAO 4 -- FUNCOES SQL
-- ================================================================

-- ==== Funcoes de Texto ====

-- UPPER: titulos em maiusculas
SELECT UPPER(titulo) AS titulo_maiusculo
FROM livros ORDER BY titulo LIMIT 5;

-- LOWER: normalizar e-mails
SELECT LOWER(email) AS email_normalizado
FROM usuarios ORDER BY email LIMIT 5;

-- CONCAT: formatar linha de contato
SELECT CONCAT(nome, ' <', email, '>') AS contato
FROM usuarios ORDER BY nome LIMIT 5;

-- LENGTH: titulos mais longos
SELECT titulo, LENGTH(titulo) AS caracteres
FROM livros ORDER BY caracteres DESC LIMIT 5;

-- REPLACE: abreviar editora na exibicao
SELECT titulo,
       REPLACE(editora, 'Jose Olympio', 'J. Olympio') AS editora_abrev
FROM livros WHERE editora = 'Jose Olympio' LIMIT 5;

-- SUBSTR: primeiros 25 caracteres do titulo
SELECT SUBSTR(titulo, 1, 25) AS titulo_curto, autor
FROM livros ORDER BY titulo LIMIT 5;

-- ==== Funcoes Numericas ====

-- COUNT: total de cada entidade
SELECT COUNT(*) AS total_livros      FROM livros;
SELECT COUNT(*) AS total_usuarios    FROM usuarios;
SELECT COUNT(*) AS total_emprestimos FROM emprestimos;

-- SUM: valor total do acervo
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- AVG: preco medio dos livros
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- MAX: maior preco do acervo
SELECT MAX(preco) AS maior_preco FROM livros;

-- MAX com linha completa
SELECT titulo, autor, preco AS maior_preco
FROM livros WHERE preco = (SELECT MAX(preco) FROM livros);

-- MIN: menor preco do acervo
SELECT MIN(preco) AS menor_preco FROM livros;

-- MIN com linha completa
SELECT titulo, autor, preco AS menor_preco
FROM livros WHERE preco = (SELECT MIN(preco) FROM livros);

-- ==== Funcoes de Data ====

-- NOW: data e hora atual do servidor
SELECT NOW() AS data_hora_atual;

-- CURDATE: data de hoje (sem hora)
SELECT CURDATE() AS data_hoje;

-- DATE_FORMAT: formato brasileiro dd/mm/aaaa
SELECT nome, DATE_FORMAT(created_at, '%d/%m/%Y %H:%i') AS cadastrado_em
FROM usuarios ORDER BY created_at LIMIT 5;

-- DATE_ADD: calcular devolucao prevista (saida + 14 dias)
SELECT l.titulo, e.data_saida,
       DATE_ADD(e.data_saida, INTERVAL 14 DAY) AS devolucao_calculada
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
LIMIT 5;

-- DATEDIFF: dias em aberto para emprestimos pendentes
SELECT l.titulo,
       DATEDIFF(CURDATE(), e.data_saida) AS dias_em_aberto
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status = 'pendente'
ORDER BY dias_em_aberto DESC LIMIT 5;


-- ================================================================
-- SECAO 5 -- RELACIONAMENTO ENTRE TABELAS
-- ================================================================
-- ON DELETE RESTRICT: impede excluir livro/usuario com emprestimos.
-- ON UPDATE CASCADE:  atualiza FK nos filhos se a PK pai mudar.

-- Listar FK com regras de exclusao
SELECT CONSTRAINT_NAME,
       TABLE_NAME           AS tabela_filha,
       COLUMN_NAME          AS coluna_fk,
       REFERENCED_TABLE_NAME  AS tabela_pai,
       REFERENCED_COLUMN_NAME AS coluna_pk
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'biblioteca'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Integridade referencial em acao (comentado para nao interromper):
-- DELETE FROM livros WHERE titulo = 'Dom Casmurro';
-- ERRO: Cannot delete a parent row: a foreign key constraint fails


-- ================================================================
-- SECAO 6 -- CONSULTAS COM JOIN
-- ================================================================

-- INNER JOIN: emprestimos com dados de usuario e livro
-- (exclui Rafael e Sofia que nao possuem emprestimos)
SELECT u.nome AS usuario, l.titulo AS livro,
       e.data_saida, e.data_devolucao_prevista, e.status
FROM emprestimos e
INNER JOIN usuarios u ON e.id_usuario = u.id_usuario
INNER JOIN livros   l ON e.id_livro   = l.id_livro
ORDER BY e.data_saida DESC LIMIT 10;

-- LEFT JOIN: todos os livros, inclusive nunca emprestados (NULL)
SELECT l.titulo, l.autor, e.data_saida, e.status
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
ORDER BY l.titulo LIMIT 10;

-- LEFT JOIN filtrado: so livros nunca emprestados
SELECT l.titulo, l.autor, l.preco
FROM livros l
LEFT JOIN emprestimos e ON l.id_livro = e.id_livro
WHERE e.id_emprestimo IS NULL
ORDER BY l.titulo;

-- RIGHT JOIN: todos os usuarios, inclusive sem emprestimo (NULL)
-- Rafael Nascimento e Sofia Cardoso aparecem com NULL
SELECT u.nome AS usuario, u.email, e.data_saida, e.status
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
ORDER BY u.nome;

-- RIGHT JOIN filtrado: so usuarios sem nenhum emprestimo
SELECT u.nome AS usuario, u.email,
       DATE_FORMAT(u.created_at, '%d/%m/%Y') AS cadastrado_em
FROM emprestimos e
RIGHT JOIN usuarios u ON e.id_usuario = u.id_usuario
WHERE e.id_emprestimo IS NULL
ORDER BY u.nome;


-- ================================================================
-- SECAO 7 -- RELATORIOS E INDICADORES
-- ================================================================

-- Totais gerais
SELECT COUNT(*) AS total_usuarios    FROM usuarios;
SELECT COUNT(*) AS total_livros      FROM livros;
SELECT COUNT(*) AS total_emprestimos FROM emprestimos;

-- Emprestimos por status (COUNT + GROUP BY)
SELECT status, COUNT(*) AS quantidade
FROM emprestimos GROUP BY status ORDER BY quantidade DESC;

-- Valor total do acervo (SUM)
SELECT SUM(preco) AS valor_total_acervo FROM livros;

-- Livro mais caro (MAX)
SELECT titulo, autor, preco AS maior_preco
FROM livros WHERE preco = (SELECT MAX(preco) FROM livros);

-- Livro mais barato (MIN)
SELECT titulo, autor, preco AS menor_preco
FROM livros WHERE preco = (SELECT MIN(preco) FROM livros);

-- Preco medio (AVG)
SELECT ROUND(AVG(preco), 2) AS preco_medio FROM livros;

-- Valor dos livros em circulacao (pendentes + atrasados)
SELECT ROUND(SUM(l.preco), 2) AS valor_em_circulacao
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
WHERE e.status IN ('pendente', 'atrasado');

-- Media de dias de atraso nas devolucoes tardias
SELECT ROUND(AVG(DATEDIFF(data_devolucao_real, data_devolucao_prevista)), 1) AS media_dias_atraso
FROM emprestimos
WHERE status = 'devolvido'
  AND data_devolucao_real > data_devolucao_prevista;

-- Usuarios com mais emprestimos
SELECT u.nome, COUNT(*) AS total_emprestimos
FROM emprestimos e
JOIN usuarios u ON e.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY total_emprestimos DESC LIMIT 5;

-- Livros mais emprestados
SELECT l.titulo, l.autor, COUNT(*) AS vezes_emprestado
FROM emprestimos e
JOIN livros l ON e.id_livro = l.id_livro
GROUP BY l.id_livro, l.titulo, l.autor
ORDER BY vezes_emprestado DESC LIMIT 5;


-- ================================================================
-- SECAO 9 -- CONCLUSAO
-- ================================================================

-- ----------------------------------------------------------------
-- Principais dificuldades encontradas
-- ----------------------------------------------------------------
-- 1. Hash de senhas em SQL puro
--    Queriamos usar um KDF real (como PBKDF2 ou bcrypt), mas
--    MariaDB/MySQL nao expoe essas funcoes via SQL. A solucao foi
--    simular o conceito com SHA2 + salt + iteracoes manuais dentro
--    de uma stored procedure.
--
-- 2. Diferenca entre MariaDB e MySQL
--    O tipo UUID e nativo no MariaDB mas nao existe no MySQL --
--    tivemos que usar CHAR(36). Alem disso, a sintaxe
--    DEFAULT UUID() precisa de parenteses no MySQL 8.0:
--    DEFAULT (UUID()). Descobrimos isso apenas ao testar.
--
-- 3. Datas dos emprestimos
--    Para que as queries de "atrasados" e "pendentes" retornassem
--    resultados reais durante a apresentacao, as datas precisaram
--    ser calculadas com base na data atual (2026-06-17).
--    Qualquer desvio deixaria os relatorios vazios.
--
-- 4. DCL e usuarios globais
--    CREATE USER falha se o usuario ja existir globalmente no banco
--    (os usuarios sobrevivem ao DROP DATABASE). Corrigimos com
--    IF NOT EXISTS e DROP USER IF EXISTS no inicio do script.

-- ----------------------------------------------------------------
-- Conhecimentos adquiridos
-- ----------------------------------------------------------------
-- - Como estruturar um banco relacional com FK e integridade
--   referencial (ON DELETE RESTRICT / ON UPDATE CASCADE).
--
-- - Hash de senhas em camadas: o que e salt, por que ele existe,
--   o que e key stretching e por que importa contra ataques de
--   forca bruta.
--
-- - Stored procedures com DELIMITER e variaveis locais (DECLARE).
--
-- - DCL na pratica: criar usuarios com privilegios diferentes
--   (admin, atendente, estagiario) e usar REVOKE para ajuste fino.
--
-- - Diferenca entre MariaDB e MySQL -- mesmo sendo compatíveis,
--   existem diferencas de tipos e sintaxe que exigem atencao.
--
-- - Funcoes de agregacao (COUNT, SUM, AVG, MAX, MIN) e como usar
--   subquery para buscar a linha completa do resultado de MAX/MIN.
--
-- - JOINs na pratica: INNER, LEFT e RIGHT com casos reais --
--   usuarios sem emprestimo, livros nunca emprestados.

-- ----------------------------------------------------------------
-- Melhorias futuras para o banco de dados do sistema
-- ----------------------------------------------------------------
-- 1. Hash real na aplicacao
--    Mover o hash de senhas para a camada de aplicacao usando
--    bcrypt ou Argon2. O banco so armazenaria o resultado final.
--
-- 2. Tabela de categorias
--    Criar uma tabela categorias e vincular aos livros (N:N),
--    permitindo filtrar o acervo por genero ou tema.
--
-- 3. Trigger de atualizacao de status
--    Um evento agendado (EVENT) ou trigger poderia mudar
--    automaticamente emprestimos de 'pendente' para 'atrasado'
--    quando a data_devolucao_prevista passar sem devolucao.
--
-- 4. Indice em colunas de busca frequente
--    Adicionar INDEX em livros.titulo, livros.autor e
--    emprestimos.status para acelerar as consultas de relatorio.
--
-- 5. Historico de alteracoes (audit log)
--    Uma tabela de log com trigger poderia registrar quem alterou
--    cada emprestimo e quando, facilitando auditoria.
