use utf8;
package TopTable::Schema::Result::LookupWeekday;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::LookupWeekday

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

=head1 TABLE: C<lookup_weekdays>

=cut

__PACKAGE__->table("lookup_weekdays");

=head1 ACCESSORS

=head2 weekday_number

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 weekday_name

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "weekday_number",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "weekday_name",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</weekday_number>

=back

=cut

__PACKAGE__->set_primary_key("weekday_number");

=head1 UNIQUE CONSTRAINTS

=head2 C<weekday_name>

=over 4

=item * L</weekday_name>

=back

=cut

__PACKAGE__->add_unique_constraint("weekday_name", ["weekday_name"]);

=head1 RELATIONS

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.home_night" => "self.weekday_number" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue_timetables

Type: has_many

Related object: L<TopTable::Schema::Result::VenueTimetable>

=cut

__PACKAGE__->has_many(
  "venue_timetables",
  "TopTable::Schema::Result::VenueTimetable",
  { "foreign.day" => "self.weekday_number" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-08 16:54:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f1GWZmnAZIAoo+ZxVXHACg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
