-- MariaDB dump 10.19  Distrib 10.4.19-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: fakeexpert
-- ------------------------------------------------------
-- Server version	10.4.19-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cp`
--

DROP TABLE IF EXISTS `cp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cpnum` int(11) DEFAULT NULL,
  `cpx` float DEFAULT NULL,
  `cpy` float DEFAULT NULL,
  `cpz` float DEFAULT NULL,
  `cpx2` float DEFAULT NULL,
  `cpy2` float DEFAULT NULL,
  `cpz2` float DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cp`
--

LOCK TABLES `cp` WRITE;
/*!40000 ALTER TABLE `cp` DISABLE KEYS */;
INSERT INTO `cp` VALUES (7,1,8283.97,9991.97,-143.96,7549.7,9512.03,-143.96,'trikz_cyrus'),(8,2,9719.03,9968.04,-1730.97,10199,10492.3,-1730.97,'trikz_cyrus'),(9,3,-4849.14,-9283.97,-3902.97,-6733.97,-8732.01,-3903.97,'trikz_cyrus'),(10,4,-7637.97,-5939.97,-5157.97,-7158.03,-5576.15,-5157.97,'trikz_cyrus'),(12,0,2510.37,2232.03,64.0312,NULL,NULL,NULL,'trikz_adventure'),(13,1,2512.47,2232.03,64.0312,2098.14,2695.97,64.0312,'trikz_adventure'),(14,2,12766,-3069.92,28.0312,12302,-3405.48,28.0312,'trikz_adventure'),(15,3,5352.02,-2521.72,-451.969,5755.37,-2918.97,-451.997,'trikz_adventure'),(16,4,1914.74,-7098.97,744.031,1495.28,-6763,744.031,'trikz_adventure'),(17,5,-5758.88,-251.031,1621.03,-5423.03,-400.95,1621.03,'trikz_adventure'),(18,1,1664.03,-2927.97,15360,2271.97,-2439.9,15360,'trikz_eonia'),(19,2,6319.97,15800,5952.03,5712.03,15442.6,5952.03,'trikz_eonia'),(20,3,-9808.03,14196.7,3232.03,-11056,13333.7,3232.03,'trikz_eonia'),(21,4,4799.97,-6767.97,-4287.97,3862.68,-4752.03,-4287.97,'trikz_eonia'),(22,2,4847.97,12079.7,1472.71,4672.92,12944.1,1472.22,'trikz_kyoto_final'),(23,1,-6640.03,9200.03,-607.969,-7695.97,9759.5,-607.969,'trikz_soft'),(24,2,-128.031,2691.97,-239.969,-414.566,2402.5,-239.969,'trikz_soft'),(25,3,-5359.97,-14712,384.031,-3599.74,-16184,384.031,'trikz_soft'),(26,1,12656,15024,512.031,11664,14594.2,512.031,'trikz_alpha'),(27,2,-2679.22,-15248,576.031,-2184.69,-16240,576.031,'trikz_alpha'),(28,3,-13168,-2927.97,-319.969,-12182.1,-1939.35,-319.969,'trikz_alpha'),(29,4,-13168,8239.97,96.0312,-12176,7749.45,96.0312,'trikz_alpha');
/*!40000 ALTER TABLE `cp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cp1`
--

DROP TABLE IF EXISTS `cp1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cp1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cpnum` int(11) DEFAULT NULL,
  `cpx` float DEFAULT NULL,
  `cpy` float DEFAULT NULL,
  `cpz` float DEFAULT NULL,
  `cpx2` float DEFAULT NULL,
  `cpy2` float DEFAULT NULL,
  `cpz2` float DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cp1`
--

LOCK TABLES `cp1` WRITE;
/*!40000 ALTER TABLE `cp1` DISABLE KEYS */;
/*!40000 ALTER TABLE `cp1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `records`
--

DROP TABLE IF EXISTS `records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) DEFAULT NULL,
  `partnerid` int(11) DEFAULT NULL,
  `time` float DEFAULT NULL,
  `cp1` float DEFAULT NULL,
  `cp2` float DEFAULT NULL,
  `cp3` float DEFAULT NULL,
  `cp4` float DEFAULT NULL,
  `cp5` float DEFAULT NULL,
  `cp6` float DEFAULT NULL,
  `cp7` float DEFAULT NULL,
  `cp8` float DEFAULT NULL,
  `cp9` float DEFAULT NULL,
  `cp10` float DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `records`
--

LOCK TABLES `records` WRITE;
/*!40000 ALTER TABLE `records` DISABLE KEYS */;
INSERT INTO `records` VALUES (14,18496618,120192594,402.984,15.5469,13.508,6.25763,49.8433,0,0,0,0,0,0,'trikz_eonia',1622801390),(15,146118177,120192594,405.58,47.5703,92.5518,219.61,368.131,0,0,0,0,0,0,'trikz_eonia',1623773423),(16,12298050,120192594,923.199,54.8281,0,0,0,0,0,0,0,0,0,'trikz_eonia',1622704296),(17,120192594,12298050,993.188,0,0,0,0,0,0,0,0,0,0,'trikz_eonia',1623048572),(18,120192594,97826675,456.48,46.6602,0,0,0,0,0,0,0,0,0,'trikz_eonia',1622706681),(19,120192594,61148119,373.906,55.9844,102.562,186.375,333.234,0,0,0,0,0,0,'trikz_eonia',1622886847),(20,120192594,41217631,451.469,46.0781,121.258,209.617,406.562,0,0,0,0,0,0,'trikz_eonia',1622730833),(21,64150955,120192594,4184.31,123.047,347.734,574.172,1745.84,0,0,0,0,0,0,'trikz_eonia',1622822784),(22,120192594,58075991,734,61.8125,135.656,271.656,602.031,0,0,0,0,0,0,'trikz_eonia',1622966553),(23,120192594,61148119,317.969,63.7188,154.844,233.781,301.125,0,0,0,0,0,0,'trikz_cyrus',1623067815),(24,146118177,120192594,1138.06,42.6875,157.75,389.188,682.438,1013.88,0,0,0,0,0,'trikz_adventure',1623227432),(25,146118177,120192594,1776.13,256.125,830.5,1663.42,0,0,0,0,0,0,0,'trikz_soft',1623685420),(26,120192594,58075991,1191.24,93.6875,792.008,1077.26,0,0,0,0,0,0,0,'trikz_soft',1623691212),(27,120192594,180930334,1305.36,233.219,646.25,1194.52,0,0,0,0,0,0,0,'trikz_soft',1623753201);
/*!40000 ALTER TABLE `records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `records1`
--

DROP TABLE IF EXISTS `records1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `records1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) DEFAULT NULL,
  `partnerid` int(11) DEFAULT NULL,
  `time` float DEFAULT NULL,
  `cp1` float DEFAULT NULL,
  `cp2` float DEFAULT NULL,
  `cp3` float DEFAULT NULL,
  `cp4` float DEFAULT NULL,
  `cp5` float DEFAULT NULL,
  `cp6` float DEFAULT NULL,
  `cp7` float DEFAULT NULL,
  `cp8` float DEFAULT NULL,
  `cp9` float DEFAULT NULL,
  `cp10` float DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `records1`
--

LOCK TABLES `records1` WRITE;
/*!40000 ALTER TABLE `records1` DISABLE KEYS */;
/*!40000 ALTER TABLE `records1` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) CHARACTER SET utf8mb4 DEFAULT NULL,
  `steamid` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Smesh',120192594,3080),(2,'ó €¡aaaaa',12298050,560),(3,'ÐÑƒÑ€Ð¸Ðº',18496618,600),(4,'Ñ€ÑƒÑÑÐºÐ¸Ð¹ Ð´Ñ€Ð¸Ð»Ð»',11070,200),(5,'rinnemaru',1108684233,240),(6,'1',135236385,NULL),(7,'VerMon',180930334,40),(8,'1',205045939,NULL),(9,'1',954285328,NULL),(10,'1',185554338,NULL),(11,'unnamed',97826675,NULL),(12,'1',77893865,NULL),(13,'LOn',58075991,40),(14,'1',189222381,NULL),(15,'Mati',146118177,320),(16,'FL3PPY',61148119,120),(17,'1',27128328,NULL),(18,'1',17384004,NULL),(19,'1',1135423021,NULL),(20,'1',14622106,NULL),(21,'1',346817812,NULL),(22,'1',80810556,NULL),(23,'RazoOm',108383178,NULL),(24,'1',69740861,NULL),(25,'2b or not 2b',0,NULL),(26,'RUST1C',1106894729,NULL),(27,'ÐšÐžÐ ÐÐ‘Ð›Ð˜Ðš Ð›Ð®Ð‘Ð’Ð˜',77029426,NULL),(28,'SAV1TAR',41217631,NULL),(29,'Colos Enough !?',240717259,NULL),(30,'DEF',64150955,200),(31,'remember',83111642,NULL),(32,'SEJIYâˆ† * sejiya.ru',54149780,NULL),(33,'meowRin',60226812,NULL),(34,'Zaint',148371419,NULL),(35,'mTi',101384907,NULL),(36,'2b or not 2b',128329572,NULL),(37,'Ð¥Ð¾Ñ€Ð¾ÑˆÐ¸Ð¹',89001873,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zones`
--

DROP TABLE IF EXISTS `zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `map` varchar(128) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `possition_x` float DEFAULT NULL,
  `possition_y` float DEFAULT NULL,
  `possition_z` float DEFAULT NULL,
  `possition_x2` float DEFAULT NULL,
  `possition_y2` float DEFAULT NULL,
  `possition_z2` float DEFAULT NULL,
  `tier` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zones`
--

LOCK TABLES `zones` WRITE;
/*!40000 ALTER TABLE `zones` DISABLE KEYS */;
INSERT INTO `zones` VALUES (1,'trikz_kyoto_final',0,-6864.03,4143.97,1408.03,-7471.97,3241.55,1408.03,5),(2,'trikz_kyoto_final',1,912.031,-3308.72,-2303.97,1775.97,-2708.79,-2303.97,NULL),(5,'trikz_cyrus',0,5742.53,6600.03,4.03125,5010.03,7087.97,4.03125,2),(6,'trikz_cyrus',1,491.975,2068.03,-2921.97,-1003.97,3563.97,-2921.97,NULL),(9,'trikz_adventure',0,231.969,-179.969,64.0312,-231.996,125.881,64.0312,2),(10,'trikz_adventure',1,-15002,9250.03,2134.03,-14552.4,9802.43,2134.04,NULL),(11,'trikz_eonia',0,2688.03,3071.97,7664.03,3295.97,2720.03,7664.03,NULL),(12,'trikz_eonia',1,59.5152,6450.97,9104.03,780.202,7279.8,9104.03,NULL),(13,'trikz_soft',0,8446.72,1886.04,32.0312,8257.61,1634.51,32.0312,NULL),(14,'trikz_soft',1,11945.2,-6105.7,384.031,12213.5,-6341.6,384.031,NULL),(15,'trikz_alpha',0,-1402.97,-14148.8,64.0312,-1157.42,-14394.7,64.0312,NULL),(16,'trikz_alpha',1,5829.72,15802.5,-1983.97,6074.92,15301.2,-1983.97,NULL);
/*!40000 ALTER TABLE `zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zones1`
--

DROP TABLE IF EXISTS `zones1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zones1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `map` varchar(128) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `possition_x` float DEFAULT NULL,
  `possition_y` float DEFAULT NULL,
  `possition_z` float DEFAULT NULL,
  `possition_x2` float DEFAULT NULL,
  `possition_y2` float DEFAULT NULL,
  `possition_z2` float DEFAULT NULL,
  `tier = 1` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zones1`
--

LOCK TABLES `zones1` WRITE;
/*!40000 ALTER TABLE `zones1` DISABLE KEYS */;
/*!40000 ALTER TABLE `zones1` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-06-16 21:41:19
