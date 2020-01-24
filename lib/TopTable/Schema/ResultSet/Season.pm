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
  
  return $self->find({
    url_key => $url_key,
  });
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
  my ( $self, $short_name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($short_name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
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
  my $return_value = {error => []};
  my ( $season_name_check, $start_date_error, $season_weeks, $end_date_error, $restricted_edit );
  
  my $id                                              = $parameters->{id} || undef;
  my $season                                          = $parameters->{season} || undef;
  my $name                                            = $parameters->{name} || undef;
  my $start_date                                      = $parameters->{start_date} || undef;
  my $end_date                                        = $parameters->{end_date} || undef;
  my $start_hour                                      = $parameters->{start_hour} || undef;
  my $start_minute                                    = $parameters->{start_minute} || undef;
  my $timezone                                        = $parameters->{timezone} || undef;
  my $allow_loan_players                              = $parameters->{allow_loan_players} || undef;
  my $allow_loan_players_above                        = $parameters->{allow_loan_players_above} || undef;
  my $allow_loan_players_below                        = $parameters->{allow_loan_players_below} || undef;
  my $allow_loan_players_across                       = $parameters->{allow_loan_players_across} || undef;
  my $allow_loan_players_same_club_only               = $parameters->{allow_loan_players_same_club_only} || undef;
  my $allow_loan_players_multiple_teams_per_division  = $parameters->{allow_loan_players_multiple_teams_per_division} || undef;
  my $loan_players_limit_per_player                   = $parameters->{loan_players_limit_per_player} || 0;
  my $loan_players_limit_per_player_per_team          = $parameters->{loan_players_limit_per_player_per_team} || 0;
  my $loan_players_limit_per_team                     = $parameters->{loan_players_limit_per_team} || 0;
  my $rules                                           = $parameters->{rules} || undef;
  
  # Split the year up
  my ($start_day, $start_month, $start_year)  = split("/", $start_date) if defined( $start_date );
  my ($end_day, $end_month, $end_year)        = split("/", $end_date) if defined( $end_date );
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    return $return_value;
  } elsif ($action eq "edit") {
    # Check the user passed is valid
    unless ( defined( $season ) and ref( $season ) eq "TopTable::Model::DB::Season" ) {
      push(@{ $return_value->{error} }, {id => "seasons.form.error.season-invalid"});
      
      # Another fatal error
      return $return_value;
    }
    
    # Find out if we can edit the dates for this season; otherwise we'll ignore the date inputs
    my $league_matches = $season->search_related("team_matches")->count;
    
    # Check if we have any rows, if so disable the dates
    $restricted_edit = 1 if $league_matches > 0;
  }
  
  # Make sure we return the restricted edit value
  $return_value->{restricted_edit} = $restricted_edit;
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    if ( $action eq "edit" ) {
      $season_name_check = $self->find({}, {
        where => {
          name  => $name,
          id    => {
            "!=" => $season->id,
          }
        }
      });
    } else {
      $season_name_check = $self->find({name => $name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "seasons.form.error.name-exists",
      parameters  => [$name],
    }) if defined( $season_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "seasons.form.error.name-blank"});
  }
  
  # Check the entered start time values (hour and minute) are valid
  unless( $restricted_edit ) {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.start-hour-invalid"}) if !$start_hour or $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    push(@{ $return_value->{error} }, {id => "seasons.form.error.start-minute-invalid"}) if !$start_minute or $start_minute !~ m/^(?:[0-5][0-9])$/;
  }
  
  if ( defined( $timezone ) ) {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.timezone-invalid"}) unless DateTime::TimeZone->is_valid_name( $timezone );
  } else {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.timezone-blank"});
  }
  
  # Only error check the dates / loan player rules if we're not ignoring them.
  if ( !$restricted_edit ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    try {
      $start_date = DateTime->new(
        year  => $start_year,
        month => $start_month,
        day   => $start_day,
      );
    } catch {
      push(@{ $return_value->{error} }, {id => "seasons.form.error.start-date-invalid"});
      $start_date_error = 1; # We need to know whether or not we can call datetime methods on this
    };
    
    try {
      $end_date = DateTime->new(
        year  => $end_year,
        month => $end_month,
        day   => $end_day,
      );
    } catch {
      push(@{ $return_value->{error} }, {id => "seasons.form.error.end-date-invalid"});
      $end_date_error = 1; # We need to know whether or not we can call datetime methods on this
    };
    
    # We can only do these date checks if we didn't trap any errors in the previous routines, as otherwise they won't be proper DateTime objects
    if ( !$start_date_error and !$end_date_error ) {
      # No errors on the dates so far; make sure the end date is after the start date
      if ( $end_date->ymd("") <= $start_date->ymd("") ) {
        push(@{ $return_value->{error} }, {id => "seasons.form.error.start-date-after-end-date"});
      } else {
        # Change our week days to the Monday in the same week, if they're not already
        $start_date = TopTable::Controller::Root::get_day_in_same_week($start_date, 1);
        $end_date   = TopTable::Controller::Root::get_day_in_same_week($end_date, 1);
        
        # Now find out the number of weeks we'll be using for this
        # Iterate through dates from the start date to the end date, adding one week each time.
        for (my $dt = $start_date->clone; $dt <= $end_date; $dt->add( weeks => 1 ) ) {
          $season_weeks++;
        }
        
        $return_value->{season_weeks} = $season_weeks;
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
      push(@{ $return_value->{error} }, {id => "seasons.form.error.loan-playerss-limit-per-player-invalid"}) unless $loan_players_limit_per_player =~ m/^\d{1,2}$/;
      push(@{ $return_value->{error} }, {id => "seasons.form.error.loan-players-limit-per-player-per-team-invalid"}) unless $loan_players_limit_per_player_per_team =~ m/^\d{1,2}$/;
      push(@{ $return_value->{error} }, {id => "seasons.form.error.loan-players-limit-per-team"}) unless $loan_players_limit_per_team =~ m/^\d{1,2}$/;
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
  }
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $id );
    } else {
      $url_key = $self->generate_url_key( $name );
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
  }
  
  # The season needs to be returned so we have a handle to it in the controller  
  $return_value->{season} = $season;
  return $return_value;
}

=head2 edit_teams_list

Takes a list of teams and validates them before creating / updating the team_season object for the current season.  There must already be a current season and fixtures must not have been created yet.

Each team item should have a hashref with the following:

db: DB::Team object referring to the row in the teams database for this team.
id: team ID (id column in the teams database).
new_club: DB::Club object referring to the row in the club database for the new club.
new_division: DB::Division object referring to the row in the divisions database for the new division.
new_home_night: DB::Weekday object referring to the row in the weekdays database for the new home night.
new_name: the new name for this team.
new_captain: DB::Person object referring to the row in the people database for the new captain (optional).
new_players: array of DB::Person objects referring to the rows in the people database for the players in the team (optional.)
entered: boolean value telling us whether to enter the team or not (if false, none of the above are required and if supplied are ignored).

The following checks are performed for the given parameters:
new_club: is checked that it's a valid club object.
new_division: is checked that it's a valid division object and that the given division has a division_season row for the current season; all teams being added to any division are added to the teams already added to that division to ensure that there are not too many teams in the division for the grid attached to that division.
new_home_night: is checked that it's a valid weekday object.
new_name: is checked the new names to ensure that there are no clashes (teams being added to the same club with the same name for the current season in addition to teams that have already been added to the current season with the given club and name).

=cut

sub edit_teams_list {
  my ( $self, $parameters ) = @_;
  my $teams           = $parameters->{teams};
  my $reassign_active = $parameters->{reassign_active_players};
  my $return_value    = {
    error   => [],
    warning => [],
  };
  
  # Make sure there's a current season
  my $season = $self->get_current;
  
  unless ( defined( $season ) ) {
    push(@{ $return_value->{error} }, {id => "seasons.set-teams.error.no-current-season"});
    return $return_value;
  }
  
  # Make sure we have no matches yet, otherwise we can't enter any more teams
  my $matches = $season->search_related("team_matches")->count;
  
  if ( $matches ) {
    push(@{ $return_value->{error} }, {id => "seasons.set-teams.error.matches-created"});
    return $return_value;
  }
  
  # Check the teams is an arrayref
  if ( ref( $teams ) eq "HASH" ) {
    # If it's a hashref, just convert it to a single row arrayref for ease of use
    $teams = [ $teams ];
  } elsif ( ref( $teams ne "ARRAY" ) ) {
    die "The \$teams parameter must be an array reference or a hash reference.";
  }
  
  # Array of team IDs not entering
  my @teams_not_entering;
  
  # Get the valid divisions we can add to - these have a key of the division ID for easy access
  my %valid_divisions = map {
    # Set up the Division ID as the key
    $_->division->id => {
      name          => $_->division->name, # Name so we can refer to it if required in error messages
      maximum_teams => $_->fixtures_grid->maximum_teams, # Maximum number of teams is obtained from the fixtures grid associated with this division this season
      grid_name     => $_->fixtures_grid->name, # Grid name for error messages
      
      # For the current number of teams attached to this division we need to do a little extra search
      current_teams => $_->search_related("division", {
        "team_seasons.season" => $season->id,
      }, {
        join => "team_seasons",
      })->count,
    };
  } @{[
    $season->search_related("division_seasons", {}, {
      prefetch => "fixtures_grid",
      join => "division",
    })
  ]};
  
  # Build up a list of IDs that have been submitted so we know which teams could be changing.
  my @team_ids_submitted = map($_->{id}, @{ $teams } );
  
  # Not entered arrayref of hashes - these hashes will eventually hold the information to be passed to update_or_create 
  my $teams_entered = [];
  
  # This will be a hash of hashes - the top level key will be the club ID, the second key will be the team name, i.e.,
  # $team_names_in_clubs->{$club_id}{$team_name} = $number_of_times.  Any more than one will mean an error
  my $team_names_in_clubs = {};
  
  # Get a resultset of team_season objects that haven't been submitted
  my $existing_teams = $season->search_related("team_seasons", {
    team => {
      -not_in => \@team_ids_submitted,
    }
  });
  
  # Now loop through the provided teams and check the values
  foreach my $team_hash ( @{ $teams } ) {
    # Grab the passed in values
    my $id              = $team_hash->{id};
    my $team_entered    = $team_hash->{entered} || undef;
    my $team            = $team_hash->{db} || undef; # DB object
    my $new_division    = $team_hash->{new_division} || undef;
    my $new_club        = $team_hash->{new_club} || undef;
    my $new_home_night  = $team_hash->{new_home_night} || undef;
    my $team_errored    = 0;
    my $team_hash->{update} = 0; # Signals an update to the team object is needed if any of the details in there (club) have changed
    
    # Check the team is valid
    if ( !defined( $team ) or ref( $team ) ne "TopTable::Model::DB::Team" ) {
      push(@{ $return_value->{error} }, {id => "seasons.set-teams.error.invalid-team"});
      $team_errored = 1;
    } else {
      # Now check they've entered
      
      if ( $team_entered ) {
        # Only do the other checks if the team is valid; this is so we can use the team name when logging the error message
        # Check which names to use in error messages
        my $club_name_to_use = ref( $new_club ) eq "TopTable::Model::DB::Club" ? $new_club->short_name : $team->club->short_name;
        
        # This is set if we've errored on team name or club; if we do, there's no point checking the team name against the chosen club
        my $club_or_name_error = 0;
        
        # Check the club is valid
        if ( defined( $new_club ) and ref( $new_club ) eq "TopTable::Model::DB::Club" ) {
          $team_hash->{update} = 1 if $new_club->id != $team->club->id;
        } else {
          # Invalid club
          push(@{ $return_value->{error} }, {
            id          => "seasons.set-teams.error.invalid-club",
            parameters  => [$club_name_to_use, $team->name],
          });
          
          $club_or_name_error = 1;
          $team_errored = 1;
        }
        
        # Check the team name against teams we've seen in this club already - only do this if we haven't errored on the team / club name already
        unless ( $club_or_name_error ) {
          if ( exists( $team_names_in_clubs->{$new_club->id}{$team->name} ) ) {
            # We already have a team for this club
            $team_names_in_clubs->{$new_club->id}{$team->name}++;
            $team_errored = 1;
          } else {
            # Haven't seen this team already, add it to the hash so we can check against it on subsequent iterations
            $team_names_in_clubs->{$new_club->id}{$team->name} = 1;
            
            # Now look for this club / team name combination in the resultset we looked up previously.
            my $db_team = $existing_teams->search_related("team", {
              "me.name" => $team->name,
              "club.id" => $new_club->id,
            }, {
              join => "club",
            })->single;
            
            if ( defined( $db_team ) ) {
              push(@{ $return_value->{error} }, {
                id          => "seasons.set-teams.error.name-exists-in-club",
                parameters  => [$team->name, $new_club->full_name, $season->name],
              });
              
              $team_errored = 1;
            }
          }
        }
        
        # Check the division is valid
        if ( defined( $new_division ) and ref( $new_division ) eq "TopTable::Model::DB::Division" ) {
          # Division is valid, but we still need to ensure it is in use this season
          if ( exists( $valid_divisions{$new_division->id} ) ) {
            # The division is valid, increase the 'current_teams' value
            $valid_divisions{$new_division->id}{current_teams}++;
          } else {
            push(@{ $return_value->{error} }, {
              id          => "seasons.set-teams.error.division-not-used",
              parameters  => [$club_name_to_use, $team->name, $new_division->name, $season->name],
            });
          }
        } else {
          # Invalid division
          push(@{ $return_value->{error} }, {
            id          => "seasons.set-teams.error.division-invalid",
            parameters  => [$club_name_to_use, $team->name],
          });
          $team_errored = 1;
        }
        
        # Check the home night is valid
        unless ( defined( $new_home_night ) and ref( $new_home_night ) eq "TopTable::Model::DB::LookupWeekday" ) {
          # Invalid home night
          push(@{ $return_value->{error} }, {
            id          => "seasons.set-teams.error.home-night-invalid",
            parameters  => [$club_name_to_use, $team->name],
          });
          $team_errored = 1;
        }
      } else {
        # Team hasn't entered, add the ID into the list we need to get delete from team_seasons for this season
        push( @teams_not_entering, $team->id );
      }
    }
  } ## End of loop through teams
  
  # Now we've looped through, make sure we haven't gone over the maximum number of teams for each division
  foreach my $division_id ( keys %valid_divisions ) {
    push(@{ $return_value->{error} }, {
      id          => "seasons.set-teams.error.too-many-teams-in-division",
      parameters  => [$valid_divisions{$division_id}{current_teams}, $valid_divisions{$division_id}{name}, $valid_divisions{$division_id}{grid_name}, $valid_divisions{$division_id}{maximum_teams}],
    }) if $valid_divisions{$division_id}{current_teams} > $valid_divisions{$division_id}{maximum_teams};
  }
  
  if ( scalar( @{ $return_value->{error} } ) ) {
    # We have errors; send the team details back so we can flash back the
    my %teams = map{
      # Set up the team ID as the key and the original array item as the value
      $_->{id} => $_;
    } @{ $teams };
    
    $return_value->{teams} = \%teams;
  } else {
    # Now we've done all our error checking, if there are no errors, we can go through and update / create the relevant records; this requires another loop through the teams
    my %seen_player_ids = ();
    foreach my $team_hash ( @{ $teams } ) {
      my $id              = $team_hash->{id};
      my $team            = $team_hash->{db};
      my $new_division    = $team_hash->{new_division};
      my $new_club        = $team_hash->{new_club};
      my $new_home_night  = $team_hash->{new_home_night};
      my $team_entered    = $team_hash->{entered};
      my $update          = $team_hash->{update};
      my $new_captain     = $team_hash->{new_captain};
      my $new_players     = $team_hash->{new_players};
      
      # Check the players has been passed as an arrayref; if not, make it one
      $new_players = [ $new_players ] if ref( $new_players ) ne "ARRAY";
      
      if ( $team_entered ) {
        if ( $update ) {
          # If we need to update the main team object, we'll do that; we may also need a new URL key
          
          $team_hash->{db}->update({
            club        => $new_club->id,
          });
        }
        
        # Now we need to look for a team season object to see whether we need to update or create
        my $team_season = $team_hash->{db}->search_related("team_seasons", {
          season => $season->id,
        })->single;
        
        # Now we validate the captain (this only produces a warning if invalid as they can be added later on). 
        # Check the captain (if entered) is valid
        if ( $new_captain eq "" ) {
          # Captain was blank, undef it so it goes in the DB as null
          undef( $new_captain );
        } else {
          # Captain was entered, validate them
          if ( defined( $new_captain ) and ref( $new_captain ) eq "TopTable::Model::DB::Person" ) {
            # Captain is valid; set the value to just the ID, so we can just use $captain regardless of whther it's null or not
            $new_captain = $new_captain->id;
          } else {
            # Invalid captain, warning; set to undef so we set it as null in the DB
            undef( $new_captain );
            push(@{ $return_value->{warning} }, {
              id          => "seasons.set-team.warning.captain-invalid",
              parameters  => [$new_club->short_name, $team->name],
            });
          }
        }
        
        if ( defined( $team_season ) ) {
          $team_season->update({
            season              => $season->id,
            name                => $team->name,
            club                => $new_club->id,
            division            => $new_division->id,
            captain             => $new_captain,
            home_night          => $new_home_night->weekday_number,
          });
        } else {
          $team_hash->{db}->create_related("team_seasons", {
            season              => $season->id,
            name                => $team->name,
            club                => $new_club->id,
            division            => $new_division->id,
            captain             => $new_captain,
            home_night          => $new_home_night->weekday_number,
          });
        }
        
        unless( my $club_season = $new_club->find_related("club_seasons", {season => $season->id}) ) {
          $club_season = $new_club->create_related("club_seasons", {
            season            => $season->id,
            full_name         => $new_club->full_name,
            short_name        => $new_club->short_name,
            abbreviated_name  => $new_club->abbreviated_name,
            venue             => $new_club->venue->id,
            secretary         => $new_club->secretary->id,
          });
        }
        
        # Validate and create the players' seasons - these are validated here because any invalid ones will just create warnings, as they're not essential at this point and can be entered later if needed
        # Check the players (if entered) are valid
        # Just keep count of the number of invalid players, as if there's more than one, the same message multiple times will be annoying
        my $invalid_players = 0;
        
        # We can't do a normal foreach, as we need to keep the index so we can splice if needed
        # Loop through in reverse so that when we splice, we don't end up missing rows
        # Because we're looping through in reverse, we will reverse it first so that we actually loop through in the right order
        @{ $new_players } = reverse @{ $new_players };
        foreach my $i ( reverse 0 .. $#{ $new_players } ) {
          my $player = $new_players->[$i];
          if ( defined( $player ) and ref( $player ) eq "TopTable::Model::DB::Person" ) {
            if ( exists( $seen_player_ids{$player->id} ) ) {
              # This player has already been set in a different team; splice and warn
              push(@{ $return_value->{warning} }, {
                id          => "seasons.set-team.warning.player-entered-more-than-once",
                parameters  => [$player->display_name, $new_club->short_name, $team->name, $player->first_name],
              });
              
              # If the player is invalid, splice them out
              splice(@{ $new_players }, $i, 1);
            } else {
              # Add them to the seen player IDs
              $seen_player_ids{$player->id}++;
              
              # Check if this player is active already
              my $active_membership = $player->search_related("person_seasons", {
                season => $season->id,
                team_membership_type => "active",
              }, {
                rows      => 1,
                prefetch  => {
                  team    => "club",
                }
              })->single;
              
              if ( defined( $active_membership ) ) {
                # This person already has an active membership for another team; now we need to check the reassignment setting
                if ( $reassign_active ) {
                  # Reassign and warn that we've reassigned; the membership needs deleting
                  $active_membership->delete;
                  push(@{ $return_value->{warning} }, {
                    id          => "seasons.set-teams.warning.player-already-active-reassigned",
                    parameters  => [$player->display_name, $new_club->short_name, $team->name, $season->name, $player->first_name]
                  });
                } else {
                  # Do not reassign, just warn and splice the value from the array.
                  splice(@{ $new_players }, $i, 1);
                  push(@{ $return_value->{warning} }, {
                    id          => "seasons.set-teams.warning.player-already-active-not-reassigned",
                    [$player->display_name, $new_club->short_name, $team->name, $season->name, $player->first_name],
                  });
                }
              }
            }
          } else {
            $invalid_players++;
            
            # If the player is invalid, splice them out
            splice(@{ $new_players }, $i, 1);
          }
        }
        
        if ( $invalid_players == 1 ) {
          push(@{ $return_value->{warning} }, {
            id          => "seasons.set-teams.warning.player-invalid",
            parameters  => [$new_club->short_name, $team->name],
          });
        } elsif ( $invalid_players > 1 ) {
          push(@{ $return_value->{warning} }, {
            id          => "seasons.set-teams.warning.players-invalid",
            parameters  => [$invalid_players, $new_club->short_name, $team->name],
          });
        }
        
        # Finally done our error checking; create the person seasons
        foreach my $player ( @{ $new_players } ) {
          $player->create_related("person_seasons", {
            season        => $season->id,
            team          => $team->id,
            first_name    => $player->first_name,
            surname       => $player->surname,
            display_name  => $player->display_name,
          });
        }
      }
    }
    
    # Perform a delete on any "non-entries"
    $season->delete_related("team_seasons", {
      team => {
        -in => \@teams_not_entering,
      }
    }) if scalar( @teams_not_entering );
  }
  
  # Return the current season in the hash so we don't have to look it up again
  $return_value->{current_season} = $season;
  return $return_value;
}

1;