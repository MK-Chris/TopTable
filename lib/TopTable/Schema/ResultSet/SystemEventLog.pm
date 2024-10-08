package TopTable::Schema::ResultSet::SystemEventLog;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use Math::Round;
use DateTime;
use DateTime::Duration;

=head2 page_records

A predefined search to find all events and page them if required, ordered by the specified column / relationship.  We always return an array from this (as opposed to a resultset), as if we're caching multiple pages, we can't merge them into one resultset (that I know of - UNION won't work because we need a LIMIT clause on each query and LIMIT only works after the UNIONs).

=cut

sub page_records {
  my $class = shift;
  my ( $params ) = @_;
  my $public_only = $params->{public_only};
  my $page = $params->{page};
  my $start = $params->{start};
  my $page_length = $params->{page_length};
  my $max_results = $params->{max_results};
  my $pages = 1; # Number of pages to retrieve.  1 is default, but if we are paging, this is worked out below 
  my $page_results = 0; # Default; gets overridden further down
  my $last_page_retrieved;
  my $order_col = $params->{order_col};
  my $order_dir = $params->{order_dir};
  my $search_val = $params->{search_val};
  my $search_ips = $params->{search_ips};
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  # Sanity check public only / search IPs
  $public_only = 1 unless defined($public_only) and ( $public_only == 1 or $public_only == 0 );
  $search_ips = 0 unless defined($search_ips) and ( $search_ips == 1 or $search_ips == 0 );
  
  # Initial attrib set - these are here whatever happens
  my $attrib = {
    prefetch  => [qw(
      system_event_log_average_filters
      system_event_log_clubs
      system_event_log_contact_reasons
      system_event_log_divisions
      system_event_log_events
      system_event_log_files
      system_event_log_fixtures_grids
      system_event_log_images
      system_event_log_meeting_types
      system_event_log_meetings
      system_event_log_news
      system_event_log_people
      system_event_log_roles
      system_event_log_seasons
      system_event_log_team_matches
      system_event_log_teams
      system_event_log_template_league_table_rankings
      system_event_log_template_match_individuals
      system_event_log_template_match_team_games
      system_event_log_template_match_teams
      system_event_log_template_league_table_rankings
      system_event_log_users
      system_event_log_venues ), {
        user => "person",
      },
      "system_event_log_type"
    ]
  };
  
  ## Work out pagination options
  # We must have a max number of pages, otherwise we don't do anything with pagination
  if ( defined($page_length) and $page_length =~ /^\d+$/ ) {
    # Sanity check on page length
    $max_results = $page_length unless defined($max_results) and $max_results =~ /^\d+$/;
    
    # Max results can't be less tha page length
    $max_results = $page_length unless $max_results >= $page_length;
    
    if ( defined($page) and $page =~ /^\d+$/ ) {
      # If we have a page number, use that
      $attrib->{page} = $page;
      $attrib->{rows} = $page_length;
      $page_results = 1;
    } elsif ( defined($page_length) and $page_length =~ /^\d+$/ and defined($start) and $start =~ /^\d+$/ ) {
      # We have a page length / start value instead, so work out the page
      # This is the start + page length - 1 (to give the last value of this page), divided by page length
      $page = ( ( $start + $page_length ) - 1 ) / $page_length;
      $attrib->{page} = $page;
      
      # Still use max results here, as we could be caching subsequent pages
      $attrib->{rows} = $page_length;
      $page_results = 1;
    }
    
    if ( $page_results and $max_results > $page_length ) {
      # Max results is greater than page length, work out how many pages to get
      # We shouldn't need to round, as it should divide exactly, but make sure by using Math::Round
      $pages = round($max_results / $page_length);
      $last_page_retrieved = ( $page + $pages ) - 1;
      
      # Sanity check, this should always be at least the current page number
      $last_page_retrieved = $page if $last_page_retrieved < $page;
    }
  }
  
  # Check we have a search column and direction
  if ( defined($order_col) ) {
    # Sanity check direction
    $order_dir = "asc" unless defined($order_dir) and ( $order_dir eq "asc" or $order_dir eq "desc" );
    $attrib->{order_by} = {"-$order_dir" => $order_col};
  }
  
  # Set up the search query if we have one
  my $where = defined( $search_val ) ? [{
    "user.username" => {-like => "%$search_val%"}
  }, {
    "me.log_updated" => {-like => "%$search_val%"}
  }, {
    "system_event_log_type.object_description" => {-like => "%$search_val%"}
  }] : {};
  
  push(@{$where}, {ip_address => {-like => "%$search_val%"}}) if defined($search_val) and $search_ips;
  
  # Add the public event clause if we need to
  if ( $public_only ) {
    if ( ref( $where ) eq "HASH" ) {
      # Hash ref, just add the key in
      $where->{"system_event_log_type.public_event"} = 1;
    } else {
      # Array ref, add the key into each element of the array
      my $i = 0;
      while ( $i < scalar( @{ $where } ) ) {
        $where->[$i]{"system_event_log_type.public_event"} = 1;
        $i++;
      }
    }
  }
  
  # Return into a resultset, even though we really want an array, so that we can perform paging functions on it first
  my $rs = $class->search($where, $attrib);
  
  if ( $page_results ) {
    my @pages = $rs->all;
    my $pager = $rs->pager;
    
    if ( defined($last_page_retrieved) and $pager->current_page < $last_page_retrieved ) {
      for my $curr_page ( $pager->current_page  .. $last_page_retrieved ) {
        last if $curr_page > $pager->last_page;
        
        # Grab the next page and union it
        my $rs_page = $rs->page($curr_page);
        my @page = $rs_page->all;
        push(@pages, @page);
      }
    }
    
    # Return the array
    return @pages;
  } else {
    # Return the resultset if we're not paging
    return $rs;
  }
}

=head2 set_event_log

Provides the logic for setting the event log entry - either creating a new one or updating an older one, depending on what's passed in and what's found in the database already.

=cut

sub set_event_log {
  my $class = shift;
  my ( $params ) = @_;
  
  my $object_type = $params->{object_type} || undef;
  my $event_type = $params->{event_type} || undef;
  my $object_ids = $params->{object_ids} || undef;
  my $object_name = $params->{object_name} || "";
  my $user_id = defined($params->{user}) ? $params->{user}->id : undef;
  my $ip_address = $params->{ip_address} || undef;
  my $current_datetime = $params->{current_time} || undef;
  my $return_value = {};
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.;;
  
  # Do some initial error checking / prep on names and IDs
  if ( ref($object_ids) eq "HASH" ) {
    # We neeed an arrayref so we can do the loop in one go
    $object_ids = [$object_ids];
    
    # If this is a hash, the names must just be text
    if ( ref($object_name) ) {
      # Name is a reference to something, error
      $return_value->{error} .= "The name passed in must be a string and not a reference.\n";
    } else {
      # Convert the value passed in to an arrayref
      $object_name = [$object_name];
    }
  } elsif ( ref($object_ids) eq "ARRAY" ) {
    # If we have an array, the names must be an array as well (with the same number of items)
    if ( ref($object_name) ne "ARRAY" ) {
      $return_value->{error} .= "The IDs have been passed in as an array, so the names must also be an array of equal length.\n";
    } elsif ( scalar @{$object_ids} != scalar @{$object_name} ) {
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
    if ( ref($object_ids->[$i]) ne "HASH" and !$ids_errored ) {
      $return_value->{error} .= "Not all IDs passed in as a hashref.\n";
      $ids_errored = 1;
    }
    
    # Check the name is not a reference
    if ( ref($object_name->[$i]) and !$names_errored ) {
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
  my $event = $class->get_related($object_type, $event_type, $user_id, $ip_address, $earliest_updated_time);
  
  if ( defined($event) ) {
    # Update the event's edit number
    my $update_count = $event->number_of_edits + 1;
    $event->update({number_of_edits => $update_count});
    
    # If we're not creating, we may just update the edit count for this object, if it was returned in the related objects.
    foreach my $i ( 0 .. $#{$object_ids} ) {
      # We need to work through the IDs so we know what to use in our find()
      my $ids = {};
      # Add each key to the find IDs
      $ids->{"object_" . $_} = $object_ids->[$i]{$_} foreach ( keys %{ $object_ids->[$i] } );
      
      my $event_objects = $event->$object_relation;
      my $related_object = $event_objects->find( $ids );
      
      if ( defined( $related_object ) ) {
        # If we have a related object, just update the count on it...
        my $update_count = $related_object->number_of_edits + 1;
        $related_object->update({number_of_edits => $update_count});
      } else {
        # ...otherwise create a new related object
        # Add in the event ID so we can link them
        my $event_log_object = {
          name => $object_name->[$i],
          number_of_edits => 1,
        };
        
        # Add our IDs in, then create the related item
        $event_log_object->{$_} = $ids->{$_} foreach ( keys %{$ids} );
        $event->create_related($object_relation, $event_log_object);
      }
    }
  } else {
    # Create a new event with the associated object(s)
    # Start off by looping through and creating the related objects
    my $event_log_objects = [];
    foreach my $i ( 0 .. $#{$object_ids} ) {
      # Push the scalar values on
      push(@{$event_log_objects}, {
        name=> $object_name->[$i],
        number_of_edits => 1,
      });
      
      # Now loop through and add the IDs in
      $event_log_objects->[-1]{"object_" . $_} = $object_ids->[$i]{$_} foreach ( keys %{$object_ids->[$i]} );
    }
    
    # Do the creation, now we have all the related objects
    $event = $class->create({
      object_type => $object_type,
      event_type => $event_type,
      user_id => $user_id,
      ip_address => $ip_address,
      number_of_edits => 1,
      $object_relation => $event_log_objects,
    });
  }
}

=head2 get_related

Returns the latest related event (if there is one updated in time period specified; if no time period is specified, an hour is used as the default).

=cut

sub get_related {
  my $class = shift;
  my ( $object_type, $event_type, $user_id, $ip_address, $earliest_updated ) = @_;
  $earliest_updated = DateTime->now(time_zone => "UTC")->subtract(hours => 1) unless defined($earliest_updated) and ref($earliest_updated) eq "DateTime";
  
  # Initial where clause
  my $where = {
    object_type => $object_type,
    event_type => $event_type,
    user_id => $user_id,
    ip_address => $ip_address,
    "me.log_updated" => {
      ">=" => sprintf("%s %s", $earliest_updated->ymd, $earliest_updated->hms),
    }
  };
  
  # Add the earliest updated 
  
  return $class->find($where, {
    prefetch => [qw(
      system_event_log_average_filters
      system_event_log_clubs
      system_event_log_contact_reasons
      system_event_log_divisions
      system_event_log_events
      system_event_log_files
      system_event_log_fixtures_grids
      system_event_log_images
      system_event_log_meeting_types
      system_event_log_meetings
      system_event_log_news
      system_event_log_people
      system_event_log_roles
      system_event_log_seasons
      system_event_log_team_matches
      system_event_log_teams
      system_event_log_template_league_table_rankings
      system_event_log_template_match_individuals
      system_event_log_template_match_team_games
      system_event_log_template_match_teams
      system_event_log_template_league_table_rankings
      system_event_log_users
      system_event_log_venues )],
    order_by => {
      -desc => [qw( me.log_updated )],
    },
  });
}

1;
