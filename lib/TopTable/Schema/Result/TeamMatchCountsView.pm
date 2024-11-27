package TopTable::Schema::Result::TeamMatchCountsView;

=head1 NAME

TopTable::Schema::Result::TeamMatchCountsView

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

=head1 VIEW: C<club_teams>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("team_match_count");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT COUNT(*) AS 'number_of_matches', team_id, club_url, team_url, club_full_name, club_short_name, team_name, season_id, season_url, season_name
FROM
((SELECT `match`.home_team as team_id, c.url_key AS club_url, t.url_key AS team_url, cs.full_name AS club_full_name, cs.short_name AS club_short_name, ts.`name` AS team_name, s.id AS season_id, s.url_key AS season_url, s.`name` AS season_name
FROM team_matches `match`
JOIN team_seasons ts ON `match`.home_team = ts.team AND `match`.season = ts.season
JOIN teams t ON ts.team = t.id
JOIN club_seasons cs ON ts.club = cs.club AND ts.season = cs.season
JOIN clubs c ON cs.club = c.id
JOIN seasons s ON `match`.season = s.id)
UNION ALL
(SELECT `match`.away_team as team_id, c.url_key AS club_url, t.url_key AS team_url, cs.full_name AS club_full_name, cs.short_name AS club_short_name, ts.`name` AS team_name, s.id AS season_id, s.url_key AS season_url, s.`name` AS season_name
FROM team_matches `match`
JOIN team_seasons ts ON `match`.away_team = ts.team AND `match`.season = ts.season
JOIN teams t ON ts.team = t.id
JOIN club_seasons cs ON ts.club = cs.club AND ts.season = cs.season
JOIN clubs c ON cs.club = c.id
JOIN seasons s ON `match`.season = s.id)) AS matches
WHERE season_id = 9
GROUP BY team_id, season_id"
);

__PACKAGE__->add_columns(
  "number_of_matches" => {
    data_type => "integer",
    is_nullable => 0,
    size => 20,
    extra => { unsigned => 1 },
  },
  "team_id" => {
    data_type => "integer",
    is_nullable => 0,
    size => 20,
  },
  "club_url" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "team_url" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "club_full_name" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 150,
  },
  "club_short_name" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 150,
  },
  "team_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "season_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0
  },
  "season_url" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },,
  "season_name" => {
    data_type => "varchar",
    default_value => 0,
    size => 150,
  },
);

__PACKAGE__->set_primary_key("team_id", "season_id");


1;