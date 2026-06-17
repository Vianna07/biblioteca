USE biblioteca;

DELIMITER $$

-- Procedure para cadastrar usuário com senha segura em 3 camadas:
--   Nível 1 – gera salt dinâmico: SHA2(id || created_at, 256)
--   Nível 2 – hash com salt:      SHA2(senha || salt, 256)
--   Nível 3 – 2 iterações extras: SHA2(SHA2(..., 256), 256)
CREATE PROCEDURE cadastrar_usuario(
    IN p_nome  VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255)
)
BEGIN
    DECLARE v_id         CHAR(36);
    DECLARE v_now        TIMESTAMP;
    DECLARE v_salt       VARCHAR(64);
    DECLARE v_senha_hash VARCHAR(64);

    SET v_id  = UUID();
    SET v_now = NOW();

    -- Nível 1: salt = SHA2(id_usuario + created_at, 256)
    SET v_salt = SHA2(CONCAT(v_id, v_now), 256);

    -- Nível 2 + 3: 3 rodadas de SHA2-256 com o salt embutido
    SET v_senha_hash = SHA2(
                           SHA2(
                               SHA2(CONCAT(p_senha, v_salt), 256),
                           256),
                       256);

    INSERT INTO usuarios (id_usuario, nome, email, senha, salt, created_at)
    VALUES (v_id, p_nome, p_email, v_senha_hash, v_salt, v_now);
END$$

DELIMITER ;
