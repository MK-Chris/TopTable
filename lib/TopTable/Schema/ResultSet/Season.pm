package TopTable::Schema::ResultSet::Season;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use Data::Dumper;

=head2 last_complete_season

A predefined search to find the latest season that has been completed; optionally takes a team, in which case returns the latest completed season that the specified team entered.

=cut

sub last_complete_season {
  my ( $self, $team ) = @_;
  my ( $where, $attributes );
  
  if ( $team ) {
    $where      = {
      complete            => 1,
      "team_seasons.team" => $team->id
    };
    $attributes = {
      prefetch  => {team_seasons => "home_night"},
      order_by  => {  -desc => [qw/ start_date end_date /] },
      rows      => 1,
    };
  } else {
    $where      = {complete  => 1,};
    $attributes = {
      order_by  => {
        -desc   => [qw( start_date end_date )]
      },
      rows      => 1,
    };
  }
  
  return $self->find( $where, $attributes );
}

=head2 all_seasons

A predefined search to find all seasons.  A non-complete season will be ordered first, then in descending order of start date, then end date.

=cut

sub all_seasons {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => [{
      -asc => [
        qw( complete )
      ]}, {
      -desc => [
        qw( start_date end_date )
      ]}, {
        -asc => [
          qw( division.rank )
      ]}
    ],
    prefetch  => {
      division_seasons  => "division",
    },
  });
}

=head2 get_archived

A predefined search to get all archived seasons (complete = 1)

=cut

sub get_archived {
  my ( $self ) = @_;
  
  return $self->search({
    complete => 1,
  }, {
    order_by => [{
      -desc => [
        qw(
          start_date
          end_date
          )
      ]
    }, {
      -asc => [
        qw( division.rank )
      ],
    }],
    prefetch  => {
      division_seasons  => "division",
    },
  });
}

=head2 get_current

A predefined search to get the current season (complete = 0)

=cut

sub get_current {
  my ( $self ) = @_;
  
  return $self->find({
    complete  => 0,
  }, {
    order_by => {
      -asc => [qw( division.rank )],
    },
    prefetch  => {
      division_seasons  => "division",
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
    $where = {
      id => $id_or_url_key,
    };
  } else {
    # Not numeric - must be the URL key
    $where = {
      url_key => $id_or_url_key,
    };
  }
  
  return $self->find( $where );
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $parameters ) = @_;
  my $name        = $parameters->{name};
  my $exclude_id  = $parameters->{id};
  my $log         = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc( $original_url_key ); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined( $count ) ) {
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

=head2 divisions_and_teams_in_season

Retrieve the season with the specified ID, prefetched with the teams and divisions.

=cut

sub divisions_and_teams_in_season {
  my ( $self, $season_id ) = @_;
  
  return $self->find({
    id  => $season_id,
  }, {
    prefetch  => [{
      division_seasons => "division",
    }, {
      team_seasons => [{
        team => {
          club => "venue",
        },
      },
      "home_night"],
    }],
  });
}

=head2 last_season_with_team_entries

Return the last season that has any teams registered to it.

=cut

sub last_season_with_team_entries {
  my ( $self ) = @_;
  
  return $self->find({}, {
    join => {
      team_seasons => "team",
    },
    having => \["COUNT(team.id) > ?", 0],
    group_by => "me.id",
    rows => 1,
    order_by => [{
      -asc => [qw( complete )]
    }, {
      -desc => [qw( start_date end_date )]
    }],
  });
}

=head2 page_records

Retrieve a paginated list of seasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number       = $parameters->{page_number} || 1;
  my $results_per_page  = $parameters->{results_per_page} || 25;
  my $club              = $parameters->{club};
  my $team              = $parameters->{team};
  my $division          = $parameters->{division};
  my $person            = $parameters->{person};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  # Attributes has a default set that doesn't change (only the join is added after this).  The criteria is added when we know which object is specified
  my $where;
  my $attributes = {
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => [{
      -asc    => [qw( complete )]
    }, {
      -desc   => [qw( start_date end_date )]
    }],
    group_by => "me.id",
  };
  
  if ( defined( $club ) ) {
    $where = {
      "club.id" => $club->id,
    };
    $attributes->{join} = {
      team_seasons => "club",
    };
  } elsif ( defined( $team ) ) {
    $where = {
      "team.id" => $team->id,
    };
    $attributes->{join} = {
      team_seasons => "team",
    };
  } elsif ( defined( $division ) ) {
    $where = {
      "division.id" => $division->id,
    };
    $attributes->{join} = {
      division_seasons => "division",
    };
  } elsif ( defined( $person ) ) {
    $where = {
      "person.id" => $person->id,
    };
    $attributes->{join} = {
      person_seasons => "person",
    };
  }
  
  return $self->search($where, $attributes);
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $season_name_check, $start_date_error, $season_weeks, $end_date_error, $restricted_edit );
  
  my $id                                              = $parameters->{id} || undef;
  my $season                                          = $parameters->{season} || undef;
  my $name                                            = $parameters->{name} || undef;
  my $start_date                                      = $parameters->{start_date} || undef;
  my $end_date                                        = $parameters->{end_date} || undef;
  my $start_hour                                      = $parameters->{start_hour} || undef;
  my $start_minute                                    = $parameters->{start_minute} || undef;
  my $timezone                                        = $parameters->{timezone} || undef;
  my $allow_loan_players                              = $parameters->{allow_loan_players} || 0;
  my $allow_loan_players_above                        = $parameters->{allow_loan_players_above} || 0;
  my $allow_loan_players_below                        = $parameters->{allow_loan_players_below} || 0;
  my $allow_loan_players_across                       = $parameters->{allow_loan_players_across} || 0;
  my $allow_loan_players_same_club_only               = $parameters->{allow_loan_players_same_club_only} || 0;
  my $allow_loan_players_multiple_teams_per_division  = $parameters->{allow_loan_players_multiple_teams_per_division} || 0;
  my $loan_players_limit_per_player                   = $parameters->{loan_players_limit_per_player} || 0;
  my $loan_players_limit_per_player_per_team          = $parameters->{loan_players_limit_per_player_per_team} || 0;
  my $loan_players_limit_per_team                     = $parameters->{loan_players_limit_per_team} || 0;
  my $rules                                           = $parameters->{rules} || undef;
  my $log                                             = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $lang                                            = $parameters->{language} || sub { return wantarray ? @_ : "@_"; }; # Default to a sub that just returns everything, as we don't want errors if we haven't passed in a language sub.
  my $return          = {
    fatal             => [],
    error             => [],
    warning           => [],
    sanitised_fields  => {
      name  => $name, # Don't need to do anything to sanitise the name, so just pass it back in
    },
  };
  
  # Split the year up
  my ($start_day, $start_month, $start_year)  = split("/", $start_date) if defined( $start_date );
  my ($end_day, $end_month, $end_year)        = split("/", $end_date) if defined( $end_date );
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return->{error} }, $lang->("admin.form.invalid-action", $action) );
    
    return $return;
  } elsif ($action eq "edit") {
    # Check the user passed is valid
    unless ( defined( $season ) and ref( $season ) eq "TopTable::Model::DB::Season" ) {
      push(@{ $return->{error} }, $lang->("seasons.form.error.season-invalid"));
      
      # Another fatal error
      return $return;
    }
    
    # Find out if we can edit the dates for this season; otherwise we'll ignore the date inputs
    my $league_matches = $season->search_related("team_matches")->count;
    
    # Check if we have any rows, if so disable the dates
    $restricted_edit = ( $league_matches ) ? 1 : 0;
  }
  
  # Make sure we return the restricted edit value
  $return->{restricted_edit} = $restricted_edit;
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    if ( $action eq "edit" ) {
      $season_name_check = $self->find({}, {
        where => {
          name  => $name,
          id    => {"!=" => $season->id},
        }
      });
    } else {
      $season_name_check = $self->find({name => $name});
    }
    
    push(@{ $return->{error} }, $lang->("seasons.form.error.name-exists", $name)) if defined( $season_name_check );
  } else {
    # Full name omitted.
    push(@{ $return->{error} }, $lang->("seasons.form.error.name-blank"));
  }
  
  # Check the entered start time values (hour and minute) are valid
  unless( $restricted_edit ) {
    if ( !$start_hour or $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
      push(@{ $return->{error} }, $lang->("seasons.form.error.start-hour-invalid"));
      $start_hour = "";
    }
    
    if ( !$start_minute or $start_minute !~ m/^(?:[0-5][0-9])$/ ) {
      push(@{ $return->{error} }, $lang->("seasons.form.error.start-minute-invalid"));
      $start_minute = "";
    }
    
    # Add hour / minute fields to the sanitised group
    $return->{sanitised_fields}{start_hour}   = $start_hour;
    $return->{sanitised_fields}{start_minute} = $start_minute;
  }
  
  if ( defined( $timezone ) ) {
    unless ( DateTime::TimeZone->is_valid_name( $timezone ) ) {
      push(@{ $return->{error} }, $lang->("seasons.form.error.timezone-invalid"));
      $timezone = "";
    }
  } else {
    push(@{ $return->{error} }, $lang->("seasons.form.error.timezone-blank"));
  }
  
  $return->{sanitised_fields}{timezone} = $timezone;
  
  # Only error check the dates / loan player rules if we're not ignoring them.
  if ( !$restricted_edit ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    # unshift instead of push so these errors (if they are errors) are at the start of the array
    try {
      $end_date = DateTime->new(
        year  => $end_year,
        month => $end_month,
        day   => $end_day,
      );
    } catch {
      unshift(@{ $return->{error} }, $lang->("seasons.form.error.end-date-invalid"));
      $end_date_error = 1; # We need to know whether or not we can call datetime methods on this
      $end_date       = "";
    };
    
    try {
      $start_date = DateTime->new(
        year  => $start_year,
        month => $start_month,
        day   => $start_day,
      );
    } catch {
      unshift(@{ $return->{error} }, $lang->("seasons.form.error.start-date-invalid"));
      $start_date_error = 1; # We need to know whether or not we can call datetime methods on this
      $start_date       = "";
    };
    
    $return->{sanitised_fields}{start_date} = ( ref( $start_date ) eq "DateTime" ) ? $start_date->dmy("/") : "";
    $return->{sanitised_fields}{end_date}   = ( ref( $end_date ) eq "DateTime" ) ? $end_date->dmy("/") : "";
    
    # We can only do these date checks if we didn't trap any errors in the previous routines, as otherwise they won't be proper DateTime objects
    if ( !$start_date_error and !$end_date_error ) {
      # No errors on the dates so far; make sure the end date is after the start date
      if ( $end_date->ymd("") <= $start_date->ymd("") ) {
        push(@{ $return->{error} }, $lang->("seasons.form.error.start-date-after-end-date"));
      } else {
        # Change our week days to the Monday in the same week, if they're not already
        $start_date = TopTable::Controller::Root::get_day_in_same_week($start_date, 1);
        $end_date   = TopTable::Controller::Root::get_day_in_same_week($end_date, 1);
        
        # Now find out the number of weeks we'll be using for this
        # Iterate through dates from the start date to the end date, adding one week each time.
        for (my $dt = $start_date->clone; $dt <= $end_date; $dt->add( weeks => 1 ) ) {
          $season_weeks++;
        }
        
        $return->{season_weeks} = $season_weeks;
      }
    }
    
    # Loan player rules
    if ( $allow_loan_players ) {
      # Allow loan players - check rules - the booleans are just sanity checks - set to 1 if the value is true, or 0 if not
      $allow_loan_players_above                        = $allow_loan_players_above                        ? 1 : 0;
      $allow_loan_players_below                        = $allow_loan_players_below                        ? 1 : 0;
      $allow_loan_players_across                       = $allow_loan_players_across                       ? 1 : 0;
      $allow_loan_players_same_club_only               = $allow_loan_players_same_club_only               ? 1 : 0;
      $allow_loan_players_multiple_teams_per_division  = $allow_loan_players_multiple_teams_per_division  ? 1 : 0;
      
      # Check the limits are numeric and not negative
      unless ( $loan_players_limit_per_player eq "" or $loan_players_limit_per_player =~ m/^\d{1,2}$/ ) {
        push(@{ $return->{error} }, $lang->("seasons.form.error.loan-playerss-limit-per-player-invalid"));
        $loan_players_limit_per_player = "";
      }
      
      unless ( $loan_players_limit_per_player_per_team eq "" or $loan_players_limit_per_player_per_team =~ m/^\d{1,2}$/ ) {
        push(@{ $return->{error} }, {id => "seasons.form.error.loan-players-limit-per-player-per-team-invalid"});
        $loan_players_limit_per_player_per_team = "";
      }
      
      unless ( $loan_players_limit_per_team eq "" or $loan_players_limit_per_team =~ m/^\d{1,2}$/ ) {
        push(@{ $return->{error} }, {id => "seasons.form.error.loan-players-limit-per-team"});
        $loan_players_limit_per_team = "";
      }
    } else {
      # No loan players, zero all other options
      $allow_loan_players_above               = 0;
      $allow_loan_players_below               = 0;
      $allow_loan_players_across              = 0;
      $allow_loan_players_same_club_only      = 0;
      $loan_players_limit_per_player          = 0;
      $loan_players_limit_per_player_per_team = 0;
      $loan_players_limit_per_team            = 0;
    }
    
    $return->{sanitised_fields}{allow_loan_players}                             = $allow_loan_players;
    $return->{sanitised_fields}{allow_loan_players_above}                       = $allow_loan_players_above;
    $return->{sanitised_fields}{allow_loan_players_below}                       = $allow_loan_players_below;
    $return->{sanitised_fields}{allow_loan_players_across}                      = $allow_loan_players_across;
    $return->{sanitised_fields}{allow_loan_players_same_club_only}              = $allow_loan_players_same_club_only;
    $return->{sanitised_fields}{allow_loan_players_multiple_teams_per_division} = $allow_loan_players_multiple_teams_per_division;
    $return->{sanitised_fields}{loan_players_limit_per_player}                  = $loan_players_limit_per_player;
    $return->{sanitised_fields}{loan_players_limit_per_player_per_team}         = $loan_players_limit_per_player_per_team;
    $return->{sanitised_fields}{loan_players_limit_per_team}                    = $loan_players_limit_per_team;
  }
  
  if ( scalar( @{ $return->{error} } ) == 0 ) {
    my $url_key;
    if ( $action eq "edit" ) {
      
      $url_key = $self->generate_url_key({
        name    => $name,
        id      => $season->id,
      });
    } else {
      $url_key = $self->generate_url_key({name => $name});
    }
    
    # Filter the HTML from the rules
    $rules = TopTable->model("FilterHTML")->filter( $rules, "textarea" );
    
    my @fixtures_weeks = ();
    if ( $action eq "create" or !$restricted_edit ) {
      # Create the related weeks array
      # Now we need to create some weeks for that season between the start and end dates
      # Iterate through dates from the start date to the end date, adding one week each time.
      for (my $dt = $start_date->clone; $dt <= $end_date; $dt->add( weeks => 1 ) ) {
        push(@fixtures_weeks, {week_beginning_date => $dt->clone->ymd});
      }
    }
    
    if ( $action eq "create" ) {
      # Success, we need to create the season
      $season = $self->create({
        name                                            => $name,
        url_key                                         => $url_key,
        start_date                                      => $start_date->ymd,
        end_date                                        => $end_date->ymd,
        default_match_start                             => sprintf( "%s:%s", $start_hour, $start_minute ),
        timezone                                        => $timezone,
        allow_loan_players_above                        => $allow_loan_players_above,
        allow_loan_players_below                        => $allow_loan_players_below,
        allow_loan_players_across                       => $allow_loan_players_across,
        allow_loan_players_same_club_only               => $allow_loan_players_same_club_only,
        allow_loan_players_multiple_teams_per_division  => $allow_loan_players_multiple_teams_per_division,
        loan_players_limit_per_player                   => $loan_players_limit_per_player,
        loan_players_limit_per_player_per_team          => $loan_players_limit_per_player_per_team,
        loan_players_limit_per_team                     => $loan_players_limit_per_team,
        fixtures_weeks                                  => \@fixtures_weeks,
        rules                                           => $rules,
      });
    } else {
      my $update_data;
      if ( $restricted_edit ) {
        # In restricted edit mode, we can only update certain fields
        $update_data = {
          name                    => $name,
          url_key                 => $url_key,
          default_match_start     => sprintf("%02d:%02d", $start_hour, $start_minute),
          rules                   => $rules,
        };
      } else {
        $update_data = {
          name                                            => $name,
          url_key                                         => $url_key,
          start_date                                      => $start_date->ymd,
          end_date                                        => $end_date->ymd,
          default_match_start                             => sprintf("%02d:%02d", $start_hour, $start_minute),
          allow_loan_players_above                        => $allow_loan_players_above,
          allow_loan_players_below                        => $allow_loan_players_below,
          allow_loan_players_across                       => $allow_loan_players_across,
          allow_loan_players_same_club_only               => $allow_loan_players_same_club_only,
          allow_loan_players_multiple_teams_per_division  => $allow_loan_players_multiple_teams_per_division,
          loan_players_limit_per_player                   => $loan_players_limit_per_player,
          loan_players_limit_per_player_per_team          => $loan_players_limit_per_player_per_team,
          loan_players_limit_per_team                     => $loan_players_limit_per_team,
          rules                                           => $rules,
        };
      }
      
      $season->update( $update_data );
      
      if ( !$restricted_edit ) {
        # Since we're updating, if we've been able to update the dates, we will need to delete the existing fixtures weeks and recreate them
        $season->delete_related("fixtures_weeks");
        
        # Now we need to recreate them
        $season->create_related( "fixtures_weeks", $_ ) for ( @fixtures_weeks ); 
      }
    }
    
    # Process the divisions passed in.
    my $divisions = [];
    
    # Check if we have an array of values (multiple games) or not (just a single game).
    unless ( ref( $parameters->{division_name} ) eq "ARRAY" ) {
      # Set parameters that would be arrays in the case of multi-divisions to arrays so we can use the same code in the loop
      $parameters->{division_name}                  = [ $parameters->{division_name} ];
      $parameters->{league_match_template}          = [ $parameters->{league_match_template} ];
      $parameters->{league_table_ranking_template}  = [ $parameters->{league_table_ranking_template} ];
      $parameters->{fixtures_grid}                  = [ $parameters->{fixtures_grid} ];
    }
    
    # Now loop through our divisions
    for my $i ( 0 .. scalar( @{ $parameters->{division_name} } ) ) {
      my $rank = $i + 1;
      
      # The "use" field is onlt sent if it's ticked, so we can't use a repeating field name.
      if ( $parameters->{"use_division$rank"} or $rank == 1 ) {
        # Take the parameters from the form and put them into the divisions array
        $divisions->[$i]{name}                          = $parameters->{division_name}[$i];
        $divisions->[$i]{id}                            = $parameters->{division_id}[$i];
        $divisions->[$i]{league_match_template}         = $parameters->{league_match_template}[$i];
        $divisions->[$i]{league_table_ranking_template} = $parameters->{league_table_ranking_template}[$i];
        $divisions->[$i]{fixtures_grid}                 = $parameters->{fixtures_grid}[$i];
        $divisions->[$i]{use_division}                  = 1;
      }
    }
    
    # Now send the divisions of for creation / editing
    my $division_details = $self->result_source->schema->resultset("Division")->check_and_create({
      divisions => $divisions,
      logger    => $log,
      language  => $lang,
    }) unless $restricted_edit;
    
    # Turn division details errors into warnings for the return from here, as we have still created the division
    push( @{ $return->{warning} }, @{ $division_details->{error} }, @{ $division_details->{warning} } );
    $return->{divisions} = $division_details->{divisions};
    $return->{divisions_sanitised_fields} = $division_details->{sanitised_fields};
  }
  
  # The season needs to be returned so we have a handle to it in the controller  
  $return->{season} = $season;
  return $return;
}

1;