-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Dec 23 13:25:24 2019
-- 
;
--
-- Table: average_filters
--
CREATE TABLE "average_filters" (
  "id" serial NOT NULL,
  "url_key" character varying(50) NOT NULL,
  "name" character varying(50) NOT NULL,
  "show_active" smallint DEFAULT 1,
  "show_loan" smallint DEFAULT 0,
  "show_inactive" smallint DEFAULT 0,
  "criteria_field" character varying(10),
  "operator" character varying(2),
  "criteria" smallint NOT NULL,
  "criteria_type" character varying(10),
  "user" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "name_user" UNIQUE ("name", "user"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "average_filters_idx_user" on "average_filters" ("user");

;
--
-- Table: calendar_types
--
CREATE TABLE "calendar_types" (
  "id" serial NOT NULL,
  "url_key" character varying(50) NOT NULL,
  "name" character varying(50) NOT NULL,
  "uri" character varying(500) NOT NULL,
  "calendar_scheme" character varying(10),
  "uri_escape_replacements" smallint DEFAULT 0 NOT NULL,
  "display_order" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "name" UNIQUE ("name")
);

;
--
-- Table: clubs
--
CREATE TABLE "clubs" (
  "id" serial NOT NULL,
  "url_key" character varying(45),
  "full_name" character varying(300) NOT NULL,
  "short_name" character varying(150) NOT NULL,
  "venue" integer NOT NULL,
  "secretary" integer,
  "email_address" character varying(200),
  "website" character varying(2083),
  "facebook" character varying(2083),
  "twitter" character varying(2083),
  "instagram" character varying(2083),
  "youtube" character varying(2083),
  "default_match_start" time,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "clubs_idx_secretary" on "clubs" ("secretary");
CREATE INDEX "clubs_idx_venue" on "clubs" ("venue");

;
--
-- Table: contact_reason_recipients
--
CREATE TABLE "contact_reason_recipients" (
  "contact_reason" integer NOT NULL,
  "person" integer NOT NULL,
  PRIMARY KEY ("contact_reason", "person")
);
CREATE INDEX "contact_reason_recipients_idx_contact_reason" on "contact_reason_recipients" ("contact_reason");
CREATE INDEX "contact_reason_recipients_idx_person" on "contact_reason_recipients" ("person");

;
--
-- Table: contact_reasons
--
CREATE TABLE "contact_reasons" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: division_seasons
--
CREATE TABLE "division_seasons" (
  "division" integer NOT NULL,
  "season" integer NOT NULL,
  "name" character varying(45) NOT NULL,
  "fixtures_grid" integer NOT NULL,
  "league_match_template" integer NOT NULL,
  "league_table_ranking_template" integer NOT NULL,
  "promotion_places" smallint DEFAULT 0,
  "relegation_places" smallint DEFAULT 0,
  PRIMARY KEY ("division", "season")
);
CREATE INDEX "division_seasons_idx_division" on "division_seasons" ("division");
CREATE INDEX "division_seasons_idx_fixtures_grid" on "division_seasons" ("fixtures_grid");
CREATE INDEX "division_seasons_idx_league_match_template" on "division_seasons" ("league_match_template");
CREATE INDEX "division_seasons_idx_league_table_ranking_template" on "division_seasons" ("league_table_ranking_template");
CREATE INDEX "division_seasons_idx_season" on "division_seasons" ("season");

;
--
-- Table: divisions
--
CREATE TABLE "divisions" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(45) NOT NULL,
  "rank" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: doubles_pairs
--
CREATE TABLE "doubles_pairs" (
  "id" serial NOT NULL,
  "person1" integer NOT NULL,
  "person2" integer NOT NULL,
  "season" integer NOT NULL,
  "team" integer NOT NULL,
  "person1_loan" smallint DEFAULT 0 NOT NULL,
  "person2_loan" smallint DEFAULT 0 NOT NULL,
  "games_played" smallint DEFAULT 0 NOT NULL,
  "games_won" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "games_lost" smallint DEFAULT 0 NOT NULL,
  "average_game_wins" float DEFAULT 0 NOT NULL,
  "legs_played" smallint DEFAULT 0 NOT NULL,
  "legs_won" smallint DEFAULT 0 NOT NULL,
  "legs_lost" smallint DEFAULT 0 NOT NULL,
  "average_leg_wins" float DEFAULT 0 NOT NULL,
  "points_played" integer DEFAULT 0 NOT NULL,
  "points_won" integer DEFAULT 0 NOT NULL,
  "points_lost" integer DEFAULT 0 NOT NULL,
  "average_point_wins" float DEFAULT 0 NOT NULL,
  "last_updated" timestamp NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "doubles_pairs_idx_person1" on "doubles_pairs" ("person1");
CREATE INDEX "doubles_pairs_idx_person2" on "doubles_pairs" ("person2");
CREATE INDEX "doubles_pairs_idx_season" on "doubles_pairs" ("season");
CREATE INDEX "doubles_pairs_idx_team" on "doubles_pairs" ("team");

;
--
-- Table: event_seasons
--
CREATE TABLE "event_seasons" (
  "event" integer NOT NULL,
  "season" integer NOT NULL,
  "name" character varying(300) NOT NULL,
  "date" date,
  "date_and_start_time" timestamp,
  "all_day" smallint,
  "finish_time" time,
  "organiser" integer,
  "venue" integer,
  "description" text,
  PRIMARY KEY ("event", "season")
);
CREATE INDEX "event_seasons_idx_event" on "event_seasons" ("event");
CREATE INDEX "event_seasons_idx_organiser" on "event_seasons" ("organiser");
CREATE INDEX "event_seasons_idx_season" on "event_seasons" ("season");
CREATE INDEX "event_seasons_idx_venue" on "event_seasons" ("venue");

;
--
-- Table: events
--
CREATE TABLE "events" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(300) NOT NULL,
  "event_type" character varying(20) NOT NULL,
  "description" text,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "events_idx_event_type" on "events" ("event_type");

;
--
-- Table: fixtures_grid_matches
--
CREATE TABLE "fixtures_grid_matches" (
  "grid" integer NOT NULL,
  "week" smallint NOT NULL,
  "match_number" smallint NOT NULL,
  "home_team" smallint,
  "away_team" smallint,
  PRIMARY KEY ("grid", "week", "match_number")
);
CREATE INDEX "fixtures_grid_matches_idx_grid_week" on "fixtures_grid_matches" ("grid", "week");

;
--
-- Table: fixtures_grid_weeks
--
CREATE TABLE "fixtures_grid_weeks" (
  "grid" integer NOT NULL,
  "week" smallint NOT NULL,
  PRIMARY KEY ("grid", "week")
);
CREATE INDEX "fixtures_grid_weeks_idx_grid" on "fixtures_grid_weeks" ("grid");

;
--
-- Table: fixtures_grids
--
CREATE TABLE "fixtures_grids" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(45) NOT NULL,
  "maximum_teams" smallint NOT NULL,
  "fixtures_repeated" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: fixtures_season_weeks
--
CREATE TABLE "fixtures_season_weeks" (
  "grid" integer NOT NULL,
  "grid_week" smallint NOT NULL,
  "fixtures_week" integer NOT NULL,
  PRIMARY KEY ("grid", "grid_week", "fixtures_week")
);
CREATE INDEX "fixtures_season_weeks_idx_grid_grid_week" on "fixtures_season_weeks" ("grid", "grid_week");
CREATE INDEX "fixtures_season_weeks_idx_fixtures_week" on "fixtures_season_weeks" ("fixtures_week");

;
--
-- Table: fixtures_weeks
--
CREATE TABLE "fixtures_weeks" (
  "id" serial NOT NULL,
  "season" integer NOT NULL,
  "week_beginning_date" date NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "fixtures_weeks_idx_season" on "fixtures_weeks" ("season");

;
--
-- Table: individual_matches
--
CREATE TABLE "individual_matches" (
  "id" serial NOT NULL,
  "home_player" integer,
  "away_player" integer,
  "individual_match_template" integer NOT NULL,
  "home_doubles_pair" integer,
  "away_doubles_pair" integer,
  "home_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "away_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "home_team_points_won" smallint DEFAULT 0 NOT NULL,
  "away_team_points_won" smallint DEFAULT 0 NOT NULL,
  "doubles_game" smallint DEFAULT 0 NOT NULL,
  "umpire" integer,
  "started" smallint DEFAULT 0,
  "complete" smallint DEFAULT 0,
  "awarded" smallint,
  "void" smallint,
  "winner" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "individual_matches_idx_away_player" on "individual_matches" ("away_player");
CREATE INDEX "individual_matches_idx_home_player" on "individual_matches" ("home_player");
CREATE INDEX "individual_matches_idx_individual_match_template" on "individual_matches" ("individual_match_template");

;
--
-- Table: invalid_logins
--
CREATE TABLE "invalid_logins" (
  "ip_address" character varying(40) NOT NULL,
  "invalid_logins" smallint NOT NULL,
  "last_invalid_login" timestamp NOT NULL,
  PRIMARY KEY ("ip_address")
);

;
--
-- Table: lookup_event_types
--
CREATE TABLE "lookup_event_types" (
  "id" character varying(20) NOT NULL,
  "display_order" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "display_order" UNIQUE ("display_order")
);

;
--
-- Table: lookup_game_types
--
CREATE TABLE "lookup_game_types" (
  "id" character varying(20) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: lookup_gender
--
CREATE TABLE "lookup_gender" (
  "id" character varying(20) DEFAULT '' NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: lookup_locations
--
CREATE TABLE "lookup_locations" (
  "id" character varying(10) NOT NULL,
  "location" character varying(20) DEFAULT '' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "location" UNIQUE ("location")
);

;
--
-- Table: lookup_serve_types
--
CREATE TABLE "lookup_serve_types" (
  "id" character varying(20) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: lookup_team_membership_types
--
CREATE TABLE "lookup_team_membership_types" (
  "id" character varying(20) NOT NULL,
  "display_order" smallint NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: lookup_tournament_types
--
CREATE TABLE "lookup_tournament_types" (
  "id" character varying(20) NOT NULL,
  "display_order" smallint NOT NULL,
  "allowed_in_single_tournament_events" smallint NOT NULL,
  "allowed_in_multi_tournament_events" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "display_order" UNIQUE ("display_order")
);

;
--
-- Table: lookup_weekdays
--
CREATE TABLE "lookup_weekdays" (
  "weekday_number" smallint DEFAULT 0 NOT NULL,
  "weekday_name" character varying(20),
  PRIMARY KEY ("weekday_number"),
  CONSTRAINT "weekday_name" UNIQUE ("weekday_name")
);

;
--
-- Table: lookup_winner_types
--
CREATE TABLE "lookup_winner_types" (
  "id" character varying(10) NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: meeting_attendees
--
CREATE TABLE "meeting_attendees" (
  "meeting" integer NOT NULL,
  "person" integer NOT NULL,
  "apologies" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("meeting", "person")
);
CREATE INDEX "meeting_attendees_idx_meeting" on "meeting_attendees" ("meeting");
CREATE INDEX "meeting_attendees_idx_person" on "meeting_attendees" ("person");

;
--
-- Table: meeting_types
--
CREATE TABLE "meeting_types" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(45) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: meetings
--
CREATE TABLE "meetings" (
  "id" serial NOT NULL,
  "event" integer,
  "season" integer,
  "type" integer,
  "organiser" integer,
  "venue" integer,
  "date_and_start_time" timestamp,
  "all_day" smallint,
  "finish_time" time,
  "agenda" text,
  "minutes" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "meetings_idx_event_season" on "meetings" ("event", "season");
CREATE INDEX "meetings_idx_organiser" on "meetings" ("organiser");
CREATE INDEX "meetings_idx_type" on "meetings" ("type");
CREATE INDEX "meetings_idx_venue" on "meetings" ("venue");

;
--
-- Table: news_articles
--
CREATE TABLE "news_articles" (
  "id" serial NOT NULL,
  "url_key" character varying(45),
  "published_year" date,
  "published_month" smallint,
  "updated_by_user" integer NOT NULL,
  "ip_address" character varying(45) NOT NULL,
  "date_updated" timestamp NOT NULL,
  "headline" character varying(500) NOT NULL,
  "article_content" text NOT NULL,
  "original_article" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key", "published_year", "published_month")
);
CREATE INDEX "news_articles_idx_original_article" on "news_articles" ("original_article");
CREATE INDEX "news_articles_idx_updated_by_user" on "news_articles" ("updated_by_user");

;
--
-- Table: officials
--
CREATE TABLE "officials" (
  "id" serial NOT NULL,
  "position" character varying(150) NOT NULL,
  "position_order" smallint NOT NULL,
  "position_holder" integer NOT NULL,
  "season" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "officials_idx_position_holder" on "officials" ("position_holder");
CREATE INDEX "officials_idx_season" on "officials" ("season");

;
--
-- Table: page_text
--
CREATE TABLE "page_text" (
  "page_key" character varying(50) NOT NULL,
  "page_text" text NOT NULL,
  "last_updated" timestamp NOT NULL,
  PRIMARY KEY ("page_key")
);

;
--
-- Table: people
--
CREATE TABLE "people" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "first_name" character varying(150) NOT NULL,
  "surname" character varying(150) NOT NULL,
  "display_name" character varying(301) NOT NULL,
  "date_of_birth" date,
  "gender" character varying(20),
  "address1" character varying(150),
  "address2" character varying(150),
  "address3" character varying(150),
  "address4" character varying(150),
  "address5" character varying(150),
  "postcode" character varying(8),
  "home_telephone" character varying(25),
  "work_telephone" character varying(25),
  "mobile_telephone" character varying(25),
  "email_address" character varying(254),
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "people_idx_gender" on "people" ("gender");

;
--
-- Table: person_seasons
--
CREATE TABLE "person_seasons" (
  "person" integer NOT NULL,
  "season" integer NOT NULL,
  "team" integer NOT NULL,
  "first_name" character varying(150) NOT NULL,
  "surname" character varying(150) NOT NULL,
  "display_name" character varying(301) NOT NULL,
  "registration_date" date,
  "fees_paid" smallint DEFAULT 0 NOT NULL,
  "matches_played" smallint DEFAULT 0 NOT NULL,
  "matches_won" smallint DEFAULT 0 NOT NULL,
  "matches_drawn" smallint DEFAULT 0 NOT NULL,
  "matches_lost" smallint DEFAULT 0 NOT NULL,
  "games_played" smallint DEFAULT 0 NOT NULL,
  "games_won" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "games_lost" smallint DEFAULT 0 NOT NULL,
  "average_game_wins" float DEFAULT 0 NOT NULL,
  "legs_played" smallint DEFAULT 0 NOT NULL,
  "legs_won" smallint DEFAULT 0 NOT NULL,
  "legs_lost" smallint DEFAULT 0 NOT NULL,
  "average_leg_wins" float DEFAULT 0 NOT NULL,
  "points_played" integer DEFAULT 0 NOT NULL,
  "points_won" integer DEFAULT 0 NOT NULL,
  "points_lost" integer DEFAULT 0 NOT NULL,
  "average_point_wins" float DEFAULT 0 NOT NULL,
  "doubles_games_played" smallint DEFAULT 0 NOT NULL,
  "doubles_games_won" smallint DEFAULT 0 NOT NULL,
  "doubles_games_drawn" smallint DEFAULT 0 NOT NULL,
  "doubles_games_lost" smallint DEFAULT 0 NOT NULL,
  "doubles_average_game_wins" float DEFAULT 0 NOT NULL,
  "doubles_legs_played" smallint DEFAULT 0 NOT NULL,
  "doubles_legs_won" smallint DEFAULT 0 NOT NULL,
  "doubles_legs_lost" smallint DEFAULT 0 NOT NULL,
  "doubles_average_leg_wins" float DEFAULT 0 NOT NULL,
  "doubles_points_played" integer DEFAULT 0 NOT NULL,
  "doubles_points_won" integer DEFAULT 0 NOT NULL,
  "doubles_points_lost" integer DEFAULT 0 NOT NULL,
  "doubles_average_point_wins" float DEFAULT 0 NOT NULL,
  "team_membership_type" character varying(20) DEFAULT 'active' NOT NULL,
  "last_updated" timestamp NOT NULL,
  PRIMARY KEY ("person", "season", "team")
);
CREATE INDEX "person_seasons_idx_person" on "person_seasons" ("person");
CREATE INDEX "person_seasons_idx_season" on "person_seasons" ("season");
CREATE INDEX "person_seasons_idx_team" on "person_seasons" ("team");
CREATE INDEX "person_seasons_idx_team_membership_type" on "person_seasons" ("team_membership_type");

;
--
-- Table: person_tournaments
--
CREATE TABLE "person_tournaments" (
  "id" serial NOT NULL,
  "tournament" integer NOT NULL,
  "season" integer NOT NULL,
  "person1" integer NOT NULL,
  "person2" integer NOT NULL,
  "team" integer,
  "first_name" character varying(150) NOT NULL,
  "surname" character varying(150) NOT NULL,
  "display_name" character varying(301) NOT NULL,
  "registration_date" date,
  "fees_paid" smallint DEFAULT 0 NOT NULL,
  "matches_played" smallint DEFAULT 0 NOT NULL,
  "matches_won" smallint DEFAULT 0 NOT NULL,
  "matches_drawn" smallint DEFAULT 0 NOT NULL,
  "matches_lost" smallint DEFAULT 0 NOT NULL,
  "games_played" smallint DEFAULT 0 NOT NULL,
  "games_won" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "games_lost" smallint DEFAULT 0 NOT NULL,
  "average_game_wins" float DEFAULT 0 NOT NULL,
  "legs_played" smallint DEFAULT 0 NOT NULL,
  "legs_won" smallint DEFAULT 0 NOT NULL,
  "legs_lost" smallint DEFAULT 0 NOT NULL,
  "average_leg_wins" float DEFAULT 0 NOT NULL,
  "points_played" integer DEFAULT 0 NOT NULL,
  "points_won" integer DEFAULT 0 NOT NULL,
  "points_lost" integer DEFAULT 0 NOT NULL,
  "average_point_wins" float DEFAULT 0 NOT NULL,
  "team_membership_type" character varying(20) DEFAULT 'active' NOT NULL,
  "last_updated" timestamp NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "person_tournaments_idx_person1" on "person_tournaments" ("person1");
CREATE INDEX "person_tournaments_idx_person2" on "person_tournaments" ("person2");
CREATE INDEX "person_tournaments_idx_team" on "person_tournaments" ("team");

;
--
-- Table: roles
--
CREATE TABLE "roles" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(100) NOT NULL,
  "system" smallint DEFAULT 0 NOT NULL,
  "sysadmin" smallint DEFAULT 0 NOT NULL,
  "anonymous" smallint DEFAULT 0 NOT NULL,
  "apply_on_registration" smallint DEFAULT 0 NOT NULL,
  "average_filter_create_public" smallint DEFAULT 0 NOT NULL,
  "average_filter_edit_public" smallint DEFAULT 0 NOT NULL,
  "average_filter_delete_public" smallint DEFAULT 0 NOT NULL,
  "average_filter_view_all" smallint DEFAULT 0 NOT NULL,
  "average_filter_edit_all" smallint DEFAULT 0 NOT NULL,
  "average_filter_delete_all" smallint DEFAULT 0 NOT NULL,
  "club_view" smallint DEFAULT 0 NOT NULL,
  "club_create" smallint DEFAULT 0 NOT NULL,
  "club_edit" smallint DEFAULT 0 NOT NULL,
  "club_delete" smallint DEFAULT 0 NOT NULL,
  "committee_view" smallint DEFAULT 0 NOT NULL,
  "committee_create" smallint DEFAULT 0 NOT NULL,
  "committee_edit" smallint DEFAULT 0 NOT NULL,
  "committee_delete" smallint DEFAULT 0 NOT NULL,
  "contact_reason_view" smallint DEFAULT 0 NOT NULL,
  "contact_reason_create" smallint DEFAULT 0 NOT NULL,
  "contact_reason_edit" smallint DEFAULT 0 NOT NULL,
  "contact_reason_delete" smallint DEFAULT 0 NOT NULL,
  "event_view" smallint DEFAULT 0 NOT NULL,
  "event_create" smallint DEFAULT 0 NOT NULL,
  "event_edit" smallint DEFAULT 0 NOT NULL,
  "event_delete" smallint DEFAULT 0 NOT NULL,
  "file_upload" smallint DEFAULT 0 NOT NULL,
  "fixtures_view" smallint DEFAULT 0 NOT NULL,
  "fixtures_create" smallint DEFAULT 0 NOT NULL,
  "fixtures_edit" smallint DEFAULT 0 NOT NULL,
  "fixtures_delete" smallint DEFAULT 0 NOT NULL,
  "image_upload" smallint DEFAULT 0 NOT NULL,
  "match_view" smallint DEFAULT 0 NOT NULL,
  "match_update" smallint DEFAULT 0 NOT NULL,
  "match_cancel" smallint DEFAULT 0 NOT NULL,
  "match_report_create" smallint DEFAULT 0 NOT NULL,
  "match_report_create_associated" smallint DEFAULT 0 NOT NULL,
  "match_report_edit_own" smallint DEFAULT 0 NOT NULL,
  "match_report_edit_all" smallint DEFAULT 0 NOT NULL,
  "match_report_delete_own" smallint DEFAULT 0 NOT NULL,
  "match_report_delete_all" smallint DEFAULT 0 NOT NULL,
  "meeting_view" smallint DEFAULT 0 NOT NULL,
  "meeting_create" smallint DEFAULT 0 NOT NULL,
  "meeting_edit" smallint DEFAULT 0 NOT NULL,
  "meeting_delete" smallint DEFAULT 0 NOT NULL,
  "meeting_type_view" smallint DEFAULT 0 NOT NULL,
  "meeting_type_create" smallint DEFAULT 0 NOT NULL,
  "meeting_type_edit" smallint DEFAULT 0 NOT NULL,
  "meeting_type_delete" smallint DEFAULT 0 NOT NULL,
  "news_article_view" smallint DEFAULT 0 NOT NULL,
  "news_article_create" smallint DEFAULT 0 NOT NULL,
  "news_article_edit_own" smallint DEFAULT 0 NOT NULL,
  "news_article_edit_all" smallint DEFAULT 0 NOT NULL,
  "news_article_delete_own" smallint DEFAULT 0 NOT NULL,
  "news_article_delete_all" smallint DEFAULT 0 NOT NULL,
  "online_users_view" smallint DEFAULT 0 NOT NULL,
  "anonymous_online_users_view" smallint DEFAULT 0 NOT NULL,
  "view_users_ip" smallint DEFAULT 0 NOT NULL,
  "view_users_user_agent" smallint DEFAULT 0 NOT NULL,
  "person_view" smallint DEFAULT 0 NOT NULL,
  "person_create" smallint DEFAULT 0 NOT NULL,
  "person_contact_view" smallint DEFAULT 0 NOT NULL,
  "person_edit" smallint DEFAULT 0 NOT NULL,
  "person_delete" smallint DEFAULT 0 NOT NULL,
  "privacy_view" smallint DEFAULT 0 NOT NULL,
  "privacy_edit" smallint DEFAULT 0 NOT NULL,
  "role_view" smallint DEFAULT 0 NOT NULL,
  "role_create" smallint DEFAULT 0 NOT NULL,
  "role_edit" smallint DEFAULT 0 NOT NULL,
  "role_delete" smallint DEFAULT 0 NOT NULL,
  "season_view" smallint DEFAULT 0 NOT NULL,
  "season_create" smallint DEFAULT 0 NOT NULL,
  "season_edit" smallint DEFAULT 0 NOT NULL,
  "season_delete" smallint DEFAULT 0 NOT NULL,
  "season_archive" smallint DEFAULT 0 NOT NULL,
  "session_delete" smallint DEFAULT 0 NOT NULL,
  "system_event_log_view_all" smallint DEFAULT 0 NOT NULL,
  "team_view" smallint DEFAULT 0 NOT NULL,
  "team_create" smallint DEFAULT 0 NOT NULL,
  "team_edit" smallint DEFAULT 0 NOT NULL,
  "team_delete" smallint DEFAULT 0 NOT NULL,
  "template_view" smallint DEFAULT 0 NOT NULL,
  "template_create" smallint DEFAULT 0 NOT NULL,
  "template_edit" smallint DEFAULT 0 NOT NULL,
  "template_delete" smallint DEFAULT 0 NOT NULL,
  "tournament_view" smallint DEFAULT 0 NOT NULL,
  "tournament_create" smallint DEFAULT 0 NOT NULL,
  "tournament_edit" smallint DEFAULT 0 NOT NULL,
  "tournament_delete" smallint DEFAULT 0 NOT NULL,
  "user_view" smallint DEFAULT 0 NOT NULL,
  "user_edit_all" smallint DEFAULT 0 NOT NULL,
  "user_edit_own" smallint DEFAULT 0 NOT NULL,
  "user_delete_all" smallint DEFAULT 0 NOT NULL,
  "user_delete_own" smallint DEFAULT 0 NOT NULL,
  "venue_view" smallint DEFAULT 0 NOT NULL,
  "venue_create" smallint DEFAULT 0 NOT NULL,
  "venue_edit" smallint DEFAULT 0 NOT NULL,
  "venue_delete" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: seasons
--
CREATE TABLE "seasons" (
  "id" serial NOT NULL,
  "url_key" character varying(30) NOT NULL,
  "name" character varying(150) NOT NULL,
  "default_match_start" time NOT NULL,
  "timezone" character varying(50) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "complete" smallint DEFAULT 0 NOT NULL,
  "allow_loan_players_below" smallint DEFAULT 0 NOT NULL,
  "allow_loan_players_above" smallint DEFAULT 0 NOT NULL,
  "allow_loan_players_across" smallint DEFAULT 0 NOT NULL,
  "allow_loan_players_multiple_teams_per_division" smallint DEFAULT 0 NOT NULL,
  "allow_loan_players_same_club_only" smallint DEFAULT 0 NOT NULL,
  "loan_players_limit_per_player" smallint DEFAULT 0 NOT NULL,
  "loan_players_limit_per_player_per_team" smallint DEFAULT 0 NOT NULL,
  "loan_players_limit_per_team" smallint DEFAULT 0 NOT NULL,
  "rules" text,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: sessions
--
CREATE TABLE "sessions" (
  "id" character(72) NOT NULL,
  "data" text,
  "expires" integer,
  "user" integer,
  "ip_address" character varying(40),
  "client_hostname" text,
  "user_agent" integer,
  "secure" smallint,
  "locale" character varying(6),
  "path" character varying(255),
  "query_string" text,
  "referrer" text,
  "view_online_display" character varying(300),
  "view_online_link" smallint,
  "hide_online" smallint,
  "last_active" timestamp NOT NULL,
  "invalid_logins" smallint DEFAULT 0 NOT NULL,
  "last_invalid_login" timestamp,
  PRIMARY KEY ("id")
);
CREATE INDEX "sessions_idx_user" on "sessions" ("user");
CREATE INDEX "sessions_idx_user_agent" on "sessions" ("user_agent");

;
--
-- Table: system_event_log
--
CREATE TABLE "system_event_log" (
  "id" serial NOT NULL,
  "object_type" character varying(40) NOT NULL,
  "event_type" character varying(20) NOT NULL,
  "user_id" integer,
  "ip_address" character varying(40) NOT NULL,
  "log_created" timestamp NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_idx_object_type_event_type" on "system_event_log" ("object_type", "event_type");
CREATE INDEX "system_event_log_idx_user_id" on "system_event_log" ("user_id");

;
--
-- Table: system_event_log_average_filters
--
CREATE TABLE "system_event_log_average_filters" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_average_filters_idx_object_id" on "system_event_log_average_filters" ("object_id");
CREATE INDEX "system_event_log_average_filters_idx_system_event_log_id" on "system_event_log_average_filters" ("system_event_log_id");

;
--
-- Table: system_event_log_club
--
CREATE TABLE "system_event_log_club" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_club_idx_object_id" on "system_event_log_club" ("object_id");
CREATE INDEX "system_event_log_club_idx_system_event_log_id" on "system_event_log_club" ("system_event_log_id");

;
--
-- Table: system_event_log_contact_reason
--
CREATE TABLE "system_event_log_contact_reason" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_contact_reason_idx_object_id" on "system_event_log_contact_reason" ("object_id");
CREATE INDEX "system_event_log_contact_reason_idx_system_event_log_id" on "system_event_log_contact_reason" ("system_event_log_id");

;
--
-- Table: system_event_log_division
--
CREATE TABLE "system_event_log_division" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_division_idx_object_id" on "system_event_log_division" ("object_id");
CREATE INDEX "system_event_log_division_idx_system_event_log_id" on "system_event_log_division" ("system_event_log_id");

;
--
-- Table: system_event_log_event
--
CREATE TABLE "system_event_log_event" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_event_idx_object_id" on "system_event_log_event" ("object_id");
CREATE INDEX "system_event_log_event_idx_system_event_log_id" on "system_event_log_event" ("system_event_log_id");

;
--
-- Table: system_event_log_file
--
CREATE TABLE "system_event_log_file" (
  "id" serial NOT NULL,
  "system_event_log_id" integer DEFAULT 0 NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_file_idx_object_id" on "system_event_log_file" ("object_id");
CREATE INDEX "system_event_log_file_idx_system_event_log_id" on "system_event_log_file" ("system_event_log_id");

;
--
-- Table: system_event_log_fixtures_grid
--
CREATE TABLE "system_event_log_fixtures_grid" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_fixtures_grid_idx_object_id" on "system_event_log_fixtures_grid" ("object_id");
CREATE INDEX "system_event_log_fixtures_grid_idx_system_event_log_id" on "system_event_log_fixtures_grid" ("system_event_log_id");

;
--
-- Table: system_event_log_image
--
CREATE TABLE "system_event_log_image" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_image_idx_object_id" on "system_event_log_image" ("object_id");
CREATE INDEX "system_event_log_image_idx_system_event_log_id" on "system_event_log_image" ("system_event_log_id");

;
--
-- Table: system_event_log_meeting
--
CREATE TABLE "system_event_log_meeting" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_meeting_idx_object_id" on "system_event_log_meeting" ("object_id");
CREATE INDEX "system_event_log_meeting_idx_system_event_log_id" on "system_event_log_meeting" ("system_event_log_id");

;
--
-- Table: system_event_log_meeting_type
--
CREATE TABLE "system_event_log_meeting_type" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_meeting_type_idx_object_id" on "system_event_log_meeting_type" ("object_id");
CREATE INDEX "system_event_log_meeting_type_idx_system_event_log_id" on "system_event_log_meeting_type" ("system_event_log_id");

;
--
-- Table: system_event_log_news
--
CREATE TABLE "system_event_log_news" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_news_idx_object_id" on "system_event_log_news" ("object_id");
CREATE INDEX "system_event_log_news_idx_system_event_log_id" on "system_event_log_news" ("system_event_log_id");

;
--
-- Table: system_event_log_person
--
CREATE TABLE "system_event_log_person" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_person_idx_object_id" on "system_event_log_person" ("object_id");
CREATE INDEX "system_event_log_person_idx_system_event_log_id" on "system_event_log_person" ("system_event_log_id");

;
--
-- Table: system_event_log_role
--
CREATE TABLE "system_event_log_role" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_role_idx_object_id" on "system_event_log_role" ("object_id");
CREATE INDEX "system_event_log_role_idx_system_event_log_id" on "system_event_log_role" ("system_event_log_id");

;
--
-- Table: system_event_log_season
--
CREATE TABLE "system_event_log_season" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_season_idx_object_id" on "system_event_log_season" ("object_id");
CREATE INDEX "system_event_log_season_idx_system_event_log_id" on "system_event_log_season" ("system_event_log_id");

;
--
-- Table: system_event_log_team
--
CREATE TABLE "system_event_log_team" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_team_idx_object_id" on "system_event_log_team" ("object_id");
CREATE INDEX "system_event_log_team_idx_system_event_log_id" on "system_event_log_team" ("system_event_log_id");

;
--
-- Table: system_event_log_team_match
--
CREATE TABLE "system_event_log_team_match" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_home_team" integer,
  "object_away_team" integer,
  "object_scheduled_date" date,
  "name" character varying(620) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_team_match_idx_system_event_log_id" on "system_event_log_team_match" ("system_event_log_id");
CREATE INDEX "system_event_log_team_match_idx_object_home_team_object_away_team_object_scheduled_date" on "system_event_log_team_match" ("object_home_team", "object_away_team", "object_scheduled_date");

;
--
-- Table: system_event_log_template_league_table_ranking
--
CREATE TABLE "system_event_log_template_league_table_ranking" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_template_league_table_ranking_idx_object_id" on "system_event_log_template_league_table_ranking" ("object_id");
CREATE INDEX "system_event_log_template_league_table_ranking_idx_system_event_log_id" on "system_event_log_template_league_table_ranking" ("system_event_log_id");

;
--
-- Table: system_event_log_template_match_individual
--
CREATE TABLE "system_event_log_template_match_individual" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_template_match_individual_idx_object_id" on "system_event_log_template_match_individual" ("object_id");
CREATE INDEX "system_event_log_template_match_individual_idx_system_event_log_id" on "system_event_log_template_match_individual" ("system_event_log_id");

;
--
-- Table: system_event_log_template_match_team
--
CREATE TABLE "system_event_log_template_match_team" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_template_match_team_idx_object_id" on "system_event_log_template_match_team" ("object_id");
CREATE INDEX "system_event_log_template_match_team_idx_system_event_log_id" on "system_event_log_template_match_team" ("system_event_log_id");

;
--
-- Table: system_event_log_template_match_team_game
--
CREATE TABLE "system_event_log_template_match_team_game" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_template_match_team_game_idx_object_id" on "system_event_log_template_match_team_game" ("object_id");
CREATE INDEX "system_event_log_template_match_team_game_idx_system_event_log_id" on "system_event_log_template_match_team_game" ("system_event_log_id");

;
--
-- Table: system_event_log_types
--
CREATE TABLE "system_event_log_types" (
  "object_type" character varying(40) NOT NULL,
  "event_type" character varying(40) NOT NULL,
  "object_description" character varying(40) NOT NULL,
  "description" character varying(500) NOT NULL,
  "view_action_for_uri" character varying(500),
  "plural_objects" character varying(50) NOT NULL,
  "public_event" smallint NOT NULL,
  PRIMARY KEY ("object_type", "event_type")
);

;
--
-- Table: system_event_log_user
--
CREATE TABLE "system_event_log_user" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_user_idx_object_id" on "system_event_log_user" ("object_id");
CREATE INDEX "system_event_log_user_idx_system_event_log_id" on "system_event_log_user" ("system_event_log_id");

;
--
-- Table: system_event_log_venue
--
CREATE TABLE "system_event_log_venue" (
  "id" serial NOT NULL,
  "system_event_log_id" integer NOT NULL,
  "object_id" integer,
  "name" character varying(300) NOT NULL,
  "log_updated" timestamp NOT NULL,
  "number_of_edits" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_event_log_venue_idx_object_id" on "system_event_log_venue" ("object_id");
CREATE INDEX "system_event_log_venue_idx_system_event_log_id" on "system_event_log_venue" ("system_event_log_id");

;
--
-- Table: team_match_games
--
CREATE TABLE "team_match_games" (
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_game_number" smallint NOT NULL,
  "individual_match_template" integer NOT NULL,
  "actual_game_number" smallint NOT NULL,
  "home_player" integer,
  "home_player_number" smallint,
  "away_player" integer,
  "away_player_number" smallint,
  "home_doubles_pair" integer,
  "away_doubles_pair" integer,
  "home_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "away_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "home_team_points_won" smallint DEFAULT 0 NOT NULL,
  "away_team_points_won" smallint DEFAULT 0 NOT NULL,
  "home_team_match_score" smallint DEFAULT 0 NOT NULL,
  "away_team_match_score" smallint DEFAULT 0 NOT NULL,
  "doubles_game" smallint DEFAULT 0 NOT NULL,
  "game_in_progress" smallint DEFAULT 0 NOT NULL,
  "umpire" integer,
  "started" smallint DEFAULT 0,
  "complete" smallint DEFAULT 0,
  "awarded" smallint,
  "void" smallint,
  "winner" integer,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number")
);
CREATE INDEX "team_match_games_idx_away_doubles_pair" on "team_match_games" ("away_doubles_pair");
CREATE INDEX "team_match_games_idx_away_player" on "team_match_games" ("away_player");
CREATE INDEX "team_match_games_idx_home_doubles_pair" on "team_match_games" ("home_doubles_pair");
CREATE INDEX "team_match_games_idx_home_player" on "team_match_games" ("home_player");
CREATE INDEX "team_match_games_idx_individual_match_template" on "team_match_games" ("individual_match_template");
CREATE INDEX "team_match_games_idx_home_team_away_team_scheduled_date" on "team_match_games" ("home_team", "away_team", "scheduled_date");
CREATE INDEX "team_match_games_idx_umpire" on "team_match_games" ("umpire");
CREATE INDEX "team_match_games_idx_winner" on "team_match_games" ("winner");

;
--
-- Table: team_match_legs
--
CREATE TABLE "team_match_legs" (
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_game_number" smallint NOT NULL,
  "leg_number" smallint NOT NULL,
  "home_team_points_won" smallint DEFAULT 0 NOT NULL,
  "away_team_points_won" smallint DEFAULT 0 NOT NULL,
  "first_server" integer,
  "leg_in_progress" smallint DEFAULT 0 NOT NULL,
  "next_point_server" integer,
  "started" smallint DEFAULT 0 NOT NULL,
  "complete" smallint DEFAULT 0 NOT NULL,
  "awarded" smallint DEFAULT 0 NOT NULL,
  "void" smallint DEFAULT 0 NOT NULL,
  "winner" integer,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number", "leg_number")
);
CREATE INDEX "team_match_legs_idx_first_server" on "team_match_legs" ("first_server");
CREATE INDEX "team_match_legs_idx_next_point_server" on "team_match_legs" ("next_point_server");
CREATE INDEX "team_match_legs_idx_home_team_away_team_scheduled_date_scheduled_game_number" on "team_match_legs" ("home_team", "away_team", "scheduled_date", "scheduled_game_number");
CREATE INDEX "team_match_legs_idx_winner" on "team_match_legs" ("winner");

;
--
-- Table: team_match_players
--
CREATE TABLE "team_match_players" (
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "player_number" smallint NOT NULL,
  "location" character varying(10) NOT NULL,
  "player" integer,
  "player_missing" smallint DEFAULT 0 NOT NULL,
  "loan_team" integer,
  "games_played" smallint DEFAULT 0 NOT NULL,
  "games_won" smallint DEFAULT 0 NOT NULL,
  "games_lost" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "legs_played" smallint DEFAULT 0 NOT NULL,
  "legs_won" smallint DEFAULT 0 NOT NULL,
  "legs_lost" smallint DEFAULT 0 NOT NULL,
  "average_leg_wins" float DEFAULT 0 NOT NULL,
  "points_played" smallint DEFAULT 0 NOT NULL,
  "points_won" smallint DEFAULT 0 NOT NULL,
  "points_lost" smallint DEFAULT 0 NOT NULL,
  "average_point_wins" float DEFAULT 0 NOT NULL,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date", "player_number")
);
CREATE INDEX "team_match_players_idx_loan_team" on "team_match_players" ("loan_team");
CREATE INDEX "team_match_players_idx_location" on "team_match_players" ("location");
CREATE INDEX "team_match_players_idx_player" on "team_match_players" ("player");
CREATE INDEX "team_match_players_idx_home_team_away_team_scheduled_date" on "team_match_players" ("home_team", "away_team", "scheduled_date");

;
--
-- Table: team_match_reports
--
CREATE TABLE "team_match_reports" (
  "id" serial NOT NULL,
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "published" timestamp NOT NULL,
  "author" integer NOT NULL,
  "report" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "team_match_reports_idx_author" on "team_match_reports" ("author");
CREATE INDEX "team_match_reports_idx_home_team_away_team_scheduled_date" on "team_match_reports" ("home_team", "away_team", "scheduled_date");

;
--
-- Table: team_matches
--
CREATE TABLE "team_matches" (
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "scheduled_start_time" time NOT NULL,
  "season" integer NOT NULL,
  "tournament_round" integer,
  "division" integer NOT NULL,
  "venue" integer NOT NULL,
  "scheduled_week" integer NOT NULL,
  "played_date" date,
  "start_time" time,
  "played_week" integer,
  "team_match_template" integer NOT NULL,
  "started" smallint DEFAULT 0 NOT NULL,
  "updated_since" timestamp NOT NULL,
  "home_team_games_won" smallint DEFAULT 0 NOT NULL,
  "home_team_games_lost" smallint DEFAULT 0 NOT NULL,
  "away_team_games_won" smallint DEFAULT 0 NOT NULL,
  "away_team_games_lost" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "home_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "home_team_average_leg_wins" float DEFAULT 0 NOT NULL,
  "away_team_legs_won" smallint DEFAULT 0 NOT NULL,
  "away_team_average_leg_wins" float DEFAULT 0 NOT NULL,
  "home_team_points_won" smallint DEFAULT 0 NOT NULL,
  "home_team_average_point_wins" float DEFAULT 0 NOT NULL,
  "away_team_points_won" smallint DEFAULT 0 NOT NULL,
  "away_team_average_point_wins" float DEFAULT 0 NOT NULL,
  "home_team_match_score" smallint DEFAULT 0 NOT NULL,
  "away_team_match_score" smallint DEFAULT 0 NOT NULL,
  "player_of_the_match" integer,
  "fixtures_grid" integer,
  "complete" smallint DEFAULT 0 NOT NULL,
  "league_official_verified" integer,
  "home_team_verified" integer,
  "away_team_verified" integer,
  "cancelled" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("home_team", "away_team", "scheduled_date")
);
CREATE INDEX "team_matches_idx_away_team" on "team_matches" ("away_team");
CREATE INDEX "team_matches_idx_away_team_verified" on "team_matches" ("away_team_verified");
CREATE INDEX "team_matches_idx_division" on "team_matches" ("division");
CREATE INDEX "team_matches_idx_fixtures_grid" on "team_matches" ("fixtures_grid");
CREATE INDEX "team_matches_idx_home_team" on "team_matches" ("home_team");
CREATE INDEX "team_matches_idx_home_team_verified" on "team_matches" ("home_team_verified");
CREATE INDEX "team_matches_idx_league_official_verified" on "team_matches" ("league_official_verified");
CREATE INDEX "team_matches_idx_played_week" on "team_matches" ("played_week");
CREATE INDEX "team_matches_idx_player_of_the_match" on "team_matches" ("player_of_the_match");
CREATE INDEX "team_matches_idx_scheduled_week" on "team_matches" ("scheduled_week");
CREATE INDEX "team_matches_idx_season" on "team_matches" ("season");
CREATE INDEX "team_matches_idx_team_match_template" on "team_matches" ("team_match_template");
CREATE INDEX "team_matches_idx_tournament_round" on "team_matches" ("tournament_round");
CREATE INDEX "team_matches_idx_venue" on "team_matches" ("venue");

;
--
-- Table: team_seasons
--
CREATE TABLE "team_seasons" (
  "team" integer NOT NULL,
  "season" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "club" integer NOT NULL,
  "division" integer NOT NULL,
  "captain" integer,
  "matches_played" smallint DEFAULT 0 NOT NULL,
  "matches_won" smallint DEFAULT 0 NOT NULL,
  "matches_drawn" smallint DEFAULT 0 NOT NULL,
  "matches_lost" smallint DEFAULT 0 NOT NULL,
  "table_points" smallint DEFAULT 0,
  "games_played" smallint DEFAULT 0 NOT NULL,
  "games_won" smallint DEFAULT 0 NOT NULL,
  "games_drawn" smallint DEFAULT 0 NOT NULL,
  "games_lost" smallint DEFAULT 0 NOT NULL,
  "average_game_wins" float DEFAULT 0 NOT NULL,
  "legs_played" smallint DEFAULT 0 NOT NULL,
  "legs_won" smallint DEFAULT 0 NOT NULL,
  "legs_lost" smallint DEFAULT 0 NOT NULL,
  "average_leg_wins" float DEFAULT 0 NOT NULL,
  "points_played" integer DEFAULT 0 NOT NULL,
  "points_won" integer DEFAULT 0 NOT NULL,
  "points_lost" integer DEFAULT 0 NOT NULL,
  "average_point_wins" float DEFAULT 0 NOT NULL,
  "doubles_games_played" smallint DEFAULT 0 NOT NULL,
  "doubles_games_won" smallint DEFAULT 0 NOT NULL,
  "doubles_games_drawn" smallint DEFAULT 0 NOT NULL,
  "doubles_games_lost" smallint DEFAULT 0 NOT NULL,
  "doubles_average_game_wins" float DEFAULT 0 NOT NULL,
  "doubles_legs_played" smallint DEFAULT 0 NOT NULL,
  "doubles_legs_won" smallint DEFAULT 0 NOT NULL,
  "doubles_legs_lost" smallint DEFAULT 0 NOT NULL,
  "doubles_average_leg_wins" float DEFAULT 0 NOT NULL,
  "doubles_points_played" integer DEFAULT 0 NOT NULL,
  "doubles_points_won" integer DEFAULT 0 NOT NULL,
  "doubles_points_lost" integer DEFAULT 0 NOT NULL,
  "doubles_average_point_wins" float DEFAULT 0 NOT NULL,
  "home_night" smallint DEFAULT 0 NOT NULL,
  "grid_position" smallint DEFAULT 0,
  "last_updated" timestamp NOT NULL,
  PRIMARY KEY ("team", "season")
);
CREATE INDEX "team_seasons_idx_captain" on "team_seasons" ("captain");
CREATE INDEX "team_seasons_idx_club" on "team_seasons" ("club");
CREATE INDEX "team_seasons_idx_division" on "team_seasons" ("division");
CREATE INDEX "team_seasons_idx_home_night" on "team_seasons" ("home_night");
CREATE INDEX "team_seasons_idx_season" on "team_seasons" ("season");
CREATE INDEX "team_seasons_idx_team" on "team_seasons" ("team");

;
--
-- Table: team_seasons_intervals
--
CREATE TABLE "team_seasons_intervals" (
  "team" integer NOT NULL,
  "season" integer NOT NULL,
  "week" integer NOT NULL,
  "division" integer NOT NULL,
  "league_table_points" smallint NOT NULL,
  "matches_played" smallint NOT NULL,
  "matches_won" smallint NOT NULL,
  "matches_lost" smallint NOT NULL,
  "matches_drawn" smallint NOT NULL,
  "games_played" smallint NOT NULL,
  "games_won" smallint NOT NULL,
  "games_lost" smallint NOT NULL,
  "games_drawn" smallint NOT NULL,
  "average_game_wins" float NOT NULL,
  "legs_played" smallint NOT NULL,
  "legs_won" smallint NOT NULL,
  "legs_lost" smallint NOT NULL,
  "average_leg_wins" float NOT NULL,
  "points_played" integer NOT NULL,
  "points_won" integer NOT NULL,
  "points_lost" integer NOT NULL,
  "average_point_wins" float NOT NULL,
  "table_points" smallint DEFAULT 0,
  PRIMARY KEY ("team", "season", "week")
);
CREATE INDEX "team_seasons_intervals_idx_division" on "team_seasons_intervals" ("division");
CREATE INDEX "team_seasons_intervals_idx_season" on "team_seasons_intervals" ("season");
CREATE INDEX "team_seasons_intervals_idx_team" on "team_seasons_intervals" ("team");
CREATE INDEX "team_seasons_intervals_idx_week" on "team_seasons_intervals" ("week");

;
--
-- Table: teams
--
CREATE TABLE "teams" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(150) NOT NULL,
  "club" integer NOT NULL,
  "default_match_start" time,
  PRIMARY KEY ("id"),
  CONSTRAINT "name_club" UNIQUE ("name", "club"),
  CONSTRAINT "url_key_club" UNIQUE ("url_key", "club")
);
CREATE INDEX "teams_idx_club" on "teams" ("club");

;
--
-- Table: template_league_table_ranking
--
CREATE TABLE "template_league_table_ranking" (
  "id" serial NOT NULL,
  "url_key" character varying(30) NOT NULL,
  "name" character varying(300) NOT NULL,
  "assign_points" smallint,
  "points_per_win" smallint,
  "points_per_draw" smallint,
  "points_per_loss" smallint,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: template_match_individual
--
CREATE TABLE "template_match_individual" (
  "id" serial NOT NULL,
  "url_key" character varying(60) NOT NULL,
  "name" character varying(45) NOT NULL,
  "game_type" character varying(20) NOT NULL,
  "legs_per_game" smallint NOT NULL,
  "minimum_points_win" smallint NOT NULL,
  "clear_points_win" smallint NOT NULL,
  "serve_type" character varying(20) NOT NULL,
  "serves" smallint,
  "serves_deuce" smallint,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "template_match_individual_idx_game_type" on "template_match_individual" ("game_type");
CREATE INDEX "template_match_individual_idx_serve_type" on "template_match_individual" ("serve_type");

;
--
-- Table: template_match_team
--
CREATE TABLE "template_match_team" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(45) NOT NULL,
  "singles_players_per_team" smallint NOT NULL,
  "winner_type" character varying(10) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "template_match_team_idx_winner_type" on "template_match_team" ("winner_type");

;
--
-- Table: template_match_team_games
--
CREATE TABLE "template_match_team_games" (
  "id" serial NOT NULL,
  "team_match_template" integer NOT NULL,
  "individual_match_template" integer,
  "match_game_number" smallint NOT NULL,
  "doubles_game" smallint NOT NULL,
  "singles_home_player_number" smallint,
  "singles_away_player_number" smallint,
  PRIMARY KEY ("id")
);
CREATE INDEX "template_match_team_games_idx_individual_match_template" on "template_match_team_games" ("individual_match_template");
CREATE INDEX "template_match_team_games_idx_team_match_template" on "template_match_team_games" ("team_match_template");

;
--
-- Table: tournament_round_group_individual_membership
--
CREATE TABLE "tournament_round_group_individual_membership" (
  "id" serial NOT NULL,
  "group" integer NOT NULL,
  "person1" integer NOT NULL,
  "person2" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "tournament_round_group_individual_membership_idx_group" on "tournament_round_group_individual_membership" ("group");
CREATE INDEX "tournament_round_group_individual_membership_idx_person1" on "tournament_round_group_individual_membership" ("person1");
CREATE INDEX "tournament_round_group_individual_membership_idx_person2" on "tournament_round_group_individual_membership" ("person2");

;
--
-- Table: tournament_round_group_team_membership
--
CREATE TABLE "tournament_round_group_team_membership" (
  "id" serial NOT NULL,
  "group" integer NOT NULL,
  "team" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "tournament_round_group_team_membership_idx_group" on "tournament_round_group_team_membership" ("group");
CREATE INDEX "tournament_round_group_team_membership_idx_team" on "tournament_round_group_team_membership" ("team");

;
--
-- Table: tournament_round_groups
--
CREATE TABLE "tournament_round_groups" (
  "id" serial NOT NULL,
  "tournament_round" integer NOT NULL,
  "group_name" character varying(150) NOT NULL,
  "group_order" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "tournament_round_groups_idx_tournament_round" on "tournament_round_groups" ("tournament_round");

;
--
-- Table: tournament_round_phases
--
CREATE TABLE "tournament_round_phases" (
  "id" serial NOT NULL,
  "tournament_round" integer NOT NULL,
  "phase_number" smallint NOT NULL,
  "name" character varying(150) NOT NULL,
  "date" date NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "tournament_round_phases_idx_tournament_round" on "tournament_round_phases" ("tournament_round");

;
--
-- Table: tournament_rounds
--
CREATE TABLE "tournament_rounds" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "tournament" integer NOT NULL,
  "season" integer NOT NULL,
  "round_number" smallint NOT NULL,
  "name" character varying(150) NOT NULL,
  "round_type" character(1) NOT NULL,
  "team_match_template" integer NOT NULL,
  "individual_match_template" integer NOT NULL,
  "date" date,
  "venue" integer,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key_unique_in_tournament_season" UNIQUE ("url_key", "tournament", "season")
);
CREATE INDEX "tournament_rounds_idx_individual_match_template" on "tournament_rounds" ("individual_match_template");
CREATE INDEX "tournament_rounds_idx_team_match_template" on "tournament_rounds" ("team_match_template");

;
--
-- Table: tournament_team_matches
--
CREATE TABLE "tournament_team_matches" (
  "id" serial NOT NULL,
  "match_template" integer NOT NULL,
  "home_team" integer NOT NULL,
  "away_team" integer NOT NULL,
  "tournament_round_phase" integer NOT NULL,
  "venue" integer NOT NULL,
  "scheduled_date" date NOT NULL,
  "played_date" date,
  "match_in_progress" smallint DEFAULT 0 NOT NULL,
  "home_team_score" smallint DEFAULT 0 NOT NULL,
  "away_team_score" smallint DEFAULT 0 NOT NULL,
  "complete" smallint DEFAULT 0 NOT NULL,
  "league_official_verified" integer,
  "home_team_verified" integer,
  "away_team_verified" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "tournament_team_matches_idx_away_team" on "tournament_team_matches" ("away_team");
CREATE INDEX "tournament_team_matches_idx_away_team_verified" on "tournament_team_matches" ("away_team_verified");
CREATE INDEX "tournament_team_matches_idx_home_team" on "tournament_team_matches" ("home_team");
CREATE INDEX "tournament_team_matches_idx_home_team_verified" on "tournament_team_matches" ("home_team_verified");
CREATE INDEX "tournament_team_matches_idx_league_official_verified" on "tournament_team_matches" ("league_official_verified");
CREATE INDEX "tournament_team_matches_idx_match_template" on "tournament_team_matches" ("match_template");
CREATE INDEX "tournament_team_matches_idx_tournament_round_phase" on "tournament_team_matches" ("tournament_round_phase");
CREATE INDEX "tournament_team_matches_idx_venue" on "tournament_team_matches" ("venue");

;
--
-- Table: tournaments
--
CREATE TABLE "tournaments" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(100) NOT NULL,
  "event" integer NOT NULL,
  "season" integer NOT NULL,
  "entry_type" character varying(20) NOT NULL,
  "allow_online_entries" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);
CREATE INDEX "tournaments_idx_entry_type" on "tournaments" ("entry_type");
CREATE INDEX "tournaments_idx_event_season" on "tournaments" ("event", "season");

;
--
-- Table: uploaded_files
--
CREATE TABLE "uploaded_files" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "filename" character varying(255) NOT NULL,
  "description" character varying(255),
  "mime_type" character varying(150) NOT NULL,
  "uploaded" timestamp NOT NULL,
  "downloaded_count" integer DEFAULT 0 NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: uploaded_images
--
CREATE TABLE "uploaded_images" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "filename" character varying(255) NOT NULL,
  "description" character varying(255),
  "mime_type" character varying(150) NOT NULL,
  "uploaded" timestamp NOT NULL,
  "viewed_count" integer DEFAULT 0 NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Table: user_agents
--
CREATE TABLE "user_agents" (
  "id" serial NOT NULL,
  "string" text NOT NULL,
  "sha256_hash" character varying(64) NOT NULL,
  "first_seen" timestamp NOT NULL,
  "last_seen" timestamp NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: user_ip_addresses_browsers
--
CREATE TABLE "user_ip_addresses_browsers" (
  "user_id" integer NOT NULL,
  "ip_address" character varying(40) NOT NULL,
  "user_agent" integer NOT NULL,
  "first_seen" timestamp NOT NULL,
  "last_seen" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "ip_address", "user_agent")
);
CREATE INDEX "user_ip_addresses_browsers_idx_user_id" on "user_ip_addresses_browsers" ("user_id");
CREATE INDEX "user_ip_addresses_browsers_idx_user_agent" on "user_ip_addresses_browsers" ("user_agent");

;
--
-- Table: user_roles
--
CREATE TABLE "user_roles" (
  "user" integer NOT NULL,
  "role" integer NOT NULL,
  PRIMARY KEY ("user", "role")
);
CREATE INDEX "user_roles_idx_role" on "user_roles" ("role");
CREATE INDEX "user_roles_idx_user" on "user_roles" ("user");

;
--
-- Table: users
--
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "username" character varying(45) NOT NULL,
  "email_address" character varying(300) NOT NULL,
  "person" integer,
  "password" text NOT NULL,
  "change_password_next_login" smallint DEFAULT 0 NOT NULL,
  "html_emails" smallint DEFAULT 0 NOT NULL,
  "registered_date" timestamp NOT NULL,
  "registered_ip" character varying(45) NOT NULL,
  "last_visit_date" timestamp NOT NULL,
  "last_visit_ip" character varying(45),
  "last_active_date" timestamp NOT NULL,
  "last_active_ip" character varying(45),
  "locale" character varying(6) NOT NULL,
  "timezone" character varying(50),
  "avatar" character varying(500),
  "posts" integer DEFAULT 0 NOT NULL,
  "comments" integer DEFAULT 0 NOT NULL,
  "signature" text,
  "facebook" character varying(255),
  "twitter" character varying(255),
  "aim" character varying(255),
  "jabber" character varying(255),
  "website" character varying(255),
  "interests" text,
  "occupation" character varying(150),
  "location" character varying(150),
  "hide_online" smallint DEFAULT 0 NOT NULL,
  "activation_key" character varying(64),
  "activated" smallint DEFAULT 0 NOT NULL,
  "activation_expires" timestamp NOT NULL,
  "invalid_logins" smallint DEFAULT 0 NOT NULL,
  "password_reset_key" character varying(64),
  "password_reset_expires" timestamp NOT NULL,
  "last_invalid_login" timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key"),
  CONSTRAINT "user_person_idx" UNIQUE ("person")
);
CREATE INDEX "users_idx_person" on "users" ("person");

;
--
-- Table: venue_timetables
--
CREATE TABLE "venue_timetables" (
  "id" integer NOT NULL,
  "venue" integer NOT NULL,
  "day" smallint NOT NULL,
  "number_of_tables" smallint,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "price_information" character varying(50),
  "description" text NOT NULL,
  "matches" smallint NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "venue_timetables_idx_day" on "venue_timetables" ("day");
CREATE INDEX "venue_timetables_idx_venue" on "venue_timetables" ("venue");

;
--
-- Table: venues
--
CREATE TABLE "venues" (
  "id" serial NOT NULL,
  "url_key" character varying(45) NOT NULL,
  "name" character varying(300) NOT NULL,
  "address1" character varying(100),
  "address2" character varying(100),
  "address3" character varying(100),
  "address4" character varying(100),
  "address5" character varying(100),
  "postcode" character varying(10),
  "telephone" character varying(20),
  "email_address" character varying(240),
  "coordinates_latitude" float(10,8),
  "coordinates_longitude" float(11,8),
  PRIMARY KEY ("id"),
  CONSTRAINT "url_key" UNIQUE ("url_key")
);

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "average_filters" ADD CONSTRAINT "average_filters_fk_user" FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "clubs" ADD CONSTRAINT "clubs_fk_secretary" FOREIGN KEY ("secretary")
  REFERENCES "people" ("id") ON DELETE SET NULL ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "clubs" ADD CONSTRAINT "clubs_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "contact_reason_recipients" ADD CONSTRAINT "contact_reason_recipients_fk_contact_reason" FOREIGN KEY ("contact_reason")
  REFERENCES "contact_reasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "contact_reason_recipients" ADD CONSTRAINT "contact_reason_recipients_fk_person" FOREIGN KEY ("person")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fk_division" FOREIGN KEY ("division")
  REFERENCES "divisions" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fk_fixtures_grid" FOREIGN KEY ("fixtures_grid")
  REFERENCES "fixtures_grids" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fk_league_match_template" FOREIGN KEY ("league_match_template")
  REFERENCES "template_match_team" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fk_league_table_ranking_template" FOREIGN KEY ("league_table_ranking_template")
  REFERENCES "template_league_table_ranking" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "division_seasons" ADD CONSTRAINT "division_seasons_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_fk_person1" FOREIGN KEY ("person1")
  REFERENCES "people" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_fk_person2" FOREIGN KEY ("person2")
  REFERENCES "people" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "doubles_pairs" ADD CONSTRAINT "doubles_pairs_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_fk_event" FOREIGN KEY ("event")
  REFERENCES "events" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_fk_organiser" FOREIGN KEY ("organiser")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "event_seasons" ADD CONSTRAINT "event_seasons_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "events" ADD CONSTRAINT "events_fk_event_type" FOREIGN KEY ("event_type")
  REFERENCES "lookup_event_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "fixtures_grid_matches" ADD CONSTRAINT "fixtures_grid_matches_fk_grid_week" FOREIGN KEY ("grid", "week")
  REFERENCES "fixtures_grid_weeks" ("grid", "week") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "fixtures_grid_weeks" ADD CONSTRAINT "fixtures_grid_weeks_fk_grid" FOREIGN KEY ("grid")
  REFERENCES "fixtures_grids" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "fixtures_season_weeks" ADD CONSTRAINT "fixtures_season_weeks_fk_grid_grid_week" FOREIGN KEY ("grid", "grid_week")
  REFERENCES "fixtures_grid_weeks" ("grid", "week") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "fixtures_season_weeks" ADD CONSTRAINT "fixtures_season_weeks_fk_fixtures_week" FOREIGN KEY ("fixtures_week")
  REFERENCES "fixtures_weeks" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "fixtures_weeks" ADD CONSTRAINT "fixtures_weeks_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_fk_away_player" FOREIGN KEY ("away_player")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_fk_home_player" FOREIGN KEY ("home_player")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "individual_matches" ADD CONSTRAINT "individual_matches_fk_individual_match_template" FOREIGN KEY ("individual_match_template")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meeting_attendees" ADD CONSTRAINT "meeting_attendees_fk_meeting" FOREIGN KEY ("meeting")
  REFERENCES "meetings" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meeting_attendees" ADD CONSTRAINT "meeting_attendees_fk_person" FOREIGN KEY ("person")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_fk_event_season" FOREIGN KEY ("event", "season")
  REFERENCES "event_seasons" ("event", "season") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_fk_organiser" FOREIGN KEY ("organiser")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_fk_type" FOREIGN KEY ("type")
  REFERENCES "meeting_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "news_articles" ADD CONSTRAINT "news_articles_fk_original_article" FOREIGN KEY ("original_article")
  REFERENCES "news_articles" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "news_articles" ADD CONSTRAINT "news_articles_fk_updated_by_user" FOREIGN KEY ("updated_by_user")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "officials" ADD CONSTRAINT "officials_fk_position_holder" FOREIGN KEY ("position_holder")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "officials" ADD CONSTRAINT "officials_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

;
ALTER TABLE "people" ADD CONSTRAINT "people_fk_gender" FOREIGN KEY ("gender")
  REFERENCES "lookup_gender" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_fk_person" FOREIGN KEY ("person")
  REFERENCES "people" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_seasons" ADD CONSTRAINT "person_seasons_fk_team_membership_type" FOREIGN KEY ("team_membership_type")
  REFERENCES "lookup_team_membership_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_fk_person1" FOREIGN KEY ("person1")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_fk_person2" FOREIGN KEY ("person2")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "person_tournaments" ADD CONSTRAINT "person_tournaments_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_fk_user" FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_fk_user_agent" FOREIGN KEY ("user_agent")
  REFERENCES "user_agents" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log" ADD CONSTRAINT "system_event_log_fk_object_type_event_type" FOREIGN KEY ("object_type", "event_type")
  REFERENCES "system_event_log_types" ("object_type", "event_type") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log" ADD CONSTRAINT "system_event_log_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_average_filters" ADD CONSTRAINT "system_event_log_average_filters_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "average_filters" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_average_filters" ADD CONSTRAINT "system_event_log_average_filters_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_club" ADD CONSTRAINT "system_event_log_club_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "clubs" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_club" ADD CONSTRAINT "system_event_log_club_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_contact_reason" ADD CONSTRAINT "system_event_log_contact_reason_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "contact_reasons" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_contact_reason" ADD CONSTRAINT "system_event_log_contact_reason_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_division" ADD CONSTRAINT "system_event_log_division_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "divisions" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_division" ADD CONSTRAINT "system_event_log_division_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_event" ADD CONSTRAINT "system_event_log_event_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "events" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_event" ADD CONSTRAINT "system_event_log_event_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_file" ADD CONSTRAINT "system_event_log_file_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "uploaded_files" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_file" ADD CONSTRAINT "system_event_log_file_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_fixtures_grid" ADD CONSTRAINT "system_event_log_fixtures_grid_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "fixtures_grids" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_fixtures_grid" ADD CONSTRAINT "system_event_log_fixtures_grid_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_image" ADD CONSTRAINT "system_event_log_image_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "uploaded_images" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_image" ADD CONSTRAINT "system_event_log_image_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_meeting" ADD CONSTRAINT "system_event_log_meeting_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "meetings" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_meeting" ADD CONSTRAINT "system_event_log_meeting_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_meeting_type" ADD CONSTRAINT "system_event_log_meeting_type_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "meeting_types" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_meeting_type" ADD CONSTRAINT "system_event_log_meeting_type_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_news" ADD CONSTRAINT "system_event_log_news_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "news_articles" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_news" ADD CONSTRAINT "system_event_log_news_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_person" ADD CONSTRAINT "system_event_log_person_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "people" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_person" ADD CONSTRAINT "system_event_log_person_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_role" ADD CONSTRAINT "system_event_log_role_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "roles" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_role" ADD CONSTRAINT "system_event_log_role_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_season" ADD CONSTRAINT "system_event_log_season_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "seasons" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_season" ADD CONSTRAINT "system_event_log_season_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_team" ADD CONSTRAINT "system_event_log_team_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "teams" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_team" ADD CONSTRAINT "system_event_log_team_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_team_match" ADD CONSTRAINT "system_event_log_team_match_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_team_match" ADD CONSTRAINT "system_event_log_team_match_fk_object_home_team_object_away_team_object_scheduled_date" FOREIGN KEY ("object_home_team", "object_away_team", "object_scheduled_date")
  REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_template_league_table_ranking" ADD CONSTRAINT "system_event_log_template_league_table_ranking_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "template_league_table_ranking" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_template_league_table_ranking" ADD CONSTRAINT "system_event_log_template_league_table_ranking_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_individual" ADD CONSTRAINT "system_event_log_template_match_individual_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "template_match_individual" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_individual" ADD CONSTRAINT "system_event_log_template_match_individual_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_team" ADD CONSTRAINT "system_event_log_template_match_team_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "template_match_team" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_team" ADD CONSTRAINT "system_event_log_template_match_team_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_team_game" ADD CONSTRAINT "system_event_log_template_match_team_game_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "template_match_team" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_template_match_team_game" ADD CONSTRAINT "system_event_log_template_match_team_game_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_user" ADD CONSTRAINT "system_event_log_user_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_user" ADD CONSTRAINT "system_event_log_user_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "system_event_log_venue" ADD CONSTRAINT "system_event_log_venue_fk_object_id" FOREIGN KEY ("object_id")
  REFERENCES "venues" ("id") ON DELETE SET NULL ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_event_log_venue" ADD CONSTRAINT "system_event_log_venue_fk_system_event_log_id" FOREIGN KEY ("system_event_log_id")
  REFERENCES "system_event_log" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_away_doubles_pair" FOREIGN KEY ("away_doubles_pair")
  REFERENCES "doubles_pairs" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_away_player" FOREIGN KEY ("away_player")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_home_doubles_pair" FOREIGN KEY ("home_doubles_pair")
  REFERENCES "doubles_pairs" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_home_player" FOREIGN KEY ("home_player")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_individual_match_template" FOREIGN KEY ("individual_match_template")
  REFERENCES "template_match_individual" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_home_team_away_team_scheduled_date" FOREIGN KEY ("home_team", "away_team", "scheduled_date")
  REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_umpire" FOREIGN KEY ("umpire")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_games" ADD CONSTRAINT "team_match_games_fk_winner" FOREIGN KEY ("winner")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_fk_first_server" FOREIGN KEY ("first_server")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_fk_next_point_server" FOREIGN KEY ("next_point_server")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_fk_home_team_away_team_scheduled_date_scheduled_game_number" FOREIGN KEY ("home_team", "away_team", "scheduled_date", "scheduled_game_number")
  REFERENCES "team_match_games" ("home_team", "away_team", "scheduled_date", "scheduled_game_number") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "team_match_legs" ADD CONSTRAINT "team_match_legs_fk_winner" FOREIGN KEY ("winner")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_fk_loan_team" FOREIGN KEY ("loan_team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_fk_location" FOREIGN KEY ("location")
  REFERENCES "lookup_locations" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_fk_player" FOREIGN KEY ("player")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_players" ADD CONSTRAINT "team_match_players_fk_home_team_away_team_scheduled_date" FOREIGN KEY ("home_team", "away_team", "scheduled_date")
  REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "team_match_reports" ADD CONSTRAINT "team_match_reports_fk_author" FOREIGN KEY ("author")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_match_reports" ADD CONSTRAINT "team_match_reports_fk_home_team_away_team_scheduled_date" FOREIGN KEY ("home_team", "away_team", "scheduled_date")
  REFERENCES "team_matches" ("home_team", "away_team", "scheduled_date") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_away_team" FOREIGN KEY ("away_team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_away_team_verified" FOREIGN KEY ("away_team_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_division" FOREIGN KEY ("division")
  REFERENCES "divisions" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_fixtures_grid" FOREIGN KEY ("fixtures_grid")
  REFERENCES "fixtures_grids" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_home_team" FOREIGN KEY ("home_team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_home_team_verified" FOREIGN KEY ("home_team_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_league_official_verified" FOREIGN KEY ("league_official_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_played_week" FOREIGN KEY ("played_week")
  REFERENCES "fixtures_weeks" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_player_of_the_match" FOREIGN KEY ("player_of_the_match")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_scheduled_week" FOREIGN KEY ("scheduled_week")
  REFERENCES "fixtures_weeks" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_team_match_template" FOREIGN KEY ("team_match_template")
  REFERENCES "template_match_team" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_tournament_round" FOREIGN KEY ("tournament_round")
  REFERENCES "tournament_rounds" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_matches" ADD CONSTRAINT "team_matches_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_captain" FOREIGN KEY ("captain")
  REFERENCES "people" ("id") ON DELETE SET NULL ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_club" FOREIGN KEY ("club")
  REFERENCES "clubs" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_division" FOREIGN KEY ("division")
  REFERENCES "divisions" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_home_night" FOREIGN KEY ("home_night")
  REFERENCES "lookup_weekdays" ("weekday_number") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons" ADD CONSTRAINT "team_seasons_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_fk_division" FOREIGN KEY ("division")
  REFERENCES "divisions" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_fk_season" FOREIGN KEY ("season")
  REFERENCES "seasons" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "team_seasons_intervals" ADD CONSTRAINT "team_seasons_intervals_fk_week" FOREIGN KEY ("week")
  REFERENCES "fixtures_weeks" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "teams" ADD CONSTRAINT "teams_fk_club" FOREIGN KEY ("club")
  REFERENCES "clubs" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "template_match_individual" ADD CONSTRAINT "template_match_individual_fk_game_type" FOREIGN KEY ("game_type")
  REFERENCES "lookup_game_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "template_match_individual" ADD CONSTRAINT "template_match_individual_fk_serve_type" FOREIGN KEY ("serve_type")
  REFERENCES "lookup_serve_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "template_match_team" ADD CONSTRAINT "template_match_team_fk_winner_type" FOREIGN KEY ("winner_type")
  REFERENCES "lookup_winner_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "template_match_team_games" ADD CONSTRAINT "template_match_team_games_fk_individual_match_template" FOREIGN KEY ("individual_match_template")
  REFERENCES "template_match_individual" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "template_match_team_games" ADD CONSTRAINT "template_match_team_games_fk_team_match_template" FOREIGN KEY ("team_match_template")
  REFERENCES "template_match_team" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_individual_membership_fk_group" FOREIGN KEY ("group")
  REFERENCES "tournament_round_groups" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_individual_membership_fk_person1" FOREIGN KEY ("person1")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_group_individual_membership" ADD CONSTRAINT "tournament_round_group_individual_membership_fk_person2" FOREIGN KEY ("person2")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_group_team_membership" ADD CONSTRAINT "tournament_round_group_team_membership_fk_group" FOREIGN KEY ("group")
  REFERENCES "tournament_round_groups" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_group_team_membership" ADD CONSTRAINT "tournament_round_group_team_membership_fk_team" FOREIGN KEY ("team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_groups" ADD CONSTRAINT "tournament_round_groups_fk_tournament_round" FOREIGN KEY ("tournament_round")
  REFERENCES "tournament_rounds" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_round_phases" ADD CONSTRAINT "tournament_round_phases_fk_tournament_round" FOREIGN KEY ("tournament_round")
  REFERENCES "tournament_rounds" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_rounds" ADD CONSTRAINT "tournament_rounds_fk_individual_match_template" FOREIGN KEY ("individual_match_template")
  REFERENCES "template_match_individual" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_rounds" ADD CONSTRAINT "tournament_rounds_fk_team_match_template" FOREIGN KEY ("team_match_template")
  REFERENCES "template_match_team" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_away_team" FOREIGN KEY ("away_team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_away_team_verified" FOREIGN KEY ("away_team_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_home_team" FOREIGN KEY ("home_team")
  REFERENCES "teams" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_home_team_verified" FOREIGN KEY ("home_team_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_league_official_verified" FOREIGN KEY ("league_official_verified")
  REFERENCES "people" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_match_template" FOREIGN KEY ("match_template")
  REFERENCES "template_match_team" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_tournament_round_phase" FOREIGN KEY ("tournament_round_phase")
  REFERENCES "tournament_round_phases" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournament_team_matches" ADD CONSTRAINT "tournament_team_matches_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournaments" ADD CONSTRAINT "tournaments_fk_entry_type" FOREIGN KEY ("entry_type")
  REFERENCES "lookup_tournament_types" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "tournaments" ADD CONSTRAINT "tournaments_fk_event_season" FOREIGN KEY ("event", "season")
  REFERENCES "event_seasons" ("event", "season") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "user_ip_addresses_browsers" ADD CONSTRAINT "user_ip_addresses_browsers_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "user_ip_addresses_browsers" ADD CONSTRAINT "user_ip_addresses_browsers_fk_user_agent" FOREIGN KEY ("user_agent")
  REFERENCES "user_agents" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_fk_role" FOREIGN KEY ("role")
  REFERENCES "roles" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_fk_user" FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "users" ADD CONSTRAINT "users_fk_person" FOREIGN KEY ("person")
  REFERENCES "people" ("id") ON DELETE SET NULL ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "venue_timetables" ADD CONSTRAINT "venue_timetables_fk_day" FOREIGN KEY ("day")
  REFERENCES "lookup_weekdays" ("weekday_number") ON DELETE RESTRICT ON UPDATE RESTRICT DEFERRABLE;

;
ALTER TABLE "venue_timetables" ADD CONSTRAINT "venue_timetables_fk_venue" FOREIGN KEY ("venue")
  REFERENCES "venues" ("id") ON DELETE CASCADE ON UPDATE RESTRICT DEFERRABLE;

;
