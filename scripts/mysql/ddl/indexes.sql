-- ================================================================
-- indexes.sql -- Indices do 3 bimestre (MySQL)
-- ================================================================
USE biblioteca;

-- emprestimos.status: usado em WHERE e GROUP BY em praticamente
-- todo relatorio de atraso/pendencia
CREATE INDEX idx_emprestimos_status ON emprestimos(status);

-- livros.autor: usado em GROUP BY (secao 3) e em buscas de catalogo
CREATE INDEX idx_livros_autor ON livros(autor);

-- Demonstracao
SHOW INDEX FROM emprestimos;
SHOW INDEX FROM livros;

-- usuarios.email ja possui indice automatico por causa do UNIQUE
SHOW INDEX FROM usuarios;
