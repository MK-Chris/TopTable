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

=head2 start_date_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 all_day

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 end_date_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

Time will be an approximate value in minutes; the value can then be converted in the script to hours / an end time.

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
  "start_date_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "all_day",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "end_date_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-21 16:36:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xqih/JGxlswNcHqibfaH6g

use DateTime;

# Add UTC time zone to date / time columns
__PACKAGE__->add_columns(
    "start_date_time",
    { data_type => "datetime", timezone => "UTC", datetime_undef_if_invalid => 1, is_nullable => 1, },
    "end_date_time",
    { data_type => "datetime", timezone => "UTC", datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 ends_on_different_day

Work out whether the end date of the event is on a different day to the start date.

=cut

sub ends_on_different_day {
  my $self = shift;
  
  # Truncate the times off then compare
  return DateTime->compare($self->start_date_time->truncate(to => "day"), $self->end_date_time->truncate(to => "day")) == 0 ? 0 : 1;
}

=head2 event_detail

Returns a different detail depending on the event.

=cut

sub event_detail {
  my $self = shift;
  
  # Get the event type
  my $event_type = $self->event->event_type->id;
  my %attribs = ();
  
  if ( $event_type eq "meeting" ) {
    return $self->search_related("meetings", {}, {rows => 1})->single;
  } elsif ( $event_type eq "single_tournament" ) {
    my $tournament = $self->find_related("tournaments", {});
    my $entry_type = $tournament->entry_type->id;
    my $has_group_round = $tournament->has_group_round;
    
    # Set the initial prefetch that will hold the rounds / groups
    if ( $has_group_round ) {
      # Get the groups along with participants
      if ( $entry_type eq "teams" ) {
        # Grab the teams
        %attribs = (
          prefetch => [qw( entry_type tournament_teams ), {
            tournament_rounds => [qw( tournament_round_groups )],
          }],
        );
      } elsif ( $entry_type eq "singles" ) {
        # Grab the players
        %attribs = (
          prefetch => [qw( entry_type tournament_people ), {
            tournament_rounds => [qw( tournament_round_groups )],
          }],
        );
      } elsif ( $entry_type eq "doubles" ) {
        # Grab the pairs
        %attribs = (
          prefetch => [qw( entry_type tournament_doubles ), {
            tournament_rounds => [qw( tournament_round_groups )],
          }],
        );
      }
    } else {
      if ( $entry_type eq "teams" ) {
        # Grab the teams
        %attribs = (
          prefetch => [qw( entry_type tournament_teams tournament_rounds )],
        );
      } elsif ( $entry_type eq "singles" ) {
        # Grab the players
        %attribs = (
          prefetch => [qw( entry_type tournament_people tournament_rounds )],
        );
      } elsif ( $entry_type eq "doubles" ) {
        # Grab the pairs
        %attribs = (
          prefetch => [qw( entry_type tournament_doubles tournament_rounds )],
        );
      }
    }
    
    return $self->find_related("tournaments", {}, \%attribs);
  }
}

=head2 attendees

Get the attendees for this event (if it's a meeting; if it's not, return undef).

=cut

sub attendees {
  my $self = shift;
  my $event_type = $self->event->event_type->id;
  
  if ( $event_type eq "meeting" ) {
    return $self->search_related("meetings", undef, {rows => 1})->single->attendees;
  } else {
    return undef;
  }
}

=head2 apologies

Get the attendees for this event (if it's a meeting; if it's not, return undef).

=cut

sub apologies {
  my $self = shift;
  my $event_type = $self->event->event_type->id;
  
  if ( $event_type eq "meeting" ) {
    return $self->search_related("meetings", undef, {rows => 1})->single->apologies;
  } else {
    return undef;
  }
}

=head2 set_details

Set the details of this season's event.  What exactly happens here depends on the type of event.

=cut

sub set_details {
  my $self = shift;
  
  if ( $self->event->event_type->id eq "meeting" ) {
    return $self->_set_meeting_details(@_);
  }
}

=head2 get_meeting

Get the meeting object.

=cut

sub get_meeting {
  my $self = shift;
  return $self->search_related("meetings", undef, {rows => 1})->single;
}

=head2 _set_meeting_details

Called internally by set_details if the event is a meeting

=cut

sub _set_meeting_details {
  my $self = shift;
  my ( $params ) = @_;
  
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Get the specific meeting
  my $meeting = $self->get_meeting;
  
  # Grab the fields
  my $attendees = $params->{attendees} || [];
  my $apologies = $params->{apologies} || [];
  my $agenda = $params->{agenda} || undef;
  my $minutes = $params->{minutes} || undef;
  
  # Set the response hash up
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      agenda => $agenda,
      minutes => $minutes,
    },
    completed => 0,
  };
  
  # Prepare the people for DB insert / update / delete
  my $people = $schema->resultset("Meeting")->prepare_attendees_for_update({
    meeting => $meeting,
    attendees => $attendees,
    apologies => $apologies,
    logger => $logger,
  });
  
  # Now check if we have anyone who appears on both lists
  if ( scalar(@{$people->{conflict}}) == 1 ) {
    # One person on both lists elicits a different message to multiple people
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.attendee-on-both-lists", encode_entities($people->{conflict}[0]->display_name)));
  } elsif ( scalar(@{$people->{conflict}}) > 1 ) {
    # Multiple people on both lists, get their names and encode them for the error message
    # Save the number of conflicts, as we'll be popping the last one off here to build the message, so we need to get the total number early on
    my $conflicts = @{$people->{conflict}};
    
    # Now join all the remaining elements with ", " and add " and $last" to the end of it
    my @people_names = map(encode_entities($_->display_name), @{$people->{conflict}});
    
    # Get the last element from the list, as we don't want this to have commas before it
    my $last = pop(@people_names);
    
    my $conflict_people = sprintf("%s %s %s", join(", ", @people_names), $lang->maketext("msg.and"), $last);
    
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.attendees-on-both-lists", $conflicts, $conflict_people));
  }
  
  # Check for invalid attendees / apologies
  push(@{$response->{errors}}, $lang->maketext("meetings.form.error.attendees-invalid", $people->{attendees}{invalid})) if $people->{attendees}{invalid};
  push(@{$response->{errors}}, $lang->maketext("meetings.form.error.apologies-invalid", $people->{apologies}{invalid})) if $people->{apologies}{invalid};
  
  # Start a transaction so we don't have a partially updated database
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  $meeting->update({
    agenda => $agenda,
    minutes => $minutes,
  });
  
  # Now sort out our attendees from the prepared list
  $meeting->update_attendees($people);
  $response->{completed} = 1;
  
  $transaction->commit;
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
