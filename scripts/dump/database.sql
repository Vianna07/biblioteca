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
-- Current Database: `biblioteca`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `biblioteca` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;

USE `biblioteca`;

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
('1ff5a84e-3923-11f1-b1c4-8eb6307b03ec','1ff4b44e-3923-11f1-b1c4-8eb6307b03ec','1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','2026-01-10','2026-01-24','2026-01-20','devolvido'),
('1ff5aae6-3923-11f1-b1c4-8eb6307b03ec','1ff4b5a4-3923-11f1-b1c4-8eb6307b03ec','1ff3d1b6-3923-11f1-b1c4-8eb6307b03ec','2026-01-15','2026-01-29','2026-01-28','devolvido'),
('1ff5ac0d-3923-11f1-b1c4-8eb6307b03ec','1ff4b5e3-3923-11f1-b1c4-8eb6307b03ec','1ff3d215-3923-11f1-b1c4-8eb6307b03ec','2026-02-01','2026-02-15','2026-02-10','devolvido'),
('1ff5accb-3923-11f1-b1c4-8eb6307b03ec','1ff4b613-3923-11f1-b1c4-8eb6307b03ec','1ff3d24b-3923-11f1-b1c4-8eb6307b03ec','2026-02-05','2026-02-19','2026-02-18','devolvido'),
('1ff5ad8b-3923-11f1-b1c4-8eb6307b03ec','1ff4b628-3923-11f1-b1c4-8eb6307b03ec','1ff3d26a-3923-11f1-b1c4-8eb6307b03ec','2026-02-10','2026-02-24','2026-02-22','devolvido'),
('1ff62c16-3923-11f1-b1c4-8eb6307b03ec','1ff4b63c-3923-11f1-b1c4-8eb6307b03ec','1ff3d283-3923-11f1-b1c4-8eb6307b03ec','2026-01-05','2026-01-19','2026-02-01','devolvido'),
('1ff62e93-3923-11f1-b1c4-8eb6307b03ec','1ff4b64e-3923-11f1-b1c4-8eb6307b03ec','1ff3d299-3923-11f1-b1c4-8eb6307b03ec','2026-01-20','2026-02-03','2026-02-15','devolvido'),
('1ff62f2a-3923-11f1-b1c4-8eb6307b03ec','1ff4b663-3923-11f1-b1c4-8eb6307b03ec','1ff3d2b2-3923-11f1-b1c4-8eb6307b03ec','2026-02-01','2026-02-15','2026-03-01','devolvido'),
('1ff62fbc-3923-11f1-b1c4-8eb6307b03ec','1ff4b676-3923-11f1-b1c4-8eb6307b03ec','1ff3d2c8-3923-11f1-b1c4-8eb6307b03ec','2026-02-10','2026-02-24','2026-03-05','devolvido'),
('1ff6304b-3923-11f1-b1c4-8eb6307b03ec','1ff4b688-3923-11f1-b1c4-8eb6307b03ec','1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','2026-02-15','2026-03-01','2026-03-10','devolvido'),
('1ff6c756-3923-11f1-b1c4-8eb6307b03ec','1ff4b69b-3923-11f1-b1c4-8eb6307b03ec','1ff3d1b6-3923-11f1-b1c4-8eb6307b03ec','2026-04-10','2026-04-24',NULL,'pendente'),
('1ff6c901-3923-11f1-b1c4-8eb6307b03ec','1ff4b6ae-3923-11f1-b1c4-8eb6307b03ec','1ff3d215-3923-11f1-b1c4-8eb6307b03ec','2026-04-08','2026-04-22',NULL,'pendente'),
('1ff6c99c-3923-11f1-b1c4-8eb6307b03ec','1ff4b6c0-3923-11f1-b1c4-8eb6307b03ec','1ff3d231-3923-11f1-b1c4-8eb6307b03ec','2026-04-05','2026-04-19',NULL,'pendente'),
('1ff6ca2c-3923-11f1-b1c4-8eb6307b03ec','1ff4b6e3-3923-11f1-b1c4-8eb6307b03ec','1ff3d24b-3923-11f1-b1c4-8eb6307b03ec','2026-04-12','2026-04-26',NULL,'pendente'),
('1ff6cac0-3923-11f1-b1c4-8eb6307b03ec','1ff4b6f1-3923-11f1-b1c4-8eb6307b03ec','1ff3d26a-3923-11f1-b1c4-8eb6307b03ec','2026-04-11','2026-04-25',NULL,'pendente'),
('1ff6cb4d-3923-11f1-b1c4-8eb6307b03ec','1ff4b6ff-3923-11f1-b1c4-8eb6307b03ec','1ff3d283-3923-11f1-b1c4-8eb6307b03ec','2026-04-09','2026-04-23',NULL,'pendente'),
('1ff6cbe1-3923-11f1-b1c4-8eb6307b03ec','1ff4b70d-3923-11f1-b1c4-8eb6307b03ec','1ff3d299-3923-11f1-b1c4-8eb6307b03ec','2026-04-13','2026-04-27',NULL,'pendente'),
('1ff6ccab-3923-11f1-b1c4-8eb6307b03ec','1ff4b72b-3923-11f1-b1c4-8eb6307b03ec','1ff3d2b2-3923-11f1-b1c4-8eb6307b03ec','2026-04-07','2026-04-21',NULL,'pendente'),
('1ff6cd3b-3923-11f1-b1c4-8eb6307b03ec','1ff4b739-3923-11f1-b1c4-8eb6307b03ec','1ff3d2c8-3923-11f1-b1c4-8eb6307b03ec','2026-04-14','2026-04-28',NULL,'pendente'),
('1ff6cdc8-3923-11f1-b1c4-8eb6307b03ec','1ff4b746-3923-11f1-b1c4-8eb6307b03ec','1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','2026-04-06','2026-04-20',NULL,'pendente'),
('1ff74853-3923-11f1-b1c4-8eb6307b03ec','1ff4b755-3923-11f1-b1c4-8eb6307b03ec','1ff3d1b6-3923-11f1-b1c4-8eb6307b03ec','2026-03-01','2026-03-15',NULL,'atrasado'),
('1ff74a0d-3923-11f1-b1c4-8eb6307b03ec','1ff4b763-3923-11f1-b1c4-8eb6307b03ec','1ff3d215-3923-11f1-b1c4-8eb6307b03ec','2026-03-05','2026-03-19',NULL,'atrasado'),
('1ff74aab-3923-11f1-b1c4-8eb6307b03ec','1ff4b770-3923-11f1-b1c4-8eb6307b03ec','1ff3d231-3923-11f1-b1c4-8eb6307b03ec','2026-03-10','2026-03-24',NULL,'atrasado'),
('1ff74b3e-3923-11f1-b1c4-8eb6307b03ec','1ff4b77d-3923-11f1-b1c4-8eb6307b03ec','1ff3d24b-3923-11f1-b1c4-8eb6307b03ec','2026-03-02','2026-03-16',NULL,'atrasado'),
('1ff74bcd-3923-11f1-b1c4-8eb6307b03ec','1ff4b78a-3923-11f1-b1c4-8eb6307b03ec','1ff3d26a-3923-11f1-b1c4-8eb6307b03ec','2026-03-08','2026-03-22',NULL,'atrasado'),
('1ff74c5e-3923-11f1-b1c4-8eb6307b03ec','1ff4b798-3923-11f1-b1c4-8eb6307b03ec','1ff3d283-3923-11f1-b1c4-8eb6307b03ec','2026-03-12','2026-03-26',NULL,'atrasado'),
('1ff74cef-3923-11f1-b1c4-8eb6307b03ec','1ff4b7a4-3923-11f1-b1c4-8eb6307b03ec','1ff3d299-3923-11f1-b1c4-8eb6307b03ec','2026-03-03','2026-03-17',NULL,'atrasado'),
('1ff74d7c-3923-11f1-b1c4-8eb6307b03ec','1ff4b7b2-3923-11f1-b1c4-8eb6307b03ec','1ff3d2b2-3923-11f1-b1c4-8eb6307b03ec','2026-03-07','2026-03-21',NULL,'atrasado'),
('1ff74e0b-3923-11f1-b1c4-8eb6307b03ec','1ff4b7bf-3923-11f1-b1c4-8eb6307b03ec','1ff3d2c8-3923-11f1-b1c4-8eb6307b03ec','2026-03-15','2026-03-29',NULL,'atrasado'),
('1ff74e9c-3923-11f1-b1c4-8eb6307b03ec','1ff4b5fd-3923-11f1-b1c4-8eb6307b03ec','1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','2026-03-20','2026-04-03',NULL,'atrasado'),
('1ff7ec1f-3923-11f1-b1c4-8eb6307b03ec','1ff4b44e-3923-11f1-b1c4-8eb6307b03ec','1ff3d231-3923-11f1-b1c4-8eb6307b03ec','2026-04-01','2026-04-16',NULL,'pendente'),
('1ff7ed8f-3923-11f1-b1c4-8eb6307b03ec','1ff4b5a4-3923-11f1-b1c4-8eb6307b03ec','1ff3d24b-3923-11f1-b1c4-8eb6307b03ec','2026-04-02','2026-04-17',NULL,'pendente'),
('1ff7ee2b-3923-11f1-b1c4-8eb6307b03ec','1ff4b5e3-3923-11f1-b1c4-8eb6307b03ec','1ff3d26a-3923-11f1-b1c4-8eb6307b03ec','2026-04-03','2026-04-16',NULL,'pendente'),
('1ff7eebc-3923-11f1-b1c4-8eb6307b03ec','1ff4b613-3923-11f1-b1c4-8eb6307b03ec','1ff3d283-3923-11f1-b1c4-8eb6307b03ec','2026-04-01','2026-04-15',NULL,'pendente'),
('1ff7ef54-3923-11f1-b1c4-8eb6307b03ec','1ff4b628-3923-11f1-b1c4-8eb6307b03ec','1ff3d299-3923-11f1-b1c4-8eb6307b03ec','2026-04-02','2026-04-18',NULL,'pendente'),
('1ff8b46b-3923-11f1-b1c4-8eb6307b03ec','1ff4b77d-3923-11f1-b1c4-8eb6307b03ec','1ff3d2b2-3923-11f1-b1c4-8eb6307b03ec','2025-12-01','2025-12-15','2025-12-14','devolvido'),
('1ff8b64d-3923-11f1-b1c4-8eb6307b03ec','1ff4b78a-3923-11f1-b1c4-8eb6307b03ec','1ff3d2c8-3923-11f1-b1c4-8eb6307b03ec','2025-12-05','2025-12-19','2025-12-18','devolvido'),
('1ff8b6f0-3923-11f1-b1c4-8eb6307b03ec','1ff4b798-3923-11f1-b1c4-8eb6307b03ec','1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','2025-12-10','2025-12-24','2025-12-23','devolvido'),
('1ff8b78f-3923-11f1-b1c4-8eb6307b03ec','1ff4b7a4-3923-11f1-b1c4-8eb6307b03ec','1ff3d1b6-3923-11f1-b1c4-8eb6307b03ec','2025-12-15','2025-12-29','2025-12-28','devolvido'),
('1ff8b834-3923-11f1-b1c4-8eb6307b03ec','1ff4b7b2-3923-11f1-b1c4-8eb6307b03ec','1ff3d215-3923-11f1-b1c4-8eb6307b03ec','2025-12-20','2026-01-03','2026-01-02','devolvido');
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
  PRIMARY KEY (`id_livro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES
('1ff4b44e-3923-11f1-b1c4-8eb6307b03ec','Dom Casmurro','Machado de Assis','Garnier',1899),
('1ff4b5a4-3923-11f1-b1c4-8eb6307b03ec','Grande Sertão: Veredas','Guimarães Rosa','José Olympio',1956),
('1ff4b5e3-3923-11f1-b1c4-8eb6307b03ec','Memórias Póstumas de Brás Cubas','Machado de Assis','Tipografia Nacional',1881),
('1ff4b5fd-3923-11f1-b1c4-8eb6307b03ec','O Cortiço','Aluísio Azevedo','B. L. Garnier',1890),
('1ff4b613-3923-11f1-b1c4-8eb6307b03ec','Capitães da Areia','Jorge Amado','José Olympio',1937),
('1ff4b628-3923-11f1-b1c4-8eb6307b03ec','Vidas Secas','Graciliano Ramos','José Olympio',1938),
('1ff4b63c-3923-11f1-b1c4-8eb6307b03ec','A Hora da Estrela','Clarice Lispector','José Olympio',1977),
('1ff4b64e-3923-11f1-b1c4-8eb6307b03ec','O Alienista','Machado de Assis','Garnier',1882),
('1ff4b663-3923-11f1-b1c4-8eb6307b03ec','Iracema','José de Alencar','Tipografia Viana',1865),
('1ff4b676-3923-11f1-b1c4-8eb6307b03ec','Macunaíma','Mário de Andrade','Oficinas Gráficas',1928),
('1ff4b688-3923-11f1-b1c4-8eb6307b03ec','O Tempo e o Vento','Erico Verissimo','Globo',1949),
('1ff4b69b-3923-11f1-b1c4-8eb6307b03ec','Quincas Borba','Machado de Assis','Garnier',1891),
('1ff4b6ae-3923-11f1-b1c4-8eb6307b03ec','Menino de Engenho','José Lins do Rego','José Olympio',1932),
('1ff4b6c0-3923-11f1-b1c4-8eb6307b03ec','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958),
('1ff4b6e3-3923-11f1-b1c4-8eb6307b03ec','São Bernardo','Graciliano Ramos','Ariel',1934),
('1ff4b6f1-3923-11f1-b1c4-8eb6307b03ec','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844),
('1ff4b6ff-3923-11f1-b1c4-8eb6307b03ec','O Guarani','José de Alencar','Empresa Nacional',1857),
('1ff4b70d-3923-11f1-b1c4-8eb6307b03ec','Clara dos Anjos','Lima Barreto','Mérito',1948),
('1ff4b72b-3923-11f1-b1c4-8eb6307b03ec','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915),
('1ff4b739-3923-11f1-b1c4-8eb6307b03ec','A Paixão Segundo G.H.','Clarice Lispector','Editora do Autor',1964),
('1ff4b746-3923-11f1-b1c4-8eb6307b03ec','Lavoura Arcaica','Raduan Nassar','José Olympio',1975),
('1ff4b755-3923-11f1-b1c4-8eb6307b03ec','Angústia','Graciliano Ramos','José Olympio',1936),
('1ff4b763-3923-11f1-b1c4-8eb6307b03ec','Memórias de um Sargento de Milícias','Manuel Antônio de Almeida','Tipografia Nacional',1854),
('1ff4b770-3923-11f1-b1c4-8eb6307b03ec','O Quinze','Rachel de Queiroz','Editora Olympio',1930),
('1ff4b77d-3923-11f1-b1c4-8eb6307b03ec','Sagarana','Guimarães Rosa','Universal',1946),
('1ff4b78a-3923-11f1-b1c4-8eb6307b03ec','Fogo Morto','José Lins do Rego','José Olympio',1943),
('1ff4b798-3923-11f1-b1c4-8eb6307b03ec','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966),
('1ff4b7a4-3923-11f1-b1c4-8eb6307b03ec','Olhai os Lírios do Campo','Erico Verissimo','Globo',1938),
('1ff4b7b2-3923-11f1-b1c4-8eb6307b03ec','Noite na Taverna','Álvares de Azevedo','Garnier',1855),
('1ff4b7bf-3923-11f1-b1c4-8eb6307b03ec','Dois Irmãos','Milton Hatoum','Companhia das Letras',2000);
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
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES
('1ff3d04e-3923-11f1-b1c4-8eb6307b03ec','Ana Clara Silva','ana.silva@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d1b6-3923-11f1-b1c4-8eb6307b03ec','Bruno Oliveira','bruno.oliveira@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d215-3923-11f1-b1c4-8eb6307b03ec','Carla Mendes','carla.mendes@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d231-3923-11f1-b1c4-8eb6307b03ec','Daniel Souza','daniel.souza@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d24b-3923-11f1-b1c4-8eb6307b03ec','Elena Ferreira','elena.ferreira@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d26a-3923-11f1-b1c4-8eb6307b03ec','Felipe Santos','felipe.santos@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d283-3923-11f1-b1c4-8eb6307b03ec','Gabriela Lima','gabriela.lima@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d299-3923-11f1-b1c4-8eb6307b03ec','Hugo Pereira','hugo.pereira@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d2b2-3923-11f1-b1c4-8eb6307b03ec','Isabela Costa','isabela.costa@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1ff3d2c8-3923-11f1-b1c4-8eb6307b03ec','João Almeida','joao.almeida@email.com','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251');
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

-- Dump completed on 2026-04-15 23:30:44
