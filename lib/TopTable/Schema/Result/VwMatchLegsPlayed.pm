package TopTable::Schema::Result::VwMatchLegsPlayed;

=head1 NAME

TopTable::Schema::Result::VwMatchPointsScored - a view to show the highest number of points scored in matches

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

=head1 VIEW: C<vw_match_points_scored>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_match_legs_played");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT total_legs, home_team, away_team, home_team_legs_won, away_team_legs_won, home_team_match_score, away_team_match_score, scheduled_date, played_date, home_team_id, home_club_url_key, home_team_url_key, away_team_id, away_club_url_key, away_team_url_key, season_id, season_url_key, season_name, season_start_date, season_end_date, season_complete, division_id, division_url_key, division_name, tourn_id, tourn_url_key, tourn_name
FROM ((
	SELECT
		ht.id AS home_team_id,
		hc.url_key AS home_club_url_key,
		ht.url_key AS home_team_url_key,
		`at`.id AS away_team_id,
		ac.url_key AS away_club_url_key,
		`at`.url_key AS away_team_url_key,
		m.scheduled_date AS scheduled_date,
		m.played_date AS played_date,
		m.home_team_legs_won + m.away_team_legs_won AS total_legs,
    m.home_team_legs_won,
    m.away_team_legs_won,
    CASE
      WHEN m.home_team_match_score_override IS NOT NULL THEN m.home_team_match_score_override
      ELSE m.home_team_match_score
    END AS home_team_match_score,
    CASE
      WHEN m.away_team_match_score_override IS NOT NULL THEN m.away_team_match_score_override
      ELSE m.away_team_match_score
    END AS away_team_match_score,
		CONCAT(hcs.short_name, ' ', hts.`name`) AS home_team,
		CONCAT(acs.short_name, ' ', ats.`name`) AS away_team,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete,
		d.id AS division_id,
		d.url_key AS division_url_key,
		ds.`name` AS division_name,
		e.url_key AS tourn_url_key,
		tou.id AS tourn_id,
		tou.`name` AS tourn_name
	FROM team_matches m
	JOIN seasons s ON m.season = s.id
	LEFT JOIN division_seasons ds ON m.division = ds.division AND m.season = ds.season
	LEFT JOIN divisions d ON ds.division = d.id
	LEFT JOIN tournament_rounds tr ON m.tournament_round = tr.id
	LEFT JOIN tournaments tou ON tr.`event` = tou.`event` AND tr.season = tou.season
	LEFT JOIN `events` e ON tou.`event` = e.id
	JOIN teams ht ON m.home_team = ht.id
	JOIN team_seasons hts ON m.home_team = hts.team AND m.season = hts.season
	JOIN clubs hc ON ht.club = hc.id
	JOIN club_seasons hcs ON hts.club = hcs.club AND hts.season = hcs.season
	JOIN teams `at` ON m.away_team = `at`.id
	JOIN team_seasons ats ON m.away_team = ats.team AND m.season = ats.season
	JOIN clubs ac ON `at`.club = ac.id
	JOIN club_seasons acs ON ats.club = acs.club AND ats.season = acs.season
	WHERE m.complete = 1)) AS matches"
);

__PACKAGE__->add_columns(
  "total_legs" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "away_team" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
  },
  "home_team_legs_won" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_legs_won" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "scheduled_date" => {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0
  },
  "played_date" => {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0
  },
  "home_team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_club_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "home_team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "away_team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_club_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "away_team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "home_team_match_score" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_match_score" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
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
  "division_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "division_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "division_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "tourn_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "tourn_url_key" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 45
  },
  "tourn_name" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 150
  },
);

__PACKAGE__->set_primary_key("home_club_url_key", "home_team_url_key", "away_club_url_key", "away_team_url_key", "scheduled_date", "season_id");


1;
