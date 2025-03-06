package TopTable::Schema::Result::VwClubTeam;

=head1 NAME

TopTable::Schema::Result::VwClubTeam - a view to get the team information and club together for searching.

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

=head1 VIEW: C<vw_club_teams>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_club_teams");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT c.id AS 'club_id', c.url_key AS 'club_url_key', t.id AS 'team_id', t.url_key AS 'team_url_key', s.id AS 'season_id', s.url_key AS 'season_url_key', s.name AS 'season_name', s.start_date AS 'season_start_date', s.end_date AS 'season_end_date', s.complete AS 'season_complete', CONCAT(c.short_name, ' ', t.name) AS 'team_with_club', CONCAT(c.abbreviated_name, ' ', t.name) AS 'abbreviated_team_with_club', c.full_name AS 'club_full_name'
  FROM teams t
  JOIN clubs c
  ON t.club = c.id
  JOIN team_seasons ts
  ON ts.team = t.id
  JOIN seasons s
  ON ts.season = s.id"
);

__PACKAGE__->add_columns(
  "club_id" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "club_url_key" => {
    data_type => "varchar",
    is_nullable => 1,
    size => 45,
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
    size => 45
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
  "team_with_club" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301,
  },
  "abbreviated_team_with_club" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 170,
  },
  "club_full_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 300
  },
);

__PACKAGE__->set_primary_key("team_id", "season_id");

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->club_url_key, $self->team_url_key];
}

=head2 last_season_entered

Return the season this team was last entered in.

=cut

sub last_season_entered {
  my ( $self ) = @_;
  
  return $self->result_source->schema->resultset("Season")->search({
    "team_seasons.team" => $self->team_id,
  }, {
    join => "team_seasons",
    order_by => {-desc => [qw( me.start_date me.end_date )]},
    rows => 1,
  })->single;
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->team_id,
    name => $self->team_with_club,
    url_keys => $self->url_keys,
    type => "team"
  };
}

1;
