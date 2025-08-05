package TopTable::Schema::ResultSet::Team;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;
use HTML::Entities;

=head2 all_teams_by_club_by_team_name

A predefined search for all teams ordered by club (alphabetically by club full name), then team name.

=cut

sub all_teams_by_club_by_team_name {
  my $class = shift;
  my ( $param ) = @_;
  my $season = $param->{season} || undef;
  my $years_to_go_back = $param->{years} || undef;
  my ( $where, $earliest_start_date );
  
  if ( defined($season) ) {
    # Get a specific season
    $where = [{
      "season.id" => $season->id,
      #"person_seasons.team_membership_type" => "active",
      "person_seasons.season" => $season->id,
    }, {
      "season.id" => undef,
      #"person_seasons.team_membership_type" => "active",
    }];
  } else {
    # Get the last x seasons
    $years_to_go_back = 5 if !defined($years_to_go_back) or $years_to_go_back !~ /^\d+$/;
    $earliest_start_date = DateTime->today->subtract(years => $years_to_go_back);
    
    $where = {
      #"person_seasons.team_membership_type" => "active",
      "season.start_date" => {">=" => $earliest_start_date->ymd}
    };
  }
  
  return $class->search($where, {
    prefetch => [{
      club => "club_seasons",
      team_seasons => [qw( season captain home_night ), {
        division_season => "division",
        person_seasons  => "person",
      }],
    }],
    order_by => [{
      -asc => [qw( club.full_name me.name season.complete )]
    }, {
      -desc  => [qw( season.start_date season.end_date )]
    }, {
      -asc => [qw( person.surname person.first_name )]
    }]
  });
}

=head2 teams_in_club

A predefined search for all teams in the given club.

=cut

sub teams_in_club {
  my $class = shift;
  my ( $param ) = @_;
  my ( $where, $attrib, $sort_hash );
  my $club = $param->{club};
  my $season = $param->{season} || undef;
  my $sort_column = $param->{sort};
  my $order = $param->{order};
  
  # Sanitist the sort order
  $sort_column = "name" unless defined($sort_column) and ( $sort_column eq "name" or $sort_column eq "captain" or $sort_column eq "division" or $sort_column eq "home-night" );
  $order = "asc" unless defined($order) and ( $order eq "asc" or $order eq "desc" );
  $order = "-$order"; # The 'order_by' hash key needs to start with a '-'
  
  # If there's no season specified, we won't have a captain, a division or a home night, so we must just be sorting by name
  $sort_column = "name" unless defined($season);
  
  # Build the hashref that will give us the database columns to sort by
  my %db_columns = (
    name => [qw( me.name )],
    captain => [qw( captain.surname captain.first_name )],
    division => [qw( division.rank )],
    "home-night" => [qw( home_night.weekday_number )],
  );
  
  # Build the sort hash
  my $sort_instruction = {$order => $db_columns{$sort_column}};
  
  # Add an ascending team name search to the sort hash if the primary sort isn't by name
  if ( $sort_column ne "name" ) {
    if ( $sort_column eq "-asc" ) {
      # We're doing an ascending sort already, so just push "me.name" on to it
      push(@{$sort_instruction->{$order}}, "me.name");
    } else {
      # The primary sort is descending, so we need to make the sort hash an array
      $sort_instruction = [$sort_instruction, {-asc => "me.name"}];
    }
  }
  
  if ( defined($season) ) {
    $where = {
      "me.club" => $club->id,
      "team_seasons.season" => $season->id,
    };
    
    $attrib = {
      prefetch  => {
        "team_seasons" => [qw( season captain home_night ), {division_season => "division"}],
      },
      order_by => $sort_instruction,
    };
  } else {
    $where = {"me.club" => $club->id};
    
    $attrib = {
      prefetch  => {
        "team_seasons" => [qw( season captain home_night ), {division_season => "division", club_season => "club"}],
      },
      order_by => [{
        -asc => [qw( me.name )]
      }, {
        -desc => [qw( season.start_date season.end_date)]
      }]
    };
  }
  
  return $class->search($where, $attrib);
}

=head2 find_by_name_in_club

Finds a team with the given name in the given club

=cut

sub find_by_name_in_club {
  my $class = shift;
  my ( $club, $name ) = @_;
  
  return $class->find({
    name => $name,
    club => $club->id,
  }, {prefetch  => "club"});
}

=head2 teams_in_season_by_club_by_team_name

A predefined search for all teams in a particular season ordered by club (alphabetically by club short name), then team name.

=cut

sub teams_in_season_by_club_by_team_name {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "team_seasons.season" => $season->id,
  }, {
    prefetch => {
      "team_seasons" => [qw( club_season season captain ), {division_season => "division"}],
    },
    order_by  => {-asc => [qw( club_season.short_name team_seasons.name )]}
  });
}

=head2 teams_in_season_by_division_by_club_team_name

A predefined search for all teams in a particular season ordered by club (alphabetically by club short name), then team name.

=cut

sub teams_in_season_by_division_by_club_team_name {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    "team_seasons.season" => $season->id,
  }, {
    prefetch => {
      "club" => "club_seasons",
      "team_seasons" => [qw( season captain ), {division_season => "division"}],
    },
    order_by  => {-asc => [qw( division.rank club.short_name me.name )]}
  });
}

=head2 get_teams_with_captains_in_season

Return a list of teams in a season with a captain set.  Order by club / team name or by division rank (then club / team name), depending on the $view-mode param.

=cut

sub get_teams_with_captains_in_season {
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  my $view_by = $params->{view_by};
  
  my $order_by = $view_by eq "by-division"
    ? {-asc => [qw( division.rank club.short_name me.name )]}
    : {-asc => [qw( club.short_name me.name division.rank )]};
  
  return $class->search({
    "team_seasons.season" => $season->id,
    "club_seasons.season" => $season->id,
    "team_seasons.captain" => {
      "!=" => undef,
    }
  }, {
    prefetch => {
      "club" => "club_seasons",
      "team_seasons" => [qw( season captain ), {division_season => "division"}],
    },
    order_by => $order_by,
  });
}

=head2 get_teams_with_specified_captain

Get all teams that have the specified person as captain within the specified season

=cut

sub get_teams_with_specified_captain {
  my $class = shift;
  my ( $person, $season ) = @_;
  
  return $class->search({
    "team_seasons.season" => $season->id,
    "team_seasons.captain" => $person->id,
  }, {
    join => {team_seasons => "captain"},
    prefetch => "club",
  });
}

=head2 find_with_prefetches

A wrapper for find() that prefetches the joined tables with the team data.

=cut

sub find_with_prefetches {
  my $class = shift;
  my ( $id, $params ) = @_;
  my $season = delete $params->{season};
  my ( $where, $attrib );
  
  # Default attributes:
  
  if ( defined($season) ) {
    # If we have a season specified, we'll prefetch team_seasons as well
    $where = {
      id => $id,
      "team_seasons.season" => $season->id,
    };
    $attrib = {
      prefetch => {
        team_seasons => [{club_season => "club"}, qw( home_night )],
      },
    };
  } else {
    $where = {id => $id};
    $attrib = {prefetch  => [qw( club )]};
  }
  
  return $class->find($where, $attrib);
}

=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_name {
  my $class = shift;
  my ( $params ) = @_;
  my $q = $params->{q};
  my $season = $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my @words = split(/\s+/, $q);
  
  # We do words on 'or' here so we can construct a 'club name + team name' in the search
  my @constructed_like = ("-and");
  foreach my $word ( @words ) {
    my $constructed_like = {-like => "%$word%"};
    push (@constructed_like, $constructed_like);
  }
  
  my $where = [{
    "club.full_name" => \@constructed_like,
  }, {
    "club.short_name" => \@constructed_like,
  }, {
    "me.name" => \@constructed_like,
  }];
  
  my $attrib = {
    prefetch => "club",
    order_by => {-asc => [ qw( club.short_name me.name ) ]},
    group_by => [ qw( club.short_name me.name ) ],
  };
  
  if ( defined( $season ) ) {
    $where->[0]{"team_seasons.season"} = $season->id;
    $where->[1]{"team_seasons.season"} = $season->id;
    $where->[2]{"team_seasons.season"} = $season->id;
    $attrib->{join} = "team_seasons";
    push(@{$attrib->{order_by}{-asc}}, qw( me.id ));
  }
  
  return $class->search($where, $attrib);
}

=head2 find_url_key

Same as find(), but uses the url_key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $class, $club, $url_key, $params ) = @_;
  my $season = $params->{season};
  my ( $where, $attrib );
  
  if ( defined($season) ) {
    $where = {
      url_key => $url_key,
      "club.id" => $club->id,
      "team_seasons.season" => $season->id,
    };
    $attrib = {
      prefetch => {team_seasons => [{club_season => "club"}, "home_night"]},
    };
  } else {
    $where = {
      url_key => $url_key,
      "club.id" => $club->id,
    };
    $attrib = {prefetch  => [qw( club )]};
  }
  
  return $class->find($where, $attrib);
}

=head2 find_url_keys

Same as find(), but uses the url_key columns (from both the club and team tables) instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_keys {
  my ( $class, $club_url, $team_url, $params ) = @_;
  my $season = $params->{season};
  my ( $where, $attrib );
  
  if ( defined($season) ) {
    $where = {
      "me.url_key" => $team_url,
      "club.url_key" => $club_url,
      "team_seasons.season" => $season->id,
    };
    $attrib = {
      prefetch => {team_seasons => [{club_season => "club"}, "home_night"]},
    };
  } else {
    $where = {
      "me.url_key" => $team_url,
      "club.url_key" => $club_url,
    };
    $attrib = {prefetch  => [qw( club )]};
  }
  
  return $class->find($where, $attrib);
}

=head2 find_names

Same as find(), but uses the url_keys column (in ) instead of the id.  So we can use human-readable URLs.

=cut

sub find_by_names {
  my ( $class, $params ) = @_;
  my $club_name = $params->{club_name};
  my $team_name = $params->{team_name};
  my $season = $params->{season};
  my ( $where, $attrib );
  
  if ( defined($season) ) {
    $where = {
      "club.short_name" => $club_name,
      "me.name" => $team_name,
      "team_seasons.season" => $season->id,
    };
    $attrib = {
      prefetch  => {
        team_seasons => [{club_season => "club"}, qw( home_night )],
      },
    };
  } else {
    $where = {
      "club.short_name" => $club_name,
      "me.name" => $team_name,
    };
    $attrib = {
      prefetch  => [qw( club )],
    };
  }
  
  return $class->find($where, $attrib);
}

=head2 make_url_key

Generate a unique key from the given season name.

=cut

sub make_url_key {
  my ( $class, $club, $name, $exclusion_obj ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc($original_url_key); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = sprintf("%s-%d", $original_url_key, $count);
    } else {
      $url_key = $original_url_key;
    }
    
    my $conflict;
    if ( defined($exclusion_obj) ) {
      # Find anything with this value, excluding the exclusion object passed in
      $conflict = $class->find({}, {
        where => {
          "me.url_key" => $url_key,
          "club.url_key" => $club->url_key,
          "me.id" => {"!=" => $exclusion_obj->id},
        },
        join  => [qw( club )],
      });
    } else {
      # Find anything with this value
      $conflict = $class->find({
        "club.url_key" => $club->url_key,
        "me.url_key" => $url_key,
      }, {
        join => [qw( club )],
      });
    }
    
    # If not, return it
    return $url_key unless defined($conflict);
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a team.

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
  my $team = $params->{team} || undef;
  my $name = $params->{name} || undef;
  my $club = $params->{club} || undef;
  my $division = $params->{division} || undef;
  my $captain = $params->{captain} || undef;
  my $home_night = $params->{home_night} || undef;
  my $venue = $params->{venue} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $players = $params->{players} || [];
  my $reassign_active = $params->{reassign_active_players};
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      start_hour => $start_hour,
      start_minute => $start_minute,
      players => [],
    },
    completed => 0,
    
    # We communicate that the captain or home night has changed, as these may trigger an event log
    home_night_changed => 0,
    captain_changed => 0,
  };
  
  # Check there's a current season (we'll need it later anyway, but it's an error if there isn't)
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    # No current season, which is a fatal error, return
    push(@{$response->{error}}, $lang->maketext("teams.form.error.no-current-season"));
    return $response;
  }
  
  # Work out if we're mid-season by searching for matches - if the matches have been created already, it's counted as mid-season
  my $mid_season = $season->search_related("team_matches")->count > 0 ? 1 : 0;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{error}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "create" ) {
    # Creating fatal checks
    # We can't create teams mid-season.
    if ( $mid_season ) {
      push(@{$response->{error}}, $lang->maketext("teams.form.error.create-not-allowed"));
      return $response;
    }
  } else {
    # Editing fatal checks
    if ( defined($team) ) {
      # Look up the team if it's not a valid team object already
      $team = $class->find($team) unless $team->isa("TopTable::Schema::Result::Team");
      
      unless ( defined($team) ) {
        push(@{$response->{error}}, $lang->maketext("teams.form.error.team-invalid"));
        
        # Another fatal error
        return $response;
      }
    } else {
      # No team submitted
      push(@{$response->{error}}, $lang->maketext("teams.form.error.team-blank"));
      return $response;
    }
  }
  
  # Club error needs to be set so we can put the club error in the correct place in the array, as we first want the name error
  # if there is one, so can't just push this on to the errors stack.  The name can't be checked before the club because we need
  # the club to be able to know whether or not the name is unique to that club.
  # We also do division checks here, as they are different depending on whether we're creating or editing, so it makes sense to do them
  # in the same if blocks as the clubs - so again, they need to be stored and pushed on to the error stack at the right place.
  my ( $old_club, $old_division, $old_venue, $team_season, $club_error, $division_error, $venue_error );
  if ( $action eq "create" ) {
    # Creating
    # Club and division checks - these are simpler than the ones we do when editing, so they need to be separate to the edit checks
    
    if ( defined($club) ) {
      $club = $schema->resultset("Club")->find_id_or_url_key($club) unless $club->isa("TopTable::Schema::Result::Club");
      $club_error = $lang->maketext("teams.form.error.club-invalid") unless defined($club);
    } else {
      $club_error = $lang->maketext("teams.form.error.club-blank");
    }
    
    if ( defined($division) ) {
      $division = $schema->resultset("Division")->find_id_or_url_key($division) unless $division->isa("TopTable::Schema::Result::Division");
      
      if ( defined($division) ) {
        # Division is valid, but we need to make sure it's being used in this season
        my $division_season = $division->find_related("division_seasons", {season => $season->id});
        $division_error = $lang->maketext("teams.form.error.division-not-in-use", encode_entities($division->name)) unless defined($division_season);
      } else {
        # Invalid division
        $division_error = $lang->maketext("teams.form.error.division-invalid");
      }
    } else {
      $division_error = $lang->maketext("teams.form.error.division-blank");
    }
    
    # Venue can be blank, in which case we use the club's default venue, or it can be a valid venue ID / URL key
    if ( defined($venue) ) {
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue) unless $venue->isa("TopTable::Schema::Result::Venue");
      
      if ( defined($venue) ) {
        # Venue is valid, but we need to make sure it's active
        $venue_error = $lang->maketext("teams.form.error.venue-inactive", encode_entities($venue->name)) unless $venue->active;
      } else {
        # Invalid division
        $venue_error = $lang->maketext("teams.form.error.venue-invalid");
      }
    }
  } else {
    # Editing
    $old_club = $team->club;
    $team_season = $team->find_related("team_seasons", {season => $season->id});
    
    if ( !defined($team_season) and $mid_season ) {
      # If this team hasn't entered this season yet and the matches have already been created, we can't edit them now
      push(@{$response->{error}}, $lang->maketext("teams.form.error.matches-exist-team-not-entered", $team->club->short_name, $team->name));
    } elsif ( defined($team_season) ) {
      # We have a team season, which means there must be a division
      $old_division = $team_season->division_season->division;
      $old_venue = $team_season->venue;
    }
    
    # Club checks; fairly complex due to changes that may or may not be allowed.  The HTML form may have disabled the field,
    # in which case the value won't come through and will be undef
    if ( defined($club) ) {
      # Check the specified club is either a valid ID / URL key or a club object already (this will undef $club if it's not a valid ID)
      $club = $schema->resultset("Club")->find_id_or_url_key($club) unless $club->isa("TopTable::Schema::Result::Club");
      
      if ( !defined($club) ) {
        $club_error = $lang->maketext("teams.form.error.club-invalid");
      } elsif ( $mid_season and $club->id != $old_club->id ) {
        # A different club to the one we have stored is specified and we can't change clubs mid-season
        $club_error = $lang->maketext("teams.form.error.club-change-not-allowed");
      }
    } else {
      # No club specified; ensure we use the old club when we do the update (assigning here saves an additional check later on)
      $club = $old_club;
    }
    
    # Division checks; fairly complex due to changes that may or may not be allowed.  The HTML form may have disabled the field,
    # in which case the value won't come through and will be undef
    if ( defined($division) ) {
      # A division's been specified, but it's invalid
      $division = $schema->resultset("Division")->find_id_or_url_key($division) unless $division->isa("TopTable::Schema::Result::Division");
      
      if ( defined($division) ) {
        # Division is valid, we need to first check if it's changed and if we're allowed to change divisions at this stage
        if ( defined($old_division) and $division->id != $old_division->id ) {
          # A different division to the one we have stored is specified
          if ( $mid_season ) {
            # Mid-season, can't change divisions
            $division_error = $lang->maketext("teams.form.error.division-change-not-allowed");
          } else {
            # The division is changed and that is allowed, we just need to check that the division is in use this season
            my $division_season = $division->find_related("division_seasons", {season => $season->id});
            $division_error = $lang->maketext("teams.form.error.division-not-in-use", encode_entities($division->name)) unless defined($division_season);
          }
        }
      } else {
        # Invalid division specified
        $division_error = $lang->maketext("teams.form.error.division-invalid");
      }
    } else {
      # No division specified; ensure we use the old one when we do the update (assigning here saves an additional check later on)
      $division = $old_division;
    }
    
    # Venue checks; fairly complex due to changes that may or may not be allowed (and it can be blank).  The HTML form may have disabled the field,
    # in which case the value won't come through and will be undef; if we are allowed to edit the venue and it's undef, we can blank it; if we're not
    # allowed to edit the venue, we need to use the old one (which may or may not be populated).
    if ( $mid_season ) {
      # Can't change the venue mid-season, so if the venue is specified we'll error, as it shouldn't be passed in
      $venue_error = $lang->maketext("teams.form.error.venue-change-not-allowed") if defined($venue);
      $venue = $old_venue; # Reset back to the old venue (we do this regardless of whether or not it's been specified).
    } else {
      # Not mid-seasons, so the venue can be specified / changed - in this case, if the venue is specified, we check and set it,
      # if not, we need to remove it so the club's default venue is used.
      if ( defined($venue) ) {
        $venue = $schema->resultset("Venue")->find_id_or_url_key($venue) unless $venue->isa("TopTable::Schema::Result::Venue");
        
        if ( defined($venue) ) {
          # Venue is valid, but we need to make sure it's active
          $venue_error = $lang->maketext("teams.form.error.venue-inactive", encode_entities($venue->name)) unless $venue->active;
        } else {
          # Invalid division
          $venue_error = $lang->maketext("teams.form.error.venue-invalid");
        }
      }
    }
  }
  
  $response->{fields}{club} = $club;
  $response->{fields}{division} = $division;
  $response->{fields}{venue} = $venue;
  
  # Check this doesn't ensure the division doesn't have too many teams to add another one
  if ( defined($division) ) {
    # If we're editing, we only check this if the division has changed; if we're creating,
    # we check regardless; if we're editing we only check if the division has changed.
    if ( ( $action eq "edit" and defined($old_division) and $division->id != $old_division->id ) or $action eq "create" ) {
      my $division_season = $division->search_related("division_seasons", {
        season => $season->id,
      }, {
        prefetch => "fixtures_grid",
        rows => 1,
      })->single;
      
      my $maximum_teams = $division_season->fixtures_grid->maximum_teams;
      my $current_teams = $division_season->search_related("team_seasons")->count;
      
      $division_error = $lang->maketext("teams.form.error.division-full", $division->name, $maximum_teams, $current_teams) if $current_teams >= $maximum_teams;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already in that club.
  if ( defined($name) ) {
    # Name entered, check it.
    # We only need to do this if we have a club to check - if we don't have a club,  we can't do this check, but then we will already have generated an error.
    # The name check is more complex for a team; a team name must be unique within the
    # club that it's currently registered for, not within the entire league.
    if ( defined($club) ) {
      my $team_name_check;
      if ( $action eq "edit" ) {
        $team_name_check = $class->find({}, {
          where => {
            name => $name,
            club => $club->id,
            id => {"!=" => $team->id}
          }
        });
      } else {
        $team_name_check = $class->find({
          name => $name,
          club => $club->id,
        });
      }
      
      push(@{$response->{error}}, $lang->maketext("teams.form.error.name-exists", $name, $club->full_name)) if defined($team_name_check);
    }
  } else {
    # Name omitted.
    push(@{$response->{error}}, $lang->maketext("teams.form.error.name-blank"));
  }
  
  # Now we've done our name checks, push the club / division errors on to the error stack if we have them
  push(@{$response->{error}}, $club_error) if defined($club_error);
  push(@{$response->{error}}, $division_error) if defined($division_error);
  
  # Lookup the captain and check it if an ID was specified
  if ( defined($captain) ) {
    $captain = $schema->resultset("Person")->find_id_or_url_key($captain) unless $captain->isa("TopTable::Schema::Result::Person");
    push(@{$response->{error}}, $lang->maketext("teams.form.error.captain-invalid")) unless defined($captain);
  }
  
  $response->{fields}{captain} = $captain;
  
  if ( $mid_season ) {
    if ( (defined($captain) and defined($team_season->captain) and $captain->id != $team_season->captain->id) or (!defined($captain) and defined($team_season->captain)) or (defined($captain) and !defined($team_season->captain)) ) {
      # Captain has changed if:
      #  * The captain is submitted and there is a team captain already but they don't match
      #  * The captain is submitted and there's NOT a team captain already
      #  * The captain is NOT submitted and there's a team captain already (remove the captain)
      $response->{captain_changed} = 1;
    }
  }
  
  # Check valid start time
  # If blank, we won't error; they'll just use the club's default match start time - and if
  # that's blank, we'll use the club's default start time, followed by the season's if that's blank.
  if ( defined($start_hour) and $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
    push(@{$response->{error}}, $lang->maketext("teams.form.error.start-hour-invalid"));
  }
  
  if ( defined($start_minute) and $start_minute !~ m/^(?:[0-5][0-9])$/ ) {
    push(@{ $response->{error} }, $lang->maketext("teams.form.error.start-minute-invalid"));
  }
  
  # Check we don't have one and not the other
  push(@{$response->{error}}, $lang->maketext("teams.form.error.start-time-not-complete")) if ( defined($start_hour) and !defined($start_minute) ) or ( !defined($start_hour) and defined($start_minute) );
  
  # Check home night
  if ( defined($home_night) ) {
    $home_night = $schema->resultset("LookupWeekday")->find($home_night) unless $home_night->isa("TopTable::Schema::Result::LookupWeekday");
    push(@{$response->{error}}, $lang->maketext("teams.form.error.home-night-invalid")) unless defined($home_night);
  } else {
    # Home night not specified
    push(@{$response->{error}}, $lang->maketext("teams.form.error.home-night-blank"));
  }
  
  # Add home night to the fields to pass back
  $response->{fields}{home_night} = $home_night;
  
  push(@{$response->{error}}, $venue_error) if defined($venue_error);
  
  # Grab the player IDs
  # Look up all the players first; these are submitted in a single field, comma separated
  # Set up the arrayref that will hold the DB object for each player, then push the result of a find() on to it for each ID
  $players = [] unless ref($players) eq "ARRAY";
  
  # Validate and create the players' seasons - these are validated here because any invalid ones will just create warnings, as they're not essential at this point and can
  # be entered later if needed
  # Check the players (if entered) are valid
  # Just keep count of the number of invalid players, as if there's more than one, the same message multiple times will be annoying
  my $invalid_players = 0;
  
  # We can't do a normal foreach, as we need to keep the index so we can splice if needed
  # Loop through in reverse so that when we splice, we don't end up missing rows
  # Because we're looping through in reverse, we will reverse it first so that we actually loop through in the right order
  @{$players} = reverse @{$players};
  
  # We need to build the below array of submitted IDs that already exist as an active membership so that we can check against that list
  my @existing_ids = ();
  foreach my $i ( reverse 0 .. $#{$players} ) {
    # Easy access to this array element
    my $player = $players->[$i];
    
    # Turn it into a DB object if it's not already
    $player = $schema->resultset("Person")->find_id_or_url_key($player) unless $player->isa("TopTable::Schema::Result::Person");
    
    # Set the player back into the array
    $players->[$i] = $player;
    
    if ( defined($player) ) {
      # Check if this player is active already
      my $active_membership = $player->search_related("person_seasons", {
        "me.season" => $season->id,
        "team_season.season" => $season->id,
        team_membership_type => "active",
      }, {
        rows => 1,
        prefetch => {team_season => "club_season"}
      })->single;
      
      if ( defined($active_membership) ) {
        my $active_team_name = sprintf("%s %s", $active_membership->team_season->club_season->short_name, $active_membership->team_season->name);
        
        if ( $action eq "edit" and $active_membership->team_season->team->id == $team->id ) {
          # Splice the player out, since their active membership is already for this team.
          push(@existing_ids, $player->id);
          splice(@{$players}, $i, 1);
        } else {
          # This person already has an active membership for another team; now we need to check the reassignment setting
          if ( $reassign_active ) {
            # Reassign and warn that we've reassigned; the membership needs either deleting or setting to inactive, depending on whether or not they've played any games yet
            if ( $active_membership->matches_played > 0 ) {
              $active_membership->update({team_membership_type => "inactive"});
              push(@{$response->{info}}, $lang->maketext("teams.form.warning.player-reassigned-old-membership-inactive", encode_entities($player->display_name), encode_entities($active_team_name), encode_entities($season->name), encode_entities($player->first_name)));
            } else {
              # No matches played, delete
              $active_membership->delete;
              push(@{$response->{info}}, $lang->maketext("teams.form.warning.player-reassigned-old-membership-removed", encode_entities($player->display_name), encode_entities($active_team_name), encode_entities($season->name), encode_entities($player->first_name)));
            }
          } else {
            # Do not reassign, just warn and splice the value from the array.
            splice(@{$players}, $i, 1);
            push(@{$response->{warning}}, $lang->maketext("teams.form.warning.player-not-reassigned", encode_entities($player->display_name), encode_entities($active_team_name), encode_entities($season->name), encode_entities($player->first_name)));
          }
        }
      }
      
      # This player is valid, so we definitely will add it to sanitised fields to pass back in case we are redirecting to the error form
      push(@{$response->{fields}{players}}, $player);
    } else {
      $invalid_players++;
      
      # If the player is invalid, splice them out
      splice(@{$players}, $i, 1);
    }
  }
  
  my ( $players_text, $past_tense_indicative );
  if ( $invalid_players == 1 ) {
    push(@{$response->{warning}}, $lang->maketext("teams.form.warning.player-invalid-singular"));
  } elsif ( $invalid_players > 1 ) {
    push(@{$response->{warning}}, $lang->maketext("teams.form.warning.players-invalid-multiple"));
  }
  
  if ( scalar @{ $response->{error}} == 0 ) {
    # Set the time to null if it's not been set
    my $default_match_start = sprintf("%s:%s", $start_hour, $start_minute) if defined($start_hour) and defined($start_minute);
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $class->result_source->schema->txn_scope_guard;
    
    # Check if we need to create a new club season
    unless ( defined(my $club_season = $club->get_season($season)) ) {
      $club_season = $club->create_related("club_seasons", {
        season => $season->id,
        full_name => $club->full_name,
        short_name => $club->short_name,
        abbreviated_name => $club->abbreviated_name,
        venue => $club->venue->id,
        secretary => defined($club->secretary) ? $club->secretary->id : undef,
      });
    }
    
    # Success, we need to create / edit the team
    if ( $action eq "create" ) {
      # Setup the team season
      $team = $class->create({
        name => $name,
        url_key => $class->make_url_key($club, $name),
        club => $club->id,
        venue => defined($venue) ? $venue->id : undef,
        default_match_start => $default_match_start,
        team_seasons => [{
          season => $season->id,
          name => $name,
          club => $club->id,
          division => $division->id,
          captain => defined($captain) ? $captain->id : undef,
          home_night => $home_night->weekday_number,
          venue => defined($venue) ? $venue->id : undef,
          grid_position => undef,
        }],
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($club->full_name), $lang->maketext("admin.message.created")));
    } else {
      # Editing
      
      # Save away the old home night so we can check if it's changed; if it has and we're mid-season, we will need to
      # change the scheduled date for all the home matches for this team.
      my $old_home_night = $team_season->home_night if defined($team_season);
      
      $team->update({
        name => $name,
        url_key => $class->make_url_key($club, $name, $team),
        club => $club->id,
        venue => defined($venue) ? $venue->id : undef,
        default_match_start => $default_match_start,
      });
      
      if ( $mid_season and $old_home_night->weekday_number != $home_night->weekday_number ) {
        # If we're mid-season and the home night has changed, we'll look for matches where this team is at home
        # this season and re-calculate the match date.
        my $matches = $team->search_related("team_matches_home_teams", {
          "me.season" => $season->id,
        }, {
          prefetch => "scheduled_week",
        });
        
        # Now we've searched, we need to loop through and update them
        while ( my $match = $matches->next ) {
          # Get the week beginning date
          my $week_beginning_date = $match->scheduled_week->week_beginning_date;
          
          # Get the new match date in that week
          my $new_match_date = TopTable::Controller::Root::get_day_in_same_week($week_beginning_date, $home_night->weekday_number);
          
          # Update the match
          $match->update({scheduled_date  => $new_match_date->ymd});
        }
        
        $response->{home_night_changed} = 1;
      }
      
      if ( defined($team_season) ) {
        # If we have a season, we just update the changeable things - we don't worry here whether division is changeable,
        # as we've already raised an error if it's been specified and has changed; if it's not been specified, it's already
        # been set to the old value to save checks here
        
        $team_season->update({
          name => $name,
          club => $club->id,
          captain => defined($captain) ? $captain->id : undef,
          division => $division->id,
          venue => defined($venue) ? $venue->id : undef,
          home_night => $home_night->weekday_number,
        });
      } else {
        # If we're editing and we don't have a season association for this season yet, we'll create one here - if we're mid-season, we won't get
        # here, we've raised an error already.
        $team_season = $team->create_related("team_seasons", {
          season => $season->id,
          name => $name,
          club => $club->id,
          division => $division->id,
          captain => defined($captain) ? $captain->id : undef,
          home_night => $home_night->weekday_number,
          venue => defined($venue) ? $venue->id : undef,
          grid_position => undef,
        });
      }
      
      # If the club has been changed and this was the last team attached to the old club in the current season, the club_seasons record can
      # be deleted
      $old_club->delete_related("club_seasons", {season => $season->id}) if $club->id != $old_club->id and $old_club->get_team_seasons({season => $season})->count == 0;
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($club->full_name), $lang->maketext("admin.message.edited")));
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    # Now we need to work out who's been removed - check the current list of players for that team
    # who are not in the list of submitted players
    my @players_to_remove = $team->find_related("team_seasons", {season => $season->id})->search_related("person_seasons", {
      team_membership_type => "active",
      person => {-not_in => \@existing_ids}
    });
    
    # Check if we have had rows returned
    if ( scalar @players_to_remove ) {
      foreach my $remove_player ( @players_to_remove ) {
        # Check if this person has played matches already
        if ( $remove_player->matches_played > 0 ) {
          # They've played matches, set them to inactive
          $remove_player->update({team_membership_type => "inactive"});
        } else {
          # They haven't played matches, delete the association
          $remove_player->delete;
        }
      }
    }
    
    # Finally done our error checking; create the person seasons
    foreach my $player ( @{$players} ) {
      my $person_season = $player->find_related("person_seasons", {
        season => $season->id,
        team => $team->id,
      });
      
      if ( defined($person_season) ) {
        # If we have a membership of this team, ensure it's active
        $person_season->update({team_membership_type => "active"});
      } else {
        # If not, create it
        $player->create_related("person_seasons", {
          season => $season->id,
          team => $team->id,
          first_name => $player->first_name,
          surname => $player->surname,
          display_name => $player->display_name,
        });
      }
    }
  }
  
  # Return the team object we've just created or edited
  $response->{team} = $team;
  
  return $response;
}

1;
