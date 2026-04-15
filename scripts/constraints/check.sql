ALTER TABLE emprestimos ADD CONSTRAINT check_datas CHECK (data_devolucao_prevista >= data_saida);
