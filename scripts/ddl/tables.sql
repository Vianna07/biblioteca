USE biblioteca;

CREATE TABLE livros (
    id_livro       UUID           PRIMARY KEY DEFAULT UUID(),
    titulo         VARCHAR(255)   NOT NULL,
    autor          VARCHAR(100)   NOT NULL,
    editora        VARCHAR(100),
    ano_lancamento INT,
    preco          DECIMAL(8, 2)  NOT NULL DEFAULT 0.00
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
    id_emprestimo            UUID                                      PRIMARY KEY DEFAULT UUID(),
    id_livro                 UUID                                      NOT NULL,
    id_usuario               UUID                                      NOT NULL,
    data_saida               DATE                                      NOT NULL,
    data_devolucao_prevista  DATE                                      NOT NULL,
    data_devolucao_real      DATE,
    status                   ENUM('pendente', 'atrasado', 'devolvido') NOT NULL DEFAULT 'pendente'
);
