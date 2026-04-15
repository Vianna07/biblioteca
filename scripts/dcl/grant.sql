USE biblioteca;

GRANT ALL PRIVILEGES ON biblioteca.* TO 'admin_biblioteca'@'localhost' WITH GRANT OPTION;

GRANT SELECT, INSERT, UPDATE ON biblioteca.livros TO 'atendente_biblioteca'@'localhost';
GRANT SELECT, INSERT, UPDATE ON biblioteca.emprestimos TO 'atendente_biblioteca'@'localhost';
GRANT SELECT ON biblioteca.usuarios TO 'atendente_biblioteca'@'localhost';

GRANT SELECT ON biblioteca.* TO 'estagiario_biblioteca'@'localhost';