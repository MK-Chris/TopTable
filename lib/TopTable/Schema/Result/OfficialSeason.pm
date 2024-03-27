use utf8;
package TopTable::Schema::Result::OfficialSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::OfficialSeason

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

=head1 TABLE: C<official_seasons>

=cut

__PACKAGE__->table("official_seasons");

=head1 ACCESSORS

=head2 official

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 position_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 position_order

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "official",
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
  "position_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "position_order",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</official>

=item * L</season>

=back

=cut

__PACKAGE__->set_primary_key("official", "season");

=head1 RELATIONS

=head2 official

Type: belongs_to

Related object: L<TopTable::Schema::Result::Official>

=cut

__PACKAGE__->belongs_to(
  "official",
  "TopTable::Schema::Result::Official",
  { id => "official" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 official_season_people

Type: has_many

Related object: L<TopTable::Schema::Result::OfficialSeasonPerson>

=cut

__PACKAGE__->has_many(
  "official_season_people",
  "TopTable::Schema::Result::OfficialSeasonPerson",
  {
    "foreign.official" => "self.official",
    "foreign.season"   => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 position_holders

Type: many_to_many

Composing rels: L</official_season_people> -> position_holder

=cut

__PACKAGE__->many_to_many(
  "position_holders",
  "official_season_people",
  "position_holder",
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-03-25 13:28:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lIqmMZEKqdtrcxll+JN7fQ

=head2 positioned_before

Return the OfficialSeason object positioned after this one (i.e., the one that this is positioned before)

=cut

sub next_position {
  my ( $self ) = @_;
  
  # Return the next position on from us in the list (the one that this is 'ordered before')
  return $self->result_source->schema->resultset("OfficialSeason")->find({
    season => $self->season->id,
    position_order => {">" => $self->position_order},
  }, {
    prefetch => "official",
    order_by => {-asc => [qw( position_order )]},
    rows => 1,
  });
}

=head2 check_holder

Check the given person is the holder of this position in this season.

=cut

sub check_holder {
  my ( $self, $person ) = @_;
  
  # Return 1 if this person holds the position, or 0 if not.
  return defined($self->find_related("official_season_people", {position_holder => $person->id})) ? 1 : 0;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
