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
('443c9fc7-6a9e-11f1-93ed-b669aea04130','443c1d2f-6a9e-11f1-93ed-b669aea04130','44368c95-6a9e-11f1-93ed-b669aea04130','2026-01-10','2026-01-24','2026-01-20','devolvido'),
('443ca23d-6a9e-11f1-93ed-b669aea04130','443c1e7d-6a9e-11f1-93ed-b669aea04130','4436fc63-6a9e-11f1-93ed-b669aea04130','2026-01-15','2026-01-29','2026-01-28','devolvido'),
('443ca32d-6a9e-11f1-93ed-b669aea04130','443c1ebd-6a9e-11f1-93ed-b669aea04130','44377953-6a9e-11f1-93ed-b669aea04130','2026-02-01','2026-02-15','2026-02-10','devolvido'),
('443ca3de-6a9e-11f1-93ed-b669aea04130','443c1ee2-6a9e-11f1-93ed-b669aea04130','4438bfda-6a9e-11f1-93ed-b669aea04130','2026-02-05','2026-02-19','2026-02-18','devolvido'),
('443ca4c3-6a9e-11f1-93ed-b669aea04130','443c1ef1-6a9e-11f1-93ed-b669aea04130','4439219c-6a9e-11f1-93ed-b669aea04130','2026-02-10','2026-02-24','2026-02-22','devolvido'),
('443d81e2-6a9e-11f1-93ed-b669aea04130','443c1f01-6a9e-11f1-93ed-b669aea04130','44397db9-6a9e-11f1-93ed-b669aea04130','2026-01-05','2026-01-19','2026-02-01','devolvido'),
('443d8394-6a9e-11f1-93ed-b669aea04130','443c1f0f-6a9e-11f1-93ed-b669aea04130','4439f68a-6a9e-11f1-93ed-b669aea04130','2026-01-20','2026-02-03','2026-02-15','devolvido'),
('443d8425-6a9e-11f1-93ed-b669aea04130','443c1f1e-6a9e-11f1-93ed-b669aea04130','443a6603-6a9e-11f1-93ed-b669aea04130','2026-02-01','2026-02-15','2026-03-01','devolvido'),
('443d84b4-6a9e-11f1-93ed-b669aea04130','443c1f2c-6a9e-11f1-93ed-b669aea04130','443acb6a-6a9e-11f1-93ed-b669aea04130','2026-02-10','2026-02-24','2026-03-05','devolvido'),
('443d8542-6a9e-11f1-93ed-b669aea04130','443c1f3a-6a9e-11f1-93ed-b669aea04130','44368c95-6a9e-11f1-93ed-b669aea04130','2026-02-15','2026-03-01','2026-03-10','devolvido'),
('443e123b-6a9e-11f1-93ed-b669aea04130','443c1f47-6a9e-11f1-93ed-b669aea04130','4436fc63-6a9e-11f1-93ed-b669aea04130','2026-06-01','2026-06-22',NULL,'pendente'),
('443e140a-6a9e-11f1-93ed-b669aea04130','443c1f55-6a9e-11f1-93ed-b669aea04130','44377953-6a9e-11f1-93ed-b669aea04130','2026-06-03','2026-06-24',NULL,'pendente'),
('443e14b7-6a9e-11f1-93ed-b669aea04130','443c1f62-6a9e-11f1-93ed-b669aea04130','4438525e-6a9e-11f1-93ed-b669aea04130','2026-06-04','2026-06-25',NULL,'pendente'),
('443e155b-6a9e-11f1-93ed-b669aea04130','443c1f71-6a9e-11f1-93ed-b669aea04130','4438bfda-6a9e-11f1-93ed-b669aea04130','2026-06-05','2026-06-26',NULL,'pendente'),
('443e1605-6a9e-11f1-93ed-b669aea04130','443c1f7f-6a9e-11f1-93ed-b669aea04130','4439219c-6a9e-11f1-93ed-b669aea04130','2026-06-06','2026-06-27',NULL,'pendente'),
('443e16a6-6a9e-11f1-93ed-b669aea04130','443c1f8c-6a9e-11f1-93ed-b669aea04130','44397db9-6a9e-11f1-93ed-b669aea04130','2026-06-07','2026-06-28',NULL,'pendente'),
('443e1748-6a9e-11f1-93ed-b669aea04130','443c1f9a-6a9e-11f1-93ed-b669aea04130','4439f68a-6a9e-11f1-93ed-b669aea04130','2026-06-08','2026-06-29',NULL,'pendente'),
('443e17eb-6a9e-11f1-93ed-b669aea04130','443c1fa8-6a9e-11f1-93ed-b669aea04130','443a6603-6a9e-11f1-93ed-b669aea04130','2026-06-09','2026-06-30',NULL,'pendente'),
('443e188f-6a9e-11f1-93ed-b669aea04130','443c1fb6-6a9e-11f1-93ed-b669aea04130','443acb6a-6a9e-11f1-93ed-b669aea04130','2026-06-10','2026-07-01',NULL,'pendente'),
('443e1946-6a9e-11f1-93ed-b669aea04130','443c1fc4-6a9e-11f1-93ed-b669aea04130','44368c95-6a9e-11f1-93ed-b669aea04130','2026-06-12','2026-07-03',NULL,'pendente'),
('443e922e-6a9e-11f1-93ed-b669aea04130','443c1fd2-6a9e-11f1-93ed-b669aea04130','4436fc63-6a9e-11f1-93ed-b669aea04130','2026-04-15','2026-04-29',NULL,'atrasado'),
('443e93de-6a9e-11f1-93ed-b669aea04130','443c1fe0-6a9e-11f1-93ed-b669aea04130','44377953-6a9e-11f1-93ed-b669aea04130','2026-04-18','2026-05-02',NULL,'atrasado'),
('443e9470-6a9e-11f1-93ed-b669aea04130','443c1fee-6a9e-11f1-93ed-b669aea04130','4438525e-6a9e-11f1-93ed-b669aea04130','2026-04-20','2026-05-04',NULL,'atrasado'),
('443e94fa-6a9e-11f1-93ed-b669aea04130','443c1ffc-6a9e-11f1-93ed-b669aea04130','4438bfda-6a9e-11f1-93ed-b669aea04130','2026-04-22','2026-05-06',NULL,'atrasado'),
('443e958a-6a9e-11f1-93ed-b669aea04130','443c200a-6a9e-11f1-93ed-b669aea04130','4439219c-6a9e-11f1-93ed-b669aea04130','2026-04-24','2026-05-08',NULL,'atrasado'),
('443e9617-6a9e-11f1-93ed-b669aea04130','443c2017-6a9e-11f1-93ed-b669aea04130','44397db9-6a9e-11f1-93ed-b669aea04130','2026-04-28','2026-05-12',NULL,'atrasado'),
('443e96a8-6a9e-11f1-93ed-b669aea04130','443c2024-6a9e-11f1-93ed-b669aea04130','4439f68a-6a9e-11f1-93ed-b669aea04130','2026-05-01','2026-05-15',NULL,'atrasado'),
('443e9731-6a9e-11f1-93ed-b669aea04130','443c2032-6a9e-11f1-93ed-b669aea04130','443a6603-6a9e-11f1-93ed-b669aea04130','2026-05-05','2026-05-19',NULL,'atrasado'),
('443e97be-6a9e-11f1-93ed-b669aea04130','443c2041-6a9e-11f1-93ed-b669aea04130','443acb6a-6a9e-11f1-93ed-b669aea04130','2026-05-08','2026-05-22',NULL,'atrasado'),
('443e9853-6a9e-11f1-93ed-b669aea04130','443c1ed0-6a9e-11f1-93ed-b669aea04130','44368c95-6a9e-11f1-93ed-b669aea04130','2026-05-12','2026-05-26',NULL,'atrasado'),
('443f0a8e-6a9e-11f1-93ed-b669aea04130','443c1d2f-6a9e-11f1-93ed-b669aea04130','4438525e-6a9e-11f1-93ed-b669aea04130','2026-06-03','2026-06-17',NULL,'pendente'),
('443f0bd8-6a9e-11f1-93ed-b669aea04130','443c1e7d-6a9e-11f1-93ed-b669aea04130','4438bfda-6a9e-11f1-93ed-b669aea04130','2026-06-04','2026-06-18',NULL,'pendente'),
('443f0c6d-6a9e-11f1-93ed-b669aea04130','443c1ebd-6a9e-11f1-93ed-b669aea04130','4439219c-6a9e-11f1-93ed-b669aea04130','2026-06-04','2026-06-18',NULL,'pendente'),
('443f0cf9-6a9e-11f1-93ed-b669aea04130','443c1ee2-6a9e-11f1-93ed-b669aea04130','44397db9-6a9e-11f1-93ed-b669aea04130','2026-06-03','2026-06-17',NULL,'pendente'),
('443f0d86-6a9e-11f1-93ed-b669aea04130','443c1ef1-6a9e-11f1-93ed-b669aea04130','4439f68a-6a9e-11f1-93ed-b669aea04130','2026-06-05','2026-06-19',NULL,'pendente'),
('443f8ef5-6a9e-11f1-93ed-b669aea04130','443c1ffc-6a9e-11f1-93ed-b669aea04130','443a6603-6a9e-11f1-93ed-b669aea04130','2025-12-01','2025-12-15','2025-12-14','devolvido'),
('443f9058-6a9e-11f1-93ed-b669aea04130','443c200a-6a9e-11f1-93ed-b669aea04130','443acb6a-6a9e-11f1-93ed-b669aea04130','2025-12-05','2025-12-19','2025-12-18','devolvido'),
('443f9107-6a9e-11f1-93ed-b669aea04130','443c2017-6a9e-11f1-93ed-b669aea04130','44368c95-6a9e-11f1-93ed-b669aea04130','2025-12-10','2025-12-24','2025-12-23','devolvido'),
('443f91b8-6a9e-11f1-93ed-b669aea04130','443c2024-6a9e-11f1-93ed-b669aea04130','4436fc63-6a9e-11f1-93ed-b669aea04130','2025-12-15','2025-12-29','2025-12-28','devolvido'),
('443f9263-6a9e-11f1-93ed-b669aea04130','443c2032-6a9e-11f1-93ed-b669aea04130','44377953-6a9e-11f1-93ed-b669aea04130','2025-12-20','2026-01-03','2026-01-02','devolvido');
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
('443c1d2f-6a9e-11f1-93ed-b669aea04130','Dom Casmurro','Machado de Assis','Garnier',1899,29.90),
('443c1e7d-6a9e-11f1-93ed-b669aea04130','Grande Sertão: Veredas','Guimarães Rosa','José Olympio',1956,54.90),
('443c1ebd-6a9e-11f1-93ed-b669aea04130','Memórias Póstumas de Brás Cubas','Machado de Assis','Tipografia Nacional',1881,24.90),
('443c1ed0-6a9e-11f1-93ed-b669aea04130','O Cortiço','Aluísio Azevedo','B. L. Garnier',1890,22.50),
('443c1ee2-6a9e-11f1-93ed-b669aea04130','Capitães da Areia','Jorge Amado','José Olympio',1937,34.90),
('443c1ef1-6a9e-11f1-93ed-b669aea04130','Vidas Secas','Graciliano Ramos','José Olympio',1938,27.90),
('443c1f01-6a9e-11f1-93ed-b669aea04130','A Hora da Estrela','Clarice Lispector','José Olympio',1977,39.90),
('443c1f0f-6a9e-11f1-93ed-b669aea04130','O Alienista','Machado de Assis','Garnier',1882,19.90),
('443c1f1e-6a9e-11f1-93ed-b669aea04130','Iracema','José de Alencar','Tipografia Viana',1865,18.50),
('443c1f2c-6a9e-11f1-93ed-b669aea04130','Macunaíma','Mário de Andrade','Oficinas Gráficas',1928,32.90),
('443c1f3a-6a9e-11f1-93ed-b669aea04130','O Tempo e o Vento','Erico Verissimo','Globo',1949,69.90),
('443c1f47-6a9e-11f1-93ed-b669aea04130','Quincas Borba','Machado de Assis','Garnier',1891,26.90),
('443c1f55-6a9e-11f1-93ed-b669aea04130','Menino de Engenho','José Lins do Rego','José Olympio',1932,28.50),
('443c1f62-6a9e-11f1-93ed-b669aea04130','Gabriela, Cravo e Canela','Jorge Amado','Martins',1958,42.90),
('443c1f71-6a9e-11f1-93ed-b669aea04130','São Bernardo','Graciliano Ramos','Ariel',1934,31.00),
('443c1f7f-6a9e-11f1-93ed-b669aea04130','A Moreninha','Joaquim Manuel de Macedo','Tipografia Francesa',1844,17.90),
('443c1f8c-6a9e-11f1-93ed-b669aea04130','O Guarani','José de Alencar','Empresa Nacional',1857,21.50),
('443c1f9a-6a9e-11f1-93ed-b669aea04130','Clara dos Anjos','Lima Barreto','Mérito',1948,23.90),
('443c1fa8-6a9e-11f1-93ed-b669aea04130','Triste Fim de Policarpo Quaresma','Lima Barreto','Tipografia do Jornal',1915,25.90),
('443c1fb6-6a9e-11f1-93ed-b669aea04130','A Paixão Segundo G.H.','Clarice Lispector','Editora do Autor',1964,44.90),
('443c1fc4-6a9e-11f1-93ed-b669aea04130','Lavoura Arcaica','Raduan Nassar','José Olympio',1975,48.50),
('443c1fd2-6a9e-11f1-93ed-b669aea04130','Angústia','Graciliano Ramos','José Olympio',1936,29.00),
('443c1fe0-6a9e-11f1-93ed-b669aea04130','Memórias de um Sargento de Milícias','Manuel Antônio de Almeida','Tipografia Nacional',1854,20.90),
('443c1fee-6a9e-11f1-93ed-b669aea04130','O Quinze','Rachel de Queiroz','Editora Olympio',1930,26.50),
('443c1ffc-6a9e-11f1-93ed-b669aea04130','Sagarana','Guimarães Rosa','Universal',1946,37.90),
('443c200a-6a9e-11f1-93ed-b669aea04130','Fogo Morto','José Lins do Rego','José Olympio',1943,33.50),
('443c2017-6a9e-11f1-93ed-b669aea04130','Dona Flor e Seus Dois Maridos','Jorge Amado','Martins',1966,45.90),
('443c2024-6a9e-11f1-93ed-b669aea04130','Olhai os Lírios do Campo','Erico Verissimo','Globo',1938,35.90),
('443c2032-6a9e-11f1-93ed-b669aea04130','Noite na Taverna','Álvares de Azevedo','Garnier',1855,16.90),
('443c2041-6a9e-11f1-93ed-b669aea04130','Dois Irmãos','Milton Hatoum','Companhia das Letras',2000,52.90);
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
('44368c95-6a9e-11f1-93ed-b669aea04130','Ana Clara Silva','ana.silva@email.com','cb121906cc3bca49f6cb8c22834d82b3e9e46fc78e4662e88fb63dc014b9fb36','cafa66b56aa33e9f6cadece9137cdbb0147d129bc1cb7c7da4860cc57e5214ed','2026-06-17 22:45:40'),
('4436fc63-6a9e-11f1-93ed-b669aea04130','Bruno Oliveira','bruno.oliveira@email.com','ecbf4fec0750427559d84c592e0568ca7cf8e93d51cb53b204dfa443c53ea1c7','9b2432266cfea031da9e34abcbe035dc3d0419336b6bc050fb797288c2484cc3','2026-06-17 22:45:40'),
('44377953-6a9e-11f1-93ed-b669aea04130','Carla Mendes','carla.mendes@email.com','636da7a63c88f6dcb91f8b5bb8af3270027a63b577f8bf7e89eac16b31cc8f80','09ce232d296a7f3e980a0ebd81dd2ab5abdfe435dfb9c7e2dfdebd8353a2de61','2026-06-17 22:45:40'),
('4438525e-6a9e-11f1-93ed-b669aea04130','Daniel Souza','daniel.souza@email.com','7d0d6f25b6aa8e58372628275ab65cffdd6c3e6e171f1f25b08813c5f144d4bc','ee7ee2630df37c7f0dfdcc5b94b05c42b7b405af6876fa892f6df4dbd3fd7af4','2026-06-17 22:45:40'),
('4438bfda-6a9e-11f1-93ed-b669aea04130','Elena Ferreira','elena.ferreira@email.com','69cdc5cce058e21db6e64d0bc4c565a448d9fea3a45d33c8413a98664eb85d3a','b1c330d241d142927a9e9a6c2d2068e63e5774d7102dff21e575b3bd4fd8dbae','2026-06-17 22:45:40'),
('4439219c-6a9e-11f1-93ed-b669aea04130','Felipe Santos','felipe.santos@email.com','a6347e440b43ca67dbe1cacf2d4981fa4b3ac7a2ee6582e734316139bc4c4354','f4607d15f3ae7380c18a381164be03603349355d82402d6bdef2e0c345ce7135','2026-06-17 22:45:40'),
('44397db9-6a9e-11f1-93ed-b669aea04130','Gabriela Lima','gabriela.lima@email.com','b08edde1a2e6482c171609e01e2b663fc17aa8858e0b046bf62d377cf5e7f3ba','91bc77b5bd44e40becf9772aa7f1ce66d21413064f5d0b6237e93204cbbefa80','2026-06-17 22:45:40'),
('4439f68a-6a9e-11f1-93ed-b669aea04130','Hugo Pereira','hugo.pereira@email.com','9f3b1d8e2aaaf397bff5affe0d0606384981930b6f91cb38bb2694e15024cf03','0f6e49b38ecc95517ae8562c7bf5ca3413d4ca181d2311600f5f00505a25fcd9','2026-06-17 22:45:40'),
('443a6603-6a9e-11f1-93ed-b669aea04130','Isabela Costa','isabela.costa@email.com','7d2b9d970c47eea2b2235b514f9cfac193cebef72473e7a26cecb9fc8d4f0d23','017bf54debd90b69302475d3f52cb9714fa61e08e92c484667b0fd812a7962a1','2026-06-17 22:45:40'),
('443acb6a-6a9e-11f1-93ed-b669aea04130','João Almeida','joao.almeida@email.com','6cf08539828610cf686dc497862f170669ab443d8d69f117a6ceed44c3da76c4','27b280c27a2e72dacbfd262628957d40aa064cdf3c72e096aeb2c8bd4ca08a19','2026-06-17 22:45:40'),
('443b2869-6a9e-11f1-93ed-b669aea04130','Rafael Nascimento','rafael.nascimento@email.com','7bb6d6eb52e1ceaf66ccf9400fd59530249557de2eefda846ad0b501e25ffd24','b5bc8ee17029b69eb85940cb891cdaf152fcbb66e06a2df867bce2c867bfc062','2026-06-17 22:45:40'),
('443b9f9d-6a9e-11f1-93ed-b669aea04130','Sofia Cardoso','sofia.cardoso@email.com','cb1a5c512fd8f9d5d87e1802ea4da2092621ea873f1a5641f730c98a51b482e6','951b308f1691be9208c4c9b7e50d96c6cb95ec2bcf32c92f5b947287844eeeda','2026-06-17 22:45:40');
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

-- Dump completed on 2026-06-17 22:45:40
