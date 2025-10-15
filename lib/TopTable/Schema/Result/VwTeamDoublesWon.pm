package TopTable::Schema::Result::VwTeamDoublesWon;

=head1 NAME

TopTable::Schema::Result::VwTeamDoublesWon - a view to show the highest number of doubles games won by teams

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

=head1 VIEW: C<vw_team_doubles_won>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_team_doubles_won");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT team_name, team_id, club_url_key, team_url_key, doubles_games_won, season_id, season_url_key, season_name, season_start_date, season_end_date, season_complete, division_id, division_url_key, division_rank, division_name
FROM ((
	SELECT
		t.id AS team_id,
		c.url_key AS club_url_key,
		t.url_key AS team_url_key,
		CONCAT(cs.short_name, ' ', ts.`name`) AS team_name,
		ts.doubles_games_won,
		s.id AS season_id,
		s.url_key AS season_url_key,
		s.`name` AS season_name,
		s.start_date AS season_start_date,
		s.end_date AS season_end_date,
		s.complete AS season_complete,
		d.id AS division_id,
		d.url_key AS division_url_key,
    d.rank AS division_rank,
		ds.`name` AS division_name
	FROM team_seasons ts
	JOIN seasons s ON ts.season = s.id
	LEFT JOIN division_seasons ds ON ts.division = ds.division AND ts.season = ds.season
	LEFT JOIN divisions d ON ds.division = d.id
	JOIN teams t ON ts.team = t.id
	JOIN clubs c ON t.club = c.id
	JOIN club_seasons cs ON ts.club = cs.club AND ts.season = cs.season
	WHERE ts.doubles_games_played > 1)) AS `teams`"
);

__PACKAGE__->add_columns(
  "team_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301
  },
  "team_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "club_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
  "team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "doubles_games_won" => {
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
  "division_rank" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "division_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45
  },
);

__PACKAGE__->set_primary_key("team_id", "season_id");


1;
