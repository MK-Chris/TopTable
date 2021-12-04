package TopTable::Schema::Result::TeamMatchView;

=head1 NAME

TopTable::Schema::Result::TeamMatchView

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

=head1 VIEW: C<team_match_view>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("team_match_view");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT m.home_team, m.away_team, m.scheduled_date, m.played_date, hc.url_key AS 'home_club_url_key', ht.url_key AS 'home_team_url_key', ac.url_key AS 'away_club_url_key', at.url_key AS 'away_team_url_key', CONCAT(hc.short_name, ' ', ht.name) AS 'home_team_name', CONCAT(ac.short_name, ' ', at.name) AS 'away_team_name', CONCAT(hc.short_name, ' ', ht.name, ' v ', ac.short_name, ' ', at.name) AS 'match_name', s.id AS 'season_id', s.name AS 'season_name', d.name AS 'division_name', v.name AS 'venue_name', m.home_team_match_score AS 'home_score', m.away_team_match_score AS 'away_score', m.complete, m.cancelled
  FROM team_matches m
  JOIN teams ht
  ON m.home_team = ht.id
  JOIN clubs hc
  ON ht.club = hc.id
  JOIN teams at
  ON m.away_team = at.id
  JOIN clubs ac
  ON at.club = ac.id
  JOIN divisions d
  ON m.division = d.id
  JOIN venues v
  ON m.venue = v.id
  JOIN seasons s
  ON m.season = s.id"
);

__PACKAGE__->add_columns(
  "home_team" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 0,
    is_nullable => 0,
  },
  "away_team" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 0,
    is_nullable => 0,
  },
  "scheduled_date", {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "played_date", {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "home_club_url_key" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 45,
  },
  "home_team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "away_club_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "away_team_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "home_team_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301,
  },
  "away_team_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301,
  },
  "match_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 605,
  },
  "season_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 0,
    is_nullable => 0,
  },
  "season_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "division_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "venue_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 300,
  },
  "home_score" => {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_score" => {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "cancelled" => {
    data_type => "tinyint",
    default_value => 0,
    is_nullable => 0,
  },
  "complete" => {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

__PACKAGE__->set_primary_key("home_team", "away_team", "scheduled_date");

=head2 id

If we need one ID, return a comma separated list of URL keys.

=cut

sub id {
  my ( $self ) = @_;
  
  return sprintf( "%s,%s,%s,%s,%d,%02d,%02d", $self->home_club_url_key, $self->home_team_url_key, $self->away_club_url_key, $self->away_team_url_key, $self->scheduled_date->year, $self->scheduled_date->month, $self->scheduled_date->day ); 
}

=head2 url_keys

Returns a hashref with the URL keys in the order we need to use them to generate URLs.

=cut

sub url_keys {
  my ( $self ) = @_;
  return [ $self->home_club_url_key, $self->home_team_url_key, $self->away_club_url_key, $self->away_team_url_key, $self->scheduled_date->year, sprintf("%02d", $self->scheduled_date->month), sprintf("%02d", $self->scheduled_date->day) ];
}

=head2 actual_date

Row-level helper method to get the match played date if there is one, or the scheduled date if not.

=cut

sub actual_date {
  my ( $self ) = @_;
  
  if ( defined( $self->played_date ) ) {
    return $self->played_date;
  } else {
    return $self->scheduled_date;
  }
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->match_name,
    url_keys => $self->url_keys,
    type => "team-match"
  };
}

1;