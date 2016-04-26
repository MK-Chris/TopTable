CREATE TABLE `system_event_log_role` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`system_event_log_id` INT UNSIGNED NOT NULL,
	`object_id` INT UNSIGNED,
	`name` VARCHAR(300) NOT NULL COMMENT 'Only used if there is no ID (i.e., if the club was deleted and is not available).',
	`log_updated` DATETIME NOT NULL,
	`number_of_edits` TINYINT(4) NOT NULL COMMENT 'Used if the event is for an edit.',
	PRIMARY KEY (`id`),
	CONSTRAINT `system_event_log_role` FOREIGN KEY (`object_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE ON DELETE SET NULL,
	CONSTRAINT `role_system_event_log` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;