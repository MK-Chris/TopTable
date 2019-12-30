use utf8;
package TopTable::Schema::Result::EventSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::EventSeason

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

=head1 TABLE: C<event_seasons>

=cut

__PACKAGE__->table("event_seasons");

=head1 ACCESSORS

=head2 event

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 date_and_start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 all_day

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 finish_time

  data_type: 'time'
  is_nullable: 1

=head2 organiser

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 description

  data_type: 'longtext'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "event",
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "date_and_start_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "all_day",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "finish_time",
  { data_type => "time", is_nullable => 1 },
  "organiser",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "description",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</event>

=item * L</season>

=back

=cut

__PACKAGE__->set_primary_key("event", "season");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<TopTable::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "TopTable::Schema::Result::Event",
  { id => "event" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 meetings

Type: has_many

Related object: L<TopTable::Schema::Result::Meeting>

=cut

__PACKAGE__->has_many(
  "meetings",
  "TopTable::Schema::Result::Meeting",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 organiser

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "organiser",
  "TopTable::Schema::Result::Person",
  { id => "organiser" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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

=head2 tournaments

Type: has_many

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->has_many(
  "tournaments",
  "TopTable::Schema::Result::Tournament",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue

Type: belongs_to

Related object: L<TopTable::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "TopTable::Schema::Result::Venue",
  { id => "venue" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-12-26 23:42:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wg1SezM31AR7gYsUEJt2AA

=head2 event_detail

Returns a different detail depending on the event.

=cut

sub event_detail {
  my ( $self ) = @_;
  
  # Get the event type
  my $event_type = $self->event->event_type->id;
  
  if ( $event_type eq "meeting" ) {
    return $self->search_related("meetings", undef, {rows => 1})->single;
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
