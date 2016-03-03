package TopTable::Schema::ResultSet::Event;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Regexp::Common qw /URI/;
use Try::Tiny;

=head2 all_events_by_name

Retrieve all events without any prefetching, ordered by full name.

=cut

sub all_events_by_name {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {
      -asc => [ qw( name ) ]
    }
  });
}

=head2 page_records

Returns a paginated resultset of events.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number         = $parameters->{page_number} || 1;
  my $results_per_page    = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => {
      -asc => "name",
    },
  });
}

=head2 events_in_season

Retrieve all events that have been run in a given season.

=cut

sub events_in_season {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season};
  
  return $self->search({
    "event_seasons.season" => $season->id,    
  }, {
    join => "event_seasons",
    order_by => {
      -asc => [ qw( name ) ],
    },
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key ) = @_;
  return $self->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my ( $where );
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - assume it's the ID
    $where = {id => $id_or_url_key};
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $self->find($where, {
    prefetch  => [
      "event_type", {
        event_seasons => [
          "meetings",
          "organiser",
          "tournaments", # Will eventually be a hashref drilling down to rounds, groups, etc.
        ],
      },
    ],
  });
}

=head2 generate_url_key

Generate a unique key from the given event short name.

=cut

sub generate_url_key {
  my ( $self, $name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc( $original_url_key ); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = $original_url_key . "-" . $count;
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $key_check = $self->find_url_key( $url_key );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a event.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $event_name_check );
  my $date_error = 0;
  my $return_value = {error => []};
  
  # Required fields - certain keys get deleted depending on the values of other fields
  # Note this is not ALL required fields, just the ones that may or may not be required
  # depending on other factors.
  my %required = (
    venue => 1,
    date  => 1,
    time  => 1,
  );
  
  # Default to event type not editable (this is only effective when editing, obvisously)
  my ( $event_type_editable, $tournament_type_editable ) = qw( 0 0 );
  
  my $event                 = $parameters->{event}                || undef;
  my $name                  = $parameters->{name}                 || undef;
  my $event_type            = $parameters->{event_type}           || undef;
  my $tournament_type       = $parameters->{tournament_type}      || undef;
  my $allow_online_entries  = $parameters->{allow_online_entries} || 0;
  my $venue                 = $parameters->{venue}                || undef;
  my $organiser             = $parameters->{organiser}            || undef;
  my $date                  = $parameters->{date}                 || undef;
  my $start_hour            = $parameters->{start_hour}           || undef;
  my $start_minute          = $parameters->{start_minute}         || undef;
  my $all_day               = $parameters->{all_day}              || 0;
  my $finish_hour           = $parameters->{finish_hour}          || undef;
  my $finish_minute         = $parameters->{finish_minute}        || undef;
  my $season                = $parameters->{season}               || undef;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ($action eq "edit") {
    # Check the event passed is valid
    unless ( defined( $event ) and ref( $event ) eq "TopTable::Model::DB::Event" ) {
      push(@{ $return_value->{error} }, {id => "event.form.error.event-invalid"});
      
      # Another fatal error
      return $return_value;
    }
  }
  
  if ( !defined( $season ) or ref( $season ) ne "TopTable::Model::DB::Season" ) {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.season-invalid"});
  } else {
    # Check it's current
    if ( $season->complete ) {
      push(@{ $return_value->{error} }, {id => "events.form.error.season-not-current"});
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined( $name ) ) {
    # Name entered, check it.
    if ( $action eq "edit" ) {
      $event_name_check = $self->find({}, {
        where   => {
          name  => $name,
          id    => {
            "!=" => $event->id
          }
        }
      });
    } else {
      $event_name_check = $self->find({name => $name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "events.form.error.name-exists",
      parameters  => [$name],
    }) if defined( $event_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "events.form.error.name-blank"});
  }
  
  if ( !defined( $event_type ) or ref( $event_type ) ne "TopTable::Model::DB::LookupEventType" ) {
    # Event type not entered or invalid
    push(@{ $return_value->{error} }, {id => "events.form.error.event-type-invalid"});
  } elsif ( defined( $event_type ) and $event_type->id eq "single-tournament" and ( !defined( $tournament_type ) or ref( $tournament_type ) ne "TopTable::Model::DB::LookupTournamentType" ) ) {
    # Event type is 'single-tournament', so we need a tournament type, but it's not entered or invalid
    push(@{ $return_value->{error} }, {id => "events.form.error.tournament-type-invalid"});
  } elsif ( defined( $event_type ) and $event_type->id ne "single-tournament" and defined( $tournament_type ) ) {
    # Event type is not 'single-tournament', so we discard any tournament type
    undef( $tournament_type );
  } elsif ( defined( $event_type ) and $event_type->id eq "single-tournament" and defined( $tournament_type ) and $tournament_type->id eq "team" ) {
    # Event type is 'single-tournament' and tournament type is 'team', so the venue, date, start time, all day flag and finish time are cleared
    undef( $venue );
    undef( $date );
    undef( $start_hour );
    undef( $start_minute );
    undef( $all_day );
    undef( $finish_hour );
    undef( $finish_minute );
    delete $required{venue};
    delete $required{date};
    delete $required{time};
    $allow_online_entries = 0; # Don't allow online entries for team events
  }
  
  if ( defined( $event_type ) and $event_type->id eq "single-tournament" and defined( $tournament_type ) and $tournament_type->id ne "team" ) {
    # Non-team event, allow online entries should be 1 or 0
    $allow_online_entries = ( $allow_online_entries ) ? 1 : 0;
  }
  
  # Check the venue is valid if we need it
  if ( exists( $required{venue} ) ) {
    # Venue is required, make sure it's provided and valid
    push(@{ $return_value->{error} }, {id => "events.form.error.venue-invalid"}) if !defined( $venue ) or ref( $venue ) ne "TopTable::Model::DB::Venue";
  } else {
    # Venue is NOT required, but make sure it's valid IF provided
    push(@{ $return_value->{error} }, {id => "events.form.error.venue-invalid"}) if defined( $venue ) and ref( $venue ) ne "TopTable::Model::DB::Venue";
  }
  
  # Check the organiser is a valid person
  push(@{ $return_value->{error} }, {id => "events.form.error.organiser-invalid"}) if defined( $organiser ) and ref( $organiser ) ne "TopTable::Model::DB::Person";
  
  # Split the date up
  my ( $day, $month, $year ) = split("/", $date) if defined( $date );
  
  if ( defined( $date ) ) {
    # Date has been defined, check it's valid
    # Split the date up
    my ( $day, $month, $year ) = split("/", $date);
    
    try {
      $date = DateTime->new(
        year  => $year,
        month => $month,
        day   => $day,
      );
    } catch {
      $date_error = 1; # We need to know whether or not we can call datetime methods on this
      push(@{ $return_value->{error} }, {id => "events.form.error.date-invalid"});
      undef( $date );
    };
  } elsif ( exists( $required{date} ) ) {
    # Date is required, but missing
    $date_error = 1; # We need to know whether or not we can call datetime methods on this
    push(@{ $return_value->{error} }, {id => "events.form.error.date-invalid"});
    undef( $date );
  }
  
  # Check the start time is valid if we need it
  if ( exists( $required{time} ) ) {
    push(@{ $return_value->{error} }, {id => "events.form.error.start-hour-invalid"}) if !defined( $start_hour ) or $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    push(@{ $return_value->{error} }, {id => "events.form.error.start-minute-invalid"}) if !defined( $start_minute ) or $start_minute !~ m/^(?:[0-5][0-9])$/;
    
    if ( $all_day ) {
      # Sanity check - if it's true, make sure we put a 1 in the database
      undef( $finish_hour );
      undef( $finish_minute );
      $all_day = 1;
    } else {
      # If it's not all day, we need to check the end time
      push(@{ $return_value->{error} }, {id => "events.form.error.finish-hour-invalid"}) if defined( $finish_hour ) and $finish_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
      push(@{ $return_value->{error} }, {id => "events.form.error.finish-minute-invalid"}) if defined( $finish_minute ) and $finish_minute !~ m/^(?:[0-5][0-9])$/;
      $all_day = 0;
    }
  } else {
    # Not required, but still check if they're valid IF provided
    push(@{ $return_value->{error} }, {id => "events.form.error.start-hour-invalid"}) if defined( $start_hour ) and $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    push(@{ $return_value->{error} }, {id => "events.form.error.start-minute-invalid"}) if defined( $start_minute ) and $start_minute !~ m/^(?:[0-5][0-9])$/;
    
    if ( $all_day ) {
      # Sanity check - if it's true, make sure we put a 1 in the database
      undef( $finish_hour );
      undef( $finish_minute );
      $all_day = 1;
    } else {
      # If it's not all day, we need to check the end time
      push(@{ $return_value->{error} }, {id => "events.form.error.finish-hour-invalid"}) if defined( $finish_hour ) and $finish_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
      push(@{ $return_value->{error} }, {id => "events.form.error.finish-minute-invalid"}) if defined( $finish_minute ) and $finish_minute !~ m/^(?:[0-5][0-9])$/;
      $all_day = 0;
    }
  }
  
  if ( defined( $date ) and defined( $start_hour ) and defined( $start_minute ) ) {
    $date->set_hour( $start_hour );
    $date->set_minute( $start_minute );
  }
  
  my $finish_time = sprintf( "%02d:%02d", $finish_hour, $finish_minute ) if defined( $finish_hour ) and defined( $finish_minute );
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Grab the submitted values
    
    # Build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $event->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to create / edit the event
    if ( $action eq "create" ) {
      # Create a transaction to safeguard - if either operation fails, nothing is written
      my $transaction = $self->result_source->schema->txn_scope_guard;
      
      $event = $self->create({
        url_key       => $url_key,
        name          => $name,
        event_type    => $event_type->id,
      });
      
      # This needs to be done as create_related, rather than in the above create statement, because we need a handle to the object
      # to be able to create the meeting / tournament
      my $event_season = $event->create_related("event_seasons", {
        season              => $season->id,
        name                => $name,
        date_and_start_time => $date,
        all_day             => $all_day,
        finish_time         => $finish_time,
        organiser           => $organiser,
        venue               => $venue,
      });
      
      if ( $event_type->id eq "single-tournament" ) {
        $event_season->create_related("tournaments", {
          season                => $season->id,
          name                  => $name,
          entry_type            => $tournament_type->id,
          allow_online_entries  => $allow_online_entries,
        });
      } elsif ( $event_type->id eq "meeting" ) {
        my $meeting = $event_season->create_related("meetings", {season  => $season->id});
      }
      
      # Commit the transaction if there are no errors
      $transaction->commit;
    } else {
      
      if ( defined( $event_type ) and $event_type->id ne $event->event_type->id ) {
        if ( $event->can_edit_event_type ) {
          # Event type has changed, get the old value then update the field
          my $old_event_type = $event->event_type->id;
          $event->event_type( $event_type->id );
          
          # Now depending on the old event type, we need to delete meetings or tournaments
          if ( $old_event_type eq "single-tournament" ) {
            # Delete tournament matches
            
          } elsif ( $old_event_type eq "meeting" ) {
            # Delete meetings
            
          }
        } else {
          # Event type is not editable, return before we update
          push(@{ $return_value->{error} }, {id => "events.form.error.cant-edit-event-type"});
          return $return_value;
        }
      }
      
      $event->url_key( $url_key );
      $event->name( $name );
      
      $event->update;
    }
    
    $return_value->{event} = $event;
  }
  
  return $return_value;
}

1;