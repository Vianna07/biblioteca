ALTER TABLE emprestimos ADD FOREIGN KEY (id_livro) REFERENCES livros(id_livro);
ALTER TABLE emprestimos ADD FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario);
