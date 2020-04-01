CREATE TABLE `stazioni` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`nome` VARCHAR(50) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
	`comune` VARCHAR(50) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
	`provincia` VARCHAR(50) NULL DEFAULT NULL COLLATE 'latin1_swedish_ci',
	`lat` FLOAT(12) NULL DEFAULT NULL,
	`lon` FLOAT(12) NULL DEFAULT NULL,
	`codseqst` INT(11) NULL DEFAULT NULL,
	INDEX `id` (`id`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;
