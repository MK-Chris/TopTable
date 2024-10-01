use utf8;
package TopTable::Schema::Result::TournamentRoundDoubles;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRoundDoubles

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

=head1 TABLE: C<tournament_round_doubles>

=cut

__PACKAGE__->table("tournament_round_doubles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tournament_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_round_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
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
  "tournament_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tournament_round_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
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

=head2 tournament_groups_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentGroupDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_groups_doubles",
  "TopTable::Schema::Result::TournamentGroupDoubles",
  { "foreign.tournament_round_pair" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->belongs_to(
  "tournament_pair",
  "TopTable::Schema::Result::TournamentDoubles",
  { id => "tournament_pair" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_round

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->belongs_to(
  "tournament_round",
  "TopTable::Schema::Result::TournamentRound",
  { id => "tournament_round" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_round_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRoundTeam>

=cut

__PACKAGE__->belongs_to(
  "tournament_round_team",
  "TopTable::Schema::Result::TournamentRoundTeam",
  { id => "tournament_round_team" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PP7uBIWIcvfGFymlgTagOg

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 object_id

Return the ID of the doubles pair linked.  The ID for doubles is the tournament_doubles ID, since we may not necessarily link to a doubles pair that have played in the league season together.

=cut

sub object_id {
  my $self = shift;
  return $self->tournament_pair->id;
}

=head2 object_name

Get the names of the doubles pairs separated by an ampersand: "Player One & Player Two".

=cut

sub object_name {
  my $self = shift;
  
  my $person1_name = $self->tournament_pair->person_season_person1_season_person1_team->display_name;
  my $person2_name = $self->tournament_pair->person_season_person2_season_person2_team->display_name;
  return "$person1_name & $person2_name";
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;