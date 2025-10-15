package TopTable::Schema::Result::VwMatchDecidingGame;

=head1 NAME

TopTable::Schema::Result::VwMatchDecidingGame - a view to group together the deciding set wins and losses by person / season.

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

=head1 VIEW: C<vw_match_deciding_sets>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_match_deciding_sets");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT COUNT(*) AS number_of_sets, player_id, player_url_key, player_first_name, player_surname, player_display_name, club_id, club_url_key, team_id, team_url_key, registered_team, division_id, division_url_key, division_rank, registered_division, season_id, season_url_key, season_name, season_start_date, season_end_date, season_complete, result, min_legs, max_legs
FROM ((
	SELECT
		g.home_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		c.id AS club_id,
		c.url_key AS club_url_key,
		t.id AS team_id,
		t.url_key AS team_url_key,
		CONCAT(cs.short_name, ' ', ts.`name`) AS registered_team,
		d.id AS division_id,
		d.url_key AS division_url_key,
		d.`rank` AS division_rank,
		ds.`name` AS registered_division,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete,
		g.home_team_legs_won + g.away_team_legs_won AS legs_played,
		tpl.legs_per_game AS max_legs,
		tpl.game_type AS game_type,
		CEILING(tpl.legs_per_game / 2) AS 'min_legs',
		CASE g.winner
			WHEN g.home_team THEN 'win'
			WHEN g.away_team THEN 'loss'
			ELSE 'unknown'
		END AS 'result'
	FROM team_match_games g
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id AND tpl.game_type = 'best-of'
	JOIN people p ON g.home_player = p.id
	JOIN seasons s ON m.season = s.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team_membership_type = 'active'
	JOIN team_seasons ts ON ps.season = ts.season AND ps.team = ts.team
	JOIN teams t ON ts.team = t.id
	JOIN club_seasons cs ON ts.club = cs.club AND ts.season = cs.season
	JOIN clubs c ON cs.club = c.id
	JOIN division_seasons ds ON ts.division = ds.division AND ts.season = ds.season
	JOIN divisions d ON ds.division = d.id
	WHERE g.home_team_legs_won + g.away_team_legs_won = tpl.legs_per_game)
	UNION ALL
	(
	SELECT
		g.away_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		c.id AS club_id,
		c.url_key AS club_url_key,
		t.id AS team_id,
		t.url_key AS team_url_key,
		CONCAT(cs.short_name, ' ', ts.`name`) AS registered_team,
		d.id AS division_id,
		d.url_key AS division_url_key,
		d.`rank` AS division_rank,
		ds.`name` AS registered_division,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete,
		g.home_team_legs_won + g.away_team_legs_won AS legs_played,
		tpl.legs_per_game AS max_legs,
		tpl.game_type AS game_type,
		CEILING(tpl.legs_per_game / 2) AS 'min_legs',
		CASE g.winner
			WHEN g.away_team THEN 'win'
			WHEN g.home_team THEN 'loss'
			ELSE 'unknown'
		END AS 'result'
	FROM team_match_games g
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id AND tpl.game_type = 'best-of'
	JOIN people p ON g.away_player = p.id
	JOIN seasons s ON m.season = s.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team_membership_type = 'active'
	JOIN team_seasons ts ON ps.season = ts.season AND ps.team = ts.team
	JOIN teams t ON ts.team = t.id
	JOIN club_seasons cs ON ts.club = cs.club AND ts.season = cs.season
	JOIN clubs c ON cs.club = c.id
	JOIN division_seasons ds ON ts.division = ds.division AND ts.season = ds.season
	JOIN divisions d ON ds.division = d.id
	WHERE g.home_team_legs_won + g.away_team_legs_won = tpl.legs_per_game)) AS games
WHERE legs_played = max_legs
AND game_type = 'best-of'
GROUP BY player_id, season_id, result"
);

__PACKAGE__->add_columns(
  "number_of_sets" => {
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
  "club_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "club_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 30,
  },
  "team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 30,
  },
  "registered_team" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "division_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "division_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 30,
  },
  "division_rank" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "registered_division" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
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
  "result" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 10,
  },
  "min_legs" => {
    data_type => "smallint",
    default_value => 0,
    is_nullable => 0
  },
  "max_legs" => {
    data_type => "smallint",
    default_value => 0,
    is_nullable => 0
  },
);

__PACKAGE__->set_primary_key("player_id", "season_id");


1;
