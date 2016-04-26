ALTER TABLE `roles`
	ADD COLUMN `system` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'System (built-in) roles are built-in from installation; they can\'t be deleted or renamed; the permissions can be edited (except administrators; anyone in administrators can do anything - they are denoted by the sysadmin field being 1).' AFTER `name`,
	ADD COLUMN `sysadmin` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Should only be applied to built-in "Administrators" role - permissions cannot be altered.' AFTER `system`,
	ADD COLUMN `anonymous` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Should only be applied to built-in "anonymous" role - anyone not logged in gets these permissions.' AFTER `sysadmin`,
	ADD COLUMN `apply_on_registration` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'If this is 1, upon registration, users will get assigned to the role automatically.  This can be altered on user-defined roles, but not on built-in roles.' AFTER `anonymous`,
	ALTER `name` DROP DEFAULT,
	CHANGE COLUMN `name` `name` VARCHAR(100) NOT NULL COMMENT 'For system (built-in) roles, this will not be the actual name, but the key for the translation routine to get the actual name in the correct language; for user-defined roles, it will be the name itself as entered by the user.' AFTER `url_key`,ALTER TABLE `roles`
	ADD COLUMN `role_view` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `person_delete`,
	CHANGE COLUMN `role_permissions_create` `role_create` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `role_view`,
	CHANGE COLUMN `role_permissions_edit` `role_edit` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `role_create`,
	CHANGE COLUMN `role_permissions_delete` `role_delete` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `role_edit`,
	DROP COLUMN `club_edit_silent`,
	CHANGE COLUMN `committee_position_create` `committee_create` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `committee_view`,
	CHANGE COLUMN `committee_position_edit` `committee_edit` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `committee_create`,
	CHANGE COLUMN `committee_position_delete` `committee_delete` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `committee_edit`,
	DROP COLUMN `committee_member_assign`,
	DROP COLUMN `committee_member_remove`,
	DROP COLUMN `division_view`,
	DROP COLUMN `division_edit`,
	DROP COLUMN `division_delete`,
	DROP COLUMN `person_personal_view`,
	DROP COLUMN `person_edit_silent`,
	DROP COLUMN `team_edit_silent`,
	DROP COLUMN `user_role_assign`;


UPDATE `toptable`.`roles` SET `name`='administrators', `system`='1', `sysadmin`='1', `role_view`='1', `role_create`='1', `role_edit`='1', `role_delete`='1' WHERE  `id`=1;
UPDATE `toptable`.`roles` SET `name`='league-officials', `system`='1', `role_view`='1', `role_create`='1', `role_edit`='1', `role_delete`='1' WHERE  `id`=2;
UPDATE `toptable`.`roles` SET `name`='anonymous', `system`='1', `anonymous`='1', `role_view`='1' WHERE  `id`=3;
UPDATE `toptable`.`roles` SET `name`='registered-users', `system`='1', `apply_on_registration`='1', `role_view`='1' WHERE  `id`=4;

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

INSERT INTO `toptable`.`system_event_log_types` (`object_type`, `event_type`, `object_description`, `description`, `view_action_for_uri`, `plural_objects`, `public_event`)
VALUES
('role', 'create', 'Role', 'system.event-log-description.create', '/roles/view', 'roles', '0'),
('role', 'edit', 'Role', 'system.event-log-description.edit', '/roles/view', 'roles', '0'),
('role', 'delete', 'Role', 'system.event-log-description.delete', 'roles', '0');


