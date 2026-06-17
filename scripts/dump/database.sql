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
  `status` enum('pendente','atrasado','devolvido') NOT NULL DEFAULT 'pendente',
  PRIMARY KEY (`id_emprestimo`),
  KEY `fk_emprestimo_livro` (`id_livro`),
  KEY `fk_emprestimo_usuario` (`id_usuario`),
  CONSTRAINT `fk_emprestimo_livro` FOREIGN KEY (`id_livro`) REFERENCES `livros` (`id_livro`) ON UPDATE CASCADE,
  CONSTRAINT `fk_emprestimo_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON UPDATE CASCADE,
  CONSTRAINT `check_datas` CHECK (`data_devolucao_prevista` >= `data_saida`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emprestimos`
--

LOCK TABLES `emprestimos` WRITE;
/*!40000 ALTER TABLE `emprestimos` DISABLE KEYS */;
INSERT INTO `emprestimos` VALUES
('dca1288b-6a99-11f1-93ed-b669aea04130','dca08ebf-6a99-11f1-93ed-b669aea04130','dc9ad929-6a99-11f1-93ed-b669aea04130','2026-01-10','2026-01-24','2026-01-20','devolvido'),
('dca12a47-6a99-11f1-93ed-b669aea04130','dca08fae-6a99-11f1-93ed-b669aea04130','dc9b62e3-6a99-11f1-93ed-b669aea04130','2026-01-15','2026-01-29','2026-01-28','devolvido'),
('dca12b24-6a99-11f1-93ed-b669aea04130','dca08ffa-6a99-11f1-93ed-b669aea04130','dc9bcb89-6a99-11f1-93ed-b669aea04130','2026-02-01','2026-02-15','2026-02-10','devolvido'),
('dca12bbb-6a99-11f1-93ed-b669aea04130','dca0901e-6a99-11f1-93ed-b669aea04130','dc9d1886-6a99-11f1-93ed-b669aea04130','2026-02-05','2026-02-19','2026-02-18','devolvido'),
('dca12c56-6a99-11f1-93ed-b669aea04130','dca0902d-6a99-11f1-93ed-b669aea04130','dc9d7c14-6a99-11f1-93ed-b669aea04130','2026-02-10','2026-02-24','2026-02-22','devolvido'),
('dca20ef9-6a99-11f1-93ed-b669aea04130','dca0903c-6a99-11f1-93ed-b669aea04130','dc9df232-6a99-11f1-93ed-b669aea04130','2026-01-05','2026-01-19','2026-02-01','devolvido'),
('dca211ee-6a99-11f1-93ed-b669aea04130','dca0904a-6a99-11f1-93ed-b669aea04130','dc9e543f-6a99-11f1-93ed-b669aea04130','2026-01-20','2026-02-03','2026-02-15','devolvido'),
('dca212ff-6a99-11f1-93ed-b669aea04130','dca09059-6a99-11f1-93ed-b669aea04130','dc9ec984-6a99-11f1-93ed-b669aea04130','2026-02-01','2026-02-15','2026-03-01','devolvido'),
('dca213f5-6a99-11f1-93ed-b669aea04130','dca09068-6a99-11f1-93ed-b669aea04130','dc9f2e07-6a99-11f1-93ed-b669aea04130','2026-02-10','2026-02-24','2026-03-05','devolvido'),
('dca214af-6a99-11f1-93ed-b669aea04130','dca09077-6a99-11f1-93ed-b669aea04130','dc9ad929-6a99-11f1-93ed-b669aea04130','2026-02-15','2026-03-01','2026-03-10','devolvido'),
('dca2a3f2-6a99-11f1-93ed-b669aea04130','dca09086-6a99-11f1-93ed-b669aea04130','dc9b62e3-6a99-11f1-93ed-b669aea04130','2026-04-10','2026-04-24',NULL,'pendente'),
('dca2a5a5-6a99-11f1-93ed-b669aea04130','dca09094-6a99-11f1-93ed-b669aea04130','dc9bcb89-6a99-11f1-93ed-b669aea04130','2026-04-08','2026-04-22',NULL,'pendente'),
('dca2a640-6a99-11f1-93ed-b669aea04130','dca090a1-6a99-11f1-93ed-b669aea04130','dc9ca1ec-6a99-11f1-93ed-b669aea04130','2026-04-05','2026-04-19',NULL,'pendente'),
('dca2a6d6-6a99-11f1-93ed-b669aea04130','dca090af-6a99-11f1-93ed-b669aea04130','dc9d1886-6a99-11f1-93ed-b669aea04130','2026-04-12','2026-04-26',NULL,'pendente'),
('dca2a76e-6a99-11f1-93ed-b669aea04130','dca090bd-6a99-11f1-93ed-b669aea04130','dc9d7c14-6a99-11f1-93ed-b669aea04130','2026-04-11','2026-04-25',NULL,'pendente'),
('dca2a804-6a99-11f1-93ed-b669aea04130','dca090cb-6a99-11f1-93ed-b669aea04130','dc9df232-6a99-11f1-93ed-b669aea04130','2026-04-09','2026-04-23',NULL,'pendente'),
('dca2a897-6a99-11f1-93ed-b669aea04130','dca090d9-6a99-11f1-93ed-b669aea04130','dc9e543f-6a99-11f1-93ed-b669aea04130','2026-04-13','2026-04-27',NULL,'pendente'),
('dca2a92d-6a99-11f1-93ed-b669aea04130','dca090e7-6a99-11f1-93ed-b669aea04130','dc9ec984-6a99-11f1-93ed-b669aea04130','2026-04-07','2026-04-21',NULL,'pendente'),
('dca2a9bc-6a99-11f1-93ed-b669aea04130','dca090f5-6a99-11f1-93ed-b669aea04130','dc9f2e07-6a99-11f1-93ed-b669aea04130','2026-04-14','2026-04-28',NULL,'pendente'),
('dca2aa4b-6a99-11f1-93ed-b669aea04130','dca09103-6a99-11f1-93ed-b669aea04130','dc9ad929-6a99-11f1-93ed-b669aea04130','2026-04-06','2026-04-20',NULL,'pendente'),
('dca318e9-6a99-11f1-93ed-b669aea04130','dca09111-6a99-11f1-93ed-b669aea04130','dc9b62e3-6a99-11f1-93ed-b669aea04130','2026-03-01','2026-03-15',NULL,'atrasado'),
('dca31a96-6a99-11f1-93ed-b669aea04130','dca09120-6a99-11f1-93ed-b669aea04130','dc9bcb89-6a99-11f1-93ed-b669aea04130','2026-03-05','2026-03-19',NULL,'atrasado'),
('dca31b4f-6a99-11f1-93ed-b669aea04130','dca0912f-6a99-11f1-93ed-b669aea04130','dc9ca1ec-6a99-11f1-93ed-b669aea04130','2026-03-10','2026-03-24',NULL,'atrasado'),
('dca31c02-6a99-11f1-93ed-b669aea04130','dca0913c-6a99-11f1-93ed-b669aea04130','dc9d1886-6a99-11f1-93ed-b669aea04130','2026-03-02','2026-03-16',NULL,'atrasado'),
('dca31cb3-6a99-11f1-93ed-b669aea04130','dca0914a-6a99-11f1-93ed-b669aea04130','dc9d7c14-6a99-11f1-93ed-b669aea04130','2026-03-08','2026-03-22',NULL,'atrasado'),
('dca31d66-6a99-11f1-93ed-b669aea04130','dca09157-6a99-11f1-93ed-b669aea04130','dc9df232-6a99-11f1-93ed-b669aea04130','2026-03-12','2026-03-26',NULL,'atrasado'),
('dca31e1e-6a99-11f1-93ed-b669aea04130','dca09165-6a99-11f1-93ed-b669aea04130','dc9e543f-6a99-11f1-93ed-b669aea04130','2026-03-03','2026-03-17',NULL,'atrasado'),
('dca31ecb-6a99-11f1-93ed-b669aea04130','dca09172-6a99-11f1-93ed-b669aea04130','dc9ec984-6a99-11f1-93ed-b669aea04130','2026-03-07','2026-03-21',NULL,'atrasado'),
('dca31f7b-6a99-11f1-93ed-b669aea04130','dca09181-6a99-11f1-93ed-b669aea04130','dc9f2e07-6a99-11f1-93ed-b669aea04130','2026-03-15','2026-03-29',NULL,'atrasado'),
('dca3202e-6a99-11f1-93ed-b669aea04130','dca0900d-6a99-11f1-93ed-b669aea04130','dc9ad929-6a99-11f1-93ed-b669aea04130','2026-03-20','2026-04-03',NULL,'atrasado'),
('dca39d03-6a99-11f1-93ed-b669aea04130','dca08ebf-6a99-11f1-93ed-b669aea04130','dc9ca1ec-6a99-11f1-93ed-b669aea04130','2026-04-01','2026-04-16',NULL,'pendente'),
('dca39e9a-6a99-11f1-93ed-b669aea04130','dca08fae-6a99-11f1-93ed-b669aea04130','dc9d1886-6a99-11f1-93ed-b669aea04130','2026-04-02','2026-04-17',NULL,'pendente'),
('dca39fc3-6a99-11f1-93ed-b669aea04130','dca08ffa-6a99-11f1-93ed-b669aea04130','dc9d7c14-6a99-11f1-93ed-b669aea04130','2026-04-03','2026-04-16',NULL,'pendente'),
('dca3a082-6a99-11f1-93ed-b669aea04130','dca0901e-6a99-11f1-93ed-b669aea04130','dc9df232-6a99-11f1-93ed-b669aea04130','2026-04-01','2026-04-15',NULL,'pendente'),
('dca3a139-6a99-11f1-93ed-b669aea04130','dca0902d-6a99-11f1-93ed-b669aea04130','dc9e543f-6a99-11f1-93ed-b669aea04130','2026-04-02','2026-04-18',NULL,'pendente'),
('dca40c83-6a99-11f1-93ed-b669aea04130','dca0913c-6a99-11f1-93ed-b669aea04130','dc9ec984-6a99-11f1-93ed-b669aea04130','2025-12-01','2025-12-15','2025-12-14','devolvido'),
('dca40e2d-6a99-11f1-93ed-b669aea04130','dca0914a-6a99-11f1-93ed-b669aea04130','dc9f2e07-6a99-11f1-93ed-b669aea04130','2025-12-05','2025-12-19','2025-12-18','devolvido'),
('dca40ec7-6a99-11f1-93ed-b669aea04130','dca09157-6a99-11f1-93ed-b669aea04130','dc9ad929-6a99-11f1-93ed-b669aea04130','2025-12-10','2025-12-24','2025-12-23','devolvido'),
('dca40f62-6a99-11f1-93ed-b669aea04130','dca09165-6a99-11f1-93ed-b669aea04130','dc9b62e3-6a99-11f1-93ed-b669aea04130','2025-12-15','2025-12-29','2025-12-28','devolvido'),
('dca40fff-6a99-11f1-93ed-b669aea04130','dca09172-6a99-11f1-93ed-b669aea04130','dc9bcb89-6a99-11f1-93ed-b669aea04130','2025-12-20','2026-01-03','2026-01-02','devolvido');
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
  `preco` decimal(8,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_livro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `livros`
--

LOCK TABLES `livros` WRITE;
/*!40000 ALTER TABLE `livros` DISABLE KEYS */;
INSERT INTO `livros` VALUES
('dca08ebf-6a99-11f1-93ed-b669aea04130','Dom Casmurro','Machado de Assis','Garnier',1899,29.90),
('dca08fae-6a99-11f1-93ed-b669aea04130','Grande Sertão: Veredas','Guimarães Rosa','José Olympio',1956,54.90),
('dca08ffa-6a99-11f1-93ed-b669aea04130','Memórias Póstumas de Brás Cubas','Machado de Assis','Tipografia Nacional',1881,24.90),
('dca0900d-6a99-11f1-93ed-b669aea04130','O Cortiço','Aluísio Azevedo','B. L. Garnier',1890,22.50),
('dca0901e-6a99-11f1-93ed-b669aea04130','Capitães da Areia','Jorge Amado','José Olympio',1937,34.90),
('dca0902d-6a99-11f1-93ed-b669aea04130','Vidas Secas','Graciliano Ramos','José Olympio',1938,27.90),
('dca0903c-6a99-11f1-93ed-b669aea04130','A Hora da Estrela','Clarice Lispector','José Olympio',1977,39.90),
('dca0904a-6a99-11f1-93ed-b669aea04130','O Alienista','Machado de Assis','Garnier',1882,19.90),
('dca09059-6a99-11f1-93ed-b669aea04130','Iracema','José de Alencar','Tipografia Viana',1865,18.50),
('dca09068-6a99-11f1-93ed-b669aea04130','Macunaíma','Mário de Andrade','Oficinas Gráficas',1928,32.90),
('dca09077-6a99-11f1-93ed-b669aea04130','O Tempo e o Vento','Erico Verissimo','Globo',1949,69.90),
('dca09086-6a99-11f1-93ed-b669aea04130','Quincas Borba','Machado de Assis','Garnier',1891,26.90),
('dca09094-6a99-11f1-93ed-b669aea04130','Menino de Engenho','José Lins do Rego','José Olympio',1932,28.50),
('dca090a1-6a99-11f1-93ed-b669aea04130','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,42.90),
('dca090af-6a99-11f1-93ed-b669aea04130','São Bernardo','Graciliano Ramos','Ariel',1934,31.00),
('dca090bd-6a99-11f1-93ed-b669aea04130','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,17.90),
('dca090cb-6a99-11f1-93ed-b669aea04130','O Guarani','José de Alencar','Empresa Nacional',1857,21.50),
('dca090d9-6a99-11f1-93ed-b669aea04130','Clara dos Anjos','Lima Barreto','Mérito',1948,23.90),
('dca090e7-6a99-11f1-93ed-b669aea04130','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,25.90),
('dca090f5-6a99-11f1-93ed-b669aea04130','A Paixão Segundo G.H.','Clarice Lispector','Editora do Autor',1964,44.90),
('dca09103-6a99-11f1-93ed-b669aea04130','Lavoura Arcaica','Raduan Nassar','José Olympio',1975,48.50),
('dca09111-6a99-11f1-93ed-b669aea04130','Angústia','Graciliano Ramos','José Olympio',1936,29.00),
('dca09120-6a99-11f1-93ed-b669aea04130','Memórias de um Sargento de Milícias','Manuel Antônio de Almeida','Tipografia Nacional',1854,20.90),
('dca0912f-6a99-11f1-93ed-b669aea04130','O Quinze','Rachel de Queiroz','Editora Olympio',1930,26.50),
('dca0913c-6a99-11f1-93ed-b669aea04130','Sagarana','Guimarães Rosa','Universal',1946,37.90),
('dca0914a-6a99-11f1-93ed-b669aea04130','Fogo Morto','José Lins do Rego','José Olympio',1943,33.50),
('dca09157-6a99-11f1-93ed-b669aea04130','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,45.90),
('dca09165-6a99-11f1-93ed-b669aea04130','Olhai os Lírios do Campo','Erico Verissimo','Globo',1938,35.90),
('dca09172-6a99-11f1-93ed-b669aea04130','Noite na Taverna','Álvares de Azevedo','Garnier',1855,16.90),
('dca09181-6a99-11f1-93ed-b669aea04130','Dois Irmãos','Milton Hatoum','Companhia das Letras',2000,52.90);
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
  `senha` varchar(64) NOT NULL,
  `salt` varchar(64) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
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
('dc9ad929-6a99-11f1-93ed-b669aea04130','Ana Clara Silva','ana.silva@email.com','7e90e4ac8c5bf3b1135feba17037c39abf495a0e6689a3a407aeff53c03cbeda','4da5ab3e75a896b9b6c0ab0d6ee8c858f784fd8dc2dfe2443ae5e81895cb9d25','2026-06-17 22:14:08'),
('dc9b62e3-6a99-11f1-93ed-b669aea04130','Bruno Oliveira','bruno.oliveira@email.com','991ced7bca9196d34be7c7439e1fd9f6a20e58a47683cb46e7d8588cc94e2a58','c15b63b54526d4500d09639df55f0d27dc1f45c85e3d23f0677e99d3977f49d3','2026-06-17 22:14:08'),
('dc9bcb89-6a99-11f1-93ed-b669aea04130','Carla Mendes','carla.mendes@email.com','be9336f2ac34934e75a285bc4db02a3788451fd8876dd5ca7db50b0ef724363b','10ebe4e2c0b268d2c605144edbbe7b43d8d1874d3d26edbbf207cc2a6c1f66e9','2026-06-17 22:14:08'),
('dc9ca1ec-6a99-11f1-93ed-b669aea04130','Daniel Souza','daniel.souza@email.com','ca6f7ec2b7bc26813620c8fa070781da1f5d1d51bf3bba834f20e292483ede21','c26c7e0d11682c8b442d9d8fd9e015bd24d6dc27d110c40fd6b95721b824192e','2026-06-17 22:14:08'),
('dc9d1886-6a99-11f1-93ed-b669aea04130','Elena Ferreira','elena.ferreira@email.com','1499bef670585006e647377aa0c204a313520489a3dba403302e7f4a261cb3e5','e9ceafb2419425076dae5c07fbb4d0d235e1fac2088764397014afcc9b183678','2026-06-17 22:14:08'),
('dc9d7c14-6a99-11f1-93ed-b669aea04130','Felipe Santos','felipe.santos@email.com','19b0f3f781dfb6827fbe81c3871a34b864790a41750973a784c1c9c8890953d9','2809834e80f7e8828251d8bb8cf0e94abd8f6cb27bfa9fdaa7067b56fcc9c44d','2026-06-17 22:14:08'),
('dc9df232-6a99-11f1-93ed-b669aea04130','Gabriela Lima','gabriela.lima@email.com','ff61dc8c44604d3ad16b935878906f7311c891ef11b9db8ae85bec5715ebd323','081f49a7f6393ae704089c2872dcf71b2e710eff3898fc1af39582f7873cc62d','2026-06-17 22:14:08'),
('dc9e543f-6a99-11f1-93ed-b669aea04130','Hugo Pereira','hugo.pereira@email.com','2fcf90ce0a6e71128bea9cfd65b9e1506f7428701d5558c76a12848e2099bed8','b8a084e58742e9f6f1ca0e8c8c41b368470df17a7aa62091a3b568e11a69450f','2026-06-17 22:14:08'),
('dc9ec984-6a99-11f1-93ed-b669aea04130','Isabela Costa','isabela.costa@email.com','9b3017a934eaf2da7736275c31107f1172aba9c43a51470fe5c9fa6460f4d176','14cfeb900a9683f8d344108ada3b0cc648b6d83ba23ab39b2ff9d55e4a18d611','2026-06-17 22:14:08'),
('dc9f2e07-6a99-11f1-93ed-b669aea04130','João Almeida','joao.almeida@email.com','d7a8d0fb80d9df034ae6a9d08bcf4310f4f9fe16ec45b34309917c6a1ec2b231','419edb06c12e7b1762251c5d9e1300892c63319d0672e142fa6ebbe91bc63f4b','2026-06-17 22:14:08'),
('dc9faab1-6a99-11f1-93ed-b669aea04130','Rafael Nascimento','rafael.nascimento@email.com','b77b044df0573837e8fc0ef6800d903b46261fc18eac9fb7f9dc2c315a86b9a3','24c05bfa9b8b0d4d1c0144f786bece5352ceaab9181aa402453cbe6c97d08bfb','2026-06-17 22:14:08'),
('dca00ed9-6a99-11f1-93ed-b669aea04130','Sofia Cardoso','sofia.cardoso@email.com','7acd24478b1e2b1297919a2e9cb6429bddf0237916f85f76c4109b9901be656f','d77105c5e28b533d4ff5ba5f2fa86c4b0808814650082c10378324e95fd07036','2026-06-17 22:14:08');
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

-- Dump completed on 2026-06-17 22:14:09
