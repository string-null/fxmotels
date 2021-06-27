-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         10.4.16-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Volcando estructura para tabla randstad.pluto_motels
CREATE TABLE IF NOT EXISTS `fx_motels` (
  `interiorId` longtext NOT NULL,
  `roomOwner` varchar(50) NOT NULL,
  `roomData` text NOT NULL,
  `latestPayment` bigint(20) NOT NULL,
  FULLTEXT KEY `interiorId` (`interiorId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Volcando datos para la tabla randstad.pluto_motels: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `pluto_motels` DISABLE KEYS */;
/*!40000 ALTER TABLE `pluto_motels` ENABLE KEYS */;

-- Volcando estructura para tabla randstad.user_keys
CREATE TABLE IF NOT EXISTS `user_keys` (
  `identifier` varchar(50) NOT NULL,
  `keyTable` longtext NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Volcando datos para la tabla randstad.user_keys: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `user_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_keys` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
