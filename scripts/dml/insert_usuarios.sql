USE biblioteca;

INSERT INTO usuarios (nome, login, senha) VALUES
('Ana Clara Silva', 'ana.silva', SHA2('senha123', 256)),
('Bruno Oliveira', 'bruno.oliveira', SHA2('senha123', 256)),
('Carla Mendes', 'carla.mendes', SHA2('senha123', 256)),
('Daniel Souza', 'daniel.souza', SHA2('senha123', 256)),
('Elena Ferreira', 'elena.ferreira', SHA2('senha123', 256)),
('Felipe Santos', 'felipe.santos', SHA2('senha123', 256)),
('Gabriela Lima', 'gabriela.lima', SHA2('senha123', 256)),
('Hugo Pereira', 'hugo.pereira', SHA2('senha123', 256)),
('Isabela Costa', 'isabela.costa', SHA2('senha123', 256)),
('João Almeida', 'joao.almeida', SHA2('senha123', 256));
