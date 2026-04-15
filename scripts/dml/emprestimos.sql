USE biblioteca;

-- 1-5: Empréstimos já devolvidos (no prazo)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-001-1'), (SELECT id_usuario FROM usuarios WHERE login = 'ana.silva'), '2026-01-10', '2026-01-24', '2026-01-20', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-002-8'), (SELECT id_usuario FROM usuarios WHERE login = 'bruno.oliveira'), '2026-01-15', '2026-01-29', '2026-01-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-003-5'), (SELECT id_usuario FROM usuarios WHERE login = 'carla.mendes'), '2026-02-01', '2026-02-15', '2026-02-10', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-005-9'), (SELECT id_usuario FROM usuarios WHERE login = 'elena.ferreira'), '2026-02-05', '2026-02-19', '2026-02-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-006-6'), (SELECT id_usuario FROM usuarios WHERE login = 'felipe.santos'), '2026-02-10', '2026-02-24', '2026-02-22', 'devolvido');

-- 6-10: Empréstimos devolvidos com atraso
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-007-3'), (SELECT id_usuario FROM usuarios WHERE login = 'gabriela.lima'), '2026-01-05', '2026-01-19', '2026-02-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-008-0'), (SELECT id_usuario FROM usuarios WHERE login = 'hugo.pereira'), '2026-01-20', '2026-02-03', '2026-02-15', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-009-7'), (SELECT id_usuario FROM usuarios WHERE login = 'isabela.costa'), '2026-02-01', '2026-02-15', '2026-03-01', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-010-3'), (SELECT id_usuario FROM usuarios WHERE login = 'joao.almeida'), '2026-02-10', '2026-02-24', '2026-03-05', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-011-0'), (SELECT id_usuario FROM usuarios WHERE login = 'ana.silva'), '2026-02-15', '2026-03-01', '2026-03-10', 'devolvido');

-- 11-20: Empréstimos pendentes (ainda dentro do prazo - data_devolucao_prevista > hoje)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-012-7'), (SELECT id_usuario FROM usuarios WHERE login = 'bruno.oliveira'), '2026-04-10', '2026-04-24', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-013-4'), (SELECT id_usuario FROM usuarios WHERE login = 'carla.mendes'), '2026-04-08', '2026-04-22', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-014-1'), (SELECT id_usuario FROM usuarios WHERE login = 'daniel.souza'), '2026-04-05', '2026-04-19', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-015-8'), (SELECT id_usuario FROM usuarios WHERE login = 'elena.ferreira'), '2026-04-12', '2026-04-26', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-016-5'), (SELECT id_usuario FROM usuarios WHERE login = 'felipe.santos'), '2026-04-11', '2026-04-25', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-017-2'), (SELECT id_usuario FROM usuarios WHERE login = 'gabriela.lima'), '2026-04-09', '2026-04-23', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-018-9'), (SELECT id_usuario FROM usuarios WHERE login = 'hugo.pereira'), '2026-04-13', '2026-04-27', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-019-6'), (SELECT id_usuario FROM usuarios WHERE login = 'isabela.costa'), '2026-04-07', '2026-04-21', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-020-2'), (SELECT id_usuario FROM usuarios WHERE login = 'joao.almeida'), '2026-04-14', '2026-04-28', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-021-9'), (SELECT id_usuario FROM usuarios WHERE login = 'ana.silva'), '2026-04-06', '2026-04-20', NULL, 'pendente');

-- 21-30: Empréstimos atrasados (data_devolucao_prevista < hoje, sem devolução)
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-022-6'), (SELECT id_usuario FROM usuarios WHERE login = 'bruno.oliveira'), '2026-03-01', '2026-03-15', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-023-3'), (SELECT id_usuario FROM usuarios WHERE login = 'carla.mendes'), '2026-03-05', '2026-03-19', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-024-0'), (SELECT id_usuario FROM usuarios WHERE login = 'daniel.souza'), '2026-03-10', '2026-03-24', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-025-7'), (SELECT id_usuario FROM usuarios WHERE login = 'elena.ferreira'), '2026-03-02', '2026-03-16', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-026-4'), (SELECT id_usuario FROM usuarios WHERE login = 'felipe.santos'), '2026-03-08', '2026-03-22', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-027-1'), (SELECT id_usuario FROM usuarios WHERE login = 'gabriela.lima'), '2026-03-12', '2026-03-26', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-028-8'), (SELECT id_usuario FROM usuarios WHERE login = 'hugo.pereira'), '2026-03-03', '2026-03-17', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-029-5'), (SELECT id_usuario FROM usuarios WHERE login = 'isabela.costa'), '2026-03-07', '2026-03-21', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-030-1'), (SELECT id_usuario FROM usuarios WHERE login = 'joao.almeida'), '2026-03-15', '2026-03-29', NULL, 'atrasado'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-004-2'), (SELECT id_usuario FROM usuarios WHERE login = 'ana.silva'), '2026-03-20', '2026-04-03', NULL, 'atrasado');

-- 31-35: Empréstimos pendentes com prazo muito próximo de vencer
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-001-1'), (SELECT id_usuario FROM usuarios WHERE login = 'daniel.souza'), '2026-04-01', '2026-04-16', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-002-8'), (SELECT id_usuario FROM usuarios WHERE login = 'elena.ferreira'), '2026-04-02', '2026-04-17', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-003-5'), (SELECT id_usuario FROM usuarios WHERE login = 'felipe.santos'), '2026-04-03', '2026-04-16', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-005-9'), (SELECT id_usuario FROM usuarios WHERE login = 'gabriela.lima'), '2026-04-01', '2026-04-15', NULL, 'pendente'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-006-6'), (SELECT id_usuario FROM usuarios WHERE login = 'hugo.pereira'), '2026-04-02', '2026-04-18', NULL, 'pendente');

-- 36-40: Mais empréstimos devolvidos para histórico
INSERT INTO emprestimos (id_livro, id_usuario, data_saida, data_devolucao_prevista, data_devolucao_real, status) VALUES
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-025-7'), (SELECT id_usuario FROM usuarios WHERE login = 'isabela.costa'), '2025-12-01', '2025-12-15', '2025-12-14', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-026-4'), (SELECT id_usuario FROM usuarios WHERE login = 'joao.almeida'), '2025-12-05', '2025-12-19', '2025-12-18', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-027-1'), (SELECT id_usuario FROM usuarios WHERE login = 'ana.silva'), '2025-12-10', '2025-12-24', '2025-12-23', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-028-8'), (SELECT id_usuario FROM usuarios WHERE login = 'bruno.oliveira'), '2025-12-15', '2025-12-29', '2025-12-28', 'devolvido'),
((SELECT id_livro FROM livros WHERE isbn = '978-85-7232-029-5'), (SELECT id_usuario FROM usuarios WHERE login = 'carla.mendes'), '2025-12-20', '2026-01-03', '2026-01-02', 'devolvido');
