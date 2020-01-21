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

=head2 tournament_team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches",
  "TopTable::Schema::Result::TournamentTeamMatch",
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-15 14:32:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lrjQxlbcbmzn62yIj7eNtQ


#
# Row-level helper methods
#
=head2 full_address

Type: Row-level helper method to get the address with blank lines removed.

=cut

sub full_address {
    my ( $self, $separator ) = @_;
    my @full_address = ();
    $separator ||= "\n";
    
    # Add each address line if it's not blank
    push(@full_address, $self->address1) if $self->address1 ne "";
    push(@full_address, $self->address2) if $self->address2 ne "";
    push(@full_address, $self->address3) if $self->address3 ne "";
    push(@full_address, $self->address4) if $self->address4 ne "";
    push(@full_address, $self->address5) if $self->address5 ne "";
    push(@full_address, $self->postcode) if $self->postcode ne "";
    
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

=head2 check_and_delete

Checks that the venue can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "venues.delete.error.not-allowed",
    parameters  => [$self->name],
  }) unless $self->can_delete;
  
  # Delete
  my $ok = $self->delete unless scalar( @{ $error } );
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

=head2 get_full_timetable_by_day

Returns a hashref of timetable information for the venue with each key relating to a day of the week, containing an array of sessions on that day.

=cut

sub get_full_timetable_by_day {
  my ( $self ) = @_;
  my @db_timetables = $self->search_related("venue_timetables", {}, {
    prefetch => {
      venue_timetable_days => "day",
    }, {
      order_by => {
        -asc => [ qw( day.weekday_number start_time end_time ) ],
      },
    }
  });
  
  if ( scalar( @db_timetables ) ) {
    # We have some timetables, loop through and set them into days
    my $venue_timetable = {};
    foreach my $timetable_item ( @db_timetables ) {
      my $days = $timetable_item->venue_timetable_days;
      
      # Loop through each day that this timetable item is active for
      while ( my $day = $days->next ) {
        # Check if this day exists in the hash already; if not, create it as a new key
        if ( exists( $venue_timetable->{$day->day->weekday_number} ) ) {
          # Key exists, push this item on to it
          push( @{ $venue_timetable->{$day->day->weekday_number} }, {
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
    prefetch => {
      venue_timetable_days => "day",
    },
    order_by => {
      -asc => [ qw( start_time end_time ) ],
    },
  });
  
  if ( scalar( @db_timetables ) ) {
    # Return a reference to the lookup array
    return \@db_timetables;
  } else {
    # No timetable information, return undefined
    return undef;
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
