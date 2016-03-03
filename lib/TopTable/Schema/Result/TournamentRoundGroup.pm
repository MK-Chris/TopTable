use utf8;
package TopTable::Schema::Result::TournamentRoundGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRoundGroup

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

=head1 TABLE: C<tournament_round_groups>

=cut

__PACKAGE__->table("tournament_round_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 group_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 group_order

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
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "group_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "group_order",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 tournament_round_group_individual_memberships

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroupIndividualMembership>

=cut

__PACKAGE__->has_many(
  "tournament_round_group_individual_memberships",
  "TopTable::Schema::Result::TournamentRoundGroupIndividualMembership",
  { "foreign.group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_group_team_memberships

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroupTeamMembership>

=cut

__PACKAGE__->has_many(
  "tournament_round_group_team_memberships",
  "TopTable::Schema::Result::TournamentRoundGroupTeamMembership",
  { "foreign.group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dEAnfz6ex0KfUyZhliJWQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
