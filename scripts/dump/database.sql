-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: biblioteca
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `biblioteca`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `biblioteca` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `biblioteca`;

--
-- Table structure for table `emprestimos`
--

DROP TABLE IF EXISTS `emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emprestimos` (
  `id_emprestimo` char(36) NOT NULL DEFAULT (uuid()),
  `id_livro` char(36) NOT NULL,
  `id_usuario` char(36) NOT NULL,
  `data_saida` date NOT NULL,
  `data_devolucao_prevista` date NOT NULL,
  `data_devolucao_real` date DEFAULT NULL,
  `status` enum('pendente','atrasado','devolvido') NOT NULL DEFAULT 'pendente',
  PRIMARY KEY (`id_emprestimo`),
  KEY `fk_emprestimo_livro` (`id_livro`),
  KEY `fk_emprestimo_usuario` (`id_usuario`),
  CONSTRAINT `fk_emprestimo_livro` FOREIGN KEY (`id_livro`) REFERENCES `livros` (`id_livro`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_emprestimo_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `check_datas` CHECK ((`data_devolucao_prevista` >= `data_saida`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimos`
--

LOCK TABLES `emprestimos` WRITE;
/*!40000 ALTER TABLE `emprestimos` DISABLE KEYS */;
INSERT INTO `emprestimos` VALUES ('5c28197c-6a9f-11f1-8ef9-5602d808ef1b','5c272428-6a9f-11f1-8ef9-5602d808ef1b','5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','2026-01-10','2026-01-24','2026-01-20','devolvido'),('5c281d97-6a9f-11f1-8ef9-5602d808ef1b','5c2725f5-6a9f-11f1-8ef9-5602d808ef1b','5c1c010c-6a9f-11f1-8ef9-5602d808ef1b','2026-01-15','2026-01-29','2026-01-28','devolvido'),('5c281ffc-6a9f-11f1-8ef9-5602d808ef1b','5c27265c-6a9f-11f1-8ef9-5602d808ef1b','5c1d3e54-6a9f-11f1-8ef9-5602d808ef1b','2026-02-01','2026-02-15','2026-02-10','devolvido'),('5c28224f-6a9f-11f1-8ef9-5602d808ef1b','5c2726bf-6a9f-11f1-8ef9-5602d808ef1b','5c1f346e-6a9f-11f1-8ef9-5602d808ef1b','2026-02-05','2026-02-19','2026-02-18','devolvido'),('5c28244f-6a9f-11f1-8ef9-5602d808ef1b','5c2726ef-6a9f-11f1-8ef9-5602d808ef1b','5c201dc6-6a9f-11f1-8ef9-5602d808ef1b','2026-02-10','2026-02-24','2026-02-22','devolvido'),('5c291815-6a9f-11f1-8ef9-5602d808ef1b','5c27271e-6a9f-11f1-8ef9-5602d808ef1b','5c20f2d9-6a9f-11f1-8ef9-5602d808ef1b','2026-01-05','2026-01-19','2026-02-01','devolvido'),('5c291bfe-6a9f-11f1-8ef9-5602d808ef1b','5c272749-6a9f-11f1-8ef9-5602d808ef1b','5c2235c2-6a9f-11f1-8ef9-5602d808ef1b','2026-01-20','2026-02-03','2026-02-15','devolvido'),('5c291dd3-6a9f-11f1-8ef9-5602d808ef1b','5c27277a-6a9f-11f1-8ef9-5602d808ef1b','5c232cd7-6a9f-11f1-8ef9-5602d808ef1b','2026-02-01','2026-02-15','2026-03-01','devolvido'),('5c291f8e-6a9f-11f1-8ef9-5602d808ef1b','5c2727a6-6a9f-11f1-8ef9-5602d808ef1b','5c2416fe-6a9f-11f1-8ef9-5602d808ef1b','2026-02-10','2026-02-24','2026-03-05','devolvido'),('5c29214b-6a9f-11f1-8ef9-5602d808ef1b','5c2727d2-6a9f-11f1-8ef9-5602d808ef1b','5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','2026-02-15','2026-03-01','2026-03-10','devolvido'),('5c2a6553-6a9f-11f1-8ef9-5602d808ef1b','5c272803-6a9f-11f1-8ef9-5602d808ef1b','5c1c010c-6a9f-11f1-8ef9-5602d808ef1b','2026-06-01','2026-06-22',NULL,'pendente'),('5c2a68f7-6a9f-11f1-8ef9-5602d808ef1b','5c27282f-6a9f-11f1-8ef9-5602d808ef1b','5c1d3e54-6a9f-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-24',NULL,'pendente'),('5c2a6acc-6a9f-11f1-8ef9-5602d808ef1b','5c272861-6a9f-11f1-8ef9-5602d808ef1b','5c1e5558-6a9f-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-25',NULL,'pendente'),('5c2a6c86-6a9f-11f1-8ef9-5602d808ef1b','5c27288f-6a9f-11f1-8ef9-5602d808ef1b','5c1f346e-6a9f-11f1-8ef9-5602d808ef1b','2026-06-05','2026-06-26',NULL,'pendente'),('5c2a6e33-6a9f-11f1-8ef9-5602d808ef1b','5c2728bf-6a9f-11f1-8ef9-5602d808ef1b','5c201dc6-6a9f-11f1-8ef9-5602d808ef1b','2026-06-06','2026-06-27',NULL,'pendente'),('5c2a6ffa-6a9f-11f1-8ef9-5602d808ef1b','5c2728ec-6a9f-11f1-8ef9-5602d808ef1b','5c20f2d9-6a9f-11f1-8ef9-5602d808ef1b','2026-06-07','2026-06-28',NULL,'pendente'),('5c2a71ae-6a9f-11f1-8ef9-5602d808ef1b','5c272918-6a9f-11f1-8ef9-5602d808ef1b','5c2235c2-6a9f-11f1-8ef9-5602d808ef1b','2026-06-08','2026-06-29',NULL,'pendente'),('5c2a7367-6a9f-11f1-8ef9-5602d808ef1b','5c272944-6a9f-11f1-8ef9-5602d808ef1b','5c232cd7-6a9f-11f1-8ef9-5602d808ef1b','2026-06-09','2026-06-30',NULL,'pendente'),('5c2a7527-6a9f-11f1-8ef9-5602d808ef1b','5c272970-6a9f-11f1-8ef9-5602d808ef1b','5c2416fe-6a9f-11f1-8ef9-5602d808ef1b','2026-06-10','2026-07-01',NULL,'pendente'),('5c2a76d8-6a9f-11f1-8ef9-5602d808ef1b','5c27299c-6a9f-11f1-8ef9-5602d808ef1b','5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','2026-06-12','2026-07-03',NULL,'pendente'),('5c2b5f53-6a9f-11f1-8ef9-5602d808ef1b','5c2729c9-6a9f-11f1-8ef9-5602d808ef1b','5c1c010c-6a9f-11f1-8ef9-5602d808ef1b','2026-04-15','2026-04-29',NULL,'atrasado'),('5c2b6377-6a9f-11f1-8ef9-5602d808ef1b','5c2729f5-6a9f-11f1-8ef9-5602d808ef1b','5c1d3e54-6a9f-11f1-8ef9-5602d808ef1b','2026-04-18','2026-05-02',NULL,'atrasado'),('5c2b656b-6a9f-11f1-8ef9-5602d808ef1b','5c272a23-6a9f-11f1-8ef9-5602d808ef1b','5c1e5558-6a9f-11f1-8ef9-5602d808ef1b','2026-04-20','2026-05-04',NULL,'atrasado'),('5c2b672e-6a9f-11f1-8ef9-5602d808ef1b','5c272a4f-6a9f-11f1-8ef9-5602d808ef1b','5c1f346e-6a9f-11f1-8ef9-5602d808ef1b','2026-04-22','2026-05-06',NULL,'atrasado'),('5c2b68e7-6a9f-11f1-8ef9-5602d808ef1b','5c272a7b-6a9f-11f1-8ef9-5602d808ef1b','5c201dc6-6a9f-11f1-8ef9-5602d808ef1b','2026-04-24','2026-05-08',NULL,'atrasado'),('5c2b6aab-6a9f-11f1-8ef9-5602d808ef1b','5c272aa6-6a9f-11f1-8ef9-5602d808ef1b','5c20f2d9-6a9f-11f1-8ef9-5602d808ef1b','2026-04-28','2026-05-12',NULL,'atrasado'),('5c2b6c6a-6a9f-11f1-8ef9-5602d808ef1b','5c272ad2-6a9f-11f1-8ef9-5602d808ef1b','5c2235c2-6a9f-11f1-8ef9-5602d808ef1b','2026-05-01','2026-05-15',NULL,'atrasado'),('5c2b6e1a-6a9f-11f1-8ef9-5602d808ef1b','5c272afd-6a9f-11f1-8ef9-5602d808ef1b','5c232cd7-6a9f-11f1-8ef9-5602d808ef1b','2026-05-05','2026-05-19',NULL,'atrasado'),('5c2b6fd4-6a9f-11f1-8ef9-5602d808ef1b','5c272b29-6a9f-11f1-8ef9-5602d808ef1b','5c2416fe-6a9f-11f1-8ef9-5602d808ef1b','2026-05-08','2026-05-22',NULL,'atrasado'),('5c2b719a-6a9f-11f1-8ef9-5602d808ef1b','5c27268d-6a9f-11f1-8ef9-5602d808ef1b','5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','2026-05-12','2026-05-26',NULL,'atrasado'),('5c2c4a9b-6a9f-11f1-8ef9-5602d808ef1b','5c272428-6a9f-11f1-8ef9-5602d808ef1b','5c1e5558-6a9f-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-17',NULL,'pendente'),('5c2c4f73-6a9f-11f1-8ef9-5602d808ef1b','5c2725f5-6a9f-11f1-8ef9-5602d808ef1b','5c1f346e-6a9f-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-18',NULL,'pendente'),('5c2c5168-6a9f-11f1-8ef9-5602d808ef1b','5c27265c-6a9f-11f1-8ef9-5602d808ef1b','5c201dc6-6a9f-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-18',NULL,'pendente'),('5c2c5335-6a9f-11f1-8ef9-5602d808ef1b','5c2726bf-6a9f-11f1-8ef9-5602d808ef1b','5c20f2d9-6a9f-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-17',NULL,'pendente'),('5c2c54fb-6a9f-11f1-8ef9-5602d808ef1b','5c2726ef-6a9f-11f1-8ef9-5602d808ef1b','5c2235c2-6a9f-11f1-8ef9-5602d808ef1b','2026-06-05','2026-06-19',NULL,'pendente'),('5c2d913d-6a9f-11f1-8ef9-5602d808ef1b','5c272a4f-6a9f-11f1-8ef9-5602d808ef1b','5c232cd7-6a9f-11f1-8ef9-5602d808ef1b','2025-12-01','2025-12-15','2025-12-14','devolvido'),('5c2d94af-6a9f-11f1-8ef9-5602d808ef1b','5c272a7b-6a9f-11f1-8ef9-5602d808ef1b','5c2416fe-6a9f-11f1-8ef9-5602d808ef1b','2025-12-05','2025-12-19','2025-12-18','devolvido'),('5c2d9670-6a9f-11f1-8ef9-5602d808ef1b','5c272aa6-6a9f-11f1-8ef9-5602d808ef1b','5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','2025-12-10','2025-12-24','2025-12-23','devolvido'),('5c2d9821-6a9f-11f1-8ef9-5602d808ef1b','5c272ad2-6a9f-11f1-8ef9-5602d808ef1b','5c1c010c-6a9f-11f1-8ef9-5602d808ef1b','2025-12-15','2025-12-29','2025-12-28','devolvido'),('5c2d99d0-6a9f-11f1-8ef9-5602d808ef1b','5c272afd-6a9f-11f1-8ef9-5602d808ef1b','5c1d3e54-6a9f-11f1-8ef9-5602d808ef1b','2025-12-20','2026-01-03','2026-01-02','devolvido');
/*!40000 ALTER TABLE `emprestimos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `livros`
--

DROP TABLE IF EXISTS `livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `livros` (
  `id_livro` char(36) NOT NULL DEFAULT (uuid()),
  `titulo` varchar(255) NOT NULL,
  `autor` varchar(100) NOT NULL,
  `editora` varchar(100) DEFAULT NULL,
  `ano_lancamento` int DEFAULT NULL,
  `preco` decimal(8,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_livro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES ('5c272428-6a9f-11f1-8ef9-5602d808ef1b','Dom Casmurro','Machado de Assis','Garnier',1899,29.90),('5c2725f5-6a9f-11f1-8ef9-5602d808ef1b','Grande SertÃ£o: Veredas','GuimarÃ£es Rosa','JosÃ© Olympio',1956,54.90),('5c27265c-6a9f-11f1-8ef9-5602d808ef1b','MemÃ³rias PÃ³stumas de BrÃ¡s Cubas','Machado de Assis','Tipografia Nacional',1881,24.90),('5c27268d-6a9f-11f1-8ef9-5602d808ef1b','O CortiÃ§o','AluÃ­sio Azevedo','B. L. Garnier',1890,22.50),('5c2726bf-6a9f-11f1-8ef9-5602d808ef1b','CapitÃ£es da Areia','Jorge Amado','JosÃ© Olympio',1937,34.90),('5c2726ef-6a9f-11f1-8ef9-5602d808ef1b','Vidas Secas','Graciliano Ramos','JosÃ© Olympio',1938,27.90),('5c27271e-6a9f-11f1-8ef9-5602d808ef1b','A Hora da Estrela','Clarice Lispector','JosÃ© Olympio',1977,39.90),('5c272749-6a9f-11f1-8ef9-5602d808ef1b','O Alienista','Machado de Assis','Garnier',1882,19.90),('5c27277a-6a9f-11f1-8ef9-5602d808ef1b','Iracema','JosÃ© de Alencar','Tipografia Viana',1865,18.50),('5c2727a6-6a9f-11f1-8ef9-5602d808ef1b','MacunaÃ­ma','MÃ¡rio de Andrade','Oficinas GrÃ¡ficas',1928,32.90),('5c2727d2-6a9f-11f1-8ef9-5602d808ef1b','O Tempo e o Vento','Erico Verissimo','Globo',1949,69.90),('5c272803-6a9f-11f1-8ef9-5602d808ef1b','Quincas Borba','Machado de Assis','Garnier',1891,26.90),('5c27282f-6a9f-11f1-8ef9-5602d808ef1b','Menino de Engenho','JosÃ© Lins do Rego','JosÃ© Olympio',1932,28.50),('5c272861-6a9f-11f1-8ef9-5602d808ef1b','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,42.90),('5c27288f-6a9f-11f1-8ef9-5602d808ef1b','SÃ£o Bernardo','Graciliano Ramos','Ariel',1934,31.00),('5c2728bf-6a9f-11f1-8ef9-5602d808ef1b','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,17.90),('5c2728ec-6a9f-11f1-8ef9-5602d808ef1b','O Guarani','JosÃ© de Alencar','Empresa Nacional',1857,21.50),('5c272918-6a9f-11f1-8ef9-5602d808ef1b','Clara dos Anjos','Lima Barreto','MÃ©rito',1948,23.90),('5c272944-6a9f-11f1-8ef9-5602d808ef1b','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,25.90),('5c272970-6a9f-11f1-8ef9-5602d808ef1b','A PaixÃ£o Segundo G.H.','Clarice Lispector','Editora do Autor',1964,44.90),('5c27299c-6a9f-11f1-8ef9-5602d808ef1b','Lavoura Arcaica','Raduan Nassar','JosÃ© Olympio',1975,48.50),('5c2729c9-6a9f-11f1-8ef9-5602d808ef1b','AngÃºstia','Graciliano Ramos','JosÃ© Olympio',1936,29.00),('5c2729f5-6a9f-11f1-8ef9-5602d808ef1b','MemÃ³rias de um Sargento de MilÃ­cias','Manuel AntÃ´nio de Almeida','Tipografia Nacional',1854,20.90),('5c272a23-6a9f-11f1-8ef9-5602d808ef1b','O Quinze','Rachel de Queiroz','Editora Olympio',1930,26.50),('5c272a4f-6a9f-11f1-8ef9-5602d808ef1b','Sagarana','GuimarÃ£es Rosa','Universal',1946,37.90),('5c272a7b-6a9f-11f1-8ef9-5602d808ef1b','Fogo Morto','JosÃ© Lins do Rego','JosÃ© Olympio',1943,33.50),('5c272aa6-6a9f-11f1-8ef9-5602d808ef1b','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,45.90),('5c272ad2-6a9f-11f1-8ef9-5602d808ef1b','Olhai os LÃ­rios do Campo','Erico Verissimo','Globo',1938,35.90),('5c272afd-6a9f-11f1-8ef9-5602d808ef1b','Noite na Taverna','Ãlvares de Azevedo','Garnier',1855,16.90),('5c272b29-6a9f-11f1-8ef9-5602d808ef1b','Dois IrmÃ£os','Milton Hatoum','Companhia das Letras',2000,52.90);
/*!40000 ALTER TABLE `livros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` char(36) NOT NULL DEFAULT (uuid()),
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(64) NOT NULL,
  `salt` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES ('5c1b1c69-6a9f-11f1-8ef9-5602d808ef1b','Ana Clara Silva','ana.silva@email.com','5c2b32c96625aadd7138ea8edd479079782a979df76dbee0873f2d6c5cdf7a96','a12b61758d83ffa773ff9268117c8222400373976f66e556fb1096bd62ea7786','2026-06-17 22:53:30'),('5c1c010c-6a9f-11f1-8ef9-5602d808ef1b','Bruno Oliveira','bruno.oliveira@email.com','4c9115c136a26aa51778a93fb89d28a894186fc2d00423594b030e215f873fa8','187fa3e3d655ff848740addc26fb24816fbea7ea4bc0b4347debfdbd10041037','2026-06-17 22:53:30'),('5c1d3e54-6a9f-11f1-8ef9-5602d808ef1b','Carla Mendes','carla.mendes@email.com','8ea98d292e501793ea1e6ea8fdad7c9035558ce65fef5b266cdbcea74071a586','d5cbe920a74df44f62d78ef87c222764438c8626b309497b1c3c944115e5082d','2026-06-17 22:53:30'),('5c1e5558-6a9f-11f1-8ef9-5602d808ef1b','Daniel Souza','daniel.souza@email.com','ff724c7ddcb01f1a67c3c83736348ae04923270684188585b7e57c450b143a65','a8bebbb3359d392f9b6247e9f5fa8d3b1b7144bacf139b08dcefe54a945a830c','2026-06-17 22:53:30'),('5c1f346e-6a9f-11f1-8ef9-5602d808ef1b','Elena Ferreira','elena.ferreira@email.com','c19bd3e8d070f604968c9355163c4bf6d4b2792d3c633005f205b2093b20884b','67e87de67e32162230e54facc8a91fff6437f8fa7377695fb4dcf8cbac5c1961','2026-06-17 22:53:30'),('5c201dc6-6a9f-11f1-8ef9-5602d808ef1b','Felipe Santos','felipe.santos@email.com','930e1cf2fbfdcfb4a327885f424b45a88815263ed57f8a03a87e8886100b8c1d','6433e4b6acdeed4edc9e7accd97a7cc45757dd37003f219a6f88d348619eda70','2026-06-17 22:53:30'),('5c20f2d9-6a9f-11f1-8ef9-5602d808ef1b','Gabriela Lima','gabriela.lima@email.com','ea177cdf00b115b4d85b799d5cde9481b565c26f220f322aab77bdb027b1be14','364447a1f005596d72b66514d52ab5ed568f6b8e201577579a33a2dd01ab2f6d','2026-06-17 22:53:30'),('5c2235c2-6a9f-11f1-8ef9-5602d808ef1b','Hugo Pereira','hugo.pereira@email.com','f57050d6db1463e4fcb7010b76859c66c9e99926a335a2cd22c48bda35d2fff3','ec7c36d9345a351d2a6b6cd73265c89735d5017dd134eb74e27cd094139910ad','2026-06-17 22:53:30'),('5c232cd7-6a9f-11f1-8ef9-5602d808ef1b','Isabela Costa','isabela.costa@email.com','d286d02f9842210914a50bf804a92e23d32a9067d001cc80faaa7c20d973a86e','17f607438dc7a7f394105da64a2640587424fbce187a041b862a938adca41f70','2026-06-17 22:53:30'),('5c2416fe-6a9f-11f1-8ef9-5602d808ef1b','JoÃ£o Almeida','joao.almeida@email.com','74afa66c15ebbc57ae0c104a26598bc15be88e45c5bfec0565bcfd4159f4aac5','9663016701e2fd288b4bb7a929f609fb1fc37d619882389cbb99ad3d8e191ba9','2026-06-17 22:53:30'),('5c24fc43-6a9f-11f1-8ef9-5602d808ef1b','Rafael Nascimento','rafael.nascimento@email.com','170a80bf9f544e6e127bc52ee9be513b727ee10ca699607eb5962d03884c753b','5325a709199dec27a59658befa593f87f0c86baafe0d07adb55e73fb032cba8b','2026-06-17 22:53:30'),('5c25d3ae-6a9f-11f1-8ef9-5602d808ef1b','Sofia Cardoso','sofia.cardoso@email.com','4ec902523c8f868e9e618f4cd964651f8630902ea7e0293208334643477d504c','2dde3f189141d06328f84012c1606cb2a644b103b30debe27ec63c689adfa1a0','2026-06-17 22:53:30');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'biblioteca'
--
/*!50003 DROP PROCEDURE IF EXISTS `cadastrar_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `cadastrar_usuario`(
    IN p_nome  VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_senha VARCHAR(255)
)
BEGIN
    DECLARE v_id         CHAR(36);
    DECLARE v_now        TIMESTAMP;
    DECLARE v_salt       VARCHAR(64);
    DECLARE v_senha_hash VARCHAR(64);

    SET v_id  = UUID();
    SET v_now = NOW();

    
    SET v_salt = SHA2(CONCAT(v_id, v_now), 256);

    
    SET v_senha_hash = SHA2(
                           SHA2(
                               SHA2(CONCAT(p_senha, v_salt), 256),
                           256),
                       256);

    INSERT INTO usuarios (id_usuario, nome, email, senha, salt, created_at)
    VALUES (v_id, p_nome, p_email, v_senha_hash, v_salt, v_now);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-17 22:53:30
