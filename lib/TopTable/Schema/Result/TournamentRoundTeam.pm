use utf8;
package TopTable::Schema::Result::TournamentRoundTeam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRoundTeam

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

=head1 TABLE: C<tournament_round_teams>

=cut

__PACKAGE__->table("tournament_round_teams");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tournament_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 0
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
  "tournament_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
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
    default_value => 0,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 tournament_group_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentGroupTeam>

=cut

__PACKAGE__->has_many(
  "tournament_group_teams",
  "TopTable::Schema::Result::TournamentGroupTeam",
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 tournament_round_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundPerson>

=cut

__PACKAGE__->has_many(
  "tournament_round_people",
  "TopTable::Schema::Result::TournamentRoundPerson",
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_rounds_doubles",
  "TopTable::Schema::Result::TournamentRoundDoubles",
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentTeam>

=cut

__PACKAGE__->belongs_to(
  "tournament_team",
  "TopTable::Schema::Result::TournamentTeam",
  { id => "tournament_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JDlACgh0zSepO0V24HBOcQ

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 object_id

Return the ID of the team linked.

=cut

sub object_id {
  my $self = shift;
  return $self->tournament_team->team_season->team->id;
}

=head2 object_name

Get the name of the team from the team season object linked.

=cut

sub object_name {
  my $self = shift;
  
  my $team_season = $self->tournament_team->team_season;
  return sprintf("%s %s", $team_season->club_season->short_name, $team_season->name);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
