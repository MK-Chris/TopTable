use utf8;
package TopTable::Schema::Result::LookupGridTeamType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::LookupGridTeamType

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

=head1 TABLE: C<lookup_grid_team_type>

=cut

__PACKAGE__->table("lookup_grid_team_type");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 type

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 10

=head2 player

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 display_order

  data_type: 'tinyint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "type",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 10 },
  "player",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "display_order",
  { data_type => "tinyint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 fixtures_grid_matches_away_team_types

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesGridMatch>

=cut

__PACKAGE__->has_many(
  "fixtures_grid_matches_away_team_types",
  "TopTable::Schema::Result::FixturesGridMatch",
  { "foreign.away_team_type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_grid_matches_home_team_types

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesGridMatch>

=cut

__PACKAGE__->has_many(
  "fixtures_grid_matches_home_team_types",
  "TopTable::Schema::Result::FixturesGridMatch",
  { "foreign.home_team_type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-08-15 20:43:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AWPlT8LWipcKdYH858zfMg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
