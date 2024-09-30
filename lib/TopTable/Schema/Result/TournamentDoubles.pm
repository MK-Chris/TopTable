use utf8;
package TopTable::Schema::Result::TournamentDoubles;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentDoubles

=head1 DESCRIPTION

Holds doubles pairs for both team tournaments and doubles tournaments.

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

=head1 TABLE: C<tournament_doubles>

=cut

__PACKAGE__->table("tournament_doubles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 person1

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person2

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person1_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

References the active team membership for this person, unless this is a team entry tournament, in which case it specifically references the doubles paring for this team

=head2 person2_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

References the active team membership for this person, unless this is a team entry tournament, in which case it specifically references the doubles paring for this team

=head2 person1_first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 person1_surname

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 person1_display_name

  data_type: 'varchar'
  is_nullable: 0
  size: 301

=head2 person1_loan

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person2_first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 person2_surname

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 person2_display_name

  data_type: 'varchar'
  is_nullable: 0
  size: 301

=head2 person2_loan

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

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

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
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
  "event",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "season_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "person1",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person2",
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
  "person1_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person2_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person1_first_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "person1_surname",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "person1_display_name",
  { data_type => "varchar", is_nullable => 0, size => 301 },
  "person1_loan",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person2_first_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "person2_surname",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "person2_display_name",
  { data_type => "varchar", is_nullable => 0, size => 301 },
  "person2_loan",
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
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 person1

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person1",
  "TopTable::Schema::Result::Person",
  { id => "person1" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person2

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person2",
  "TopTable::Schema::Result::Person",
  { id => "person2" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person_season_person1_season_person1_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->belongs_to(
  "person_season_person1_season_person1_team",
  "TopTable::Schema::Result::PersonSeason",
  { person => "person1", season => "season", team => "person1_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person_season_person2_season_person2_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->belongs_to(
  "person_season_person2_season_person2_team",
  "TopTable::Schema::Result::PersonSeason",
  { person => "person2", season => "season", team => "person2_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 season_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->belongs_to(
  "season_pair",
  "TopTable::Schema::Result::DoublesPair",
  { id => "season_pair" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 tournament

Type: belongs_to

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->belongs_to(
  "tournament",
  "TopTable::Schema::Result::Tournament",
  { event => "event", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_rounds_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_rounds_doubles",
  "TopTable::Schema::Result::TournamentRoundDoubles",
  { "foreign.tournament_pair" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Zj3vijh8ftTbFwekgQmdcA

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 object_id

Return the ID of the doubles pair linked.  The ID for doubles is the tournament_doubles ID, since we may not necessarily link to a doubles pair that have played in the league season together.

In this case, this is just the ID, but it's here for compatibility with the team / person object_id calls so we can call it on any of them.

=cut

sub object_id {
  my $self = shift;
  return $self->id;
}

=head2 object_name

Get the names of the doubles pairs separated by an ampersand: "Player One & Player Two".

=cut

sub object_name {
  my $self = shift;
  
  my $person1_name = $self->person_season_person1_season_person1_team->display_name;
  my $person2_name = $self->person_season_person2_season_person2_team->display_name;
  return "$person1_name & $person2_name";
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
