use utf8;
package TopTable::Schema::Result::Venue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Venue

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

=head1 TABLE: C<venues>

=cut

__PACKAGE__->table("venues");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 address1

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address2

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address3

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address4

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address5

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 postcode

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 240

=head2 coordinates_latitude

  data_type: 'float'
  is_nullable: 1
  size: [10,8]

=head2 coordinates_longitude

  data_type: 'float'
  is_nullable: 1
  size: [11,8]

=head2 active

  data_type: 'tinyint'
  default_value: 1
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
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "address1",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address2",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address3",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address4",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address5",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "postcode",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "telephone",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 240 },
  "coordinates_latitude",
  { data_type => "float", is_nullable => 1, size => [10, 8] },
  "coordinates_longitude",
  { data_type => "float", is_nullable => 1, size => [11, 8] },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 club_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::ClubSeason>

=cut

__PACKAGE__->has_many(
  "club_seasons",
  "TopTable::Schema::Result::ClubSeason",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 clubs

Type: has_many

Related object: L<TopTable::Schema::Result::Club>

=cut

__PACKAGE__->has_many(
  "clubs",
  "TopTable::Schema::Result::Club",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->has_many(
  "event_seasons",
  "TopTable::Schema::Result::EventSeason",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 meetings

Type: has_many

Related object: L<TopTable::Schema::Result::Meeting>

=cut

__PACKAGE__->has_many(
  "meetings",
  "TopTable::Schema::Result::Meeting",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_venues

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogVenue>

=cut

__PACKAGE__->has_many(
  "system_event_log_venues",
  "TopTable::Schema::Result::SystemEventLogVenue",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->has_many(
  "tournament_rounds",
  "TopTable::Schema::Result::TournamentRound",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue_timetables

Type: has_many

Related object: L<TopTable::Schema::Result::VenueTimetable>

=cut

__PACKAGE__->has_many(
  "venue_timetables",
  "TopTable::Schema::Result::VenueTimetable",
  { "foreign.venue" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WClnG5gi5QQPhA1xKPzehQ

use HTML::Entities;

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->url_key];
}

=head2 full_address

Type: Row-level helper method to get the address with blank lines removed.

=cut

sub full_address {
    my ( $self, $separator ) = @_;
    $separator ||= "\n";
    my @addr_fields = qw( address1 address2 address3 address4 address5 postcode );
    
    # Add each address line if it's not blank
    my @full_address = ();
    foreach my $addr_line ( @addr_fields ) {
      my $field = $self->$addr_line;
      push(@full_address, $field) if defined($field) and $field ne "";
    }
    
    # Return the string joined with linefeeds. 
    return join($separator, @full_address);
}

=head2 can_delete

Performs the logic checks to see if the venue can be deleted; returns true if it can or false if it can't.  A venue can be deleted if it has no clubs using it and if there are no matches that have used the venue.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # First check clubs using venue, as this will be quicker than checking the number of matches.
  my $clubs_using_venue = $self->search_related("clubs")->count;
  return 0 if $clubs_using_venue;
  
  # If there are no clubs using the venue, we need to check the matches
  my $matches_at_venue = $self->search_related("team_matches")->count;
  return 0 if $matches_at_venue;
  
  # If we get this far, we can delete.
  return 1;
}

=head2 can_deactivate

Performs the logic checks to see if the venue can be deactivated; returns true if it can or false if it can't.  A venue can be deactivated if it has no clubs *currently* using it.

=cut

sub can_deactivate {
  my ( $self ) = @_;
  
  # First check clubs using venue, as this will be quicker than checking the number of matches.
  my $season = $self->result_source->schema->resultset("Season")->get_current_or_last;
  
  my $clubs_using_venue = $self->search_related("club_seasons", {season => $season->id})->count;
  return 0 if $clubs_using_venue;
  
  # If we get this far, we can deactivated.
  return 1;
}

=head2 check_and_delete

Checks that the venue can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the name for messaging
  my $name = encode_entities($self->full_name);
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("venues.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Delete
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

=head2 get_full_timetable_by_day

Returns a hashref of timetable information for the venue with each key relating to a day of the week, containing an array of sessions on that day.

=cut

sub get_full_timetable_by_day {
  my ( $self ) = @_;
  my @db_timetables = $self->search_related("venue_timetables", undef, {
    prefetch => {venue_timetable_days => "day"},
    order_by => {-asc => [qw( start_time end_time )]},
  });
  
  if ( scalar @db_timetables ) {
    # We have some timetables, loop through and set them into days
    my $venue_timetable = {};
    foreach my $timetable_item ( @db_timetables ) {
      my $days = $timetable_item->venue_timetable_days;
      
      # Loop through each day that this timetable item is active for
      while ( my $day = $days->next ) {
        # Check if this day exists in the hash already; if not, create it as a new key
        if ( exists($venue_timetable->{$day->day->weekday_number}) ) {
          # Key exists, push this item on to it
          push(@{$venue_timetable->{$day->day->weekday_number}}, {
            session => $timetable_item,
          });
        } else {
          # Key doesn't exist, create it as an arrayref
          $venue_timetable->{$day->day->weekday_number} = [{
            session => $timetable_item,
          }];
        }
      }
    }
    
    # Return the hashref we've built up.
    return $venue_timetable;
  } else {
    # No timetable information, return undefined
    return undef;
  }
}

=head2 get_full_timetable_by_session

Returns an arrayref of timetable information (each session is one element of the array) for the venue with each key relating to a day of the week, containing an array of sessions on that day.

=cut

sub get_full_timetable_by_session {
  my ( $self ) = @_;
#   my @db_timetables = $self->search_related("venue_timetables", {}, {
#     prefetch => {
#       venue_timetable_days => "day",
#     }, {
#       order_by => {
#         -asc => [ qw( start_time end_time ) ],
#       },
#     }
#   });
  
  my @db_timetables = $self->search_related("venue_timetables", {}, {
    prefetch => {venue_timetable_days => "day"},
    order_by => {-asc => [qw( start_time end_time )]},
  });
  
  if ( scalar( @db_timetables ) ) {
    # Return a reference to the lookup array
    return \@db_timetables;
  } else {
    # No timetable information, return undefined
    return undef;
  }
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name,
    url_keys => $self->url_keys,
    type => "venue"
  };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
