USE biblioteca;

-- 1-5: Empréstimos já devolvidos (no prazo)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2026-01-10', '2026-01-24', '2026-01-20', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertão: Veredas'), (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-01-15', '2026-01-29', '2026-01-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias Póstumas de Brás Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'), '2026-02-01', '2026-02-15', '2026-02-10', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitães da Areia'), (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-02-05', '2026-02-19', '2026-02-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'), '2026-02-10', '2026-02-24', '2026-02-22', 'devolvido');

-- 6-10: Empréstimos devolvidos com atraso
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'A Hora da Estrela'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), '2026-01-05', '2026-01-19', '2026-02-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Alienista'), (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'), '2026-01-20', '2026-02-03', '2026-02-15', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Iracema'), (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'), '2026-02-01', '2026-02-15', '2026-03-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Macunaíma'), (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'), '2026-02-10', '2026-02-24', '2026-03-05', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'O Tempo e o Vento'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2026-02-15', '2026-03-01', '2026-03-10', 'devolvido');

-- 11-20: Empréstimos pendentes (ainda dentro do prazo - data_devolucao_prevista > hoje)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Quincas Borba'), (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-04-10', '2026-04-24', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Menino de Engenho'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'), '2026-04-08', '2026-04-22', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Gabriela, Cravo e Canela'), (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'), '2026-04-05', '2026-04-19', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'São Bernardo'), (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-04-12', '2026-04-26', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Moreninha'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'), '2026-04-11', '2026-04-25', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'O Guarani'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), '2026-04-09', '2026-04-23', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Clara dos Anjos'), (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'), '2026-04-13', '2026-04-27', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Triste Fim de Policarpo Quaresma'), (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'), '2026-04-07', '2026-04-21', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'A Paixão Segundo G.H.'), (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'), '2026-04-14', '2026-04-28', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Lavoura Arcaica'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2026-04-06', '2026-04-20', NULL, 'pendente');

-- 21-30: Empréstimos atrasados (data_devolucao_prevista < hoje, sem devolução)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Angústia'), (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2026-03-01', '2026-03-15', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias de um Sargento de Milícias'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'), '2026-03-05', '2026-03-19', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Quinze'), (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'), '2026-03-10', '2026-03-24', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'), (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-03-02', '2026-03-16', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'), '2026-03-08', '2026-03-22', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), '2026-03-12', '2026-03-26', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lírios do Campo'), (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'), '2026-03-03', '2026-03-17', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'), (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'), '2026-03-07', '2026-03-21', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'Dois Irmãos'), (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'), '2026-03-15', '2026-03-29', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE titulo = 'O Cortiço'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2026-03-20', '2026-04-03', NULL, 'atrasado');

-- 31-35: Empréstimos pendentes com prazo muito próximo de vencer
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Dom Casmurro'), (SELECT id_usuario FROM usuarios WHERE email = 'daniel.souza@email.com'), '2026-04-01', '2026-04-16', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Grande Sertão: Veredas'), (SELECT id_usuario FROM usuarios WHERE email = 'elena.ferreira@email.com'), '2026-04-02', '2026-04-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Memórias Póstumas de Brás Cubas'), (SELECT id_usuario FROM usuarios WHERE email = 'felipe.santos@email.com'), '2026-04-03', '2026-04-16', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Capitães da Areia'), (SELECT id_usuario FROM usuarios WHERE email = 'gabriela.lima@email.com'), '2026-04-01', '2026-04-15', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE titulo = 'Vidas Secas'), (SELECT id_usuario FROM usuarios WHERE email = 'hugo.pereira@email.com'), '2026-04-02', '2026-04-18', NULL, 'pendente');

-- 36-40: Mais empréstimos devolvidos para histórico
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE titulo = 'Sagarana'), (SELECT id_usuario FROM usuarios WHERE email = 'isabela.costa@email.com'), '2025-12-01', '2025-12-15', '2025-12-14', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Fogo Morto'), (SELECT id_usuario FROM usuarios WHERE email = 'joao.almeida@email.com'), '2025-12-05', '2025-12-19', '2025-12-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Dona Flor e Seus Dois Maridos'), (SELECT id_usuario FROM usuarios WHERE email = 'ana.silva@email.com'), '2025-12-10', '2025-12-24', '2025-12-23', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Olhai os Lírios do Campo'), (SELECT id_usuario FROM usuarios WHERE email = 'bruno.oliveira@email.com'), '2025-12-15', '2025-12-29', '2025-12-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE titulo = 'Noite na Taverna'), (SELECT id_usuario FROM usuarios WHERE email = 'carla.mendes@email.com'), '2025-12-20', '2026-01-03', '2026-01-02', 'devolvido');
