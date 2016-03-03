package TopTable::Schema::ResultSet::FixturesGrid;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_grids

Return all fixtures grids sorted by name.

=cut

sub all_grids {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {
      -asc => "name",
    },
  });
}

=head2 page_records

Returns a paginated resultset of fixtures grids.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number       = $parameters->{page_number} || 1;
  my $results_per_page  = $parameters->{results_per_page} || 25;
  
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

=head2 get_grid_matches

A predefined search to get the matches for a grid in week number, then match number order.

=cut

sub get_grid_matches {
  my ( $self, $grid ) = @_;
  
  return $self->search( {
    id => $grid->id
  }, {
    prefetch => {
      fixtures_grid_weeks => "fixtures_grid_matches",
    },
    order_by => {
      -asc => [
        qw( fixtures_grid_weeks.week fixtures_grid_matches.match_number )
      ]
    },
  });
}

=head2 incomplete_matches

A predefined search to get the matches for a grid in week number, then match number order.

=cut

sub incomplete_matches {
  my ( $self, $grid ) = @_;
  
  return $self->search({
    -or => [{
      "fixtures_grid_matches.home_team" => undef,
      "fixtures_grid_matches.away_team" => undef,
    }],
    -and => {
      id => $grid->id
    },
  }, {
    join => {
      fixtures_grid_weeks => "fixtures_grid_matches",
    },
    order_by => {
      -asc => [
        qw( fixtures_grid_weeks.week fixtures_grid_matches.match_number )
      ]
    },
  });
}

=head2 incomplete_grid_positions

Returns the count of teams that have incomplete grid positions for a given grid in a given season.

=cut

sub incomplete_grid_positions {
  my ( $self, $grid, $season ) = @_;
  
  return $self->search({
    "me.id"                       => $grid->id,
    "team_seasons.grid_position"  => undef,
  }, {
    join => {
      division_seasons => {
        season => "team_seasons",
      },
    },
  })->count;
}

=head2 find_with_weeks

Wraps find() with a prefetch on season weeks.

=cut

sub find_with_weeks {
  my ( $self, $grid_id ) = @_;
  
  return $self->find({
    id  => $grid_id,
  }, {
    prefetch => "fixtures_grid_weeks",
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

Generate a unique key from the given template name.

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

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a fixtures grid.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my $return_value = {error => []};
  my ( $grid_name_check );
  
  my $grid              = $parameters->{grid};
  my $name              = $parameters->{name};
  my $maximum_teams     = $parameters->{maximum_teams};
  my $fixtures_repeated = $parameters->{fixtures_repeated};
  
  if ($action ne "create" and $action ne "edit") {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    return $return_value;
  } elsif ($action eq "edit") {
    unless ( defined( $grid ) and ref( $grid ) eq "TopTable::Model::DB::FixturesGrid" ) {
      # Editing a fixtures grid that doesn't exist.
      push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.grid-invalid"});
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    if ( $action eq "edit" ) {
      $grid_name_check = $self->find({}, {
        where => {
          name  => $name ,
          id    => {
            "!=" => $grid->id
          }
        }
      });
    } else {
      $grid_name_check = $self->find({name => $name});
    }
    
    push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.grid-exists"}) if defined( $grid_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.name-blank"});
  }
  
  # Check the maximum teams is a valid numeric value (2-98, even only).
  push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.maximum-teams-invalid"}) if !$maximum_teams or $maximum_teams !~ m/^\d{1,2}$/ or $maximum_teams < 2 or $maximum_teams > 98 or $maximum_teams % 2 == 1;
  
  # Check the number of weeks is valid; this needs to be a valid numeric figure and
  # less than 52, as a season will definitely not last a year.
  push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.repeat-fixtures-invalid"}) if !$fixtures_repeated or $fixtures_repeated !~ m/^\d$/ or $fixtures_repeated < 1;
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Generate a URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $grid->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Now work out the number of fixtures weeks we'll have.  This is the maximum number of teams per division
    # (minus 1) multiplied by the number of times a fixture is repeated; for example if teams play each other
    # team three times and there are a maximum of eight teams per division, number of weeks we will have is:
    # (8 - 1) * 3 = 21.
    my $number_of_weeks   = ( $maximum_teams - 1 ) * $fixtures_repeated;
    
    # Number of matches per divsion per week is the maximum teams per division divided by 2.
    my $matches_per_week  = $maximum_teams / 2;
    
    # Array used to populate multiple rows of data; each row will be a hashref containing the data we wish to insert.
    # This array will be passed as a reference, but keeping it a normal array right now makes the loop more readable.
    my @week_data = ();
    
    # Loop through all of our weeks building a hashref 
    for my $i ( 1 .. $number_of_weeks ) {
      my @matches   = ();
      # Now loop through the week's matches
      for my $x ( 1 .. $matches_per_week ) {
        push( @matches, {match_number => $x,} );
      }
      
      # The hashref contains the grid ID and week number; the home and
      # away team numbers are populated later.  The grid ID is populated in the create
      push( @week_data, {
        week                  => $i,
        fixtures_grid_matches => \@matches,
      });
    }
    
    if ( $action eq "create" ) {
      # Create the grid
      $grid = $self->create({
        name                => $name,
        url_key             => $url_key,
        maximum_teams       => $maximum_teams,
        fixtures_repeated   => $fixtures_repeated,
        fixtures_grid_weeks => \@week_data,
      });
    } else {
      # Delete the grid weeks and matches
      my @weeks   = $grid->fixtures_grid_weeks->all;
      my @matches = map $_->fixtures_grid_matches->all, @weeks;
      $_->delete foreach ( @matches );
      $_->delete foreach ( @weeks );
      
      # Update the existing grid
      $grid->update({
        name                => $name,
        url_key             => $url_key,
        maximum_teams       => $maximum_teams,
        fixtures_repeated   => $fixtures_repeated,
      });
      
      foreach my $week ( @week_data ) {
        $grid->create_related("fixtures_grid_weeks", $week);
      }
    }
    
    $return_value->{grid} = $grid;
  }
  
  return $return_value;
}

=head2 set_grid_matches

Performs error checking and updates the grid matches for each week.

=cut

sub set_grid_matches {
  my ( $self, $parameters ) = @_;
  my $grid            = $parameters->{grid};
  my $repeat_fixtures = $parameters->{repeat_fixtures};
  my %match_teams     = %{ $parameters->{match_teams} };
  my $return_value    = {error => []};
  
  # These are set from the grid retrieved and most are only used if we repeat fixtures, but the maximum number of teams will also be checked to ensure no value goes higher than that
  my ( $maximum_teams_per_division, $fixtures_repeated_count, $first_pass_fixtures_weeks );
  
  # Do a bit of fatal error checking first (invalid grid / season / season not current / matches already set)
  if ( defined( $grid ) and ref( $grid ) eq "TopTable::Model::DB::FixturesGrid" ) {
    # Success, we have a valid grid
    $return_value->{grid} = $grid;
    
    # Get the grid settings
    $maximum_teams_per_division = $grid->maximum_teams;
    $fixtures_repeated_count    = $grid->fixtures_repeated;
    
    # The number of weeks required to complete a set of fixtures (i.e., everybody playing everybody) will always be the number of teams minus 1 (as everybody plays everybody but themselves)
    $first_pass_fixtures_weeks  = $maximum_teams_per_division - 1;
  } else {
    push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.grid-invalid"});
    return $return_value;
  }
  
  my $grid_matches  = $self->get_grid_matches( $grid );
  $grid             = $grid_matches->first;
  my $weeks         = $grid->fixtures_grid_weeks;
  
  # This array will hold the match number / week number information from the database as well as the submitted form information (home / away teams for each match) 
  my @fixtures_grid_weeks = ();
  # Loop through all weeks
  while ( my $week = $weeks->next ) {
    # Push this week on to the array, with an empty arrayref for matches
    push(@fixtures_grid_weeks, {week => $week->week, matches => []});
    
    my $matches = $week->fixtures_grid_matches;
    while ( my $match = $matches->next ) {
      # Create the arrayref of matches within this week
      push ( @ { $fixtures_grid_weeks[$#fixtures_grid_weeks]{matches} }, {
        match_number  => $match->match_number,
        home_team     => $match_teams{$week->week}{$match->match_number}{home},
        away_team     => $match_teams{$week->week}{$match->match_number}{away},
      });
    }
    
    # Break out of the loop if we are repeating and we have reached the end of the first pass of fixtures
    last if $repeat_fixtures and $week->week == $first_pass_fixtures_weeks;
  }
  
  # These will hold the details of any selects that are blank / invalid in a text form so that they can be 'join'ed in a final error message
  my (@blank_teams, @invalid_teams);
  
  # This hash will hold a hashref of weeks and the keys to each week will be a team number; keys will be added as teams are used so that we can check
  # if a key exists when validating the teams selected
  my %used_teams = ();
  
  # Now loop through the data structure we've created and make sure everything is valid.
  foreach my $week ( @fixtures_grid_weeks ) {
    foreach my $match ( @{ $week->{matches} } ) {
      if ( !$match->{home_team} ) {
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.matches.home-team-blank",
          parameters  => [$week->{week}, $match->{match_number}],
        });
      } elsif ( $match->{home_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.matches.home-number-invalid",
          parameters  => [$week->{week}, $match->{match_number}, $maximum_teams_per_division],
        });
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref( $used_teams{$week->{week}}{$match->{home_team}} ) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push( @{ $used_teams{$week->{week}}{$match->{home_team}} } , "match " . $match->{match_number} . " (home)");
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{home_team}} = ["match " . $match->{match_number} . " (home)"];
        }
      }
      
      if ( !$match->{away_team} ) {
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.matches.away-team-blank",
          parameters  => [$week->{week}, $match->{match_number}],
        });
      } elsif ( $match->{away_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.matches.away-number-invalid",
          parameters  => [$week->{week}, $match->{match_number}, $maximum_teams_per_division],
        });
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref( $used_teams{$week->{week}}{$match->{away_team}} ) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push( @{ $used_teams{$week->{week}}{$match->{away_team}} } , "match " . $match->{match_number} . " (away)");
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{away_team}} = ["match " . $match->{match_number} . " (away)"];
        }
      }
    }
  }
  
  # Now loop through our %used_teams hash and make sure we haven't used any team more than once.
  foreach my $week ( keys(%used_teams) ) {
    foreach my $team ( keys( %{ $used_teams{$week} } ) ) {
      push(@{ $return_value->{error} }, {
        id          => "fixtures-grids.form.matches.team-overused",
        parameters  => [$week, $team, join(", ", @{ $used_teams{$week}{$team} } )],
      }) if scalar(@{ $used_teams{$week}{$team} }) > 1;
    }
  }
  
  # If we've errored, we need to return all the values so - for example - a web application can set them back into the form - we didn't do this originally, as we didn't know if there was an error or not.
  if ( scalar( @{ $return_value->{error} } ) ) {
    $return_value->{weeks}            = \@fixtures_grid_weeks;
    $return_value->{repeat_fixtures}  = $repeat_fixtures;
  } else {
    # Finally we need to loop through again updating the home / away teams for each match
    # If we're repeating, we need to do multiple loops through
    my $loop_end;
    if ( $repeat_fixtures ) {
      # Loop through as many times as fixtures are repeated
      $loop_end = $fixtures_repeated_count;
    } else {
      # Loop through just once (this saves an if statement deciding whether to create a loop within a loop or not, which would duplicate code)
      $loop_end = 1;
    }
    
    # Loop through as many times as we need to repeat the fixtures
    # The week number is counted manually, as we only have the first pass of fixtures in the array, so we need to keep our own count
    my $week_number;
    foreach my $i ( 1 .. $loop_end ) {
      # Now loop through the array we build up
      foreach my $week ( @fixtures_grid_weeks ) {
        # Increment the week number
        $week_number++;
        
        # ... and within that, loop through the matches in that array
        foreach my $match ( @{ $week->{matches} } ) {
          # The home / away teams will be swapped if the first loop counter ($1) is an EVEN number.
          my ( $home_team, $away_team );
          
          if ( $i % 2 ) {
            # Odd number (no remainder), don't swap home and away teams
            $home_team = $match->{home_team};
            $away_team = $match->{away_team};
          } else {
            # Even number (remainder 1), swap home and away teams
            $home_team = $match->{away_team};
            $away_team = $match->{home_team};
          }
          
          $weeks->find({
            grid          => $grid->id,
            week          => $week_number,
          })->fixtures_grid_matches->find({
            match_number  => $match->{match_number},
          })->update({
            home_team => $home_team,
            away_team => $away_team,
          });
        }
      }
    }
  }
  
  return $return_value;
}

=head2 set_grid_teams

Set the teams to their grid numbers for the current season.

=cut

sub set_grid_teams {
  my ( $self, $parameters ) = @_;
  my $grid      = $parameters->{grid};
  my $season    = $parameters->{season};
  my $divisions = $parameters->{divisions};
  
  my $return_value = {};
  
  # Do a bit of fatal error checking first (invalid grid / season / season not current / matches already set)
  if ( defined( $grid ) ) {
    if ( ref( $grid ) eq "TopTable::Model::DB::FixturesGrid" ) {
      # Success, we have a valid grid
      $return_value->{grid} = $grid;
    } else {
      $return_value->{error} .= "Invalid fixtures grid specified.\n";
    }
  } else {
    $return_value->{error} .= "The fixtures grid has not been specified.\n";
  }
  
  if ( !defined( $season ) or ref( $season ) ne "TopTable::Model::DB::Season" ) {
    $return_value->{error} .= "The season specified is invalid\n";
  } elsif ( $season->complete ) {
    $return_value->{error} .= "The season specified (" . $season->name . ") is not current; team positions can only be set or changed on the current season.\n";
  }
  
  # At this point, any errors will have been fatal
  return $return_value if $return_value->{error};
    
  # If we have a grid and a season, we need to see if matches have already been set for that grid
  my $matches_set_already = $grid->search_related("team_matches", {
    season => $season->id,
  })->count;
  
  if ( $matches_set_already > 0 ) {
    $return_value->{error} .= "This season already has matches set from this grid.\n";
    return $return_value;
  }
  
  # Get the list of teams who've entered in divisions assigned to the grid
  my @division_seasons = $season->search_related("division_seasons", {
    fixtures_grid  => $grid->id,
    "team_seasons.season" => $season->id,
  }, {
    prefetch  => {
      division => {
        team_seasons => {
          team => "club",
        },
      },
    },
    order_by  => {
      -asc => [ qw( division.rank team_seasons.grid_position ) ]
    },
  });
  
  # Go through each division season object, grabbing its division
  my @divisions; 
  push( @divisions, $_->division ) foreach ( @division_seasons );
  
  # This hash will hold divisions and their teams and their positions as well as
  # some other name data so that we can use it in error messages.
  my %submitted_data = ();
  
  # This will hold the values we've seen for each division so we can make sure we've not seen any
  # position more than once for any divisioon
  my %used_values = ();
  
  # The error message to build up
  my $error;
  
  foreach my $division ( @divisions ) {
    # Store the name for purposes of error messages
    $submitted_data{ $division->url_key } = {
      id      => $division->id,
      rank    => $division->rank,
      name    => $division->name,
      object  => $division,
      teams   => {},
    };
    
    # Get the submitted value for this division
    my @team_ids = split( ",", $divisions->{"division-positions-" . $division->id} );
    
    # Loop through the team IDs; make sure each team belongs to this division and is only itemised once and that no teams are missing.
    my $position = 1;
    foreach my $id ( @team_ids ) {
      if ( $id ) {
        # If we have an ID, make sure it's in the resultset for this division
        my $team_season = $division->team_seasons->find({
          team    => $id,
          season  => $season->id,
        });
        
        if ( defined($team_season) ) {
          $submitted_data{ $division->url_key }{teams}{$team_season->team->id} = {
            name      => $team_season->team->club->short_name . " " . $team_season->team->name,
            position  => $position,
          };
          
          if ( defined( $used_values{ $division->name }{$position} ) ) {
            # Already exists, push it on to the arrayref
            push( @{ $used_values{ $division->name }{$position} } , $team_season->team->club->short_name . " " . $team_season->team->name );
          } else {
            # Doesn't exist, create a new arrayref
            $used_values{ $division->name }{$position} = [$team_season->team->club->short_name . " " . $team_season->team->name];
          }
        } else {
          $return_value->{error} .= "$id is not a valid team identifier or is in the wrong division.\n";
        }
      } else {
        # No ID, push undefined values for the bye
        $submitted_data{ $division->url_key }{teams}{0} = {
          id        => 0,
          name      => "[Bye]",
          position  => $position,
        };
      }
      $position++;
    }
    
    # After we loop through the IDs, make sure we have each team in there
    my $team_seasons = $division->team_seasons;
    while ( my $team_season = $team_seasons->next ) {
      $return_value->{error} .= sprintf("%s %s has been entered into %s but does has not been listed in a position.\n", $team_season->team->club->short_name, $team_season->team->name, $submitted_data{ $division->url_key }{name})  if !exists( $submitted_data{ $division->url_key }{teams}{ $team_season->team->id } );
    }
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $division ( keys(%used_values) ) {
    foreach my $position ( keys( %{ $used_values{$division} } ) ) {
      $return_value->{error} .= "In $division, $position is used more than once: (" . join(", ", @{ $used_values{$division}{$position} } ) . ").  Please ensure each position is used only once in a given division.\n" if scalar(@{ $used_values{$division}{$position} }) > 1;
    }
  }
  
  # Check for errors
  if ( $return_value->{error} ) {
    $return_value->{submitted_data} = \%submitted_data;
  } else {
    # Finally we need to loop through again updating the home / away teams for each match
    foreach my $division_key ( keys %submitted_data ) {
      # Get the division DB object, then the team seasons object
      my $division      = $submitted_data{ $division_key }{object};
      my $team_seasons  = $division->team_seasons;
      foreach my $team_id ( keys %{ $submitted_data{ $division_key }{teams} } ) {
        $team_seasons->find({
          team    => $team_id,
          season  => $season->id
        })->update({
          grid_position => $submitted_data{ $division_key }{teams}{ $team_id }{position},
        }) if $team_id;
      }
    }
  }
  
  return $return_value;
}

1;