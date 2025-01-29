package TopTable::Schema::ResultSet::TeamMatch;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;

=head2 season_matches

A predefined search to find and return the matches created with a season (optionally for a specific team).

=cut

sub season_matches {
  my $class = shift;
  my ( $season, $params ) = @_;
  my ( $where, $team, $grid );
  
  if ( defined($params->{team}) ) {
    $team = $params->{team};
  } elsif ( defined($params->{grid}) ) {
    $grid = $params->{grid};
  }
  
  if ( $team ) {
    $where = [{
      "scheduled_week.season" => $season->id,
      home_team => $team->id,
    }, {
      "scheduled_week.season" => $season->id,
      away_team => $team->id,
    }];
  } elsif ( $grid ) {
    $where = {
      "scheduled_week.season" => $season->id,
      fixtures_grid => $grid->id,
    };
  } else {
    $where = {"scheduled_week.season" => $season->id};
  }
  
  return $class->search($where, { join  => "scheduled_week",});
}

=head2 team_home_matches

Finds all matches within a season where the given team is at home.

=cut

sub team_home_matches {
  my $class = shift;
  my ( $season, $team ) = @_;
  
  return $class->search({
    home_team => $team->id,
    "scheduled_week.season" => $season->id,
  }, {
    prefetch => "scheduled_week",
  });
}

=head2 match_counts_by_month

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_month {
  my $class = shift;
  my ( $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where = {"season.id" => $season->id};
    $attributes = {
      select => [{
        count => "me.scheduled_date"
      },
      "scheduled_date"],
      as => [qw(number_of_matches scheduled_date)],
      join => {scheduled_week => "season"},
      group_by => {month => "scheduled_date"},
      order_by => {-asc => "scheduled_date"},
    };
  } else {
    $where = {};
    $attributes = {
      select => [{
        count => "me.scheduled_date"
      },
      "scheduled_date"],
      as => [ qw(number_of_matches scheduled_date) ],
      join => {scheduled_week => "season"},
      group_by => {month => "scheduled_date"},
      order_by => [{
        -desc => [qw( season.complete start_date end_date )]
      }, {
        -asc => "scheduled_date"
      }],
    };
  }
  
  return $class->search($where, $attributes);
}

=head2 match_counts_by_week

Returns, in date order, all of the weeks that have matches within a season and the number of matches.  

=cut

sub match_counts_by_week {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "season.id" => $season->id,
  }, {
    select => [{count => "me.scheduled_date"},
    qw( scheduled_week.id scheduled_week.week_beginning_date )],
    as => [qw( number_of_matches scheduled_week_id scheduled_week_date )],
    join => {scheduled_week  => "season"},
    prefetch => "scheduled_week",
    group_by => "scheduled_week.id",
    order_by => {-asc => "scheduled_week.id"},
  });
}

=head2 match_counts_by_day

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_day {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "season.id" => $season->id,
  }, {
    select => [{
      count => "me.played_date"
    },
    "played_date"],
    as => [ qw(number_of_matches played_date) ],
    join => [qw( season )],
    group_by => [qw( me.played_date )],
    order_by => {-asc => [qw( me.played_date )]},
  });
}

=head2 match_counts_by_venue

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_venue {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "season.id" => $season->id,
  }, {
    select => [{
      count => "me.scheduled_date"
    },
    "venue"],
    as => [ qw(number_of_matches venue)],
    prefetch => [qw( venue )],
    join => [qw( season )],
    group_by => [qw( venue.id )],
    order_by => {-asc => "venue.name"},
  });
}

=head2 match_counts_by_month

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_division {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "season.id" => $season->id,
    "division.id" => {"!=" => undef},
  }, {
    select => [{
      count => "me.scheduled_date"
    },
    "division"],
    as => [qw( number_of_matches division )],
    prefetch => {division_season => "division"},
    join => {scheduled_week => "season"},
    group_by => "division.id",
    order_by => {-asc => "division.rank"},
  });
}

=head2 match_counts_by_team

Returns, in date order, all of the months that have matches within a season and the number of matches.  

=cut

sub match_counts_by_team {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "me.season" => $season->id,
  }, {
    select => [{
      count => "me.scheduled_date"
    },
    qw( me.home_team me.away_team )],
    as => [qw( number_of_matches home_team away_team )],
    prefetch => {
      team_season_home_team_season => [ qw( team ), {club_season => "club"}],
      team_season_away_team_season => [ qw( team ), {club_season => "club"}],
    },
    group_by => [qw( team.id team_2.id )],
    order_by => {-asc => [qw( club_season.short_name team_season_home_team_season )]},
  });
}

=head2 matches_for_team

A search for matches involving the specified team in the specified season.

=cut

sub matches_for_team {
  my $class = shift;
  my ( $params ) = @_;
  my $team = $params->{team};
  my $season = $params->{season};
  my ( $page_number, $results_per_page );
  
  # These attributes are constant
  my $attributes = {
    prefetch => [qw( venue ), {
      team_season_home_team_season => [ qw( team ), {club_season => "club"}],
      team_season_away_team_season => [ qw( team ), {club_season => "club"}],
      division_season => [qw( division )],
      tournament_round => {
        tournament => {event_season => [qw( event )]},
      },
    }],
    order_by => {
      -asc => [qw( division.rank played_date )]
    }
  };
  
  # If we have a page number and a number of results per page, paginate
  if ( exists( $params->{page_number} ) or exists( $params->{results_per_page} ) ) {
    $page_number = delete $params->{page_number};
    $results_per_page = delete $params->{results_per_page};
    
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attributes->{page} = $page_number;
    $attributes->{rows} = $results_per_page;
  }
  
  return $class->search([{
    "me.season" => $season->id,
    home_team => $team->id,
  }, {
    "me.season" => $season->id,
    away_team => $team->id,
  }], $attributes);
}

=head2 matches_in_tourn_round

A search for matches in the specified tournament round.

=cut

sub matches_in_tourn_round {
  my $class = shift;
  my ( $params ) = @_;
  my $round = $params->{round};
  my ( $page_number, $results_per_page );
  
  # These attributes are constant
  my %attributes = (
    prefetch => [qw( venue ), {
      team_season_home_team_season => [ qw( team ), {club_season => "club"}],
      team_season_away_team_season => [ qw( team ), {club_season => "club"}],
      division_season => [qw( division )],
      tournament_round => {
        tournament => {event_season => [qw( event )]},
      },
    }],
    order_by => {
      -asc => [qw( division.rank played_date )]
    }
  );
  
  # If we have a page number and a number of results per page, paginate
  if ( exists( $params->{page_number} ) or exists( $params->{results_per_page} ) ) {
    $page_number = delete $params->{page_number};
    $results_per_page = delete $params->{results_per_page};
    
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attributes{page} = $page_number;
    $attributes{rows} = $results_per_page;
  }
  
  return $class->search({
    "tournament_round.id" => $round->id,
  }, \%attributes);
}

=head2 matches_in_division

A search for matches involving the specified division in the specified season.

=cut

sub matches_in_division {
  my $class = shift;
  my ( $params ) = @_;
  my $division = $params->{division};
  my $season = $params->{season};
  my $page_number = $params->{page_number};
  my $results_per_page = $params->{results_per_page};
  my %attrib = (
    prefetch  => [qw( venue ), {
      team_season_home_team_season => [qw( team ), {club_season => [qw( club )]}],
      team_season_away_team_season => [qw( team ), {club_season => [qw( club )]}],
      division_season => [qw( division )],
    }],
    order_by => {
      -asc => [qw( division.rank played_date club_season.short_name team_season_home_team_season.name )]
    },
  );
  
  # If we have a page number or a results_per_page parameter defined, we have to ensure both are provided and sane
  if ( defined($results_per_page) or defined($page_number) ) {
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attrib{page} = $page_number;
    $attrib{rows} = $results_per_page;
  }
  
  return $class->search({
    "me.season" => $season->id,
    "me.division" => $division->id,
  }, \%attrib);
}

=head2 matches_in_date_range

A search for matches in the specified date range in the given season.

=cut

sub matches_in_date_range {
  my $class = shift;
  my ( $params ) = @_;
  my $start_date = $params->{start_date};
  my $end_date = $params->{end_date};
  my $season = $params->{season};
  my $page_number = $params->{page_number};
  my $results_per_page = $params->{results_per_page};
  my %attrib = (
    prefetch  => [qw( venue ), {
      team_season_home_team_season => [qw( team ), {club_season => "club"}],
      team_season_away_team_season => [qw( team ), {club_season => "club"}],
      division_season => [qw( division )],
      tournament_round => {
        tournament => {
          event_season => [qw( event )]
        },
      },
    }],
    order_by  =>  {
      -asc => [qw( scheduled_date division.rank tournament.name tournament_round.round_number club_season.short_name team_season_home_team_season.name )],
    }
  );
  
  # If we have a page number or a results_per_page parameter defined, we have to ensure both are provided and sane
  if ( defined($results_per_page) or defined($page_number) ) {
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attrib{page} = $page_number;
    $attrib{rows} = $results_per_page;
  }
  
  return $class->search({
    "me.season" => $season->id,
    "team_season_home_team_season.season" => $season->id,
    "club_season.season" => $season->id,
    "team_season_away_team_season.season" => $season->id,
    "club_season_2.season" => $season->id,
    "me.played_date" => {
      -between => [$start_date->ymd, $end_date->ymd]
    },
  }, \%attrib);
}

=head2 incomplete_matches

A search for incomplete matches that should have been played before the specified cutoff.

=cut

sub incomplete_matches {
  my $class = shift;
  my ( $params ) = @_;
  my $date_cutoff = $params->{date_cutoff};
  my $season = $params->{season};
  my $page_number = $params->{page_number};
  my $results_per_page = $params->{results_per_page};
  my $attrib = {
    prefetch => [qw( venue ), {
      team_season_home_team_season => [qw( team ), {club_season => "club"}],
      team_season_away_team_season => [qw( team ), {club_season => "club"}],
      division_season => [qw( division )],
    }],
    order_by  =>  {
      -asc => [qw( played_date division.rank club_season.short_name team_season_home_team_season.name )]
    }
  };
  
  # If we have a page number or a results_per_page parameter defined, we have to ensure both are provided and sane
  if ( defined( $results_per_page ) or defined( $page_number ) ) {
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attrib->{page} = $page_number;
    $attrib->{rows} = $results_per_page;
  }
  
  return $class->search({
    "me.complete" => 0,
    "me.cancelled" => 0,
    played_date => {"<>" => undef},
    played_date => {
      "<=" => sprintf( "%s %s", $date_cutoff->ymd, $date_cutoff->hms ),
    }
  }, $attrib);
}

=head2 next_match_date

Get the next date with matches.

=cut

sub next_match_date {
  my $class = shift;
  my $schema = $class->result_source->schema;
  my $dtf = $schema->storage->datetime_parser;
  
  my $date = $class->search({
    played_date => {">=" => DateTime->now->ymd}
  }, {
    columns => [{
      date => {min => "played_date"}
    }],
  })->single->get_column("date");
  
  return $dtf->parse_date($date) if defined($date);
  return undef;
}

=head2 matches_on_date

A search for matches on a specified date.

=cut

sub matches_on_date {
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  my $date = $params->{date};
  my $page_number = $params->{page_number};
  my $results_per_page = $params->{results_per_page};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if defined($results_per_page) and $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if defined($page_number) and $page_number !~ m/^\d+$/;
  
  my $attributes = {
    prefetch  => [qw( venue ), {
      team_season_home_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_season_away_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      division_season => [qw( division )],
    }],
    order_by  =>  {
      -asc => [qw( division.rank scheduled_date club_season.short_name team_season_home_team_season.name )]
    }
  };
  
  if ( defined( $results_per_page ) and $page_number ) {
    $attributes->{page} = $page_number;
    $attributes->{rows} = $results_per_page;
  }
  
  return $class->search({
    "me.season" => $season->id,
    "team_season_home_team_season.season" => $season->id,
    "club_season.season" => $season->id,
    "team_season_away_team_season.season" => $season->id,
    "club_season_2.season" => $season->id,
    played_date => $date->ymd,
    
  }, $attributes);
}

=head2 matches_started

Return a list of matches that have been started (this is intended to be chained to another search, so we're searching on that resultset).

=cut

sub matches_started {
  my $class = shift;
  return $class->search({"me.started" => 1});
}

=head2 matches_at_venue

A search for matches involving the specified team in the specified season.

=cut

sub matches_at_venue {
  my $class = shift;
  my ( $params ) = @_;
  my $venue = $params->{venue};
  my $season = $params->{season};
  my $page_number = $params->{page_number};
  my $results_per_page = $params->{results_per_page};
  my $where;
  
  my %attrib = (
    prefetch  => [{
      team_season_home_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_season_away_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      division_season => [qw( division )],
    }],
    join => [qw( venue )],
    order_by =>  {
      -asc => [ qw( scheduled_date division.rank club_season.short_name team_season_home_team_season.name )]
    }
  );
  
  # If we have a page number or a results_per_page parameter defined, we have to ensure both are provided and sane
  if ( defined($results_per_page) or defined($page_number) ) {
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
    
    $attrib{page} = $page_number;
    $attrib{rows} = $results_per_page;
  }
  
  if ( $season ) {
    $where = {
      "me.season" => $season->id,
      "team_season_home_team_season.season" => $season->id,
      "club_season.season" => $season->id,
      "team_season_away_team_season.season" => $season->id,
      "club_season_2.season" => $season->id,
      "venue.id" => $venue->id,
    };
  } else {
    $where = {venue => $venue->id};
  }
  
  return $class->search($where, \%attrib);
}

=head2 competitions

Get the competition count for a given resultset of team matches.

=cut

sub competitions {
  my $class = shift;
  my ( $params ) = @_;
  my $exclude_league = $params->{exclude_league} || 0;
  my $prefetch = $params->{prefetch} || 0;
  
  # Exclude league matches if we need
  my %where = $exclude_league ? (tournament_round => {"!=" => undef}) : ();
  
  # Only prefetch if we want the extra data, otherwise join
  my $relation_key = $prefetch ? "prefetch" : "join";
  
  return $class->search(\%where, {
    $relation_key => {
      tournament_round => {
        tournament => {event_season => [qw( event )]},
      },
    },
    group_by => [qw( event.id )],
  });
}

=head2 handicapped_matches

Return the subset of matches within a resultset that are handicapped.

=cut

sub handicapped_matches {
  my $class = shift;
  return $class->search({"team_match_template.handicapped" => 1}, {
    join => [qw( team_match_template )],
  });
}

=head2 get_match_by_ids

Returns a match in the same way that ->find() would, but prefetches related players, games and legs.

=cut

sub get_match_by_ids {
  my $class = shift;
  my ( $home_team_id, $away_team_id, $scheduled_date ) = @_;
  
  return $class->find({
    home_team => $home_team_id,
    away_team => $away_team_id,
    scheduled_date => $scheduled_date->ymd,
  }, {
    prefetch  => [qw( venue season ), {
      team_season_home_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_season_away_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_match_players => [qw( loan_team location player )],
      division_season => [qw( division )],
      team_match_template => "winner_type",
      team_match_games => [qw( home_player away_player umpire ), {
        individual_match_template => [qw( game_type serve_type )],
        team_match_legs => [qw( first_server next_point_server )],
      }, {
        home_doubles_pair => [qw(person_season_person1_season_team person_season_person2_season_team)],
      }, {
        away_doubles_pair => [qw(person_season_person1_season_team person_season_person2_season_team)],
      }],
    }],
    order_by  => {
      -asc  => [qw(team_match_games.actual_game_number team_match_legs.leg_number team_match_players.player_number)],
    }
  });
}

=head2 get_match_by_url_keys

Returns a match in the same way that ->find() would, but prefetches related players, games and legs.

=cut

sub get_match_by_url_keys {
  my $class = shift;
  my ( $home_club_url_key, $home_team_url_key, $away_club_url_key, $away_team_url_key, $scheduled_date, $params ) = @_;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  return $class->find({
    "club.url_key" => $home_club_url_key,
    "team.url_key" => $home_team_url_key,
    "club_2.url_key" => $away_club_url_key,
    "team_2.url_key" => $away_team_url_key,
    scheduled_date => $scheduled_date->ymd,
  }, {
    prefetch  => [qw( venue season ), {
      team_season_home_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_season_away_team_season => [qw( team ), {club_season => [qw( club )]}],
    }, {
      team_match_players => [qw( loan_team location player )],
      division_season => [qw( division )],
      team_match_template => "winner_type",
      team_match_games => [qw( home_player away_player umpire ), {
        individual_match_template => [qw( game_type serve_type )],
        team_match_legs => [qw( first_server next_point_server )],
      }, {
        home_doubles_pair => [qw(person_season_person1_season_team person_season_person2_season_team)],
      }, {
        away_doubles_pair => [qw(person_season_person1_season_team person_season_person2_season_team)],
      }],
    }],
    order_by => {
      -asc => [qw( team_match_games.actual_game_number team_match_legs.leg_number team_match_players.player_number )],
    },
    group_by => [qw( team_match_games.actual_game_number team_match_games.scheduled_game_number team_match_legs.leg_number team_match_players.player_number )],
  });
}

=head2 matches_involving_player_in_season

Retrieve all of the matches for a given player in the given season.

=cut

sub matches_involving_player_in_season {
  my $class = shift;
  my ( $season, $person ) = @_;
  
  return $class->search({
    "season.id" => $season->id,
    "player.id" => $person->id,
  }, {
    prefetch => {
      team_match_players => "player",
    },
    join => [qw( season )],
  });
}

=head2 incomplete_and_not_cancelled

Returns matches that have either been completed or cancelled.  If a season parameter is passed, only looks in the given season.

=cut

sub incomplete_and_not_cancelled {
  my $class = shift;
  my ( $parameters ) = @_;
  my $season = delete $parameters->{season};
  
  # Set up the initial where clause that will exist regardless
  my $where = {
    cancelled => 0,
    complete => 0,
  };
  
  $where->{season} = $season->id if defined($season);
  
  return $class->search($where);
}

1;