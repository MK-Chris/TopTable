package TopTable::Schema::ResultSet::Meeting;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Try::Tiny;
use HTML::Entities;
use DateTime;
use Set::Object;

=head2 all_meetings

Search for all meeting types ordered by name.

=cut

sub all_meeting_types {
  my $class = shift;
  
  return $class->search({}, {
    prefetch => "type",
    order_by => {-desc => "date"},
  });
}

=head2 find_by_type_and_date

Finds a meeting, prefetching various bits of information, by type and date.  The meeting type can be passed as an object, ID or URL key.  The meeting can be passed as a DateTime object, or a hashref in the form {year => $year, month => $month, day => $day}.

=cut

sub find_by_type_and_date {
  my $class = shift;
  my ( $params ) = @_;
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
    start_date_time => {-between => [ sprintf( "%s 00:00:00", $date->ymd ), sprintf( "%s 23:59:00", $date->ymd ) ]}
  } : {
    "type.url_key" => $type,
    start_date_time => {-between => [ sprintf( "%s 00:00:00", $date->ymd ), sprintf( "%s 23:59:00", $date->ymd ) ]}
  };
  
  return $class->find($where, {
    prefetch  => [ qw( type venue meeting_attendees ) ],
  });
}

=head2 find_by_type_and_date

Finds a meeting, prefetching various bits of information, by meeting ID.

=cut

sub find_by_id {
  my $class = shift;
  my ( $id ) = @_;
  
  return $class->find({
    id => $id,
  }, {
    prefetch  => [qw( type venue meeting_attendees )],
  });
}

=head2 page_records

Retrieve a paginated list of meetings.  This only retrieves meetings that are not listed as events, as they are retrieved in the equivalent Event model.

=cut

sub page_records {
  my $class = shift;
  my ( $parameters ) = @_;
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
  
  return $class->search($where, {
    prefetch => "type",
    page => $page_number,
    rows => $results_per_page,
    order_by => [{
      -desc => [qw( start_date_time )],
    }, {
      -asc => [qw( type.name )],
    }],
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my $class = shift;
  my ( $url_key, $exclude_id ) = @_;
  return $class->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my $class = shift;
  my ( $id_or_url_key ) = @_;
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
  
  return $class->search($where, {rows => 1})->single;
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my $class = shift;
  my ( $name, $exclude_id ) = @_;
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
    my $key_check = $class->find_url_key( $url_key );
    
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
  my $class = shift;
  my ( $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $meeting = $params->{meeting} || undef;
  my $type = $params->{type} || undef;
  my $start_date = $params->{start_date} || undef;
  my $venue = $params->{venue} || undef;
  my $organiser = $params->{organiser} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $all_day = $params->{all_day}|| undef;
  my $end_date = $params->{end_date} || undef;
  my $end_hour = $params->{end_hour} || undef;
  my $end_minute = $params->{end_minute} || undef;
  my $attendees = $params->{attendees} || [];
  my $apologies = $params->{apologies} || [];
  my $agenda = $params->{agenda} || undef;
  my $minutes = $params->{minutes} || undef;
  
  # Setup the dates in a hash for looping through
  my @dates = ( $start_date, $end_date );
  
  # Date errors hash, as the dates are checked together, not necessarily in the order we want them to appear, so store them here then push to errors when appropriate
  my %date_errors = (start_date => "", end_date => "");
  
  my $is_event = 0;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  # If the start date isn't required, we'll just undef it, as we don't want it (this is for team events)
  foreach my $date_idx ( 0 .. $#dates ) {
    my ( $date_fld, $date_required );
    
    if ( $date_idx == 0 ) {
      $date_required = 1;
      $date_fld = "start_date";
    } else {
      $date_required = 0;
      $date_fld = "end_date";
    }
    
    my $date = $dates[$date_idx];
    my $date_valid = 1; # Default to valid
    
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
          $date_errors{$date_fld} = $lang->maketext("events.form.error.$date_fld-invalid");
          $date_valid = 0;
        };
      } elsif ( ref($date) ne "DateTime" ) {
        # Not a hashref, not a DateTime
        $date_errors{$date_fld} = $lang->maketext("events.form.error.$date_fld-invalid");
        $date_valid = 0;
      }
    } elsif ( $date_required ) {
      # Date blank, check if this is the required date or not
      $date_errors{$date_fld} = $lang->maketext("events.form.error.$date_fld-blank");
    }
    
    if ( $date_valid ) {
      # Date is valid, set the relevant var
      if ( $date_fld eq "start_date" ) {
        $start_date = $date;
      } else {
        # End date is set to the start date if it's blank
        if ( defined($date) ) {
          $end_date = $date; # Set end date if it's supplied
        } elsif ( defined($end_hour) and defined($end_minute) ) {
          # End time was supplied, so we have to set the end date as well, but it wasn't supplied.  Set it to the same as the start date
          $end_date = $start_date->clone;
        } else {
          # End time not specified, neither was the date, just undef it
          undef($end_date);
        }
      }
    } else {
      # Date is invalid  - set date to undef
      if ( $date_fld eq "start_date" ) {
        undef($start_date);
      } else {
        undef($end_date);
      }
    }
  }
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # If we're editing, check the meeting is valid
    if ( defined($meeting) and ref($meeting) eq "TopTable::Model::DB::Meeting" ) {
      # The meeting is valid, we now need to check whether or not it's an event
      $is_event = 1 if defined($meeting->event);
    } else {
      # Meeting is invalid
      push(@{$response->{errors}}, {id => "meetings.form.error.meeting-invalid"});
    }
  }
  
  ## Error checking
  if ( $is_event ) {
    # This meeting is an event, so won't have a type
    undef($type);
  } else {
    # Not an event, vadlidate the type
    if ( defined($type) ) {
      # we have a type, check it's valid
      if ( ref($type) ne "TopTable::Model::DB::MeetingType" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $type = $schema->resultset("MeetingType")->find_id_or_url_key($type);
        
        # Definitely error if we're now undef
        if  ( defined($type) ) {
          $response->{fields}{type} = $type;
        } else {
          push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-invalid"));
        }
        
        # Check the type / date combination isn't a duplicate (only if we haven't already errored on date validation above)
        my $meeting_check;
        unless ( $date_errors{start_date} ) {
          if ( $action eq "edit" ) {
            $meeting_check = $class->find({}, {
              where => {
                type => $type->id,
                start_date_time => {-between => [sprintf("%s 00:00:00", $start_date->ymd), sprintf("%s 23:59:59", $start_date->ymd)]},
                id => {"!=" => $meeting->id},
              }
            });
          } else {
            $meeting_check = $class->find({
              type => $type->id,
              start_date_time => {-between => [sprintf("%s 00:00:00", $start_date->ymd), sprintf("%s 23:59:59", $start_date->ymd)]},
            });
          }
        }
        
        push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-and-date-exists", $type->name)) if defined($meeting_check);
      }
    } else {
      # Blank type
      push(@{$response->{errors}}, $lang->maketext("meetings.form.error.meeting-type-blank"));
    }
  }
  
  # Check the venue
  if ( defined($venue) ) {
    $venue = $schema->resultset("Venue")->find_id_or_url_key($venue) unless ref($venue) eq "TopTable::Model::DB::Venue";
    
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
    $organiser = $schema->resultset("Venue")->find_id_or_url_key($organiser) unless ref($organiser) eq "TopTable::Model::DB::Person";
    
    if ( defined($organiser) ) {
      # Push the organiser back into the returned fields
      $response->{fields}{organiser} = $organiser;
    } else {
      # Organiser invalid
      push(@{$response->{errors}}, {id => "meetings.form.error.organiser-invalid"}) unless defined($venue); # Organiser will now be undef if we haven't managed to find it with the ID and it wasn't a Person in the first place
    }
  }
  
  # Push any start date error we found here
  push(@{$response->{errors}}, $date_errors{start_date}) if $date_errors{start_date};
  
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
  
  if ( $all_day ) {
    # All day events don't have a finish time
    undef($end_date);
    undef($end_hour);
    undef($end_minute);
  } else {
    # Push any start date error we found here
    push(@{$response->{errors}}, $date_errors{start_date}) if $date_errors{start_date};
    
    # Check the finish time, if it's provided
    if ( defined($end_hour) ) {
      # Passed in, check it's valid
      push(@{$response->{errors}}, $lang->maketext("events.form.error.finish-hour-invalid")) unless $end_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    }
    
    if ( defined($end_minute) ) {
      # Passed in, check it's valid
      push(@{$response->{errors}}, $lang->maketext("events.form.error.finish-minute-invalid")) unless $end_minute =~ m/^(?:[0-5][0-9])$/;
    }
    
    push(@{$response->{errors}}, $lang->maketext("events.form.error.end-time-partially-blank")) if (defined($end_hour) and !defined($end_minute)) or (!defined($end_hour) and defined($end_minute));
  }
  
  # Add the start time to the date if it's provided
  if ( defined($start_date) and defined($start_hour) and defined($start_minute) ) {
    $start_date->set_hour($start_hour);
    $start_date->set_minute($start_minute);
  }
  
  if ( defined($end_date) and defined($end_hour) and defined($end_minute) ) {
    $end_date->set_hour($end_hour);
    $end_date->set_minute($end_minute);
  }
  
  # Formate the finish time if we have one
  $response->{fields}{start_date} = $start_date;
  $response->{fields}{end_date} = $end_date;
  
  if ( defined($start_date) and defined($end_date) ) {
    if ( DateTime->compare($start_date, $end_date) == 1 ) {
      # Start date is before end date
      push(@{$response->{errors}}, $lang->maketext("events.form.error.start-date-must-be-before-end-date"));
    }
  }
  
  # Prepare the people for DB insert / update / delete
  my $people = $class->prepare_attendees_for_update({
    meeting => $meeting,
    attendees => $attendees,
    apologies => $apologies,
    logger => $logger,
  });
  
  # Filter the HTML in the agenda / minutes.  Do this before we check if we have errors, as we then push this back in the response to be flashed back
  #$agenda = TopTable->model("FilterHTML")->filter($agenda, "textarea");
  #$minutes = TopTable->model("FilterHTML")->filter($minutes, "textarea");
  
  $response->{fields}{agenda} = $agenda;
  $response->{fields}{minutes} = $minutes;
  
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
  
  # Sanity check for the all day flag
  $all_day = $all_day ? 1 : 0;
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # Success, we need to create / edit the meeting
    # We need to build the start time string - the start time is part of the date as well, so we just use DateTime to set the time.
    $start_date->set_hour($start_hour);
    $start_date->set_minute($start_minute);
    
    if ( defined($end_date) and defined($end_hour) and defined($end_minute) ) {
      $end_date->set_hour($end_hour);
      $end_date->set_minute($end_minute);
    }
    
    # The ONLY thing we can be sure we'll want to submit is the agenda and minutes - anything else is dependent on whether or not it's an event
    my $meeting_data = {
      agenda  => $agenda,
      minutes => $minutes,
    };
    
    # Don't put this in the below if statement, as we need to use it outside that scope.
    my $event = $meeting->event_season if $is_event;
    
    # Check the organiser is a defined value - if it is, we'll set it to the ID so we're not trying to use the ->id of an undefined organiser
    
    # Start a transaction so we don't have a partially updated database
    my $transaction = $class->result_source->schema->txn_scope_guard;
    
    if ( !$is_event ) {
      $meeting_data->{type} = $type->id;
      $meeting_data->{venue} = $venue->id;
      $meeting_data->{organiser} = defined($organiser) ? $organiser->id : undef;
      $meeting_data->{start_date_time} = $start_date;
      $meeting_data->{all_day} = $all_day;
      $meeting_data->{end_date_time} = $end_date;
    }
    
    if ( $action eq "create" ) {
      # We need to save away some details so that we can log that the attendees were added.
      $meeting = $class->create($meeting_data);
    } else {
      $meeting->update($meeting_data);
    }
    
    # Now sort out our attendees from the prepared list
    $meeting->update_attendees($people);
    
    # Commit the transaction if there are no errors
    $transaction->commit;
    
    $response->{completed} = 1;
    $response->{meeting} = $meeting;
  }
  
  return $response;
}

=head2 prepare_attendees_for_update

Take a list of people and prepare them for insertion as attendees or apologies.

The argument to this will be params hashref, of which:
  - "meeting" is the meeting ID (if we're editing, if not this can be left out)
  - "attendees" is an arrayref of people to add to the attendees list
  - "apologies" is an arrayref of people to add to the apologies list

attendees and apologies work in exactly the same way - if the arrayref is empty, nobody is added to the relevant list in the database, and anyone already in there is removed (this assumes you intended to create an empty list of attendees / apologies).  If undef, the existing list will be left as-is (supplying both as undef is redundant, as the purpose is to prepare the lists for modification).

People in the attendee or apologies lists can be people / IDs / URL keys (we will lookup any that aren't people, so don't worry if there's a mix).

Return value will be a hashref:

{
  attendees => {
    add => [list of IDs to add to the attendee list],
    remove => [list of IDs to remove from the attendee list], # These are in the attendee / apology list already but weren't submitted to the sub, so will be removed - obviously with no meeting submitted, this will always be empty
    invalid => number of invalid people submitted to the attendee list
  }, apologies => {
    add => [list of IDs to add to the apology list],
    remove => [list of IDs to remove from the apology list], # These are in the attendee / apology list already but weren't submitted to the sub, so will be removed - obviously with no meeting submitted, this will always be empty
    invalid => number of invalid people submitted to the apology list
  }
}

=cut

sub prepare_attendees_for_update {
  my $class = shift;
  my ( $params ) = @_;
  my $meeting = $params->{meeting} || undef;
  my $attendees = $params->{attendees} || undef;
  my $apologies = $params->{apologies} || undef;
  my $schema = $class->result_source->schema;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  # Return undef if neither the attendee or apologies list is defined - there would be nothing to do
  return undef if !defined($attendees) and !defined($apologies);
  
  my %response = (
    attendees => {
      add => [],
      remove => [],
      invalid => 0,
    }, apologies => {
      add => [],
      remove => [],
      invalid => 0,
    },
    conflict => [],
  );
  
  # Go through the list of submitted people and make sure they are all people
  # Ensure the given values are arrays (as long as they were passed as defined)
  $attendees = [$attendees] if defined($attendees) and ref($attendees) ne "ARRAY";
  $apologies = [$apologies] if defined($apologies) and ref($apologies) ne "ARRAY";
  
  # Populate the lists hash with whatever was passed in
  my %lists = ();
  $lists{attendees} = $attendees if defined($attendees);
  $lists{apologies} = $apologies if defined($apologies);
  
  foreach my $list_type ( keys %lists ) {
    my @list = @{$lists{$list_type}};
    
    while ( my ($idx, $person) = each @list ) {
      # Ensure we are undef if blank
      $person ||= undef;
      
      if ( defined($person) ) {
        $person = $schema->resultset("Person")->find_id_or_url_key($person) unless ref($person);
        
        # Set the looked up value's ID back to the array (even if undef, the grep below will pick it out)
        # We are using ID here because we need to check it against existing lists / arrays and Set::Object
        if ( defined($person) ) {
          $list[$idx] = $person->id;
        } else {
          # Increase invalid count and add undef into the array (which will be removed later with grep)
          $list[$idx] = undef;
          $response{$list_type}{invalid}++;
        }
      }
    }
    
    # Weed out undef values that were invalid
    @list = grep(defined, @list);
    
    # Put the newly validated list back into the hash
    $lists{$list_type} = Set::Object->new(@list);
  }
  
  # Check no one is on both submitted lists if we're processing both
  if ( defined($attendees) and defined($apologies) ) {
    my $submitted_intersection = $lists{attendees}->intersection($lists{apologies});
    
    # Map the conflicts to the person objects
    my @submitted_intersection = map($schema->resultset("Person")->find($_), @$submitted_intersection);
    
    # Push the intersection of those submitted to both lists to the conflicting list
    $response{conflict} = \@submitted_intersection;
    
    # Remove anything in the intersection from both lists, since we don't know which is the correct one
    $lists{attendees}->delete(@$submitted_intersection);
    $lists{apologies}->delete(@$submitted_intersection);
  }
  
  # We now need to get the original attendees / apologies to see if any need removing (not included in these lists and the list is defined,
  # or are included in the new attendees list but were originally in the apologies list for example - in this case, remove from apologies as
  # you can't be in both)
  # Work out who needs adding / removing by comparing the new with original lists
  # Get a list of attendees to remove (on original list, but not new)
  # We only have an entry in the %lists hash if we're set to process
  foreach my $list_type ( keys %lists ) {
    # This is now a Set::Object object, so no need to get the array
    my $list = $lists{$list_type};
    
    if ( defined($meeting) ) {
        my $orig_list = Set::Object->new(map($_->person->id, $meeting->$list_type));
        
        # Add in anyone in the new list that wasn't in the original; remove anyone in the original that's not in the new
        my $add = $lists{$list_type}->difference($orig_list);
        my $remove = $orig_list->difference($lists{$list_type});
        
        # Now we're done comparing IDs we can get the people objects again to put into the array
        my @add = map($schema->resultset("Person")->find($_), @$add);
        my @remove = map($schema->resultset("Person")->find($_), @$remove);
        $response{$list_type}{add} = \@add;
        $response{$list_type}{remove} = \@remove;
    } else {
      # No meeting, just add in the list as we built up before; nothing to remove
      my @list = map($schema->resultset("Person")->find($_), @$list);
      $response{$list_type}{add} = \@list;
    }
  }
  
  return \%response;
}

1;