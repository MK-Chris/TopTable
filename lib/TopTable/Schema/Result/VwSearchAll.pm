package TopTable::Schema::Result::VwSearchAll;

=head1 NAME

TopTable::Schema::Result::VwSearchAll - A unionised view to get all searchable objects together for searching.

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

=head1 VIEW: C<vw_search_all>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_search_all");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "-- People
SELECT 'person' AS 'type', id, url_key AS 'url_keys_csv', display_name AS 'name1', NULL AS 'name2', 1 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM people
UNION
-- Clubs
SELECT 'club' AS 'type', id, url_key AS 'url_keys_csv', full_name AS 'name1', short_name AS 'name2', 2 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM clubs
UNION
-- Venues
SELECT 'venue' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 3 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM venues
UNION
-- Teams
SELECT 'team' AS 'type', t.id AS 'id', CONCAT(c.url_key, ',', t.url_key) AS 'url_keys_csv', CONCAT(c.short_name, ' ', t.name) AS 'name1', NULL AS 'name2', 4 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM teams t
JOIN clubs c
ON t.club = c.id
UNION
-- Team matches
SELECT 'team-match' AS 'type', CONCAT(home_team, ',', away_team, ',', YEAR(scheduled_date), ',', MONTH(scheduled_date), ',', DAY(scheduled_date)) AS 'id', CONCAT(hc.url_key, ',', ht.url_key, ',', ac.url_key, ',', at.url_key, ',', YEAR(scheduled_date), ',', MONTH(scheduled_date), ',', DAY(scheduled_date)) AS 'url_keys_csv', CONCAT(hcs.short_name, ' ', hts.name, ' v ', acs.short_name, ' ', ats.name) AS 'name1', NULL AS 'name2', 5 AS 'search_priority', scheduled_date AS 'date', complete AS 'match_complete'
FROM team_matches m
JOIN team_seasons hts
ON m.home_team = hts.team AND m.season = hts.season
JOIN club_seasons hcs
ON hts.club = hcs.club AND hts.season = hcs.season
JOIN teams ht
ON hts.team = ht.id
JOIN clubs hc
ON hcs.club = hc.id
JOIN team_seasons ats
ON m.away_team = ats.team AND m.season = ats.season
JOIN club_seasons acs
ON ats.club = acs.club AND ats.season = acs.season
JOIN teams at
ON ats.team = at.id
JOIN clubs ac
ON acs.club = ac.id
UNION
-- Divisions
SELECT 'division' AS 'type', id, url_key AS 'url_keys', name AS 'name1', NULL AS 'name2', 6 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM divisions
UNION
-- Seasons
SELECT 'season' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 7 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM seasons
UNION
-- Fixtures grids
SELECT 'fixtures-grid' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 8 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM fixtures_grids
UNION
-- League ranking templates
SELECT 'template-league-table-ranking' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 9 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM template_league_table_ranking
UNION
-- Individual match templates
SELECT 'template-match-individual' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 10 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM template_match_individual
UNION
-- Team match templates
SELECT 'template-match-team' AS 'type', id, url_key AS 'url_keys_csv', name AS 'name1', NULL AS 'name2', 11 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM template_match_team
UNION
-- Users
SELECT 'user' AS 'type', id, url_key AS 'url_keys_csv', username AS 'name1', NULL AS 'name2', 12 AS 'search_priority', NULL AS 'date', NULL AS 'match_complete'
FROM users"
);

__PACKAGE__->add_columns(
  "type" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 20,
  },
  "id" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 20,
  },
  "url_keys_csv" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 200,
  },
  "name1" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 600,
  },
  "name2" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 150,
  },
  "search_priority" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "date" => {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0
  },
  "match_complete" => {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

__PACKAGE__->set_primary_key("type", "id");

=head2 ids

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub ids {
  my ( $self ) = @_;
  return split(",", $self->id);
}

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [split(",", $self->url_keys_csv)];
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name1,
    url_keys => $self->url_keys,
    type => $self->type,
  };
}

1;