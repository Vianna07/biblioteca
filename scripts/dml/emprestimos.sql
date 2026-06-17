USE biblioteca;

-- 1-5: Emprestimos devolvidos no prazo
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),                    (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),       '2026-01-10', '2026-01-24', '2026-01-20', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertão: Veredas'),          (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'),  '2026-01-15', '2026-01-29', '2026-01-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias Póstumas de Brás Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),    '2026-02-01', '2026-02-15', '2026-02-10', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitães da Areia'),               (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'),  '2026-02-05', '2026-02-19', '2026-02-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),                     (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),   '2026-02-10', '2026-02-24', '2026-02-22', 'devolvido');

-- 6-10: Emprestimos devolvidos com atraso
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'),    (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),  '2026-01-05', '2026-01-19', '2026-02-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Alienista'),          (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),   '2026-01-20', '2026-02-03', '2026-02-15', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'),              (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  '2026-02-01', '2026-02-15', '2026-03-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Macunaíma'),            (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   '2026-02-10', '2026-02-24', '2026-03-05', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Tempo e o Vento'),    (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),       '2026-02-15', '2026-03-01', '2026-03-10', 'devolvido');

-- 11-20: Emprestimos pendentes dentro do prazo (datas futuras a partir de 2026-06-17)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Quincas Borba'),                   (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'),  '2026-06-01', '2026-06-22', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Menino de Engenho'),               (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),    '2026-06-03', '2026-06-24', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Gabriela, Cravo e Canela'),        (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),    '2026-06-04', '2026-06-25', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'São Bernardo'),                    (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'),  '2026-06-05', '2026-06-26', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Moreninha'),                     (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),   '2026-06-06', '2026-06-27', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'O Guarani'),                       (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),   '2026-06-07', '2026-06-28', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Clara dos Anjos'),                 (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),    '2026-06-08', '2026-06-29', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Triste Fim de Policarpo Quaresma'),(SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),   '2026-06-09', '2026-06-30', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Paixão Segundo G.H.'),           (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),    '2026-06-10', '2026-07-01', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Lavoura Arcaica'),                 (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),       '2026-06-12', '2026-07-03', NULL, 'pendente');

-- 21-30: Emprestimos atrasados (prazo vencido, sem devolucao)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Angústia'),                        (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'),  '2026-04-15', '2026-04-29', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias de um Sargento de Milícias'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'), '2026-04-18', '2026-05-02', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Quinze'),                        (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),    '2026-04-20', '2026-05-04', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'),                        (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'),  '2026-04-22', '2026-05-06', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'),                      (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),   '2026-04-24', '2026-05-08', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'),   (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),   '2026-04-28', '2026-05-12', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lírios do Campo'),        (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),    '2026-05-01', '2026-05-15', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'),                (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),   '2026-05-05', '2026-05-19', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dois Irmãos'),                     (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),    '2026-05-08', '2026-05-22', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Cortiço'),                       (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),       '2026-05-12', '2026-05-26', NULL, 'atrasado');

-- 31-35: Emprestimos prestes a vencer (devolucao nos proximos 2 dias)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'),                    (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'),    '2026-06-03', '2026-06-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertão: Veredas'),          (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'),  '2026-06-04', '2026-06-18', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias Póstumas de Brás Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'),   '2026-06-04', '2026-06-18', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitães da Areia'),               (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'),   '2026-06-03', '2026-06-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'),                     (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'),    '2026-06-05', '2026-06-19', NULL, 'pendente');

-- 36-40: Historico de devolucoes (dezembro 2025)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'),                   (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'),  '2025-12-01', '2025-12-15', '2025-12-14', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'),                 (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'),   '2025-12-05', '2025-12-19', '2025-12-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'),   '2025-12-10', '2025-12-24', '2025-12-23', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lírios do Campo'),   (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2025-12-15', '2025-12-29', '2025-12-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'),           (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'),   '2025-12-20', '2026-01-03', '2026-01-02', 'devolvido');
