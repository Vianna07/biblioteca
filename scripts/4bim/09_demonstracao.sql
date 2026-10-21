-- ================================================================
-- 09_demonstracao.sql -- Objetos criados no banco (4 bim)
-- Projeto: Biblioteca Digital
-- ================================================================

USE biblioteca;

-- >> S1 | Procedures criadas
SHOW PROCEDURE STATUS WHERE Db = 'biblioteca';

-- >> S2 | Triggers criadas
SHOW TRIGGERS FROM biblioteca;

-- >> S3 | Estrutura da tabela de log
DESCRIBE log_auditoria;
