USE biblioteca;

INSERT INTO usuarios (nome, email, senha) VALUES
('Ana Clara Silva', 'ana.silva@email.com', SHA2('senha123', 256)),
('Bruno Oliveira', 'bruno.oliveira@email.com', SHA2('senha123', 256)),
('Carla Mendes', 'carla.mendes@email.com', SHA2('senha123', 256)),
('Daniel Souza', 'daniel.souza@email.com', SHA2('senha123', 256)),
('Elena Ferreira', 'elena.ferreira@email.com', SHA2('senha123', 256)),
('Felipe Santos', 'felipe.santos@email.com', SHA2('senha123', 256)),
('Gabriela Lima', 'gabriela.lima@email.com', SHA2('senha123', 256)),
('Hugo Pereira', 'hugo.pereira@email.com', SHA2('senha123', 256)),
('Isabela Costa', 'isabela.costa@email.com', SHA2('senha123', 256)),
('João Almeida', 'joao.almeida@email.com', SHA2('senha123', 256));
