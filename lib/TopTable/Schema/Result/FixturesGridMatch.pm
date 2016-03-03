use utf8;
package TopTable::Schema::Result::FixturesGridMatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesGridMatch

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

=head1 TABLE: C<fixtures_grid_matches>

=cut

__PACKAGE__->table("fixtures_grid_matches");

=head1 ACCESSORS

=head2 grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 week

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 match_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 away_team

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "week",
  {
    data_type => "tinyint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "match_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "home_team",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "away_team",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</grid>

=item * L</week>

=item * L</match_number>

=back

=cut

__PACKAGE__->set_primary_key("grid", "week", "match_number");

=head1 RELATIONS

=head2 fixtures_grid_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGridWeek>

=cut

__PACKAGE__->belongs_to(
  "fixtures_grid_week",
  "TopTable::Schema::Result::FixturesGridWeek",
  { grid => "grid", week => "week" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0yzYThN8SEwoh7wL0/ZB5Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
