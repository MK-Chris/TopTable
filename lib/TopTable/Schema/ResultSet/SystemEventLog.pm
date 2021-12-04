package TopTable::Schema::ResultSet::SystemEventLog;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper::Concise;

=head2 page_records

A predefined search to find all events, ordered by the datestamp.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $public_events_only  = $parameters->{public_events_only} // 1;
  my $page_number         = $parameters->{page_number} || 1;
  my $results_per_page    = $parameters->{results_per_page} || 25;
  my ( $where );
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  # Set up the where clause based on what we want to return (public only, or all)
  if ( $public_events_only ) {
    $where = {
      "system_event_log_type.public_event" => 1,
    };
  } else {
    $where = {};
  }
  
  return $self->search($where, {
    prefetch  => [
      "system_event_log_average_filters",
      "system_event_log_clubs",
      "system_event_log_contact_reasons",
      "system_event_log_divisions",
      "system_event_log_events",
      "system_event_log_files",
      "system_event_log_fixtures_grids",
      "system_event_log_images",
      "system_event_log_meeting_types",
      "system_event_log_meetings",
      "system_event_log_news",
      "system_event_log_people",
      "system_event_log_roles",
      "system_event_log_seasons",
      "system_event_log_team_matches",
      "system_event_log_teams",
      "system_event_log_template_league_table_rankings",
      "system_event_log_template_match_individuals",
      "system_event_log_template_match_team_games",
      "system_event_log_template_match_teams",
      "system_event_log_template_league_table_rankings",
      "system_event_log_users",
      "system_event_log_venues", {
        user => "person",
      },
      "system_event_log_type",
    ],
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => [{
      -desc => "me.log_updated",
    }, {
      # ID is in there in case we do any multiple updates together, which may appear in the same second.
      -asc => "me.id",
    }],
  });
}

=head2 set_event_log

Provides the logic for setting the event log entry - either creating a new one or updating an older one, depending on what's passed in and what's found in the database already.

=cut

sub set_event_log {
  my ( $self, $params ) = @_;
  
  my $object_type       = $params->{object_type} || undef;
  my $event_type        = $params->{event_type} || undef;
  my $object_ids        = $params->{object_ids} || undef;
  my $object_name       = $params->{object_name} || "";
  my $user_id           = defined( $params->{user} ) ? $params->{user}->id : undef;
  my $ip_address        = $params->{ip_address} || undef;
  my $current_datetime  = $params->{current_time} || undef;
  my $return_value      = {};
  my $logger            = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.;;
  
  # Do some initial error checking / prep on names and IDs
  if ( ref($object_ids) eq "HASH" ) {
    # We neeed an arrayref so we can do the loop in one go
    $object_ids = [$object_ids];
    
    # If this is a hash, the names must just be text
    if ( ref( $object_name ) ) {
      # Name is a reference to something, error
      $return_value->{error} .= "The name passed in must be a string and not a reference.\n";
    } else {
      # Convert the value passed in to an arrayref
      $object_name = [$object_name];
    }
  } elsif ( ref($object_ids) eq "ARRAY" ) {
    # If we have an array, the names must be an array as well (with the same number of items)
    if ( ref( $object_name ) ne "ARRAY" ) {
      $return_value->{error} .= "The IDs have been passed in as an array, so the names must also be an array of equal length.\n";
    } elsif ( scalar( @{ $object_ids } ) != scalar( @{ $object_name } ) ) {
      $return_value->{error} .= "The IDs and names arrays must be of equal length.\n";
    }
  } else {
    # Not a hashref or an arrayref, error (the arrayref processing is done further down)
    $return_value->{error} .= "ID(s) not passed in as a hashref or arrayref\n.";
  }
  
  return $return_value if $return_value->{error};
  
  # Make sure all the elements of the IDs array are hashrefs and all the elements of the names array are strings
  # Doesn't matter if we use the object IDs or the names in the foreach because we've already checked they have
  # the same number of elements.
  # Keep an eye on what's errored so we don't get duplicate error messages
  my $ids_errored   = 0;
  my $names_errored = 0;
  foreach my $i ( 0 .. $#{ $object_ids } ) {
    # Check the ID is a hashref
    if ( ref( $object_ids->[$i] ) ne "HASH" and !$ids_errored ) {
      $return_value->{error} .= "Not all IDs passed in as a hashref.\n";
      $ids_errored = 1;
    }
    
    # Check the name is not a reference
    if ( ref( $object_name->[$i] ) and !$names_errored ) {
      $return_value->{error} .= "Some object names have been passed in as a reference.\n";
      $names_errored = 1;
    }
    
    # If we've errored both the ID and name already, no need to carry on checking, so break out of the loop
    last if $ids_errored and $names_errored;
  }
  
  # Get the SytemEventLog relation - this will tend to be the object type prefixed with "system_event_log_" and suffixed with "s" 
  my $object_relation = "system_event_log_" . $object_type . "s";
  
  # Dashes will have underscores instead
  $object_relation =~ s/-/_/g;
  
  # Exceptions to the rule:
  if ( $object_type eq "person" ) {
    # people instead of persons
    $object_relation = "system_event_log_people";
  } elsif ( $object_type eq "team-match" ) {
    # matches instead of matchs
    $object_relation = "system_event_log_team_matches";
  } elsif ( $object_type eq "news" ) {
    # news instead of newss
    $object_relation = "system_event_log_news";
  }
  
  # Work out when we want to search up to for a related event
  my $earliest_updated_time = $current_datetime->clone->subtract( hours => 1 );
  
  # Now work out if there are any more events we can add this object to
  my $event = $self->get_related( $object_type, $event_type, $user_id, $ip_address, $earliest_updated_time );
  
  if ( defined( $event ) ) {
    # Update the event's edit number
    my $update_count = $event->number_of_edits + 1;
    $event->update({
      number_of_edits => $update_count,
      #log_updated     => $current_datetime->ymd . " " . $current_datetime->hms,
    });
    
    # If we're not creating, we may just update the edit count for this object, if it was returned in the related objects.
    foreach my $i ( 0 .. $#{ $object_ids } ) {
      # We need to work through the IDs so we know what to use in our find()
      my $ids = {};
      # Add each key to the find IDs
      $ids->{"object_" . $_} = $object_ids->[$i]{$_} foreach ( keys %{ $object_ids->[$i] } );
      
      my $event_objects = $event->$object_relation;
      my $related_object = $event_objects->find( $ids );
      
      if ( defined( $related_object ) ) {
        # If we have a related object, just update the count on it...
        my $update_count = $related_object->number_of_edits + 1;
        $related_object->update({
          number_of_edits => $update_count,
          #log_updated     => $current_datetime->ymd . " " . $current_datetime->hms,
        });
      } else {
        # ...otherwise create a new related object
        # Add in the event ID so we can link them
        my $event_log_object = {
          name            => $object_name->[$i],
          number_of_edits => 1,
          #log_updated     => $current_datetime->ymd . " " . $current_datetime->hms,
        };
        
        # Add our IDs in, then create the related item
        $event_log_object->{$_} = $ids->{$_} foreach ( keys %{ $ids } );
        $event->create_related( $object_relation, $event_log_object );
      }
    }
  } else {
    # Create a new event with the associated object(s)
    # Start off by looping through and creating the related objects
    my $event_log_objects = [];
    foreach my $i ( 0 .. $#{ $object_ids } ) {
      # Push the scalar values on
      push( @{ $event_log_objects }, {
        name            => $object_name->[$i],
        number_of_edits => 1,
        #log_updated     => $current_datetime->ymd . " " . $current_datetime->hms,
      });
      
      # Now loop through and add the IDs in
      $event_log_objects->[-1]{"object_" . $_} = $object_ids->[$i]{$_} foreach ( keys %{ $object_ids->[$i] } );
    }
    
    # Do the creation, now we have all the related objects
    $event = $self->create({
      object_type       => $object_type,
      event_type        => $event_type,
      user_id           => $user_id,
      ip_address        => $ip_address,
      number_of_edits   => 1,
      $object_relation  => $event_log_objects,
      #log_created       => $current_datetime->ymd . " " . $current_datetime->hms,
      #log_updated       => $current_datetime->ymd . " " . $current_datetime->hms,
    });
  }
}

=head2 get_related

Returns the latest related event (if there is one updated in time period specified; if no time period is specified, an hour is used as the default).

=cut

sub get_related {
  my ( $self, $object_type, $event_type, $user_id, $ip_address, $earliest_updated ) = @_;
  
  return $self->find({
    object_type => $object_type,
    event_type  => $event_type,
    user_id     => $user_id,
    ip_address  => $ip_address,
    log_created => {
      -between => [
        sprintf("%s 00:00:00", $earliest_updated->ymd),
        sprintf("%s 23:59:59", $earliest_updated->ymd),
      ]
    },
    "me.log_updated" => {
      ">=" => sprintf("%s %s", $earliest_updated->ymd, $earliest_updated->hms),
    }
  }, {
    prefetch => [qw(
      system_event_log_clubs
      system_event_log_venues
      system_event_log_seasons
    )],
    order_by => {
      -desc => [qw( me.log_updated )],
    },
  });
}

1;