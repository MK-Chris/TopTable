package TopTable::Schema::ResultSet::Event;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use Regexp::Common qw( URI );
use Try::Tiny;
use HTML::Entities;

=head2 all_events_by_name

Retrieve all events without any prefetching, ordered by full name.

=cut

sub all_events_by_name {
  my $class = shift;
  
  return $class->search(undef, {
    order_by => {-asc => [qw( name )]}
  });
}

=head2 page_records

Returns a paginated resultset of events.

=cut

sub page_records {
  my $class = shift;
  my ( $params ) = @_;
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
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  
  return $class->search({
    "event_seasons.season" => $season->id,    
  }, {
    join => "event_seasons",
    order_by => {-asc => [qw( name )]},
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.  Overrides the base class because we have to check the event type.

=cut

sub find_id_or_url_key {
  my $class = shift;
  my ( $id_or_url_key, $params ) = @_;
  my $type = $params->{type};
  my %where = ();
  my %attrib = (prefetch  => [qw( event_type ), {
    event_seasons => [qw( organiser meetings tournaments )] # Tournaments will eventually be a hashref drilling down to rounds, groups, etc.
  }]);
  
  
  if ( defined($type) ) {
    if ( $type eq "tournament" ) {
      $where{"event_type.id"} = {-in => [qw( single_tournament multi_tournament )]};
    } else {
      $where{"event_type.id"} = $type;
    }
  }
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric value, check the ID first, then check the URL key
    $where{"me.id"} = $id_or_url_key;
    my $obj = $class->find(\%where, \%attrib);
    return $obj if defined($obj);
    
    # If we get this far, we didn't find anything, so delete the ID key and add in the URL key for searching
    delete $where{"me.id"};
    $where{"me.url_key"} = $id_or_url_key;
    $obj = $class->find(\%where, \%attrib);
    return $obj;
  } else {
    # Not numeric, so it can't be the ID - just check the URL key
    $where{"me.url_key"} = $id_or_url_key;
    return $class->find(\%where, \%attrib);
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a event.

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
  my $default_team_match_template = $params->{default_team_match_template} || undef;
  my $default_individual_match_template = $params->{default_individual_match_template} || undef;
  my $allow_loan_players = $params->{allow_loan_players} || 0;
  my $allow_loan_players_above = $params->{allow_loan_players_above} || 0;
  my $allow_loan_players_below = $params->{allow_loan_players_below} || 0;
  my $allow_loan_players_across = $params->{allow_loan_players_across} || 0;
  my $allow_loan_players_same_club_only = $params->{allow_loan_players_same_club_only} || 0;
  my $allow_loan_players_multiple_teams = $params->{allow_loan_players_multiple_teams} || 0;
  my $loan_players_limit_per_player = $params->{loan_players_limit_per_player} || 0;
  my $loan_players_limit_per_player_per_team = $params->{loan_players_limit_per_player_per_team} || 0;
  my $loan_players_limit_per_player_per_opposition = $params->{loan_players_limit_per_player_per_opposition} || 0;
  my $loan_players_limit_per_team = $params->{loan_players_limit_per_team} || 0;
  my $void_unplayed_games_if_both_teams_incomplete = $params->{void_unplayed_games_if_both_teams_incomplete} || 0;
  my $forefeit_count_averages_if_game_not_started = $params->{forefeit_count_averages_if_game_not_started} || 0;
  my $missing_player_count_win_in_averages = $params->{missing_player_count_win_in_averages} || 0;
  my $round_name = $params->{round_name} || undef;
  my $round_group = $params->{round_group} || 0;
  my $round_group_rank_template = $params->{round_group_rank_template} || undef;
  my $round_team_match_template = $params->{round_team_match_template} || undef;
  my $round_individual_match_template = $params->{round_individual_match_template} || undef;
  my $round_date = $params->{round_date} || undef;
  my $round_week_commencing = $params->{round_week_commencing} || undef;
  my $round_venue = $params->{round_venue} || 0;
  
  # Setup the dates in a hash for looping through
  my @dates = ( $start_date, $end_date, $round_date );
  
  # Date errors hash, as the dates are checked together, not necessarily in the order we want them to appear, so store them here then push to errors when appropriate
  my %date_errors = (start_date => "", end_date => "", round_date => "");
  
  my $season = $schema->resultset("Season")->get_current;
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      round_name => $round_name,
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{error}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # Check the event passed is valid
    unless ( defined($event) and $event->isa("TopTable::Schema::Result::Event") ) {
      push(@{$response->{error}}, $lang->maketext("event.form.error.event-invalid"));
      
      # Another fatal error
      return $response;
    }
  }
  
  unless ( defined($season) ) {
    my $action_desc = $action eq "create" ? $lang->maketext("admin.message.created") : $lang->maketext("admin.message.edited");
    push(@{$response->{error}}, $lang->maketext("events.form.error.no-current-season", $action_desc));
  }
  
  # Required fields - certain keys get deleted depending on the values of other fields
  # Note this is not ALL required fields, just the ones that may or may not be required
  # depending on other factors.
  my ( $venue_required, $start_date_required, $start_time_required, $default_template_required, $first_round_required ) = qw( 1 1 1 0 0 );
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    # Name entered, check it.
    push(@{$response->{error}}, $lang->maketext("events.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $event}));
  } else {
    # Name omitted.
    push(@{$response->{error}}, $lang->maketext("events.form.error.name-blank"));
  }
  
  if ( $action eq "create" or $event->can_edit_event_type ) {
    if ( defined($event_type) ) {
      # We have an event type passed, make sure it's either a valid event type object, or an ID we can look up
      $event_type = $schema->resultset("LookupEventType")->find($event_type) unless $event_type->isa("TopTable::Schema::Result::LookupEventType");
      
      if ( defined($event_type) ) {
        # Valid event type, check if it's a tournament
        if ( $event_type->id eq "single_tournament" ) {
          # If the event is a single-event tournament, then we have to have some default templates (team or individual, depending on entry type) and first round details
          ( $default_template_required, $first_round_required ) = qw( 1 1 );
          
          # Check we have a tournament type
          if ( defined($tournament_type) ) {
            $tournament_type = $schema->resultset("LookupTournamentType")->find($tournament_type) unless $tournament_type->isa("TopTable::Schema::Result::LookupTournamentType");
            
            if ( defined($tournament_type) ) {
              if ( $tournament_type->id eq "team" ) {
                # Event type is 'single_tournament' and tournament type is 'team', so the venue, date, start time, all day flag and finish time are cleared
                undef($venue);
                undef($start_hour);
                undef($start_minute);
                undef($all_day);
                undef($end_hour);
                undef($end_minute);
                ( $venue_required, $start_date_required, $start_time_required, $allow_online_entries ) = qw( 0 0 0 0 );
              } else {
                # Tournament, but not a team tournament - sanity check the allow online entries flag to ensure it's 1 or 0 but nothing else
                $allow_online_entries = $allow_online_entries ? 1 : 0;
              }
            } else {
              # Invalid tournament type
              push(@{$response->{error}}, $lang->maketext("events.form.error.tournament-type-invalid"));
            }
          } else {
            # Tournament type not given
            push(@{$response->{error}}, $lang->maketext("events.form.error.tournament-type-blank"));
          }
        } else {
          # Not a tournament, so we don't need a tournament type
          undef($tournament_type);
        }
      } else {
        # Event type invalid
        push(@{$response->{error}}, $lang->maketext("events.form.error.event-type-invalid"));
      }
    } else {
      # Event type blank
      push(@{$response->{error}}, $lang->maketext("events.form.error.event-type-blank"));
    }
  }
  
  # Ensure the sanitised event / tournament type is passed back
  $response->{fields}{event_type} = $event_type;
  $response->{fields}{tournament_type} = $tournament_type;
  
  if ( $default_template_required and defined($tournament_type) ) {
    if ( $tournament_type->id eq "team" ) {
      # Templates have to be team
      if ( defined($default_team_match_template) ) {
        $default_team_match_template = $schema->resultset("TemplateMatchTeam")->find_id_or_url_key($default_team_match_template) unless $default_team_match_template->isa("TopTable::Schema::Result::TemplateMatchTeam");
        push(@{$response->{error}}, $lang->maketext("events.form.error.def-match-template-invalid")) unless $default_team_match_template->isa("TopTable::Schema::Result::TemplateMatchTeam");
      } else {
        push(@{$response->{error}}, $lang->maketext("events.form.error.def-match-template-blank"));
      }
      
      # We don't want an individual match template for team entry events
      undef($default_individual_match_template);
      
      # Check the loan player options
      
      # Loan player rules
      if ( $allow_loan_players ) {
        # Allow loan players - check rules - the booleans are just sanity checks - set to 1 if the value is true, or 0 if not
        $allow_loan_players = 1; # Sanity - make sure a true value is 1
        $allow_loan_players_above = $allow_loan_players_above ? 1 : 0;
        $allow_loan_players_below = $allow_loan_players_below ? 1 : 0;
        $allow_loan_players_across = $allow_loan_players_across ? 1 : 0;
        $allow_loan_players_same_club_only = $allow_loan_players_same_club_only ? 1 : 0;
        $allow_loan_players_multiple_teams = $allow_loan_players_multiple_teams ? 1 : 0;
        
        # Check the limits are numeric and not negative
        push(@{$response->{error}}, $lang->maketext("events.form.error.loan-playerss-limit-per-player-invalid")) unless $loan_players_limit_per_player =~ m/^\d{1,2}$/;
        push(@{$response->{error}}, $lang->maketext("events.form.error.loan-players-limit-per-player-per-team-invalid")) unless $loan_players_limit_per_player_per_team =~ m/^\d{1,2}$/;
        push(@{$response->{error}}, $lang->maketext("events.form.error.loan-players-limit-per-player-per-opposition-invalid")) unless $loan_players_limit_per_player_per_opposition =~ m/^\d{1,2}$/;
        push(@{$response->{error}}, $lang->maketext("events.form.error.loan-players-limit-per-team-invalid")) unless $loan_players_limit_per_team =~ m/^\d{1,2}$/;
      } else {
        # No loan players, zero all other options
        $allow_loan_players_above = 0;
        $allow_loan_players_below = 0;
        $allow_loan_players_across = 0;
        $allow_loan_players_same_club_only = 0;
        $loan_players_limit_per_player = 0;
        $loan_players_limit_per_player_per_team = 0;
        $loan_players_limit_per_team = 0;
      }
      
      # Rules covering unplayed games / missing players
      $void_unplayed_games_if_both_teams_incomplete = $void_unplayed_games_if_both_teams_incomplete ? 1 : 0;
      $forefeit_count_averages_if_game_not_started = $forefeit_count_averages_if_game_not_started ? 1 : 0;
      $missing_player_count_win_in_averages = $missing_player_count_win_in_averages ? 1 : 0;
      
      $response->{fields}{allow_loan_players} = $allow_loan_players;
      $response->{fields}{allow_loan_players_above} = $allow_loan_players_above;
      $response->{fields}{allow_loan_players_below} = $allow_loan_players_below;
      $response->{fields}{allow_loan_players_across} = $allow_loan_players_across;
      $response->{fields}{allow_loan_players_same_club_only} = $allow_loan_players_same_club_only;
      $response->{fields}{allow_loan_players_multiple_teams} = $allow_loan_players_multiple_teams;
      $response->{fields}{loan_players_limit_per_player} = $loan_players_limit_per_player;
      $response->{fields}{loan_players_limit_per_player_per_team} = $loan_players_limit_per_player_per_team;
      $response->{fields}{loan_players_limit_per_player_per_opposition} = $loan_players_limit_per_player_per_opposition;
      $response->{fields}{loan_players_limit_per_team} = $loan_players_limit_per_team;
      $response->{fields}{void_unplayed_games_if_both_teams_incomplete} = $void_unplayed_games_if_both_teams_incomplete;
      $response->{fields}{forefeit_count_averages_if_game_not_started} = $forefeit_count_averages_if_game_not_started;
      $response->{fields}{missing_player_count_win_in_averages} = $missing_player_count_win_in_averages;
    } else {
      # Templates have to be individual for any tournament entry type other than team (singles or doubles)
      if ( defined($default_individual_match_template) ) {
        $default_individual_match_template = $schema->resultset("TemplateMatchIndividual")->find_id_or_url_key($default_individual_match_template) unless $default_individual_match_template->isa("TopTable::Schema::Result::TemplateMatchIndividual");
        push(@{$response->{error}}, $lang->maketext("events.form.error.def-match-template-invalid")) unless $default_individual_match_template->isa("TopTable::Schema::Result::TemplateMatchIndividual");
      } else {
        push(@{$response->{error}}, $lang->maketext("events.form.error.def-match-template-blank"));
      }
      
      # We don't want a team match template for singles or doubles entry events
      undef($default_team_match_template);
    }
  }
  
  $response->{fields}{default_team_match_template} = $default_team_match_template;
  $response->{fields}{default_individual_match_template} = $default_individual_match_template;
  
  # Check the venue is valid passed and valid
  if ( defined($venue) ) {
    # Venue has been passed, make sure it's valid
    if ( !$venue->isa("TopTable::Schema::Result::Venue") ) {
      # Venue hasn't been passed in as an object, try and lookup as an ID / URL key
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue);
      push(@{$response->{error}}, $lang->maketext("events.form.error.venue-invalid")) unless defined($venue);
    }
    
    # Now check the venue is active if we have one
    push(@{$response->{error}}, $lang->maketext("events.form.error.venue-inactive", encode_entities($venue->name))) if defined($venue) and !$venue->active;
  } else {
    # Venue is blank - only error if we've determined it's required
    push(@{$response->{error}}, $lang->maketext("events.form.error.venue-blank")) if $venue_required;
  }
  
  # Push the sanitised field back
  $response->{fields}{venue} = $venue;
  
  # Validate the organiser if it's been passed in - it's not required, so don't error if it hasn't
  if ( defined($organiser) ) {
    if ( !$organiser->isa("TopTable::Schema::Result::Person") ) {
      # Not passed in as an object, check if it's a valid ID / URL key
      $organiser = $schema->resultset("Person")->find_id_or_url_key($organiser);
      push(@{$response->{error}}, $lang->maketext("events.form.error.organiser-invalid")) unless defined($organiser);
    }
  }
  
  # Push the sanitised field back
  $response->{fields}{organiser} = $organiser;
  
  # Check the dates
  # If the start date isn't required, we'll just undef it, as we don't want it (this is for team events)
  # If the start date is required, check all dates, otherwise just check the last one (round date)
  my $start = $start_date_required ? 0 : 2;
  
  # Remove the first round date if we don't need a first round
  pop(@dates) unless $first_round_required;
  
  # Loop through from start to end - but only if the start element isn't before the end element of the array (this can happen if we
  # don't need a start date - because it's a team tournament - and there's no first round to process - because we're editing)
  if ( $start <= $#dates ) {
    foreach my $date_idx ( $start .. $#dates ) {
      my ( $date_fld, $date_required );
      
      if ( $date_idx == 0 ) {
        $date_required = 1;
        $date_fld = "start_date";
      } elsif ( $date_idx == 1 ) {
        $date_required = 0;
        $date_fld = "end_date";
      } else {
        $date_required = 0;
        $date_fld = "round_date";
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
        } elsif ( !$date->isa("DateTime") ) {
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
        } elsif ( $date_fld eq "end_date" ) {
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
        } else {
          # Round date
        }
      } else {
        # Date is invalid  - set date to undef
        if ( $date_fld eq "start_date" ) {
          undef($start_date);
        } elsif ( $date_fld eq "end_date" ) {
          undef($end_date);
        } else {
          undef($round_date);
        }
      }
    }
  }
  
  $response->{fields}{start_date} = $start_date;
  $response->{fields}{end_date} = $end_date;
  $response->{fields}{round_date} = $round_date;
  
  # Push any start date error we found here
  push(@{$response->{error}}, $date_errors{start_date}) if $date_errors{start_date};
  
  # Check the start time is valid if we need it
  if ( defined($start_hour) ) {
    # Passed in, check it's valid
    push(@{$response->{error}}, $lang->maketext("events.form.error.start-hour-invalid")) unless $start_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
  } else {
    # Blank, error if it's required
    push(@{$response->{error}}, $lang->maketext("events.form.error.start-hour-blank")) if $start_time_required;
  }
  
  if ( defined($start_minute) ) {
    # Passed in, check it's valid
    push(@{$response->{error}}, $lang->maketext("events.form.error.start-minute-invalid")) unless $start_minute =~ m/^(?:[0-5][0-9])$/;
  } else {
    # Blank, error if it's required
    push(@{$response->{error}}, $lang->maketext("events.form.error.start-minute-blank")) if $start_time_required;
  }
  
  push(@{$response->{error}}, $lang->maketext("events.form.error.start-time-partially-blank")) if (!$start_time_required and (defined($start_hour) and !defined($start_minute)) or (!defined($start_hour) and defined($start_minute)));
  
  if ( $all_day ) {
    # All day events don't have a finish time
    undef($end_date);
    undef($end_hour);
    undef($end_minute);
  } else {
    # Push any start date error we found here
    push(@{$response->{error}}, $date_errors{end_date}) if $date_errors{end_date};
    
    # Check the finish time, if it's provided
    if ( defined($end_hour) ) {
      # Passed in, check it's valid
      push(@{$response->{error}}, $lang->maketext("events.form.error.finish-hour-invalid")) unless $end_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    }
    
    if ( defined($end_minute) ) {
      # Passed in, check it's valid
      push(@{$response->{error}}, $lang->maketext("events.form.error.finish-minute-invalid")) unless $end_minute =~ m/^(?:[0-5][0-9])$/;
    }
    
    push(@{$response->{error}}, $lang->maketext("events.form.error.end-time-partially-blank")) if (defined($end_hour) and !defined($end_minute)) or (!defined($end_hour) and defined($end_minute));
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
      push(@{$response->{error}}, $lang->maketext("events.form.error.start-date-must-be-before-end-date"));
    }
  }
  
  if ( $first_round_required ) {
    # Need first round details, so check those fields
    # No need to check the name - the name is optional and only needs to be unique (when specified) within the current tournament;
    # if we're creating, there are no other rounds to check this against yet, if we're editing there are no first round details to check.
    
    # Sanity check for the group round field
    $round_group = $round_group ? 1 : 0;
    $response->{fields}{round_group} = $round_group;
    
    if ( $round_group ) {
      if ( defined($round_group_rank_template) ) {
        # Check we have a valid table rank template
        $round_group_rank_template = $schema->resultset("TemplateLeagueTableRanking")->find($round_group_rank_template) unless $round_group_rank_template->isa("TopTable::Schema::Result::TemplateLeagueTableRanking");
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.table-ranking-template-invalid")) unless defined($round_group_rank_template);
      } else {
        # Error, we need a table rank template in a group round
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.table-ranking-template-blank"));
      }
    } else {
      # Not a group round, ensure the ranking template is undef
      undef($round_group_rank_template);
    }
    
    $response->{fields}{round_group_rank_template} = $round_group_rank_template;
    
    # Check the template - need to know the entry type for this - they are optional, as the tournament has a default, so only raise an error if it's specified and invalid
    if ( $tournament_type->id eq "team" ) {
      # Check the round team match template and undef the individual one
      if ( defined($round_team_match_template) ) {
        # Lookup the first round team match template if it's provided (and not already a template object)
        $round_team_match_template = $schema->resultset("TemplateMatchTeam")->find($round_team_match_template) unless $round_team_match_template->isa("TopTable::Schema::Result::TemplateMatchTeam");
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.match-template-invalid")) unless defined($round_team_match_template);
        
        # Ensure the individual match template is undef
        undef($round_individual_match_template);
      }
    } else {
      # Any other entry type, we check the round individual match template and undef the team one
      if ( defined($round_individual_match_template) ) {
        # Lookup the first round team match template if it's provided (and not already a template object)
        $round_individual_match_template = $schema->resultset("TemplateMatchIndividual")->find($round_individual_match_template) unless $round_individual_match_template->isa("TopTable::Schema::Result::TemplateMatchIndividual");
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.match-template-invalid")) unless defined($round_individual_match_template);
        
        # Ensure the individual match template is undef
        undef($round_team_match_template);
      }
    }
    
    # The date is already checked in the dates loop above, put hte error here if we have one
    push(@{$response->{error}}, $date_errors{round_date}) if $date_errors{round_date};
    
    # Check the round venue if supplied
    if ( defined($round_venue) ) {
      $round_venue = $schema->resultset("Venue")->find_id_or_url_key($round_venue) unless $round_venue->isa("TopTable::Schema::Result::Venue");
      
      if ( defined($round_venue) ) {
        # Venue is valid, but need to check it's active
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.venue-inactive", encode_entities($venue->name))) unless $round_venue->active;
      } else {
        # Invalid venue
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.form.error.venue-invalid"));
      }
    }
    
    $response->{fields}{round_venue} = $round_venue;
  }
  
  if ( scalar(@{$response->{error}}) == 0 ) {
    # Success, we need to create / edit the event
    # Build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($name, $event);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Create a transaction to safeguard - if either operation fails, nothing is written / updated
    my $transaction = $class->result_source->schema->txn_scope_guard;
    my $round_response;
    my $commit = 1; # Default - revert to 0 if the first round doesn't create
    
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
      
      if ( $event_type->id eq "single_tournament" ) {
        my $tournament = $event_season->create_related("tournaments", {
          season => $season->id,
          name => $name,
          entry_type => $tournament_type->id,
          allow_online_entries => $allow_online_entries,
          default_team_match_template => defined($default_team_match_template) ? $default_team_match_template->id : undef,
          default_individual_match_template => defined($default_individual_match_template) ? $default_individual_match_template->id : undef,
          allow_loan_players_above => $allow_loan_players_above,
          allow_loan_players_below => $allow_loan_players_below,
          allow_loan_players_across => $allow_loan_players_across,
          allow_loan_players_same_club_only => $allow_loan_players_same_club_only,
          allow_loan_players_multiple_teams => $allow_loan_players_multiple_teams,
          loan_players_limit_per_player => $loan_players_limit_per_player,
          loan_players_limit_per_player_per_team => $loan_players_limit_per_player_per_team,
          loan_players_limit_per_player_per_opposition => $loan_players_limit_per_player_per_opposition,
          loan_players_limit_per_team => $loan_players_limit_per_team,
          void_unplayed_games_if_both_teams_incomplete => $void_unplayed_games_if_both_teams_incomplete,
          forefeit_count_averages_if_game_not_started => $forefeit_count_averages_if_game_not_started,
          missing_player_count_win_in_averages => $missing_player_count_win_in_averages,
        });
        
        if ( $first_round_required ) {
          $round_response = $tournament->create_or_edit_round(undef, {
            round_name => $round_name,
            round_group => $round_group,
            round_group_rank_template => $round_group_rank_template,
            round_team_match_template => $round_team_match_template,
            round_individual_match_template => $round_individual_match_template,
            round_date => $round_date,
            round_venue => $round_venue,
          });
          
          # Push any responses we get back to the calling routine
          push(@{$response->{error}}, @{$round_response->{error}});
          push(@{$response->{warning}}, @{$round_response->{warning}});
          push(@{$response->{info}}, @{$round_response->{info}});
          push(@{$response->{success}}, @{$round_response->{success}});
          $response->{round_completed} = $round_response->{completed};
          $commit = 0 unless $response->{round_completed};
        }
      } elsif ( $event_type->id eq "meeting" ) {
        my $meeting = $event_season->create_related("meetings", {season => $season->id});
      }
      
      $response->{completed} = 1 if $commit;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $event->name, $lang->maketext("admin.message.created")));
    } else {
      if ( $event->can_edit_event_type ) {
        if ( defined($event_type) and $event_type->id ne $event->event_type->id ) {
          # Event type has changed, get the old value then update the field
          my $old_event_type = $event->event_type->id;
          $event->event_type($event_type->id);
          
          # Now depending on the old event type, we need to delete meetings or tournaments
          if ( $old_event_type eq "single_tournament" ) {
            # Delete tournament matches
            
          } elsif ( $old_event_type eq "meeting" ) {
            # Delete meetings
            
          }
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
      
      $response->{completed} = 1 if $commit;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $event->name, $lang->maketext("admin.message.edited")));
    }
    
    # Commit the transaction if there are no errors
    $transaction->commit if $commit;
    
    $response->{event} = $event;
  }
  
  return $response;
}

1;
