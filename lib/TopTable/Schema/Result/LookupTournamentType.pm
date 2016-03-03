use utf8;
package TopTable::Schema::Result::LookupTournamentType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::LookupTournamentType

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

=head1 TABLE: C<lookup_tournament_types>

=cut

__PACKAGE__->table("lookup_tournament_types");

=head1 ACCESSORS

=head2 id

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 display_order

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allowed_in_single_tournament_events

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 allowed_in_multi_tournament_events

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "display_order",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "allowed_in_single_tournament_events",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "allowed_in_multi_tournament_events",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<display_order>

=over 4

=item * L</display_order>

=back

=cut

__PACKAGE__->add_unique_constraint("display_order", ["display_order"]);

=head1 RELATIONS

=head2 tournaments

Type: has_many

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->has_many(
  "tournaments",
  "TopTable::Schema::Result::Tournament",
  { "foreign.entry_type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-06 22:16:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BGEMTl3BqTWcW7pBWjKFbw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
