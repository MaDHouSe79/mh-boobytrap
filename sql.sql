CREATE TABLE IF NOT EXISTS `player_boobytraps` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `radius` int(15) NOT NULL DEFAULT 0,
  `coords` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enable` int(5) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;