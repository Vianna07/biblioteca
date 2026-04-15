CREATE TABLE livros (
    id_livro UUID PRIMARY KEY DEFAULT UUID(),
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    editora VARCHAR(100),
    ano_lancamento INT,
    isbn VARCHAR(20) UNIQUE
);

CREATE TABLE usuarios (
    id_usuario UUID PRIMARY KEY DEFAULT UUID(),
    nome VARCHAR(100) NOT NULL,
    login VARCHAR(50) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE emprestimos (
    id_emprestimo UUID PRIMARY KEY DEFAULT UUID(),
    id_livro UUID NOT NULL,
    id_usuario UUID NOT NULL,
    data_saida DATE NOT NULL,
    data_devolucao_prevista DATE NOT NULL,
    data_devolucao_real DATE,
    status VARCHAR(20) DEFAULT 'pendente'
);
