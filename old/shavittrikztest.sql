-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1
-- Время создания: Май 16 2021 г., 20:15
-- Версия сервера: 10.4.10-MariaDB
-- Версия PHP: 7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `shavittrikztest`
--

DELIMITER $$
--
-- Функции
--
CREATE DEFINER=`root`@`localhost` FUNCTION `GetRecordPoints` (`rstyle` INT, `rtrack` INT, `rtime` FLOAT, `rmap` VARCHAR(128), `pointspertier` FLOAT, `stylemultiplier` FLOAT) RETURNS FLOAT READS SQL DATA
BEGIN DECLARE pwr, ppoints FLOAT DEFAULT 0.0; DECLARE ptier INT DEFAULT 1; SELECT tier FROM maptiers WHERE map = rmap INTO ptier; SELECT MIN(time) FROM playertimes WHERE map = rmap AND style = rstyle AND track = rtrack INTO pwr; IF rtrack > 0 THEN SET ptier = 1; END IF; SET ppoints = ((pointspertier * ptier) * 1.5) + (pwr / 15.0); IF rtime > pwr THEN SET ppoints = ppoints * (pwr / rtime); END IF; SET ppoints = ppoints * stylemultiplier; IF rtrack > 0 THEN SET ppoints = ppoints * 0.25; END IF; RETURN ppoints; END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetWeightedPoints` (`steamid` INT) RETURNS FLOAT READS SQL DATA
BEGIN DECLARE p FLOAT; DECLARE total FLOAT DEFAULT 0.0; DECLARE mult FLOAT DEFAULT 1.0; DECLARE done INT DEFAULT 0; DECLARE cur CURSOR FOR SELECT points FROM playertimes WHERE (auth = steamid OR partner = steamid) AND points > 0.0 ORDER BY points DESC; DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1; OPEN cur; iter: LOOP FETCH cur INTO p; IF done THEN LEAVE iter; END IF; SET total = total + (p * mult); SET mult = mult * 0.975000; END LOOP; CLOSE cur; RETURN total; END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `chat`
--

CREATE TABLE `chat` (
  `auth` int(11) NOT NULL,
  `name` int(11) NOT NULL DEFAULT 0,
  `ccname` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` int(11) NOT NULL DEFAULT 0,
  `ccmessage` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `maptiers`
--

CREATE TABLE `maptiers` (
  `map` varchar(128) NOT NULL,
  `tier` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `maptiers`
--

INSERT INTO `maptiers` (`map`, `tier`) VALUES
('bhop_123x', 1),
('css', 1),
('de_dust', 1),
('de_dust2', 1),
('de_dust2_unlimited', 1),
('l33t', 1),
('surf_dust2005_final', 1),
('surf_dust2008_final', 1),
('test01', 1),
('trikz_2_hard', 1),
('trikz_absinthe', 1),
('trikz_abuze_v2', 1),
('trikz_addict_final', 1),
('trikz_advanced', 1),
('trikz_advenced', 1),
('trikz_adventure', 1),
('trikz_affinity', 1),
('trikz_ahorma', 1),
('trikz_airtime', 1),
('trikz_alpha', 1),
('trikz_alteria_final', 1),
('trikz_angell', 1),
('trikz_aportal', 1),
('trikz_approximatif', 1),
('trikz_aroundtheworld_v3', 1),
('trikz_asdfsda_final', 1),
('trikz_asux', 1),
('trikz_aura', 1),
('trikz_autist', 1),
('trikz_bars', 1),
('trikz_bbdd', 1),
('trikz_bignstrong', 1),
('trikz_blue', 1),
('trikz_brink', 1),
('trikz_brisingr', 1),
('trikz_clarity', 1),
('trikz_colors', 1),
('trikz_colors_noblack3', 1),
('trikz_concret', 1),
('trikz_cool', 1),
('trikz_coop_mini', 1),
('trikz_cosmos_fix', 1),
('trikz_cyrus', 1),
('trikz_daemon', 1),
('trikz_deserted_v2', 1),
('trikz_desert_b7', 1),
('trikz_devision', 1),
('trikz_dev_final', 1),
('trikz_diversity_final', 1),
('trikz_dream', 1),
('trikz_e1m', 1),
('trikz_eonia', 1),
('trikz_eternity', 1),
('trikz_ethereal', 1),
('trikz_ethereal2', 1),
('trikz_expertzone', 1),
('trikz_exssses', 1),
('trikz_extra', 1),
('trikz_extreme_final', 1),
('trikz_factory_v3', 1),
('trikz_failtime', 1),
('trikz_fapfap', 1),
('trikz_firsttime', 1),
('trikz_forfun', 1),
('trikz_foryou_b4', 1),
('trikz_fpsgamerz_banana_v2', 1),
('trikz_go', 1),
('trikz_greg', 1),
('trikz_hammer', 1),
('trikz_howtodo', 1),
('trikz_insanity', 1),
('trikz_insomnia', 1),
('trikz_inspaire', 1),
('trikz_invincible_b2', 1),
('trikz_krepix', 1),
('trikz_kyoto_final', 1),
('trikz_kyoto_fix', 1),
('trikz_l33t', 1),
('trikz_learn', 1),
('trikz_learn_hard', 1),
('trikz_legends_b1', 1),
('trikz_lego_fix', 1),
('trikz_lizawhorez_fix', 1),
('trikz_lucky', 1),
('trikz_measuregeneric', 1),
('trikz_measuregeneric2', 1),
('trikz_mh', 1),
('trikz_milk_final', 1),
('trikz_minecraft', 1),
('trikz_mom', 1),
('trikz_move', 1),
('trikz_myinstyle', 1),
('trikz_newmap', 2),
('trikz_newmap2', 3),
('trikz_newmap3', 1),
('trikz_newmap3_prelast', 1),
('trikz_noflash', 1),
('trikz_noxious', 1),
('trikz_ocean', 1),
('trikz_oof', 1),
('trikz_overdriver', 1),
('trikz_p4p3r', 1),
('trikz_penguin', 1),
('trikz_penguin_fix', 1),
('trikz_pentrix', 1),
('trikz_pewpew', 1),
('trikz_pharaohs_tomb', 1),
('trikz_portal2', 1),
('trikz_portal_final', 1),
('trikz_proud', 1),
('trikz_randomraider_fix', 1),
('trikz_reality', 1),
('trikz_reality_openbeta', 1),
('trikz_research_laboratories', 1),
('trikz_revolution_final', 1),
('trikz_sakura_final', 1),
('trikz_shinsekai_final', 1),
('trikz_shokirlegend', 1),
('trikz_short', 1),
('trikz_shutthefuckup', 1),
('trikz_simplicity', 1),
('trikz_simplicity2', 1),
('trikz_skyway_fixed', 1),
('trikz_smile', 1),
('trikz_soft', 2),
('trikz_speed', 1),
('trikz_suicidal', 1),
('trikz_suicidal_final', 1),
('trikz_sun', 1),
('trikz_tanyaisawhore', 1),
('trikz_tintin', 1),
('trikz_unorthodox', 1),
('trikz_victory', 1),
('trikz_vintage_final', 1),
('trikz_visuals', 1),
('trikz_vpizdu', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `mapzones`
--

CREATE TABLE `mapzones` (
  `id` int(11) NOT NULL,
  `map` varchar(128) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `corner1_x` float DEFAULT NULL,
  `corner1_y` float DEFAULT NULL,
  `corner1_z` float DEFAULT NULL,
  `corner2_x` float DEFAULT NULL,
  `corner2_y` float DEFAULT NULL,
  `corner2_z` float DEFAULT NULL,
  `destination_x` float NOT NULL DEFAULT 0,
  `destination_y` float NOT NULL DEFAULT 0,
  `destination_z` float NOT NULL DEFAULT 0,
  `track` int(11) NOT NULL DEFAULT 0,
  `flags` int(11) NOT NULL DEFAULT 0,
  `data` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `mapzones`
--

INSERT INTO `mapzones` (`id`, `map`, `type`, `corner1_x`, `corner1_y`, `corner1_z`, `corner2_x`, `corner2_y`, `corner2_z`, `destination_x`, `destination_y`, `destination_z`, `track`, `flags`, `data`) VALUES
(1, 'trikz_cyrus', 0, 5010, 6600, 5.031, 5746, 7088, 132.031, 0, 0, 0, 0, 0, 0),
(2, 'trikz_cyrus', 1, -896, 3472, -2920.97, -736, 3344, -2793.97, 0, 0, 0, 0, 0, 0),
(3, 'trikz_cyrus', 0, -11794, 509, -395.468, -11306, 296, -268.468, 0, 0, 0, 2, 0, 0),
(4, 'trikz_cyrus', 3, -11794, 646, -395.468, -11306, 555, -268.468, 0, 0, 0, 2, 0, 0),
(5, 'trikz_cyrus', 1, -535, 2980, -2920.97, -874, 2644, -2793.97, 0, 0, 0, 2, 0, 0),
(6, 'trikz_alpha', 0, -1404, -14147, 65.029, -1156, -14397, 192.031, 0, 0, 0, 0, 0, 0),
(7, 'trikz_alpha', 1, 6076, 15300, -1982.97, 5828, 15804, -1855.97, 0, 0, 0, 0, 0, 0),
(8, 'trikz_alpha', 0, 6652, 15300, -1982.97, 6403, 15804, -1855.97, 0, 0, 0, 2, 0, 0),
(9, 'trikz_alpha', 1, 15492, -9084, -958.968, 15997, -8836, -830.493, 0, 0, 0, 2, 0, 0),
(10, 'trikz_alpha', 0, 15996, -9348, -958.968, 15491, -9532, -831.968, 0, 0, 0, 4, 0, 0),
(11, 'trikz_alpha', 1, 12675, -7461, -798.968, 13181, -7211, -671.968, 0, 0, 0, 4, 0, 0),
(12, 'trikz_cyrus', 0, -560, 3488, -2920.97, -688, 3408, -2793.97, 0, 0, 0, 4, 0, 0),
(13, 'trikz_cyrus', 1, -592, 3280, -2920.97, -704, 3200, -2793.97, 0, 0, 0, 4, 0, 0),
(14, 'trikz_cyrus', 3, -6057, 7408, -1518.97, -5958, 7424, -1391.97, 0, 0, 0, 4, 0, 0),
(17, 'trikz_alpha', 3, 15760, -9216, -958.968, 15728, -9280, -831.968, 0, 0, 0, 4, 0, 0),
(18, 'trikz_eonia', 0, 3293, 3072, 7665.03, 2691, 2950, 7792.03, 0, 0, 0, 0, 0, 0),
(19, 'trikz_eonia', 1, 480, 3856, 8721.03, 288, 5099, 8848.03, 0, 0, 0, 0, 0, 0),
(20, 'trikz_daemon', 0, 432, 80, 67.031, -48, 560, 194.031, 0, 0, 0, 0, 0, 0),
(21, 'trikz_daemon', 7, -2848, 4411, 577.031, -2827, 4347, 704.031, -2803.89, 4378.35, 578.031, 0, 0, 0),
(23, 'trikz_kyoto_final', 0, -10880, -3984, 5505.03, -10816, -4032, 5632.03, 0, 0, 0, 0, 0, 0),
(25, 'trikz_kyoto_final', 7, -9792, -3584, 5505.03, -10112, -4096, 5632.03, -10430.7, -3616.54, 5506.03, 0, 0, 0),
(26, 'trikz_research_laboratories', 0, 6224, -6688, -695.968, 6128, -6608, -568.968, 0, 0, 0, 4, 0, 0),
(27, 'trikz_visuals', 0, 7872, 6960, -3006.97, 7984, 7056, -2879.97, 0, 0, 0, 4, 0, 0),
(28, 'trikz_randomraider_fix', 0, 7152, -12848, 10273, 7040, -12368, 10400, 0, 0, 0, 4, 0, 0),
(29, 'trikz_measuregeneric', 0, -8032, -656, -13135, -7888, -752, -13008, 0, 0, 0, 4, 0, 0),
(30, 'trikz_newmap', 0, 8256, 1888, 33.031, 8448, 1632, 160.031, 0, 0, 0, 0, 0, 0),
(31, 'trikz_newmap', 1, 12216, -6104, 385.031, 11944, -6344, 512.031, 0, 0, 0, 0, 0, 0),
(32, 'trikz_newmap', 0, 13224, -5936, 385.031, 13560, -6512, 512.031, 0, 0, 0, 4, 0, 0),
(33, 'trikz_newmap', 1, 15768, -1328, 185.031, 15336, -1760, 312.031, 0, 0, 0, 4, 0, 0),
(62, 'trikz_newmap', 3, 13328, -5880, 385.031, 13456, -5872, 512.031, 0, 0, 0, 4, 0, 0),
(63, 'trikz_newmap', 3, 13456, -6568, 385.031, 13328, -6576, 512.031, 0, 0, 0, 4, 0, 0),
(64, 'trikz_newmap', 3, 13168, -6512, 385.031, 13160, -5912, 512.031, 0, 0, 0, 4, 0, 0),
(65, 'trikz_newmap2', 1, -1248, -14656, 65.031, -1200, -14560, 192.031, 0, 0, 0, 4, 0, 0),
(66, 'trikz_newmap2', 0, -1104, -14560, 65.031, -1168, -14496, 192.031, 0, 0, 0, 4, 0, 0),
(67, 'trikz_newmap2', 1, 15492, -9084, -958.968, 15996, -8836, -831.968, 0, 0, 0, 2, 0, 0),
(68, 'trikz_newmap2', 0, -1404, -14148, 65.031, -1156, -14396, 192.031, 0, 0, 0, 0, 0, 0),
(69, 'trikz_newmap2', 0, 6404, 15804, -1982.97, 6652, 15300, -1855.97, 0, 0, 0, 2, 0, 0),
(70, 'trikz_newmap2', 1, 6076, 15300, -1982.97, 5828, 15804, -1855.97, 0, 0, 0, 0, 0, 0),
(71, 'trikz_affinity', 0, 544, 32, 129.031, 240, 336, 256.031, 0, 0, 0, 0, 0, 0),
(72, 'trikz_greg', 0, -4716, 9064, -6730.97, -4320, 8400, -6604.47, 0, 0, 0, 0, 0, 0),
(73, 'trikz_greg', 1, 4896, -8464, 681.031, 4464, -7968, 808.031, 0, 0, 0, 0, 0, 0),
(74, 'trikz_legends_b1', 0, 4704, 8992, -1253.97, 5024, 8480, -1126.97, 0, 0, 0, 0, 0, 0),
(75, 'trikz_penguin', 0, -1040, 720, -1694.97, -624, 1088, -1567.97, 0, 0, 0, 0, 0, 0),
(76, 'trikz_penguin', 1, 400, 2864, -3468.96, 592, 2592, -3341.96, 0, 0, 0, 0, 0, 0),
(77, 'trikz_kyoto_final', 0, -7376, 3744, 1409.03, -7184, 3840, 1536.03, 0, 0, 0, 4, 0, 0),
(78, 'de_dust2', 0, -1168, -736, 133.107, -1344, -880, 270.39, 0, 0, 0, 4, 0, 0),
(79, 'de_dust2', 1, 560, 2384, 41.031, 608, 2336, 168.031, 0, 0, 0, 4, 0, 0),
(80, 'trikz_lizawhorez_fix', 0, -96, -416, 65.031, -32, -352, 192.031, 0, 0, 0, 4, 0, 0),
(81, 'trikz_lizawhorez_fix', 1, 432, -32, 65.031, 320, -144, 192.031, 0, 0, 0, 4, 0, 0),
(82, 'de_dust2', 0, 336, -816, 3.197, 240, -704, 130.197, 0, 0, 0, 0, 0, 0),
(83, 'trikz_measuregeneric', 0, -6784, -656, -13135, -6880, -768, -13008, 0, 0, 0, 0, 0, 0),
(84, 'trikz_soft', 0, 13560, -5936, 385.031, 13224, -6512, 512.031, 0, 0, 0, 4, 0, 0),
(85, 'trikz_soft', 1, 15336, -1760, 185.031, 15768, -1328, 312.031, 0, 0, 0, 4, 0, 0),
(86, 'trikz_daemon', 1, -3568, 2896, 705.031, -3088, 3376, 832.031, 0, 0, 0, 0, 0, 0),
(87, 'trikz_eonia', 0, 4816, -5328, -4286.97, 4608, -5584, -4159.97, 0, 0, 0, 4, 0, 0),
(88, 'trikz_eonia', 1, 4784, -6256, -4286.97, 4608, -5904, -4159.97, 0, 0, 0, 4, 0, 0),
(89, 'trikz_newmap3', 0, -2528, 15248, -2046.97, -2592, 15312, -1919.97, 0, 0, 0, 4, 0, 0),
(90, 'trikz_newmap3', 1, 4848, 13232, -2942.69, 4784, 13296, -2815.69, 0, 0, 0, 4, 0, 0),
(91, 'trikz_newmap3', 0, -13440, -7232, 201.325, -13632, -7088, 329.968, 0, 0, 0, 0, 0, 0),
(92, 'trikz_mom', 0, -640, -192, 33.031, -544, -272, 160.031, 0, 0, 0, 0, 0, 0),
(93, 'trikz_mom', 1, -416, -736, 33.031, -512, -608, 160.031, 0, 0, 0, 0, 0, 0),
(94, 'trikz_mom', 1, -416, -464, 33.031, -512, -368, 160.031, 0, 0, 0, 4, 0, 0),
(95, 'trikz_mom', 1, -416, -240, 33.031, -464, -320, 160.031, 0, 0, 0, 2, 0, 0),
(96, 'trikz_mom', 0, -624, -416, 33.031, -560, -352, 160.031, 0, 0, 0, 2, 0, 0),
(97, 'trikz_greg', 0, 3696, -7984, 713.031, 3616, -7888, 840.031, 0, 0, 0, 4, 0, 0),
(98, 'trikz_brink', 0, -8320, 13344, 1.031, -8432, 13424, 128.031, 0, 0, 0, 0, 0, 0),
(99, 'trikz_aura', 0, 1344, 1024, -206.968, 1232, 976, -79.968, 0, 0, 0, 0, 0, 0),
(100, 'test01', 0, 3280, -6720, 1409.03, 3344, -6800, 1536.03, 0, 0, 0, 0, 0, 0),
(101, 'trikz_asdfsda_final', 0, -2848, 12496, -446.968, -2976, 12384, -319.968, 0, 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `playertimes`
--

CREATE TABLE `playertimes` (
  `id` int(11) NOT NULL,
  `auth` int(11) DEFAULT NULL,
  `partner` int(11) DEFAULT NULL,
  `map` varchar(128) DEFAULT NULL,
  `time` float DEFAULT NULL,
  `jumps` int(11) DEFAULT NULL,
  `style` tinyint(4) DEFAULT NULL,
  `firstdate` int(11) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  `strafes` int(11) DEFAULT NULL,
  `nades` int(11) DEFAULT NULL,
  `sync` float DEFAULT NULL,
  `points` float NOT NULL DEFAULT 0,
  `track` tinyint(4) NOT NULL DEFAULT 0,
  `perfs` float DEFAULT 0,
  `completions` smallint(6) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `playertimes`
--

INSERT INTO `playertimes` (`id`, `auth`, `partner`, `map`, `time`, `jumps`, `style`, `firstdate`, `date`, `strafes`, `nades`, `sync`, `points`, `track`, `perfs`, `completions`) VALUES
(1, 120192594, 58075991, 'trikz_cyrus', 48.5379, 17, 0, 1605036620, 1605036620, 59, 6, 75.08, 10.5106, 2, 100, 5),
(2, 58075991, 346817812, 'trikz_cyrus', 141.232, 79, 0, 1605041784, 1605041784, 64, 41, 60.9, 3.61222, 2, 90, 2),
(4, 120192594, 101384907, 'trikz_alpha', 867.715, 585, 0, 1605272129, 1605272129, 647, 277, 65.05, 12.1874, 2, 98.21, 1),
(6, 58075991, 120192594, 'trikz_cyrus', 321.673, 216, 0, 1605292535, 1606255981, 440, 69, 77.95, 96.4448, 0, 98.75, 5),
(7, 101384907, 101384907, 'trikz_alpha', 51.1674, 37, 0, 1605305988, 1605696120, 93, 0, 86.71, 18.6374, 4, 100, 5),
(8, 346817812, 346817812, 'trikz_alpha', 48.7478, 35, 0, 1605306356, 1605552332, 97, 0, 85.33, 19.5625, 4, 100, 10),
(9, 120192594, 120192594, 'trikz_alpha', 63.5453, 40, 0, 1605468079, 1606769838, 103, 0, 87.47, 15.007, 4, 80.95, 11),
(10, 120192594, 58075991, 'trikz_eonia', 495.422, 404, 0, 1605795550, 1605795550, 875, 103, 81.27, 108.028, 0, 96.98, 2),
(11, 120192594, 120192594, 'trikz_cyrus', 0.519999, 0, 1, 1606242202, 1606242202, 0, 0, 0, 24.3675, 4, 100, 1),
(31, 58075991, 58075991, 'trikz_cyrus', 0.459999, 1, 0, 1606256403, 1606256454, 2, 0, 95, 17.9418, 4, 100, 89),
(32, 346817812, 346817812, 'trikz_cyrus', 0.459999, 1, 0, 1606256410, 1606256410, 2, 0, 89.74, 17.9418, 4, 100, 114),
(33, 120192594, 120192594, 'trikz_cyrus', 0.449999, 1, 0, 1606256417, 1606469291, 2, 0, 86.36, 18.3405, 4, 100, 68),
(34, 12298050, 12298050, 'trikz_cyrus', 31.8206, 0, 0, 1606320360, 1606320360, 1, 0, 0, 0.259367, 4, 100, 1),
(35, 346817812, 120192594, 'trikz_alpha', 412.651, 284, 0, 1606779068, 1606779068, 318, 165, 65.23, 25.6275, 2, 96.44, 1),
(38, 1055201960, 120192594, 'trikz_cyrus', 28.6806, 11, 0, 1607190716, 1607190716, 55, 6, 52.56, 17.7877, 2, 100, 2),
(39, 120192594, 120192594, 'trikz_newmap', 10.7201, 16, 0, 1607448520, 1607448924, 34, 0, 91.01, 18.9287, 4, 100, 38),
(40, 346817812, 346817812, 'trikz_newmap', 10.7201, 16, 0, 1607450379, 1607450955, 34, 0, 90.3, 18.9287, 4, 80, 17),
(41, 120192594, 346817812, 'trikz_newmap', 348.949, 166, 0, 1607460598, 1607462292, 461, 76, 61.51, 173.263, 0, 87.5, 5),
(42, 101384907, 101384907, 'trikz_newmap', 11.8002, 16, 0, 1607790969, 1607792318, 32, 0, 89.12, 17.1962, 4, 100, 2),
(43, 120192594, 346817812, 'trikz_greg', 500.067, 434, 0, 1607962348, 1607962959, 840, 163, 83.31, 108.338, 0, 90.62, 2),
(44, 120192594, 346817812, 'trikz_penguin', 706.108, 433, 0, 1607964429, 1607964429, 884, 178, 74.44, 122.074, 0, 96.84, 1),
(45, 120192594, 58075991, 'trikz_newmap2', 2.98, 0, 0, 1607972152, 1607972152, 3, 0, 0, 225.199, 0, 100, 1),
(46, 120192594, 120192594, 'trikz_newmap2', 0.629999, 0, 0, 1607972432, 1607972432, 1, 0, 0, 9.5265, 4, 100, 3),
(47, 12298050, 12298050, 'trikz_newmap2', 1.82, 0, 0, 1607972667, 1607972667, 1, 0, 0, 3.29763, 4, 100, 1),
(48, 58075991, 58075991, 'trikz_newmap2', 0.319999, 0, 0, 1607972838, 1607972838, 0, 0, 0, 18.7553, 4, 100, 1),
(49, 120192594, 120192594, 'de_dust2', 8.26009, 11, 0, 1609011689, 1609187414, 23, 0, 90.5, 18.1968, 4, 90, 36),
(50, 120192594, 120192594, 'trikz_lizawhorez_fix', 2.54, 2, 0, 1609156643, 1609157297, 6, 0, 70.22, 10.0515, 4, 100, 4),
(51, 120192594, 120192594, 'trikz_lizawhorez_fix', 4.66001, 2, 1, 1609158453, 1609158453, 5, 0, 84.25, 24.4571, 4, 100, 1),
(52, 58075991, 58075991, 'de_dust2', 7.96009, 12, 0, 1609185383, 1610885691, 28, 0, 90.22, 18.8827, 4, 55.55, 78),
(53, 118899, 120192594, 'trikz_eonia', 568.624, 432, 0, 1609598526, 1609598526, 857, 51, 83.38, 94.1212, 0, 81, 3),
(54, 118899, 118899, 'trikz_cyrus', 0.439999, 1, 0, 1609672475, 1609672581, 3, 0, 86.36, 18.7573, 4, 100, 54),
(55, 120192594, 120192594, 'trikz_soft', 11.6702, 17, 0, 1609677019, 1609677019, 24, 0, 91.58, 17.0276, 4, 78.57, 3),
(56, 118899, 118899, 'trikz_soft', 10.5001, 15, 0, 1609677046, 1609677124, 28, 0, 95.58, 18.925, 4, 70, 6),
(57, 58075991, 58075991, 'trikz_lizawhorez_fix', 1.36, 2, 0, 1609724470, 1609724535, 7, 0, 89.74, 18.7727, 4, 100, 75),
(58, 118899, 120192594, 'trikz_cyrus', 646.51, 414, 0, 1610576073, 1610576073, 975, 101, 80.98, 47.9864, 0, 92.94, 1),
(59, 118899, 120192594, 'trikz_cyrus', 26.5805, 15, 0, 1610576106, 1610576106, 34, 6, 67.73, 19.193, 2, 100, 2),
(60, 120192594, 118899, 'trikz_daemon', 342.333, 427, 0, 1610576555, 1610576555, 686, 46, 86.92, 97.8222, 0, 87.35, 1),
(61, 120192594, 60346366, 'trikz_cyrus', 76.3279, 39, 0, 1610629323, 1610629323, 104, 24, 64.18, 6.68379, 2, 100, 1),
(62, 60346366, 60346366, 'trikz_cyrus', 0.469999, 1, 0, 1610629350, 1610629358, 0, 0, 100, 17.5601, 4, 100, 11),
(63, 58075991, 58075991, 'trikz_newmap3', 10.9102, 3, 0, 1610803119, 1610821193, 21, 0, 90.54, 18.9318, 4, 100, 26),
(64, 120192594, 120192594, 'trikz_newmap3', 11.0802, 3, 0, 1610820943, 1610821267, 27, 0, 88.29, 18.6414, 4, 100, 9),
(67, 12298050, 120192594, 'trikz_mom', 13.7602, 0, 0, 1612899499, 1612899499, 7, 0, 0, 75.9174, 0, 100, 1),
(68, 146118177, 146118177, 'trikz_cyrus', 0.439999, 1, 0, 1613754252, 1613754403, 0, 0, 100, 18.7573, 4, 100, 25),
(69, 146118177, 146118177, 'trikz_lizawhorez_fix', 1.41, 2, 0, 1613988990, 1613988996, 7, 0, 89.06, 18.107, 4, 100, 6),
(70, 120192594, 146118177, 'trikz_eonia', 677.41, 603, 0, 1614796483, 1614796483, 1152, 47, 83.44, 79.0062, 0, 77.41, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `auth` int(11) NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  `ip` int(11) DEFAULT NULL,
  `firstlogin` int(11) NOT NULL DEFAULT -1,
  `lastlogin` int(11) NOT NULL DEFAULT -1,
  `points` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`auth`, `name`, `ip`, `firstlogin`, `lastlogin`, `points`) VALUES
(118899, 'rumour', -1130968760, 1609596147, 1611407470, 286.626),
(10671076, 't.tv/uselesseffort1', -1304046959, 1607021326, 1607181053, 18.8882),
(12298050, '󠀡aaaaa', -1062731418, 1604912348, 1615198906, 79.3791),
(58075991, 'LOn', -1804624772, 1604859681, 1615320923, 515.96),
(60346366, 'nyu', -1131934253, 1610628602, 1610628601, 24.0768),
(67230908, 'no koJIna4ky?', -1021562345, 1606470091, 1606473366, 0),
(82789105, 'noAim| Albo', 1530152659, 1605712751, 1605712751, 0),
(90626675, 'VIC70R', -1294214597, 1607093189, 1609780193, 0),
(101384907, 'mTi', 1434865793, 1604934020, 1613739620, 46.9894),
(116944747, 'Mapache Hunter', 1395452286, 1606792391, 1606792391, 0),
(119414284, 'Kjeldfanger', 1047246664, 1606429107, 1606429107, 0),
(120192594, 'Smesh', -1062731418, 1604859568, 1620990524, 1292.53),
(126159574, '❤DeMoツ', 521957897, 1611496071, 1611507655, 0),
(135236385, 'not-log', 1843557645, 1606474563, 1614542182, 0),
(146118177, 'Mati', 1365857892, 1604926245, 1619288292, 114.507),
(149448658, 'Hardyy.', 1293887772, 1606335722, 1606335722, 0),
(180080834, 'AarBi', 1834519007, 1608489514, 1608489514, 0),
(201645385, '3abod dj', 531074080, 1605539690, 1606470188, 0),
(247145000, 'botshit', 1448626536, 1606585587, 1611162390, 0),
(346817812, 'highfallen', 1438629141, 1605040105, 1619640528, 471.822),
(360165320, 'YO', 778939637, 1604963882, 1614341387, 0),
(371538929, 'Gl1tch\'', 1317021029, 1613146804, 1613146804, 0),
(389831235, 'KP', 842824176, 1609181660, 1609181945, 0),
(1055201960, 'Gurman', 1570635534, 1607189913, 1607195439, 19.228),
(1063610467, 'кек', 1421555421, 1606779243, 1612197267, 0),
(1137083854, 'jeunesse éternelle', -1334969786, 1604920784, 1604921975, 0);

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`auth`);

--
-- Индексы таблицы `maptiers`
--
ALTER TABLE `maptiers`
  ADD PRIMARY KEY (`map`);

--
-- Индексы таблицы `mapzones`
--
ALTER TABLE `mapzones`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `playertimes`
--
ALTER TABLE `playertimes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `auth` (`auth`,`date`,`points`),
  ADD KEY `partner` (`partner`),
  ADD KEY `map` (`map`,`style`,`track`,`time`),
  ADD KEY `time` (`time`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`auth`),
  ADD KEY `points` (`points`),
  ADD KEY `firstlogin` (`firstlogin`),
  ADD KEY `lastlogin` (`lastlogin`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `mapzones`
--
ALTER TABLE `mapzones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT для таблицы `playertimes`
--
ALTER TABLE `playertimes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `chat`
--
ALTER TABLE `chat`
  ADD CONSTRAINT `ch_auth` FOREIGN KEY (`auth`) REFERENCES `users` (`auth`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ограничения внешнего ключа таблицы `playertimes`
--
ALTER TABLE `playertimes`
  ADD CONSTRAINT `pt_auth` FOREIGN KEY (`auth`) REFERENCES `users` (`auth`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
