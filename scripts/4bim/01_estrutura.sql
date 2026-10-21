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
