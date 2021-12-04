use utf8;
package TopTable::Schema::Result::Division;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Division

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

=head1 TABLE: C<divisions>

=cut

__PACKAGE__->table("divisions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 rank

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "rank",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 division_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->has_many(
  "division_seasons",
  "TopTable::Schema::Result::DivisionSeason",
  { "foreign.division" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_divisions

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogDivision>

=cut

__PACKAGE__->has_many(
  "system_event_log_divisions",
  "TopTable::Schema::Result::SystemEventLogDivision",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons_intervals

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeasonsInterval>

=cut

__PACKAGE__->has_many(
  "team_seasons_intervals",
  "TopTable::Schema::Result::TeamSeasonsInterval",
  { "foreign.division" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-03 10:04:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LDGauLeNZKMTw8uNt3m44A

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [ $self->url_key ];
}

=head2 get_season

Retrieve the division_seasons object for this division and the specified season.

=cut

sub get_season {
  my ( $self, $season ) = @_;
  
  return $self->search_related("division_seasons", {
    season  => $season->id,
  }, {
    rows    => 1,
  })->single;
}

=head2 last_season_used

Return the last season this division was used.

=cut

sub last_season_used {
  my ( $self ) = @_;
  
  my $div_season = $self->search_related("division_seasons", undef, {
    join => "season",
    rows => 1,
    order_by => {
      -desc => [qw( season.start_date season.end_date )]
    },
  })->single;
  
  return defined( $div_season ) ? $div_season->season : undef;
}

=head2 teams

Return a list of teams in the given season.

=cut

sub teams {
  my ( $self, $params ) = @_;
  my $season = delete $params->{season};
  
  my $div_season = $self->find_related("division_seasons", {season => $season});
  
  # Return 0 if this division wasn't used for this season.
  return undef unless defined( $div_season );
  
  return $div_season->search_related("team_seasons");
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name,
    url_keys => $self->url_keys,
    type => "division"
  };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
