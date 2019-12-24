-- 
-- Created by SQL::Translator::Generator::Role::DDL
-- Created on Mon Dec 23 13:25:40 2019
-- 


--
-- Table: [average_filters]
--
CREATE TABLE [average_filters] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(50) NOT NULL,
  [name] varchar(50) NOT NULL,
  [show_active] tinyint NULL DEFAULT '1',
  [show_loan] tinyint NULL DEFAULT '0',
  [show_inactive] tinyint NULL DEFAULT '0',
  [criteria_field] varchar(10) NULL,
  [operator] varchar(2) NULL,
  [criteria] smallint NOT NULL,
  [criteria_type] varchar(10) NULL,
  [user] integer NULL,
  CONSTRAINT [average_filters_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE UNIQUE NONCLUSTERED INDEX [name_user] ON [average_filters] ([name], [user]) WHERE [user] IS NOT NULL;

CREATE INDEX [average_filters_idx_user] ON [average_filters] ([user]);


--
-- Table: [calendar_types]
--
CREATE TABLE [calendar_types] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(50) NOT NULL,
  [name] varchar(50) NOT NULL,
  [uri] varchar(500) NOT NULL,
  [calendar_scheme] varchar(10) NULL,
  [uri_escape_replacements] tinyint NOT NULL DEFAULT '0',
  [display_order] smallint NOT NULL,
  CONSTRAINT [calendar_types_pk] PRIMARY KEY ([id]),
  CONSTRAINT [name] UNIQUE ([name])
);


--
-- Table: [clubs]
--
CREATE TABLE [clubs] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NULL,
  [full_name] varchar(300) NOT NULL,
  [short_name] varchar(150) NOT NULL,
  [venue] integer NOT NULL,
  [secretary] integer NULL,
  [email_address] varchar(200) NULL,
  [website] varchar(2083) NULL,
  [facebook] varchar(2083) NULL,
  [twitter] varchar(2083) NULL,
  [instagram] varchar(2083) NULL,
  [youtube] varchar(2083) NULL,
  [default_match_start] datetime NULL,
  CONSTRAINT [clubs_pk] PRIMARY KEY ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [url_key] ON [clubs] ([url_key]) WHERE [url_key] IS NOT NULL;

CREATE INDEX [clubs_idx_secretary] ON [clubs] ([secretary]);

CREATE INDEX [clubs_idx_venue] ON [clubs] ([venue]);


--
-- Table: [contact_reason_recipients]
--
CREATE TABLE [contact_reason_recipients] (
  [contact_reason] integer NOT NULL,
  [person] integer NOT NULL,
  CONSTRAINT [contact_reason_recipients_pk] PRIMARY KEY ([contact_reason], [person])
);

CREATE INDEX [contact_reason_recipients_idx_contact_reason] ON [contact_reason_recipients] ([contact_reason]);

CREATE INDEX [contact_reason_recipients_idx_person] ON [contact_reason_recipients] ([person]);


--
-- Table: [contact_reasons]
--
CREATE TABLE [contact_reasons] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(50) NOT NULL,
  CONSTRAINT [contact_reasons_pk] PRIMARY KEY ([id])
);


--
-- Table: [division_seasons]
--
CREATE TABLE [division_seasons] (
  [division] integer NOT NULL,
  [season] integer NOT NULL,
  [name] varchar(45) NOT NULL,
  [fixtures_grid] integer NOT NULL,
  [league_match_template] integer NOT NULL,
  [league_table_ranking_template] integer NOT NULL,
  [promotion_places] tinyint NULL DEFAULT '0',
  [relegation_places] tinyint NULL DEFAULT '0',
  CONSTRAINT [division_seasons_pk] PRIMARY KEY ([division], [season])
);

CREATE INDEX [division_seasons_idx_division] ON [division_seasons] ([division]);

CREATE INDEX [division_seasons_idx_fixtures_grid] ON [division_seasons] ([fixtures_grid]);

CREATE INDEX [division_seasons_idx_league_match_template] ON [division_seasons] ([league_match_template]);

CREATE INDEX [division_seasons_idx_league_table_ranking_template] ON [division_seasons] ([league_table_ranking_template]);

CREATE INDEX [division_seasons_idx_season] ON [division_seasons] ([season]);


--
-- Table: [divisions]
--
CREATE TABLE [divisions] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(45) NOT NULL,
  [rank] tinyint NOT NULL,
  CONSTRAINT [divisions_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [doubles_pairs]
--
CREATE TABLE [doubles_pairs] (
  [id] integer IDENTITY NOT NULL,
  [person1] integer NOT NULL,
  [person2] integer NOT NULL,
  [season] integer NOT NULL,
  [team] integer NOT NULL,
  [person1_loan] tinyint NOT NULL DEFAULT '0',
  [person2_loan] tinyint NOT NULL DEFAULT '0',
  [games_played] tinyint NOT NULL DEFAULT '0',
  [games_won] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [games_lost] tinyint NOT NULL DEFAULT '0',
  [average_game_wins] float NOT NULL DEFAULT '0',
  [legs_played] tinyint NOT NULL DEFAULT '0',
  [legs_won] tinyint NOT NULL DEFAULT '0',
  [legs_lost] tinyint NOT NULL DEFAULT '0',
  [average_leg_wins] float NOT NULL DEFAULT '0',
  [points_played] integer NOT NULL DEFAULT '0',
  [points_won] integer NOT NULL DEFAULT '0',
  [points_lost] integer NOT NULL DEFAULT '0',
  [average_point_wins] float NOT NULL DEFAULT '0',
  [last_updated] datetime NOT NULL,
  CONSTRAINT [doubles_pairs_pk] PRIMARY KEY ([id])
);

CREATE INDEX [doubles_pairs_idx_person1] ON [doubles_pairs] ([person1]);

CREATE INDEX [doubles_pairs_idx_person2] ON [doubles_pairs] ([person2]);

CREATE INDEX [doubles_pairs_idx_season] ON [doubles_pairs] ([season]);

CREATE INDEX [doubles_pairs_idx_team] ON [doubles_pairs] ([team]);


--
-- Table: [event_seasons]
--
CREATE TABLE [event_seasons] (
  [event] integer NOT NULL,
  [season] integer NOT NULL,
  [name] varchar(300) NOT NULL,
  [date] datetime NULL,
  [date_and_start_time] datetime NULL,
  [all_day] tinyint NULL,
  [finish_time] datetime NULL,
  [organiser] integer NULL,
  [venue] integer NULL,
  [description] longtext NULL,
  CONSTRAINT [event_seasons_pk] PRIMARY KEY ([event], [season])
);

CREATE INDEX [event_seasons_idx_event] ON [event_seasons] ([event]);

CREATE INDEX [event_seasons_idx_organiser] ON [event_seasons] ([organiser]);

CREATE INDEX [event_seasons_idx_season] ON [event_seasons] ([season]);

CREATE INDEX [event_seasons_idx_venue] ON [event_seasons] ([venue]);


--
-- Table: [events]
--
CREATE TABLE [events] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(300) NOT NULL,
  [event_type] varchar(20) NOT NULL,
  [description] longtext NULL,
  CONSTRAINT [events_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE INDEX [events_idx_event_type] ON [events] ([event_type]);


--
-- Table: [fixtures_grid_matches]
--
CREATE TABLE [fixtures_grid_matches] (
  [grid] integer NOT NULL,
  [week] tinyint NOT NULL,
  [match_number] tinyint NOT NULL,
  [home_team] tinyint NULL,
  [away_team] tinyint NULL,
  CONSTRAINT [fixtures_grid_matches_pk] PRIMARY KEY ([grid], [week], [match_number])
);

CREATE INDEX [fixtures_grid_matches_idx_grid_week] ON [fixtures_grid_matches] ([grid], [week]);


--
-- Table: [fixtures_grid_weeks]
--
CREATE TABLE [fixtures_grid_weeks] (
  [grid] integer NOT NULL,
  [week] tinyint NOT NULL,
  CONSTRAINT [fixtures_grid_weeks_pk] PRIMARY KEY ([grid], [week])
);

CREATE INDEX [fixtures_grid_weeks_idx_grid] ON [fixtures_grid_weeks] ([grid]);


--
-- Table: [fixtures_grids]
--
CREATE TABLE [fixtures_grids] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(45) NOT NULL,
  [maximum_teams] tinyint NOT NULL,
  [fixtures_repeated] tinyint NOT NULL,
  CONSTRAINT [fixtures_grids_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [fixtures_season_weeks]
--
CREATE TABLE [fixtures_season_weeks] (
  [grid] integer NOT NULL,
  [grid_week] tinyint NOT NULL,
  [fixtures_week] integer NOT NULL,
  CONSTRAINT [fixtures_season_weeks_pk] PRIMARY KEY ([grid], [grid_week], [fixtures_week])
);

CREATE INDEX [fixtures_season_weeks_idx_grid_grid_week] ON [fixtures_season_weeks] ([grid], [grid_week]);

CREATE INDEX [fixtures_season_weeks_idx_fixtures_week] ON [fixtures_season_weeks] ([fixtures_week]);


--
-- Table: [fixtures_weeks]
--
CREATE TABLE [fixtures_weeks] (
  [id] integer IDENTITY NOT NULL,
  [season] integer NOT NULL,
  [week_beginning_date] datetime NOT NULL,
  CONSTRAINT [fixtures_weeks_pk] PRIMARY KEY ([id])
);

CREATE INDEX [fixtures_weeks_idx_season] ON [fixtures_weeks] ([season]);


--
-- Table: [individual_matches]
--
CREATE TABLE [individual_matches] (
  [id] integer IDENTITY NOT NULL,
  [home_player] integer NULL,
  [away_player] integer NULL,
  [individual_match_template] integer NOT NULL,
  [home_doubles_pair] integer NULL,
  [away_doubles_pair] integer NULL,
  [home_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [away_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [home_team_points_won] smallint NOT NULL DEFAULT '0',
  [away_team_points_won] smallint NOT NULL DEFAULT '0',
  [doubles_game] tinyint NOT NULL DEFAULT '0',
  [umpire] integer NULL,
  [started] tinyint NULL DEFAULT '0',
  [complete] tinyint NULL DEFAULT '0',
  [awarded] tinyint NULL,
  [void] tinyint NULL,
  [winner] integer NULL,
  CONSTRAINT [individual_matches_pk] PRIMARY KEY ([id])
);

CREATE INDEX [individual_matches_idx_away_player] ON [individual_matches] ([away_player]);

CREATE INDEX [individual_matches_idx_home_player] ON [individual_matches] ([home_player]);

CREATE INDEX [individual_matches_idx_individual_match_template] ON [individual_matches] ([individual_match_template]);


--
-- Table: [invalid_logins]
--
CREATE TABLE [invalid_logins] (
  [ip_address] varchar(40) NOT NULL,
  [invalid_logins] smallint NOT NULL,
  [last_invalid_login] datetime NOT NULL,
  CONSTRAINT [invalid_logins_pk] PRIMARY KEY ([ip_address])
);


--
-- Table: [lookup_event_types]
--
CREATE TABLE [lookup_event_types] (
  [id] varchar(20) NOT NULL,
  [display_order] tinyint NOT NULL,
  CONSTRAINT [lookup_event_types_pk] PRIMARY KEY ([id]),
  CONSTRAINT [display_order] UNIQUE ([display_order])
);


--
-- Table: [lookup_game_types]
--
CREATE TABLE [lookup_game_types] (
  [id] varchar(20) NOT NULL,
  CONSTRAINT [lookup_game_types_pk] PRIMARY KEY ([id])
);


--
-- Table: [lookup_gender]
--
CREATE TABLE [lookup_gender] (
  [id] varchar(20) NOT NULL DEFAULT '',
  CONSTRAINT [lookup_gender_pk] PRIMARY KEY ([id])
);


--
-- Table: [lookup_locations]
--
CREATE TABLE [lookup_locations] (
  [id] varchar(10) NOT NULL,
  [location] varchar(20) NOT NULL DEFAULT '',
  CONSTRAINT [lookup_locations_pk] PRIMARY KEY ([id]),
  CONSTRAINT [location] UNIQUE ([location])
);


--
-- Table: [lookup_serve_types]
--
CREATE TABLE [lookup_serve_types] (
  [id] varchar(20) NOT NULL,
  CONSTRAINT [lookup_serve_types_pk] PRIMARY KEY ([id])
);


--
-- Table: [lookup_team_membership_types]
--
CREATE TABLE [lookup_team_membership_types] (
  [id] varchar(20) NOT NULL,
  [display_order] tinyint NOT NULL,
  CONSTRAINT [lookup_team_membership_types_pk] PRIMARY KEY ([id])
);


--
-- Table: [lookup_tournament_types]
--
CREATE TABLE [lookup_tournament_types] (
  [id] varchar(20) NOT NULL,
  [display_order] tinyint NOT NULL,
  [allowed_in_single_tournament_events] tinyint NOT NULL,
  [allowed_in_multi_tournament_events] tinyint NOT NULL,
  CONSTRAINT [lookup_tournament_types_pk] PRIMARY KEY ([id]),
  CONSTRAINT [display_order] UNIQUE ([display_order])
);


--
-- Table: [lookup_weekdays]
--
CREATE TABLE [lookup_weekdays] (
  [weekday_number] tinyint NOT NULL DEFAULT '0',
  [weekday_name] varchar(20) NULL,
  CONSTRAINT [lookup_weekdays_pk] PRIMARY KEY ([weekday_number])
);

CREATE UNIQUE NONCLUSTERED INDEX [weekday_name] ON [lookup_weekdays] ([weekday_name]) WHERE [weekday_name] IS NOT NULL;


--
-- Table: [lookup_winner_types]
--
CREATE TABLE [lookup_winner_types] (
  [id] varchar(10) NOT NULL,
  CONSTRAINT [lookup_winner_types_pk] PRIMARY KEY ([id])
);


--
-- Table: [meeting_attendees]
--
CREATE TABLE [meeting_attendees] (
  [meeting] integer NOT NULL,
  [person] integer NOT NULL,
  [apologies] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [meeting_attendees_pk] PRIMARY KEY ([meeting], [person])
);

CREATE INDEX [meeting_attendees_idx_meeting] ON [meeting_attendees] ([meeting]);

CREATE INDEX [meeting_attendees_idx_person] ON [meeting_attendees] ([person]);


--
-- Table: [meeting_types]
--
CREATE TABLE [meeting_types] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(45) NOT NULL,
  CONSTRAINT [meeting_types_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [meetings]
--
CREATE TABLE [meetings] (
  [id] integer IDENTITY NOT NULL,
  [event] integer NULL,
  [season] integer NULL,
  [type] integer NULL,
  [organiser] integer NULL,
  [venue] integer NULL,
  [date_and_start_time] datetime NULL,
  [all_day] tinyint NULL,
  [finish_time] datetime NULL,
  [agenda] longtext NULL,
  [minutes] longtext NULL,
  CONSTRAINT [meetings_pk] PRIMARY KEY ([id])
);

CREATE INDEX [meetings_idx_event_season] ON [meetings] ([event], [season]);

CREATE INDEX [meetings_idx_organiser] ON [meetings] ([organiser]);

CREATE INDEX [meetings_idx_type] ON [meetings] ([type]);

CREATE INDEX [meetings_idx_venue] ON [meetings] ([venue]);


--
-- Table: [news_articles]
--
CREATE TABLE [news_articles] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NULL,
  [published_year] year NULL,
  [published_month] tinyint NULL,
  [updated_by_user] integer NOT NULL,
  [ip_address] varchar(45) NOT NULL,
  [date_updated] datetime NOT NULL,
  [headline] varchar(500) NOT NULL,
  [article_content] longtext NOT NULL,
  [original_article] integer NULL,
  CONSTRAINT [news_articles_pk] PRIMARY KEY ([id])
);

CREATE UNIQUE NONCLUSTERED INDEX [url_key] ON [news_articles] ([url_key], [published_year], [published_month]) WHERE [url_key] IS NOT NULL AND [published_year] IS NOT NULL AND [published_month] IS NOT NULL;

CREATE INDEX [news_articles_idx_original_article] ON [news_articles] ([original_article]);

CREATE INDEX [news_articles_idx_updated_by_user] ON [news_articles] ([updated_by_user]);


--
-- Table: [officials]
--
CREATE TABLE [officials] (
  [id] integer IDENTITY NOT NULL,
  [position] varchar(150) NOT NULL,
  [position_order] tinyint NOT NULL,
  [position_holder] integer NOT NULL,
  [season] integer NOT NULL,
  CONSTRAINT [officials_pk] PRIMARY KEY ([id])
);

CREATE INDEX [officials_idx_position_holder] ON [officials] ([position_holder]);

CREATE INDEX [officials_idx_season] ON [officials] ([season]);


--
-- Table: [page_text]
--
CREATE TABLE [page_text] (
  [page_key] varchar(50) NOT NULL,
  [page_text] longtext NOT NULL,
  [last_updated] datetime NOT NULL,
  CONSTRAINT [page_text_pk] PRIMARY KEY ([page_key])
);


--
-- Table: [people]
--
CREATE TABLE [people] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [first_name] varchar(150) NOT NULL,
  [surname] varchar(150) NOT NULL,
  [display_name] varchar(301) NOT NULL,
  [date_of_birth] datetime NULL,
  [gender] varchar(20) NULL,
  [address1] varchar(150) NULL,
  [address2] varchar(150) NULL,
  [address3] varchar(150) NULL,
  [address4] varchar(150) NULL,
  [address5] varchar(150) NULL,
  [postcode] varchar(8) NULL,
  [home_telephone] varchar(25) NULL,
  [work_telephone] varchar(25) NULL,
  [mobile_telephone] varchar(25) NULL,
  [email_address] varchar(254) NULL,
  CONSTRAINT [people_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE INDEX [people_idx_gender] ON [people] ([gender]);


--
-- Table: [person_seasons]
--
CREATE TABLE [person_seasons] (
  [person] integer NOT NULL,
  [season] integer NOT NULL,
  [team] integer NOT NULL,
  [first_name] varchar(150) NOT NULL,
  [surname] varchar(150) NOT NULL,
  [display_name] varchar(301) NOT NULL,
  [registration_date] datetime NULL,
  [fees_paid] tinyint NOT NULL DEFAULT '0',
  [matches_played] tinyint NOT NULL DEFAULT '0',
  [matches_won] tinyint NOT NULL DEFAULT '0',
  [matches_drawn] tinyint NOT NULL DEFAULT '0',
  [matches_lost] tinyint NOT NULL DEFAULT '0',
  [games_played] tinyint NOT NULL DEFAULT '0',
  [games_won] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [games_lost] tinyint NOT NULL DEFAULT '0',
  [average_game_wins] float NOT NULL DEFAULT '0',
  [legs_played] smallint NOT NULL DEFAULT '0',
  [legs_won] smallint NOT NULL DEFAULT '0',
  [legs_lost] smallint NOT NULL DEFAULT '0',
  [average_leg_wins] float NOT NULL DEFAULT '0',
  [points_played] integer NOT NULL DEFAULT '0',
  [points_won] integer NOT NULL DEFAULT '0',
  [points_lost] integer NOT NULL DEFAULT '0',
  [average_point_wins] float NOT NULL DEFAULT '0',
  [doubles_games_played] tinyint NOT NULL DEFAULT '0',
  [doubles_games_won] tinyint NOT NULL DEFAULT '0',
  [doubles_games_drawn] tinyint NOT NULL DEFAULT '0',
  [doubles_games_lost] tinyint NOT NULL DEFAULT '0',
  [doubles_average_game_wins] float NOT NULL DEFAULT '0',
  [doubles_legs_played] smallint NOT NULL DEFAULT '0',
  [doubles_legs_won] smallint NOT NULL DEFAULT '0',
  [doubles_legs_lost] smallint NOT NULL DEFAULT '0',
  [doubles_average_leg_wins] float NOT NULL DEFAULT '0',
  [doubles_points_played] integer NOT NULL DEFAULT '0',
  [doubles_points_won] integer NOT NULL DEFAULT '0',
  [doubles_points_lost] integer NOT NULL DEFAULT '0',
  [doubles_average_point_wins] float NOT NULL DEFAULT '0',
  [team_membership_type] varchar(20) NOT NULL DEFAULT 'active',
  [last_updated] datetime NOT NULL,
  CONSTRAINT [person_seasons_pk] PRIMARY KEY ([person], [season], [team])
);

CREATE INDEX [person_seasons_idx_person] ON [person_seasons] ([person]);

CREATE INDEX [person_seasons_idx_season] ON [person_seasons] ([season]);

CREATE INDEX [person_seasons_idx_team] ON [person_seasons] ([team]);

CREATE INDEX [person_seasons_idx_team_membership_type] ON [person_seasons] ([team_membership_type]);


--
-- Table: [person_tournaments]
--
CREATE TABLE [person_tournaments] (
  [id] integer IDENTITY NOT NULL,
  [tournament] integer NOT NULL,
  [season] integer NOT NULL,
  [person1] integer NOT NULL,
  [person2] integer NOT NULL,
  [team] integer NULL,
  [first_name] varchar(150) NOT NULL,
  [surname] varchar(150) NOT NULL,
  [display_name] varchar(301) NOT NULL,
  [registration_date] datetime NULL,
  [fees_paid] tinyint NOT NULL DEFAULT '0',
  [matches_played] tinyint NOT NULL DEFAULT '0',
  [matches_won] tinyint NOT NULL DEFAULT '0',
  [matches_drawn] tinyint NOT NULL DEFAULT '0',
  [matches_lost] tinyint NOT NULL DEFAULT '0',
  [games_played] tinyint NOT NULL DEFAULT '0',
  [games_won] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [games_lost] tinyint NOT NULL DEFAULT '0',
  [average_game_wins] float NOT NULL DEFAULT '0',
  [legs_played] smallint NOT NULL DEFAULT '0',
  [legs_won] smallint NOT NULL DEFAULT '0',
  [legs_lost] smallint NOT NULL DEFAULT '0',
  [average_leg_wins] float NOT NULL DEFAULT '0',
  [points_played] integer NOT NULL DEFAULT '0',
  [points_won] integer NOT NULL DEFAULT '0',
  [points_lost] integer NOT NULL DEFAULT '0',
  [average_point_wins] float NOT NULL DEFAULT '0',
  [team_membership_type] varchar(20) NOT NULL DEFAULT 'active',
  [last_updated] datetime NOT NULL,
  CONSTRAINT [person_tournaments_pk] PRIMARY KEY ([id])
);

CREATE INDEX [person_tournaments_idx_person1] ON [person_tournaments] ([person1]);

CREATE INDEX [person_tournaments_idx_person2] ON [person_tournaments] ([person2]);

CREATE INDEX [person_tournaments_idx_team] ON [person_tournaments] ([team]);


--
-- Table: [roles]
--
CREATE TABLE [roles] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(100) NOT NULL,
  [system] tinyint NOT NULL DEFAULT '0',
  [sysadmin] tinyint NOT NULL DEFAULT '0',
  [anonymous] tinyint NOT NULL DEFAULT '0',
  [apply_on_registration] tinyint NOT NULL DEFAULT '0',
  [average_filter_create_public] tinyint NOT NULL DEFAULT '0',
  [average_filter_edit_public] tinyint NOT NULL DEFAULT '0',
  [average_filter_delete_public] tinyint NOT NULL DEFAULT '0',
  [average_filter_view_all] tinyint NOT NULL DEFAULT '0',
  [average_filter_edit_all] tinyint NOT NULL DEFAULT '0',
  [average_filter_delete_all] tinyint NOT NULL DEFAULT '0',
  [club_view] tinyint NOT NULL DEFAULT '0',
  [club_create] tinyint NOT NULL DEFAULT '0',
  [club_edit] tinyint NOT NULL DEFAULT '0',
  [club_delete] tinyint NOT NULL DEFAULT '0',
  [committee_view] tinyint NOT NULL DEFAULT '0',
  [committee_create] tinyint NOT NULL DEFAULT '0',
  [committee_edit] tinyint NOT NULL DEFAULT '0',
  [committee_delete] tinyint NOT NULL DEFAULT '0',
  [contact_reason_view] tinyint NOT NULL DEFAULT '0',
  [contact_reason_create] tinyint NOT NULL DEFAULT '0',
  [contact_reason_edit] tinyint NOT NULL DEFAULT '0',
  [contact_reason_delete] tinyint NOT NULL DEFAULT '0',
  [event_view] tinyint NOT NULL DEFAULT '0',
  [event_create] tinyint NOT NULL DEFAULT '0',
  [event_edit] tinyint NOT NULL DEFAULT '0',
  [event_delete] tinyint NOT NULL DEFAULT '0',
  [file_upload] tinyint NOT NULL DEFAULT '0',
  [fixtures_view] tinyint NOT NULL DEFAULT '0',
  [fixtures_create] tinyint NOT NULL DEFAULT '0',
  [fixtures_edit] tinyint NOT NULL DEFAULT '0',
  [fixtures_delete] tinyint NOT NULL DEFAULT '0',
  [image_upload] tinyint NOT NULL DEFAULT '0',
  [match_view] tinyint NOT NULL DEFAULT '0',
  [match_update] tinyint NOT NULL DEFAULT '0',
  [match_cancel] tinyint NOT NULL DEFAULT '0',
  [match_report_create] tinyint NOT NULL DEFAULT '0',
  [match_report_create_associated] tinyint NOT NULL DEFAULT '0',
  [match_report_edit_own] tinyint NOT NULL DEFAULT '0',
  [match_report_edit_all] tinyint NOT NULL DEFAULT '0',
  [match_report_delete_own] tinyint NOT NULL DEFAULT '0',
  [match_report_delete_all] tinyint NOT NULL DEFAULT '0',
  [meeting_view] tinyint NOT NULL DEFAULT '0',
  [meeting_create] tinyint NOT NULL DEFAULT '0',
  [meeting_edit] tinyint NOT NULL DEFAULT '0',
  [meeting_delete] tinyint NOT NULL DEFAULT '0',
  [meeting_type_view] tinyint NOT NULL DEFAULT '0',
  [meeting_type_create] tinyint NOT NULL DEFAULT '0',
  [meeting_type_edit] tinyint NOT NULL DEFAULT '0',
  [meeting_type_delete] tinyint NOT NULL DEFAULT '0',
  [news_article_view] tinyint NOT NULL DEFAULT '0',
  [news_article_create] tinyint NOT NULL DEFAULT '0',
  [news_article_edit_own] tinyint NOT NULL DEFAULT '0',
  [news_article_edit_all] tinyint NOT NULL DEFAULT '0',
  [news_article_delete_own] tinyint NOT NULL DEFAULT '0',
  [news_article_delete_all] tinyint NOT NULL DEFAULT '0',
  [online_users_view] tinyint NOT NULL DEFAULT '0',
  [anonymous_online_users_view] tinyint NOT NULL DEFAULT '0',
  [view_users_ip] tinyint NOT NULL DEFAULT '0',
  [view_users_user_agent] tinyint NOT NULL DEFAULT '0',
  [person_view] tinyint NOT NULL DEFAULT '0',
  [person_create] tinyint NOT NULL DEFAULT '0',
  [person_contact_view] tinyint NOT NULL DEFAULT '0',
  [person_edit] tinyint NOT NULL DEFAULT '0',
  [person_delete] tinyint NOT NULL DEFAULT '0',
  [privacy_view] tinyint NOT NULL DEFAULT '0',
  [privacy_edit] tinyint NOT NULL DEFAULT '0',
  [role_view] tinyint NOT NULL DEFAULT '0',
  [role_create] tinyint NOT NULL DEFAULT '0',
  [role_edit] tinyint NOT NULL DEFAULT '0',
  [role_delete] tinyint NOT NULL DEFAULT '0',
  [season_view] tinyint NOT NULL DEFAULT '0',
  [season_create] tinyint NOT NULL DEFAULT '0',
  [season_edit] tinyint NOT NULL DEFAULT '0',
  [season_delete] tinyint NOT NULL DEFAULT '0',
  [season_archive] tinyint NOT NULL DEFAULT '0',
  [session_delete] tinyint NOT NULL DEFAULT '0',
  [system_event_log_view_all] tinyint NOT NULL DEFAULT '0',
  [team_view] tinyint NOT NULL DEFAULT '0',
  [team_create] tinyint NOT NULL DEFAULT '0',
  [team_edit] tinyint NOT NULL DEFAULT '0',
  [team_delete] tinyint NOT NULL DEFAULT '0',
  [template_view] tinyint NOT NULL DEFAULT '0',
  [template_create] tinyint NOT NULL DEFAULT '0',
  [template_edit] tinyint NOT NULL DEFAULT '0',
  [template_delete] tinyint NOT NULL DEFAULT '0',
  [tournament_view] tinyint NOT NULL DEFAULT '0',
  [tournament_create] tinyint NOT NULL DEFAULT '0',
  [tournament_edit] tinyint NOT NULL DEFAULT '0',
  [tournament_delete] tinyint NOT NULL DEFAULT '0',
  [user_view] tinyint NOT NULL DEFAULT '0',
  [user_edit_all] tinyint NOT NULL DEFAULT '0',
  [user_edit_own] tinyint NOT NULL DEFAULT '0',
  [user_delete_all] tinyint NOT NULL DEFAULT '0',
  [user_delete_own] tinyint NOT NULL DEFAULT '0',
  [venue_view] tinyint NOT NULL DEFAULT '0',
  [venue_create] tinyint NOT NULL DEFAULT '0',
  [venue_edit] tinyint NOT NULL DEFAULT '0',
  [venue_delete] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [roles_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [seasons]
--
CREATE TABLE [seasons] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(30) NOT NULL,
  [name] varchar(150) NOT NULL,
  [default_match_start] datetime NOT NULL,
  [timezone] varchar(50) NOT NULL,
  [start_date] datetime NOT NULL,
  [end_date] datetime NOT NULL,
  [complete] tinyint NOT NULL DEFAULT '0',
  [allow_loan_players_below] tinyint NOT NULL DEFAULT '0',
  [allow_loan_players_above] tinyint NOT NULL DEFAULT '0',
  [allow_loan_players_across] tinyint NOT NULL DEFAULT '0',
  [allow_loan_players_multiple_teams_per_division] tinyint NOT NULL DEFAULT '0',
  [allow_loan_players_same_club_only] tinyint NOT NULL DEFAULT '0',
  [loan_players_limit_per_player] tinyint NOT NULL DEFAULT '0',
  [loan_players_limit_per_player_per_team] tinyint NOT NULL DEFAULT '0',
  [loan_players_limit_per_team] tinyint NOT NULL DEFAULT '0',
  [rules] longtext NULL,
  CONSTRAINT [seasons_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [sessions]
--
CREATE TABLE [sessions] (
  [id] char(72) NOT NULL,
  [data] mediumtext NULL,
  [expires] integer NULL,
  [user] integer NULL,
  [ip_address] varchar(40) NULL,
  [client_hostname] text NULL,
  [user_agent] integer NULL,
  [secure] tinyint NULL,
  [locale] varchar(6) NULL,
  [path] varchar(255) NULL,
  [query_string] text NULL,
  [referrer] text NULL,
  [view_online_display] varchar(300) NULL,
  [view_online_link] tinyint NULL,
  [hide_online] tinyint NULL,
  [last_active] datetime NOT NULL,
  [invalid_logins] smallint NOT NULL DEFAULT '0',
  [last_invalid_login] datetime NULL,
  CONSTRAINT [sessions_pk] PRIMARY KEY ([id])
);

CREATE INDEX [sessions_idx_user] ON [sessions] ([user]);

CREATE INDEX [sessions_idx_user_agent] ON [sessions] ([user_agent]);


--
-- Table: [system_event_log]
--
CREATE TABLE [system_event_log] (
  [id] integer IDENTITY NOT NULL,
  [object_type] varchar(40) NOT NULL,
  [event_type] varchar(20) NOT NULL,
  [user_id] integer NULL,
  [ip_address] varchar(40) NOT NULL,
  [log_created] datetime NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] integer NOT NULL,
  CONSTRAINT [system_event_log_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_idx_object_type_event_type] ON [system_event_log] ([object_type], [event_type]);

CREATE INDEX [system_event_log_idx_user_id] ON [system_event_log] ([user_id]);


--
-- Table: [system_event_log_average_filters]
--
CREATE TABLE [system_event_log_average_filters] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_average_filters_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_average_filters_idx_object_id] ON [system_event_log_average_filters] ([object_id]);

CREATE INDEX [system_event_log_average_filters_idx_system_event_log_id] ON [system_event_log_average_filters] ([system_event_log_id]);


--
-- Table: [system_event_log_club]
--
CREATE TABLE [system_event_log_club] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_club_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_club_idx_object_id] ON [system_event_log_club] ([object_id]);

CREATE INDEX [system_event_log_club_idx_system_event_log_id] ON [system_event_log_club] ([system_event_log_id]);


--
-- Table: [system_event_log_contact_reason]
--
CREATE TABLE [system_event_log_contact_reason] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_contact_reason_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_contact_reason_idx_object_id] ON [system_event_log_contact_reason] ([object_id]);

CREATE INDEX [system_event_log_contact_reason_idx_system_event_log_id] ON [system_event_log_contact_reason] ([system_event_log_id]);


--
-- Table: [system_event_log_division]
--
CREATE TABLE [system_event_log_division] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_division_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_division_idx_object_id] ON [system_event_log_division] ([object_id]);

CREATE INDEX [system_event_log_division_idx_system_event_log_id] ON [system_event_log_division] ([system_event_log_id]);


--
-- Table: [system_event_log_event]
--
CREATE TABLE [system_event_log_event] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_event_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_event_idx_object_id] ON [system_event_log_event] ([object_id]);

CREATE INDEX [system_event_log_event_idx_system_event_log_id] ON [system_event_log_event] ([system_event_log_id]);


--
-- Table: [system_event_log_file]
--
CREATE TABLE [system_event_log_file] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL DEFAULT '0',
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_file_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_file_idx_object_id] ON [system_event_log_file] ([object_id]);

CREATE INDEX [system_event_log_file_idx_system_event_log_id] ON [system_event_log_file] ([system_event_log_id]);


--
-- Table: [system_event_log_fixtures_grid]
--
CREATE TABLE [system_event_log_fixtures_grid] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_fixtures_grid_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_fixtures_grid_idx_object_id] ON [system_event_log_fixtures_grid] ([object_id]);

CREATE INDEX [system_event_log_fixtures_grid_idx_system_event_log_id] ON [system_event_log_fixtures_grid] ([system_event_log_id]);


--
-- Table: [system_event_log_image]
--
CREATE TABLE [system_event_log_image] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_image_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_image_idx_object_id] ON [system_event_log_image] ([object_id]);

CREATE INDEX [system_event_log_image_idx_system_event_log_id] ON [system_event_log_image] ([system_event_log_id]);


--
-- Table: [system_event_log_meeting]
--
CREATE TABLE [system_event_log_meeting] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_meeting_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_meeting_idx_object_id] ON [system_event_log_meeting] ([object_id]);

CREATE INDEX [system_event_log_meeting_idx_system_event_log_id] ON [system_event_log_meeting] ([system_event_log_id]);


--
-- Table: [system_event_log_meeting_type]
--
CREATE TABLE [system_event_log_meeting_type] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_meeting_type_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_meeting_type_idx_object_id] ON [system_event_log_meeting_type] ([object_id]);

CREATE INDEX [system_event_log_meeting_type_idx_system_event_log_id] ON [system_event_log_meeting_type] ([system_event_log_id]);


--
-- Table: [system_event_log_news]
--
CREATE TABLE [system_event_log_news] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_news_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_news_idx_object_id] ON [system_event_log_news] ([object_id]);

CREATE INDEX [system_event_log_news_idx_system_event_log_id] ON [system_event_log_news] ([system_event_log_id]);


--
-- Table: [system_event_log_person]
--
CREATE TABLE [system_event_log_person] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_person_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_person_idx_object_id] ON [system_event_log_person] ([object_id]);

CREATE INDEX [system_event_log_person_idx_system_event_log_id] ON [system_event_log_person] ([system_event_log_id]);


--
-- Table: [system_event_log_role]
--
CREATE TABLE [system_event_log_role] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_role_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_role_idx_object_id] ON [system_event_log_role] ([object_id]);

CREATE INDEX [system_event_log_role_idx_system_event_log_id] ON [system_event_log_role] ([system_event_log_id]);


--
-- Table: [system_event_log_season]
--
CREATE TABLE [system_event_log_season] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_season_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_season_idx_object_id] ON [system_event_log_season] ([object_id]);

CREATE INDEX [system_event_log_season_idx_system_event_log_id] ON [system_event_log_season] ([system_event_log_id]);


--
-- Table: [system_event_log_team]
--
CREATE TABLE [system_event_log_team] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_team_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_team_idx_object_id] ON [system_event_log_team] ([object_id]);

CREATE INDEX [system_event_log_team_idx_system_event_log_id] ON [system_event_log_team] ([system_event_log_id]);


--
-- Table: [system_event_log_team_match]
--
CREATE TABLE [system_event_log_team_match] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_home_team] integer NULL,
  [object_away_team] integer NULL,
  [object_scheduled_date] datetime NULL,
  [name] varchar(620) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_team_match_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_team_match_idx_system_event_log_id] ON [system_event_log_team_match] ([system_event_log_id]);

CREATE INDEX [system_event_log_team_match_idx_object_home_team_object_away_team_object_scheduled_date] ON [system_event_log_team_match] ([object_home_team], [object_away_team], [object_scheduled_date]);


--
-- Table: [system_event_log_template_league_table_ranking]
--
CREATE TABLE [system_event_log_template_league_table_ranking] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_template_league_table_ranking_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_template_league_table_ranking_idx_object_id] ON [system_event_log_template_league_table_ranking] ([object_id]);

CREATE INDEX [system_event_log_template_league_table_ranking_idx_system_event_log_id] ON [system_event_log_template_league_table_ranking] ([system_event_log_id]);


--
-- Table: [system_event_log_template_match_individual]
--
CREATE TABLE [system_event_log_template_match_individual] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_template_match_individual_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_template_match_individual_idx_object_id] ON [system_event_log_template_match_individual] ([object_id]);

CREATE INDEX [system_event_log_template_match_individual_idx_system_event_log_id] ON [system_event_log_template_match_individual] ([system_event_log_id]);


--
-- Table: [system_event_log_template_match_team]
--
CREATE TABLE [system_event_log_template_match_team] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_template_match_team_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_template_match_team_idx_object_id] ON [system_event_log_template_match_team] ([object_id]);

CREATE INDEX [system_event_log_template_match_team_idx_system_event_log_id] ON [system_event_log_template_match_team] ([system_event_log_id]);


--
-- Table: [system_event_log_template_match_team_game]
--
CREATE TABLE [system_event_log_template_match_team_game] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_template_match_team_game_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_template_match_team_game_idx_object_id] ON [system_event_log_template_match_team_game] ([object_id]);

CREATE INDEX [system_event_log_template_match_team_game_idx_system_event_log_id] ON [system_event_log_template_match_team_game] ([system_event_log_id]);


--
-- Table: [system_event_log_types]
--
CREATE TABLE [system_event_log_types] (
  [object_type] varchar(40) NOT NULL,
  [event_type] varchar(40) NOT NULL,
  [object_description] varchar(40) NOT NULL,
  [description] varchar(500) NOT NULL,
  [view_action_for_uri] varchar(500) NULL,
  [plural_objects] varchar(50) NOT NULL,
  [public_event] tinyint NOT NULL,
  CONSTRAINT [system_event_log_types_pk] PRIMARY KEY ([object_type], [event_type])
);


--
-- Table: [system_event_log_user]
--
CREATE TABLE [system_event_log_user] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_user_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_user_idx_object_id] ON [system_event_log_user] ([object_id]);

CREATE INDEX [system_event_log_user_idx_system_event_log_id] ON [system_event_log_user] ([system_event_log_id]);


--
-- Table: [system_event_log_venue]
--
CREATE TABLE [system_event_log_venue] (
  [id] integer IDENTITY NOT NULL,
  [system_event_log_id] integer NOT NULL,
  [object_id] integer NULL,
  [name] varchar(300) NOT NULL,
  [log_updated] datetime NOT NULL,
  [number_of_edits] tinyint NOT NULL,
  CONSTRAINT [system_event_log_venue_pk] PRIMARY KEY ([id])
);

CREATE INDEX [system_event_log_venue_idx_object_id] ON [system_event_log_venue] ([object_id]);

CREATE INDEX [system_event_log_venue_idx_system_event_log_id] ON [system_event_log_venue] ([system_event_log_id]);


--
-- Table: [team_match_games]
--
CREATE TABLE [team_match_games] (
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [scheduled_game_number] tinyint NOT NULL,
  [individual_match_template] integer NOT NULL,
  [actual_game_number] tinyint NOT NULL,
  [home_player] integer NULL,
  [home_player_number] tinyint NULL,
  [away_player] integer NULL,
  [away_player_number] tinyint NULL,
  [home_doubles_pair] integer NULL,
  [away_doubles_pair] integer NULL,
  [home_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [away_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [home_team_points_won] smallint NOT NULL DEFAULT '0',
  [away_team_points_won] smallint NOT NULL DEFAULT '0',
  [home_team_match_score] tinyint NOT NULL DEFAULT '0',
  [away_team_match_score] tinyint NOT NULL DEFAULT '0',
  [doubles_game] tinyint NOT NULL DEFAULT '0',
  [game_in_progress] tinyint NOT NULL DEFAULT '0',
  [umpire] integer NULL,
  [started] tinyint NULL DEFAULT '0',
  [complete] tinyint NULL DEFAULT '0',
  [awarded] tinyint NULL,
  [void] tinyint NULL,
  [winner] integer NULL,
  CONSTRAINT [team_match_games_pk] PRIMARY KEY ([home_team], [away_team], [scheduled_date], [scheduled_game_number])
);

CREATE INDEX [team_match_games_idx_away_doubles_pair] ON [team_match_games] ([away_doubles_pair]);

CREATE INDEX [team_match_games_idx_away_player] ON [team_match_games] ([away_player]);

CREATE INDEX [team_match_games_idx_home_doubles_pair] ON [team_match_games] ([home_doubles_pair]);

CREATE INDEX [team_match_games_idx_home_player] ON [team_match_games] ([home_player]);

CREATE INDEX [team_match_games_idx_individual_match_template] ON [team_match_games] ([individual_match_template]);

CREATE INDEX [team_match_games_idx_home_team_away_team_scheduled_date] ON [team_match_games] ([home_team], [away_team], [scheduled_date]);

CREATE INDEX [team_match_games_idx_umpire] ON [team_match_games] ([umpire]);

CREATE INDEX [team_match_games_idx_winner] ON [team_match_games] ([winner]);


--
-- Table: [team_match_legs]
--
CREATE TABLE [team_match_legs] (
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [scheduled_game_number] tinyint NOT NULL,
  [leg_number] tinyint NOT NULL,
  [home_team_points_won] tinyint NOT NULL DEFAULT '0',
  [away_team_points_won] tinyint NOT NULL DEFAULT '0',
  [first_server] integer NULL,
  [leg_in_progress] tinyint NOT NULL DEFAULT '0',
  [next_point_server] integer NULL,
  [started] tinyint NOT NULL DEFAULT '0',
  [complete] tinyint NOT NULL DEFAULT '0',
  [awarded] tinyint NOT NULL DEFAULT '0',
  [void] tinyint NOT NULL DEFAULT '0',
  [winner] integer NULL,
  CONSTRAINT [team_match_legs_pk] PRIMARY KEY ([home_team], [away_team], [scheduled_date], [scheduled_game_number], [leg_number])
);

CREATE INDEX [team_match_legs_idx_first_server] ON [team_match_legs] ([first_server]);

CREATE INDEX [team_match_legs_idx_next_point_server] ON [team_match_legs] ([next_point_server]);

CREATE INDEX [team_match_legs_idx_home_team_away_team_scheduled_date_scheduled_game_number] ON [team_match_legs] ([home_team], [away_team], [scheduled_date], [scheduled_game_number]);

CREATE INDEX [team_match_legs_idx_winner] ON [team_match_legs] ([winner]);


--
-- Table: [team_match_players]
--
CREATE TABLE [team_match_players] (
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [player_number] tinyint NOT NULL,
  [location] varchar(10) NOT NULL,
  [player] integer NULL,
  [player_missing] tinyint NOT NULL DEFAULT '0',
  [loan_team] integer NULL,
  [games_played] tinyint NOT NULL DEFAULT '0',
  [games_won] tinyint NOT NULL DEFAULT '0',
  [games_lost] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [legs_played] tinyint NOT NULL DEFAULT '0',
  [legs_won] tinyint NOT NULL DEFAULT '0',
  [legs_lost] tinyint NOT NULL DEFAULT '0',
  [average_leg_wins] float NOT NULL DEFAULT '0',
  [points_played] smallint NOT NULL DEFAULT '0',
  [points_won] smallint NOT NULL DEFAULT '0',
  [points_lost] smallint NOT NULL DEFAULT '0',
  [average_point_wins] float NOT NULL DEFAULT '0',
  CONSTRAINT [team_match_players_pk] PRIMARY KEY ([home_team], [away_team], [scheduled_date], [player_number])
);

CREATE INDEX [team_match_players_idx_loan_team] ON [team_match_players] ([loan_team]);

CREATE INDEX [team_match_players_idx_location] ON [team_match_players] ([location]);

CREATE INDEX [team_match_players_idx_player] ON [team_match_players] ([player]);

CREATE INDEX [team_match_players_idx_home_team_away_team_scheduled_date] ON [team_match_players] ([home_team], [away_team], [scheduled_date]);


--
-- Table: [team_match_reports]
--
CREATE TABLE [team_match_reports] (
  [id] integer IDENTITY NOT NULL,
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [published] datetime NOT NULL,
  [author] integer NOT NULL,
  [report] longtext NULL,
  CONSTRAINT [team_match_reports_pk] PRIMARY KEY ([id])
);

CREATE INDEX [team_match_reports_idx_author] ON [team_match_reports] ([author]);

CREATE INDEX [team_match_reports_idx_home_team_away_team_scheduled_date] ON [team_match_reports] ([home_team], [away_team], [scheduled_date]);


--
-- Table: [team_matches]
--
CREATE TABLE [team_matches] (
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [scheduled_start_time] datetime NOT NULL,
  [season] integer NOT NULL,
  [tournament_round] integer NULL,
  [division] integer NOT NULL,
  [venue] integer NOT NULL,
  [scheduled_week] integer NOT NULL,
  [played_date] datetime NULL,
  [start_time] datetime NULL,
  [played_week] integer NULL,
  [team_match_template] integer NOT NULL,
  [started] tinyint NOT NULL DEFAULT '0',
  [updated_since] datetime NOT NULL,
  [home_team_games_won] tinyint NOT NULL DEFAULT '0',
  [home_team_games_lost] tinyint NOT NULL DEFAULT '0',
  [away_team_games_won] tinyint NOT NULL DEFAULT '0',
  [away_team_games_lost] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [home_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [home_team_average_leg_wins] float NOT NULL DEFAULT '0',
  [away_team_legs_won] tinyint NOT NULL DEFAULT '0',
  [away_team_average_leg_wins] float NOT NULL DEFAULT '0',
  [home_team_points_won] smallint NOT NULL DEFAULT '0',
  [home_team_average_point_wins] float NOT NULL DEFAULT '0',
  [away_team_points_won] smallint NOT NULL DEFAULT '0',
  [away_team_average_point_wins] float NOT NULL DEFAULT '0',
  [home_team_match_score] tinyint NOT NULL DEFAULT '0',
  [away_team_match_score] tinyint NOT NULL DEFAULT '0',
  [player_of_the_match] integer NULL,
  [fixtures_grid] integer NULL,
  [complete] tinyint NOT NULL DEFAULT '0',
  [league_official_verified] integer NULL,
  [home_team_verified] integer NULL,
  [away_team_verified] integer NULL,
  [cancelled] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [team_matches_pk] PRIMARY KEY ([home_team], [away_team], [scheduled_date])
);

CREATE INDEX [team_matches_idx_away_team] ON [team_matches] ([away_team]);

CREATE INDEX [team_matches_idx_away_team_verified] ON [team_matches] ([away_team_verified]);

CREATE INDEX [team_matches_idx_division] ON [team_matches] ([division]);

CREATE INDEX [team_matches_idx_fixtures_grid] ON [team_matches] ([fixtures_grid]);

CREATE INDEX [team_matches_idx_home_team] ON [team_matches] ([home_team]);

CREATE INDEX [team_matches_idx_home_team_verified] ON [team_matches] ([home_team_verified]);

CREATE INDEX [team_matches_idx_league_official_verified] ON [team_matches] ([league_official_verified]);

CREATE INDEX [team_matches_idx_played_week] ON [team_matches] ([played_week]);

CREATE INDEX [team_matches_idx_player_of_the_match] ON [team_matches] ([player_of_the_match]);

CREATE INDEX [team_matches_idx_scheduled_week] ON [team_matches] ([scheduled_week]);

CREATE INDEX [team_matches_idx_season] ON [team_matches] ([season]);

CREATE INDEX [team_matches_idx_team_match_template] ON [team_matches] ([team_match_template]);

CREATE INDEX [team_matches_idx_tournament_round] ON [team_matches] ([tournament_round]);

CREATE INDEX [team_matches_idx_venue] ON [team_matches] ([venue]);


--
-- Table: [team_seasons]
--
CREATE TABLE [team_seasons] (
  [team] integer NOT NULL,
  [season] integer NOT NULL,
  [name] varchar(150) NOT NULL,
  [club] integer NOT NULL,
  [division] integer NOT NULL,
  [captain] integer NULL,
  [matches_played] tinyint NOT NULL DEFAULT '0',
  [matches_won] tinyint NOT NULL DEFAULT '0',
  [matches_drawn] tinyint NOT NULL DEFAULT '0',
  [matches_lost] tinyint NOT NULL DEFAULT '0',
  [table_points] tinyint NULL DEFAULT '0',
  [games_played] tinyint NOT NULL DEFAULT '0',
  [games_won] tinyint NOT NULL DEFAULT '0',
  [games_drawn] tinyint NOT NULL DEFAULT '0',
  [games_lost] tinyint NOT NULL DEFAULT '0',
  [average_game_wins] float NOT NULL DEFAULT '0',
  [legs_played] smallint NOT NULL DEFAULT '0',
  [legs_won] smallint NOT NULL DEFAULT '0',
  [legs_lost] smallint NOT NULL DEFAULT '0',
  [average_leg_wins] float NOT NULL DEFAULT '0',
  [points_played] integer NOT NULL DEFAULT '0',
  [points_won] integer NOT NULL DEFAULT '0',
  [points_lost] integer NOT NULL DEFAULT '0',
  [average_point_wins] float NOT NULL DEFAULT '0',
  [doubles_games_played] tinyint NOT NULL DEFAULT '0',
  [doubles_games_won] tinyint NOT NULL DEFAULT '0',
  [doubles_games_drawn] tinyint NOT NULL DEFAULT '0',
  [doubles_games_lost] tinyint NOT NULL DEFAULT '0',
  [doubles_average_game_wins] float NOT NULL DEFAULT '0',
  [doubles_legs_played] smallint NOT NULL DEFAULT '0',
  [doubles_legs_won] smallint NOT NULL DEFAULT '0',
  [doubles_legs_lost] smallint NOT NULL DEFAULT '0',
  [doubles_average_leg_wins] float NOT NULL DEFAULT '0',
  [doubles_points_played] integer NOT NULL DEFAULT '0',
  [doubles_points_won] integer NOT NULL DEFAULT '0',
  [doubles_points_lost] integer NOT NULL DEFAULT '0',
  [doubles_average_point_wins] float NOT NULL DEFAULT '0',
  [home_night] tinyint NOT NULL DEFAULT '0',
  [grid_position] tinyint NULL DEFAULT '0',
  [last_updated] datetime NOT NULL,
  CONSTRAINT [team_seasons_pk] PRIMARY KEY ([team], [season])
);

CREATE INDEX [team_seasons_idx_captain] ON [team_seasons] ([captain]);

CREATE INDEX [team_seasons_idx_club] ON [team_seasons] ([club]);

CREATE INDEX [team_seasons_idx_division] ON [team_seasons] ([division]);

CREATE INDEX [team_seasons_idx_home_night] ON [team_seasons] ([home_night]);

CREATE INDEX [team_seasons_idx_season] ON [team_seasons] ([season]);

CREATE INDEX [team_seasons_idx_team] ON [team_seasons] ([team]);


--
-- Table: [team_seasons_intervals]
--
CREATE TABLE [team_seasons_intervals] (
  [team] integer NOT NULL,
  [season] integer NOT NULL,
  [week] integer NOT NULL,
  [division] integer NOT NULL,
  [league_table_points] smallint NOT NULL,
  [matches_played] tinyint NOT NULL,
  [matches_won] tinyint NOT NULL,
  [matches_lost] tinyint NOT NULL,
  [matches_drawn] tinyint NOT NULL,
  [games_played] tinyint NOT NULL,
  [games_won] tinyint NOT NULL,
  [games_lost] tinyint NOT NULL,
  [games_drawn] tinyint NOT NULL,
  [average_game_wins] float NOT NULL,
  [legs_played] tinyint NOT NULL,
  [legs_won] tinyint NOT NULL,
  [legs_lost] tinyint NOT NULL,
  [average_leg_wins] float NOT NULL,
  [points_played] integer NOT NULL,
  [points_won] integer NOT NULL,
  [points_lost] integer NOT NULL,
  [average_point_wins] float NOT NULL,
  [table_points] tinyint NULL DEFAULT '0',
  CONSTRAINT [team_seasons_intervals_pk] PRIMARY KEY ([team], [season], [week])
);

CREATE INDEX [team_seasons_intervals_idx_division] ON [team_seasons_intervals] ([division]);

CREATE INDEX [team_seasons_intervals_idx_season] ON [team_seasons_intervals] ([season]);

CREATE INDEX [team_seasons_intervals_idx_team] ON [team_seasons_intervals] ([team]);

CREATE INDEX [team_seasons_intervals_idx_week] ON [team_seasons_intervals] ([week]);


--
-- Table: [teams]
--
CREATE TABLE [teams] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(150) NOT NULL,
  [club] integer NOT NULL,
  [default_match_start] datetime NULL,
  CONSTRAINT [teams_pk] PRIMARY KEY ([id]),
  CONSTRAINT [name_club] UNIQUE ([name], [club]),
  CONSTRAINT [url_key_club] UNIQUE ([url_key], [club])
);

CREATE INDEX [teams_idx_club] ON [teams] ([club]);


--
-- Table: [template_league_table_ranking]
--
CREATE TABLE [template_league_table_ranking] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(30) NOT NULL,
  [name] varchar(300) NOT NULL,
  [assign_points] tinyint NULL,
  [points_per_win] tinyint NULL,
  [points_per_draw] tinyint NULL,
  [points_per_loss] tinyint NULL,
  CONSTRAINT [template_league_table_ranking_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [template_match_individual]
--
CREATE TABLE [template_match_individual] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(60) NOT NULL,
  [name] varchar(45) NOT NULL,
  [game_type] varchar(20) NOT NULL,
  [legs_per_game] tinyint NOT NULL,
  [minimum_points_win] tinyint NOT NULL,
  [clear_points_win] tinyint NOT NULL,
  [serve_type] varchar(20) NOT NULL,
  [serves] tinyint NULL,
  [serves_deuce] tinyint NULL,
  CONSTRAINT [template_match_individual_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE INDEX [template_match_individual_idx_game_type] ON [template_match_individual] ([game_type]);

CREATE INDEX [template_match_individual_idx_serve_type] ON [template_match_individual] ([serve_type]);


--
-- Table: [template_match_team]
--
CREATE TABLE [template_match_team] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(45) NOT NULL,
  [singles_players_per_team] tinyint NOT NULL,
  [winner_type] varchar(10) NOT NULL,
  CONSTRAINT [template_match_team_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE INDEX [template_match_team_idx_winner_type] ON [template_match_team] ([winner_type]);


--
-- Table: [template_match_team_games]
--
CREATE TABLE [template_match_team_games] (
  [id] integer IDENTITY NOT NULL,
  [team_match_template] integer NOT NULL,
  [individual_match_template] integer NULL,
  [match_game_number] tinyint NOT NULL,
  [doubles_game] tinyint NOT NULL,
  [singles_home_player_number] tinyint NULL,
  [singles_away_player_number] tinyint NULL,
  CONSTRAINT [template_match_team_games_pk] PRIMARY KEY ([id])
);

CREATE INDEX [template_match_team_games_idx_individual_match_template] ON [template_match_team_games] ([individual_match_template]);

CREATE INDEX [template_match_team_games_idx_team_match_template] ON [template_match_team_games] ([team_match_template]);


--
-- Table: [tournament_round_group_individual_membership]
--
CREATE TABLE [tournament_round_group_individual_membership] (
  [id] integer IDENTITY NOT NULL,
  [group] integer NOT NULL,
  [person1] integer NOT NULL,
  [person2] integer NULL,
  CONSTRAINT [tournament_round_group_individual_membership_pk] PRIMARY KEY ([id])
);

CREATE INDEX [tournament_round_group_individual_membership_idx_group] ON [tournament_round_group_individual_membership] ([group]);

CREATE INDEX [tournament_round_group_individual_membership_idx_person1] ON [tournament_round_group_individual_membership] ([person1]);

CREATE INDEX [tournament_round_group_individual_membership_idx_person2] ON [tournament_round_group_individual_membership] ([person2]);


--
-- Table: [tournament_round_group_team_membership]
--
CREATE TABLE [tournament_round_group_team_membership] (
  [id] integer IDENTITY NOT NULL,
  [group] integer NOT NULL,
  [team] integer NOT NULL,
  CONSTRAINT [tournament_round_group_team_membership_pk] PRIMARY KEY ([id])
);

CREATE INDEX [tournament_round_group_team_membership_idx_group] ON [tournament_round_group_team_membership] ([group]);

CREATE INDEX [tournament_round_group_team_membership_idx_team] ON [tournament_round_group_team_membership] ([team]);


--
-- Table: [tournament_round_groups]
--
CREATE TABLE [tournament_round_groups] (
  [id] integer IDENTITY NOT NULL,
  [tournament_round] integer NOT NULL,
  [group_name] varchar(150) NOT NULL,
  [group_order] tinyint NOT NULL,
  CONSTRAINT [tournament_round_groups_pk] PRIMARY KEY ([id])
);

CREATE INDEX [tournament_round_groups_idx_tournament_round] ON [tournament_round_groups] ([tournament_round]);


--
-- Table: [tournament_round_phases]
--
CREATE TABLE [tournament_round_phases] (
  [id] integer IDENTITY NOT NULL,
  [tournament_round] integer NOT NULL,
  [phase_number] tinyint NOT NULL,
  [name] varchar(150) NOT NULL,
  [date] datetime NOT NULL,
  CONSTRAINT [tournament_round_phases_pk] PRIMARY KEY ([id])
);

CREATE INDEX [tournament_round_phases_idx_tournament_round] ON [tournament_round_phases] ([tournament_round]);


--
-- Table: [tournament_rounds]
--
CREATE TABLE [tournament_rounds] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [tournament] integer NOT NULL,
  [season] integer NOT NULL,
  [round_number] tinyint NOT NULL,
  [name] varchar(150) NOT NULL,
  [round_type] char(1) NOT NULL,
  [team_match_template] integer NOT NULL,
  [individual_match_template] integer NOT NULL,
  [date] datetime NULL,
  [venue] integer NULL,
  CONSTRAINT [tournament_rounds_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key_unique_in_tournament_season] UNIQUE ([url_key], [tournament], [season])
);

CREATE INDEX [tournament_rounds_idx_individual_match_template] ON [tournament_rounds] ([individual_match_template]);

CREATE INDEX [tournament_rounds_idx_team_match_template] ON [tournament_rounds] ([team_match_template]);


--
-- Table: [tournament_team_matches]
--
CREATE TABLE [tournament_team_matches] (
  [id] integer IDENTITY NOT NULL,
  [match_template] integer NOT NULL,
  [home_team] integer NOT NULL,
  [away_team] integer NOT NULL,
  [tournament_round_phase] integer NOT NULL,
  [venue] integer NOT NULL,
  [scheduled_date] datetime NOT NULL,
  [played_date] datetime NULL,
  [match_in_progress] tinyint NOT NULL DEFAULT '0',
  [home_team_score] tinyint NOT NULL DEFAULT '0',
  [away_team_score] tinyint NOT NULL DEFAULT '0',
  [complete] tinyint NOT NULL DEFAULT '0',
  [league_official_verified] integer NULL,
  [home_team_verified] integer NULL,
  [away_team_verified] integer NULL,
  CONSTRAINT [tournament_team_matches_pk] PRIMARY KEY ([id])
);

CREATE INDEX [tournament_team_matches_idx_away_team] ON [tournament_team_matches] ([away_team]);

CREATE INDEX [tournament_team_matches_idx_away_team_verified] ON [tournament_team_matches] ([away_team_verified]);

CREATE INDEX [tournament_team_matches_idx_home_team] ON [tournament_team_matches] ([home_team]);

CREATE INDEX [tournament_team_matches_idx_home_team_verified] ON [tournament_team_matches] ([home_team_verified]);

CREATE INDEX [tournament_team_matches_idx_league_official_verified] ON [tournament_team_matches] ([league_official_verified]);

CREATE INDEX [tournament_team_matches_idx_match_template] ON [tournament_team_matches] ([match_template]);

CREATE INDEX [tournament_team_matches_idx_tournament_round_phase] ON [tournament_team_matches] ([tournament_round_phase]);

CREATE INDEX [tournament_team_matches_idx_venue] ON [tournament_team_matches] ([venue]);


--
-- Table: [tournaments]
--
CREATE TABLE [tournaments] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(100) NOT NULL,
  [event] integer NOT NULL,
  [season] integer NOT NULL,
  [entry_type] varchar(20) NOT NULL,
  [allow_online_entries] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [tournaments_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE INDEX [tournaments_idx_entry_type] ON [tournaments] ([entry_type]);

CREATE INDEX [tournaments_idx_event_season] ON [tournaments] ([event], [season]);


--
-- Table: [uploaded_files]
--
CREATE TABLE [uploaded_files] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [filename] varchar(255) NOT NULL,
  [description] varchar(255) NULL,
  [mime_type] varchar(150) NOT NULL,
  [uploaded] datetime NOT NULL,
  [downloaded_count] integer NOT NULL DEFAULT '0',
  [deleted] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [uploaded_files_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [uploaded_images]
--
CREATE TABLE [uploaded_images] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [filename] varchar(255) NOT NULL,
  [description] varchar(255) NULL,
  [mime_type] varchar(150) NOT NULL,
  [uploaded] datetime NOT NULL,
  [viewed_count] integer NOT NULL DEFAULT '0',
  [deleted] tinyint NOT NULL DEFAULT '0',
  CONSTRAINT [uploaded_images_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);


--
-- Table: [user_agents]
--
CREATE TABLE [user_agents] (
  [id] integer IDENTITY NOT NULL,
  [string] text NOT NULL,
  [sha256_hash] varchar(64) NOT NULL,
  [first_seen] datetime NOT NULL,
  [last_seen] datetime NOT NULL,
  CONSTRAINT [user_agents_pk] PRIMARY KEY ([id])
);


--
-- Table: [user_ip_addresses_browsers]
--
CREATE TABLE [user_ip_addresses_browsers] (
  [user_id] integer NOT NULL,
  [ip_address] varchar(40) NOT NULL,
  [user_agent] integer NOT NULL,
  [first_seen] datetime NOT NULL,
  [last_seen] datetime NOT NULL,
  CONSTRAINT [user_ip_addresses_browsers_pk] PRIMARY KEY ([user_id], [ip_address], [user_agent])
);

CREATE INDEX [user_ip_addresses_browsers_idx_user_id] ON [user_ip_addresses_browsers] ([user_id]);

CREATE INDEX [user_ip_addresses_browsers_idx_user_agent] ON [user_ip_addresses_browsers] ([user_agent]);


--
-- Table: [user_roles]
--
CREATE TABLE [user_roles] (
  [user] integer NOT NULL,
  [role] integer NOT NULL,
  CONSTRAINT [user_roles_pk] PRIMARY KEY ([user], [role])
);

CREATE INDEX [user_roles_idx_role] ON [user_roles] ([role]);

CREATE INDEX [user_roles_idx_user] ON [user_roles] ([user]);


--
-- Table: [users]
--
CREATE TABLE [users] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [username] varchar(45) NOT NULL,
  [email_address] varchar(300) NOT NULL,
  [person] integer NULL,
  [password] text NOT NULL,
  [change_password_next_login] tinyint NOT NULL DEFAULT '0',
  [html_emails] tinyint NOT NULL DEFAULT '0',
  [registered_date] datetime NOT NULL,
  [registered_ip] varchar(45) NOT NULL,
  [last_visit_date] datetime NOT NULL,
  [last_visit_ip] varchar(45) NULL,
  [last_active_date] datetime NOT NULL,
  [last_active_ip] varchar(45) NULL,
  [locale] varchar(6) NOT NULL,
  [timezone] varchar(50) NULL,
  [avatar] varchar(500) NULL,
  [posts] integer NOT NULL DEFAULT '0',
  [comments] integer NOT NULL DEFAULT '0',
  [signature] mediumtext NULL,
  [facebook] varchar(255) NULL,
  [twitter] varchar(255) NULL,
  [aim] varchar(255) NULL,
  [jabber] varchar(255) NULL,
  [website] varchar(255) NULL,
  [interests] text NULL,
  [occupation] varchar(150) NULL,
  [location] varchar(150) NULL,
  [hide_online] tinyint NOT NULL DEFAULT '0',
  [activation_key] varchar(64) NULL,
  [activated] tinyint NOT NULL DEFAULT '0',
  [activation_expires] datetime NOT NULL,
  [invalid_logins] smallint NOT NULL DEFAULT '0',
  [password_reset_key] varchar(64) NULL,
  [password_reset_expires] datetime NOT NULL,
  [last_invalid_login] datetime NULL,
  CONSTRAINT [users_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);

CREATE UNIQUE NONCLUSTERED INDEX [user_person_idx] ON [users] ([person]) WHERE [person] IS NOT NULL;

CREATE INDEX [users_idx_person] ON [users] ([person]);


--
-- Table: [venue_timetables]
--
CREATE TABLE [venue_timetables] (
  [id] integer NOT NULL,
  [venue] integer NOT NULL,
  [day] tinyint NOT NULL,
  [number_of_tables] smallint NULL,
  [start_time] datetime NOT NULL,
  [end_time] datetime NOT NULL,
  [price_information] varchar(50) NULL,
  [description] text NOT NULL,
  [matches] tinyint NOT NULL,
  CONSTRAINT [venue_timetables_pk] PRIMARY KEY ([id])
);

CREATE INDEX [venue_timetables_idx_day] ON [venue_timetables] ([day]);

CREATE INDEX [venue_timetables_idx_venue] ON [venue_timetables] ([venue]);


--
-- Table: [venues]
--
CREATE TABLE [venues] (
  [id] integer IDENTITY NOT NULL,
  [url_key] varchar(45) NOT NULL,
  [name] varchar(300) NOT NULL,
  [address1] varchar(100) NULL,
  [address2] varchar(100) NULL,
  [address3] varchar(100) NULL,
  [address4] varchar(100) NULL,
  [address5] varchar(100) NULL,
  [postcode] varchar(10) NULL,
  [telephone] varchar(20) NULL,
  [email_address] varchar(240) NULL,
  [coordinates_latitude] float(10,8) NULL,
  [coordinates_longitude] float(11,8) NULL,
  CONSTRAINT [venues_pk] PRIMARY KEY ([id]),
  CONSTRAINT [url_key] UNIQUE ([url_key])
);
ALTER TABLE [average_filters] ADD CONSTRAINT [average_filters_fk_user] FOREIGN KEY ([user]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [clubs] ADD CONSTRAINT [clubs_fk_secretary] FOREIGN KEY ([secretary]) REFERENCES [people] ([id]) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE [clubs] ADD CONSTRAINT [clubs_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [contact_reason_recipients] ADD CONSTRAINT [contact_reason_recipients_fk_contact_reason] FOREIGN KEY ([contact_reason]) REFERENCES [contact_reasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [contact_reason_recipients] ADD CONSTRAINT [contact_reason_recipients_fk_person] FOREIGN KEY ([person]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [division_seasons] ADD CONSTRAINT [division_seasons_fk_division] FOREIGN KEY ([division]) REFERENCES [divisions] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [division_seasons] ADD CONSTRAINT [division_seasons_fk_fixtures_grid] FOREIGN KEY ([fixtures_grid]) REFERENCES [fixtures_grids] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [division_seasons] ADD CONSTRAINT [division_seasons_fk_league_match_template] FOREIGN KEY ([league_match_template]) REFERENCES [template_match_team] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [division_seasons] ADD CONSTRAINT [division_seasons_fk_league_table_ranking_template] FOREIGN KEY ([league_table_ranking_template]) REFERENCES [template_league_table_ranking] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [division_seasons] ADD CONSTRAINT [division_seasons_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [doubles_pairs] ADD CONSTRAINT [doubles_pairs_fk_person1] FOREIGN KEY ([person1]) REFERENCES [people] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [doubles_pairs] ADD CONSTRAINT [doubles_pairs_fk_person2] FOREIGN KEY ([person2]) REFERENCES [people] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [doubles_pairs] ADD CONSTRAINT [doubles_pairs_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [doubles_pairs] ADD CONSTRAINT [doubles_pairs_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [event_seasons] ADD CONSTRAINT [event_seasons_fk_event] FOREIGN KEY ([event]) REFERENCES [events] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [event_seasons] ADD CONSTRAINT [event_seasons_fk_organiser] FOREIGN KEY ([organiser]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [event_seasons] ADD CONSTRAINT [event_seasons_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [event_seasons] ADD CONSTRAINT [event_seasons_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [events] ADD CONSTRAINT [events_fk_event_type] FOREIGN KEY ([event_type]) REFERENCES [lookup_event_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [fixtures_grid_matches] ADD CONSTRAINT [fixtures_grid_matches_fk_grid_week] FOREIGN KEY ([grid], [week]) REFERENCES [fixtures_grid_weeks] ([grid], [week]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [fixtures_grid_weeks] ADD CONSTRAINT [fixtures_grid_weeks_fk_grid] FOREIGN KEY ([grid]) REFERENCES [fixtures_grids] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [fixtures_season_weeks] ADD CONSTRAINT [fixtures_season_weeks_fk_grid_grid_week] FOREIGN KEY ([grid], [grid_week]) REFERENCES [fixtures_grid_weeks] ([grid], [week]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [fixtures_season_weeks] ADD CONSTRAINT [fixtures_season_weeks_fk_fixtures_week] FOREIGN KEY ([fixtures_week]) REFERENCES [fixtures_weeks] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [fixtures_weeks] ADD CONSTRAINT [fixtures_weeks_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [individual_matches] ADD CONSTRAINT [individual_matches_fk_away_player] FOREIGN KEY ([away_player]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [individual_matches] ADD CONSTRAINT [individual_matches_fk_home_player] FOREIGN KEY ([home_player]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [individual_matches] ADD CONSTRAINT [individual_matches_fk_individual_match_template] FOREIGN KEY ([individual_match_template]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meeting_attendees] ADD CONSTRAINT [meeting_attendees_fk_meeting] FOREIGN KEY ([meeting]) REFERENCES [meetings] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meeting_attendees] ADD CONSTRAINT [meeting_attendees_fk_person] FOREIGN KEY ([person]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meetings] ADD CONSTRAINT [meetings_fk_event_season] FOREIGN KEY ([event], [season]) REFERENCES [event_seasons] ([event], [season]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meetings] ADD CONSTRAINT [meetings_fk_organiser] FOREIGN KEY ([organiser]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meetings] ADD CONSTRAINT [meetings_fk_type] FOREIGN KEY ([type]) REFERENCES [meeting_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [meetings] ADD CONSTRAINT [meetings_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [news_articles] ADD CONSTRAINT [news_articles_fk_original_article] FOREIGN KEY ([original_article]) REFERENCES [news_articles] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [news_articles] ADD CONSTRAINT [news_articles_fk_updated_by_user] FOREIGN KEY ([updated_by_user]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [officials] ADD CONSTRAINT [officials_fk_position_holder] FOREIGN KEY ([position_holder]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [officials] ADD CONSTRAINT [officials_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]);
ALTER TABLE [people] ADD CONSTRAINT [people_fk_gender] FOREIGN KEY ([gender]) REFERENCES [lookup_gender] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [person_seasons] ADD CONSTRAINT [person_seasons_fk_person] FOREIGN KEY ([person]) REFERENCES [people] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [person_seasons] ADD CONSTRAINT [person_seasons_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [person_seasons] ADD CONSTRAINT [person_seasons_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [person_seasons] ADD CONSTRAINT [person_seasons_fk_team_membership_type] FOREIGN KEY ([team_membership_type]) REFERENCES [lookup_team_membership_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [person_tournaments] ADD CONSTRAINT [person_tournaments_fk_person1] FOREIGN KEY ([person1]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [person_tournaments] ADD CONSTRAINT [person_tournaments_fk_person2] FOREIGN KEY ([person2]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [person_tournaments] ADD CONSTRAINT [person_tournaments_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [sessions] ADD CONSTRAINT [sessions_fk_user] FOREIGN KEY ([user]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [sessions] ADD CONSTRAINT [sessions_fk_user_agent] FOREIGN KEY ([user_agent]) REFERENCES [user_agents] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log] ADD CONSTRAINT [system_event_log_fk_object_type_event_type] FOREIGN KEY ([object_type], [event_type]) REFERENCES [system_event_log_types] ([object_type], [event_type]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log] ADD CONSTRAINT [system_event_log_fk_user_id] FOREIGN KEY ([user_id]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_average_filters] ADD CONSTRAINT [system_event_log_average_filters_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [average_filters] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_average_filters] ADD CONSTRAINT [system_event_log_average_filters_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_club] ADD CONSTRAINT [system_event_log_club_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [clubs] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_club] ADD CONSTRAINT [system_event_log_club_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_contact_reason] ADD CONSTRAINT [system_event_log_contact_reason_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [contact_reasons] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_contact_reason] ADD CONSTRAINT [system_event_log_contact_reason_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_division] ADD CONSTRAINT [system_event_log_division_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [divisions] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_division] ADD CONSTRAINT [system_event_log_division_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_event] ADD CONSTRAINT [system_event_log_event_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [events] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_event] ADD CONSTRAINT [system_event_log_event_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_file] ADD CONSTRAINT [system_event_log_file_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [uploaded_files] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_file] ADD CONSTRAINT [system_event_log_file_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_fixtures_grid] ADD CONSTRAINT [system_event_log_fixtures_grid_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [fixtures_grids] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_fixtures_grid] ADD CONSTRAINT [system_event_log_fixtures_grid_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_image] ADD CONSTRAINT [system_event_log_image_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [uploaded_images] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_image] ADD CONSTRAINT [system_event_log_image_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_meeting] ADD CONSTRAINT [system_event_log_meeting_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [meetings] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_meeting] ADD CONSTRAINT [system_event_log_meeting_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_meeting_type] ADD CONSTRAINT [system_event_log_meeting_type_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [meeting_types] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_meeting_type] ADD CONSTRAINT [system_event_log_meeting_type_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_news] ADD CONSTRAINT [system_event_log_news_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [news_articles] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_news] ADD CONSTRAINT [system_event_log_news_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_person] ADD CONSTRAINT [system_event_log_person_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [people] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_person] ADD CONSTRAINT [system_event_log_person_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_role] ADD CONSTRAINT [system_event_log_role_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [roles] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_role] ADD CONSTRAINT [system_event_log_role_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_season] ADD CONSTRAINT [system_event_log_season_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [seasons] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_season] ADD CONSTRAINT [system_event_log_season_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_team] ADD CONSTRAINT [system_event_log_team_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [teams] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_team] ADD CONSTRAINT [system_event_log_team_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_team_match] ADD CONSTRAINT [system_event_log_team_match_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_team_match] ADD CONSTRAINT [system_event_log_team_match_fk_object_home_team_object_away_team_object_scheduled_date] FOREIGN KEY ([object_home_team], [object_away_team], [object_scheduled_date]) REFERENCES [team_matches] ([home_team], [away_team], [scheduled_date]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_template_league_table_ranking] ADD CONSTRAINT [system_event_log_template_league_table_ranking_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [template_league_table_ranking] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_template_league_table_ranking] ADD CONSTRAINT [system_event_log_template_league_table_ranking_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_template_match_individual] ADD CONSTRAINT [system_event_log_template_match_individual_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [template_match_individual] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_template_match_individual] ADD CONSTRAINT [system_event_log_template_match_individual_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_template_match_team] ADD CONSTRAINT [system_event_log_template_match_team_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [template_match_team] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_template_match_team] ADD CONSTRAINT [system_event_log_template_match_team_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_template_match_team_game] ADD CONSTRAINT [system_event_log_template_match_team_game_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [template_match_team] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_template_match_team_game] ADD CONSTRAINT [system_event_log_template_match_team_game_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_user] ADD CONSTRAINT [system_event_log_user_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [users] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_user] ADD CONSTRAINT [system_event_log_user_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [system_event_log_venue] ADD CONSTRAINT [system_event_log_venue_fk_object_id] FOREIGN KEY ([object_id]) REFERENCES [venues] ([id]) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE [system_event_log_venue] ADD CONSTRAINT [system_event_log_venue_fk_system_event_log_id] FOREIGN KEY ([system_event_log_id]) REFERENCES [system_event_log] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_away_doubles_pair] FOREIGN KEY ([away_doubles_pair]) REFERENCES [doubles_pairs] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_away_player] FOREIGN KEY ([away_player]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_home_doubles_pair] FOREIGN KEY ([home_doubles_pair]) REFERENCES [doubles_pairs] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_home_player] FOREIGN KEY ([home_player]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_individual_match_template] FOREIGN KEY ([individual_match_template]) REFERENCES [template_match_individual] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_home_team_away_team_scheduled_date] FOREIGN KEY ([home_team], [away_team], [scheduled_date]) REFERENCES [team_matches] ([home_team], [away_team], [scheduled_date]) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_umpire] FOREIGN KEY ([umpire]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_games] ADD CONSTRAINT [team_match_games_fk_winner] FOREIGN KEY ([winner]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_legs] ADD CONSTRAINT [team_match_legs_fk_first_server] FOREIGN KEY ([first_server]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_legs] ADD CONSTRAINT [team_match_legs_fk_next_point_server] FOREIGN KEY ([next_point_server]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_legs] ADD CONSTRAINT [team_match_legs_fk_home_team_away_team_scheduled_date_scheduled_game_number] FOREIGN KEY ([home_team], [away_team], [scheduled_date], [scheduled_game_number]) REFERENCES [team_match_games] ([home_team], [away_team], [scheduled_date], [scheduled_game_number]) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE [team_match_legs] ADD CONSTRAINT [team_match_legs_fk_winner] FOREIGN KEY ([winner]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_players] ADD CONSTRAINT [team_match_players_fk_loan_team] FOREIGN KEY ([loan_team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_players] ADD CONSTRAINT [team_match_players_fk_location] FOREIGN KEY ([location]) REFERENCES [lookup_locations] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_players] ADD CONSTRAINT [team_match_players_fk_player] FOREIGN KEY ([player]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_players] ADD CONSTRAINT [team_match_players_fk_home_team_away_team_scheduled_date] FOREIGN KEY ([home_team], [away_team], [scheduled_date]) REFERENCES [team_matches] ([home_team], [away_team], [scheduled_date]) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE [team_match_reports] ADD CONSTRAINT [team_match_reports_fk_author] FOREIGN KEY ([author]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_match_reports] ADD CONSTRAINT [team_match_reports_fk_home_team_away_team_scheduled_date] FOREIGN KEY ([home_team], [away_team], [scheduled_date]) REFERENCES [team_matches] ([home_team], [away_team], [scheduled_date]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_away_team] FOREIGN KEY ([away_team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_away_team_verified] FOREIGN KEY ([away_team_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_division] FOREIGN KEY ([division]) REFERENCES [divisions] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_fixtures_grid] FOREIGN KEY ([fixtures_grid]) REFERENCES [fixtures_grids] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_home_team] FOREIGN KEY ([home_team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_home_team_verified] FOREIGN KEY ([home_team_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_league_official_verified] FOREIGN KEY ([league_official_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_played_week] FOREIGN KEY ([played_week]) REFERENCES [fixtures_weeks] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_player_of_the_match] FOREIGN KEY ([player_of_the_match]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_scheduled_week] FOREIGN KEY ([scheduled_week]) REFERENCES [fixtures_weeks] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_team_match_template] FOREIGN KEY ([team_match_template]) REFERENCES [template_match_team] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_tournament_round] FOREIGN KEY ([tournament_round]) REFERENCES [tournament_rounds] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_matches] ADD CONSTRAINT [team_matches_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_captain] FOREIGN KEY ([captain]) REFERENCES [people] ([id]) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_club] FOREIGN KEY ([club]) REFERENCES [clubs] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_division] FOREIGN KEY ([division]) REFERENCES [divisions] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_home_night] FOREIGN KEY ([home_night]) REFERENCES [lookup_weekdays] ([weekday_number]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons] ADD CONSTRAINT [team_seasons_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons_intervals] ADD CONSTRAINT [team_seasons_intervals_fk_division] FOREIGN KEY ([division]) REFERENCES [divisions] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons_intervals] ADD CONSTRAINT [team_seasons_intervals_fk_season] FOREIGN KEY ([season]) REFERENCES [seasons] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons_intervals] ADD CONSTRAINT [team_seasons_intervals_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [team_seasons_intervals] ADD CONSTRAINT [team_seasons_intervals_fk_week] FOREIGN KEY ([week]) REFERENCES [fixtures_weeks] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [teams] ADD CONSTRAINT [teams_fk_club] FOREIGN KEY ([club]) REFERENCES [clubs] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [template_match_individual] ADD CONSTRAINT [template_match_individual_fk_game_type] FOREIGN KEY ([game_type]) REFERENCES [lookup_game_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [template_match_individual] ADD CONSTRAINT [template_match_individual_fk_serve_type] FOREIGN KEY ([serve_type]) REFERENCES [lookup_serve_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [template_match_team] ADD CONSTRAINT [template_match_team_fk_winner_type] FOREIGN KEY ([winner_type]) REFERENCES [lookup_winner_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [template_match_team_games] ADD CONSTRAINT [template_match_team_games_fk_individual_match_template] FOREIGN KEY ([individual_match_template]) REFERENCES [template_match_individual] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [template_match_team_games] ADD CONSTRAINT [template_match_team_games_fk_team_match_template] FOREIGN KEY ([team_match_template]) REFERENCES [template_match_team] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_group_individual_membership] ADD CONSTRAINT [tournament_round_group_individual_membership_fk_group] FOREIGN KEY ([group]) REFERENCES [tournament_round_groups] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_group_individual_membership] ADD CONSTRAINT [tournament_round_group_individual_membership_fk_person1] FOREIGN KEY ([person1]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_group_individual_membership] ADD CONSTRAINT [tournament_round_group_individual_membership_fk_person2] FOREIGN KEY ([person2]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_group_team_membership] ADD CONSTRAINT [tournament_round_group_team_membership_fk_group] FOREIGN KEY ([group]) REFERENCES [tournament_round_groups] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_group_team_membership] ADD CONSTRAINT [tournament_round_group_team_membership_fk_team] FOREIGN KEY ([team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_groups] ADD CONSTRAINT [tournament_round_groups_fk_tournament_round] FOREIGN KEY ([tournament_round]) REFERENCES [tournament_rounds] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_round_phases] ADD CONSTRAINT [tournament_round_phases_fk_tournament_round] FOREIGN KEY ([tournament_round]) REFERENCES [tournament_rounds] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_rounds] ADD CONSTRAINT [tournament_rounds_fk_individual_match_template] FOREIGN KEY ([individual_match_template]) REFERENCES [template_match_individual] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_rounds] ADD CONSTRAINT [tournament_rounds_fk_team_match_template] FOREIGN KEY ([team_match_template]) REFERENCES [template_match_team] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_away_team] FOREIGN KEY ([away_team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_away_team_verified] FOREIGN KEY ([away_team_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_home_team] FOREIGN KEY ([home_team]) REFERENCES [teams] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_home_team_verified] FOREIGN KEY ([home_team_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_league_official_verified] FOREIGN KEY ([league_official_verified]) REFERENCES [people] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_match_template] FOREIGN KEY ([match_template]) REFERENCES [template_match_team] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_tournament_round_phase] FOREIGN KEY ([tournament_round_phase]) REFERENCES [tournament_round_phases] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournament_team_matches] ADD CONSTRAINT [tournament_team_matches_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournaments] ADD CONSTRAINT [tournaments_fk_entry_type] FOREIGN KEY ([entry_type]) REFERENCES [lookup_tournament_types] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [tournaments] ADD CONSTRAINT [tournaments_fk_event_season] FOREIGN KEY ([event], [season]) REFERENCES [event_seasons] ([event], [season]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [user_ip_addresses_browsers] ADD CONSTRAINT [user_ip_addresses_browsers_fk_user_id] FOREIGN KEY ([user_id]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [user_ip_addresses_browsers] ADD CONSTRAINT [user_ip_addresses_browsers_fk_user_agent] FOREIGN KEY ([user_agent]) REFERENCES [user_agents] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [user_roles] ADD CONSTRAINT [user_roles_fk_role] FOREIGN KEY ([role]) REFERENCES [roles] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [user_roles] ADD CONSTRAINT [user_roles_fk_user] FOREIGN KEY ([user]) REFERENCES [users] ([id]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [users] ADD CONSTRAINT [users_fk_person] FOREIGN KEY ([person]) REFERENCES [people] ([id]) ON DELETE SET NULL ON UPDATE RESTRICT;
ALTER TABLE [venue_timetables] ADD CONSTRAINT [venue_timetables_fk_day] FOREIGN KEY ([day]) REFERENCES [lookup_weekdays] ([weekday_number]) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE [venue_timetables] ADD CONSTRAINT [venue_timetables_fk_venue] FOREIGN KEY ([venue]) REFERENCES [venues] ([id]) ON DELETE CASCADE ON UPDATE RESTRICT;;
