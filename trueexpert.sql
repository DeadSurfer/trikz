-- MariaDB dump 10.19  Distrib 10.4.22-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: trueexpert
-- ------------------------------------------------------
-- Server version	10.4.22-MariaDB

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
) ENGINE=InnoDB AUTO_INCREMENT=342 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cp`
--

LOCK TABLES `cp` WRITE;
/*!40000 ALTER TABLE `cp` DISABLE KEYS */;
INSERT INTO `cp` VALUES (8,2,9714,9975,-1731,10204,10485,-1475,'trikz_cyrus'),(9,3,-4856,-9289,-3903,-6739,-8727,-3648,'trikz_cyrus'),(10,4,-7643,-5945,-5158,-7153,-5583,-4902,'trikz_cyrus'),(13,1,2512,2232,64,2098,2695,320,'trikz_adventure'),(14,2,12766,-3069,28,12302,-3405,284,'trikz_adventure'),(15,3,5352,-2521,-451,5755,-2918,-195,'trikz_adventure'),(16,4,1914,-7098,744,1495,-6763,1000,'trikz_adventure'),(17,5,-5758,-251,1621,-5423,-400,1877,'trikz_adventure'),(18,1,1664,-2928,15360,2272,-2440,15616,'trikz_eonia'),(19,2,6320,15800,5952,5712,15443,6208,'trikz_eonia'),(20,3,-9808,14197,3232,-11056,13334,3488,'trikz_eonia'),(21,4,4800,-6768,-4288,3863,-4752,-4032,'trikz_eonia'),(23,1,-6640,9200,-608,-7696,9760,-352,'trikz_soft'),(24,2,-128,2692,-240,-415,2402,16,'trikz_soft'),(25,3,-5360,-14712,384,-3600,-16184,640,'trikz_soft'),(26,1,12656,15024,512,11664,14594,768,'trikz_alpha'),(27,2,-2679,-15248,576,-2185,-16240,832,'trikz_alpha'),(28,3,-13168,-2928,-320,-12182,-1939,-64,'trikz_alpha'),(29,4,-13168,8240,96,-12176,7749,352,'trikz_alpha'),(30,1,1373,7749,1878,2215,6984,2134,'trikz_greg'),(31,2,4835,6132,1930,3958,4966,2186,'trikz_greg'),(32,3,252,1600,-3224,-326,2543,-2968,'trikz_greg'),(33,4,9522,-8565,-2220,10475,-8063,-1964,'trikz_greg'),(34,1,-11392,825,-192,-10776,272,64,'trikz_measuregeneric'),(35,2,-2480,5328,-32,-713,6064,224,'trikz_measuregeneric'),(36,3,13232,10832,-1264,12496,9127,-1008,'trikz_measuregeneric'),(38,4,6688,-2608,-2384,7200,-3257,-2128,'trikz_measuregeneric'),(39,1,-448,-176,-736,400,-888,-480,'trikz_learn_hard'),(40,2,-480,-1016,-1056,5,-1708,-800,'trikz_learn_hard'),(41,3,15313,-4193,-1984,16020,-3150,-1728,'trikz_learn_hard'),(42,1,5072,4832,-1696,4057,5952,-1440,'trikz_penguin'),(43,2,4938,8416,-3872,3962,6839,-3616,'trikz_penguin'),(44,3,5344,2688,816,5984,3464,1072,'trikz_penguin'),(45,4,1616,-660,-3832,2104,272,-3576,'trikz_penguin'),(46,1,-10496,-7272,-3648,-9952,-6557,-3392,'trikz_reality'),(47,2,-13976,-7928,-5552,-14760,-8707,-5296,'trikz_reality'),(48,3,-3920,15166,13681,-3428,14311,13937,'trikz_reality'),(49,4,-13738,-48,224,-14177,-336,480,'trikz_reality'),(50,5,1493,969,-1072,1901,600,-816,'trikz_reality'),(51,6,-13828,-4381,-8934,-14660,-3438,-8678,'trikz_reality'),(52,7,-4960,13623,5072,-4016,14344,5328,'trikz_reality'),(53,1,4431,4048,5632,4911,5040,5888,'trikz_RandomRaider'),(54,2,-6064,-592,5504,-5072,-1072,5760,'trikz_RandomRaider'),(55,3,-10768,14288,-448,-10352,15280,-192,'trikz_RandomRaider'),(56,4,6928,9360,-448,7407,10288,-192,'trikz_RandomRaider'),(57,1,-3824,5640,648,-3243,4368,904,'trikz_asdfsda_final'),(58,2,-4160,9960,352,-4928,11335,608,'trikz_asdfsda_final'),(59,3,4960,11244,-496,4192,10611,-240,'trikz_asdfsda_final'),(60,1,-4848,-6728,64,-4137,-7479,320,'trikz_dust_final'),(61,2,-2922,15662,-2048,-2499,15248,-1792,'trikz_dust_final'),(62,3,-12432,13840,-9152,-13040,13104,-8896,'trikz_dust_final'),(63,4,4042,-1680,-13056,5136,-4208,-12800,'trikz_dust_final'),(64,5,2032,-1664,7072,1552,-2048,7328,'trikz_dust_final'),(66,1,-496,-7248,64,48,-7664,320,'trikz_minecraft'),(67,2,3149,-199,-3008,2783,-596,-2752,'trikz_minecraft'),(68,3,7432,283,-5568,5904,-224,-5312,'trikz_minecraft'),(69,4,-8529,10981,4160,-7788,10373,4416,'trikz_minecraft'),(70,5,-7077,6170,-10223,-6564,6604,-9967,'trikz_minecraft'),(71,1,-2248,-4344,314,-1180,-4888,570,'trikz_revolution_final'),(72,2,184,-6520,314,984,-7768,570,'trikz_revolution_final'),(73,3,6264,-4631,-198,7392,-3448,58,'trikz_revolution_final'),(74,4,-6488,-760,-1162,-5175,232,-906,'trikz_revolution_final'),(75,1,8904,5715,-1392,9702,6161,-1136,'trikz_legends_b1'),(76,2,9593,-3705,-928,8857,-3938,-672,'trikz_legends_b1'),(77,3,13033,4263,-1536,13513,5255,-1280,'trikz_legends_b1'),(78,1,2864,3376,512,2032,3056,768,'trikz_proud'),(79,2,10096,14160,6464,8976,15051,6720,'trikz_proud'),(80,3,-14064,3312,-3690,-13444,2256,-3434,'trikz_proud'),(81,4,-7600,6672,5672,-6608,7065,5928,'trikz_proud'),(82,5,-9776,-8240,-8480,-9381,-9136,-8224,'trikz_proud'),(83,1,144,3793,-275,-363,3398,-19,'trikz_forfun'),(84,2,-10190,762,-362,-9687,1284,-106,'trikz_forfun'),(86,4,-5545,-1897,-563,-5877,-1347,-307,'trikz_forfun'),(88,1,-2896,1712,64,-3514,1232,320,'trikz_Desert_b7'),(89,2,-560,-1072,64,-263,-592,320,'trikz_Desert_b7'),(90,3,5232,3360,64,4752,3960,320,'trikz_Desert_b7'),(91,4,-4048,-3408,-64,-4656,-3897,192,'trikz_Desert_b7'),(92,5,2992,-2807,208,2373,-2448,464,'trikz_Desert_b7'),(96,3,6116,-15856,1024,7376,-15248,1280,'trikz_autist'),(97,4,13824,-7739,192,12818,-7248,448,'trikz_autist'),(98,5,160,5154,576,1152,6174,832,'trikz_autist'),(99,1,12768,-6604,-3592,13088,-7288,-3336,'trikz_vintage_final'),(100,2,13868,-2548,-3420,14494,-2884,-3164,'trikz_vintage_final'),(101,3,8166,-5300,-1952,8444,-5559,-1696,'trikz_vintage_final'),(102,4,6410,-6584,-3197,5642,-7280,-2941,'trikz_vintage_final'),(103,1,-432,-1008,-384,-16,-580,-128,'trikz_TinTin'),(104,2,3653,-2630,-499,3832,-2871,-243,'trikz_TinTin'),(105,3,-784,-6640,-512,-1532,-5648,-256,'trikz_TinTin'),(106,4,1552,8720,-1408,1968,9584,-1152,'trikz_TinTin'),(107,1,2951,1584,291,2072,624,547,'trikz_tanyaisawhore'),(108,2,5584,-544,224,4624,-129,480,'trikz_tanyaisawhore'),(109,3,6911,2864,1104,6549,3823,1360,'trikz_tanyaisawhore'),(110,4,-1280,-1552,88,-2682,-984,344,'trikz_tanyaisawhore'),(111,5,-1232,-507,80,-1527,-137,336,'trikz_tanyaisawhore'),(112,6,-2704,-8512,6816,-3530,-7648,7072,'trikz_tanyaisawhore'),(113,1,4326,-425,49,3889,143,305,'trikz_skyway_fixed'),(114,2,89,3805,427,399,3109,683,'trikz_skyway_fixed'),(115,3,-10227,-1154,271,-9945,-1522,527,'trikz_skyway_fixed'),(116,4,-634,-2114,358,-140,-1154,614,'trikz_skyway_fixed'),(117,5,-4826,-2549,64,-4354,-3007,320,'trikz_skyway_fixed'),(118,6,1531,-16338,300,2099,-15868,556,'trikz_skyway_fixed'),(119,1,-2032,1360,-192,-1552,1976,64,'trikz_shutthefuckup'),(120,2,6256,10864,-640,5712,9608,-384,'trikz_shutthefuckup'),(121,3,13168,3472,-1152,12176,5619,-896,'trikz_shutthefuckup'),(122,1,3798,-82,-160,4359,397,96,'trikz_short'),(123,2,7173,1511,-585,6529,2424,-329,'trikz_short'),(124,3,-2994,2424,-1028,-3542,1506,-772,'trikz_short'),(125,1,10539,-5265,-1209,9996,-5553,-953,'trikz_research_laboratories'),(126,2,6619,-7054,-697,6843,-7278,-441,'trikz_research_laboratories'),(127,3,5772,-7347,2102,5611,-7056,2358,'trikz_research_laboratories'),(128,4,-268,-5856,-826,-653,-6464,-570,'trikz_research_laboratories'),(129,5,-5932,-5632,-2746,-6190,-4896,-2490,'trikz_research_laboratories'),(130,6,-4333,-5216,-3769,-3853,-5825,-3513,'trikz_research_laboratories'),(131,7,-1825,-3391,-4809,-1512,-3000,-4550,'trikz_research_laboratories'),(132,8,712,-2106,-3233,1373,-2416,-2977,'trikz_research_laboratories'),(134,9,5901,-7289,-3192,5421,-7458,-2936,'trikz_research_laboratories'),(135,1,-2160,1200,672,-2832,775,928,'trikz_noxious'),(136,2,-11312,3768,88,-10672,3464,344,'trikz_noxious'),(137,3,-9328,1680,288,-8840,2320,544,'trikz_noxious'),(138,4,2800,-1568,-224,2640,-1056,32,'trikz_noxious'),(139,1,3140,1683,-368,2457,2256,-112,'trikz_MoscowDno'),(140,2,1769,5076,-202,2633,5289,54,'trikz_MoscowDno'),(141,3,-1048,5406,-166,-1660,4921,90,'trikz_MoscowDno'),(142,4,3031,-3005,676,3511,-2317,932,'trikz_MoscowDno'),(143,5,-740,3243,-737,-2057,2491,-481,'trikz_MoscowDno'),(144,6,14584,3153,-273,14128,2688,-17,'trikz_MoscowDno'),(145,7,3712,6344,-1032,4576,6616,-776,'trikz_MoscowDno'),(146,8,-4435,8350,-799,-3827,8978,-543,'trikz_MoscowDno'),(147,9,-3786,997,-623,-3166,1605,-367,'trikz_MoscowDno'),(148,1,784,376,0,1136,968,256,'trikz_hammer'),(149,2,-1008,2616,-128,-528,2001,128,'trikz_hammer'),(150,3,4752,-552,-256,4272,-192,0,'trikz_hammer'),(151,4,-1712,4832,-320,-1232,4344,-64,'trikz_hammer'),(152,5,-1712,-3464,640,-1232,-2977,896,'trikz_hammer'),(153,6,5712,5617,128,5232,6111,384,'trikz_hammer'),(154,1,5031,-3112,-154,4547,-4080,102,'trikz_go'),(155,2,-5416,-3108,-1736,-5039,-4080,-1480,'trikz_go'),(156,3,8099,-4080,-1875,7393,-3108,-1619,'trikz_go'),(157,4,9340,-1358,-2340,8548,-2399,-2084,'trikz_go'),(158,1,-3664,6368,512,-4784,5885,768,'Trikz_Failtime'),(159,2,208,4256,-192,625,3392,64,'Trikz_Failtime'),(160,3,784,1632,-576,1013,960,-320,'Trikz_Failtime'),(161,4,-4880,-288,-1024,-6064,-705,-768,'Trikz_Failtime'),(162,5,-720,-3974,-1856,-946,-3231,-1600,'Trikz_Failtime'),(163,6,6015,-2061,-1472,5661,-3059,-1216,'Trikz_Failtime'),(164,1,10320,1584,-240,10937,976,16,'trikz_diversity_final'),(165,2,3600,3376,336,4089,2768,592,'trikz_diversity_final'),(166,3,14896,11984,-320,12425,13232,-64,'trikz_diversity_final'),(167,4,-5200,1232,1280,-5656,2736,1536,'trikz_diversity_final'),(168,5,-8048,-11216,-3007,-7368,-12720,-2752,'trikz_diversity_final'),(169,6,-2000,-7632,-3584,-2728,-8624,-3328,'trikz_diversity_final'),(172,1,113,2032,100,-176,1808,356,'trikz_daemon'),(173,2,-2864,4592,576,-1616,4176,832,'trikz_daemon'),(174,3,2480,720,65,1232,1264,321,'trikz_daemon'),(175,4,3248,-496,512,2577,304,768,'trikz_daemon'),(176,5,-1872,-912,512,-2298,-1648,768,'trikz_daemon'),(177,1,1522,10890,-987,2178,11626,-731,'trikz_blue'),(178,2,-15357,5506,546,-14716,4770,802,'trikz_blue'),(179,3,8495,4465,2071,9231,3729,2327,'trikz_blue'),(180,4,7141,12104,2369,7749,11368,2625,'trikz_blue'),(181,5,-13312,-576,2560,-14384,-2017,2816,'trikz_blue'),(182,1,-4901,259,607,-4165,878,863,'trikz_affinity'),(183,2,-1111,9149,2944,-759,8280,3200,'trikz_affinity'),(184,3,-6292,5240,28,-5300,5722,284,'trikz_affinity'),(186,1,384,7571,-171,-96,7889,85,'trikz_move'),(187,2,712,1502,-672,1704,992,-416,'trikz_move'),(188,3,9385,-485,-1402,8746,216,-1146,'trikz_move'),(190,1,6416,7185,704,7152,7738,960,'trikz_exssses'),(191,2,944,11344,516,1287,10720,772,'trikz_exssses'),(193,3,1842,2944,-144,1595,3416,112,'trikz_exssses'),(194,4,11972,-12967,-13377,10677,-12139,-13121,'trikz_exssses'),(195,3,-1521,-2431,0,-2419,-1733,256,'trikz_forfun'),(198,1,-3713,984,-3768,-3245,1190,-3512,'trikz_shinsekai_final'),(199,2,-15134,3306,820,-14817,3018,1076,'trikz_shinsekai_final'),(202,3,-15884,15550,4033,-15705,15382,4289,'trikz_shinsekai_final'),(203,4,11821,-3221,338,11534,-2253,594,'trikz_shinsekai_final'),(204,5,10603,-8657,4063,12071,-7188,4319,'trikz_shinsekai_final'),(205,1,-13472,616,0,-12800,0,256,'trikz_krepix'),(206,2,-8112,-15712,-496,-6864,-15463,-240,'trikz_krepix'),(207,3,-5328,-8392,-288,-4720,-7895,-32,'trikz_krepix'),(208,4,13456,-11888,-128,14192,-10408,128,'trikz_krepix'),(209,5,2448,-3152,192,3408,-2727,448,'trikz_krepix'),(210,1,48,-3056,705,-688,-2248,960,'trikz_kyoto_final'),(211,2,-3440,14032,2432,-2832,14454,2688,'trikz_kyoto_final'),(212,3,4856,13040,1472,4048,11984,1728,'trikz_kyoto_final'),(213,4,-3440,-5008,-12416,-1808,-6069,-12160,'trikz_kyoto_final'),(214,5,48,9136,10049,-1072,8144,10305,'trikz_kyoto_final'),(215,6,-13241,14640,-8448,-12424,13008,-8192,'trikz_kyoto_final'),(216,4,-6845,12186,46,-7837,10681,302,'trikz_affinity'),(218,1,-14587,-8748,4032,-15071,-9072,4288,'trikz_VICTORY'),(219,2,-9975,-4764,3057,-9559,-5219,3313,'trikz_VICTORY'),(220,3,-5777,543,3933,-6946,-257,4189,'trikz_VICTORY'),(221,4,-1412,10410,-1427,-1086,10117,-1171,'trikz_VICTORY'),(222,5,-749,-9029,-8877,-903,-9477,-8621,'trikz_VICTORY'),(223,6,15303,4129,8842,14732,3009,9098,'trikz_VICTORY'),(225,1,848,-432,128,1456,-137,384,'trikz_devision'),(226,2,1744,-432,-320,2608,112,-64,'trikz_devision'),(227,3,3020,-432,-320,3884,111,-64,'trikz_devision'),(228,4,4432,-432,-310,5288,249,-56,'trikz_devision'),(229,5,8368,-432,-1024,6992,1103,-768,'trikz_devision'),(230,1,-2864,-1592,-288,-1840,-912,-32,'trikz_learn'),(231,2,1248,1184,64,924,576,320,'trikz_learn'),(233,1,-2229,-897,-480,-2086,-1212,-224,'trikz_sun'),(234,2,-1765,1255,-358,-1609,997,-127,'trikz_sun'),(235,3,-3002,4541,-304,-2648,5117,-48,'trikz_sun'),(236,4,-3011,4310,-882,-2448,3745,-635,'trikz_sun'),(237,5,-3606,1505,-360,-3272,1891,-128,'trikz_sun'),(238,1,7341,-14034,-597,7717,-13686,-341,'trikz_unorthodox'),(240,2,-242,-14594,-2246,-1620,-14126,-1990,'trikz_unorthodox'),(241,3,-5234,-7046,514,-5652,-7531,770,'trikz_unorthodox'),(242,4,-838,2100,-229,-1416,1612,27,'trikz_unorthodox'),(243,5,8827,3985,-152,8569,4434,104,'trikz_unorthodox'),(244,1,-3472,720,64,-3832,944,320,'trikz_overdriver'),(245,2,-4080,2832,-320,-3088,3568,-64,'trikz_overdriver'),(246,1,5044,8040,-3200,4820,7336,-2944,'trikz_p'),(247,2,11940,-888,-2432,11204,-1185,-2176,'trikz_p'),(248,3,-6945,10440,64,-7253,11176,320,'trikz_p'),(249,1,2262,1331,-108,1437,1688,148,'trikz_cool'),(250,2,425,9811,-170,-58,10705,86,'trikz_cool'),(251,3,-12227,1452,-309,-13017,1025,-53,'trikz_cool'),(252,4,-12855,4968,-1730,-12546,4113,-1474,'trikz_cool'),(253,5,-7435,-10578,-1569,-6376,-10096,-1313,'trikz_cool'),(254,6,-1764,-2694,-1615,-1231,-4044,-1359,'trikz_cool'),(255,1,-14512,9839,608,-14193,10832,864,'trikz_brink'),(256,2,-14773,3723,704,-14218,4660,960,'trikz_brink'),(257,3,-12928,-2336,-560,-13280,-2568,-304,'trikz_brink'),(258,4,-265,-4120,-3096,-745,-4609,-2840,'trikz_brink'),(259,5,-12000,10125,-5424,-9896,11117,-5168,'trikz_brink'),(260,6,15729,-12776,-13080,15177,-12031,-12824,'trikz_brink'),(261,1,1680,-2416,1024,1828,-2192,1280,'trikz_cosmos_fix'),(262,2,7144,-11280,-1736,6470,-11440,-1480,'trikz_cosmos_fix'),(263,3,8496,9488,-5504,8208,9968,-5248,'trikz_cosmos_fix'),(264,4,8304,4760,-7152,7880,4088,-6896,'trikz_cosmos_fix'),(267,6,-3866,-15248,-8832,-3379,-14974,-8576,'trikz_cosmos_fix'),(269,7,13648,5368,7936,13415,4552,8192,'trikz_cosmos_fix'),(270,1,7920,-3312,1024,7304,-2704,1280,'trikz_inspaire'),(271,2,-2512,9072,-1146,-2055,8464,-896,'trikz_inspaire'),(272,3,-8208,-10160,-4496,-7720,-9680,-4240,'trikz_inspaire'),(273,4,-8976,7920,-656,-10352,7432,-400,'trikz_inspaire'),(274,1,7760,-7760,896,7536,-7992,1152,'trikz_measuregeneric2'),(275,2,7888,-10231,-192,7504,-9928,64,'trikz_measuregeneric2'),(277,3,-1520,1888,1728,-2216,2592,1984,'trikz_measuregeneric2'),(278,4,976,-48,2080,2104,160,2336,'trikz_measuregeneric2'),(280,1,5456,-368,6432,5108,-1072,6688,'trikz_kart'),(281,2,8304,3056,4992,6992,2445,5248,'trikz_kart'),(282,3,-3911,-4112,3936,-3720,-4336,4192,'trikz_kart'),(283,1,-9968,12896,-1296,-9488,13376,-1040,'trikz_pharaohs_tomb'),(284,2,-1376,432,-1072,-640,201,-816,'trikz_pharaohs_tomb'),(285,3,-4320,-2144,-176,-5792,-1548,80,'trikz_pharaohs_tomb'),(286,4,-4288,4688,-6144,-5952,5280,-5888,'trikz_pharaohs_tomb'),(287,5,-10704,-16304,-4656,-8944,-15244,-4400,'trikz_pharaohs_tomb'),(288,1,6224,4896,80,5896,4176,336,'trikz_bbdd'),(289,2,-4744,15856,432,-5512,15136,688,'trikz_bbdd'),(290,3,-4688,576,-2080,-3888,40,-1824,'trikz_bbdd'),(291,4,-6592,-656,-4000,-5792,-1400,-3744,'trikz_bbdd'),(292,5,-3312,-5360,-1936,-2512,-4984,-1680,'trikz_bbdd'),(293,1,-496,13584,-96,496,14576,160,'trikz_green'),(294,2,-1936,-880,80,-1649,-497,336,'trikz_green'),(295,3,-2544,-9184,-3344,-3536,-8416,-3088,'trikz_green'),(296,4,2112,-10368,-3344,3104,-9856,-3088,'trikz_green'),(297,5,6256,-2048,-8736,5264,-2560,-8480,'trikz_green'),(299,6,48,11920,-12800,1104,12784,-12544,'trikz_green'),(305,1,8289,9997,-144,7557,9507,112,'trikz_cyrus'),(315,2,-1962,2389,-127.969,-2224,2539,0.03125,'trikz_visuals'),(316,6,-1866,3040,-127.969,-2569,2251,0.03125,'trikz_visuals'),(317,5,-2448,1959,-127.969,-2290,2578,0.03125,'trikz_visuals'),(319,4,-1808,1583,-127.969,-1956,1727,0.03125,'trikz_visuals'),(320,7,-2767,3023,-127.969,-2644,2889,0.03125,'trikz_visuals'),(321,8,-2768,2791,-127.969,-2611,2580,0.0625,'trikz_visuals'),(322,9,-2768,2458,-127.969,-2680,2344,0.0625,'trikz_visuals'),(323,10,-2768,2176,-127.969,-2655,2072,0.0625,'trikz_visuals'),(324,3,-2198,1916,136,-1993,1786,-120,'trikz_visuals'),(327,3,-2869,5236,-208,-2307,4461,91,'trikz_learn'),(331,1,-2556,1902,-127.969,-2458,2008,128.031,'trikz_visuals'),(332,1,-10224,-4714,-192,-10832,-5333,64,'trikz_autist'),(333,2,-1824,-4912,-320,-2560,-5905,608,'trikz_autist'),(336,2,8584,7560,-6271.97,9304,8536,-6015.97,'trikz_misery'),(337,1,760,10072,-2559.97,-248,9096,-2303.97,'trikz_misery'),(338,3,-4600,13432,-6143.97,-3848,12424,-5887.97,'trikz_misery'),(339,4,4744,9848,-8575.97,5240,8840,-8319.97,'trikz_misery'),(341,5,4136,-1288,-11776,4984,-2296,-11520,'trikz_misery');
/*!40000 ALTER TABLE `cp` ENABLE KEYS */;
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
  `finishes` int(11) DEFAULT NULL,
  `tries` int(11) DEFAULT NULL,
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
  `points` int(11) DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=591 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tier`
--

DROP TABLE IF EXISTS `tier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tier` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tier` int(11) DEFAULT NULL,
  `map` varchar(192) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tier`
--

LOCK TABLES `tier` WRITE;
/*!40000 ALTER TABLE `tier` DISABLE KEYS */;
INSERT INTO `tier` VALUES (1,4,'trikz_kyoto_final'),(3,2,'trikz_cyrus'),(4,3,'trikz_adventure'),(8,3,'trikz_soft'),(10,3,'trikz_alpha'),(13,3,'trikz_measuregeneric'),(15,1,'trikz_learn_hard'),(17,2,'trikz_penguin'),(19,6,'trikz_reality'),(21,2,'trikz_RandomRaider'),(23,2,'trikz_asdfsda_final'),(25,3,'trikz_dust_final'),(27,2,'trikz_minecraft'),(29,2,'trikz_revolution_final'),(31,2,'trikz_legends_b1'),(33,2,'trikz_proud'),(35,2,'trikz_forfun'),(37,3,'trikz_Desert_b7'),(39,3,'trikz_autist'),(41,3,'trikz_vintage_final'),(43,3,'trikz_TinTin'),(45,3,'trikz_tanyaisawhore'),(47,3,'trikz_skyway_fixed'),(49,1,'trikz_shutthefuckup'),(51,1,'trikz_short'),(55,2,'trikz_noxious'),(56,3,'trikz_MoscowDno'),(58,3,'trikz_hammer'),(60,3,'trikz_go'),(62,3,'Trikz_Failtime'),(64,4,'trikz_diversity_final'),(66,1,'trikz_daemon'),(69,3,'trikz_blue'),(71,3,'trikz_affinity'),(73,1,'trikz_move'),(75,3,'trikz_exssses'),(77,3,'trikz_research_laboratories'),(78,4,'trikz_shinsekai_final'),(80,4,'trikz_krepix'),(82,2,'trikz_greg'),(88,2,'trikz_eonia'),(89,4,'trikz_VICTORY'),(90,2,'trikz_devision'),(91,2,'trikz_learn'),(92,2,'trikz_sun'),(93,3,'trikz_unorthodox'),(94,1,'trikz_overdriver'),(96,2,'trikz_p'),(97,2,'trikz_cool'),(98,4,'trikz_brink'),(99,6,'trikz_cosmos_fix'),(100,5,'trikz_inspaire'),(101,6,'trikz_measuregeneric2'),(102,5,'trikz_kart'),(103,5,'trikz_pharaohs_tomb'),(104,5,'trikz_bbdd'),(105,5,'trikz_green'),(107,2,'trikz_misery'),(112,1,'trikz_visuals');
/*!40000 ALTER TABLE `tier` ENABLE KEYS */;
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
  `geoipcode2` varchar(64) DEFAULT NULL,
  `firstjoin` int(11) DEFAULT NULL,
  `lastjoin` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=590 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=186 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zones`
--

LOCK TABLES `zones` WRITE;
/*!40000 ALTER TABLE `zones` DISABLE KEYS */;
INSERT INTO `zones` VALUES (1,'trikz_kyoto_final',0,-6864,4144,1408,-7472,3242,1664),(2,'trikz_kyoto_final',1,912,-3309,-2304,1776,-2709,-2048),(6,'trikz_cyrus',1,497,2063,-2922,-1009,3569,-2666),(9,'trikz_adventure',0,232,-180,64,-232,126,320),(10,'trikz_adventure',1,-15002,9266,2134,-14536,9738,2390),(11,'trikz_eonia',0,2688,3072,7664,3296,2720,7920),(12,'trikz_eonia',1,60,6451,9104,732,7280,9360),(13,'trikz_soft',0,8447,1886,32,8258,1635,288),(14,'trikz_soft',1,11945,-6106,384,12214,-6342,640),(15,'trikz_alpha',0,-1403,-14149,64,-1157,-14395,320),(16,'trikz_alpha',1,5830,15802,-1984,6075,15301,-1728),(18,'trikz_greg',1,2349,-7287,680,6689,-10364,936),(19,'trikz_measuregeneric',0,-560,16,48,-16,560,304),(20,'trikz_measuregeneric',1,560,-176,64,1008,-624,320),(21,'trikz_learn_hard',0,-448,480,-736,80,-96,-480),(22,'trikz_learn_hard',1,5514,-3760,-2429,6575,-2819,-2173),(23,'trikz_penguin',0,-1072,1376,-1696,-516,640,-1440),(24,'trikz_penguin',1,1136,2310,-3470,94,3352,-3214),(25,'trikz_reality',0,1336,14728,7680,1689,15464,7936),(26,'trikz_reality',1,-12632,2584,-3963,-13137,2392,-3707),(27,'trikz_RandomRaider',0,80,-48,5888,1072,432,6144),(28,'trikz_RandomRaider',1,10176,9159,-1056,10208,9430,-800),(29,'trikz_asdfsda_final',0,-5176,7120,8,-5712,6648,264),(30,'trikz_asdfsda_final',1,6744,11253,640,7208,11989,896),(31,'trikz_dust_final',0,-13744,-7000,207,-13377,-7288,476),(32,'trikz_dust_final',1,-8114,7764,11152,-8783,7440,11398),(33,'trikz_minecraft',0,432,-912,0,-144,-528,256),(34,'trikz_minecraft',1,975,2448,-1536,-751,4588,-1280),(35,'trikz_revolution_final',0,2232,-1819,314,3032,-2276,570),(36,'trikz_revolution_final',1,1754,10770,1319,2204,10922,1575),(37,'trikz_legends_b1',0,4713,8999,-1255,5026,8487,-999),(38,'trikz_legends_b1',1,104,-496,-256,-402,-32,0),(39,'trikz_proud',0,1488,80,512,1904,272,768),(40,'trikz_proud',1,-14640,11728,584,-13392,12848,840),(41,'trikz_forfun',0,-344,-676,33,144,-189,289),(42,'trikz_forfun',1,-8248,-43,-690,-6682,1354,-434),(43,'trikz_Desert_b7',0,-496,-496,64,-16,-261,320),(44,'trikz_Desert_b7',1,4112,-2736,207,5104,-2064,534),(45,'trikz_autist',0,-15484,764,64,-14851,387,320),(46,'trikz_autist',1,-577,6706,576,-832,7087,832),(47,'trikz_vintage_final',0,12304,-10672,-3444,11984,-10277,-3188),(48,'trikz_vintage_final',1,12360,-11360,-3452,11880,-10880,-3196),(49,'trikz_TinTin',0,3056,2160,64,2576,1669,320),(50,'trikz_TinTin',1,3792,5744,-1408,5296,4240,-1152),(51,'trikz_tanyaisawhore',0,-48,480,32,507,-480,288),(52,'trikz_tanyaisawhore',1,-40,56,1592,55,-55,1848),(53,'trikz_skyway_fixed',0,-819,143,64,-138,-425,320),(54,'trikz_skyway_fixed',1,669,-4052,730,1117,-4500,988),(55,'trikz_shutthefuckup',0,-688,240,64,-135,-304,320),(56,'trikz_shutthefuckup',1,10736,8688,-1152,8720,6672,-896),(57,'trikz_short',0,-496,344,64,174,-28,320),(58,'trikz_short',1,-2623,529,-1834,-4572,-1480,-1576),(60,'trikz_research_laboratories',1,1327,-13624,-1990,2319,-12632,-1734),(62,'trikz_noxious',1,2546,960,-128,2910,656,128),(63,'trikz_noxious',0,320,-256,64,-200,256,320),(64,'trikz_MoscowDno',0,48,-1175,-127,-432,-1688,128),(65,'trikz_MoscowDno',1,5202,11246,-1094,6562,9230,-838),(66,'trikz_hammer',0,-135,-88,32,134,103,288),(67,'trikz_hammer',1,3928,-4905,-384,4408,-5320,-128),(68,'trikz_go',0,15359,-4080,-134,14553,-3112,122),(69,'trikz_go',1,14874,-6118,-928,15826,-5170,-671),(70,'Trikz_Failtime',0,3552,5040,-208,3194,5392,48),(71,'Trikz_Failtime',1,3694,-508,-342,2642,286,-86),(72,'trikz_diversity_final',0,12896,-2800,80,12230,-2320,336),(73,'trikz_diversity_final',1,11824,-7312,-512,10320,-8816,-256),(74,'trikz_daemon',0,-48,80,66,432,560,322),(75,'trikz_daemon',1,-3568,3376,704,-3088,2896,960),(76,'trikz_cyrus',0,5005,7093,4,5735,6595,260),(77,'trikz_blue',0,-8500,10877,-907,-8123,11638,-651),(78,'trikz_blue',1,-10963,11744,2944,-10035,10816,3200),(79,'trikz_affinity',0,32,-124,128,745,500,384),(81,'trikz_move',0,-96,-5406,620,384,-4598,876),(82,'trikz_move',1,6363,3447,-1725,7424,2506,-1469),(83,'trikz_exssses',0,-595,5391,128,-301,5686,384),(84,'trikz_exssses',1,-4694,-12847,-14277,-5143,-12398,-14021),(85,'trikz_research_laboratories',0,7602,-8274,978,8172,-8558,1234),(86,'trikz_shinsekai_final',0,-1177,1494,2090,-689,976,2346),(87,'trikz_shinsekai_final',1,2039,-9165,4792,3007,-9640,5048),(88,'trikz_krepix',0,-13840,16272,224,-14320,15912,480),(89,'trikz_krepix',1,6048,11184,2176,6240,11408,2432),(90,'trikz_greg',0,-4716,9063,-6732,-4326,8402,-6476),(91,'trikz_affinity',1,3711,2455,2880,2975,3110,3136),(92,'trikz_VICTORY',0,-8983,-13520,4292,-9463,-14128,4548),(93,'trikz_VICTORY',1,14192,3397,9822,14444,3738,10078),(96,'trikz_devision',0,304,-432,128,-304,-23,384),(97,'trikz_devision',1,10432,7600,-1023,9214,6472,-767),(98,'trikz_learn',0,-320,-64,64,208,512,320),(99,'trikz_learn',1,-4112,4080,512,-4624,3472,770),(101,'trikz_sun',1,-1609,2604,-147,-1030,3051,128),(102,'trikz_unorthodox',0,5422,-11195,-37,6205,-10710,219),(103,'trikz_unorthodox',1,15134,-1404,963,14528,-806,1219),(104,'trikz_overdriver',0,-1008,-176,0,-16,300,256),(105,'trikz_overdriver',1,-4880,5679,-4288,-5487,5265,-4032),(106,'trikz_p',0,309,4427,12,398,4531,280),(107,'trikz_p',1,-8396,3400,-320,-6348,4488,-64),(108,'trikz_cool',0,-682,48,-173,-414,528,83),(109,'trikz_cool',1,-362,-10020,-3338,-2304,-7953,-3082),(110,'trikz_sun',0,-752,222,-225,-971,741,31),(111,'trikz_brink',0,-15312,13904,0,-14736,13681,256),(112,'trikz_brink',1,10120,-1320,-7432,9896,-1065,-7176),(113,'trikz_cosmos_fix',0,-130,4815,-438,-443,4559,-182),(114,'trikz_cosmos_fix',1,4528,-15687,5836,4065,-15557,6092),(115,'trikz_inspaire',0,-758,266,0,-139,885,256),(116,'trikz_inspaire',1,1525,5110,-2880,1163,4747,-2624),(117,'trikz_measuregeneric2',0,-2024,-1776,384,-1736,-1488,640),(118,'trikz_measuregeneric2',1,8336,-14096,2208,8784,-14544,2464),(119,'trikz_kart',0,-13871,-519,6912,-13577,-920,7168),(120,'trikz_kart',1,11927,7306,10112,11514,7702,10368),(121,'trikz_pharaohs_tomb',0,-240,-384,-48,240,247,208),(122,'trikz_pharaohs_tomb',1,4496,1904,-8192,5744,651,-7936),(123,'trikz_bbdd',0,432,921,80,-224,432,336),(124,'trikz_bbdd',1,5784,-912,-1344,5385,-1143,-1088),(125,'trikz_green',0,-496,-208,-128,496,272,128),(126,'trikz_green',1,-736,-3008,-208,-304,-2737,48),(181,'trikz_visuals',1,-2727,1721,-127.969,-2628,1841,128.031),(183,'trikz_visuals',0,-2618,1626,-126.969,-2744,1600,128.031),(184,'trikz_misery',1,12912,-11792,-12032,11664,-12656,-11776),(185,'trikz_misery',0,2960,11632,-1535.97,3312,10640,-1279.97);
/*!40000 ALTER TABLE `zones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-02-05 14:48:48
