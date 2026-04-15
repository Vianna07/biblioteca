/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.4.10-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: biblioteca
-- ------------------------------------------------------
-- Server version	11.4.10-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `emprestimos`
--

DROP TABLE IF EXISTS `emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimos` (
  `id_emprestimo` uuid NOT NULL DEFAULT uuid(),
  `id_livro` uuid NOT NULL,
  `id_usuario` uuid NOT NULL,
  `data_saida` date NOT NULL,
  `data_devolucao_prevista` date NOT NULL,
  `data_devolucao_real` date DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pendente',
  PRIMARY KEY (`id_emprestimo`),
  KEY `id_livro` (`id_livro`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `emprestimos_ibfk_1` FOREIGN KEY (`id_livro`) REFERENCES `livros` (`id_livro`),
  CONSTRAINT `emprestimos_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `check_datas` CHECK (`data_devolucao_prevista` >= `data_saida`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimos`
--

LOCK TABLES `emprestimos` WRITE;
/*!40000 ALTER TABLE `emprestimos` DISABLE KEYS */;
INSERT INTO `emprestimos` VALUES
('ec51567c-391f-11f1-882f-e268fd616e52','ec5083ef-391f-11f1-882f-e268fd616e52','ec4f988e-391f-11f1-882f-e268fd616e52','2026-01-10','2026-01-24','2026-01-20','devolvido'),
('ec5158b0-391f-11f1-882f-e268fd616e52','ec508511-391f-11f1-882f-e268fd616e52','ec4f9a01-391f-11f1-882f-e268fd616e52','2026-01-15','2026-01-29','2026-01-28','devolvido'),
('ec51592a-391f-11f1-882f-e268fd616e52','ec508565-391f-11f1-882f-e268fd616e52','ec4f9a6f-391f-11f1-882f-e268fd616e52','2026-02-01','2026-02-15','2026-02-10','devolvido'),
('ec515964-391f-11f1-882f-e268fd616e52','ec5085ac-391f-11f1-882f-e268fd616e52','ec4f9ab1-391f-11f1-882f-e268fd616e52','2026-02-05','2026-02-19','2026-02-18','devolvido'),
('ec5159a1-391f-11f1-882f-e268fd616e52','ec5085ce-391f-11f1-882f-e268fd616e52','ec4f9adb-391f-11f1-882f-e268fd616e52','2026-02-10','2026-02-24','2026-02-22','devolvido'),
('ec51dc5f-391f-11f1-882f-e268fd616e52','ec5085ed-391f-11f1-882f-e268fd616e52','ec4f9b03-391f-11f1-882f-e268fd616e52','2026-01-05','2026-01-19','2026-02-01','devolvido'),
('ec51dd53-391f-11f1-882f-e268fd616e52','ec508602-391f-11f1-882f-e268fd616e52','ec4f9b29-391f-11f1-882f-e268fd616e52','2026-01-20','2026-02-03','2026-02-15','devolvido'),
('ec51dd84-391f-11f1-882f-e268fd616e52','ec508619-391f-11f1-882f-e268fd616e52','ec4f9b50-391f-11f1-882f-e268fd616e52','2026-02-01','2026-02-15','2026-03-01','devolvido'),
('ec51ddbc-391f-11f1-882f-e268fd616e52','ec508634-391f-11f1-882f-e268fd616e52','ec4f9b74-391f-11f1-882f-e268fd616e52','2026-02-10','2026-02-24','2026-03-05','devolvido'),
('ec51dde3-391f-11f1-882f-e268fd616e52','ec50865a-391f-11f1-882f-e268fd616e52','ec4f988e-391f-11f1-882f-e268fd616e52','2026-02-15','2026-03-01','2026-03-10','devolvido'),
('ec52593c-391f-11f1-882f-e268fd616e52','ec5086a0-391f-11f1-882f-e268fd616e52','ec4f9a01-391f-11f1-882f-e268fd616e52','2026-04-10','2026-04-24',NULL,'pendente'),
('ec525a52-391f-11f1-882f-e268fd616e52','ec5086b4-391f-11f1-882f-e268fd616e52','ec4f9a6f-391f-11f1-882f-e268fd616e52','2026-04-08','2026-04-22',NULL,'pendente'),
('ec525a8b-391f-11f1-882f-e268fd616e52','ec5086c9-391f-11f1-882f-e268fd616e52','ec4f9a8f-391f-11f1-882f-e268fd616e52','2026-04-05','2026-04-19',NULL,'pendente'),
('ec525ab9-391f-11f1-882f-e268fd616e52','ec5086db-391f-11f1-882f-e268fd616e52','ec4f9ab1-391f-11f1-882f-e268fd616e52','2026-04-12','2026-04-26',NULL,'pendente'),
('ec525ae6-391f-11f1-882f-e268fd616e52','ec5086ef-391f-11f1-882f-e268fd616e52','ec4f9adb-391f-11f1-882f-e268fd616e52','2026-04-11','2026-04-25',NULL,'pendente'),
('ec525b13-391f-11f1-882f-e268fd616e52','ec508702-391f-11f1-882f-e268fd616e52','ec4f9b03-391f-11f1-882f-e268fd616e52','2026-04-09','2026-04-23',NULL,'pendente'),
('ec525b40-391f-11f1-882f-e268fd616e52','ec508715-391f-11f1-882f-e268fd616e52','ec4f9b29-391f-11f1-882f-e268fd616e52','2026-04-13','2026-04-27',NULL,'pendente'),
('ec525b6d-391f-11f1-882f-e268fd616e52','ec508728-391f-11f1-882f-e268fd616e52','ec4f9b50-391f-11f1-882f-e268fd616e52','2026-04-07','2026-04-21',NULL,'pendente'),
('ec525b9b-391f-11f1-882f-e268fd616e52','ec50873c-391f-11f1-882f-e268fd616e52','ec4f9b74-391f-11f1-882f-e268fd616e52','2026-04-14','2026-04-28',NULL,'pendente'),
('ec525bc7-391f-11f1-882f-e268fd616e52','ec50874f-391f-11f1-882f-e268fd616e52','ec4f988e-391f-11f1-882f-e268fd616e52','2026-04-06','2026-04-20',NULL,'pendente'),
('ec52cd5f-391f-11f1-882f-e268fd616e52','ec508762-391f-11f1-882f-e268fd616e52','ec4f9a01-391f-11f1-882f-e268fd616e52','2026-03-01','2026-03-15',NULL,'atrasado'),
('ec52ce67-391f-11f1-882f-e268fd616e52','ec508776-391f-11f1-882f-e268fd616e52','ec4f9a6f-391f-11f1-882f-e268fd616e52','2026-03-05','2026-03-19',NULL,'atrasado'),
('ec52ce97-391f-11f1-882f-e268fd616e52','ec50878b-391f-11f1-882f-e268fd616e52','ec4f9a8f-391f-11f1-882f-e268fd616e52','2026-03-10','2026-03-24',NULL,'atrasado'),
('ec52cebe-391f-11f1-882f-e268fd616e52','ec50879d-391f-11f1-882f-e268fd616e52','ec4f9ab1-391f-11f1-882f-e268fd616e52','2026-03-02','2026-03-16',NULL,'atrasado'),
('ec52cee7-391f-11f1-882f-e268fd616e52','ec5087b0-391f-11f1-882f-e268fd616e52','ec4f9adb-391f-11f1-882f-e268fd616e52','2026-03-08','2026-03-22',NULL,'atrasado'),
('ec52cf0d-391f-11f1-882f-e268fd616e52','ec5087c3-391f-11f1-882f-e268fd616e52','ec4f9b03-391f-11f1-882f-e268fd616e52','2026-03-12','2026-03-26',NULL,'atrasado'),
('ec52cf35-391f-11f1-882f-e268fd616e52','ec5087d6-391f-11f1-882f-e268fd616e52','ec4f9b29-391f-11f1-882f-e268fd616e52','2026-03-03','2026-03-17',NULL,'atrasado'),
('ec52cf5b-391f-11f1-882f-e268fd616e52','ec5087e9-391f-11f1-882f-e268fd616e52','ec4f9b50-391f-11f1-882f-e268fd616e52','2026-03-07','2026-03-21',NULL,'atrasado'),
('ec52cf82-391f-11f1-882f-e268fd616e52','ec5087fc-391f-11f1-882f-e268fd616e52','ec4f9b74-391f-11f1-882f-e268fd616e52','2026-03-15','2026-03-29',NULL,'atrasado'),
('ec52cfa9-391f-11f1-882f-e268fd616e52','ec50858b-391f-11f1-882f-e268fd616e52','ec4f988e-391f-11f1-882f-e268fd616e52','2026-03-20','2026-04-03',NULL,'atrasado'),
('ec533671-391f-11f1-882f-e268fd616e52','ec5083ef-391f-11f1-882f-e268fd616e52','ec4f9a8f-391f-11f1-882f-e268fd616e52','2026-04-01','2026-04-16',NULL,'pendente'),
('ec533777-391f-11f1-882f-e268fd616e52','ec508511-391f-11f1-882f-e268fd616e52','ec4f9ab1-391f-11f1-882f-e268fd616e52','2026-04-02','2026-04-17',NULL,'pendente'),
('ec5337af-391f-11f1-882f-e268fd616e52','ec508565-391f-11f1-882f-e268fd616e52','ec4f9adb-391f-11f1-882f-e268fd616e52','2026-04-03','2026-04-16',NULL,'pendente'),
('ec5337e3-391f-11f1-882f-e268fd616e52','ec5085ac-391f-11f1-882f-e268fd616e52','ec4f9b03-391f-11f1-882f-e268fd616e52','2026-04-01','2026-04-15',NULL,'pendente'),
('ec533819-391f-11f1-882f-e268fd616e52','ec5085ce-391f-11f1-882f-e268fd616e52','ec4f9b29-391f-11f1-882f-e268fd616e52','2026-04-02','2026-04-18',NULL,'pendente'),
('ec53b011-391f-11f1-882f-e268fd616e52','ec50879d-391f-11f1-882f-e268fd616e52','ec4f9b50-391f-11f1-882f-e268fd616e52','2025-12-01','2025-12-15','2025-12-14','devolvido'),
('ec53b122-391f-11f1-882f-e268fd616e52','ec5087b0-391f-11f1-882f-e268fd616e52','ec4f9b74-391f-11f1-882f-e268fd616e52','2025-12-05','2025-12-19','2025-12-18','devolvido'),
('ec53b151-391f-11f1-882f-e268fd616e52','ec5087c3-391f-11f1-882f-e268fd616e52','ec4f988e-391f-11f1-882f-e268fd616e52','2025-12-10','2025-12-24','2025-12-23','devolvido'),
('ec53b17c-391f-11f1-882f-e268fd616e52','ec5087d6-391f-11f1-882f-e268fd616e52','ec4f9a01-391f-11f1-882f-e268fd616e52','2025-12-15','2025-12-29','2025-12-28','devolvido'),
('ec53b1aa-391f-11f1-882f-e268fd616e52','ec5087e9-391f-11f1-882f-e268fd616e52','ec4f9a6f-391f-11f1-882f-e268fd616e52','2025-12-20','2026-01-03','2026-01-02','devolvido');
/*!40000 ALTER TABLE `emprestimos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livros`
--

DROP TABLE IF EXISTS `livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `livros` (
  `id_livro` uuid NOT NULL DEFAULT uuid(),
  `titulo` varchar(255) NOT NULL,
  `autor` varchar(100) NOT NULL,
  `editora` varchar(100) DEFAULT NULL,
  `ano_lancamento` int(11) DEFAULT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_livro`),
  UNIQUE KEY `isbn` (`isbn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES
('ec5083ef-391f-11f1-882f-e268fd616e52','Dom Casmurro','Machado de Assis','Garnier',1899,'978-85-7232-001-1'),
('ec508511-391f-11f1-882f-e268fd616e52','Grande Sertão: Veredas','Guimarães Rosa','José Olympio',1956,'978-85-7232-002-8'),
('ec508565-391f-11f1-882f-e268fd616e52','Memórias Póstumas de Brás Cubas','Machado de Assis','Tipografia Nacional',1881,'978-85-7232-003-5'),
('ec50858b-391f-11f1-882f-e268fd616e52','O Cortiço','Aluísio Azevedo','B. L. Garnier',1890,'978-85-7232-004-2'),
('ec5085ac-391f-11f1-882f-e268fd616e52','Capitães da Areia','Jorge Amado','José Olympio',1937,'978-85-7232-005-9'),
('ec5085ce-391f-11f1-882f-e268fd616e52','Vidas Secas','Graciliano Ramos','José Olympio',1938,'978-85-7232-006-6'),
('ec5085ed-391f-11f1-882f-e268fd616e52','A Hora da Estrela','Clarice Lispector','José Olympio',1977,'978-85-7232-007-3'),
('ec508602-391f-11f1-882f-e268fd616e52','O Alienista','Machado de Assis','Garnier',1882,'978-85-7232-008-0'),
('ec508619-391f-11f1-882f-e268fd616e52','Iracema','José de Alencar','Tipografia Viana',1865,'978-85-7232-009-7'),
('ec508634-391f-11f1-882f-e268fd616e52','Macunaíma','Mário de Andrade','Oficinas Gráficas',1928,'978-85-7232-010-3'),
('ec50865a-391f-11f1-882f-e268fd616e52','O Tempo e o Vento','Erico Verissimo','Globo',1949,'978-85-7232-011-0'),
('ec5086a0-391f-11f1-882f-e268fd616e52','Quincas Borba','Machado de Assis','Garnier',1891,'978-85-7232-012-7'),
('ec5086b4-391f-11f1-882f-e268fd616e52','Menino de Engenho','José Lins do Rego','José Olympio',1932,'978-85-7232-013-4'),
('ec5086c9-391f-11f1-882f-e268fd616e52','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,'978-85-7232-014-1'),
('ec5086db-391f-11f1-882f-e268fd616e52','São Bernardo','Graciliano Ramos','Ariel',1934,'978-85-7232-015-8'),
('ec5086ef-391f-11f1-882f-e268fd616e52','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,'978-85-7232-016-5'),
('ec508702-391f-11f1-882f-e268fd616e52','O Guarani','José de Alencar','Empresa Nacional',1857,'978-85-7232-017-2'),
('ec508715-391f-11f1-882f-e268fd616e52','Clara dos Anjos','Lima Barreto','Mérito',1948,'978-85-7232-018-9'),
('ec508728-391f-11f1-882f-e268fd616e52','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,'978-85-7232-019-6'),
('ec50873c-391f-11f1-882f-e268fd616e52','A Paixão Segundo G.H.','Clarice Lispector','Editora do Autor',1964,'978-85-7232-020-2'),
('ec50874f-391f-11f1-882f-e268fd616e52','Lavoura Arcaica','Raduan Nassar','José Olympio',1975,'978-85-7232-021-9'),
('ec508762-391f-11f1-882f-e268fd616e52','Angústia','Graciliano Ramos','José Olympio',1936,'978-85-7232-022-6'),
('ec508776-391f-11f1-882f-e268fd616e52','Memórias de um Sargento de Milícias','Manuel Antônio de Almeida','Tipografia Nacional',1854,'978-85-7232-023-3'),
('ec50878b-391f-11f1-882f-e268fd616e52','O Quinze','Rachel de Queiroz','Editora Olympio',1930,'978-85-7232-024-0'),
('ec50879d-391f-11f1-882f-e268fd616e52','Sagarana','Guimarães Rosa','Universal',1946,'978-85-7232-025-7'),
('ec5087b0-391f-11f1-882f-e268fd616e52','Fogo Morto','José Lins do Rego','José Olympio',1943,'978-85-7232-026-4'),
('ec5087c3-391f-11f1-882f-e268fd616e52','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,'978-85-7232-027-1'),
('ec5087d6-391f-11f1-882f-e268fd616e52','Olhai os Lírios do Campo','Erico Verissimo','Globo',1938,'978-85-7232-028-8'),
('ec5087e9-391f-11f1-882f-e268fd616e52','Noite na Taverna','Álvares de Azevedo','Garnier',1855,'978-85-7232-029-5'),
('ec5087fc-391f-11f1-882f-e268fd616e52','Dois Irmãos','Milton Hatoum','Companhia das Letras',2000,'978-85-7232-030-1');
/*!40000 ALTER TABLE `livros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` uuid NOT NULL DEFAULT uuid(),
  `nome` varchar(100) NOT NULL,
  `login` varchar(50) NOT NULL,
  `senha` varchar(255) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `login` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES
('ec4f988e-391f-11f1-882f-e268fd616e52','Ana Clara Silva','ana.silva','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9a01-391f-11f1-882f-e268fd616e52','Bruno Oliveira','bruno.oliveira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9a6f-391f-11f1-882f-e268fd616e52','Carla Mendes','carla.mendes','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9a8f-391f-11f1-882f-e268fd616e52','Daniel Souza','daniel.souza','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9ab1-391f-11f1-882f-e268fd616e52','Elena Ferreira','elena.ferreira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9adb-391f-11f1-882f-e268fd616e52','Felipe Santos','felipe.santos','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9b03-391f-11f1-882f-e268fd616e52','Gabriela Lima','gabriela.lima','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9b29-391f-11f1-882f-e268fd616e52','Hugo Pereira','hugo.pereira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9b50-391f-11f1-882f-e268fd616e52','Isabela Costa','isabela.costa','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('ec4f9b74-391f-11f1-882f-e268fd616e52','João Almeida','joao.almeida','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-15 23:07:55
