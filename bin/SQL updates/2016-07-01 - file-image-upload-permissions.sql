ALTER TABLE `roles`
	ADD COLUMN `file_upload` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `event_delete`,
	ADD COLUMN `image_upload` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `fixtures_delete`;

UPDATE `mkttl`.`roles` SET `file_upload`='1', `image_upload`='1' WHERE  `id`=1;
UPDATE `mkttl`.`roles` SET `file_upload`='1', `image_upload`='1' WHERE  `id`=2;

