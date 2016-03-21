USE `toptable`;
CREATE TABLE IF NOT EXISTS `team_match_reports` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `home_team` int(11) unsigned NOT NULL,
  `away_team` int(11) unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `published` datetime DEFAULT NULL,
  `author` int(11) unsigned NOT NULL,
  `report` longtext,
  PRIMARY KEY (`id`),
  KEY `team_match_report` (`home_team`,`away_team`,`scheduled_date`),
  CONSTRAINT `team_match_report` FOREIGN KEY (`home_team`, `away_team`, `scheduled_date`) REFERENCES `team_matches` (`home_team`, `away_team`, `scheduled_date`),
  CONSTRAINT `team_match_report_author` FOREIGN KEY (`author`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;


ALTER TABLE `team_matches`
	DROP COLUMN `report`;

ALTER TABLE `roles`
	ADD COLUMN `match_report_create` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'If 1 the person can create match reports for any team.' AFTER `match_cancel`,
	ADD COLUMN `match_report_create_associated` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'If 1 the person can create match reports involving teams the user is associated with (by playing for or captaining the team or being secretary for the club)' AFTER `match_report_create`,
	ADD COLUMN `match_report_edit_own` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `match_report_create_team`,
	ADD COLUMN `match_report_edit_all` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `match_report_edit_own`,
	ADD COLUMN `match_report_delete_own` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `match_report_edit_all`,
	ADD COLUMN `match_report_delete_all` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `match_report_delete_own`;

UPDATE `toptable`.`roles` SET `match_report_create`='1', `match_report_create_associated`='1', `match_report_edit_own`='1', `match_report_edit_all`='1', `match_report_delete_own`='1', `match_report_delete_all`='1' WHERE  `id`IN (1, 2);

INSERT INTO `toptable`.`system_event_log_types`
(`object_type`, `event_type`, `object_description`, `description`, `view_action_for_uri`, `plural_objects`, `public_event`)
VALUES
('team-match', 'report-create', 'Team Matches', 'system-event-log.description.report-create', '/matches/team/view_by_ids', 'matches', '1'),
('team-match', 'report-edit', 'Team Matches', 'system-event-log.description.report-edit', '/matches/team/view_by_ids', 'matches', '1');

