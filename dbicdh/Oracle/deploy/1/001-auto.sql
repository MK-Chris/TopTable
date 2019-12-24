-- 
-- Created by SQL::Translator::Producer::Oracle
-- Created on Mon Dec 23 13:25:36 2019
-- 
;
--
-- Table: average_filters
--;
CREATE SEQUENCE "sq_average_filters_id";
CREATE TABLE "average_filters" (
  "id" number NOT NULL,
  "url_key" varchar2(50) NOT NULL,
  "name" varchar2(50) NOT NULL,
  "show_active" number DEFAULT '1',
  "show_loan" number DEFAULT '0',
  "show_inactive" number DEFAULT '0',
  "criteria_field" varchar2(10),
  "operator" varchar2(2),
  "criteria" number NOT NULL,
  "criteria_type" varchar2(10),
  "user" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_average_filters_name_user" UNIQUE ("name", "user"),
  CONSTRAINT "u_average_filters_url_key" UNIQUE ("url_key")
);
--
-- Table: calendar_types
--;
CREATE SEQUENCE "sq_calendar_types_id";
CREATE TABLE "calendar_types" (
  "id" number NOT NULL,
  "url_key" varchar2(50) NOT NULL,
  "name" varchar2(50) NOT NULL,
  "uri" varchar2(500) NOT NULL,
  "calendar_scheme" varchar2(10),
  "uri_escape_replacements" number DEFAULT '0' NOT NULL,
  "display_order" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_calendar_types_name" UNIQUE ("name")
);
--
-- Table: clubs
--;
CREATE SEQUENCE "sq_clubs_id";
CREATE TABLE "clubs" (
  "id" number NOT NULL,
  "url_key" varchar2(45),
  "full_name" varchar2(300) NOT NULL,
  "short_name" varchar2(150) NOT NULL,
  "venue" number NOT NULL,
  "secretary" number,
  "email_address" varchar2(200),
  "website" varchar2(2083),
  "facebook" varchar2(2083),
  "twitter" varchar2(2083),
  "instagram" varchar2(2083),
  "youtube" varchar2(2083),
  "default_match_start" date,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_clubs_url_key" UNIQUE ("url_key")
);
--
-- Table: contact_reason_recipients
--;
CREATE TABLE "contact_reason_recipients" (
  "contact_reason" number NOT NULL,
  "person" number NOT NULL,
  PRIMARY KEY ("contact_reason", "person")
);
--
-- Table: contact_reasons
--;
CREATE SEQUENCE "sq_contact_reasons_id";
CREATE TABLE "contact_reasons" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(50) NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: division_seasons
--;
CREATE TABLE "division_seasons" (
  "division" number NOT NULL,
  "season" number NOT NULL,
  "name" varchar2(45) NOT NULL,
  "fixtures_grid" number NOT NULL,
  "league_match_template" number NOT NULL,
  "league_table_ranking_template" number NOT NULL,
  "promotion_places" number DEFAULT '0',
  "relegation_places" number DEFAULT '0',
  PRIMARY KEY ("division", "season")
);
--
-- Table: divisions
--;
CREATE SEQUENCE "sq_divisions_id";
CREATE TABLE "divisions" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(45) NOT NULL,
  "rank" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_divisions_url_key" UNIQUE ("url_key")
);
--
-- Table: doubles_pairs
--;
CREATE SEQUENCE "sq_doubles_pairs_id";
CREATE TABLE "doubles_pairs" (
  "id" number NOT NULL,
  "person1" number NOT NULL,
  "person2" number NOT NULL,
  "season" number NOT NULL,
  "team" number NOT NULL,
  "person1_loan" number DEFAULT '0' NOT NULL,
  "person2_loan" number DEFAULT '0' NOT NULL,
  "games_played" number DEFAULT '0' NOT NULL,
  "games_won" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "games_lost" number DEFAULT '0' NOT NULL,
  "average_game_wins" float DEFAULT '0' NOT NULL,
  "legs_played" number DEFAULT '0' NOT NULL,
  "legs_won" number DEFAULT '0' NOT NULL,
  "legs_lost" number DEFAULT '0' NOT NULL,
  "average_leg_wins" float DEFAULT '0' NOT NULL,
  "points_played" number DEFAULT '0' NOT NULL,
  "points_won" number DEFAULT '0' NOT NULL,
  "points_lost" number DEFAULT '0' NOT NULL,
  "average_point_wins" float DEFAULT '0' NOT NULL,
  "last_updated" date NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: event_seasons
--;
CREATE TABLE "event_seasons" (
  "event" number NOT NULL,
  "season" number NOT NULL,
  "name" varchar2(300) NOT NULL,
  "date" date,
  "date_and_start_time" date,
  "all_day" number,
  "finish_time" date,
  "organiser" number,
  "venue" number,
  "description" clob,
  PRIMARY KEY ("event", "season")
);
--
-- Table: events
--;
CREATE SEQUENCE "sq_events_id";
CREATE TABLE "events" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(300) NOT NULL,
  "event_type" varchar2(20) NOT NULL,
  "description" clob,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_events_url_key" UNIQUE ("url_key")
);
--
-- Table: fixtures_grid_matches
--;
CREATE TABLE "fixtures_grid_matches" (
  "grid" number NOT NULL,
  "week" number NOT NULL,
  "match_number" number NOT NULL,
  "home_team" number,
  "away_team" number,
  PRIMARY KEY ("grid", "week", "match_number")
);
--
-- Table: fixtures_grid_weeks
--;
CREATE TABLE "fixtures_grid_weeks" (
  "grid" number NOT NULL,
  "week" number NOT NULL,
  PRIMARY KEY ("grid", "week")
);
--
-- Table: fixtures_grids
--;
CREATE SEQUENCE "sq_fixtures_grids_id";
CREATE TABLE "fixtures_grids" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(45) NOT NULL,
  "maximum_teams" number NOT NULL,
  "fixtures_repeated" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_fixtures_grids_url_key" UNIQUE ("url_key")
);
--
-- Table: fixtures_season_weeks
--;
CREATE TABLE "fixtures_season_weeks" (
  "grid" number NOT NULL,
  "grid_week" number NOT NULL,
  "fixtures_week" number NOT NULL,
  PRIMARY KEY ("grid", "grid_week", "fixtures_week")
);
--
-- Table: fixtures_weeks
--;
CREATE SEQUENCE "sq_fixtures_weeks_id";
CREATE TABLE "fixtures_weeks" (
  "id" number NOT NULL,
  "season" number NOT NULL,
  "week_beginning_date" date NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: individual_matches
--;
CREATE SEQUENCE "sq_individual_matches_id";
CREATE TABLE "individual_matches" (
  "id" number NOT NULL,
  "home_player" number,
  "away_player" number,
  "individual_match_template" number NOT NULL,
  "home_doubles_pair" number,
  "away_doubles_pair" number,
  "home_team_legs_won" number DEFAULT '0' NOT NULL,
  "away_team_legs_won" number DEFAULT '0' NOT NULL,
  "home_team_points_won" number DEFAULT '0' NOT NULL,
  "away_team_points_won" number DEFAULT '0' NOT NULL,
  "doubles_game" number DEFAULT '0' NOT NULL,
  "umpire" number,
  "started" number DEFAULT '0',
  "complete" number DEFAULT '0',
  "awarded" number,
  "void" number,
  "winner" number,
  PRIMARY KEY ("id")
);
--
-- Table: invalid_logins
--;
CREATE TABLE "invalid_logins" (
  "ip_address" varchar2(40) NOT NULL,
  "invalid_logins" number NOT NULL,
  "last_invalid_login" date NOT NULL,
  PRIMARY KEY ("ip_address")
);
--
-- Table: lookup_event_types
--;
CREATE TABLE "lookup_event_types" (
  "id" varchar2(20) NOT NULL,
  "display_order" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_lookup_event_types_display_o" UNIQUE ("display_order")
);
--
-- Table: lookup_game_types
--;
CREATE TABLE "lookup_game_types" (
  "id" varchar2(20) NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: lookup_gender
--;
CREATE TABLE "lookup_gender" (
  "id" varchar2(20) DEFAULT '' NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: lookup_locations
--;
CREATE TABLE "lookup_locations" (
  "id" varchar2(10) NOT NULL,
  "location" varchar2(20) DEFAULT '' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_lookup_locations_location" UNIQUE ("location")
);
--
-- Table: lookup_serve_types
--;
CREATE TABLE "lookup_serve_types" (
  "id" varchar2(20) NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: lookup_team_membership_types
--;
CREATE TABLE "lookup_team_membership_types" (
  "id" varchar2(20) NOT NULL,
  "display_order" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: lookup_tournament_types
--;
CREATE TABLE "lookup_tournament_types" (
  "id" varchar2(20) NOT NULL,
  "display_order" number NOT NULL,
  "allowed_in_single_tournament_e" number NOT NULL,
  "allowed_in_multi_tournament_ev" number NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_lookup_tournament_types_disp" UNIQUE ("display_order")
);
--
-- Table: lookup_weekdays
--;
CREATE TABLE "lookup_weekdays" (
  "weekday_number" number DEFAULT '0' NOT NULL,
  "weekday_name" varchar2(20),
  PRIMARY KEY ("weekday_number"),
  CONSTRAINT "u_lookup_weekdays_weekday_name" UNIQUE ("weekday_name")
);
--
-- Table: lookup_winner_types
--;
CREATE TABLE "lookup_winner_types" (
  "id" varchar2(10) NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: meeting_attendees
--;
CREATE TABLE "meeting_attendees" (
  "meeting" number NOT NULL,
  "person" number NOT NULL,
  "apologies" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("meeting", "person")
);
--
-- Table: meeting_types
--;
CREATE SEQUENCE "sq_meeting_types_id";
CREATE TABLE "meeting_types" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(45) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_meeting_types_url_key" UNIQUE ("url_key")
);
--
-- Table: meetings
--;
CREATE SEQUENCE "sq_meetings_id";
CREATE TABLE "meetings" (
  "id" number NOT NULL,
  "event" number,
  "season" number,
  "type" number,
  "organiser" number,
  "venue" number,
  "date_and_start_time" date,
  "all_day" number,
  "finish_time" date,
  "agenda" clob,
  "minutes" clob,
  PRIMARY KEY ("id")
);
--
-- Table: news_articles
--;
CREATE SEQUENCE "sq_news_articles_id";
CREATE TABLE "news_articles" (
  "id" number NOT NULL,
  "url_key" varchar2(45),
  "published_year" date,
  "published_month" number,
  "updated_by_user" number NOT NULL,
  "ip_address" varchar2(45) NOT NULL,
  "date_updated" date NOT NULL,
  "headline" varchar2(500) NOT NULL,
  "article_content" clob NOT NULL,
  "original_article" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_news_articles_url_key" UNIQUE ("url_key", "published_year", "published_month")
);
--
-- Table: officials
--;
CREATE SEQUENCE "sq_officials_id";
CREATE TABLE "officials" (
  "id" number NOT NULL,
  "position" varchar2(150) NOT NULL,
  "position_order" number NOT NULL,
  "position_holder" number NOT NULL,
  "season" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: page_text
--;
CREATE TABLE "page_text" (
  "page_key" varchar2(50) NOT NULL,
  "page_text" clob NOT NULL,
  "last_updated" date NOT NULL,
  PRIMARY KEY ("page_key")
);
--
-- Table: people
--;
CREATE SEQUENCE "sq_people_id";
CREATE TABLE "people" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "first_name" varchar2(150) NOT NULL,
  "surname" varchar2(150) NOT NULL,
  "display_name" varchar2(301) NOT NULL,
  "date_of_birth" date,
  "gender" varchar2(20),
  "address1" varchar2(150),
  "address2" varchar2(150),
  "address3" varchar2(150),
  "address4" varchar2(150),
  "address5" varchar2(150),
  "postcode" varchar2(8),
  "home_telephone" varchar2(25),
  "work_telephone" varchar2(25),
  "mobile_telephone" varchar2(25),
  "email_address" varchar2(254),
  PRIMARY KEY ("id"),
  CONSTRAINT "u_people_url_key" UNIQUE ("url_key")
);
--
-- Table: person_seasons
--;
CREATE TABLE "person_seasons" (
  "person" number NOT NULL,
  "season" number NOT NULL,
  "team" number NOT NULL,
  "first_name" varchar2(150) NOT NULL,
  "surname" varchar2(150) NOT NULL,
  "display_name" varchar2(301) NOT NULL,
  "registration_date" date,
  "fees_paid" number DEFAULT '0' NOT NULL,
  "matches_played" number DEFAULT '0' NOT NULL,
  "matches_won" number DEFAULT '0' NOT NULL,
  "matches_drawn" number DEFAULT '0' NOT NULL,
  "matches_lost" number DEFAULT '0' NOT NULL,
  "games_played" number DEFAULT '0' NOT NULL,
  "games_won" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "games_lost" number DEFAULT '0' NOT NULL,
  "average_game_wins" float DEFAULT '0' NOT NULL,
  "legs_played" number DEFAULT '0' NOT NULL,
  "legs_won" number DEFAULT '0' NOT NULL,
  "legs_lost" number DEFAULT '0' NOT NULL,
  "average_leg_wins" float DEFAULT '0' NOT NULL,
  "points_played" number DEFAULT '0' NOT NULL,
  "points_won" number DEFAULT '0' NOT NULL,
  "points_lost" number DEFAULT '0' NOT NULL,
  "average_point_wins" float DEFAULT '0' NOT NULL,
  "doubles_games_played" number DEFAULT '0' NOT NULL,
  "doubles_games_won" number DEFAULT '0' NOT NULL,
  "doubles_games_drawn" number DEFAULT '0' NOT NULL,
  "doubles_games_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_game_wins" float DEFAULT '0' NOT NULL,
  "doubles_legs_played" number DEFAULT '0' NOT NULL,
  "doubles_legs_won" number DEFAULT '0' NOT NULL,
  "doubles_legs_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_leg_wins" float DEFAULT '0' NOT NULL,
  "doubles_points_played" number DEFAULT '0' NOT NULL,
  "doubles_points_won" number DEFAULT '0' NOT NULL,
  "doubles_points_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_point_wins" float DEFAULT '0' NOT NULL,
  "team_membership_type" varchar2(20) DEFAULT 'active' NOT NULL,
  "last_updated" date NOT NULL,
  PRIMARY KEY ("person", "season", "team")
);
--
-- Table: person_tournaments
--;
CREATE SEQUENCE "sq_person_tournaments_id";
CREATE TABLE "person_tournaments" (
  "id" number NOT NULL,
  "tournament" number NOT NULL,
  "season" number NOT NULL,
  "person1" number NOT NULL,
  "person2" number NOT NULL,
  "team" number,
  "first_name" varchar2(150) NOT NULL,
  "surname" varchar2(150) NOT NULL,
  "display_name" varchar2(301) NOT NULL,
  "registration_date" date,
  "fees_paid" number DEFAULT '0' NOT NULL,
  "matches_played" number DEFAULT '0' NOT NULL,
  "matches_won" number DEFAULT '0' NOT NULL,
  "matches_drawn" number DEFAULT '0' NOT NULL,
  "matches_lost" number DEFAULT '0' NOT NULL,
  "games_played" number DEFAULT '0' NOT NULL,
  "games_won" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "games_lost" number DEFAULT '0' NOT NULL,
  "average_game_wins" float DEFAULT '0' NOT NULL,
  "legs_played" number DEFAULT '0' NOT NULL,
  "legs_won" number DEFAULT '0' NOT NULL,
  "legs_lost" number DEFAULT '0' NOT NULL,
  "average_leg_wins" float DEFAULT '0' NOT NULL,
  "points_played" number DEFAULT '0' NOT NULL,
  "points_won" number DEFAULT '0' NOT NULL,
  "points_lost" number DEFAULT '0' NOT NULL,
  "average_point_wins" float DEFAULT '0' NOT NULL,
  "team_membership_type" varchar2(20) DEFAULT 'active' NOT NULL,
  "last_updated" date NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: roles
--;
CREATE SEQUENCE "sq_roles_id";
CREATE TABLE "roles" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(100) NOT NULL,
  "system" number DEFAULT '0' NOT NULL,
  "sysadmin" number DEFAULT '0' NOT NULL,
  "anonymous" number DEFAULT '0' NOT NULL,
  "apply_on_registration" number DEFAULT '0' NOT NULL,
  "average_filter_create_public" number DEFAULT '0' NOT NULL,
  "average_filter_edit_public" number DEFAULT '0' NOT NULL,
  "average_filter_delete_public" number DEFAULT '0' NOT NULL,
  "average_filter_view_all" number DEFAULT '0' NOT NULL,
  "average_filter_edit_all" number DEFAULT '0' NOT NULL,
  "average_filter_delete_all" number DEFAULT '0' NOT NULL,
  "club_view" number DEFAULT '0' NOT NULL,
  "club_create" number DEFAULT '0' NOT NULL,
  "club_edit" number DEFAULT '0' NOT NULL,
  "club_delete" number DEFAULT '0' NOT NULL,
  "committee_view" number DEFAULT '0' NOT NULL,
  "committee_create" number DEFAULT '0' NOT NULL,
  "committee_edit" number DEFAULT '0' NOT NULL,
  "committee_delete" number DEFAULT '0' NOT NULL,
  "contact_reason_view" number DEFAULT '0' NOT NULL,
  "contact_reason_create" number DEFAULT '0' NOT NULL,
  "contact_reason_edit" number DEFAULT '0' NOT NULL,
  "contact_reason_delete" number DEFAULT '0' NOT NULL,
  "event_view" number DEFAULT '0' NOT NULL,
  "event_create" number DEFAULT '0' NOT NULL,
  "event_edit" number DEFAULT '0' NOT NULL,
  "event_delete" number DEFAULT '0' NOT NULL,
  "file_upload" number DEFAULT '0' NOT NULL,
  "fixtures_view" number DEFAULT '0' NOT NULL,
  "fixtures_create" number DEFAULT '0' NOT NULL,
  "fixtures_edit" number DEFAULT '0' NOT NULL,
  "fixtures_delete" number DEFAULT '0' NOT NULL,
  "image_upload" number DEFAULT '0' NOT NULL,
  "match_view" number DEFAULT '0' NOT NULL,
  "match_update" number DEFAULT '0' NOT NULL,
  "match_cancel" number DEFAULT '0' NOT NULL,
  "match_report_create" number DEFAULT '0' NOT NULL,
  "match_report_create_associated" number DEFAULT '0' NOT NULL,
  "match_report_edit_own" number DEFAULT '0' NOT NULL,
  "match_report_edit_all" number DEFAULT '0' NOT NULL,
  "match_report_delete_own" number DEFAULT '0' NOT NULL,
  "match_report_delete_all" number DEFAULT '0' NOT NULL,
  "meeting_view" number DEFAULT '0' NOT NULL,
  "meeting_create" number DEFAULT '0' NOT NULL,
  "meeting_edit" number DEFAULT '0' NOT NULL,
  "meeting_delete" number DEFAULT '0' NOT NULL,
  "meeting_type_view" number DEFAULT '0' NOT NULL,
  "meeting_type_create" number DEFAULT '0' NOT NULL,
  "meeting_type_edit" number DEFAULT '0' NOT NULL,
  "meeting_type_delete" number DEFAULT '0' NOT NULL,
  "news_article_view" number DEFAULT '0' NOT NULL,
  "news_article_create" number DEFAULT '0' NOT NULL,
  "news_article_edit_own" number DEFAULT '0' NOT NULL,
  "news_article_edit_all" number DEFAULT '0' NOT NULL,
  "news_article_delete_own" number DEFAULT '0' NOT NULL,
  "news_article_delete_all" number DEFAULT '0' NOT NULL,
  "online_users_view" number DEFAULT '0' NOT NULL,
  "anonymous_online_users_view" number DEFAULT '0' NOT NULL,
  "view_users_ip" number DEFAULT '0' NOT NULL,
  "view_users_user_agent" number DEFAULT '0' NOT NULL,
  "person_view" number DEFAULT '0' NOT NULL,
  "person_create" number DEFAULT '0' NOT NULL,
  "person_contact_view" number DEFAULT '0' NOT NULL,
  "person_edit" number DEFAULT '0' NOT NULL,
  "person_delete" number DEFAULT '0' NOT NULL,
  "privacy_view" number DEFAULT '0' NOT NULL,
  "privacy_edit" number DEFAULT '0' NOT NULL,
  "role_view" number DEFAULT '0' NOT NULL,
  "role_create" number DEFAULT '0' NOT NULL,
  "role_edit" number DEFAULT '0' NOT NULL,
  "role_delete" number DEFAULT '0' NOT NULL,
  "season_view" number DEFAULT '0' NOT NULL,
  "season_create" number DEFAULT '0' NOT NULL,
  "season_edit" number DEFAULT '0' NOT NULL,
  "season_delete" number DEFAULT '0' NOT NULL,
  "season_archive" number DEFAULT '0' NOT NULL,
  "session_delete" number DEFAULT '0' NOT NULL,
  "system_event_log_view_all" number DEFAULT '0' NOT NULL,
  "team_view" number DEFAULT '0' NOT NULL,
  "team_create" number DEFAULT '0' NOT NULL,
  "team_edit" number DEFAULT '0' NOT NULL,
  "team_delete" number DEFAULT '0' NOT NULL,
  "template_view" number DEFAULT '0' NOT NULL,
  "template_create" number DEFAULT '0' NOT NULL,
  "template_edit" number DEFAULT '0' NOT NULL,
  "template_delete" number DEFAULT '0' NOT NULL,
  "tournament_view" number DEFAULT '0' NOT NULL,
  "tournament_create" number DEFAULT '0' NOT NULL,
  "tournament_edit" number DEFAULT '0' NOT NULL,
  "tournament_delete" number DEFAULT '0' NOT NULL,
  "user_view" number DEFAULT '0' NOT NULL,
  "user_edit_all" number DEFAULT '0' NOT NULL,
  "user_edit_own" number DEFAULT '0' NOT NULL,
  "user_delete_all" number DEFAULT '0' NOT NULL,
  "user_delete_own" number DEFAULT '0' NOT NULL,
  "venue_view" number DEFAULT '0' NOT NULL,
  "venue_create" number DEFAULT '0' NOT NULL,
  "venue_edit" number DEFAULT '0' NOT NULL,
  "venue_delete" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_roles_url_key" UNIQUE ("url_key")
);
--
-- Table: seasons
--;
CREATE SEQUENCE "sq_seasons_id";
CREATE TABLE "seasons" (
  "id" number NOT NULL,
  "url_key" varchar2(30) NOT NULL,
  "name" varchar2(150) NOT NULL,
  "default_match_start" date NOT NULL,
  "timezone" varchar2(50) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "complete" number DEFAULT '0' NOT NULL,
  "allow_loan_players_below" number DEFAULT '0' NOT NULL,
  "allow_loan_players_above" number DEFAULT '0' NOT NULL,
  "allow_loan_players_across" number DEFAULT '0' NOT NULL,
  "allow_loan_players_multiple_te" number DEFAULT '0' NOT NULL,
  "allow_loan_players_same_club_o" number DEFAULT '0' NOT NULL,
  "loan_players_limit_per_player" number DEFAULT '0' NOT NULL,
  "loan_players_limit_per_player_" number DEFAULT '0' NOT NULL,
  "loan_players_limit_per_team" number DEFAULT '0' NOT NULL,
  "rules" clob,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_seasons_url_key" UNIQUE ("url_key")
);
--
-- Table: sessions
--;
CREATE TABLE "sessions" (
  "id" char(72) NOT NULL,
  "data" clob,
  "expires" number,
  "user" number,
  "ip_address" varchar2(40),
  "client_hostname" clob,
  "user_agent" number,
  "secure" number,
  "locale" varchar2(6),
  "path" varchar2(255),
  "query_string" clob,
  "referrer" clob,
  "view_online_display" varchar2(300),
  "view_online_link" number,
  "hide_online" number,
  "last_active" date NOT NULL,
  "invalid_logins" number DEFAULT '0' NOT NULL,
  "last_invalid_login" date,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log
--;
CREATE SEQUENCE "sq_system_event_log_id";
CREATE TABLE "system_event_log" (
  "id" number NOT NULL,
  "object_type" varchar2(40) NOT NULL,
  "event_type" varchar2(20) NOT NULL,
  "user_id" number,
  "ip_address" varchar2(40) NOT NULL,
  "log_created" date NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_average_filters
--;
CREATE SEQUENCE "sq_system_event_log_average_fi";
CREATE TABLE "system_event_log_average_filters" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_club
--;
CREATE SEQUENCE "sq_system_event_log_club_id";
CREATE TABLE "system_event_log_club" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_contact_reason
--;
CREATE SEQUENCE "sq_system_event_log_contact_re";
CREATE TABLE "system_event_log_contact_reason" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_division
--;
CREATE SEQUENCE "sq_system_event_log_division_i";
CREATE TABLE "system_event_log_division" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_event
--;
CREATE SEQUENCE "sq_system_event_log_event_id";
CREATE TABLE "system_event_log_event" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_file
--;
CREATE SEQUENCE "sq_system_event_log_file_id";
CREATE TABLE "system_event_log_file" (
  "id" number NOT NULL,
  "system_event_log_id" number DEFAULT '0' NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_fixtures_grid
--;
CREATE SEQUENCE "sq_system_event_log_fixtures_g";
CREATE TABLE "system_event_log_fixtures_grid" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_image
--;
CREATE SEQUENCE "sq_system_event_log_image_id";
CREATE TABLE "system_event_log_image" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_meeting
--;
CREATE SEQUENCE "sq_system_event_log_meeting_id";
CREATE TABLE "system_event_log_meeting" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_meeting_type
--;
CREATE SEQUENCE "sq_system_event_log_meeting_ty";
CREATE TABLE "system_event_log_meeting_type" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_news
--;
CREATE SEQUENCE "sq_system_event_log_news_id";
CREATE TABLE "system_event_log_news" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_person
--;
CREATE SEQUENCE "sq_system_event_log_person_id";
CREATE TABLE "system_event_log_person" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_role
--;
CREATE SEQUENCE "sq_system_event_log_role_id";
CREATE TABLE "system_event_log_role" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_season
--;
CREATE SEQUENCE "sq_system_event_log_season_id";
CREATE TABLE "system_event_log_season" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_team
--;
CREATE SEQUENCE "sq_system_event_log_team_id";
CREATE TABLE "system_event_log_team" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_team_match
--;
CREATE SEQUENCE "sq_system_event_log_team_match";
CREATE TABLE "system_event_log_team_match" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_home_team" number,
  "object_away_team" number,
  "object_scheduled_date" date,
  "name" varchar2(620) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_template_league_table_ranking
--;
CREATE SEQUENCE "sq_system_event_log_template_l";
CREATE TABLE "system_event_log_template_league_table_ranking" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_template_match_individual
--;
CREATE SEQUENCE "sq_system_event_log_template_m";
CREATE TABLE "system_event_log_template_match_individual" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_template_match_team
--;
CREATE SEQUENCE "sq_system_event_log_template01";
CREATE TABLE "system_event_log_template_match_team" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_template_match_team_game
--;
CREATE SEQUENCE "sq_system_event_log_template02";
CREATE TABLE "system_event_log_template_match_team_game" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_types
--;
CREATE TABLE "system_event_log_types" (
  "object_type" varchar2(40) NOT NULL,
  "event_type" varchar2(40) NOT NULL,
  "object_description" varchar2(40) NOT NULL,
  "description" varchar2(500) NOT NULL,
  "view_action_for_uri" varchar2(500),
  "plural_objects" varchar2(50) NOT NULL,
  "public_event" number NOT NULL,
  PRIMARY KEY ("object_type", "event_type")
);
--
-- Table: system_event_log_user
--;
CREATE SEQUENCE "sq_system_event_log_user_id";
CREATE TABLE "system_event_log_user" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: system_event_log_venue
--;
CREATE SEQUENCE "sq_system_event_log_venue_id";
CREATE TABLE "system_event_log_venue" (
  "id" number NOT NULL,
  "system_event_log_id" number NOT NULL,
  "object_id" number,
  "name" varchar2(300) NOT NULL,
  "log_updated" date NOT NULL,
  "number_of_edits" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: team_match_games
--;
CREATE TABLE "team_match_games" (
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_game_number" number NOT NULL,
  "individual_match_template" number NOT NULL,
  "actual_game_number" number NOT NULL,
  "home_player" number,
  "home_player_number" number,
  "away_player" number,
  "away_player_number" number,
  "home_doubles_pair" number,
  "away_doubles_pair" number,
  "home_team_legs_won" number DEFAULT '0' NOT NULL,
  "away_team_legs_won" number DEFAULT '0' NOT NULL,
  "home_team_points_won" number DEFAULT '0' NOT NULL,
  "away_team_points_won" number DEFAULT '0' NOT NULL,
  "home_team_match_score" number DEFAULT '0' NOT NULL,
  "away_team_match_score" number DEFAULT '0' NOT NULL,
  "doubles_game" number DEFAULT '0' NOT NULL,
  "game_in_progress" number DEFAULT '0' NOT NULL,
  "umpire" number,
  "started" number DEFAULT '0',
  "complete" number DEFAULT '0',
  "awarded" number,
  "void" number,
  "winner" number,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number")
);
--
-- Table: team_match_legs
--;
CREATE TABLE "team_match_legs" (
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_game_number" number NOT NULL,
  "leg_number" number NOT NULL,
  "home_team_points_won" number DEFAULT '0' NOT NULL,
  "away_team_points_won" number DEFAULT '0' NOT NULL,
  "first_server" number,
  "leg_in_progress" number DEFAULT '0' NOT NULL,
  "next_point_server" number,
  "started" number DEFAULT '0' NOT NULL,
  "complete" number DEFAULT '0' NOT NULL,
  "awarded" number DEFAULT '0' NOT NULL,
  "void" number DEFAULT '0' NOT NULL,
  "winner" number,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number", "leg_number")
);
--
-- Table: team_match_players
--;
CREATE TABLE "team_match_players" (
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "player_number" number NOT NULL,
  "location" varchar2(10) NOT NULL,
  "player" number,
  "player_missing" number DEFAULT '0' NOT NULL,
  "loan_team" number,
  "games_played" number DEFAULT '0' NOT NULL,
  "games_won" number DEFAULT '0' NOT NULL,
  "games_lost" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "legs_played" number DEFAULT '0' NOT NULL,
  "legs_won" number DEFAULT '0' NOT NULL,
  "legs_lost" number DEFAULT '0' NOT NULL,
  "average_leg_wins" float DEFAULT '0' NOT NULL,
  "points_played" number DEFAULT '0' NOT NULL,
  "points_won" number DEFAULT '0' NOT NULL,
  "points_lost" number DEFAULT '0' NOT NULL,
  "average_point_wins" float DEFAULT '0' NOT NULL,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "player_number")
);
--
-- Table: team_match_reports
--;
CREATE SEQUENCE "sq_team_match_reports_id";
CREATE TABLE "team_match_reports" (
  "id" number NOT NULL,
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "published" date NOT NULL,
  "author" number NOT NULL,
  "report" clob,
  PRIMARY KEY ("id")
);
--
-- Table: team_matches
--;
CREATE TABLE "team_matches" (
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_start_time" date NOT NULL,
  "season" number NOT NULL,
  "tournament_round" number,
  "division" number NOT NULL,
  "venue" number NOT NULL,
  "scheduled_week" number NOT NULL,
  "played_date" date,
  "start_time" date,
  "played_week" number,
  "team_match_template" number NOT NULL,
  "started" number DEFAULT '0' NOT NULL,
  "updated_since" date NOT NULL,
  "home_team_games_won" number DEFAULT '0' NOT NULL,
  "home_team_games_lost" number DEFAULT '0' NOT NULL,
  "away_team_games_won" number DEFAULT '0' NOT NULL,
  "away_team_games_lost" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "home_team_legs_won" number DEFAULT '0' NOT NULL,
  "home_team_average_leg_wins" float DEFAULT '0' NOT NULL,
  "away_team_legs_won" number DEFAULT '0' NOT NULL,
  "away_team_average_leg_wins" float DEFAULT '0' NOT NULL,
  "home_team_points_won" number DEFAULT '0' NOT NULL,
  "home_team_average_point_wins" float DEFAULT '0' NOT NULL,
  "away_team_points_won" number DEFAULT '0' NOT NULL,
  "away_team_average_point_wins" float DEFAULT '0' NOT NULL,
  "home_team_match_score" number DEFAULT '0' NOT NULL,
  "away_team_match_score" number DEFAULT '0' NOT NULL,
  "player_of_the_match" number,
  "fixtures_grid" number,
  "complete" number DEFAULT '0' NOT NULL,
  "league_official_verified" number,
  "home_team_verified" number,
  "away_team_verified" number,
  "cancelled" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date")
);
--
-- Table: team_seasons
--;
CREATE TABLE "team_seasons" (
  "team" number NOT NULL,
  "season" number NOT NULL,
  "name" varchar2(150) NOT NULL,
  "club" number NOT NULL,
  "division" number NOT NULL,
  "captain" number,
  "matches_played" number DEFAULT '0' NOT NULL,
  "matches_won" number DEFAULT '0' NOT NULL,
  "matches_drawn" number DEFAULT '0' NOT NULL,
  "matches_lost" number DEFAULT '0' NOT NULL,
  "table_points" number DEFAULT '0',
  "games_played" number DEFAULT '0' NOT NULL,
  "games_won" number DEFAULT '0' NOT NULL,
  "games_drawn" number DEFAULT '0' NOT NULL,
  "games_lost" number DEFAULT '0' NOT NULL,
  "average_game_wins" float DEFAULT '0' NOT NULL,
  "legs_played" number DEFAULT '0' NOT NULL,
  "legs_won" number DEFAULT '0' NOT NULL,
  "legs_lost" number DEFAULT '0' NOT NULL,
  "average_leg_wins" float DEFAULT '0' NOT NULL,
  "points_played" number DEFAULT '0' NOT NULL,
  "points_won" number DEFAULT '0' NOT NULL,
  "points_lost" number DEFAULT '0' NOT NULL,
  "average_point_wins" float DEFAULT '0' NOT NULL,
  "doubles_games_played" number DEFAULT '0' NOT NULL,
  "doubles_games_won" number DEFAULT '0' NOT NULL,
  "doubles_games_drawn" number DEFAULT '0' NOT NULL,
  "doubles_games_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_game_wins" float DEFAULT '0' NOT NULL,
  "doubles_legs_played" number DEFAULT '0' NOT NULL,
  "doubles_legs_won" number DEFAULT '0' NOT NULL,
  "doubles_legs_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_leg_wins" float DEFAULT '0' NOT NULL,
  "doubles_points_played" number DEFAULT '0' NOT NULL,
  "doubles_points_won" number DEFAULT '0' NOT NULL,
  "doubles_points_lost" number DEFAULT '0' NOT NULL,
  "doubles_average_point_wins" float DEFAULT '0' NOT NULL,
  "home_night" number DEFAULT '0' NOT NULL,
  "grid_position" number DEFAULT '0',
  "last_updated" date NOT NULL,
  PRIMARY KEY ("team", "season")
);
--
-- Table: team_seasons_intervals
--;
CREATE TABLE "team_seasons_intervals" (
  "team" number NOT NULL,
  "season" number NOT NULL,
  "week" number NOT NULL,
  "division" number NOT NULL,
  "league_table_points" number NOT NULL,
  "matches_played" number NOT NULL,
  "matches_won" number NOT NULL,
  "matches_lost" number NOT NULL,
  "matches_drawn" number NOT NULL,
  "games_played" number NOT NULL,
  "games_won" number NOT NULL,
  "games_lost" number NOT NULL,
  "games_drawn" number NOT NULL,
  "average_game_wins" float NOT NULL,
  "legs_played" number NOT NULL,
  "legs_won" number NOT NULL,
  "legs_lost" number NOT NULL,
  "average_leg_wins" float NOT NULL,
  "points_played" number NOT NULL,
  "points_won" number NOT NULL,
  "points_lost" number NOT NULL,
  "average_point_wins" float NOT NULL,
  "table_points" number DEFAULT '0',
  PRIMARY KEY ("team", "season", "week")
);
--
-- Table: teams
--;
CREATE SEQUENCE "sq_teams_id";
CREATE TABLE "teams" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(150) NOT NULL,
  "club" number NOT NULL,
  "default_match_start" date,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_teams_name_club" UNIQUE ("name", "club"),
  CONSTRAINT "u_teams_url_key_club" UNIQUE ("url_key", "club")
);
--
-- Table: template_league_table_ranking
--;
CREATE SEQUENCE "sq_template_league_table_ranki";
CREATE TABLE "template_league_table_ranking" (
  "id" number NOT NULL,
  "url_key" varchar2(30) NOT NULL,
  "name" varchar2(300) NOT NULL,
  "assign_points" number,
  "points_per_win" number,
  "points_per_draw" number,
  "points_per_loss" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_template_league_table_rankin" UNIQUE ("url_key")
);
--
-- Table: template_match_individual
--;
CREATE SEQUENCE "sq_template_match_individual_i";
CREATE TABLE "template_match_individual" (
  "id" number NOT NULL,
  "url_key" varchar2(60) NOT NULL,
  "name" varchar2(45) NOT NULL,
  "game_type" varchar2(20) NOT NULL,
  "legs_per_game" number NOT NULL,
  "minimum_points_win" number NOT NULL,
  "clear_points_win" number NOT NULL,
  "serve_type" varchar2(20) NOT NULL,
  "serves" number,
  "serves_deuce" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_template_match_individual_ur" UNIQUE ("url_key")
);
--
-- Table: template_match_team
--;
CREATE SEQUENCE "sq_template_match_team_id";
CREATE TABLE "template_match_team" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(45) NOT NULL,
  "singles_players_per_team" number NOT NULL,
  "winner_type" varchar2(10) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_template_match_team_url_key" UNIQUE ("url_key")
);
--
-- Table: template_match_team_games
--;
CREATE SEQUENCE "sq_template_match_team_games_i";
CREATE TABLE "template_match_team_games" (
  "id" number NOT NULL,
  "team_match_template" number NOT NULL,
  "individual_match_template" number,
  "match_game_number" number NOT NULL,
  "doubles_game" number NOT NULL,
  "singles_home_player_number" number,
  "singles_away_player_number" number,
  PRIMARY KEY ("id")
);
--
-- Table: tournament_round_group_individual_membership
--;
CREATE SEQUENCE "sq_tournament_round_group_indi";
CREATE TABLE "tournament_round_group_individual_membership" (
  "id" number NOT NULL,
  "group" number NOT NULL,
  "person1" number NOT NULL,
  "person2" number,
  PRIMARY KEY ("id")
);
--
-- Table: tournament_round_group_team_membership
--;
CREATE SEQUENCE "sq_tournament_round_group_team";
CREATE TABLE "tournament_round_group_team_membership" (
  "id" number NOT NULL,
  "group" number NOT NULL,
  "team" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: tournament_round_groups
--;
CREATE SEQUENCE "sq_tournament_round_groups_id";
CREATE TABLE "tournament_round_groups" (
  "id" number NOT NULL,
  "tournament_round" number NOT NULL,
  "group_name" varchar2(150) NOT NULL,
  "group_order" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: tournament_round_phases
--;
CREATE SEQUENCE "sq_tournament_round_phases_id";
CREATE TABLE "tournament_round_phases" (
  "id" number NOT NULL,
  "tournament_round" number NOT NULL,
  "phase_number" number NOT NULL,
  "name" varchar2(150) NOT NULL,
  "date" date NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: tournament_rounds
--;
CREATE SEQUENCE "sq_tournament_rounds_id";
CREATE TABLE "tournament_rounds" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "tournament" number NOT NULL,
  "season" number NOT NULL,
  "round_number" number NOT NULL,
  "name" varchar2(150) NOT NULL,
  "round_type" char(1) NOT NULL,
  "team_match_template" number NOT NULL,
  "individual_match_template" number NOT NULL,
  "date" date,
  "venue" number,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_tournament_rounds_url_key_un" UNIQUE ("url_key", "tournament", "season")
);
--
-- Table: tournament_team_matches
--;
CREATE SEQUENCE "sq_tournament_team_matches_id";
CREATE TABLE "tournament_team_matches" (
  "id" number NOT NULL,
  "match_template" number NOT NULL,
  "home_team" number NOT NULL,
  "away_team" number NOT NULL,
  "tournament_round_phase" number NOT NULL,
  "venue" number NOT NULL,
  "scheduled_date" date NOT NULL,
  "played_date" date,
  "match_in_progress" number DEFAULT '0' NOT NULL,
  "home_team_score" number DEFAULT '0' NOT NULL,
  "away_team_score" number DEFAULT '0' NOT NULL,
  "complete" number DEFAULT '0' NOT NULL,
  "league_official_verified" number,
  "home_team_verified" number,
  "away_team_verified" number,
  PRIMARY KEY ("id")
);
--
-- Table: tournaments
--;
CREATE SEQUENCE "sq_tournaments_id";
CREATE TABLE "tournaments" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(100) NOT NULL,
  "event" number NOT NULL,
  "season" number NOT NULL,
  "entry_type" varchar2(20) NOT NULL,
  "allow_online_entries" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_tournaments_url_key" UNIQUE ("url_key")
);
--
-- Table: uploaded_files
--;
CREATE SEQUENCE "sq_uploaded_files_id";
CREATE TABLE "uploaded_files" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "filename" varchar2(255) NOT NULL,
  "description" varchar2(255),
  "mime_type" varchar2(150) NOT NULL,
  "uploaded" date NOT NULL,
  "downloaded_count" number DEFAULT '0' NOT NULL,
  "deleted" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_uploaded_files_url_key" UNIQUE ("url_key")
);
--
-- Table: uploaded_images
--;
CREATE SEQUENCE "sq_uploaded_images_id";
CREATE TABLE "uploaded_images" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "filename" varchar2(255) NOT NULL,
  "description" varchar2(255),
  "mime_type" varchar2(150) NOT NULL,
  "uploaded" date NOT NULL,
  "viewed_count" number DEFAULT '0' NOT NULL,
  "deleted" number DEFAULT '0' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_uploaded_images_url_key" UNIQUE ("url_key")
);
--
-- Table: user_agents
--;
CREATE SEQUENCE "sq_user_agents_id";
CREATE TABLE "user_agents" (
  "id" number NOT NULL,
  "string" clob NOT NULL,
  "sha256_hash" varchar2(64) NOT NULL,
  "first_seen" date NOT NULL,
  "last_seen" date NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: user_ip_addresses_browsers
--;
CREATE TABLE "user_ip_addresses_browsers" (
  "user_id" number NOT NULL,
  "ip_address" varchar2(40) NOT NULL,
  "user_agent" number NOT NULL,
  "first_seen" date NOT NULL,
  "last_seen" date NOT NULL,
  PRIMARY KEY ("user_id", "ip_address", "user_agent")
);
--
-- Table: user_roles
--;
CREATE TABLE "user_roles" (
  "user" number NOT NULL,
  "role" number NOT NULL,
  PRIMARY KEY ("user", "role")
);
--
-- Table: users
--;
CREATE SEQUENCE "sq_users_id";
CREATE TABLE "users" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "username" varchar2(45) NOT NULL,
  "email_address" varchar2(300) NOT NULL,
  "person" number,
  "password" clob NOT NULL,
  "change_password_next_login" number DEFAULT '0' NOT NULL,
  "html_emails" number DEFAULT '0' NOT NULL,
  "registered_date" date NOT NULL,
  "registered_ip" varchar2(45) NOT NULL,
  "last_visit_date" date NOT NULL,
  "last_visit_ip" varchar2(45),
  "last_active_date" date NOT NULL,
  "last_active_ip" varchar2(45),
  "locale" varchar2(6) NOT NULL,
  "timezone" varchar2(50),
  "avatar" varchar2(500),
  "posts" number DEFAULT '0' NOT NULL,
  "comments" number DEFAULT '0' NOT NULL,
  "signature" clob,
  "facebook" varchar2(255),
  "twitter" varchar2(255),
  "aim" varchar2(255),
  "jabber" varchar2(255),
  "website" varchar2(255),
  "interests" clob,
  "occupation" varchar2(150),
  "location" varchar2(150),
  "hide_online" number DEFAULT '0' NOT NULL,
  "activation_key" varchar2(64),
  "activated" number DEFAULT '0' NOT NULL,
  "activation_expires" date NOT NULL,
  "invalid_logins" number DEFAULT '0' NOT NULL,
  "password_reset_key" varchar2(64),
  "password_reset_expires" date NOT NULL,
  "last_invalid_login" date,
  PRIMARY KEY ("id"),
  CONSTRAINT "u_users_url_key" UNIQUE ("url_key"),
  CONSTRAINT "u_users_user_person_idx" UNIQUE ("person")
);
--
-- Table: venue_timetables
--;
CREATE TABLE "venue_timetables" (
  "id" number NOT NULL,
  "venue" number NOT NULL,
  "day" number NOT NULL,
  "number_of_tables" number,
  "start_time" date NOT NULL,
  "end_time" date NOT NULL,
  "price_information" varchar2(50),
  "description" clob NOT NULL,
  "matches" number NOT NULL,
  PRIMARY KEY ("id")
);
--
-- Table: venues
--;
CREATE SEQUENCE "sq_venues_id";
CREATE TABLE "venues" (
  "id" number NOT NULL,
  "url_key" varchar2(45) NOT NULL,
  "name" varchar2(300) NOT NULL,
  "address1" varchar2(100),
  "address2" varchar2(100),
  "address3" varchar2(100),
  "address4" varchar2(100),
  "address5" varchar2(100),
  "postcode" varchar2(10),
  "telephone" varchar2(20),
  "email_address" varchar2(240),
  "coordinates_latitude" float(10,8),
  "coordinates_longitude" float(11,8),
  PRIMARY KEY ("id"),
  CONSTRAINT "u_venues_url_key" UNIQUE ("url_key")
);
ALTER TABLE "average_filters" ADD CONSTRAINT "average_filters_user_fk" FOREIGN KEY ("user") REFERENCES "users" ("id");
ALTER TABLE "clubs" ADD CONSTRAINT "clubs_secretary_fk" FOREIGN KEY ("secretary") REFERENCES "people" ("id") ON DELETE SET NULL;
ALTER TABLE "clubs" ADD CONSTRAINT "clubs_venue_fk" FOREIGN KEY ("venue") REFERENCES "venues" ("id");
ALTER TABLE "contact_reason_recipients" ADD CONSTRAINT "contact_reason_recipients_cont" FOREIGN KEY ("contact_reason") REFERENCES "contact_reasons" ("id");
ALTER TABLE "contact_reason_recipients" ADD CONSTRAINT "contact_reason_recipients_pers" FOREIGN KEY ("person") REFERENCES "people" ("id");
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_division_fk" FOREIGN KEY ("division") REFERENCES "divisions" ("id");
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fixtures_grid" FOREIGN KEY ("fixtures_grid") REFERENCES "fixtures_grids" ("id");
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_league_match_" FOREIGN KEY ("league_match_template") REFERENCES "template_match_team" ("id");
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_league_table_" FOREIGN KEY ("league_table_ranking_template") REFERENCES "template_league_table_ranking" ("id");
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_person1_fk" FOREIGN KEY ("person1") REFERENCES "people" ("id") ON DELETE CASCADE;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_person2_fk" FOREIGN KEY ("person2") REFERENCES "people" ("id") ON DELETE CASCADE;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_team_fk" FOREIGN KEY ("team") REFERENCES "teams" ("id");
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_event_fk" FOREIGN KEY ("event") REFERENCES "events" ("id");
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_organiser_fk" FOREIGN KEY ("organiser") REFERENCES "people" ("id");
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_venue_fk" FOREIGN KEY ("venue") REFERENCES "venues" ("id");
ALTER TABLE "events" ADD CONSTRAINT "events_event_type_fk" FOREIGN KEY ("event_type") REFERENCES "lookup_event_types" ("id");
ALTER TABLE "fixtures_grid_matches" ADD CONSTRAINT "fixtures_grid_matches_grid_wee" FOREIGN KEY ("grid", "week") REFERENCES "fixtures_grid_weeks" ("grid", "week") ON DELETE CASCADE;
ALTER TABLE "fixtures_grid_weeks" ADD CONSTRAINT "fixtures_grid_weeks_grid_fk" FOREIGN KEY ("grid") REFERENCES "fixtures_grids" ("id") ON DELETE CASCADE;
ALTER TABLE "fixtures_season_weeks" ADD CONSTRAINT "fixtures_season_weeks_grid_gri" FOREIGN KEY ("grid", "grid_week") REFERENCES "fixtures_grid_weeks" ("grid", "week") ON DELETE CASCADE;
ALTER TABLE "fixtures_season_weeks" ADD CONSTRAINT "fixtures_season_weeks_fixtures" FOREIGN KEY ("fixtures_week") REFERENCES "fixtures_weeks" ("id") ON DELETE CASCADE;
ALTER TABLE "fixtures_weeks" ADD CONSTRAINT "fixtures_weeks_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_away_player" FOREIGN KEY ("away_player") REFERENCES "people" ("id");
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_home_player" FOREIGN KEY ("home_player") REFERENCES "people" ("id");
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_individual_" FOREIGN KEY ("individual_match_template") REFERENCES "people" ("id");
ALTER TABLE "meeting_attendees" ADD CONSTRAINT "meeting_attendees_meeting_fk" FOREIGN KEY ("meeting") REFERENCES "meetings" ("id");
ALTER TABLE "meeting_attendees" ADD CONSTRAINT "meeting_attendees_person_fk" FOREIGN KEY ("person") REFERENCES "people" ("id");
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_event_season_fk" FOREIGN KEY ("event", "season") REFERENCES "event_seasons" ("event", "season");
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_organiser_fk" FOREIGN KEY ("organiser") REFERENCES "people" ("id");
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_type_fk" FOREIGN KEY ("type") REFERENCES "meeting_types" ("id");
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_venue_fk" FOREIGN KEY ("venue") REFERENCES "venues" ("id");
ALTER TABLE "news_articles" ADD CONSTRAINT "news_articles_original_article" FOREIGN KEY ("original_article") REFERENCES "news_articles" ("id");
ALTER TABLE "news_articles" ADD CONSTRAINT "news_articles_updated_by_user_" FOREIGN KEY ("updated_by_user") REFERENCES "users" ("id");
ALTER TABLE "officials" ADD CONSTRAINT "officials_position_holder_fk" FOREIGN KEY ("position_holder") REFERENCES "people" ("id");
ALTER TABLE "officials" ADD CONSTRAINT "officials_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id") ON DELETE NO ACTION;
ALTER TABLE "people" ADD CONSTRAINT "people_gender_fk" FOREIGN KEY ("gender") REFERENCES "lookup_gender" ("id");
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_person_fk" FOREIGN KEY ("person") REFERENCES "people" ("id") ON DELETE CASCADE;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_team_fk" FOREIGN KEY ("team") REFERENCES "teams" ("id") ON DELETE CASCADE;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_team_membership" FOREIGN KEY ("team_membership_type") REFERENCES "lookup_team_membership_types" ("id");
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_person1_fk" FOREIGN KEY ("person1") REFERENCES "people" ("id");
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_person2_fk" FOREIGN KEY ("person2") REFERENCES "people" ("id");
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_team_fk" FOREIGN KEY ("team") REFERENCES "teams" ("id");
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_fk" FOREIGN KEY ("user") REFERENCES "users" ("id");
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_agent_fk" FOREIGN KEY ("user_agent") REFERENCES "user_agents" ("id");
ALTER TABLE "system_event_log" ADD CONSTRAINT "system_event_log_object_type_e" FOREIGN KEY ("object_type", "event_type") REFERENCES "system_event_log_types" ("object_type", "event_type");
ALTER TABLE "system_event_log" ADD CONSTRAINT "system_event_log_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "system_event_log_average_filters" ADD CONSTRAINT "system_event_log_average_filte" FOREIGN KEY ("object_id") REFERENCES "average_filters" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_average_filters" ADD CONSTRAINT "system_event_log_average_fil01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_club" ADD CONSTRAINT "system_event_log_club_object_i" FOREIGN KEY ("object_id") REFERENCES "clubs" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_club" ADD CONSTRAINT "system_event_log_club_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_contact_reason" ADD CONSTRAINT "system_event_log_contact_reaso" FOREIGN KEY ("object_id") REFERENCES "contact_reasons" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_contact_reason" ADD CONSTRAINT "system_event_log_contact_rea01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_division" ADD CONSTRAINT "system_event_log_division_obje" FOREIGN KEY ("object_id") REFERENCES "divisions" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_division" ADD CONSTRAINT "system_event_log_division_syst" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_event" ADD CONSTRAINT "system_event_log_event_object_" FOREIGN KEY ("object_id") REFERENCES "events" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_event" ADD CONSTRAINT "system_event_log_event_system_" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_file" ADD CONSTRAINT "system_event_log_file_object_i" FOREIGN KEY ("object_id") REFERENCES "uploaded_files" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_file" ADD CONSTRAINT "system_event_log_file_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_fixtures_grid" ADD CONSTRAINT "system_event_log_fixtures_grid" FOREIGN KEY ("object_id") REFERENCES "fixtures_grids" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_fixtures_grid" ADD CONSTRAINT "system_event_log_fixtures_gr01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_image" ADD CONSTRAINT "system_event_log_image_object_" FOREIGN KEY ("object_id") REFERENCES "uploaded_images" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_image" ADD CONSTRAINT "system_event_log_image_system_" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_meeting" ADD CONSTRAINT "system_event_log_meeting_objec" FOREIGN KEY ("object_id") REFERENCES "meetings" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_meeting" ADD CONSTRAINT "system_event_log_meeting_syste" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_meeting_type" ADD CONSTRAINT "system_event_log_meeting_type_" FOREIGN KEY ("object_id") REFERENCES "meeting_types" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_meeting_type" ADD CONSTRAINT "system_event_log_meeting_typ01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_news" ADD CONSTRAINT "system_event_log_news_object_i" FOREIGN KEY ("object_id") REFERENCES "news_articles" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_news" ADD CONSTRAINT "system_event_log_news_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_person" ADD CONSTRAINT "system_event_log_person_object" FOREIGN KEY ("object_id") REFERENCES "people" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_person" ADD CONSTRAINT "system_event_log_person_system" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_role" ADD CONSTRAINT "system_event_log_role_object_i" FOREIGN KEY ("object_id") REFERENCES "roles" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_role" ADD CONSTRAINT "system_event_log_role_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_season" ADD CONSTRAINT "system_event_log_season_object" FOREIGN KEY ("object_id") REFERENCES "seasons" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_season" ADD CONSTRAINT "system_event_log_season_system" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_team" ADD CONSTRAINT "system_event_log_team_object_i" FOREIGN KEY ("object_id") REFERENCES "teams" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_team" ADD CONSTRAINT "system_event_log_team_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_team_match" ADD CONSTRAINT "system_event_log_team_match_sy" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_team_match" ADD CONSTRAINT "system_event_log_team_match_ob" FOREIGN KEY ("object_home_team", "object_away_team", "object_scheduled_date") REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE SET NULL;
ALTER TABLE "system_event_log_template_league_table_ranking" ADD CONSTRAINT "system_event_log_template_leag" FOREIGN KEY ("object_id") REFERENCES "template_league_table_ranking" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_template_league_table_ranking" ADD CONSTRAINT "system_event_log_template_le01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_template_match_individual" ADD CONSTRAINT "system_event_log_template_matc" FOREIGN KEY ("object_id") REFERENCES "template_match_individual" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_template_match_individual" ADD CONSTRAINT "system_event_log_template_ma01" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_template_match_team" ADD CONSTRAINT "system_event_log_template_ma04" FOREIGN KEY ("object_id") REFERENCES "template_match_team" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_template_match_team" ADD CONSTRAINT "system_event_log_template_ma05" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_template_match_team_game" ADD CONSTRAINT "system_event_log_template_ma08" FOREIGN KEY ("object_id") REFERENCES "template_match_team" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_template_match_team_game" ADD CONSTRAINT "system_event_log_template_ma09" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_user" ADD CONSTRAINT "system_event_log_user_object_i" FOREIGN KEY ("object_id") REFERENCES "users" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_user" ADD CONSTRAINT "system_event_log_user_system_e" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "system_event_log_venue" ADD CONSTRAINT "system_event_log_venue_object_" FOREIGN KEY ("object_id") REFERENCES "venues" ("id") ON DELETE SET NULL;
ALTER TABLE "system_event_log_venue" ADD CONSTRAINT "system_event_log_venue_system_" FOREIGN KEY ("system_event_log_id") REFERENCES "system_event_log" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_away_doubles_" FOREIGN KEY ("away_doubles_pair") REFERENCES "doubles_pairs" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_away_player_f" FOREIGN KEY ("away_player") REFERENCES "people" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_home_doubles_" FOREIGN KEY ("home_doubles_pair") REFERENCES "doubles_pairs" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_home_player_f" FOREIGN KEY ("home_player") REFERENCES "people" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_individual_ma" FOREIGN KEY ("individual_match_template") REFERENCES "template_match_individual" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_home_team_awa" FOREIGN KEY ("home_team", "away_team", "scheduled_date") REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE CASCADE;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_umpire_fk" FOREIGN KEY ("umpire") REFERENCES "people" ("id");
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_winner_fk" FOREIGN KEY ("winner") REFERENCES "teams" ("id");
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_first_server_f" FOREIGN KEY ("first_server") REFERENCES "people" ("id");
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_next_point_ser" FOREIGN KEY ("next_point_server") REFERENCES "people" ("id");
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_home_team_away" FOREIGN KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number") REFERENCES "team_match_games" ("home_team", "away_team", "scheduled_date", "scheduled_game_number") ON DELETE CASCADE;
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_winner_fk" FOREIGN KEY ("winner") REFERENCES "teams" ("id");
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_loan_team_f" FOREIGN KEY ("loan_team") REFERENCES "teams" ("id");
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_location_fk" FOREIGN KEY ("location") REFERENCES "lookup_locations" ("id");
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_player_fk" FOREIGN KEY ("player") REFERENCES "people" ("id");
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_home_team_a" FOREIGN KEY ("home_team", "away_team", "scheduled_date") REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE CASCADE;
ALTER TABLE "team_match_reports" ADD CONSTRAINT "team_match_reports_author_fk" FOREIGN KEY ("author") REFERENCES "users" ("id");
ALTER TABLE "team_match_reports" ADD CONSTRAINT "team_match_reports_home_team_a" FOREIGN KEY ("home_team", "away_team", "scheduled_date") REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_away_team_fk" FOREIGN KEY ("away_team") REFERENCES "teams" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_away_team_verifie" FOREIGN KEY ("away_team_verified") REFERENCES "people" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_division_fk" FOREIGN KEY ("division") REFERENCES "divisions" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fixtures_grid_fk" FOREIGN KEY ("fixtures_grid") REFERENCES "fixtures_grids" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_home_team_fk" FOREIGN KEY ("home_team") REFERENCES "teams" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_home_team_verifie" FOREIGN KEY ("home_team_verified") REFERENCES "people" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_league_official_v" FOREIGN KEY ("league_official_verified") REFERENCES "people" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_played_week_fk" FOREIGN KEY ("played_week") REFERENCES "fixtures_weeks" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_player_of_the_mat" FOREIGN KEY ("player_of_the_match") REFERENCES "people" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_scheduled_week_fk" FOREIGN KEY ("scheduled_week") REFERENCES "fixtures_weeks" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_team_match_templa" FOREIGN KEY ("team_match_template") REFERENCES "template_match_team" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_tournament_round_" FOREIGN KEY ("tournament_round") REFERENCES "tournament_rounds" ("id");
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_venue_fk" FOREIGN KEY ("venue") REFERENCES "venues" ("id");
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_captain_fk" FOREIGN KEY ("captain") REFERENCES "people" ("id") ON DELETE SET NULL;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_club_fk" FOREIGN KEY ("club") REFERENCES "clubs" ("id");
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_division_fk" FOREIGN KEY ("division") REFERENCES "divisions" ("id");
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_home_night_fk" FOREIGN KEY ("home_night") REFERENCES "lookup_weekdays" ("weekday_number");
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_season_fk" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_team_fk" FOREIGN KEY ("team") REFERENCES "teams" ("id");
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_divisio" FOREIGN KEY ("division") REFERENCES "divisions" ("id");
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_season_" FOREIGN KEY ("season") REFERENCES "seasons" ("id");
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_team_fk" FOREIGN KEY ("team") REFERENCES "teams" ("id");
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_week_fk" FOREIGN KEY ("week") REFERENCES "fixtures_weeks" ("id");
ALTER TABLE "teams" ADD CONSTRAINT "teams_club_fk" FOREIGN KEY ("club") REFERENCES "clubs" ("id");
ALTER TABLE "template_match_individual" ADD CONSTRAINT "template_match_individual_game" FOREIGN KEY ("game_type") REFERENCES "lookup_game_types" ("id");
ALTER TABLE "template_match_individual" ADD CONSTRAINT "template_match_individual_serv" FOREIGN KEY ("serve_type") REFERENCES "lookup_serve_types" ("id");
ALTER TABLE "template_match_team" ADD CONSTRAINT "template_match_team_winner_typ" FOREIGN KEY ("winner_type") REFERENCES "lookup_winner_types" ("id");
ALTER TABLE "template_match_team_games" ADD CONSTRAINT "template_match_team_games_indi" FOREIGN KEY ("individual_match_template") REFERENCES "template_match_individual" ("id");
ALTER TABLE "template_match_team_games" ADD CONSTRAINT "template_match_team_games_team" FOREIGN KEY ("team_match_template") REFERENCES "template_match_team" ("id") ON DELETE CASCADE;
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_individ" FOREIGN KEY ("group") REFERENCES "tournament_round_groups" ("id");
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_indiv01" FOREIGN KEY ("person1") REFERENCES "people" ("id");
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_indiv02" FOREIGN KEY ("person2") REFERENCES "people" ("id");
ALTER TABLE "tournament_round_group_team_membership" ADD CONSTRAINT "tournament_round_group_team_me" FOREIGN KEY ("group") REFERENCES "tournament_round_groups" ("id");
ALTER TABLE "tournament_round_group_team_membership" ADD CONSTRAINT "tournament_round_group_team_01" FOREIGN KEY ("team") REFERENCES "teams" ("id");
ALTER TABLE "tournament_round_groups" ADD CONSTRAINT "tournament_round_groups_tourna" FOREIGN KEY ("tournament_round") REFERENCES "tournament_rounds" ("id");
ALTER TABLE "tournament_round_phases" ADD CONSTRAINT "tournament_round_phases_tourna" FOREIGN KEY ("tournament_round") REFERENCES "tournament_rounds" ("id");
ALTER TABLE "tournament_rounds" ADD CONSTRAINT "tournament_rounds_individual_m" FOREIGN KEY ("individual_match_template") REFERENCES "template_match_individual" ("id");
ALTER TABLE "tournament_rounds" ADD CONSTRAINT "tournament_rounds_team_match_t" FOREIGN KEY ("team_match_template") REFERENCES "template_match_team" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_away_t" FOREIGN KEY ("away_team") REFERENCES "teams" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_away01" FOREIGN KEY ("away_team_verified") REFERENCES "people" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_home_t" FOREIGN KEY ("home_team") REFERENCES "teams" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_home01" FOREIGN KEY ("home_team_verified") REFERENCES "people" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_league" FOREIGN KEY ("league_official_verified") REFERENCES "people" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_match_" FOREIGN KEY ("match_template") REFERENCES "template_match_team" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_tourna" FOREIGN KEY ("tournament_round_phase") REFERENCES "tournament_round_phases" ("id");
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_venue_" FOREIGN KEY ("venue") REFERENCES "venues" ("id");
ALTER TABLE "tournaments" ADD CONSTRAINT "tournaments_entry_type_fk" FOREIGN KEY ("entry_type") REFERENCES "lookup_tournament_types" ("id");
ALTER TABLE "tournaments" ADD CONSTRAINT "tournaments_event_season_fk" FOREIGN KEY ("event", "season") REFERENCES "event_seasons" ("event", "season");
ALTER TABLE "user_ip_addresses_browsers" ADD CONSTRAINT "user_ip_addresses_browsers_use" FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "user_ip_addresses_browsers" ADD CONSTRAINT "user_ip_addresses_browsers_u01" FOREIGN KEY ("user_agent") REFERENCES "user_agents" ("id");
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_fk" FOREIGN KEY ("role") REFERENCES "roles" ("id");
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_fk" FOREIGN KEY ("user") REFERENCES "users" ("id");
ALTER TABLE "users" ADD CONSTRAINT "users_person_fk" FOREIGN KEY ("person") REFERENCES "people" ("id") ON DELETE SET NULL;
ALTER TABLE "venue_timetables" ADD CONSTRAINT "venue_timetables_day_fk" FOREIGN KEY ("day") REFERENCES "lookup_weekdays" ("weekday_number");
ALTER TABLE "venue_timetables" ADD CONSTRAINT "venue_timetables_venue_fk" FOREIGN KEY ("venue") REFERENCES "venues" ("id") ON DELETE CASCADE;
CREATE OR REPLACE TRIGGER "ai_average_filters_id"
BEFORE INSERT ON "average_filters"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_average_filters_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_calendar_types_id"
BEFORE INSERT ON "calendar_types"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_calendar_types_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_clubs_id"
BEFORE INSERT ON "clubs"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_clubs_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_contact_reasons_id"
BEFORE INSERT ON "contact_reasons"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_contact_reasons_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_divisions_id"
BEFORE INSERT ON "divisions"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_divisions_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_doubles_pairs_id"
BEFORE INSERT ON "doubles_pairs"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_doubles_pairs_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_events_id"
BEFORE INSERT ON "events"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_events_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_fixtures_grids_id"
BEFORE INSERT ON "fixtures_grids"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_fixtures_grids_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_fixtures_weeks_id"
BEFORE INSERT ON "fixtures_weeks"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_fixtures_weeks_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_individual_matches_id"
BEFORE INSERT ON "individual_matches"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_individual_matches_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_meeting_types_id"
BEFORE INSERT ON "meeting_types"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_meeting_types_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_meetings_id"
BEFORE INSERT ON "meetings"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_meetings_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_news_articles_id"
BEFORE INSERT ON "news_articles"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_news_articles_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_officials_id"
BEFORE INSERT ON "officials"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_officials_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_people_id"
BEFORE INSERT ON "people"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_people_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_person_tournaments_id"
BEFORE INSERT ON "person_tournaments"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_person_tournaments_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_roles_id"
BEFORE INSERT ON "roles"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_roles_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_seasons_id"
BEFORE INSERT ON "seasons"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_seasons_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_id"
BEFORE INSERT ON "system_event_log"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_average_fi"
BEFORE INSERT ON "system_event_log_average_filters"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_average_fi".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_club_id"
BEFORE INSERT ON "system_event_log_club"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_club_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_contact_re"
BEFORE INSERT ON "system_event_log_contact_reason"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_contact_re".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_division_i"
BEFORE INSERT ON "system_event_log_division"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_division_i".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_event_id"
BEFORE INSERT ON "system_event_log_event"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_event_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_file_id"
BEFORE INSERT ON "system_event_log_file"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_file_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_fixtures_g"
BEFORE INSERT ON "system_event_log_fixtures_grid"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_fixtures_g".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_image_id"
BEFORE INSERT ON "system_event_log_image"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_image_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_meeting_id"
BEFORE INSERT ON "system_event_log_meeting"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_meeting_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_meeting_ty"
BEFORE INSERT ON "system_event_log_meeting_type"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_meeting_ty".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_news_id"
BEFORE INSERT ON "system_event_log_news"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_news_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_person_id"
BEFORE INSERT ON "system_event_log_person"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_person_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_role_id"
BEFORE INSERT ON "system_event_log_role"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_role_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_season_id"
BEFORE INSERT ON "system_event_log_season"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_season_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_team_id"
BEFORE INSERT ON "system_event_log_team"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_team_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_team_match"
BEFORE INSERT ON "system_event_log_team_match"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_team_match".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_template_l"
BEFORE INSERT ON "system_event_log_template_league_table_ranking"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_template_l".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_template_m"
BEFORE INSERT ON "system_event_log_template_match_individual"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_template_m".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_template01"
BEFORE INSERT ON "system_event_log_template_match_team"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_template01".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_template02"
BEFORE INSERT ON "system_event_log_template_match_team_game"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_template02".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_user_id"
BEFORE INSERT ON "system_event_log_user"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_user_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_system_event_log_venue_id"
BEFORE INSERT ON "system_event_log_venue"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_system_event_log_venue_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_team_match_reports_id"
BEFORE INSERT ON "team_match_reports"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_team_match_reports_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_teams_id"
BEFORE INSERT ON "teams"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_teams_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_template_league_table_ranki"
BEFORE INSERT ON "template_league_table_ranking"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_template_league_table_ranki".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_template_match_individual_i"
BEFORE INSERT ON "template_match_individual"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_template_match_individual_i".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_template_match_team_id"
BEFORE INSERT ON "template_match_team"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_template_match_team_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_template_match_team_games_i"
BEFORE INSERT ON "template_match_team_games"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_template_match_team_games_i".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_round_group_indi"
BEFORE INSERT ON "tournament_round_group_individual_membership"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_round_group_indi".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_round_group_team"
BEFORE INSERT ON "tournament_round_group_team_membership"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_round_group_team".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_round_groups_id"
BEFORE INSERT ON "tournament_round_groups"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_round_groups_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_round_phases_id"
BEFORE INSERT ON "tournament_round_phases"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_round_phases_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_rounds_id"
BEFORE INSERT ON "tournament_rounds"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_rounds_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournament_team_matches_id"
BEFORE INSERT ON "tournament_team_matches"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournament_team_matches_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_tournaments_id"
BEFORE INSERT ON "tournaments"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_tournaments_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_uploaded_files_id"
BEFORE INSERT ON "uploaded_files"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_uploaded_files_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_uploaded_images_id"
BEFORE INSERT ON "uploaded_images"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_uploaded_images_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_user_agents_id"
BEFORE INSERT ON "user_agents"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_user_agents_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_users_id"
BEFORE INSERT ON "users"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_users_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE OR REPLACE TRIGGER "ai_venues_id"
BEFORE INSERT ON "venues"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_venues_id".nextval
 INTO :new."id"
 FROM dual;
END;
;
CREATE INDEX "average_filters_idx_user" on "average_filters" ("user");
CREATE INDEX "clubs_idx_secretary" on "clubs" ("secretary");
CREATE INDEX "clubs_idx_venue" on "clubs" ("venue");
CREATE INDEX "contact_reason_recipients_idx_" on "contact_reason_recipients" ("contact_reason");
CREATE INDEX "contact_reason_recipients_id01" on "contact_reason_recipients" ("person");
CREATE INDEX "division_seasons_idx_division" on "division_seasons" ("division");
CREATE INDEX "division_seasons_idx_fixtures_" on "division_seasons" ("fixtures_grid");
CREATE INDEX "division_seasons_idx_league_ma" on "division_seasons" ("league_match_template");
CREATE INDEX "division_seasons_idx_league_ta" on "division_seasons" ("league_table_ranking_template");
CREATE INDEX "division_seasons_idx_season" on "division_seasons" ("season");
CREATE INDEX "doubles_pairs_idx_person1" on "doubles_pairs" ("person1");
CREATE INDEX "doubles_pairs_idx_person2" on "doubles_pairs" ("person2");
CREATE INDEX "doubles_pairs_idx_season" on "doubles_pairs" ("season");
CREATE INDEX "doubles_pairs_idx_team" on "doubles_pairs" ("team");
CREATE INDEX "event_seasons_idx_event" on "event_seasons" ("event");
CREATE INDEX "event_seasons_idx_organiser" on "event_seasons" ("organiser");
CREATE INDEX "event_seasons_idx_season" on "event_seasons" ("season");
CREATE INDEX "event_seasons_idx_venue" on "event_seasons" ("venue");
CREATE INDEX "events_idx_event_type" on "events" ("event_type");
CREATE INDEX "fixtures_grid_matches_idx_grid" on "fixtures_grid_matches" ("grid", "week");
CREATE INDEX "fixtures_grid_weeks_idx_grid" on "fixtures_grid_weeks" ("grid");
CREATE INDEX "fixtures_season_weeks_idx_grid" on "fixtures_season_weeks" ("grid", "grid_week");
CREATE INDEX "fixtures_season_weeks_idx_fixt" on "fixtures_season_weeks" ("fixtures_week");
CREATE INDEX "fixtures_weeks_idx_season" on "fixtures_weeks" ("season");
CREATE INDEX "individual_matches_idx_away_pl" on "individual_matches" ("away_player");
CREATE INDEX "individual_matches_idx_home_pl" on "individual_matches" ("home_player");
CREATE INDEX "individual_matches_idx_individ" on "individual_matches" ("individual_match_template");
CREATE INDEX "meeting_attendees_idx_meeting" on "meeting_attendees" ("meeting");
CREATE INDEX "meeting_attendees_idx_person" on "meeting_attendees" ("person");
CREATE INDEX "meetings_idx_event_season" on "meetings" ("event", "season");
CREATE INDEX "meetings_idx_organiser" on "meetings" ("organiser");
CREATE INDEX "meetings_idx_type" on "meetings" ("type");
CREATE INDEX "meetings_idx_venue" on "meetings" ("venue");
CREATE INDEX "news_articles_idx_original_art" on "news_articles" ("original_article");
CREATE INDEX "news_articles_idx_updated_by_u" on "news_articles" ("updated_by_user");
CREATE INDEX "officials_idx_position_holder" on "officials" ("position_holder");
CREATE INDEX "officials_idx_season" on "officials" ("season");
CREATE INDEX "people_idx_gender" on "people" ("gender");
CREATE INDEX "person_seasons_idx_person" on "person_seasons" ("person");
CREATE INDEX "person_seasons_idx_season" on "person_seasons" ("season");
CREATE INDEX "person_seasons_idx_team" on "person_seasons" ("team");
CREATE INDEX "person_seasons_idx_team_member" on "person_seasons" ("team_membership_type");
CREATE INDEX "person_tournaments_idx_person1" on "person_tournaments" ("person1");
CREATE INDEX "person_tournaments_idx_person2" on "person_tournaments" ("person2");
CREATE INDEX "person_tournaments_idx_team" on "person_tournaments" ("team");
CREATE INDEX "sessions_idx_user" on "sessions" ("user");
CREATE INDEX "sessions_idx_user_agent" on "sessions" ("user_agent");
CREATE INDEX "system_event_log_idx_object_ty" on "system_event_log" ("object_type", "event_type");
CREATE INDEX "system_event_log_idx_user_id" on "system_event_log" ("user_id");
CREATE INDEX "system_event_log_average_fil02" on "system_event_log_average_filters" ("object_id");
CREATE INDEX "system_event_log_average_fil03" on "system_event_log_average_filters" ("system_event_log_id");
CREATE INDEX "system_event_log_club_idx_obje" on "system_event_log_club" ("object_id");
CREATE INDEX "system_event_log_club_idx_syst" on "system_event_log_club" ("system_event_log_id");
CREATE INDEX "system_event_log_contact_rea02" on "system_event_log_contact_reason" ("object_id");
CREATE INDEX "system_event_log_contact_rea03" on "system_event_log_contact_reason" ("system_event_log_id");
CREATE INDEX "system_event_log_division_idx_" on "system_event_log_division" ("object_id");
CREATE INDEX "system_event_log_division_id01" on "system_event_log_division" ("system_event_log_id");
CREATE INDEX "system_event_log_event_idx_obj" on "system_event_log_event" ("object_id");
CREATE INDEX "system_event_log_event_idx_sys" on "system_event_log_event" ("system_event_log_id");
CREATE INDEX "system_event_log_file_idx_obje" on "system_event_log_file" ("object_id");
CREATE INDEX "system_event_log_file_idx_syst" on "system_event_log_file" ("system_event_log_id");
CREATE INDEX "system_event_log_fixtures_gr02" on "system_event_log_fixtures_grid" ("object_id");
CREATE INDEX "system_event_log_fixtures_gr03" on "system_event_log_fixtures_grid" ("system_event_log_id");
CREATE INDEX "system_event_log_image_idx_obj" on "system_event_log_image" ("object_id");
CREATE INDEX "system_event_log_image_idx_sys" on "system_event_log_image" ("system_event_log_id");
CREATE INDEX "system_event_log_meeting_idx_o" on "system_event_log_meeting" ("object_id");
CREATE INDEX "system_event_log_meeting_idx_s" on "system_event_log_meeting" ("system_event_log_id");
CREATE INDEX "system_event_log_meeting_typ02" on "system_event_log_meeting_type" ("object_id");
CREATE INDEX "system_event_log_meeting_typ03" on "system_event_log_meeting_type" ("system_event_log_id");
CREATE INDEX "system_event_log_news_idx_obje" on "system_event_log_news" ("object_id");
CREATE INDEX "system_event_log_news_idx_syst" on "system_event_log_news" ("system_event_log_id");
CREATE INDEX "system_event_log_person_idx_ob" on "system_event_log_person" ("object_id");
CREATE INDEX "system_event_log_person_idx_sy" on "system_event_log_person" ("system_event_log_id");
CREATE INDEX "system_event_log_role_idx_obje" on "system_event_log_role" ("object_id");
CREATE INDEX "system_event_log_role_idx_syst" on "system_event_log_role" ("system_event_log_id");
CREATE INDEX "system_event_log_season_idx_ob" on "system_event_log_season" ("object_id");
CREATE INDEX "system_event_log_season_idx_sy" on "system_event_log_season" ("system_event_log_id");
CREATE INDEX "system_event_log_team_idx_obje" on "system_event_log_team" ("object_id");
CREATE INDEX "system_event_log_team_idx_syst" on "system_event_log_team" ("system_event_log_id");
CREATE INDEX "system_event_log_team_match_id" on "system_event_log_team_match" ("system_event_log_id");
CREATE INDEX "system_event_log_team_match_01" on "system_event_log_team_match" ("object_home_team", "object_away_team", "object_scheduled_date");
CREATE INDEX "system_event_log_template_le02" on "system_event_log_template_league_table_ranking" ("object_id");
CREATE INDEX "system_event_log_template_le03" on "system_event_log_template_league_table_ranking" ("system_event_log_id");
CREATE INDEX "system_event_log_template_ma02" on "system_event_log_template_match_individual" ("object_id");
CREATE INDEX "system_event_log_template_ma03" on "system_event_log_template_match_individual" ("system_event_log_id");
CREATE INDEX "system_event_log_template_ma06" on "system_event_log_template_match_team" ("object_id");
CREATE INDEX "system_event_log_template_ma07" on "system_event_log_template_match_team" ("system_event_log_id");
CREATE INDEX "system_event_log_template_ma10" on "system_event_log_template_match_team_game" ("object_id");
CREATE INDEX "system_event_log_template_ma11" on "system_event_log_template_match_team_game" ("system_event_log_id");
CREATE INDEX "system_event_log_user_idx_obje" on "system_event_log_user" ("object_id");
CREATE INDEX "system_event_log_user_idx_syst" on "system_event_log_user" ("system_event_log_id");
CREATE INDEX "system_event_log_venue_idx_obj" on "system_event_log_venue" ("object_id");
CREATE INDEX "system_event_log_venue_idx_sys" on "system_event_log_venue" ("system_event_log_id");
CREATE INDEX "team_match_games_idx_away_doub" on "team_match_games" ("away_doubles_pair");
CREATE INDEX "team_match_games_idx_away_play" on "team_match_games" ("away_player");
CREATE INDEX "team_match_games_idx_home_doub" on "team_match_games" ("home_doubles_pair");
CREATE INDEX "team_match_games_idx_home_play" on "team_match_games" ("home_player");
CREATE INDEX "team_match_games_idx_individua" on "team_match_games" ("individual_match_template");
CREATE INDEX "team_match_games_idx_home_team" on "team_match_games" ("home_team", "away_team", "scheduled_date");
CREATE INDEX "team_match_games_idx_umpire" on "team_match_games" ("umpire");
CREATE INDEX "team_match_games_idx_winner" on "team_match_games" ("winner");
CREATE INDEX "team_match_legs_idx_first_serv" on "team_match_legs" ("first_server");
CREATE INDEX "team_match_legs_idx_next_point" on "team_match_legs" ("next_point_server");
CREATE INDEX "team_match_legs_idx_home_team_" on "team_match_legs" ("home_team", "away_team", "scheduled_date", "scheduled_game_number");
CREATE INDEX "team_match_legs_idx_winner" on "team_match_legs" ("winner");
CREATE INDEX "team_match_players_idx_loan_te" on "team_match_players" ("loan_team");
CREATE INDEX "team_match_players_idx_locatio" on "team_match_players" ("location");
CREATE INDEX "team_match_players_idx_player" on "team_match_players" ("player");
CREATE INDEX "team_match_players_idx_home_te" on "team_match_players" ("home_team", "away_team", "scheduled_date");
CREATE INDEX "team_match_reports_idx_author" on "team_match_reports" ("author");
CREATE INDEX "team_match_reports_idx_home_te" on "team_match_reports" ("home_team", "away_team", "scheduled_date");
CREATE INDEX "team_matches_idx_away_team" on "team_matches" ("away_team");
CREATE INDEX "team_matches_idx_away_team_ver" on "team_matches" ("away_team_verified");
CREATE INDEX "team_matches_idx_division" on "team_matches" ("division");
CREATE INDEX "team_matches_idx_fixtures_grid" on "team_matches" ("fixtures_grid");
CREATE INDEX "team_matches_idx_home_team" on "team_matches" ("home_team");
CREATE INDEX "team_matches_idx_home_team_ver" on "team_matches" ("home_team_verified");
CREATE INDEX "team_matches_idx_league_offici" on "team_matches" ("league_official_verified");
CREATE INDEX "team_matches_idx_played_week" on "team_matches" ("played_week");
CREATE INDEX "team_matches_idx_player_of_the" on "team_matches" ("player_of_the_match");
CREATE INDEX "team_matches_idx_scheduled_wee" on "team_matches" ("scheduled_week");
CREATE INDEX "team_matches_idx_season" on "team_matches" ("season");
CREATE INDEX "team_matches_idx_team_match_te" on "team_matches" ("team_match_template");
CREATE INDEX "team_matches_idx_tournament_ro" on "team_matches" ("tournament_round");
CREATE INDEX "team_matches_idx_venue" on "team_matches" ("venue");
CREATE INDEX "team_seasons_idx_captain" on "team_seasons" ("captain");
CREATE INDEX "team_seasons_idx_club" on "team_seasons" ("club");
CREATE INDEX "team_seasons_idx_division" on "team_seasons" ("division");
CREATE INDEX "team_seasons_idx_home_night" on "team_seasons" ("home_night");
CREATE INDEX "team_seasons_idx_season" on "team_seasons" ("season");
CREATE INDEX "team_seasons_idx_team" on "team_seasons" ("team");
CREATE INDEX "team_seasons_intervals_idx_div" on "team_seasons_intervals" ("division");
CREATE INDEX "team_seasons_intervals_idx_sea" on "team_seasons_intervals" ("season");
CREATE INDEX "team_seasons_intervals_idx_tea" on "team_seasons_intervals" ("team");
CREATE INDEX "team_seasons_intervals_idx_wee" on "team_seasons_intervals" ("week");
CREATE INDEX "teams_idx_club" on "teams" ("club");
CREATE INDEX "template_match_individual_idx_" on "template_match_individual" ("game_type");
CREATE INDEX "template_match_individual_id01" on "template_match_individual" ("serve_type");
CREATE INDEX "template_match_team_idx_winner" on "template_match_team" ("winner_type");
CREATE INDEX "template_match_team_games_idx_" on "template_match_team_games" ("individual_match_template");
CREATE INDEX "template_match_team_games_id01" on "template_match_team_games" ("team_match_template");
CREATE INDEX "tournament_round_group_indiv03" on "tournament_round_group_individual_membership" ("group");
CREATE INDEX "tournament_round_group_indiv04" on "tournament_round_group_individual_membership" ("person1");
CREATE INDEX "tournament_round_group_indiv05" on "tournament_round_group_individual_membership" ("person2");
CREATE INDEX "tournament_round_group_team_02" on "tournament_round_group_team_membership" ("group");
CREATE INDEX "tournament_round_group_team_03" on "tournament_round_group_team_membership" ("team");
CREATE INDEX "tournament_round_groups_idx_to" on "tournament_round_groups" ("tournament_round");
CREATE INDEX "tournament_round_phases_idx_to" on "tournament_round_phases" ("tournament_round");
CREATE INDEX "tournament_rounds_idx_individu" on "tournament_rounds" ("individual_match_template");
CREATE INDEX "tournament_rounds_idx_team_mat" on "tournament_rounds" ("team_match_template");
CREATE INDEX "tournament_team_matches_idx_aw" on "tournament_team_matches" ("away_team");
CREATE INDEX "tournament_team_matches_idx_01" on "tournament_team_matches" ("away_team_verified");
CREATE INDEX "tournament_team_matches_idx_ho" on "tournament_team_matches" ("home_team");
CREATE INDEX "tournament_team_matches_idx_01" on "tournament_team_matches" ("home_team_verified");
CREATE INDEX "tournament_team_matches_idx_le" on "tournament_team_matches" ("league_official_verified");
CREATE INDEX "tournament_team_matches_idx_ma" on "tournament_team_matches" ("match_template");
CREATE INDEX "tournament_team_matches_idx_to" on "tournament_team_matches" ("tournament_round_phase");
CREATE INDEX "tournament_team_matches_idx_ve" on "tournament_team_matches" ("venue");
CREATE INDEX "tournaments_idx_entry_type" on "tournaments" ("entry_type");
CREATE INDEX "tournaments_idx_event_season" on "tournaments" ("event", "season");
CREATE INDEX "user_ip_addresses_browsers_idx" on "user_ip_addresses_browsers" ("user_id");
CREATE INDEX "user_ip_addresses_browsers_i01" on "user_ip_addresses_browsers" ("user_agent");
CREATE INDEX "user_roles_idx_role" on "user_roles" ("role");
CREATE INDEX "user_roles_idx_user" on "user_roles" ("user");
CREATE INDEX "users_idx_person" on "users" ("person");
CREATE INDEX "venue_timetables_idx_day" on "venue_timetables" ("day");
CREATE INDEX "venue_timetables_idx_venue" on "venue_timetables" ("venue");
