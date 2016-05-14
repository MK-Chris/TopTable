use utf8;
package TopTable::Schema::Result::Season;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Season

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

=head1 TABLE: C<seasons>

=cut

__PACKAGE__->table("seasons");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 default_match_start

  data_type: 'time'
  is_nullable: 0

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 start_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 allow_loan_players_below

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allow_loan_players_above

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allow_loan_players_across

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allow_loan_players_multiple_teams_per_division

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allow_loan_players_same_club_only

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 loan_players_limit_per_player

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 loan_players_limit_per_player_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 loan_players_limit_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 rules

  data_type: 'longtext'
  is_nullable: 1

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
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "default_match_start",
  { data_type => "time", is_nullable => 0 },
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "start_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "complete",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "allow_loan_players_below",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_above",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_across",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_multiple_teams_per_division",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_same_club_only",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_player",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_player_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "rules",
  { data_type => "longtext", is_nullable => 1 },
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
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->has_many(
  "event_seasons",
  "TopTable::Schema::Result::EventSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_weeks",
  "TopTable::Schema::Result::FixturesWeek",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 officials

Type: has_many

Related object: L<TopTable::Schema::Result::Official>

=cut

__PACKAGE__->has_many(
  "officials",
  "TopTable::Schema::Result::Official",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->has_many(
  "person_seasons",
  "TopTable::Schema::Result::PersonSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogSeason>

=cut

__PACKAGE__->has_many(
  "system_event_log_seasons",
  "TopTable::Schema::Result::SystemEventLogSeason",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons_intervals

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeasonsInterval>

=cut

__PACKAGE__->has_many(
  "team_seasons_intervals",
  "TopTable::Schema::Result::TeamSeasonsInterval",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-02-02 09:27:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cbMCrtdx2rfZrrj/BSbikg

use HTML::Entities;

=head2 number_of_weeks

Returns the number of weeks in the season.

=cut

sub number_of_weeks {
  my ( $self ) = @_;
  
  my $season_weeks;
  for (my $dt = $self->start_date->clone; $dt <= $self->end_date; $dt->add( weeks => 1 ) ) {
    $season_weeks++;
  }
  
  return $season_weeks;
}

=head2 start_date_long

Return the long start date for the season.

=cut

sub start_date_long {
  my ( $self ) = @_;
  return sprintf( "%s, %s %s %s", ucfirst( $self->start_date->day_name ), $self->start_date->day, $self->start_date->month_name, $self->start_date->year );
}

=head2 end_date_long

Return the long end date for the season.

=cut

sub end_date_long {
  my ( $self ) = @_;
  return sprintf( "%s, %s %s %s", ucfirst( $self->end_date->day_name ), $self->end_date->day, $self->end_date->month_name, $self->end_date->year );
}

=head2 divisions

Return the divisions that have an association with the season.

=cut

sub divisions {
  my ( $self ) = @_;
  
  return $self->search_related("division_seasons", undef, {
    prefetch  => "division",
    order_by  => {
      -asc    => [qw( rank )],
    }
  });
}

=head2 can_complete

Checks whether or not we can complete this season, by checking that the matches are either completed or cancelled.  There may be other additions to this in future.

=cut

sub can_complete {
  my ( $self ) = @_;
  
  # First check the season is not already complete - if it is, we can't complete it again.
  return 0 if $self->complete;
  
  # Now check matches - return 0 straight away if there are any matches that are incomplete and not cancelled for this season
  return 0 if $self->result_source->schema->resultset("TeamMatch")->incomplete_and_not_cancelled({season => $self})->count > 0;
  
  # If we get this far, return a true value because we can complete the season
  return 1;
}

=head2 check_and_complete

Update the season to show that it's now complete (if possible).

=cut

sub check_and_complete {
  my ( $self, $parameters ) = @_;
  my $lang  = $parameters->{lang};
  my $encoded_name = encode_entities( $self->name );
  my $error = [];
  
  # Check we can delete
  if ( $self->complete ) {
    push( @{ $error }, $lang->("seasons.complete.error.season-complete", $encoded_name) );
    return $error;
  }
  
  if ( $self->result_source->schema->resultset("TeamMatch")->incomplete_and_not_cancelled({season => $self})->count > 0 ) {
    push( @{ $error }, $lang->("seasons.complete.error.matches-incomplete", $encoded_name) );
    return $error;
  }
  
  # Delete
  my $ok = $self->update({complete => 1}) if !scalar( @{ $error } );
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "seasons.complete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

=head2 can_uncomplete

This is here so we can call it from controllers, but there's no routine to uncomplete yet, so at the momen this just returns false.

=cut

sub can_uncomplete {
  my ( $self ) = @_;
  return 0;
}

=head2 can_delete

Performs some logic checks to see whether or not a season can be deleted.  A season can be deleted if there are no matches in it.

=cut

sub can_delete {
 my ( $self ) = @_;
 my $matches = $self->search_related("team_matches")->count;
 
 return ( $matches == 0 ) ? 1 : 0;
}

=head2 check_and_delete

Checks that the season can be deleted (via can_delete) and then does the deletion.

=cut

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "seasons.delete.error.matches-exist",
    parameters  => [$self->name],
  }) unless $self->can_delete;
  
  # Delete
  my $ok = $self->delete if !$error;
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
