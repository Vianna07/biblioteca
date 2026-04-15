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
('1c843f7d-3921-11f1-9245-c227c1f33aaa','1c83467e-3921-11f1-9245-c227c1f33aaa','1c825021-3921-11f1-9245-c227c1f33aaa','2026-01-10','2026-01-24','2026-01-20','devolvido'),
('1c8440ca-3921-11f1-9245-c227c1f33aaa','1c8347f1-3921-11f1-9245-c227c1f33aaa','1c825192-3921-11f1-9245-c227c1f33aaa','2026-01-15','2026-01-29','2026-01-28','devolvido'),
('1c844133-3921-11f1-9245-c227c1f33aaa','1c834857-3921-11f1-9245-c227c1f33aaa','1c8251fc-3921-11f1-9245-c227c1f33aaa','2026-02-01','2026-02-15','2026-02-10','devolvido'),
('1c84415d-3921-11f1-9245-c227c1f33aaa','1c83488d-3921-11f1-9245-c227c1f33aaa','1c825238-3921-11f1-9245-c227c1f33aaa','2026-02-05','2026-02-19','2026-02-18','devolvido'),
('1c844187-3921-11f1-9245-c227c1f33aaa','1c8348a5-3921-11f1-9245-c227c1f33aaa','1c825259-3921-11f1-9245-c227c1f33aaa','2026-02-10','2026-02-24','2026-02-22','devolvido'),
('1c84bfc2-3921-11f1-9245-c227c1f33aaa','1c8348bb-3921-11f1-9245-c227c1f33aaa','1c825274-3921-11f1-9245-c227c1f33aaa','2026-01-05','2026-01-19','2026-02-01','devolvido'),
('1c84c126-3921-11f1-9245-c227c1f33aaa','1c8348ce-3921-11f1-9245-c227c1f33aaa','1c82528d-3921-11f1-9245-c227c1f33aaa','2026-01-20','2026-02-03','2026-02-15','devolvido'),
('1c84c152-3921-11f1-9245-c227c1f33aaa','1c8348e4-3921-11f1-9245-c227c1f33aaa','1c8252a9-3921-11f1-9245-c227c1f33aaa','2026-02-01','2026-02-15','2026-03-01','devolvido'),
('1c84c17d-3921-11f1-9245-c227c1f33aaa','1c8348f7-3921-11f1-9245-c227c1f33aaa','1c8252c2-3921-11f1-9245-c227c1f33aaa','2026-02-10','2026-02-24','2026-03-05','devolvido'),
('1c84c1a3-3921-11f1-9245-c227c1f33aaa','1c83490c-3921-11f1-9245-c227c1f33aaa','1c825021-3921-11f1-9245-c227c1f33aaa','2026-02-15','2026-03-01','2026-03-10','devolvido'),
('1c856fcc-3921-11f1-9245-c227c1f33aaa','1c834920-3921-11f1-9245-c227c1f33aaa','1c825192-3921-11f1-9245-c227c1f33aaa','2026-04-10','2026-04-24',NULL,'pendente'),
('1c857291-3921-11f1-9245-c227c1f33aaa','1c834934-3921-11f1-9245-c227c1f33aaa','1c8251fc-3921-11f1-9245-c227c1f33aaa','2026-04-08','2026-04-22',NULL,'pendente'),
('1c8572ec-3921-11f1-9245-c227c1f33aaa','1c834946-3921-11f1-9245-c227c1f33aaa','1c82521a-3921-11f1-9245-c227c1f33aaa','2026-04-05','2026-04-19',NULL,'pendente'),
('1c85733e-3921-11f1-9245-c227c1f33aaa','1c83495c-3921-11f1-9245-c227c1f33aaa','1c825238-3921-11f1-9245-c227c1f33aaa','2026-04-12','2026-04-26',NULL,'pendente'),
('1c85738e-3921-11f1-9245-c227c1f33aaa','1c834970-3921-11f1-9245-c227c1f33aaa','1c825259-3921-11f1-9245-c227c1f33aaa','2026-04-11','2026-04-25',NULL,'pendente'),
('1c8573d2-3921-11f1-9245-c227c1f33aaa','1c834983-3921-11f1-9245-c227c1f33aaa','1c825274-3921-11f1-9245-c227c1f33aaa','2026-04-09','2026-04-23',NULL,'pendente'),
('1c85741b-3921-11f1-9245-c227c1f33aaa','1c834997-3921-11f1-9245-c227c1f33aaa','1c82528d-3921-11f1-9245-c227c1f33aaa','2026-04-13','2026-04-27',NULL,'pendente'),
('1c857462-3921-11f1-9245-c227c1f33aaa','1c8349ab-3921-11f1-9245-c227c1f33aaa','1c8252a9-3921-11f1-9245-c227c1f33aaa','2026-04-07','2026-04-21',NULL,'pendente'),
('1c8574b5-3921-11f1-9245-c227c1f33aaa','1c8349c3-3921-11f1-9245-c227c1f33aaa','1c8252c2-3921-11f1-9245-c227c1f33aaa','2026-04-14','2026-04-28',NULL,'pendente'),
('1c857503-3921-11f1-9245-c227c1f33aaa','1c8349ee-3921-11f1-9245-c227c1f33aaa','1c825021-3921-11f1-9245-c227c1f33aaa','2026-04-06','2026-04-20',NULL,'pendente'),
('1c860d6a-3921-11f1-9245-c227c1f33aaa','1c834a49-3921-11f1-9245-c227c1f33aaa','1c825192-3921-11f1-9245-c227c1f33aaa','2026-03-01','2026-03-15',NULL,'atrasado'),
('1c860fab-3921-11f1-9245-c227c1f33aaa','1c834a5f-3921-11f1-9245-c227c1f33aaa','1c8251fc-3921-11f1-9245-c227c1f33aaa','2026-03-05','2026-03-19',NULL,'atrasado'),
('1c860fd8-3921-11f1-9245-c227c1f33aaa','1c834a74-3921-11f1-9245-c227c1f33aaa','1c82521a-3921-11f1-9245-c227c1f33aaa','2026-03-10','2026-03-24',NULL,'atrasado'),
('1c861005-3921-11f1-9245-c227c1f33aaa','1c834a8a-3921-11f1-9245-c227c1f33aaa','1c825238-3921-11f1-9245-c227c1f33aaa','2026-03-02','2026-03-16',NULL,'atrasado'),
('1c861035-3921-11f1-9245-c227c1f33aaa','1c834aa0-3921-11f1-9245-c227c1f33aaa','1c825259-3921-11f1-9245-c227c1f33aaa','2026-03-08','2026-03-22',NULL,'atrasado'),
('1c86105c-3921-11f1-9245-c227c1f33aaa','1c834ab3-3921-11f1-9245-c227c1f33aaa','1c825274-3921-11f1-9245-c227c1f33aaa','2026-03-12','2026-03-26',NULL,'atrasado'),
('1c861084-3921-11f1-9245-c227c1f33aaa','1c834ac6-3921-11f1-9245-c227c1f33aaa','1c82528d-3921-11f1-9245-c227c1f33aaa','2026-03-03','2026-03-17',NULL,'atrasado'),
('1c8610ab-3921-11f1-9245-c227c1f33aaa','1c834ad9-3921-11f1-9245-c227c1f33aaa','1c8252a9-3921-11f1-9245-c227c1f33aaa','2026-03-07','2026-03-21',NULL,'atrasado'),
('1c8610d3-3921-11f1-9245-c227c1f33aaa','1c834aee-3921-11f1-9245-c227c1f33aaa','1c8252c2-3921-11f1-9245-c227c1f33aaa','2026-03-15','2026-03-29',NULL,'atrasado'),
('1c8610fb-3921-11f1-9245-c227c1f33aaa','1c834874-3921-11f1-9245-c227c1f33aaa','1c825021-3921-11f1-9245-c227c1f33aaa','2026-03-20','2026-04-03',NULL,'atrasado'),
('1c86a60f-3921-11f1-9245-c227c1f33aaa','1c83467e-3921-11f1-9245-c227c1f33aaa','1c82521a-3921-11f1-9245-c227c1f33aaa','2026-04-01','2026-04-16',NULL,'pendente'),
('1c86a770-3921-11f1-9245-c227c1f33aaa','1c8347f1-3921-11f1-9245-c227c1f33aaa','1c825238-3921-11f1-9245-c227c1f33aaa','2026-04-02','2026-04-17',NULL,'pendente'),
('1c86a7a0-3921-11f1-9245-c227c1f33aaa','1c834857-3921-11f1-9245-c227c1f33aaa','1c825259-3921-11f1-9245-c227c1f33aaa','2026-04-03','2026-04-16',NULL,'pendente'),
('1c86a7cb-3921-11f1-9245-c227c1f33aaa','1c83488d-3921-11f1-9245-c227c1f33aaa','1c825274-3921-11f1-9245-c227c1f33aaa','2026-04-01','2026-04-15',NULL,'pendente'),
('1c86a7fc-3921-11f1-9245-c227c1f33aaa','1c8348a5-3921-11f1-9245-c227c1f33aaa','1c82528d-3921-11f1-9245-c227c1f33aaa','2026-04-02','2026-04-18',NULL,'pendente'),
('1c8726cb-3921-11f1-9245-c227c1f33aaa','1c834a8a-3921-11f1-9245-c227c1f33aaa','1c8252a9-3921-11f1-9245-c227c1f33aaa','2025-12-01','2025-12-15','2025-12-14','devolvido'),
('1c872824-3921-11f1-9245-c227c1f33aaa','1c834aa0-3921-11f1-9245-c227c1f33aaa','1c8252c2-3921-11f1-9245-c227c1f33aaa','2025-12-05','2025-12-19','2025-12-18','devolvido'),
('1c872858-3921-11f1-9245-c227c1f33aaa','1c834ab3-3921-11f1-9245-c227c1f33aaa','1c825021-3921-11f1-9245-c227c1f33aaa','2025-12-10','2025-12-24','2025-12-23','devolvido'),
('1c872884-3921-11f1-9245-c227c1f33aaa','1c834ac6-3921-11f1-9245-c227c1f33aaa','1c825192-3921-11f1-9245-c227c1f33aaa','2025-12-15','2025-12-29','2025-12-28','devolvido'),
('1c8728b5-3921-11f1-9245-c227c1f33aaa','1c834ad9-3921-11f1-9245-c227c1f33aaa','1c8251fc-3921-11f1-9245-c227c1f33aaa','2025-12-20','2026-01-03','2026-01-02','devolvido');
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
('1c83467e-3921-11f1-9245-c227c1f33aaa','Dom Casmurro','Machado de Assis','Garnier',1899,'978-85-7232-001-1'),
('1c8347f1-3921-11f1-9245-c227c1f33aaa','Grande Sertão: Veredas','Guimarães Rosa','José Olympio',1956,'978-85-7232-002-8'),
('1c834857-3921-11f1-9245-c227c1f33aaa','Memórias Póstumas de Brás Cubas','Machado de Assis','Tipografia Nacional',1881,'978-85-7232-003-5'),
('1c834874-3921-11f1-9245-c227c1f33aaa','O Cortiço','Aluísio Azevedo','B. L. Garnier',1890,'978-85-7232-004-2'),
('1c83488d-3921-11f1-9245-c227c1f33aaa','Capitães da Areia','Jorge Amado','José Olympio',1937,'978-85-7232-005-9'),
('1c8348a5-3921-11f1-9245-c227c1f33aaa','Vidas Secas','Graciliano Ramos','José Olympio',1938,'978-85-7232-006-6'),
('1c8348bb-3921-11f1-9245-c227c1f33aaa','A Hora da Estrela','Clarice Lispector','José Olympio',1977,'978-85-7232-007-3'),
('1c8348ce-3921-11f1-9245-c227c1f33aaa','O Alienista','Machado de Assis','Garnier',1882,'978-85-7232-008-0'),
('1c8348e4-3921-11f1-9245-c227c1f33aaa','Iracema','José de Alencar','Tipografia Viana',1865,'978-85-7232-009-7'),
('1c8348f7-3921-11f1-9245-c227c1f33aaa','Macunaíma','Mário de Andrade','Oficinas Gráficas',1928,'978-85-7232-010-3'),
('1c83490c-3921-11f1-9245-c227c1f33aaa','O Tempo e o Vento','Erico Verissimo','Globo',1949,'978-85-7232-011-0'),
('1c834920-3921-11f1-9245-c227c1f33aaa','Quincas Borba','Machado de Assis','Garnier',1891,'978-85-7232-012-7'),
('1c834934-3921-11f1-9245-c227c1f33aaa','Menino de Engenho','José Lins do Rego','José Olympio',1932,'978-85-7232-013-4'),
('1c834946-3921-11f1-9245-c227c1f33aaa','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,'978-85-7232-014-1'),
('1c83495c-3921-11f1-9245-c227c1f33aaa','São Bernardo','Graciliano Ramos','Ariel',1934,'978-85-7232-015-8'),
('1c834970-3921-11f1-9245-c227c1f33aaa','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,'978-85-7232-016-5'),
('1c834983-3921-11f1-9245-c227c1f33aaa','O Guarani','José de Alencar','Empresa Nacional',1857,'978-85-7232-017-2'),
('1c834997-3921-11f1-9245-c227c1f33aaa','Clara dos Anjos','Lima Barreto','Mérito',1948,'978-85-7232-018-9'),
('1c8349ab-3921-11f1-9245-c227c1f33aaa','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,'978-85-7232-019-6'),
('1c8349c3-3921-11f1-9245-c227c1f33aaa','A Paixão Segundo G.H.','Clarice Lispector','Editora do Autor',1964,'978-85-7232-020-2'),
('1c8349ee-3921-11f1-9245-c227c1f33aaa','Lavoura Arcaica','Raduan Nassar','José Olympio',1975,'978-85-7232-021-9'),
('1c834a49-3921-11f1-9245-c227c1f33aaa','Angústia','Graciliano Ramos','José Olympio',1936,'978-85-7232-022-6'),
('1c834a5f-3921-11f1-9245-c227c1f33aaa','Memórias de um Sargento de Milícias','Manuel Antônio de Almeida','Tipografia Nacional',1854,'978-85-7232-023-3'),
('1c834a74-3921-11f1-9245-c227c1f33aaa','O Quinze','Rachel de Queiroz','Editora Olympio',1930,'978-85-7232-024-0'),
('1c834a8a-3921-11f1-9245-c227c1f33aaa','Sagarana','Guimarães Rosa','Universal',1946,'978-85-7232-025-7'),
('1c834aa0-3921-11f1-9245-c227c1f33aaa','Fogo Morto','José Lins do Rego','José Olympio',1943,'978-85-7232-026-4'),
('1c834ab3-3921-11f1-9245-c227c1f33aaa','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,'978-85-7232-027-1'),
('1c834ac6-3921-11f1-9245-c227c1f33aaa','Olhai os Lírios do Campo','Erico Verissimo','Globo',1938,'978-85-7232-028-8'),
('1c834ad9-3921-11f1-9245-c227c1f33aaa','Noite na Taverna','Álvares de Azevedo','Garnier',1855,'978-85-7232-029-5'),
('1c834aee-3921-11f1-9245-c227c1f33aaa','Dois Irmãos','Milton Hatoum','Companhia das Letras',2000,'978-85-7232-030-1');
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
('1c825021-3921-11f1-9245-c227c1f33aaa','Ana Clara Silva','ana.silva','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c825192-3921-11f1-9245-c227c1f33aaa','Bruno Oliveira','bruno.oliveira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c8251fc-3921-11f1-9245-c227c1f33aaa','Carla Mendes','carla.mendes','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c82521a-3921-11f1-9245-c227c1f33aaa','Daniel Souza','daniel.souza','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c825238-3921-11f1-9245-c227c1f33aaa','Elena Ferreira','elena.ferreira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c825259-3921-11f1-9245-c227c1f33aaa','Felipe Santos','felipe.santos','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c825274-3921-11f1-9245-c227c1f33aaa','Gabriela Lima','gabriela.lima','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c82528d-3921-11f1-9245-c227c1f33aaa','Hugo Pereira','hugo.pereira','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c8252a9-3921-11f1-9245-c227c1f33aaa','Isabela Costa','isabela.costa','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'),
('1c8252c2-3921-11f1-9245-c227c1f33aaa','João Almeida','joao.almeida','55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251');
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

-- Dump completed on 2026-04-15 23:17:39
