package TopTable::Schema::ResultSet::Meeting;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Try::Tiny;
use HTML::Entities;
use DateTime;

=head2 all_meetings

Search for all meeting types ordered by name.

=cut

sub all_meeting_types {
  my ( $self ) = @_;
  
  return $self->search({}, {
    prefetch => "type",
    order_by => {-desc => "date"},
  });
}

=head2 find_by_type_and_date

Finds a meeting, prefetching various bits of information, by type and date.  The meeting type can be passed as an object, ID or URL key.  The meeting can be passed as a DateTime object, or a hashref in the form {year => $year, month => $month, day => $day}.

=cut

sub find_by_type_and_date {
  my ( $self, $params ) = @_;
  my $type = $params->{type};
  my $date = $params->{date};
  
  # First we need to work out whether or not the $type is a meeting type object, or an ID / URL key
  # If it is, set it to the URL key for the query.  We don't use the ID, as that's numeric and that
  # causes an 'or' query on ID / URL key, which is likely slightly slower
  $type = $type->url_key if ref( $type ) eq "TopTable::Model::DB::MeetingType";
  
  # Now check the date.  It must either be a DateTime object, or a valid year / month / day in hashref form.
  if ( ref($date) eq "HASH" ) {
    # Hashref, get the year, month, day
    my $year = $date->{year};
    my $month = $date->{month};
    my $day = $date->{day};
    
    # Make sure the date is valid
    try {
      $date = DateTime->new(
        year => $year,
        month => $month,
        day => $day,
      );
    } catch {
      return undef;
    };
  } elsif ( ref($date) ne "DateTime" ) {
    # Not a hashref, not a DateTime; return undef
    return undef;
  }
  
  # If the type ID is entirely numeric, search the ID field, otherwise search the URL key field.
  my $where = ( $type =~ /^\d+$/ ) ? {
    "type.id" => $type,
    date_and_start_time => {-between => [ sprintf( "%s 00:00:00", $date->ymd ), sprintf( "%s 23:59:00", $date->ymd ) ]}
  } : {
    "type.url_key" => $type,
    date_and_start_time => {-between => [ sprintf( "%s 00:00:00", $date->ymd ), sprintf( "%s 23:59:00", $date->ymd ) ]}
  };
  
  return $self->find($where, {
    prefetch  => [ qw( type venue meeting_attendees ) ],
  });
}

=head2 find_by_type_and_date

Finds a meeting, prefetching various bits of information, by meeting ID.

=cut

sub find_by_id {
  my ( $self, $id ) = @_;
  
  return $self->find({
    id => $id,
  }, {
    prefetch  => [qw( type venue meeting_attendees )],
  });
}

=head2 page_records

Retrieve a paginated list of meetings.  This only retrieves meetings that are not listed as events, as they are retrieved in the equivalent Event model.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  my $meeting_type = $parameters->{meeting_type};
  
  # Initially we're just looking at event and season NULL values, as this means it's not an 'event'
  my $where = {event => undef, season => undef};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  $where->{"type.id"} = $meeting_type->id if defined($meeting_type);
  
  return $self->search($where, {
    prefetch => "type",
    page => $page_number,
    rows => $results_per_page,
    order_by => [{
      -desc => [qw( date_and_start_time )],
    }, {
      -asc => [qw( type.name )],
    }],
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $exclude_id ) = @_;
  return $self->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      id => $id_or_url_key
    }, {
      url_key => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $self->search($where, {rows => 1})->single;
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
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

Provides the wrapper (including error checking) for adding / editing a meeting.  This will only ADD a meeting if it's a standalone meeting (not an 'event'); event meetings are added via the Event class; however, all types of meetings are edited here.

=cut

sub create_or_edit {
  my ( $self, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $meeting = $params->{meeting} || undef;
  my $type = $params->{type} || undef;
  my $date = $params->{date} || undef;
  my $venue = $params->{venue} || undef;
  my $organiser = $params->{organiser} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $all_day = $params->{all_day}|| undef;
  my $finish_hour = $params->{finish_hour} || undef;
  my $finish_minute = $params->{finish_minute} || undef;
  my $attendees = $params->{attendees} || [];
  my $apologies = $params->{apologies} || [];
  my $agenda = $params->{agenda} || undef;
  my $minutes = $params->{minutes} || undef;
  my $is_event = 0;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # If we're editing, check the meeting is valid
    if ( defined( $meeting ) and ref( $meeting ) eq "TopTable::Model::DB::Meeting" ) {
      # The meeting is valid, we now need to check whether or not it's an event
      $is_event = 1 if defined( $meeting->event );
    } else {
      # Meeting is invalid
      push(@{$response->{errors}}, {id => "meetings.form.error.meeting-invalid"});
    }
  }
  
  ## Error checking
  # Check the date - if it's invalid, we set it into a variable, rather than pushing it straight on to the array, so that the errors appear in the proper order
  my $date_error = "";
  if ( defined($date) ) {
    if ( ref($date) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $date->{year};
      my $month = $date->{month};
      my $day = $date->{day};
      
      # Make sure the date is valid
      try {
        $date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        $date_error = $lang->maketext("meetings.form.error.date-invalid");
      } finally {
        # Set the date into the fields if we don't have an error
        $response->{fields}{date} = $date unless $date_error;
      };
    } elsif ( ref($date) ne "DateTime" ) {
      $date_error = $lang->maketext("meetings.form.error.date-invalid");
    }
  } else {
    $date_error = $lang->maketext("meetings.form.error.date-blank");
  }
  
  if ( $is_event ) {
    # This meeting is an event, so won't have a type
    undef( $type );
  } else {
    # Not an event, vadlidate the type
    if ( defined($type) ) {
      # we have a type, check it's valid
      if ( ref($type) ne "TopTable::Model::DB::MeetingType" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $type = $schema->resultset("MeetingType")->find_id_or_url_key( $type );
        
        # Definitely error if we're now undef
        if  ( defined($type) ) {
          $response->{fields}{type} = $type;
        } else {
          push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-invalid"));
        }
        
        # Check the type / date combination isn't a duplicate (only if we haven't already errored on date validation above)
        my $meeting_check;
        unless ( $date_error ) {
          if ( $action eq "edit" ) {
            $meeting_check = $self->find({}, {
              where => {
                type => $type->id,
                date_and_start_time => {-between => [sprintf("%s 00:00:00", $date->ymd), sprintf("%s 23:59:59", $date->ymd)]},
                id => {"!=" => $meeting->id},
              }
            });
          } else {
            $meeting_check = $self->find({
              type => $type->id,
              date_and_start_time => {-between => [sprintf("%s 00:00:00", $date->ymd), sprintf("%s 23:59:59", $date->ymd)]},
            });
          }
        }
        
        push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-and-date-exists", $type->name)) if defined( $meeting_check );
      }
    } else {
      # Blank type
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-blank"));
    }
  }
  
  # Check the venue
  if ( defined($venue) ) {
    $venue = $schema->resultset("Venue")->find_by_id_or_url_key($venue) unless ref($venue) eq "TopTable::Model::DB::Venue";
    
    if ( defined($venue) ) {
      # Venue found, push back into the fields, error if inactive
      $response->{fields}{venue} = $venue;
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.venue-inactive", encode_entities($venue->name))) unless $venue->active;
    } else {
      # Venue error
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.venue-invalid")); # Venue will now be undef if we haven't managed to find it with the ID and it wasn't a Venue in the first place
    }
  } else {
    # Blank venue
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.venue-blank"));
  }
  
  # Check the organiser (not required, so if it's undefined or blank that's fine)
  if ( defined($organiser) ) {
    $organiser = $schema->resultset("Venue")->find_by_id_or_url_key($organiser) unless ref($organiser) eq "TopTable::Model::DB::Person";
    
    if ( defined($organiser) ) {
      # Push the organiser back into the returned fields
      $response->{fields}{organiser} = $organiser;
    } else {
      # Organiser invalid
      push(@{$response->{errors}}, {id => "meetings.form.error.organiser-invalid"}) unless defined( $venue ); # Organiser will now be undef if we haven't managed to find it with the ID and it wasn't a Person in the first place
    }
  }
  
  # Add the date error here if the date is invalid (so that it appears in the order the fields appear in)
  push(@{$response->{errors}}, $date_error) if $date_error;
  
  # Check the start time is valid
  if ( defined($start_hour) ) {
    # We have a start hour, make sure it's valid
    if ( $start_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
      # Start hour matches the right pattern, push it back into the fields to return
      $response->{fields}{start_hour} = $start_hour;
    } else {
      # Invalid start hour
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.start-hour-invalid"));
    }
  } else {
   # Blank start hour
   push(@{$response->{errors}}, $lang->maketext("meetings.form.error.start-hour-blank"));
  }
  
  if ( defined($start_minute) ){
    # Make sure the start minute is valid
    if ( $start_minute =~ m/^(?:[0-5][0-9])$/ ) {
      # Start minute matches the right pattern, push it back into the fields to return
      $response->{fields}{start_minute} = $start_minute;
    } else {
      # Invalid start minute
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.start-minute-invalid"));
    }
  } else {
    # Blank start minute
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.start-hour-blank"));
  }
  
  # Check the finish time is valid, but only if it's specified
  
  
  # Invalid attendee / apologies counter
  my $invalid_attendees = 0;
  my $invalid_apologies = 0;
  
  # These are used to identify attendees and check that they aren't in the apologies list as well; it also ensures we aren't adding duplicates either list.
  my %attendee_ids = ();
  my %apology_ids = ();
  
  # This will be the final attendee list passed in the creation / update routine (it will include attendees and apologies).
  my @attendee_list = ();
  
  # Any people who appear in both the attendee list and the apology sender list will be pushed on to this array so that we can use their names in the error message.
  my @attendee_apology_list = ();
  
  # Make sure attendees and apologies are array refs so we can loop through even if there's only one
  $attendees = [$attendees] unless ref($attendees) eq "ARRAY";
  $apologies = [$apologies] unless ref($apologies) eq "ARRAY";
  
  # First loop through the attendee list
  foreach my $attendee ( @{$attendees} ) {
    # Ensure we are undef if blank
    $attendee ||= undef;
    
    if ( defined($attendee) ) {
      $attendee = $schema->resulset("Person")->find_by_id_or_url_key($attendee) unless ref($attendee) eq "TopTable::Model::DB::Person";
      
      if ( defined($attendee) ) {
        # Attendee is valid, push them on to the attendee list (as long as they weren't already there)
        unless ( exists( $attendee_ids{$attendee->id} ) ) {
          push(@attendee_list, {person => $attendee, apologies => 0});
          
          # Add their to the attendee ID hash so when we loop through the apologies, neither appears in both
          $attendee_ids{$attendee->id} = 1;
        }
      } else {
        # Attendee is invalid; this is just a warning, as attendees are not essential.
        $invalid_attendees++;
      }
    }
  }
  
  # Now loop through the apologies list
  foreach my $apology_sender (@{$apologies}) {
    $apology_sender ||= undef;
    
    if ( defined($apology_sender) ) {
      # Do a lookup if it wasn't passed in as an object
      $apology_sender = $schema->resulset("Person")->find_by_id_or_url_key($apology_sender) unless ref($apology_sender) eq "TopTable::Model::DB::Person";
      
      if ( defined($apology_sender) ) {
        # Apology sender is valid, check they're not on the list of attendees too
        if ( exists( $attendee_ids{$apology_sender->id} ) ) {
          # This person is on both lists - save them so we can use them in the error message.
          push(@attendee_apology_list, $apology_sender);
        } else {
          # This person is not on the attendee list, so we can push them on to the array safely to be passed into the create / edit routine (as long as they aren't already there)
          unless ( exists( $apology_ids{$apology_sender->id} ) ) {
            push(@attendee_list, {person => $apology_sender, apologies => 1});
            $apology_ids{$apology_sender->id} = 1;
          }
        }
      } else {
        # Attendee is invalid; this is just a warning, as attendees are not essential.
        $invalid_attendees++;
      }
    }
  }
  
  # Filter the HTML in the agenda / minutes.  Do this before we check if we have errors, as we then push this back in the response to be flashed back
  $agenda = TopTable->model("FilterHTML")->filter($agenda, "textarea");
  $minutes = TopTable->model("FilterHTML")->filter($minutes, "textarea");
  $response->{fields}{agenda} = $agenda;
  $response->{fields}{minutes} = $minutes;
  
  # Now check if we have anyone who appears on both lists
  if ( scalar(@attendee_apology_list) == 1 ) {
    # One person on both lists elicits a different message to multiple people
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.attendee-on-both-lists", encode_entities( $attendee_apology_list[0]->display_name ), encode_entities( $attendee_apology_list[0]->first_name )));
  } elsif ( scalar(@attendee_apology_list) > 1 ) {
    # Multiple people on both lists, get their names and encode them for the error message
    my @people_names = map( encode_entities( $_->display_name ) , @attendee_apology_list );
    
    push(@{$response->{errors}}, $lang->maketext("meetings.form.error.attendees-on-both-lists", scalar(@attendee_apology_list), encode_entities(join( ", ", @people_names))));
  }
  
  # Sanity check for the all day flag
  $all_day = ( $all_day ) ? 1 : 0;
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # Success, we need to create / edit the meeting
    # We need to build the start time string - the start time is part of the date as well, so we just use DateTime to set the time.
    $date->set_hour($start_hour);
    $date->set_minute($start_minute);
    my $finish_time = sprintf("%02d:%02d", $finish_hour, $finish_minute) if defined($finish_hour) and defined($finish_minute);
    
    # The ONLY thing we can be sure we'll want to submit is the agenda and minutes - anything else is dependent on whether or not it's an event
    my $meeting_data = {
      agenda  => $agenda,
      minutes => $minutes,
    };
    
    # Don't put this in the below if statement, as we need to use it outside that scope.
    my $event = $meeting->event_season if $is_event;
    
    # Check the organiser is a defined value - if it is, we'll set it to the ID so we're not trying to use the ->id of an undefined organiser
    #$organiser = $organiser->id if defined( $organiser );
    
    # Start a transaction so we don't have a partially updated database
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    if ( $is_event ) {
      $event->update({
        venue => $venue->id,
        organiser => ( defined($organiser) ) ? $organiser->id : undef,
        date_and_start_time => $date,
        all_day => $all_day,
        finish_time => $finish_time,
      });
    } else {
      $meeting_data->{type} = $type->id;
      $meeting_data->{venue} = $venue->id;
      $meeting_data->{organiser} = ( defined($organiser) ) ? $organiser->id : undef;
      $meeting_data->{date_and_start_time} = $date;
      $meeting_data->{all_day} = $all_day;
      $meeting_data->{finish_time} = $finish_time;
      $meeting_data->{meeting_attendees} = \@attendee_list if $action eq "create";
    }
    
    if ( $action eq "create" ) {
      # We need to save away some details so that we can log that the attendees were added.
      foreach my $attendee ( @attendee_list ) {
        # Now that we've added the object into the relevant array, we only really need the ID, so we can modify the hash element to
        # just be the ID for insertion
        $attendee->{person} = $attendee->{person}->id;
      }
      
      $meeting = $self->create($meeting_data);
    } else {
      $meeting->update($meeting_data);
      
      # If we're updating, we need to delete all attendees that were previously there, then recreate them if necessary
      my $previous_attendees = $meeting->search_related("meeting_attendees")->delete;
      
      # Loop through the attendees / apologies and add any that need adding
      foreach my $attendee ( @attendee_list ) {
        # Create the new attendee unless they exist already - we don't need to check whether they're an apology here, as that was all changed in the previous loop
        $meeting->create_related("meeting_attendees", {
          person => $attendee->{person}->id,
          apologies => $attendee->{apologies},
        });
      }
    }
    
    # Commit the transaction if there are no errors
    $transaction->commit;
    
    $response->{meeting} = $meeting;
  }
  
  return $response;
}

1;