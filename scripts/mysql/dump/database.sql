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
INSERT INTO `emprestimos` VALUES ('3352b3a0-6a9e-11f1-8ef9-5602d808ef1b','3351b96f-6a9e-11f1-8ef9-5602d808ef1b','33458fc3-6a9e-11f1-8ef9-5602d808ef1b','2026-01-10','2026-01-24','2026-01-20','devolvido'),('3352b81d-6a9e-11f1-8ef9-5602d808ef1b','3351bb91-6a9e-11f1-8ef9-5602d808ef1b','334678c6-6a9e-11f1-8ef9-5602d808ef1b','2026-01-15','2026-01-29','2026-01-28','devolvido'),('3352bada-6a9e-11f1-8ef9-5602d808ef1b','3351bc13-6a9e-11f1-8ef9-5602d808ef1b','3347645a-6a9e-11f1-8ef9-5602d808ef1b','2026-02-01','2026-02-15','2026-02-10','devolvido'),('3352bd86-6a9e-11f1-8ef9-5602d808ef1b','3351bc88-6a9e-11f1-8ef9-5602d808ef1b','3349c77f-6a9e-11f1-8ef9-5602d808ef1b','2026-02-05','2026-02-19','2026-02-18','devolvido'),('3352c015-6a9e-11f1-8ef9-5602d808ef1b','3351bcc3-6a9e-11f1-8ef9-5602d808ef1b','334a9b76-6a9e-11f1-8ef9-5602d808ef1b','2026-02-10','2026-02-24','2026-02-22','devolvido'),('3353fb89-6a9e-11f1-8ef9-5602d808ef1b','3351bcfa-6a9e-11f1-8ef9-5602d808ef1b','334bd88a-6a9e-11f1-8ef9-5602d808ef1b','2026-01-05','2026-01-19','2026-02-01','devolvido'),('3353ffbf-6a9e-11f1-8ef9-5602d808ef1b','3351bd2f-6a9e-11f1-8ef9-5602d808ef1b','334cac68-6a9e-11f1-8ef9-5602d808ef1b','2026-01-20','2026-02-03','2026-02-15','devolvido'),('3354021f-6a9e-11f1-8ef9-5602d808ef1b','3351bd68-6a9e-11f1-8ef9-5602d808ef1b','334dda2e-6a9e-11f1-8ef9-5602d808ef1b','2026-02-01','2026-02-15','2026-03-01','devolvido'),('33540551-6a9e-11f1-8ef9-5602d808ef1b','3351bd9c-6a9e-11f1-8ef9-5602d808ef1b','334eb5f7-6a9e-11f1-8ef9-5602d808ef1b','2026-02-10','2026-02-24','2026-03-05','devolvido'),('3354084a-6a9e-11f1-8ef9-5602d808ef1b','3351bdd0-6a9e-11f1-8ef9-5602d808ef1b','33458fc3-6a9e-11f1-8ef9-5602d808ef1b','2026-02-15','2026-03-01','2026-03-10','devolvido'),('3354f2e4-6a9e-11f1-8ef9-5602d808ef1b','3351be10-6a9e-11f1-8ef9-5602d808ef1b','334678c6-6a9e-11f1-8ef9-5602d808ef1b','2026-06-01','2026-06-22',NULL,'pendente'),('3354f720-6a9e-11f1-8ef9-5602d808ef1b','3351be47-6a9e-11f1-8ef9-5602d808ef1b','3347645a-6a9e-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-24',NULL,'pendente'),('3354f92c-6a9e-11f1-8ef9-5602d808ef1b','3351be7d-6a9e-11f1-8ef9-5602d808ef1b','33489cc7-6a9e-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-25',NULL,'pendente'),('3354fb35-6a9e-11f1-8ef9-5602d808ef1b','3351beb2-6a9e-11f1-8ef9-5602d808ef1b','3349c77f-6a9e-11f1-8ef9-5602d808ef1b','2026-06-05','2026-06-26',NULL,'pendente'),('3354fd26-6a9e-11f1-8ef9-5602d808ef1b','3351bee5-6a9e-11f1-8ef9-5602d808ef1b','334a9b76-6a9e-11f1-8ef9-5602d808ef1b','2026-06-06','2026-06-27',NULL,'pendente'),('3354ff44-6a9e-11f1-8ef9-5602d808ef1b','3351bf19-6a9e-11f1-8ef9-5602d808ef1b','334bd88a-6a9e-11f1-8ef9-5602d808ef1b','2026-06-07','2026-06-28',NULL,'pendente'),('33550174-6a9e-11f1-8ef9-5602d808ef1b','3351bf4f-6a9e-11f1-8ef9-5602d808ef1b','334cac68-6a9e-11f1-8ef9-5602d808ef1b','2026-06-08','2026-06-29',NULL,'pendente'),('3355038a-6a9e-11f1-8ef9-5602d808ef1b','3351bf85-6a9e-11f1-8ef9-5602d808ef1b','334dda2e-6a9e-11f1-8ef9-5602d808ef1b','2026-06-09','2026-06-30',NULL,'pendente'),('33550596-6a9e-11f1-8ef9-5602d808ef1b','3351bfb9-6a9e-11f1-8ef9-5602d808ef1b','334eb5f7-6a9e-11f1-8ef9-5602d808ef1b','2026-06-10','2026-07-01',NULL,'pendente'),('335507aa-6a9e-11f1-8ef9-5602d808ef1b','3351bfeb-6a9e-11f1-8ef9-5602d808ef1b','33458fc3-6a9e-11f1-8ef9-5602d808ef1b','2026-06-12','2026-07-03',NULL,'pendente'),('3355f156-6a9e-11f1-8ef9-5602d808ef1b','3351c020-6a9e-11f1-8ef9-5602d808ef1b','334678c6-6a9e-11f1-8ef9-5602d808ef1b','2026-04-15','2026-04-29',NULL,'atrasado'),('3355f5b1-6a9e-11f1-8ef9-5602d808ef1b','3351c054-6a9e-11f1-8ef9-5602d808ef1b','3347645a-6a9e-11f1-8ef9-5602d808ef1b','2026-04-18','2026-05-02',NULL,'atrasado'),('3355f7a2-6a9e-11f1-8ef9-5602d808ef1b','3351c089-6a9e-11f1-8ef9-5602d808ef1b','33489cc7-6a9e-11f1-8ef9-5602d808ef1b','2026-04-20','2026-05-04',NULL,'atrasado'),('3355f94d-6a9e-11f1-8ef9-5602d808ef1b','3351c0bb-6a9e-11f1-8ef9-5602d808ef1b','3349c77f-6a9e-11f1-8ef9-5602d808ef1b','2026-04-22','2026-05-06',NULL,'atrasado'),('3355faf7-6a9e-11f1-8ef9-5602d808ef1b','3351c0ee-6a9e-11f1-8ef9-5602d808ef1b','334a9b76-6a9e-11f1-8ef9-5602d808ef1b','2026-04-24','2026-05-08',NULL,'atrasado'),('3355fc9c-6a9e-11f1-8ef9-5602d808ef1b','3351c121-6a9e-11f1-8ef9-5602d808ef1b','334bd88a-6a9e-11f1-8ef9-5602d808ef1b','2026-04-28','2026-05-12',NULL,'atrasado'),('3355fe4b-6a9e-11f1-8ef9-5602d808ef1b','3351c153-6a9e-11f1-8ef9-5602d808ef1b','334cac68-6a9e-11f1-8ef9-5602d808ef1b','2026-05-01','2026-05-15',NULL,'atrasado'),('3355fff3-6a9e-11f1-8ef9-5602d808ef1b','3351c186-6a9e-11f1-8ef9-5602d808ef1b','334dda2e-6a9e-11f1-8ef9-5602d808ef1b','2026-05-05','2026-05-19',NULL,'atrasado'),('335602f4-6a9e-11f1-8ef9-5602d808ef1b','3351c1b9-6a9e-11f1-8ef9-5602d808ef1b','334eb5f7-6a9e-11f1-8ef9-5602d808ef1b','2026-05-08','2026-05-22',NULL,'atrasado'),('335604b9-6a9e-11f1-8ef9-5602d808ef1b','3351bc4f-6a9e-11f1-8ef9-5602d808ef1b','33458fc3-6a9e-11f1-8ef9-5602d808ef1b','2026-05-12','2026-05-26',NULL,'atrasado'),('3356e9fd-6a9e-11f1-8ef9-5602d808ef1b','3351b96f-6a9e-11f1-8ef9-5602d808ef1b','33489cc7-6a9e-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-17',NULL,'pendente'),('3356ee5c-6a9e-11f1-8ef9-5602d808ef1b','3351bb91-6a9e-11f1-8ef9-5602d808ef1b','3349c77f-6a9e-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-18',NULL,'pendente'),('3356f03f-6a9e-11f1-8ef9-5602d808ef1b','3351bc13-6a9e-11f1-8ef9-5602d808ef1b','334a9b76-6a9e-11f1-8ef9-5602d808ef1b','2026-06-04','2026-06-18',NULL,'pendente'),('3356f208-6a9e-11f1-8ef9-5602d808ef1b','3351bc88-6a9e-11f1-8ef9-5602d808ef1b','334bd88a-6a9e-11f1-8ef9-5602d808ef1b','2026-06-03','2026-06-17',NULL,'pendente'),('3356f40d-6a9e-11f1-8ef9-5602d808ef1b','3351bcc3-6a9e-11f1-8ef9-5602d808ef1b','334cac68-6a9e-11f1-8ef9-5602d808ef1b','2026-06-05','2026-06-19',NULL,'pendente'),('3357cf48-6a9e-11f1-8ef9-5602d808ef1b','3351c0bb-6a9e-11f1-8ef9-5602d808ef1b','334dda2e-6a9e-11f1-8ef9-5602d808ef1b','2025-12-01','2025-12-15','2025-12-14','devolvido'),('3357d273-6a9e-11f1-8ef9-5602d808ef1b','3351c0ee-6a9e-11f1-8ef9-5602d808ef1b','334eb5f7-6a9e-11f1-8ef9-5602d808ef1b','2025-12-05','2025-12-19','2025-12-18','devolvido'),('3357d443-6a9e-11f1-8ef9-5602d808ef1b','3351c121-6a9e-11f1-8ef9-5602d808ef1b','33458fc3-6a9e-11f1-8ef9-5602d808ef1b','2025-12-10','2025-12-24','2025-12-23','devolvido'),('3357d65c-6a9e-11f1-8ef9-5602d808ef1b','3351c153-6a9e-11f1-8ef9-5602d808ef1b','334678c6-6a9e-11f1-8ef9-5602d808ef1b','2025-12-15','2025-12-29','2025-12-28','devolvido'),('3357d828-6a9e-11f1-8ef9-5602d808ef1b','3351c186-6a9e-11f1-8ef9-5602d808ef1b','3347645a-6a9e-11f1-8ef9-5602d808ef1b','2025-12-20','2026-01-03','2026-01-02','devolvido');
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
INSERT INTO `livros` VALUES ('3351b96f-6a9e-11f1-8ef9-5602d808ef1b','Dom Casmurro','Machado de Assis','Garnier',1899,29.90),('3351bb91-6a9e-11f1-8ef9-5602d808ef1b','Grande SertÃ£o: Veredas','GuimarÃ£es Rosa','JosÃ© Olympio',1956,54.90),('3351bc13-6a9e-11f1-8ef9-5602d808ef1b','MemÃ³rias PÃ³stumas de BrÃ¡s Cubas','Machado de Assis','Tipografia Nacional',1881,24.90),('3351bc4f-6a9e-11f1-8ef9-5602d808ef1b','O CortiÃ§o','AluÃ­sio Azevedo','B. L. Garnier',1890,22.50),('3351bc88-6a9e-11f1-8ef9-5602d808ef1b','CapitÃ£es da Areia','Jorge Amado','JosÃ© Olympio',1937,34.90),('3351bcc3-6a9e-11f1-8ef9-5602d808ef1b','Vidas Secas','Graciliano Ramos','JosÃ© Olympio',1938,27.90),('3351bcfa-6a9e-11f1-8ef9-5602d808ef1b','A Hora da Estrela','Clarice Lispector','JosÃ© Olympio',1977,39.90),('3351bd2f-6a9e-11f1-8ef9-5602d808ef1b','O Alienista','Machado de Assis','Garnier',1882,19.90),('3351bd68-6a9e-11f1-8ef9-5602d808ef1b','Iracema','JosÃ© de Alencar','Tipografia Viana',1865,18.50),('3351bd9c-6a9e-11f1-8ef9-5602d808ef1b','MacunaÃ­ma','MÃ¡rio de Andrade','Oficinas GrÃ¡ficas',1928,32.90),('3351bdd0-6a9e-11f1-8ef9-5602d808ef1b','O Tempo e o Vento','Erico Verissimo','Globo',1949,69.90),('3351be10-6a9e-11f1-8ef9-5602d808ef1b','Quincas Borba','Machado de Assis','Garnier',1891,26.90),('3351be47-6a9e-11f1-8ef9-5602d808ef1b','Menino de Engenho','JosÃ© Lins do Rego','JosÃ© Olympio',1932,28.50),('3351be7d-6a9e-11f1-8ef9-5602d808ef1b','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,42.90),('3351beb2-6a9e-11f1-8ef9-5602d808ef1b','SÃ£o Bernardo','Graciliano Ramos','Ariel',1934,31.00),('3351bee5-6a9e-11f1-8ef9-5602d808ef1b','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,17.90),('3351bf19-6a9e-11f1-8ef9-5602d808ef1b','O Guarani','JosÃ© de Alencar','Empresa Nacional',1857,21.50),('3351bf4f-6a9e-11f1-8ef9-5602d808ef1b','Clara dos Anjos','Lima Barreto','MÃ©rito',1948,23.90),('3351bf85-6a9e-11f1-8ef9-5602d808ef1b','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,25.90),('3351bfb9-6a9e-11f1-8ef9-5602d808ef1b','A PaixÃ£o Segundo G.H.','Clarice Lispector','Editora do Autor',1964,44.90),('3351bfeb-6a9e-11f1-8ef9-5602d808ef1b','Lavoura Arcaica','Raduan Nassar','JosÃ© Olympio',1975,48.50),('3351c020-6a9e-11f1-8ef9-5602d808ef1b','AngÃºstia','Graciliano Ramos','JosÃ© Olympio',1936,29.00),('3351c054-6a9e-11f1-8ef9-5602d808ef1b','MemÃ³rias de um Sargento de MilÃ­cias','Manuel AntÃ´nio de Almeida','Tipografia Nacional',1854,20.90),('3351c089-6a9e-11f1-8ef9-5602d808ef1b','O Quinze','Rachel de Queiroz','Editora Olympio',1930,26.50),('3351c0bb-6a9e-11f1-8ef9-5602d808ef1b','Sagarana','GuimarÃ£es Rosa','Universal',1946,37.90),('3351c0ee-6a9e-11f1-8ef9-5602d808ef1b','Fogo Morto','JosÃ© Lins do Rego','JosÃ© Olympio',1943,33.50),('3351c121-6a9e-11f1-8ef9-5602d808ef1b','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,45.90),('3351c153-6a9e-11f1-8ef9-5602d808ef1b','Olhai os LÃ­rios do Campo','Erico Verissimo','Globo',1938,35.90),('3351c186-6a9e-11f1-8ef9-5602d808ef1b','Noite na Taverna','Ãlvares de Azevedo','Garnier',1855,16.90),('3351c1b9-6a9e-11f1-8ef9-5602d808ef1b','Dois IrmÃ£os','Milton Hatoum','Companhia das Letras',2000,52.90);
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
INSERT INTO `usuarios` VALUES ('33458fc3-6a9e-11f1-8ef9-5602d808ef1b','Ana Clara Silva','ana.silva@email.com','ebfb9654f666a51cda4f7794c88f111344ece7d36af5defed76c334059049bbc','587cafacfc66f54922347d148276ae9937124c7bbdc6d501f245101f1513a4d4','2026-06-17 22:45:12'),('334678c6-6a9e-11f1-8ef9-5602d808ef1b','Bruno Oliveira','bruno.oliveira@email.com','377501443381ef7682126a9f31aaa85b4bd2fee34f373eab20d1ca7b1c9f8a44','0c34b22871e4503836c466f947b0efeff0a89215450b517329eed2706ba0b69f','2026-06-17 22:45:12'),('3347645a-6a9e-11f1-8ef9-5602d808ef1b','Carla Mendes','carla.mendes@email.com','f31a186b65edeafe15e441c9d0da3a5006933c0f99e3d669f83840351318b4ac','785fb44dfe3add1d8d536709ae4dde632390dab4ce8e94b7c0d4e48a7a4b6a92','2026-06-17 22:45:12'),('33489cc7-6a9e-11f1-8ef9-5602d808ef1b','Daniel Souza','daniel.souza@email.com','dec70dd874ba746a326a7f0131b6f424c731c07d29086dfde52c4650200c619b','9ff4f0f2d864df4fd4719bab73d0709ac5feb4384ccf426fe0ab82cadcbaae35','2026-06-17 22:45:12'),('3349c77f-6a9e-11f1-8ef9-5602d808ef1b','Elena Ferreira','elena.ferreira@email.com','a0f5a1b76a742d2eae5919848cebb1a113ae1527128781bfb715580d20eedca5','bef0bf49e7b2e86a2032bf6d58f3c8deba490d73b438266f039970f43eed320f','2026-06-17 22:45:12'),('334a9b76-6a9e-11f1-8ef9-5602d808ef1b','Felipe Santos','felipe.santos@email.com','01f6d8028713b505040080714e8428aebbc008e4a1dff27da6dc3c69c7c89837','3f85156a78b5811a5bbfe86786b9b95491c783a22d72846f58f5c91ea413caf9','2026-06-17 22:45:12'),('334bd88a-6a9e-11f1-8ef9-5602d808ef1b','Gabriela Lima','gabriela.lima@email.com','d341dc94e9cb99e09299ffdcaf60714f886bb7b38d4faf3d6c51c9d41f0e5793','2b87466bb645018431c05d89f5ce7254b0c765959f8a5a783414d6ebf4a75089','2026-06-17 22:45:12'),('334cac68-6a9e-11f1-8ef9-5602d808ef1b','Hugo Pereira','hugo.pereira@email.com','774ebd43bf273a4fe044597c279cb7e2127207e773c92c5aefefb0d81a9e1e36','636caa5eb35cc5979bddb5cb7706c6e55ed0162e690f982db84f9b54202c3aea','2026-06-17 22:45:12'),('334dda2e-6a9e-11f1-8ef9-5602d808ef1b','Isabela Costa','isabela.costa@email.com','19133120316a9f298b04824bf0f1757885646ea5f40f667c856fdeb3eba1f4e2','7d17cb41820f4c81d25a71d861418259e25e9e2c35b65659343f49416cc590ec','2026-06-17 22:45:12'),('334eb5f7-6a9e-11f1-8ef9-5602d808ef1b','JoÃ£o Almeida','joao.almeida@email.com','e38abc47731872bef81ec60c2860fe72aa713bf05ca2f51def0fe4b12e64ff76','70a43d5199c1226bc66427254168b09fc6cdb74459cc51958ec0c2d36b596b96','2026-06-17 22:45:12'),('334f92d6-6a9e-11f1-8ef9-5602d808ef1b','Rafael Nascimento','rafael.nascimento@email.com','645fd8fe6618015a03a1d634a0e24f01bac1df9532cf6a1036acbca732b8d64b','40092eace0d224dee2d6c8b6de734a66788cf78d95b87a3885c520d1c692a232','2026-06-17 22:45:12'),('33506657-6a9e-11f1-8ef9-5602d808ef1b','Sofia Cardoso','sofia.cardoso@email.com','a290d310f9c4e4ca4d17ad0f6f8c32288cd1b179a4a2f0a1f4d6ced0e3484c7a','a870cbacdd3abc592ec80e253ebffabf3203bb96a82f1a0143287730bfc2e878','2026-06-17 22:45:12');
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

-- Dump completed on 2026-06-17 22:49:16
