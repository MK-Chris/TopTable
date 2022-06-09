use utf8;
package TopTable::Schema::Result::Meeting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Meeting

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

=head1 TABLE: C<meetings>

=cut

__PACKAGE__->table("meetings");

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
  is_nullable: 1

Only populated if the meeting is created out of an event - otherwise it will be a ENGINE selected below.

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Only populated if the meeting is created out of an event - otherwise it will be a ENGINE selected below.

=head2 type

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Only populated if the meeting is NOT created out of an event.

=head2 organiser

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Only populated if the meeting is NOT created out of an event - otherwise the venue will be specified in the event details.

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Only populated if the meeting is NOT created out of an event - otherwise the location will be specified in the event details.

=head2 date_and_start_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Only populated if the meeting is NOT created out of an event - otherwise the date will be specified in the event details.

=head2 all_day

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 finish_time

  data_type: 'time'
  is_nullable: 1

=head2 agenda

  data_type: 'longtext'
  is_nullable: 1

=head2 minutes

  data_type: 'longtext'
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
    is_nullable => 1,
  },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "type",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
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
  "agenda",
  { data_type => "longtext", is_nullable => 1 },
  "minutes",
  { data_type => "longtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->belongs_to(
  "event_season",
  "TopTable::Schema::Result::EventSeason",
  { event => "event", season => "season" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 meeting_attendees

Type: has_many

Related object: L<TopTable::Schema::Result::MeetingAttendee>

=cut

__PACKAGE__->has_many(
  "meeting_attendees",
  "TopTable::Schema::Result::MeetingAttendee",
  { "foreign.meeting" => "self.id" },
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

=head2 system_event_log_meetings

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogMeeting>

=cut

__PACKAGE__->has_many(
  "system_event_log_meetings",
  "TopTable::Schema::Result::SystemEventLogMeeting",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 type

Type: belongs_to

Related object: L<TopTable::Schema::Result::MeetingType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "TopTable::Schema::Result::MeetingType",
  { id => "type" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:opBrDUZ+RvSZYQoAlOOMyA

=head2 is_event

Detects whether or not this meeting is associated with an event in the events table.

=cut

sub is_event {
  my ( $self ) = @_;
  return ( defined($self->event) ) ? 1 : 0;
}

=head2 attendees

Returns a list or resultset of people who attended the meeting.

=cut

sub attendees {
  my ( $self ) = @_;
  
  return $self->search_related("meeting_attendees", {
    apologies => 0,
  }, {
    prefetch => "person",
    order_by  => {-asc => [qw( surname first_name )]},
  });
}

=head2 apologies

Returns a list or resultset of people who apologised for NOT attended the meeting.

=cut

sub apologies {
  my ( $self ) = @_;
  
  return $self->search_related("meeting_attendees", {
    apologies => 1,
  }, {
    prefetch => "person",
    order_by  => {-asc => [qw( surname first_name )]},
  });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
