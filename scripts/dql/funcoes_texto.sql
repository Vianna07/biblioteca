USE biblioteca;

-- ============================================================
-- Funções de Texto
-- ============================================================

-- UPPER: títulos em maiúsculas
SELECT UPPER(titulo) AS titulo_maiusculo
FROM livros
ORDER BY titulo
LIMIT 5;

-- LOWER: normalizar e-mails antes de comparar
SELECT LOWER(email) AS email_normalizado
FROM usuarios
ORDER BY email;

-- CONCAT: formatar linha de contato (nome + e-mail)
SELECT CONCAT(nome, ' <', email, '>') AS contato
FROM usuarios
ORDER BY nome;

-- LENGTH: comprimento do título (útil p/ validar campos)
SELECT titulo, LENGTH(titulo) AS caracteres
FROM livros
ORDER BY caracteres DESC
LIMIT 5;

-- REPLACE: abreviar editoras na exibição
SELECT titulo,
       REPLACE(editora, 'José Olympio', 'J. Olympio') AS editora_abrev
FROM livros
WHERE editora = 'José Olympio';

-- SUBSTR: exibir apenas os 30 primeiros caracteres do título
SELECT SUBSTR(titulo, 1, 30) AS titulo_resumido,
       autor
FROM livros
ORDER BY titulo;
