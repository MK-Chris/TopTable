-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Dec 23 13:25:18 2019
-- 
;
SET foreign_key_checks=0;
--
-- Table: `average_filters`
--
CREATE TABLE `average_filters` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `show_active` tinyint unsigned NULL DEFAULT 1,
  `show_loan` tinyint unsigned NULL DEFAULT 0,
  `show_inactive` tinyint unsigned NULL DEFAULT 0,
  `criteria_field` varchar(10) NULL,
  `operator` varchar(2) NULL,
  `criteria` smallint unsigned NOT NULL,
  `criteria_type` varchar(10) NULL,
  `user` integer unsigned NULL,
  INDEX `average_filters_idx_user` (`user`),
  PRIMARY KEY (`id`),
  UNIQUE `name_user` (`name`, `user`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `average_filters_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `calendar_types`
--
CREATE TABLE `calendar_types` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `uri` text NOT NULL,
  `calendar_scheme` varchar(10) NULL,
  `uri_escape_replacements` tinyint NOT NULL DEFAULT 0,
  `display_order` smallint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `name` (`name`)
);
--
-- Table: `clubs`
--
CREATE TABLE `clubs` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NULL,
  `full_name` text NOT NULL,
  `short_name` varchar(150) NOT NULL,
  `venue` integer unsigned NOT NULL,
  `secretary` integer unsigned NULL,
  `email_address` varchar(200) NULL,
  `website` text NULL,
  `facebook` text NULL,
  `twitter` text NULL,
  `instagram` text NULL,
  `youtube` text NULL,
  `default_match_start` time NULL,
  INDEX `clubs_idx_secretary` (`secretary`),
  INDEX `clubs_idx_venue` (`venue`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `clubs_fk_secretary` FOREIGN KEY (`secretary`) REFERENCES `people` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `clubs_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `contact_reason_recipients`
--
CREATE TABLE `contact_reason_recipients` (
  `contact_reason` integer unsigned NOT NULL,
  `person` integer unsigned NOT NULL,
  INDEX `contact_reason_recipients_idx_contact_reason` (`contact_reason`),
  INDEX `contact_reason_recipients_idx_person` (`person`),
  PRIMARY KEY (`contact_reason`, `person`),
  CONSTRAINT `contact_reason_recipients_fk_contact_reason` FOREIGN KEY (`contact_reason`) REFERENCES `contact_reasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `contact_reason_recipients_fk_person` FOREIGN KEY (`person`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `contact_reasons`
--
CREATE TABLE `contact_reasons` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `division_seasons`
--
CREATE TABLE `division_seasons` (
  `division` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `name` varchar(45) NOT NULL,
  `fixtures_grid` integer unsigned NOT NULL,
  `league_match_template` integer unsigned NOT NULL,
  `league_table_ranking_template` integer unsigned NOT NULL,
  `promotion_places` tinyint NULL DEFAULT 0,
  `relegation_places` tinyint NULL DEFAULT 0,
  INDEX `division_seasons_idx_division` (`division`),
  INDEX `division_seasons_idx_fixtures_grid` (`fixtures_grid`),
  INDEX `division_seasons_idx_league_match_template` (`league_match_template`),
  INDEX `division_seasons_idx_league_table_ranking_template` (`league_table_ranking_template`),
  INDEX `division_seasons_idx_season` (`season`),
  PRIMARY KEY (`division`, `season`),
  CONSTRAINT `division_seasons_fk_division` FOREIGN KEY (`division`) REFERENCES `divisions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `division_seasons_fk_fixtures_grid` FOREIGN KEY (`fixtures_grid`) REFERENCES `fixtures_grids` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `division_seasons_fk_league_match_template` FOREIGN KEY (`league_match_template`) REFERENCES `template_match_team` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `division_seasons_fk_league_table_ranking_template` FOREIGN KEY (`league_table_ranking_template`) REFERENCES `template_league_table_ranking` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `division_seasons_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `divisions`
--
CREATE TABLE `divisions` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `rank` tinyint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `doubles_pairs`
--
CREATE TABLE `doubles_pairs` (
  `id` integer unsigned NOT NULL auto_increment,
  `person1` integer unsigned NOT NULL,
  `person2` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `team` integer unsigned NOT NULL,
  `person1_loan` tinyint unsigned NOT NULL DEFAULT 0,
  `person2_loan` tinyint unsigned NOT NULL DEFAULT 0,
  `games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `legs_played` tinyint unsigned NOT NULL DEFAULT 0,
  `legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `legs_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `points_played` integer unsigned NOT NULL DEFAULT 0,
  `points_won` integer unsigned NOT NULL DEFAULT 0,
  `points_lost` integer unsigned NOT NULL DEFAULT 0,
  `average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `last_updated` datetime NOT NULL,
  INDEX `doubles_pairs_idx_person1` (`person1`),
  INDEX `doubles_pairs_idx_person2` (`person2`),
  INDEX `doubles_pairs_idx_season` (`season`),
  INDEX `doubles_pairs_idx_team` (`team`),
  PRIMARY KEY (`id`),
  CONSTRAINT `doubles_pairs_fk_person1` FOREIGN KEY (`person1`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `doubles_pairs_fk_person2` FOREIGN KEY (`person2`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `doubles_pairs_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `doubles_pairs_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `event_seasons`
--
CREATE TABLE `event_seasons` (
  `event` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `name` text NOT NULL,
  `date` date NULL,
  `date_and_start_time` datetime NULL,
  `all_day` tinyint unsigned NULL,
  `finish_time` time NULL,
  `organiser` integer unsigned NULL,
  `venue` integer unsigned NULL,
  `description` longtext NULL,
  INDEX `event_seasons_idx_event` (`event`),
  INDEX `event_seasons_idx_organiser` (`organiser`),
  INDEX `event_seasons_idx_season` (`season`),
  INDEX `event_seasons_idx_venue` (`venue`),
  PRIMARY KEY (`event`, `season`),
  CONSTRAINT `event_seasons_fk_event` FOREIGN KEY (`event`) REFERENCES `events` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `event_seasons_fk_organiser` FOREIGN KEY (`organiser`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `event_seasons_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `event_seasons_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `events`
--
CREATE TABLE `events` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` text NOT NULL,
  `event_type` varchar(20) NOT NULL,
  `description` longtext NULL,
  INDEX `events_idx_event_type` (`event_type`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `events_fk_event_type` FOREIGN KEY (`event_type`) REFERENCES `lookup_event_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `fixtures_grid_matches`
--
CREATE TABLE `fixtures_grid_matches` (
  `grid` integer unsigned NOT NULL,
  `week` tinyint unsigned NOT NULL,
  `match_number` tinyint unsigned NOT NULL,
  `home_team` tinyint unsigned NULL,
  `away_team` tinyint unsigned NULL,
  INDEX `fixtures_grid_matches_idx_grid_week` (`grid`, `week`),
  PRIMARY KEY (`grid`, `week`, `match_number`),
  CONSTRAINT `fixtures_grid_matches_fk_grid_week` FOREIGN KEY (`grid`, `week`) REFERENCES `fixtures_grid_weeks` (`grid`, `week`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `fixtures_grid_weeks`
--
CREATE TABLE `fixtures_grid_weeks` (
  `grid` integer unsigned NOT NULL,
  `week` tinyint unsigned NOT NULL,
  INDEX `fixtures_grid_weeks_idx_grid` (`grid`),
  PRIMARY KEY (`grid`, `week`),
  CONSTRAINT `fixtures_grid_weeks_fk_grid` FOREIGN KEY (`grid`) REFERENCES `fixtures_grids` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `fixtures_grids`
--
CREATE TABLE `fixtures_grids` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `maximum_teams` tinyint unsigned NOT NULL,
  `fixtures_repeated` tinyint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `fixtures_season_weeks`
--
CREATE TABLE `fixtures_season_weeks` (
  `grid` integer unsigned NOT NULL,
  `grid_week` tinyint unsigned NOT NULL,
  `fixtures_week` integer unsigned NOT NULL,
  INDEX `fixtures_season_weeks_idx_grid_grid_week` (`grid`, `grid_week`),
  INDEX `fixtures_season_weeks_idx_fixtures_week` (`fixtures_week`),
  PRIMARY KEY (`grid`, `grid_week`, `fixtures_week`),
  CONSTRAINT `fixtures_season_weeks_fk_grid_grid_week` FOREIGN KEY (`grid`, `grid_week`) REFERENCES `fixtures_grid_weeks` (`grid`, `week`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fixtures_season_weeks_fk_fixtures_week` FOREIGN KEY (`fixtures_week`) REFERENCES `fixtures_weeks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `fixtures_weeks`
--
CREATE TABLE `fixtures_weeks` (
  `id` integer unsigned NOT NULL auto_increment,
  `season` integer unsigned NOT NULL,
  `week_beginning_date` date NOT NULL,
  INDEX `fixtures_weeks_idx_season` (`season`),
  PRIMARY KEY (`id`),
  CONSTRAINT `fixtures_weeks_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `individual_matches`
--
CREATE TABLE `individual_matches` (
  `id` integer unsigned NOT NULL auto_increment,
  `home_player` integer unsigned NULL,
  `away_player` integer unsigned NULL,
  `individual_match_template` integer unsigned NOT NULL,
  `home_doubles_pair` integer unsigned NULL,
  `away_doubles_pair` integer unsigned NULL,
  `home_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `away_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_game` tinyint unsigned NOT NULL DEFAULT 0,
  `umpire` integer unsigned NULL,
  `started` tinyint unsigned NULL DEFAULT 0,
  `complete` tinyint unsigned NULL DEFAULT 0,
  `awarded` tinyint NULL,
  `void` tinyint NULL,
  `winner` integer unsigned NULL,
  INDEX `individual_matches_idx_away_player` (`away_player`),
  INDEX `individual_matches_idx_home_player` (`home_player`),
  INDEX `individual_matches_idx_individual_match_template` (`individual_match_template`),
  PRIMARY KEY (`id`),
  CONSTRAINT `individual_matches_fk_away_player` FOREIGN KEY (`away_player`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `individual_matches_fk_home_player` FOREIGN KEY (`home_player`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `individual_matches_fk_individual_match_template` FOREIGN KEY (`individual_match_template`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `invalid_logins`
--
CREATE TABLE `invalid_logins` (
  `ip_address` varchar(40) NOT NULL,
  `invalid_logins` smallint unsigned NOT NULL,
  `last_invalid_login` datetime NOT NULL,
  PRIMARY KEY (`ip_address`)
);
--
-- Table: `lookup_event_types`
--
CREATE TABLE `lookup_event_types` (
  `id` varchar(20) NOT NULL,
  `display_order` tinyint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `display_order` (`display_order`)
) ENGINE=InnoDB;
--
-- Table: `lookup_game_types`
--
CREATE TABLE `lookup_game_types` (
  `id` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `lookup_gender`
--
CREATE TABLE `lookup_gender` (
  `id` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `lookup_locations`
--
CREATE TABLE `lookup_locations` (
  `id` varchar(10) NOT NULL,
  `location` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE `location` (`location`)
) ENGINE=InnoDB;
--
-- Table: `lookup_serve_types`
--
CREATE TABLE `lookup_serve_types` (
  `id` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `lookup_team_membership_types`
--
CREATE TABLE `lookup_team_membership_types` (
  `id` varchar(20) NOT NULL,
  `display_order` tinyint unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `lookup_tournament_types`
--
CREATE TABLE `lookup_tournament_types` (
  `id` varchar(20) NOT NULL,
  `display_order` tinyint unsigned NOT NULL,
  `allowed_in_single_tournament_events` tinyint unsigned NOT NULL,
  `allowed_in_multi_tournament_events` tinyint unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `display_order` (`display_order`)
) ENGINE=InnoDB;
--
-- Table: `lookup_weekdays`
--
CREATE TABLE `lookup_weekdays` (
  `weekday_number` tinyint unsigned NOT NULL DEFAULT 0,
  `weekday_name` varchar(20) NULL,
  PRIMARY KEY (`weekday_number`),
  UNIQUE `weekday_name` (`weekday_name`)
) ENGINE=InnoDB;
--
-- Table: `lookup_winner_types`
--
CREATE TABLE `lookup_winner_types` (
  `id` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `meeting_attendees`
--
CREATE TABLE `meeting_attendees` (
  `meeting` integer unsigned NOT NULL,
  `person` integer unsigned NOT NULL,
  `apologies` tinyint unsigned NOT NULL DEFAULT 0,
  INDEX `meeting_attendees_idx_meeting` (`meeting`),
  INDEX `meeting_attendees_idx_person` (`person`),
  PRIMARY KEY (`meeting`, `person`),
  CONSTRAINT `meeting_attendees_fk_meeting` FOREIGN KEY (`meeting`) REFERENCES `meetings` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `meeting_attendees_fk_person` FOREIGN KEY (`person`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `meeting_types`
--
CREATE TABLE `meeting_types` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `meetings`
--
CREATE TABLE `meetings` (
  `id` integer unsigned NOT NULL auto_increment,
  `event` integer unsigned NULL,
  `season` integer unsigned NULL,
  `type` integer unsigned NULL,
  `organiser` integer unsigned NULL,
  `venue` integer unsigned NULL,
  `date_and_start_time` datetime NULL,
  `all_day` tinyint unsigned NULL,
  `finish_time` time NULL,
  `agenda` longtext NULL,
  `minutes` longtext NULL,
  INDEX `meetings_idx_event_season` (`event`, `season`),
  INDEX `meetings_idx_organiser` (`organiser`),
  INDEX `meetings_idx_type` (`type`),
  INDEX `meetings_idx_venue` (`venue`),
  PRIMARY KEY (`id`),
  CONSTRAINT `meetings_fk_event_season` FOREIGN KEY (`event`, `season`) REFERENCES `event_seasons` (`event`, `season`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `meetings_fk_organiser` FOREIGN KEY (`organiser`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `meetings_fk_type` FOREIGN KEY (`type`) REFERENCES `meeting_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `meetings_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `news_articles`
--
CREATE TABLE `news_articles` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NULL,
  `published_year` year NULL,
  `published_month` tinyint unsigned NULL,
  `updated_by_user` integer unsigned NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `date_updated` datetime NOT NULL,
  `headline` text NOT NULL,
  `article_content` longtext NOT NULL,
  `original_article` integer unsigned NULL,
  INDEX `news_articles_idx_original_article` (`original_article`),
  INDEX `news_articles_idx_updated_by_user` (`updated_by_user`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`, `published_year`, `published_month`),
  CONSTRAINT `news_articles_fk_original_article` FOREIGN KEY (`original_article`) REFERENCES `news_articles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `news_articles_fk_updated_by_user` FOREIGN KEY (`updated_by_user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `officials`
--
CREATE TABLE `officials` (
  `id` integer unsigned NOT NULL auto_increment,
  `position` varchar(150) NOT NULL,
  `position_order` tinyint unsigned NOT NULL,
  `position_holder` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  INDEX `officials_idx_position_holder` (`position_holder`),
  INDEX `officials_idx_season` (`season`),
  PRIMARY KEY (`id`),
  CONSTRAINT `officials_fk_position_holder` FOREIGN KEY (`position_holder`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `officials_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;
--
-- Table: `page_text`
--
CREATE TABLE `page_text` (
  `page_key` varchar(50) NOT NULL,
  `page_text` longtext NOT NULL,
  `last_updated` datetime NOT NULL,
  PRIMARY KEY (`page_key`)
);
--
-- Table: `people`
--
CREATE TABLE `people` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `surname` varchar(150) NOT NULL,
  `display_name` text NOT NULL,
  `date_of_birth` date NULL,
  `gender` varchar(20) NULL,
  `address1` varchar(150) NULL,
  `address2` varchar(150) NULL,
  `address3` varchar(150) NULL,
  `address4` varchar(150) NULL,
  `address5` varchar(150) NULL,
  `postcode` varchar(8) NULL,
  `home_telephone` varchar(25) NULL,
  `work_telephone` varchar(25) NULL,
  `mobile_telephone` varchar(25) NULL,
  `email_address` varchar(254) NULL,
  INDEX `people_idx_gender` (`gender`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `people_fk_gender` FOREIGN KEY (`gender`) REFERENCES `lookup_gender` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `person_seasons`
--
CREATE TABLE `person_seasons` (
  `person` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `team` integer unsigned NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `surname` varchar(150) NOT NULL,
  `display_name` text NOT NULL,
  `registration_date` date NULL,
  `fees_paid` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_played` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_won` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `legs_played` smallint unsigned NOT NULL DEFAULT 0,
  `legs_won` smallint unsigned NOT NULL DEFAULT 0,
  `legs_lost` smallint unsigned NOT NULL DEFAULT 0,
  `average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `points_played` integer unsigned NOT NULL DEFAULT 0,
  `points_won` integer unsigned NOT NULL DEFAULT 0,
  `points_lost` integer unsigned NOT NULL DEFAULT 0,
  `average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_legs_played` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_legs_won` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_legs_lost` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_points_played` integer unsigned NOT NULL DEFAULT 0,
  `doubles_points_won` integer unsigned NOT NULL DEFAULT 0,
  `doubles_points_lost` integer unsigned NOT NULL DEFAULT 0,
  `doubles_average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `team_membership_type` varchar(20) NOT NULL DEFAULT 'active',
  `last_updated` datetime NOT NULL,
  INDEX `person_seasons_idx_person` (`person`),
  INDEX `person_seasons_idx_season` (`season`),
  INDEX `person_seasons_idx_team` (`team`),
  INDEX `person_seasons_idx_team_membership_type` (`team_membership_type`),
  PRIMARY KEY (`person`, `season`, `team`),
  CONSTRAINT `person_seasons_fk_person` FOREIGN KEY (`person`) REFERENCES `people` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `person_seasons_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `person_seasons_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `person_seasons_fk_team_membership_type` FOREIGN KEY (`team_membership_type`) REFERENCES `lookup_team_membership_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `person_tournaments`
--
CREATE TABLE `person_tournaments` (
  `id` integer unsigned NOT NULL auto_increment,
  `tournament` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `person1` integer unsigned NOT NULL,
  `person2` integer unsigned NOT NULL,
  `team` integer unsigned NULL,
  `first_name` varchar(150) NOT NULL,
  `surname` varchar(150) NOT NULL,
  `display_name` text NOT NULL,
  `registration_date` date NULL,
  `fees_paid` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_played` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_won` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `legs_played` smallint unsigned NOT NULL DEFAULT 0,
  `legs_won` smallint unsigned NOT NULL DEFAULT 0,
  `legs_lost` smallint unsigned NOT NULL DEFAULT 0,
  `average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `points_played` integer unsigned NOT NULL DEFAULT 0,
  `points_won` integer unsigned NOT NULL DEFAULT 0,
  `points_lost` integer unsigned NOT NULL DEFAULT 0,
  `average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `team_membership_type` varchar(20) NOT NULL DEFAULT 'active',
  `last_updated` datetime NOT NULL,
  INDEX `person_tournaments_idx_person1` (`person1`),
  INDEX `person_tournaments_idx_person2` (`person2`),
  INDEX `person_tournaments_idx_team` (`team`),
  PRIMARY KEY (`id`),
  CONSTRAINT `person_tournaments_fk_person1` FOREIGN KEY (`person1`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `person_tournaments_fk_person2` FOREIGN KEY (`person2`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `person_tournaments_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `roles`
--
CREATE TABLE `roles` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(100) NOT NULL,
  `system` tinyint unsigned NOT NULL DEFAULT 0,
  `sysadmin` tinyint unsigned NOT NULL DEFAULT 0,
  `anonymous` tinyint unsigned NOT NULL DEFAULT 0,
  `apply_on_registration` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_create_public` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_edit_public` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_delete_public` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_view_all` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_edit_all` tinyint unsigned NOT NULL DEFAULT 0,
  `average_filter_delete_all` tinyint unsigned NOT NULL DEFAULT 0,
  `club_view` tinyint unsigned NOT NULL DEFAULT 0,
  `club_create` tinyint unsigned NOT NULL DEFAULT 0,
  `club_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `club_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `committee_view` tinyint unsigned NOT NULL DEFAULT 0,
  `committee_create` tinyint unsigned NOT NULL DEFAULT 0,
  `committee_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `committee_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `contact_reason_view` tinyint unsigned NOT NULL DEFAULT 0,
  `contact_reason_create` tinyint unsigned NOT NULL DEFAULT 0,
  `contact_reason_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `contact_reason_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `event_view` tinyint unsigned NOT NULL DEFAULT 0,
  `event_create` tinyint unsigned NOT NULL DEFAULT 0,
  `event_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `event_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `file_upload` tinyint unsigned NOT NULL DEFAULT 0,
  `fixtures_view` tinyint unsigned NOT NULL DEFAULT 0,
  `fixtures_create` tinyint unsigned NOT NULL DEFAULT 0,
  `fixtures_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `fixtures_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `image_upload` tinyint unsigned NOT NULL DEFAULT 0,
  `match_view` tinyint unsigned NOT NULL DEFAULT 0,
  `match_update` tinyint unsigned NOT NULL DEFAULT 0,
  `match_cancel` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_create` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_create_associated` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_edit_own` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_edit_all` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_delete_own` tinyint unsigned NOT NULL DEFAULT 0,
  `match_report_delete_all` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_view` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_create` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_type_view` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_type_create` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_type_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `meeting_type_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_view` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_create` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_edit_own` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_edit_all` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_delete_own` tinyint unsigned NOT NULL DEFAULT 0,
  `news_article_delete_all` tinyint unsigned NOT NULL DEFAULT 0,
  `online_users_view` tinyint unsigned NOT NULL DEFAULT 0,
  `anonymous_online_users_view` tinyint unsigned NOT NULL DEFAULT 0,
  `view_users_ip` tinyint unsigned NOT NULL DEFAULT 0,
  `view_users_user_agent` tinyint unsigned NOT NULL DEFAULT 0,
  `person_view` tinyint unsigned NOT NULL DEFAULT 0,
  `person_create` tinyint unsigned NOT NULL DEFAULT 0,
  `person_contact_view` tinyint unsigned NOT NULL DEFAULT 0,
  `person_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `person_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `privacy_view` tinyint unsigned NOT NULL DEFAULT 0,
  `privacy_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `role_view` tinyint unsigned NOT NULL DEFAULT 0,
  `role_create` tinyint unsigned NOT NULL DEFAULT 0,
  `role_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `role_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `season_view` tinyint unsigned NOT NULL DEFAULT 0,
  `season_create` tinyint unsigned NOT NULL DEFAULT 0,
  `season_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `season_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `season_archive` tinyint unsigned NOT NULL DEFAULT 0,
  `session_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `system_event_log_view_all` tinyint unsigned NOT NULL DEFAULT 0,
  `team_view` tinyint unsigned NOT NULL DEFAULT 0,
  `team_create` tinyint unsigned NOT NULL DEFAULT 0,
  `team_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `team_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `template_view` tinyint unsigned NOT NULL DEFAULT 0,
  `template_create` tinyint unsigned NOT NULL DEFAULT 0,
  `template_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `template_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `tournament_view` tinyint unsigned NOT NULL DEFAULT 0,
  `tournament_create` tinyint unsigned NOT NULL DEFAULT 0,
  `tournament_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `tournament_delete` tinyint unsigned NOT NULL DEFAULT 0,
  `user_view` tinyint unsigned NOT NULL DEFAULT 0,
  `user_edit_all` tinyint unsigned NOT NULL DEFAULT 0,
  `user_edit_own` tinyint unsigned NOT NULL DEFAULT 0,
  `user_delete_all` tinyint unsigned NOT NULL DEFAULT 0,
  `user_delete_own` tinyint unsigned NOT NULL DEFAULT 0,
  `venue_view` tinyint unsigned NOT NULL DEFAULT 0,
  `venue_create` tinyint unsigned NOT NULL DEFAULT 0,
  `venue_edit` tinyint unsigned NOT NULL DEFAULT 0,
  `venue_delete` tinyint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `seasons`
--
CREATE TABLE `seasons` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `default_match_start` time NOT NULL,
  `timezone` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `complete` tinyint NOT NULL DEFAULT 0,
  `allow_loan_players_below` tinyint unsigned NOT NULL DEFAULT 0,
  `allow_loan_players_above` tinyint unsigned NOT NULL DEFAULT 0,
  `allow_loan_players_across` tinyint unsigned NOT NULL DEFAULT 0,
  `allow_loan_players_multiple_teams_per_division` tinyint unsigned NOT NULL DEFAULT 0,
  `allow_loan_players_same_club_only` tinyint unsigned NOT NULL DEFAULT 0,
  `loan_players_limit_per_player` tinyint unsigned NOT NULL DEFAULT 0,
  `loan_players_limit_per_player_per_team` tinyint unsigned NOT NULL DEFAULT 0,
  `loan_players_limit_per_team` tinyint unsigned NOT NULL DEFAULT 0,
  `rules` longtext NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `sessions`
--
CREATE TABLE `sessions` (
  `id` char(72) NOT NULL,
  `data` mediumtext NULL,
  `expires` integer unsigned NULL,
  `user` integer unsigned NULL,
  `ip_address` varchar(40) NULL,
  `client_hostname` text NULL,
  `user_agent` integer unsigned NULL,
  `secure` tinyint unsigned NULL,
  `locale` varchar(6) NULL,
  `path` varchar(255) NULL,
  `query_string` text NULL,
  `referrer` text NULL,
  `view_online_display` text NULL,
  `view_online_link` tinyint unsigned NULL,
  `hide_online` tinyint unsigned NULL,
  `last_active` datetime NOT NULL,
  `invalid_logins` smallint unsigned NOT NULL DEFAULT 0,
  `last_invalid_login` datetime NULL,
  INDEX `sessions_idx_user` (`user`),
  INDEX `sessions_idx_user_agent` (`user_agent`),
  PRIMARY KEY (`id`),
  CONSTRAINT `sessions_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `sessions_fk_user_agent` FOREIGN KEY (`user_agent`) REFERENCES `user_agents` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log`
--
CREATE TABLE `system_event_log` (
  `id` integer unsigned NOT NULL auto_increment,
  `object_type` varchar(40) NOT NULL,
  `event_type` varchar(20) NOT NULL,
  `user_id` integer unsigned NULL,
  `ip_address` varchar(40) NOT NULL,
  `log_created` datetime NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` integer NOT NULL,
  INDEX `system_event_log_idx_object_type_event_type` (`object_type`, `event_type`),
  INDEX `system_event_log_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_fk_object_type_event_type` FOREIGN KEY (`object_type`, `event_type`) REFERENCES `system_event_log_types` (`object_type`, `event_type`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `system_event_log_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_average_filters`
--
CREATE TABLE `system_event_log_average_filters` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_average_filters_idx_object_id` (`object_id`),
  INDEX `system_event_log_average_filters_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_average_filters_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `average_filters` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_average_filters_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_club`
--
CREATE TABLE `system_event_log_club` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_club_idx_object_id` (`object_id`),
  INDEX `system_event_log_club_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_club_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `clubs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_club_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_contact_reason`
--
CREATE TABLE `system_event_log_contact_reason` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_contact_reason_idx_object_id` (`object_id`),
  INDEX `system_event_log_contact_reason_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_contact_reason_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `contact_reasons` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_contact_reason_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_division`
--
CREATE TABLE `system_event_log_division` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_division_idx_object_id` (`object_id`),
  INDEX `system_event_log_division_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_division_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `divisions` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_division_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_event`
--
CREATE TABLE `system_event_log_event` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_event_idx_object_id` (`object_id`),
  INDEX `system_event_log_event_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_event_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `events` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_event_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_file`
--
CREATE TABLE `system_event_log_file` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL DEFAULT 0,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_file_idx_object_id` (`object_id`),
  INDEX `system_event_log_file_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_file_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `uploaded_files` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_file_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_fixtures_grid`
--
CREATE TABLE `system_event_log_fixtures_grid` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_fixtures_grid_idx_object_id` (`object_id`),
  INDEX `system_event_log_fixtures_grid_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_fixtures_grid_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `fixtures_grids` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_fixtures_grid_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_image`
--
CREATE TABLE `system_event_log_image` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_image_idx_object_id` (`object_id`),
  INDEX `system_event_log_image_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_image_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `uploaded_images` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_image_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_meeting`
--
CREATE TABLE `system_event_log_meeting` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_meeting_idx_object_id` (`object_id`),
  INDEX `system_event_log_meeting_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_meeting_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `meetings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_meeting_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_meeting_type`
--
CREATE TABLE `system_event_log_meeting_type` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_meeting_type_idx_object_id` (`object_id`),
  INDEX `system_event_log_meeting_type_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_meeting_type_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `meeting_types` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_meeting_type_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_news`
--
CREATE TABLE `system_event_log_news` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_news_idx_object_id` (`object_id`),
  INDEX `system_event_log_news_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_news_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `news_articles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_news_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_person`
--
CREATE TABLE `system_event_log_person` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_person_idx_object_id` (`object_id`),
  INDEX `system_event_log_person_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_person_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `people` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_person_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_role`
--
CREATE TABLE `system_event_log_role` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint NOT NULL,
  INDEX `system_event_log_role_idx_object_id` (`object_id`),
  INDEX `system_event_log_role_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_role_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_role_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_season`
--
CREATE TABLE `system_event_log_season` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_season_idx_object_id` (`object_id`),
  INDEX `system_event_log_season_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_season_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `seasons` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_season_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_team`
--
CREATE TABLE `system_event_log_team` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_team_idx_object_id` (`object_id`),
  INDEX `system_event_log_team_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_team_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_team_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_team_match`
--
CREATE TABLE `system_event_log_team_match` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_home_team` integer unsigned NULL,
  `object_away_team` integer unsigned NULL,
  `object_scheduled_date` date NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_team_match_idx_system_event_log_id` (`system_event_log_id`),
  INDEX `system_event_log_team_match_idx_object_home_team_object_9712ee94` (`object_home_team`, `object_away_team`, `object_scheduled_date`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_team_match_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `system_event_log_team_match_fk_object_home_team_object__3cbae778` FOREIGN KEY (`object_home_team`, `object_away_team`, `object_scheduled_date`) REFERENCES `team_matches` (`home_team`, `away_team`, `scheduled_date`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `system_event_log_template_league_table_ranking`
--
CREATE TABLE `system_event_log_template_league_table_ranking` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_template_league_table_ranking_idx_object_id` (`object_id`),
  INDEX `system_event_log_template_league_table_ranking_idx_syst_ddd517a7` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_template_league_table_ranking_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `template_league_table_ranking` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_template_league_table_ranking_fk_syste_df5aca04` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_template_match_individual`
--
CREATE TABLE `system_event_log_template_match_individual` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_template_match_individual_idx_object_id` (`object_id`),
  INDEX `system_event_log_template_match_individual_idx_system_e_f830cac8` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_template_match_individual_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `template_match_individual` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_template_match_individual_fk_system_ev_d20223e8` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_template_match_team`
--
CREATE TABLE `system_event_log_template_match_team` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_template_match_team_idx_object_id` (`object_id`),
  INDEX `system_event_log_template_match_team_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_template_match_team_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `template_match_team` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_template_match_team_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_template_match_team_game`
--
CREATE TABLE `system_event_log_template_match_team_game` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_template_match_team_game_idx_object_id` (`object_id`),
  INDEX `system_event_log_template_match_team_game_idx_system_ev_c4661353` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_template_match_team_game_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `template_match_team` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_template_match_team_game_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_types`
--
CREATE TABLE `system_event_log_types` (
  `object_type` varchar(40) NOT NULL,
  `event_type` varchar(40) NOT NULL,
  `object_description` varchar(40) NOT NULL,
  `description` text NOT NULL,
  `view_action_for_uri` text NULL,
  `plural_objects` varchar(50) NOT NULL,
  `public_event` tinyint unsigned NOT NULL,
  PRIMARY KEY (`object_type`, `event_type`)
) ENGINE=InnoDB;
--
-- Table: `system_event_log_user`
--
CREATE TABLE `system_event_log_user` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_user_idx_object_id` (`object_id`),
  INDEX `system_event_log_user_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_user_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_user_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `system_event_log_venue`
--
CREATE TABLE `system_event_log_venue` (
  `id` integer unsigned NOT NULL auto_increment,
  `system_event_log_id` integer unsigned NOT NULL,
  `object_id` integer unsigned NULL,
  `name` text NOT NULL,
  `log_updated` datetime NOT NULL,
  `number_of_edits` tinyint unsigned NOT NULL,
  INDEX `system_event_log_venue_idx_object_id` (`object_id`),
  INDEX `system_event_log_venue_idx_system_event_log_id` (`system_event_log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_event_log_venue_fk_object_id` FOREIGN KEY (`object_id`) REFERENCES `venues` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `system_event_log_venue_fk_system_event_log_id` FOREIGN KEY (`system_event_log_id`) REFERENCES `system_event_log` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_match_games`
--
CREATE TABLE `team_match_games` (
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_game_number` tinyint unsigned NOT NULL,
  `individual_match_template` integer unsigned NOT NULL,
  `actual_game_number` tinyint unsigned NOT NULL,
  `home_player` integer unsigned NULL,
  `home_player_number` tinyint unsigned NULL,
  `away_player` integer unsigned NULL,
  `away_player_number` tinyint unsigned NULL,
  `home_doubles_pair` integer unsigned NULL,
  `away_doubles_pair` integer unsigned NULL,
  `home_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `away_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `home_team_match_score` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_match_score` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_game` tinyint unsigned NOT NULL DEFAULT 0,
  `game_in_progress` tinyint unsigned NOT NULL DEFAULT 0,
  `umpire` integer unsigned NULL,
  `started` tinyint unsigned NULL DEFAULT 0,
  `complete` tinyint unsigned NULL DEFAULT 0,
  `awarded` tinyint NULL,
  `void` tinyint NULL,
  `winner` integer unsigned NULL,
  INDEX `team_match_games_idx_away_doubles_pair` (`away_doubles_pair`),
  INDEX `team_match_games_idx_away_player` (`away_player`),
  INDEX `team_match_games_idx_home_doubles_pair` (`home_doubles_pair`),
  INDEX `team_match_games_idx_home_player` (`home_player`),
  INDEX `team_match_games_idx_individual_match_template` (`individual_match_template`),
  INDEX `team_match_games_idx_home_team_away_team_scheduled_date` (`home_team`, `away_team`, `scheduled_date`),
  INDEX `team_match_games_idx_umpire` (`umpire`),
  INDEX `team_match_games_idx_winner` (`winner`),
  PRIMARY KEY (`home_team`, `away_team`, `scheduled_date`, `scheduled_game_number`),
  CONSTRAINT `team_match_games_fk_away_doubles_pair` FOREIGN KEY (`away_doubles_pair`) REFERENCES `doubles_pairs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_away_player` FOREIGN KEY (`away_player`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_home_doubles_pair` FOREIGN KEY (`home_doubles_pair`) REFERENCES `doubles_pairs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_home_player` FOREIGN KEY (`home_player`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_individual_match_template` FOREIGN KEY (`individual_match_template`) REFERENCES `template_match_individual` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_home_team_away_team_scheduled_date` FOREIGN KEY (`home_team`, `away_team`, `scheduled_date`) REFERENCES `team_matches` (`home_team`, `away_team`, `scheduled_date`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `team_match_games_fk_umpire` FOREIGN KEY (`umpire`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_games_fk_winner` FOREIGN KEY (`winner`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_match_legs`
--
CREATE TABLE `team_match_legs` (
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_game_number` tinyint unsigned NOT NULL,
  `leg_number` tinyint unsigned NOT NULL,
  `home_team_points_won` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_points_won` tinyint unsigned NOT NULL DEFAULT 0,
  `first_server` integer unsigned NULL,
  `leg_in_progress` tinyint unsigned NOT NULL DEFAULT 0,
  `next_point_server` integer unsigned NULL,
  `started` tinyint unsigned NOT NULL DEFAULT 0,
  `complete` tinyint unsigned NOT NULL DEFAULT 0,
  `awarded` tinyint unsigned NOT NULL DEFAULT 0,
  `void` tinyint unsigned NOT NULL DEFAULT 0,
  `winner` integer unsigned NULL,
  INDEX `team_match_legs_idx_first_server` (`first_server`),
  INDEX `team_match_legs_idx_next_point_server` (`next_point_server`),
  INDEX `team_match_legs_idx_home_team_away_team_scheduled_date__c7144a26` (`home_team`, `away_team`, `scheduled_date`, `scheduled_game_number`),
  INDEX `team_match_legs_idx_winner` (`winner`),
  PRIMARY KEY (`home_team`, `away_team`, `scheduled_date`, `scheduled_game_number`, `leg_number`),
  CONSTRAINT `team_match_legs_fk_first_server` FOREIGN KEY (`first_server`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_legs_fk_next_point_server` FOREIGN KEY (`next_point_server`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_legs_fk_home_team_away_team_scheduled_date_s_b7a818b5` FOREIGN KEY (`home_team`, `away_team`, `scheduled_date`, `scheduled_game_number`) REFERENCES `team_match_games` (`home_team`, `away_team`, `scheduled_date`, `scheduled_game_number`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `team_match_legs_fk_winner` FOREIGN KEY (`winner`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_match_players`
--
CREATE TABLE `team_match_players` (
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `player_number` tinyint unsigned NOT NULL,
  `location` varchar(10) NOT NULL,
  `player` integer unsigned NULL,
  `player_missing` tinyint unsigned NOT NULL DEFAULT 0,
  `loan_team` integer unsigned NULL,
  `games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `legs_played` tinyint unsigned NOT NULL DEFAULT 0,
  `legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `legs_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `points_played` smallint unsigned NOT NULL DEFAULT 0,
  `points_won` smallint unsigned NOT NULL DEFAULT 0,
  `points_lost` smallint unsigned NOT NULL DEFAULT 0,
  `average_point_wins` float unsigned NOT NULL DEFAULT 0,
  INDEX `team_match_players_idx_loan_team` (`loan_team`),
  INDEX `team_match_players_idx_location` (`location`),
  INDEX `team_match_players_idx_player` (`player`),
  INDEX `team_match_players_idx_home_team_away_team_scheduled_date` (`home_team`, `away_team`, `scheduled_date`),
  PRIMARY KEY (`home_team`, `away_team`, `scheduled_date`, `player_number`),
  CONSTRAINT `team_match_players_fk_loan_team` FOREIGN KEY (`loan_team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_players_fk_location` FOREIGN KEY (`location`) REFERENCES `lookup_locations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_players_fk_player` FOREIGN KEY (`player`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_players_fk_home_team_away_team_scheduled_date` FOREIGN KEY (`home_team`, `away_team`, `scheduled_date`) REFERENCES `team_matches` (`home_team`, `away_team`, `scheduled_date`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `team_match_reports`
--
CREATE TABLE `team_match_reports` (
  `id` integer unsigned NOT NULL auto_increment,
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `published` datetime NOT NULL,
  `author` integer unsigned NOT NULL,
  `report` longtext NULL,
  INDEX `team_match_reports_idx_author` (`author`),
  INDEX `team_match_reports_idx_home_team_away_team_scheduled_date` (`home_team`, `away_team`, `scheduled_date`),
  PRIMARY KEY (`id`),
  CONSTRAINT `team_match_reports_fk_author` FOREIGN KEY (`author`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_match_reports_fk_home_team_away_team_scheduled_date` FOREIGN KEY (`home_team`, `away_team`, `scheduled_date`) REFERENCES `team_matches` (`home_team`, `away_team`, `scheduled_date`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_matches`
--
CREATE TABLE `team_matches` (
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `scheduled_start_time` time NOT NULL,
  `season` integer unsigned NOT NULL,
  `tournament_round` integer unsigned NULL,
  `division` integer unsigned NOT NULL,
  `venue` integer unsigned NOT NULL,
  `scheduled_week` integer unsigned NOT NULL,
  `played_date` date NULL,
  `start_time` time NULL,
  `played_week` integer unsigned NULL,
  `team_match_template` integer unsigned NOT NULL,
  `started` tinyint unsigned NOT NULL DEFAULT 0,
  `updated_since` datetime NOT NULL,
  `home_team_games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `away_team_legs_won` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `home_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `home_team_average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `away_team_points_won` smallint unsigned NOT NULL DEFAULT 0,
  `away_team_average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `home_team_match_score` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_match_score` tinyint unsigned NOT NULL DEFAULT 0,
  `player_of_the_match` integer unsigned NULL,
  `fixtures_grid` integer unsigned NULL,
  `complete` tinyint unsigned NOT NULL DEFAULT 0,
  `league_official_verified` integer unsigned NULL,
  `home_team_verified` integer unsigned NULL,
  `away_team_verified` integer unsigned NULL,
  `cancelled` tinyint NOT NULL DEFAULT 0,
  INDEX `team_matches_idx_away_team` (`away_team`),
  INDEX `team_matches_idx_away_team_verified` (`away_team_verified`),
  INDEX `team_matches_idx_division` (`division`),
  INDEX `team_matches_idx_fixtures_grid` (`fixtures_grid`),
  INDEX `team_matches_idx_home_team` (`home_team`),
  INDEX `team_matches_idx_home_team_verified` (`home_team_verified`),
  INDEX `team_matches_idx_league_official_verified` (`league_official_verified`),
  INDEX `team_matches_idx_played_week` (`played_week`),
  INDEX `team_matches_idx_player_of_the_match` (`player_of_the_match`),
  INDEX `team_matches_idx_scheduled_week` (`scheduled_week`),
  INDEX `team_matches_idx_season` (`season`),
  INDEX `team_matches_idx_team_match_template` (`team_match_template`),
  INDEX `team_matches_idx_tournament_round` (`tournament_round`),
  INDEX `team_matches_idx_venue` (`venue`),
  PRIMARY KEY (`home_team`, `away_team`, `scheduled_date`),
  CONSTRAINT `team_matches_fk_away_team` FOREIGN KEY (`away_team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_away_team_verified` FOREIGN KEY (`away_team_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_division` FOREIGN KEY (`division`) REFERENCES `divisions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_fixtures_grid` FOREIGN KEY (`fixtures_grid`) REFERENCES `fixtures_grids` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_home_team` FOREIGN KEY (`home_team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_home_team_verified` FOREIGN KEY (`home_team_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_league_official_verified` FOREIGN KEY (`league_official_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_played_week` FOREIGN KEY (`played_week`) REFERENCES `fixtures_weeks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_player_of_the_match` FOREIGN KEY (`player_of_the_match`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_scheduled_week` FOREIGN KEY (`scheduled_week`) REFERENCES `fixtures_weeks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_team_match_template` FOREIGN KEY (`team_match_template`) REFERENCES `template_match_team` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_tournament_round` FOREIGN KEY (`tournament_round`) REFERENCES `tournament_rounds` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_matches_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_seasons`
--
CREATE TABLE `team_seasons` (
  `team` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `club` integer unsigned NOT NULL,
  `division` integer unsigned NOT NULL,
  `captain` integer unsigned NULL,
  `matches_played` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_won` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `matches_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `table_points` tinyint NULL DEFAULT 0,
  `games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `legs_played` smallint unsigned NOT NULL DEFAULT 0,
  `legs_won` smallint unsigned NOT NULL DEFAULT 0,
  `legs_lost` smallint unsigned NOT NULL DEFAULT 0,
  `average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `points_played` integer unsigned NOT NULL DEFAULT 0,
  `points_won` integer unsigned NOT NULL DEFAULT 0,
  `points_lost` integer unsigned NOT NULL DEFAULT 0,
  `average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_games_played` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_won` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_drawn` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_games_lost` tinyint unsigned NOT NULL DEFAULT 0,
  `doubles_average_game_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_legs_played` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_legs_won` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_legs_lost` smallint unsigned NOT NULL DEFAULT 0,
  `doubles_average_leg_wins` float unsigned NOT NULL DEFAULT 0,
  `doubles_points_played` integer unsigned NOT NULL DEFAULT 0,
  `doubles_points_won` integer unsigned NOT NULL DEFAULT 0,
  `doubles_points_lost` integer unsigned NOT NULL DEFAULT 0,
  `doubles_average_point_wins` float unsigned NOT NULL DEFAULT 0,
  `home_night` tinyint unsigned NOT NULL DEFAULT 0,
  `grid_position` tinyint unsigned NULL DEFAULT 0,
  `last_updated` datetime NOT NULL,
  INDEX `team_seasons_idx_captain` (`captain`),
  INDEX `team_seasons_idx_club` (`club`),
  INDEX `team_seasons_idx_division` (`division`),
  INDEX `team_seasons_idx_home_night` (`home_night`),
  INDEX `team_seasons_idx_season` (`season`),
  INDEX `team_seasons_idx_team` (`team`),
  PRIMARY KEY (`team`, `season`),
  CONSTRAINT `team_seasons_fk_captain` FOREIGN KEY (`captain`) REFERENCES `people` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_fk_club` FOREIGN KEY (`club`) REFERENCES `clubs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_fk_division` FOREIGN KEY (`division`) REFERENCES `divisions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_fk_home_night` FOREIGN KEY (`home_night`) REFERENCES `lookup_weekdays` (`weekday_number`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `team_seasons_intervals`
--
CREATE TABLE `team_seasons_intervals` (
  `team` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `week` integer unsigned NOT NULL,
  `division` integer unsigned NOT NULL,
  `league_table_points` smallint unsigned NOT NULL,
  `matches_played` tinyint unsigned NOT NULL,
  `matches_won` tinyint unsigned NOT NULL,
  `matches_lost` tinyint unsigned NOT NULL,
  `matches_drawn` tinyint unsigned NOT NULL,
  `games_played` tinyint unsigned NOT NULL,
  `games_won` tinyint unsigned NOT NULL,
  `games_lost` tinyint unsigned NOT NULL,
  `games_drawn` tinyint unsigned NOT NULL,
  `average_game_wins` float unsigned NOT NULL,
  `legs_played` tinyint unsigned NOT NULL,
  `legs_won` tinyint unsigned NOT NULL,
  `legs_lost` tinyint unsigned NOT NULL,
  `average_leg_wins` float unsigned NOT NULL,
  `points_played` integer unsigned NOT NULL,
  `points_won` integer unsigned NOT NULL,
  `points_lost` integer unsigned NOT NULL,
  `average_point_wins` float unsigned NOT NULL,
  `table_points` tinyint NULL DEFAULT 0,
  INDEX `team_seasons_intervals_idx_division` (`division`),
  INDEX `team_seasons_intervals_idx_season` (`season`),
  INDEX `team_seasons_intervals_idx_team` (`team`),
  INDEX `team_seasons_intervals_idx_week` (`week`),
  PRIMARY KEY (`team`, `season`, `week`),
  CONSTRAINT `team_seasons_intervals_fk_division` FOREIGN KEY (`division`) REFERENCES `divisions` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_intervals_fk_season` FOREIGN KEY (`season`) REFERENCES `seasons` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_intervals_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `team_seasons_intervals_fk_week` FOREIGN KEY (`week`) REFERENCES `fixtures_weeks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `teams`
--
CREATE TABLE `teams` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(150) NOT NULL,
  `club` integer unsigned NOT NULL,
  `default_match_start` time NULL,
  INDEX `teams_idx_club` (`club`),
  PRIMARY KEY (`id`),
  UNIQUE `name_club` (`name`, `club`),
  UNIQUE `url_key_club` (`url_key`, `club`),
  CONSTRAINT `teams_fk_club` FOREIGN KEY (`club`) REFERENCES `clubs` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `template_league_table_ranking`
--
CREATE TABLE `template_league_table_ranking` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(30) NOT NULL,
  `name` text NOT NULL,
  `assign_points` tinyint unsigned NULL,
  `points_per_win` tinyint NULL,
  `points_per_draw` tinyint NULL,
  `points_per_loss` tinyint NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `template_match_individual`
--
CREATE TABLE `template_match_individual` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(60) NOT NULL,
  `name` varchar(45) NOT NULL,
  `game_type` varchar(20) NOT NULL,
  `legs_per_game` tinyint unsigned NOT NULL,
  `minimum_points_win` tinyint unsigned NOT NULL,
  `clear_points_win` tinyint unsigned NOT NULL,
  `serve_type` varchar(20) NOT NULL,
  `serves` tinyint unsigned NULL,
  `serves_deuce` tinyint unsigned NULL,
  INDEX `template_match_individual_idx_game_type` (`game_type`),
  INDEX `template_match_individual_idx_serve_type` (`serve_type`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `template_match_individual_fk_game_type` FOREIGN KEY (`game_type`) REFERENCES `lookup_game_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `template_match_individual_fk_serve_type` FOREIGN KEY (`serve_type`) REFERENCES `lookup_serve_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `template_match_team`
--
CREATE TABLE `template_match_team` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  `singles_players_per_team` tinyint unsigned NOT NULL,
  `winner_type` varchar(10) NOT NULL,
  INDEX `template_match_team_idx_winner_type` (`winner_type`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `template_match_team_fk_winner_type` FOREIGN KEY (`winner_type`) REFERENCES `lookup_winner_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `template_match_team_games`
--
CREATE TABLE `template_match_team_games` (
  `id` integer unsigned NOT NULL auto_increment,
  `team_match_template` integer unsigned NOT NULL,
  `individual_match_template` integer unsigned NULL,
  `match_game_number` tinyint unsigned NOT NULL,
  `doubles_game` tinyint unsigned NOT NULL,
  `singles_home_player_number` tinyint unsigned NULL,
  `singles_away_player_number` tinyint unsigned NULL,
  INDEX `template_match_team_games_idx_individual_match_template` (`individual_match_template`),
  INDEX `template_match_team_games_idx_team_match_template` (`team_match_template`),
  PRIMARY KEY (`id`),
  CONSTRAINT `template_match_team_games_fk_individual_match_template` FOREIGN KEY (`individual_match_template`) REFERENCES `template_match_individual` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `template_match_team_games_fk_team_match_template` FOREIGN KEY (`team_match_template`) REFERENCES `template_match_team` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_round_group_individual_membership`
--
CREATE TABLE `tournament_round_group_individual_membership` (
  `id` integer unsigned NOT NULL auto_increment,
  `group` integer unsigned NOT NULL,
  `person1` integer unsigned NOT NULL,
  `person2` integer unsigned NULL,
  INDEX `tournament_round_group_individual_membership_idx_group` (`group`),
  INDEX `tournament_round_group_individual_membership_idx_person1` (`person1`),
  INDEX `tournament_round_group_individual_membership_idx_person2` (`person2`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tournament_round_group_individual_membership_fk_group` FOREIGN KEY (`group`) REFERENCES `tournament_round_groups` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_round_group_individual_membership_fk_person1` FOREIGN KEY (`person1`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_round_group_individual_membership_fk_person2` FOREIGN KEY (`person2`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_round_group_team_membership`
--
CREATE TABLE `tournament_round_group_team_membership` (
  `id` integer unsigned NOT NULL auto_increment,
  `group` integer unsigned NOT NULL,
  `team` integer unsigned NOT NULL,
  INDEX `tournament_round_group_team_membership_idx_group` (`group`),
  INDEX `tournament_round_group_team_membership_idx_team` (`team`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tournament_round_group_team_membership_fk_group` FOREIGN KEY (`group`) REFERENCES `tournament_round_groups` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_round_group_team_membership_fk_team` FOREIGN KEY (`team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_round_groups`
--
CREATE TABLE `tournament_round_groups` (
  `id` integer unsigned NOT NULL auto_increment,
  `tournament_round` integer unsigned NOT NULL,
  `group_name` varchar(150) NOT NULL,
  `group_order` tinyint unsigned NOT NULL,
  INDEX `tournament_round_groups_idx_tournament_round` (`tournament_round`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tournament_round_groups_fk_tournament_round` FOREIGN KEY (`tournament_round`) REFERENCES `tournament_rounds` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_round_phases`
--
CREATE TABLE `tournament_round_phases` (
  `id` integer unsigned NOT NULL auto_increment,
  `tournament_round` integer unsigned NOT NULL,
  `phase_number` tinyint unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `date` date NOT NULL,
  INDEX `tournament_round_phases_idx_tournament_round` (`tournament_round`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tournament_round_phases_fk_tournament_round` FOREIGN KEY (`tournament_round`) REFERENCES `tournament_rounds` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_rounds`
--
CREATE TABLE `tournament_rounds` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `tournament` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `round_number` tinyint unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `round_type` char(1) NOT NULL,
  `team_match_template` integer unsigned NOT NULL,
  `individual_match_template` integer unsigned NOT NULL,
  `date` date NULL,
  `venue` integer unsigned NULL,
  INDEX `tournament_rounds_idx_individual_match_template` (`individual_match_template`),
  INDEX `tournament_rounds_idx_team_match_template` (`team_match_template`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key_unique_in_tournament_season` (`url_key`, `tournament`, `season`),
  CONSTRAINT `tournament_rounds_fk_individual_match_template` FOREIGN KEY (`individual_match_template`) REFERENCES `template_match_individual` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_rounds_fk_team_match_template` FOREIGN KEY (`team_match_template`) REFERENCES `template_match_team` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournament_team_matches`
--
CREATE TABLE `tournament_team_matches` (
  `id` integer unsigned NOT NULL auto_increment,
  `match_template` integer unsigned NOT NULL,
  `home_team` integer unsigned NOT NULL,
  `away_team` integer unsigned NOT NULL,
  `tournament_round_phase` integer unsigned NOT NULL,
  `venue` integer unsigned NOT NULL,
  `scheduled_date` date NOT NULL,
  `played_date` date NULL,
  `match_in_progress` tinyint unsigned NOT NULL DEFAULT 0,
  `home_team_score` tinyint unsigned NOT NULL DEFAULT 0,
  `away_team_score` tinyint unsigned NOT NULL DEFAULT 0,
  `complete` tinyint unsigned NOT NULL DEFAULT 0,
  `league_official_verified` integer unsigned NULL,
  `home_team_verified` integer unsigned NULL,
  `away_team_verified` integer unsigned NULL,
  INDEX `tournament_team_matches_idx_away_team` (`away_team`),
  INDEX `tournament_team_matches_idx_away_team_verified` (`away_team_verified`),
  INDEX `tournament_team_matches_idx_home_team` (`home_team`),
  INDEX `tournament_team_matches_idx_home_team_verified` (`home_team_verified`),
  INDEX `tournament_team_matches_idx_league_official_verified` (`league_official_verified`),
  INDEX `tournament_team_matches_idx_match_template` (`match_template`),
  INDEX `tournament_team_matches_idx_tournament_round_phase` (`tournament_round_phase`),
  INDEX `tournament_team_matches_idx_venue` (`venue`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tournament_team_matches_fk_away_team` FOREIGN KEY (`away_team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_away_team_verified` FOREIGN KEY (`away_team_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_home_team` FOREIGN KEY (`home_team`) REFERENCES `teams` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_home_team_verified` FOREIGN KEY (`home_team_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_league_official_verified` FOREIGN KEY (`league_official_verified`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_match_template` FOREIGN KEY (`match_template`) REFERENCES `template_match_team` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_tournament_round_phase` FOREIGN KEY (`tournament_round_phase`) REFERENCES `tournament_round_phases` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournament_team_matches_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `tournaments`
--
CREATE TABLE `tournaments` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` varchar(100) NOT NULL,
  `event` integer unsigned NOT NULL,
  `season` integer unsigned NOT NULL,
  `entry_type` varchar(20) NOT NULL,
  `allow_online_entries` tinyint unsigned NOT NULL DEFAULT 0,
  INDEX `tournaments_idx_entry_type` (`entry_type`),
  INDEX `tournaments_idx_event_season` (`event`, `season`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  CONSTRAINT `tournaments_fk_entry_type` FOREIGN KEY (`entry_type`) REFERENCES `lookup_tournament_types` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tournaments_fk_event_season` FOREIGN KEY (`event`, `season`) REFERENCES `event_seasons` (`event`, `season`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `uploaded_files`
--
CREATE TABLE `uploaded_files` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `description` varchar(255) NULL,
  `mime_type` varchar(150) NOT NULL,
  `uploaded` datetime NOT NULL,
  `downloaded_count` integer unsigned NOT NULL DEFAULT 0,
  `deleted` tinyint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `uploaded_images`
--
CREATE TABLE `uploaded_images` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `description` varchar(255) NULL,
  `mime_type` varchar(150) NOT NULL,
  `uploaded` datetime NOT NULL,
  `viewed_count` integer unsigned NOT NULL DEFAULT 0,
  `deleted` tinyint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
--
-- Table: `user_agents`
--
CREATE TABLE `user_agents` (
  `id` integer unsigned NOT NULL auto_increment,
  `string` text NOT NULL,
  `sha256_hash` varchar(64) NOT NULL,
  `first_seen` datetime NOT NULL,
  `last_seen` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `user_ip_addresses_browsers`
--
CREATE TABLE `user_ip_addresses_browsers` (
  `user_id` integer unsigned NOT NULL,
  `ip_address` varchar(40) NOT NULL,
  `user_agent` integer unsigned NOT NULL,
  `first_seen` datetime NOT NULL,
  `last_seen` datetime NOT NULL,
  INDEX `user_ip_addresses_browsers_idx_user_id` (`user_id`),
  INDEX `user_ip_addresses_browsers_idx_user_agent` (`user_agent`),
  PRIMARY KEY (`user_id`, `ip_address`, `user_agent`),
  CONSTRAINT `user_ip_addresses_browsers_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_ip_addresses_browsers_fk_user_agent` FOREIGN KEY (`user_agent`) REFERENCES `user_agents` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `user_roles`
--
CREATE TABLE `user_roles` (
  `user` integer unsigned NOT NULL,
  `role` integer unsigned NOT NULL,
  INDEX `user_roles_idx_role` (`role`),
  INDEX `user_roles_idx_user` (`user`),
  PRIMARY KEY (`user`, `role`),
  CONSTRAINT `user_roles_fk_role` FOREIGN KEY (`role`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_roles_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `username` varchar(45) NOT NULL,
  `email_address` text NOT NULL,
  `person` integer unsigned NULL,
  `password` text NOT NULL,
  `change_password_next_login` tinyint unsigned NOT NULL DEFAULT 0,
  `html_emails` tinyint unsigned NOT NULL DEFAULT 0,
  `registered_date` datetime NOT NULL,
  `registered_ip` varchar(45) NOT NULL,
  `last_visit_date` datetime NOT NULL,
  `last_visit_ip` varchar(45) NULL,
  `last_active_date` datetime NOT NULL,
  `last_active_ip` varchar(45) NULL,
  `locale` varchar(6) NOT NULL,
  `timezone` varchar(50) NULL,
  `avatar` text NULL,
  `posts` integer unsigned NOT NULL DEFAULT 0,
  `comments` integer unsigned NOT NULL DEFAULT 0,
  `signature` mediumtext NULL,
  `facebook` varchar(255) NULL,
  `twitter` varchar(255) NULL,
  `aim` varchar(255) NULL,
  `jabber` varchar(255) NULL,
  `website` varchar(255) NULL,
  `interests` text NULL,
  `occupation` varchar(150) NULL,
  `location` varchar(150) NULL,
  `hide_online` tinyint unsigned NOT NULL DEFAULT 0,
  `activation_key` varchar(64) NULL,
  `activated` tinyint unsigned NOT NULL DEFAULT 0,
  `activation_expires` datetime NOT NULL,
  `invalid_logins` smallint unsigned NOT NULL DEFAULT 0,
  `password_reset_key` varchar(64) NULL,
  `password_reset_expires` datetime NOT NULL,
  `last_invalid_login` datetime NULL,
  INDEX `users_idx_person` (`person`),
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`),
  UNIQUE `user_person_idx` (`person`),
  CONSTRAINT `users_fk_person` FOREIGN KEY (`person`) REFERENCES `people` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `venue_timetables`
--
CREATE TABLE `venue_timetables` (
  `id` integer unsigned NOT NULL,
  `venue` integer unsigned NOT NULL,
  `day` tinyint unsigned NOT NULL,
  `number_of_tables` smallint unsigned NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `price_information` varchar(50) NULL,
  `description` text NOT NULL,
  `matches` tinyint unsigned NOT NULL,
  INDEX `venue_timetables_idx_day` (`day`),
  INDEX `venue_timetables_idx_venue` (`venue`),
  PRIMARY KEY (`id`),
  CONSTRAINT `venue_timetables_fk_day` FOREIGN KEY (`day`) REFERENCES `lookup_weekdays` (`weekday_number`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `venue_timetables_fk_venue` FOREIGN KEY (`venue`) REFERENCES `venues` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB;
--
-- Table: `venues`
--
CREATE TABLE `venues` (
  `id` integer unsigned NOT NULL auto_increment,
  `url_key` varchar(45) NOT NULL,
  `name` text NOT NULL,
  `address1` varchar(100) NULL,
  `address2` varchar(100) NULL,
  `address3` varchar(100) NULL,
  `address4` varchar(100) NULL,
  `address5` varchar(100) NULL,
  `postcode` varchar(10) NULL,
  `telephone` varchar(20) NULL,
  `email_address` varchar(240) NULL,
  `coordinates_latitude` float(10, 8) NULL,
  `coordinates_longitude` float(11, 8) NULL,
  PRIMARY KEY (`id`),
  UNIQUE `url_key` (`url_key`)
) ENGINE=InnoDB;
SET foreign_key_checks=1;
