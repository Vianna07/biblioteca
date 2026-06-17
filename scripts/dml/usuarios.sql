USE biblioteca;

-- Cadastro via procedure: gera salt (SHA2 de id+created_at) e aplica 3 iterações SHA2-256
CALL cadastrar_usuario('Ana Clara Silva',    'ana.silva@email.com',       'senha123');
CALL cadastrar_usuario('Bruno Oliveira',     'bruno.oliveira@email.com',  'senha123');
CALL cadastrar_usuario('Carla Mendes',       'carla.mendes@email.com',    'senha123');
CALL cadastrar_usuario('Daniel Souza',       'daniel.souza@email.com',    'senha123');
CALL cadastrar_usuario('Elena Ferreira',     'elena.ferreira@email.com',  'senha123');
CALL cadastrar_usuario('Felipe Santos',      'felipe.santos@email.com',   'senha123');
CALL cadastrar_usuario('Gabriela Lima',      'gabriela.lima@email.com',   'senha123');
CALL cadastrar_usuario('Hugo Pereira',       'hugo.pereira@email.com',    'senha123');
CALL cadastrar_usuario('Isabela Costa',      'isabela.costa@email.com',   'senha123');
CALL cadastrar_usuario('João Almeida',       'joao.almeida@email.com',    'senha123');

-- Usuários sem empréstimos (úteis para demonstrar LEFT/RIGHT JOIN)
CALL cadastrar_usuario('Rafael Nascimento',  'rafael.nascimento@email.com', 'senha123');
CALL cadastrar_usuario('Sofia Cardoso',      'sofia.cardoso@email.com',     'senha123');
