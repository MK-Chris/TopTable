package TopTable::Schema::ResultSet::Event;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Regexp::Common qw( URI );
use Try::Tiny;

=head2 all_events_by_name

Retrieve all events without any prefetching, ordered by full name.

=cut

sub all_events_by_name {
  my ( $class ) = @_;
  
  return $class->search(undef, {
    order_by => {-asc => [qw( name )]}
  });
}

=head2 page_records

Returns a paginated resultset of events.

=cut

sub page_records {
  my ( $class, $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => [qw( name )]},
  });
}

=head2 events_in_season

Retrieve all events that have been run in a given season.

=cut

sub events_in_season {
  my ( $class, $params ) = @_;
  my $season = $params->{season};
  
  return $class->search({
    "event_seasons.season" => $season->id,    
  }, {
    join => "event_seasons",
    order_by => {-asc => [qw( name )]},
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $class, $url_key ) = @_;
  return $class->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $class, $id_or_url_key ) = @_;
  my ( $where );
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - assume it's the ID
    $where = {id => $id_or_url_key};
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $class->find($where, {
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
  my ( $class, $name, $exclude_id ) = @_;
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
    my $key_check = $class->find_url_key($url_key);
    
    # If not, return it
    return $url_key if !defined($key_check) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a event.

=cut

sub create_or_edit {
  my ( $class, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $event = $params->{event} || undef;
  my $name = $params->{name} || undef;
  my $event_type = $params->{event_type} || undef;
  my $tournament_type = $params->{tournament_type} || undef;
  my $allow_online_entries = $params->{allow_online_entries} || 0;
  my $venue = $params->{venue} || undef;
  my $organiser = $params->{organiser} || undef;
  my $start_date = $params->{start_date} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $all_day = $params->{all_day} || 0;
  my $end_date = $params->{end_date} || undef;
  my $end_hour = $params->{end_hour} || undef;
  my $end_minute = $params->{end_minute} || undef;
  
  # Setup the dates in a hash for looping through
  my @dates = ( $start_date, $end_date );
  
  # Date errors hash, as the dates are checked together, not necessarily in the order we want them to appear, so store them here then push to errors when appropriate
  my %date_errors = (start_date => "", end_date => "");
  
  my $season = $schema->resultset("Season")->get_current;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # Check the event passed is valid
    unless ( defined($event) and ref($event) eq "TopTable::Model::DB::Event" ) {
      push(@{$response->{errors}}, $lang->maketext("event.form.error.event-invalid"));
      
      # Another fatal error
      return $response;
    }
  }
  
  unless ( defined($season) ) {
    my $action_desc = $action eq "create" ? $lang->maketext("admin.message.created") : $lang->maketext("admin.message.edited");
    push(@{$response->{errors}}, $lang->maketext("events.form.error.no-current-season", $action_desc));
  }
  
  # Required fields - certain keys get deleted depending on the values of other fields
  # Note this is not ALL required fields, just the ones that may or may not be required
  # depending on other factors.
  my ( $venue_required, $start_date_required, $start_time_required ) = qw( 1 1 1 );
  
  # Default to event type not editable (this is only effective when editing, obvisously)
  my ( $event_type_editable, $tournament_type_editable ) = qw( 0 0 );
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    # Name entered, check it.
    my $event_name_check;
    if ( $action eq "edit" ) {
      $event_name_check = $class->find({}, {
        where => {
          name => $name,
          id => {"!=" => $event->id}
        }
      });
    } else {
      $event_name_check = $class->find({name => $name});
    }
    
    push(@{$response->{errors}}, $lang->maketext("events.form.error.name-exists", $name)) if defined($event_name_check);
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("events.form.error.name-blank"));
  }
  
  if ( defined($event_type) ) {
    # We have an event type passed, make sure it's either a valid event type object, or an ID we can look up
    $event_type = $schema->resultset("LookupEventType")->find($event_type) unless ref($event_type) eq "TopTable::Model::DB::LookupEventType";
    
    if ( defined($event_type) ) {
      # Valid event type, check if it's a tournament
      if ( $event_type->id eq "single-tournament" ) {
        # Check we have a tournament type
        if ( defined($tournament_type) ) {
          $tournament_type = $class->schema->resultset("LookupTournamentType")->find($tournament_type) unless ref($tournament_type) eq "TopTable::Model::DB::LookupTournamentType";
          
          if ( defined($tournament_type) ) {
            if ( $tournament_type->id eq "team" ) {
              # Event type is 'single-tournament' and tournament type is 'team', so the venue, date, start time, all day flag and finish time are cleared
              undef($venue);
              undef($start_hour);
              undef($start_minute);
              undef($all_day);
              undef($end_hour);
              undef($end_minute);
              $venue_required = 0;
              $start_date_required = 0;
              $start_time_required = 0;
              $allow_online_entries = 0; # Don't allow online entries for team events
            } else {
              # Tournament, but not a team tournament - sanity check the allow online entries flag to ensure it's 1 or 0 but nothing else
              $allow_online_entries = $allow_online_entries ? 1 : 0;
            }
          } else {
            # Invalid tournament type
            push(@{$response->{errors}}, $lang->maketext("events.form.error.tournament-type-invalid"));
          }
        } else {
          # Tournament type not given
          push(@{$response->{errors}}, $lang->maketext("events.form.error.tournament-type-blank"));
        }
      } else {
        # Not a tournament, so we don't need a tournament type
        undef($tournament_type);
      }
    } else {
      # Event type invalid
      push(@{$response->{errors}}, $lang->maketext("events.form.error.event-type-invalid"));
    }
  } else {
    # Event type blank
    push(@{$response->{errors}}, $lang->maketext("events.form.error.event-type-blank"));
  }
  
  # Ensure the sanitised event / tournament type is passed back
  $response->{fields}{event_type} = $event_type;
  $response->{fields}{tournament_type} = $tournament_type;
  
  # Check the venue is valid passed and valid
  if ( defined($venue) ) {
    # Venue has been passed, make sure it's valid
    if ( ref($venue) ne "TopTable::Model::DB::Venue" ) {
      # Venue hasn't been passed in as an object, try and lookup as an ID / URL key
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue);
      push(@{$response->{errors}}, $lang->maketext("events.form.error.venue-invalid")) unless defined($venue);
    }
    
    # Now check the venue is active if we have one
    push(@{$response->{errors}}, $lang->maketext("events.form.error.venue-inactive", encode_entities($venue->name))) if defined($venue) and !$venue->active;
  } else {
    # Venue is blank - only error if we've determined it's required
    push(@{$response->{errors}}, $lang->maketext("events.form.error.venue-blank")) if $venue_required;
  }
  
  # Push the sanitised field back
  $response->{fields}{venue} = $venue;
  
  # Validate the organiser if it's been passed in - it's not required, so don't error if it hasn't
  if ( defined($organiser) ) {
    if ( ref($organiser) ne "TopTable::Model::DB::Person" ) {
      # Not passed in as an object, check if it's a valid ID / URL key
      $organiser = $schema->resultset("Person")->find_id_or_url_key($organiser);
      push(@{$response->{errors}}, $lang->maketext("events.form.error.organiser-invalid")) unless defined($organiser);
    }
  }
  
  # Push the sanitised field back
  $response->{fields}{organiser} = $organiser;
  
  # Check the date
  if ( $start_date_required ) {
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
  }
  
  # Push any start date error we found here
  push(@{$response->{errors}}, $date_errors{start_date}) if $date_errors{start_date};
  
  # Check the start time is valid if we need it
  if ( defined($start_hour) ) {
    # Passed in, check it's valid
    push(@{$response->{errors}}, $lang->maketext("events.form.error.start-hour-invalid")) unless $start_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
  } else {
    # Blank, error if it's required
    push(@{$response->{errors}}, $lang->maketext("events.form.error.start-hour-blank")) if $start_time_required;
  }
  
  if ( defined($start_minute) ) {
    # Passed in, check it's valid
    push(@{$response->{errors}}, $lang->maketext("events.form.error.start-minute-invalid")) unless $start_minute =~ m/^(?:[0-5][0-9])$/;
  } else {
    # Blank, error if it's required
    push(@{$response->{errors}}, $lang->maketext("events.form.error.start-minute-blank")) if $start_time_required;
  }
  
  push(@{$response->{errors}}, $lang->maketext("events.form.error.start-time-partially-blank")) if (!$start_time_required and (defined($start_hour) and !defined($start_minute)) or (!defined($start_hour) and defined($start_minute)));
  
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
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # Success, we need to create / edit the event
    # Build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->generate_url_key($name, $event->id);
    } else {
      $url_key = $class->generate_url_key($name);
    }
    
    # Create a transaction to safeguard - if either operation fails, nothing is written / updated
    my $transaction = $class->result_source->schema->txn_scope_guard;
    
    if ( $action eq "create" ) {
      $event = $class->create({
        url_key => $url_key,
        name => $name,
        event_type => $event_type->id,
      });
      
      # This needs to be done as create_related, rather than in the above create statement, because we need a handle to the object
      # to be able to create the meeting / tournament
      my $event_season = $event->create_related("event_seasons", {
        season => $season->id,
        name => $name,
        start_date_time => $start_date,
        all_day => $all_day,
        end_date_time => $end_date,
        organiser => $organiser,
        venue => $venue,
      });
      
      if ( $event_type->id eq "single-tournament" ) {
        $event_season->create_related("tournaments", {
          season => $season->id,
          name => $name,
          entry_type => $tournament_type->id,
          allow_online_entries => $allow_online_entries,
        });
      } elsif ( $event_type->id eq "meeting" ) {
        my $meeting = $event_season->create_related("meetings", {season => $season->id});
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $event->name, $lang->maketext("admin.message.created")));
    } else {
      if ( defined($event_type) and $event_type->id ne $event->event_type->id ) {
        if ( $event->can_edit_event_type ) {
          # Event type has changed, get the old value then update the field
          my $old_event_type = $event->event_type->id;
          $event->event_type($event_type->id);
          
          # Now depending on the old event type, we need to delete meetings or tournaments
          if ( $old_event_type eq "single-tournament" ) {
            # Delete tournament matches
            
          } elsif ( $old_event_type eq "meeting" ) {
            # Delete meetings
            
          }
        } else {
          # Event type is not editable, return before we update
          push(@{$response->{errors}}, $lang->maketext("events.form.error.cant-edit-event-type"));
          return $response;
        }
      }
      
      $event->url_key($url_key);
      $event->name($name);
      
      $event->update;
      
      # Update the details for this season
      my $event_season = $event->single_season($season);
      $event_season->update({
        name => $name,
        start_date_time => $start_date,
        all_day => $all_day,
        end_date_time => $end_date,
        organiser => $organiser,
        venue => $venue,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $event->name, $lang->maketext("admin.message.edited")));
    }
    
    # Commit the transaction if there are no errors
    $transaction->commit;
    
    $response->{event} = $event;
  }
  
  return $response;
}

1;
