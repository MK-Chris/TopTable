package TopTable::Schema::ResultSet::TeamMatch;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper;

=head2 season_matches

A predefined search to find and return the matches created with a season (optionally for a specific team).

=cut

sub season_matches {
  my ( $self, $season, $parameters ) = @_;
  my ( $where, $team, $grid );
  
  if ( defined($parameters->{team}) ) {
    $team = $parameters->{team};
  } elsif ( defined($parameters->{grid}) ) {
    $grid = $parameters->{grid};
  }
  
  if ( $team ) {
    $where = [{
      "scheduled_week.season" => $season->id,
      home_team               => $team->id,
    }, {
      "scheduled_week.season" => $season->id,
      away_team               => $team->id,
    }];
  } elsif ( $grid ) {
    $where = {
      "scheduled_week.season" => $season->id,
      fixtures_grid           => $grid->id,
    };
  } else {
    $where = {
      "scheduled_week.season" => $season->id
    };
  }
  
  return $self->search( $where, { join  => "scheduled_week",});
}

=head2 team_home_matches

Finds all matches within a season where the given team is at home.

=cut

sub team_home_matches {
  my ( $self, $season, $team ) = @_;
  
  return $self->search({
    home_team               => $team->id,
    "scheduled_week.season" => $season->id,
  }, {
    prefetch  => "scheduled_week",
  });
}

=head2 division_averages_list

A predefined search to find and return the players within a division in the order in which they should appear in the full league averages.

=cut

sub division_averages_list {
  my ( $self, $season, $division, $minimum_matches_played ) = @_;
  
  $minimum_matches_played = 0 if !$minimum_matches_played;
  
  return $self->search({
    "person_seasons.matches_played" => {
      ">=" => $minimum_matches_played
    },
    "person_seasons.division"       => $division,
    "person_seasons.season"         => $season,
  }, {
    join      => "person_seasons",
    order_by  => {
      -desc => [
        "person_seasons.average_game_wins",
        "person_seasons.matches_played",
        "person_seasons.games_won",
        "person_seasons.games_played",
        "person_seasons.average_point_wins",
        "person_seasons.points_played",
        "person_seasons.points_won",
      ]
    },
  });
}

=head2 match_counts_by_month

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_month {
  my ( $self, $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where      = {
      "season.id" => $season->id
    };
    $attributes = {
      select      => [
        {
          count   => "me.scheduled_date"
        },
        "scheduled_date",
      ],
      as          => [ qw(number_of_matches scheduled_date) ],
      join        => {
        scheduled_week  => "season",
      },
      group_by    => {
        month     => "scheduled_date"
      },
      order_by    => {
        -asc            => "scheduled_date"
      },
    };
  } else {
    $where      = {};
    $attributes = {
      select      => [
        {
          count   => "me.scheduled_date"
        },
        "scheduled_date",
      ],
      as          => [ qw(number_of_matches scheduled_date) ],
      join        => {
        scheduled_week  => "season",
      },
      group_by    => {
        month           => "scheduled_date"
      },
      order_by    => [
        {
          -desc  => [ qw( season.complete start_date end_date ) ]
        }, {
          -asc   => "scheduled_date"
        }
      ],
    };
  }
  
  return $self->search( $where, $attributes );
}

=head2 match_counts_by_week

Returns, in date order, all of the weeks that have matches within a season and the number of matches.  

=cut

sub match_counts_by_week {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "season.id" => $season->id,
  }, {
    select      => [{
      count => "me.scheduled_date"
    },
    "scheduled_week.id",
    "scheduled_week.week_beginning_date"],
    as          => [
      qw(number_of_matches scheduled_week_id scheduled_week_date)
    ],
    join        => {
      scheduled_week  => "season",
    },
    prefetch    => "scheduled_week",
    group_by    => "scheduled_week.id",
    order_by    => {
      -asc      => "scheduled_week.id"
    },
  });
}

=head2 match_counts_by_day

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_day {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "season.id" => $season->id,
  }, {
    select      => [
      {
        count          => "me.scheduled_date"
      },
      "scheduled_date",
    ],
    as          => [ qw(number_of_matches scheduled_date) ],
    join        => {
      scheduled_week  => "season",
    },
    group_by    => "scheduled_date",
    order_by    => {
      -asc      => "scheduled_date"
    },
  });
}

=head2 match_counts_by_venue

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_venue {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "season.id" => $season->id,
  }, {
    select    => [
      {
        count => "me.scheduled_date"
      },
      "venue"
    ],
    as        => [ qw(number_of_matches venue)],
    prefetch  => "venue",
    join      => {
      scheduled_week  => "season",
    },
    group_by  => "venue.id",
    order_by  => {
      -asc => "venue.name"
    },
  });
}

=head2 matches_for_team

A search for matches involving the specified team in the specified season.

=cut

sub matches_for_team {
  my ( $self, $parameters ) = @_;
  my $team    = $parameters->{team};
  my $season  = $parameters->{season};
  my ( $page_number, $results_per_page );
  
  # These attributes are constant
  my %attributes = (
    prefetch  => [{
      home_team  => "club"
    }, {
      away_team => "club"
    },
    "season",
    "venue"],
    order_by  => {
      -asc => "scheduled_date"
    }
  );
  
  # If we have a page number and a number of results per page, paginate
  if ( exists( $parameters->{page_number} ) and exists( $parameters->{results_per_page} ) ) {
    $page_number      = delete $parameters->{page_number};
    $results_per_page = delete $parameters->{results_per_page};
    
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attributes{page} = $page_number;
    $attributes{rows} = $results_per_page;
  }
  
  return $self->search([{
    season    => $season->id,
    home_team => $team->id,
  }, {
    season    => $season->id,
    away_team => $team->id,
  }], \%attributes);
}

=head2 matches_in_division

A search for matches involving the specified division in the specified season.

=cut

sub matches_in_division {
  my ( $self, $parameters ) = @_;
  my $division          = $parameters->{division};
  my $season            = $parameters->{season};
  my $page_number       = $parameters->{page_number};
  my $results_per_page  = $parameters->{results_per_page};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({
    season    => $season->id,
    division  => $division->id,
  }, {
    page      => $page_number,
    rows      => $results_per_page,
    prefetch  => [{
      home_team  => "club"
    }, {
      away_team => "club"
    },
    "venue",],
    order_by  => {
      -asc => [ qw( scheduled_date club.short_name home_team.name ) ]
    }
  });
}

=head2 matches_in_date_range

A search for matches in the specified date range in the given season.

=cut

sub matches_in_date_range {
  my ( $self, $parameters ) = @_;
  my $start_date        = $parameters->{start_date};
  my $end_date          = $parameters->{end_date};
  my $season            = $parameters->{season};
  my $page_number       = $parameters->{page_number};
  my $results_per_page  = $parameters->{results_per_page};
  
  return $self->search({
    "scheduled_week.season"   => $season->id,
    "team_seasons.season"     => $season->id,
    "division_seasons.season" => $season->id,
    scheduled_date => {
      -between => [$start_date->ymd, $end_date->ymd]
    },
  }, {
    page      => $page_number,
    rows      => $results_per_page,
    prefetch  => [{
      home_team => ["club", {
        "team_seasons" => {
          "division" => "division_seasons"
        }}]
      }, {
        away_team => "club"
      }, {
        scheduled_week => "season"
      },
      "venue"
    ],
    order_by  =>  {
      -asc => [ qw( division.rank scheduled_date )]
    }
  });
}

=head2 matches_in_week

A search for matches in the specified fixtures week.

=cut

sub matches_in_week {
  my ( $self, $parameters ) = @_;
  my $season            = $parameters->{season};
  my $week              = $parameters->{week};
  my $page_number       = $parameters->{page_number};
  my $results_per_page  = $parameters->{results_per_page};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  
  return $self->search({
    "scheduled_week.season"   => $season->id,
    "team_seasons.season"     => $season->id,
    "division_seasons.season" => $season->id,
    "scheduled_week.id"       => $week->id,
  }, {
    page      => $page_number,
    rows      => $results_per_page,
    prefetch  => [{
      home_team  => ["club", {
        "team_seasons" => {
          "division" => "division_seasons"
        }}]
      }, {
        away_team => "club"
      }, {
        scheduled_week => "season"
      },
      "venue"
    ],
    order_by  => {
      -asc => [ qw(division.rank scheduled_date club.short_name home_team.name) ]
    }
  });
}

=head2 matches_on_date

A search for matches on a specified date.

=cut

sub matches_on_date {
  my ( $self, $parameters ) = @_;
  my $season            = $parameters->{season};
  my $date              = $parameters->{date};
  my $page_number       = $parameters->{page_number};
  my $results_per_page  = $parameters->{results_per_page};
  my $attributes;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if defined($results_per_page) and $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if defined($page_number) and $page_number !~ m/^\d+$/;
  
  if ( defined( $results_per_page ) and $page_number ) {
    $attributes = {
      page      => $page_number,
      rows      => $results_per_page,
      prefetch  => [
        {
          home_team  => [
            "club", {
              "team_seasons" => {
                "division" => "division_seasons"
              },
            }
          ]
        }, {
          away_team => "club"
        }, {
          scheduled_week => "season"
        },
        "venue"
      ],
      order_by  => {
        -asc => "division.rank"
      }
    };
  } else {
    $attributes = {
      prefetch  => [
        {
          home_team  => [
            "club", {
              "team_seasons" => {
                "division" => "division_seasons"
              },
            }
          ]
        }, {
          away_team => "club"
        }, {
          scheduled_week => "season"
        },
        "venue"
      ],
      order_by  => {
        -asc => "division.rank"
      }
    };
  }
  
  return $self->search({
    "scheduled_week.season"   => $season->id,
    "team_seasons.season"     => $season->id,
    "division_seasons.season" => $season->id,
    scheduled_date            => $date->ymd,
    
  }, $attributes);
}

=head2 matches_at_venue

A search for matches involving the specified team in the specified season.

=cut

sub matches_at_venue {
  my ( $self, $parameters ) = @_;
  my $venue             = $parameters->{venue};
  my $season            = $parameters->{season};
  my $page_number       = $parameters->{page_number};
  my $results_per_page  = $parameters->{results_per_page};
  my ( $where );
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  if ( $season ) {
    $where = {
      "scheduled_week.season"   => $season->id,
      "team_seasons.season"     => $season->id,
      "division_seasons.season" => $season->id,
      "venue.id"                => $venue->id,
    };
  } else {
    $where = {
      venue => $venue->id,
    };
  }
  
  return $self->search($where, {
    page      => $page_number,
    rows      => $results_per_page,
    prefetch  => [
      {
        home_team  => [
          "club", {
            team_seasons => {
              division => "division_seasons"
            },
          }
        ]
      }, {
        away_team => "club"
      }, {
        scheduled_week => "season"
      },
      "venue"
    ],
    order_by  => {
      -asc => [
        qw (scheduled_date division.rank)
      ]
    }
  });
}

=head2 get_match_by_ids

Returns a match in the same way that ->find() would, but prefetches related players, games and legs.

=cut

sub get_match_by_ids {
  my ( $self, $home_team_id, $away_team_id, $scheduled_date ) = @_;
  
  return $self->find({
    home_team       => $home_team_id,
    away_team       => $away_team_id,
    scheduled_date  => $scheduled_date->ymd,
  }, {
    prefetch  => [
      {
        team_match_games => [
          "home_player",
          "away_player",
          "umpire", {
            individual_match_template => [
              qw( game_type serve_type )
            ],
            team_match_legs    => [
              qw( first_server next_point_server )
            ],
          }, {
            home_doubles_pair => [ qw(person1 person2) ],
          }, {
            away_doubles_pair => [ qw(person1 person2) ],
          }
        ],
      }, {
        team_match_players => [
          "loan_team",
          "location", {
            player => "gender",
          }
        ]
      },
      "division", {
        home_team => "club"
      }, {
        away_team => "club"
      },
      "venue",
      "season", {
        team_match_template => "winner_type",
      },
    ],
    order_by  => {
      -asc  => [ qw(team_match_games.actual_game_number team_match_legs.leg_number team_match_players.player_number) ],
    }
  });
}

=head2 get_match_by_url_keys

Returns a match in the same way that ->find() would, but prefetches related players, games and legs.

=cut

sub get_match_by_url_keys {
  my ( $self, $home_club_url_key, $home_team_url_key, $away_club_url_key, $away_team_url_key, $scheduled_date ) = @_;
  
  return $self->find({
    "club.url_key"      => $home_club_url_key,
    "home_team.url_key" => $home_team_url_key,
    "club_2.url_key"    => $away_club_url_key,
    "away_team.url_key" => $away_team_url_key,
    scheduled_date      => $scheduled_date->ymd,
  }, {
    prefetch  => [{
      team_match_games => [
        "home_player",
        "away_player",
        "umpire", {
          individual_match_template => [
            qw( game_type serve_type )
          ],
          team_match_legs    => [
            qw( first_server next_point_server )
          ]}, {
            home_doubles_pair => [ qw(person1 person2) ],
          }, {
            away_doubles_pair => [ qw(person1 person2) ],
          }
        ],
      }, {
        team_match_players => [
          "loan_team",
          "location", {
            "player" => "gender",
          }
        ]
      },
      "division", {
        home_team => "club"
      }, {
        away_team => "club"
      },
      "venue",
      "season", {
        team_match_template => "winner_type",
      },
    ],
    order_by  => {
      -asc  => [ qw(team_match_games.actual_game_number team_match_legs.leg_number team_match_players.player_number) ],
    }
  });
}

=head2 matches_involving_player_in_season

Retrieve all of the matches for a given player in the given season.

=cut

sub matches_involving_player_in_season {
  my ( $self, $season, $person ) = @_;
  
  return $self->search({
    "season.id" => $season->id,
    "player.id" => $person->id,
  }, {
    prefetch  => {
      team_match_players => "player",
    },
    join      => {
      scheduled_week  => "season",
    },
  });
}

=head2 check_and_populate

Checks the given parameters and if everything is okay, populates the league matches for the current season for any division using the given grid.

=cut

sub check_and_populate {
  my ( $self, $parameters ) = @_;
  
  # Grab the passed parameters
  my $grid          = $parameters->{grid};
  my $season        = $parameters->{season};
  my $season_weeks  = $parameters->{season_weeks};
  
  # Return value from the function
  my $return_value = {error => []};
  my ( $team_match_template, @team_match_games_templates );
  
  # Check the fixtures grid ID is valid
  if ( defined( $grid ) and ref( $grid ) eq "TopTable::Model::DB::FixturesGrid" ) {
    $return_value->{grid} = $grid;
  } else {
    push(@{ $return_value->{error} }, {id => "fixtures-grids.form.error.grid-invalid"});
    return $return_value;
  }
  
  # Check the season is valid and not complete
  if ( !( defined( $season ) ) or ref( $season ) ne "TopTable::Model::DB::Season" ) {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.season-invalid"});
    return $return_value;
  } elsif ( $season->complete ) {
    push(@{ $return_value->{error} }, {id => "fixtures-grids.form.create-fixtures.error.season-complete"});
  }
  
  # Check the season hasn't had matches created already.
  push(@{ $return_value->{error} }, {
    id          => "fixtures-grids.form.create-fixtures.error.matches-exist",
    parameters  => [$season->name],
  }) if $self->season_matches($season, {grid => $grid })->count > 0;
  
  # Check if we have some incomplete matches set up for this grid
  my $incomplete_grid_matches;
  my $grid_weeks = $grid->search_related("fixtures_grid_weeks", undef, {
    prefetch => "fixtures_grid_matches",
  });
  
  # This will store home / away team information for each match of each week; team numbers are 1-[maximum_teams_per_division].
  # Format:
  # $grid_matches{$week_id}[$array_index]{home_team} = $home_team_number;
  # $grid_matches{$week_id}[$array_index]{away_team} = $away_team_number;
  my %grid_matches;
  
  # Loop through all weeks
  WEEKS: while ( my $week = $grid_weeks->next ) {
    # Now loop through matches within those weeks
    my $matches = $week->fixtures_grid_matches;
    while ( my $match = $matches->next ) {
      # Check that the matches have been completely filled out
      if ( $match->home_team and $match->away_team ) {
        # Store this match in the %grid_matches hash - first check if it's an arrayref
        if ( ref($grid_matches{$week->week}) eq "ARRAY" ) {
          # It's already an arrayref, push the values on to it
          push( @{$grid_matches{$week->week}}, {home_team => $match->home_team, away_team => $match->away_team} );
        } else {
          # It's not an arrayref, so these must the first values; create an arrayref with these values
          $grid_matches{$week->week} = [{home_team => $match->home_team, away_team => $match->away_team}];
        }
      } else {
        $incomplete_grid_matches++;
        last WEEKS;
      }
    }
  }
  
  push(@{ $return_value->{error} }, {id => "fixtures-grids.form.create-fixtures.error.matches-incomplete"}) if $incomplete_grid_matches;
  
  # Check if we have incomplete grid positions for any teams involved in divisions that use this fixtures grid for the current season
  my $team_grid_positions = $grid->search_related("division_seasons", {
    "team_seasons.season" => $season->id,
    "me.season"           => $season->id,
  }, {
    prefetch => {
      league_match_template => {
        template_match_team_games => "individual_match_template",
      },
      division => {
        team_seasons => ["home_night", {
          team => [{
              club => "venue"
            },
          ]
        }]
      },
    },
    order_by => {
      -asc => [ qw( division.rank template_match_team_games.match_game_number ) ],
    },
  });
  
  # Now we've done our fatal error checks, we need to loop through the values we've been given and check them for errors
  # We store the last season week's date that we processed, so we can ensure this one does not occur before the last one. 
  my $last_season_week;
    
  # This will hold the positions for each division like so:
  # $division_positions{$division_id}{$position} = $team (value is a team object)
  my ( %division_positions, $incomplete_team_grid_positions, %division_templates );
  
  # Loop through our divisions and within them the team season objects, saving away the grid position / team for each
  while ( my $division_season = $team_grid_positions->next ) {
    my $team_seasons = $division_season->division->team_seasons;
    
    # Loop through and store each team's grid position
    while( my $team_season = $team_seasons->next ) {
      if ( defined($team_season->grid_position) ) {
        # The grid position is set; use it as a hashref key so we can easily access it when creating matches
        $division_positions{ $division_season->division->id }{$team_season->grid_position} = $team_season;
      } else {
        $incomplete_team_grid_positions++;
      }
    }
    
    # Store this division's template information in a hashref.  This is better than a resultset that we need to keep resetting,
    # as we'd be doing this a lot and it would slow us down.
    $division_templates{ $division_season->division->id } = {
      id                        => $division_season->league_match_template->id,
      singles_players_per_team  => $division_season->league_match_template->singles_players_per_team,
      games                     => [],
    };
    
    # Loop through and add the games rules
    my $template_games = $division_season->league_match_template->template_match_team_games;
    while ( my $game = $template_games->next ) {
      push( @{ $division_templates{ $division_season->division->id }{games} }, {
        singles_home_player_number  => $game->singles_home_player_number,
        singles_away_player_number  => $game->singles_away_player_number,
        doubles_game                => $game->doubles_game,
        match_template              => $game->individual_match_template->id,
        match_game_number           => $game->match_game_number,
        legs_per_game               => $game->individual_match_template->legs_per_game,
      });
    }
  }
  
  # Check if we have any incomplete grid positions
  push(@{ $return_value->{error} }, {id => "fixtures-grids.form.create-fixtures.error.teams-incomplete"}) if $incomplete_team_grid_positions;
  
  # Return at this point if we have any errors so far
  return $return_value if scalar( @{ $return_value->{error} } );
  
  # If we reach this far, fixtures creation is allowed, so we can set that flag.  This is so we can redirect back to the
  # form if we're allowed to create them but there's an error (if we don't reach this far, we'll just redirect back to the
  # grid view).
  $return_value->{create_fixtures_allowed} = 1;
  
  # This hash will hold the values we'll flash back if we need to
  my %week_allocations = ();
  
  # Now loop through the weeks ensuring that we have a valid season week ID for each and that they are in order.
  # Go back to the first record
  $grid_weeks->reset;
  while ( my $week = $grid_weeks->next ) {
    $week_allocations{"week_" . $week->week }{id} = $week->week;
    
    if ( $season_weeks->{"week_" . $week->week} ) {
      # Find this week in the fixtures_weeks table
      my $season_week = $season->find_related("fixtures_weeks", {
        id => $season_weeks->{"week_" . $week->week},
      });
      
      if ( defined($season_week) ) {
        # Set the week beginning date for that week ID so we can refer to it later without going back to the DB
        $week_allocations{"week_" . $week->week }{week_beginning_id}    = $season_week->id;
        $week_allocations{"week_" . $week->week }{week_beginning_date}  = $season_week->week_beginning_date;
        
        # The week is valid; ensure it doesn't occur prior to the last one.
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.create-fixtures.error.date-occurs-before-previous-date",
          parameters  => [$week->week],
        }) if defined( $last_season_week ) and $season_week->week_beginning_date->ymd("") <= $last_season_week->week_beginning_date->ymd("");
        
        # Set the last season week so that we can check the next one occurs at a later date on the next iteration.
        $last_season_week = $season_week;
      } else {
        # Error, season week not found
        push(@{ $return_value->{error} }, {
          id          => "fixtures-grids.form.create-fixtures.error.week-invalid",
          parameters  => [$week->week],
        });
      }
    } else {
      # Error, season week not specified.
      push(@{ $return_value->{error} }, {
        id          => "fixtures-grids.form.create-fixtures.error.week-blank",
        parameters  => [$week->week],
      });
    }
  }
  
  if ( scalar( @{ $return_value->{error} } ) ) {
    $return_value->{week_allocations} = \%week_allocations;
  } else {
    ############## CREATE MATCHES #############
    # Loop through our week allocations and in each loop, loop through the divisions.
    # This will be the MASSIVE arrayref that will hold all the matches (plus their contained players, games and legs)
    my ( @matches, @match_ids, @match_names );
    
    # Loop through each week for the grid
    foreach my $week_allocation ( sort { $week_allocations{$a}{id} <=> $week_allocations{$b}{id} } keys %week_allocations ) {
      # Store the ID in a more easily readable variable
      my $scheduled_week      = $week_allocations{$week_allocation}{week_beginning_id};
      my $league_week_number  = $week_allocations{$week_allocation}{id};
      my $week_beginning_date = $week_allocations{$week_allocation}{week_beginning_date};
      
      # Loop through the divisions, getting each match for each division
      foreach my $division ( sort keys( %division_positions ) ) {
        # Store the template for this division
        my $team_match_template = $division_templates{$division};
        my @team_match_games_templates = @{ $division_templates{$division}{games} };
        
        foreach my $match ( @{ $grid_matches{$league_week_number} } ) {
          # Store the home and away team for easy access
          my $home_team = $division_positions{$division}{$match->{home_team}}->team if defined( $division_positions{$division}{$match->{home_team}} );
          my $away_team = $division_positions{$division}{$match->{away_team}}->team if defined( $division_positions{$division}{$match->{away_team}} );
          
          # This defined() check protects against teams that have a bye.
          if ( defined($home_team) and defined($away_team) ) {
            my $scheduled_date  = TopTable::Controller::Root::get_day_in_same_week($week_beginning_date, $division_positions{$division}{$match->{home_team}}->home_night->weekday_number);
            my $start_time;
            if ( defined( $home_team->default_match_start ) ) {
              # First default to the home team's start time
              $start_time = $home_team->default_match_start;
            } elsif ( defined( $home_team->club->default_match_start ) ) {
              # If null, fall back to the club's start time
              $start_time = $home_team->club->default_match_start;
            } else {
              # If null, finally use the season's default start time.
              $start_time = $season->default_match_start;
            }
            
            # Empty arrayref for the games - these will be populated in the next loop
            my @match_games = ();
            
            # Set up the league team match games / legs
            foreach my $game_template ( @team_match_games_templates ) {
              # Loop through creating legs for each game
              # Empty arrayref for the legs - this will be populated on the next loop
              my @match_legs = ();
              foreach my $i ( 1 .. $game_template->{legs_per_game} ) {
                push( @match_legs, {
                  home_team             => $home_team->id,
                  away_team             => $away_team->id,
                  scheduled_date        => $scheduled_date->ymd,
                  scheduled_game_number => $game_template->{match_game_number},
                  leg_number            => $i,
                });
              }
              
              # What we populate will be different, depending on whether it's a doubles game or not
              my $populate;
              if ( $game_template->{doubles_game} ) {
                $populate = {
                  home_team                 => $home_team->id,
                  away_team                 => $away_team->id,
                  scheduled_date            => $scheduled_date->ymd,
                  scheduled_game_number     => $game_template->{match_game_number},
                  individual_match_template => $game_template->{match_template},
                  actual_game_number        => $game_template->{match_game_number},
                  doubles_game              => $game_template->{doubles_game},
                  team_match_legs           => \@match_legs,
                };
              } else {
                $populate = {
                  home_team                 => $home_team->id,
                  away_team                 => $away_team->id,
                  scheduled_date            => $scheduled_date->ymd,
                  scheduled_game_number     => $game_template->{match_game_number},
                  individual_match_template => $game_template->{match_template},
                  actual_game_number        => $game_template->{match_game_number},
                  home_player_number        => $game_template->{singles_home_player_number},
                  away_player_number        => $game_template->{singles_away_player_number},
                  doubles_game              => $game_template->{doubles_game},
                  team_match_legs           => \@match_legs,
                }
              }
              
              push(@match_games, $populate);
            }
            
            # Now loop through and build the players.  We loop through twice for the number of players per team,
            # so that we do it for both teams
            # Empty arrayref to start off with
            my @match_players = ();
            foreach my $i ( 1 .. ( $team_match_template->{singles_players_per_team} * 2 ) ) {
              # Is it home or away?  If our loop counter is greater than the number of players in a team, we must have moved on to the away team
              my ( $location );
              if ( $i > $team_match_template->{singles_players_per_team} ) {
                $location = "away";
              } else {
                $location = "home";
              }
              
              push( @match_players, {
                home_team         => $home_team->id,
                away_team         => $away_team->id,
                player_number     => $i,
                location          => $location,
              });
            }
            
            # Push on to the array that will populate the DB
            push( @matches, {
              home_team                 => $home_team->id,
              away_team                 => $away_team->id,
              scheduled_date            => $scheduled_date->ymd,
              scheduled_start_time      => $start_time,
              season                    => $season->id,
              division                  => $division,
              tournament_round          => undef,
              venue                     => $home_team->club->venue->id,
              scheduled_week            => $scheduled_week,
              team_match_template       => $team_match_template->{id},
              fixtures_grid             => $grid->id,
              team_match_games          => \@match_games,
              team_match_players        => \@match_players,
            });
            
            # Push on to the IDs / names arrays that we'll use for the event log
            push( @match_ids, {
              home_team       => $home_team->id,
              away_team       => $away_team->id,
              scheduled_date  => $scheduled_date->ymd,
            });
            push( @match_names, sprintf("%s %s-%s %s (%s)", $home_team->club->short_name, $home_team->name, $away_team->club->short_name, $away_team->name, $scheduled_date->dmy("/")) );
          }
        }
      }
    }
    
    $self->populate( \@matches );
    
    # Return the matches so we can log their creation... lucky this is a reference, as this is a huge array!
    $return_value->{match_ids}    = \@match_ids;
    $return_value->{match_names}  = \@match_names;
    $return_value->{matches}      = \@matches;
  }
  
  return $return_value;
}

1;