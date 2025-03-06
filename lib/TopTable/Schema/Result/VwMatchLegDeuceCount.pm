package TopTable::Schema::Result::VwMatchLegDeuceCount;

=head1 NAME

TopTable::Schema::Result::VwMatchLegDeuceCount - a view to group together the deuce leg wins and losses by person / season.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 VIEW: C<vw_match_leg_deuces>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_match_leg_deuces");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT COUNT(*) AS number_of_deuce_wins, player_id, player_url_key, player_first_name, player_surname, player_display_name, season_id, season_url_key, season_name, season_start_date, season_end_date, season_complete
FROM ((
	SELECT
		g.home_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete
	FROM team_match_legs l
	JOIN team_match_games g ON l.home_team = g.home_team AND l.away_team = g.away_team AND l.scheduled_date = g.scheduled_date AND l.scheduled_game_number = g.scheduled_game_number
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id
	JOIN people p ON g.home_player = p.id
	JOIN seasons s ON m.season = s.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team_membership_type = 'active'
	WHERE l.home_team_points_won > tpl.minimum_points_win AND l.home_team_points_won > l.away_team_points_won)
	UNION ALL
	(
	SELECT
		g.away_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete
	FROM team_match_legs l
	JOIN team_match_games g ON l.home_team = g.home_team AND l.away_team = g.away_team AND l.scheduled_date = g.scheduled_date AND l.scheduled_game_number = g.scheduled_game_number
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id
	JOIN people p ON g.away_player = p.id
	JOIN seasons s ON m.season = s.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team_membership_type = 'active'
	WHERE l.away_team_points_won > tpl.minimum_points_win AND l.away_team_points_won > l.home_team_points_won)) AS legs
GROUP BY player_id, season_id"
);

__PACKAGE__->add_columns(
  "number_of_deuce_wins" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "player_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "player_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "player_first_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
  },
  "player_surname" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
  },
  "player_display_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "season_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "season_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 30,
  },
  "season_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "season_start_date" => {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0
  },
  "season_end_date" => {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0
  },
  "season_complete" => {
    data_type => "tinyint",
    default_value => 0,
    is_nullable => 0
  },
);

__PACKAGE__->set_primary_key("player_id", "season_id");


1;
