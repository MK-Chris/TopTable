use utf8;
package TopTable::Schema::Result::PersonSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::PersonSeason

=head1 DESCRIPTION

Register players (from the person table) with team links (in the team_links table).  Team links in turn link to a league season.  This table holds averages for that particular link

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

=head1 TABLE: C<person_seasons>

=cut

__PACKAGE__->table("person_seasons");

=head1 ACCESSORS

=head2 person

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 surname

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 display_name

  data_type: 'varchar'
  is_nullable: 0
  size: 301

=head2 registration_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 fees_paid

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Stores the number of matches the players has played in that the team has won.

=head2 matches_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Stores the number of matches the players has played in that the team has drawn.

=head2 matches_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Stores the number of matches the players has played in that the team has lost.

=head2 games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 team_membership_type

  data_type: 'varchar'
  default_value: 'active'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "person",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "surname",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "display_name",
  { data_type => "varchar", is_nullable => 0, size => 301 },
  "registration_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "fees_paid",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "team_membership_type",
  {
    data_type => "varchar",
    default_value => "active",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 20,
  },
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</person>

=item * L</season>

=item * L</team>

=back

=cut

__PACKAGE__->set_primary_key("person", "season", "team");

=head1 RELATIONS

=head2 doubles_pairs_person1_season_teams

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs_person1_season_teams",
  "TopTable::Schema::Result::DoublesPair",
  {
    "foreign.person1" => "self.person",
    "foreign.season"  => "self.season",
    "foreign.team"    => "self.team",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 doubles_pairs_person2_season_teams

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs_person2_season_teams",
  "TopTable::Schema::Result::DoublesPair",
  {
    "foreign.person2" => "self.person",
    "foreign.season"  => "self.season",
    "foreign.team"    => "self.team",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "TopTable::Schema::Result::Person",
  { id => "person" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 season

Type: belongs_to

Related object: L<TopTable::Schema::Result::Season>

=cut

__PACKAGE__->belongs_to(
  "season",
  "TopTable::Schema::Result::Season",
  { id => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_membership_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupTeamMembershipType>

=cut

__PACKAGE__->belongs_to(
  "team_membership_type",
  "TopTable::Schema::Result::LookupTeamMembershipType",
  { id => "team_membership_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->belongs_to(
  "team_season",
  "TopTable::Schema::Result::TeamSeason",
  { season => "season", team => "team" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 tournament_doubles_person1_season_person1_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_doubles_person1_season_person1_teams",
  "TopTable::Schema::Result::TournamentDoubles",
  {
    "foreign.person1"      => "self.person",
    "foreign.person1_team" => "self.team",
    "foreign.season"       => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_doubles_person2_season_person2_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_doubles_person2_season_person2_teams",
  "TopTable::Schema::Result::TournamentDoubles",
  {
    "foreign.person2"      => "self.person",
    "foreign.person2_team" => "self.team",
    "foreign.season"       => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentPerson>

=cut

__PACKAGE__->has_many(
  "tournament_people",
  "TopTable::Schema::Result::TournamentPerson",
  {
    "foreign.person" => "self.person",
    "foreign.season" => "self.season",
    "foreign.team"   => "self.team",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DSkS7j6ImYO99a0djKcYjA

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 0, },
);

=head2 averages_position

Get the averages position of this person for the team / season association.

=cut

sub averages_position {
  my ( $self ) = @_;
  my $season = $self->season;
  
  my $division = $self->team->find_related("team_seasons", {season => $season->id})->division;
  
  my @people = $self->result_source->resultset->get_people_in_division_in_singles_averages_order({
    season => $season,
    division => $division,
  });
  
  # Loop through our people, counting up, until we find this person's ID
  my $i = 0;
  for my $person_position ( @people ) {
    # Increment our count
    $i++;
    
    # Return with the current position if we've found our person
    last if $person_position->person->id == $self->person->id;
  }
  
  # Return the position we found
  return $i;
}

=head2 available_matches

Return the number of available matches (matches the person's team has played for active memberships; for loan / inactive memberships it's the number of matches played).

=cut

sub available_matches {
  my ( $self ) = @_;
  
  if ( $self->team_membership_type->id eq "active" ) {
    # Active - return the number of matches the person's team has played minus the number of cancelled matches
    # (because a cancelled match still goes on the matches_played).
    return $self->team_season->matches_played - $self->team_season->matches_cancelled;
  } else {
    # Loan / inactive, return matches played
    return $self->matches_played;
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
