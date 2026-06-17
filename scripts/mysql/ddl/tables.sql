-- MySQL 8.0: UUID nao e um tipo nativo -- usa-se CHAR(36).
-- DEFAULT (UUID()) requer MySQL 8.0.13+ (expressoes em DEFAULT).
USE biblioteca;

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
