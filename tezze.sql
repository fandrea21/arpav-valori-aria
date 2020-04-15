CREATE TABLE `tezze` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`datetime` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`temperatura` DECIMAL(10,1) NOT NULL,
	`precipitazione` DECIMAL(10,1) NOT NULL,
	`unidita` INT(3) NOT NULL DEFAULT '0',
	`velocita` DECIMAL(10,1) NOT NULL,
	`direzione` INT(5) NOT NULL DEFAULT '0',
	`radiazione` INT(5) NOT NULL DEFAULT '0',
	INDEX `id` (`id`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
AUTO_INCREMENT=277
;
