USE biblioteca;

-- Integridade referencial: emprestimos depende de livros e usuarios
-- ON DELETE RESTRICT impede exclusão de livro/usuário com empréstimos vinculados
ALTER TABLE emprestimos
    ADD CONSTRAINT fk_emprestimo_livro
        FOREIGN KEY (id_livro)   REFERENCES livros(id_livro)   ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE emprestimos
    ADD CONSTRAINT fk_emprestimo_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE;
