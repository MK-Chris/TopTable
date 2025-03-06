package TopTable::Schema::Result::VwHighestPointsWin;

=head1 NAME

TopTable::Schema::Result::VwHighestPointsWin - a view to show the highest number of points for a win in legs.  Will only retrieve deuce legs to save on rows coming back, therefore at the very start of the season, even if games have been played, this may not return anything.

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

__PACKAGE__->table("vw_highest_points_win");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT player_id, player_url_key, player_first_name, player_surname, player_display_name, opponent_id, opponent_url_key, opponent_first_name, opponent_surname, opponent_display_name, season_id, season_url_key, season_name, season_start_date, season_end_date, season_complete, home_team_id, home_club_url_key, home_team_url_key, away_team_id, away_club_url_key, away_team_url_key, scheduled_date, played_date, home_team, away_team, division_id, division_url_key, division_name, tourn_id, tourn_url_key, tourn_name, winning_points, losing_points, scheduled_game_number, leg_number
FROM ((
	SELECT
		g.home_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		g.away_player AS opponent_id,
		o.url_key AS opponent_url_key,
		os.first_name AS opponent_first_name,
		os.surname AS opponent_surname,
		os.display_name AS opponent_display_name,
		ht.id AS home_team_id,
		hc.url_key AS home_club_url_key,
		ht.url_key AS home_team_url_key,
		`at`.id AS away_team_id,
		ac.url_key AS away_club_url_key,
		`at`.url_key AS away_team_url_key,
		m.scheduled_date AS scheduled_date,
		m.played_date AS played_date,
		CONCAT(hcs.short_name, ' ', hts.`name`) AS home_team,
		CONCAT(acs.short_name, ' ', ats.`name`) AS away_team,
		g.scheduled_game_number AS scheduled_game_number,
		l.leg_number AS leg_number,
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
		tou.`name` AS tourn_name,
		l.home_team_points_won AS winning_points,
		l.away_team_points_won AS losing_points
	FROM team_match_legs l
	JOIN team_match_games g ON l.home_team = g.home_team AND l.away_team = g.away_team AND l.scheduled_date = g.scheduled_date AND l.scheduled_game_number = g.scheduled_game_number
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id
	JOIN seasons s ON m.season = s.id
	LEFT JOIN division_seasons ds ON m.division = ds.division AND m.season = ds.season
	LEFT JOIN divisions d ON ds.division = d.id
	LEFT JOIN tournament_rounds tr ON m.tournament_round = tr.id
	LEFT JOIN tournaments tou ON tr.`event` = tou.`event` AND tr.season = tou.season
	LEFT JOIN `events` e ON tou.`event` = e.id
	JOIN people p ON g.home_player = p.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team = m.home_team
	JOIN people o ON g.away_player = o.id -- opponent
	JOIN person_seasons os ON o.id = os.person AND s.id = os.season AND os.team = m.away_team
	JOIN teams ht ON m.home_team = ht.id
	JOIN team_seasons hts ON m.home_team = hts.team AND m.season = hts.season
	JOIN clubs hc ON ht.club = hc.id
	JOIN club_seasons hcs ON hts.club = hcs.club AND hts.season = hcs.season
	JOIN teams `at` ON m.away_team = `at`.id
	JOIN team_seasons ats ON m.away_team = ats.team AND m.season = ats.season
	JOIN clubs ac ON `at`.club = ac.id
	JOIN club_seasons acs ON ats.club = acs.club AND ats.season = acs.season
	WHERE l.home_team_points_won > l.away_team_points_won AND l.home_team_points_won > tpl.minimum_points_win
	ORDER BY l.home_team_points_won)
	UNION ALL
	(
	SELECT
		g.away_player AS player_id,
		p.url_key AS player_url_key,
		ps.first_name AS player_first_name,
		ps.surname AS player_surname,
		ps.display_name AS player_display_name,
		g.home_player AS opponent_id,
		o.url_key AS opponent_url_key,
		os.first_name AS opponent_first_name,
		os.surname AS opponent_surname,
		os.display_name AS opponent_display_name,
		ht.id AS home_team_id,
		hc.url_key AS home_club_url_key,
		ht.url_key AS home_team_url_key,
		`at`.id AS away_team_id,
		ac.url_key AS away_club_url_key,
		`at`.url_key AS away_team_url_key,
		m.scheduled_date AS scheduled_date,
		m.played_date AS played_date,
		CONCAT(hcs.short_name, ' ', hts.`name`) AS home_team,
		CONCAT(acs.short_name, ' ', ats.`name`) AS away_team,
		g.scheduled_game_number AS scheduled_game_number,
		l.leg_number AS leg_number,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete,
		d.id AS division_id,
		d.url_key AS division_url_key,
		ds.`name` AS division_name,
		tou.id AS tourn_id,
		e.url_key AS tourn_url_key,
		tou.`name` AS tourn_name,
		l.away_team_points_won AS winning_points,
		l.home_team_points_won AS losing_points
	FROM team_match_legs l
	JOIN team_match_games g ON l.home_team = g.home_team AND l.away_team = g.away_team AND l.scheduled_date = g.scheduled_date AND l.scheduled_game_number = g.scheduled_game_number
	JOIN team_matches m ON g.home_team = m.home_team AND g.away_team = m.away_team AND g.scheduled_date = m.scheduled_date
	JOIN template_match_individual tpl ON g.individual_match_template = tpl.id
	JOIN seasons s ON m.season = s.id
	LEFT JOIN division_seasons ds ON m.division = ds.division AND m.season = ds.season
	LEFT JOIN divisions d ON ds.division = d.id
	LEFT JOIN tournament_rounds tr ON m.tournament_round = tr.id
	LEFT JOIN tournaments tou ON tr.`event` = tou.`event` AND tr.season = tou.season
	LEFT JOIN `events` e ON tou.`event` = e.id
	JOIN people p ON g.away_player = p.id
	JOIN person_seasons ps ON p.id = ps.person AND s.id = ps.season AND ps.team = m.away_team
	JOIN people o ON g.home_player = o.id -- opponent
	JOIN person_seasons os ON o.id = os.person AND s.id = os.season AND os.team = m.home_team
	JOIN teams ht ON m.home_team = ht.id
	JOIN team_seasons hts ON m.home_team = hts.team AND m.season = hts.season
	JOIN clubs hc ON ht.club = hc.id
	JOIN club_seasons hcs ON hts.club = hcs.club AND hts.season = hcs.season
	JOIN teams `at` ON m.away_team = `at`.id
	JOIN team_seasons ats ON m.away_team = ats.team AND m.season = ats.season
	JOIN clubs ac ON `at`.club = ac.id
	JOIN club_seasons acs ON ats.club = acs.club AND ats.season = acs.season
	WHERE l.home_team_points_won < l.away_team_points_won AND l.away_team_points_won > tpl.minimum_points_win)) AS games
GROUP BY player_id, season_id, winning_points"
);

__PACKAGE__->add_columns(
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
  "opponent_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "opponent_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "opponent_first_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
  },
  "opponent_surname" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150
  },
  "opponent_display_name" => {
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
  "home_team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
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
    size => 45
  },
  "away_team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
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
    size => 45
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
  "home_team" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "away_team" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "division_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "division_url_key" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 45
  },
  "division_name" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 150
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
  "winning_points" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "losing_points" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "scheduled_game_number" => {
    data_type => "smallint",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "leg_number" => {
    data_type => "smallint",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

__PACKAGE__->set_primary_key("home_club_url_key", "home_team_url_key", "away_club_url_key", "away_team_url_key", "scheduled_date", "scheduled_game_number", "leg_number", "season_id");


1;
