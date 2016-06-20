ALTER TABLE `sessions`
	ADD COLUMN `client_hostname` TEXT NULL DEFAULT NULL AFTER `ip_address`,
	ADD COLUMN `secure` TINYINT(1) UNSIGNED NULL DEFAULT NULL AFTER `user_agent`,
	CHANGE COLUMN `view_online_page` `path` VARCHAR(255) NULL DEFAULT NULL AFTER `locale`,
	ADD COLUMN `query_string` TEXT NULL DEFAULT NULL AFTER `path`,
	ADD COLUMN `referrer` TEXT NULL AFTER `query_string`;

