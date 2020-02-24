package TopTable::Schema::ResultSet::Team;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use Data::Dumper::Concise;

=head2 all_teams_by_club_by_team_name_with_season

A predefined search for all teams ordered by club (alphabetically by club full name), then team name.

=cut

sub all_teams_by_club_by_team_name_with_season {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season} || undef;
  my $years_to_go_back = $parameters->{years} || undef;
  my ( $where, $earliest_start_date );
  
  if ( defined( $season ) ) {
    # Get a specific season
    $where = [{
      "season.id" => $season->id,
      "person_seasons.team_membership_type" => "active",
      "person_seasons.season" => $season->id,
    }, {
      "season.id" => undef,
      "person_seasons.team_membership_type" => "active",
    }];
  } else {
    # Get the last x seasons
    $years_to_go_back = 5 if !defined( $years_to_go_back ) or $years_to_go_back !~ /^\d+$/;
    $earliest_start_date = DateTime->today->subtract(years => $years_to_go_back);
    
    $where = {
      "person_seasons.team_membership_type" => "active",
      "season.start_date" => {
        ">=" => $earliest_start_date->ymd,
      }
    };
  }
  
  return $self->search($where, {
    prefetch  => [{
      club            => "club_seasons",
      team_seasons    => ["season", "captain", "home_night", {
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
  my ( $self, $parameters ) = @_;
  my ( $where, $attributes, $sort_hash );
  my $club        = $parameters->{club};
  my $season      = $parameters->{season} || undef;
  my $sort_column = $parameters->{sort};
  my $order       = $parameters->{order};
  
  # Sanitist the sort order
  $sort_column  = "name" unless defined( $sort_column ) and ( $sort_column eq "name" or $sort_column eq "captain" or $sort_column eq "division" or $sort_column eq "home-night" );
  $order        = "asc" unless defined( $order ) and ( $order eq "asc" or $order eq "desc" );
  $order        = "-" . $order; # The 'order_by' hash key needs to start with a '-'
  
  # If there's no season specified, we won't have a captain, a division or a home night, so we must just be sorting by name
  $sort_column = "name" unless defined( $season );
  
  # Build the hashref that will give us the database columns to sort by
  my %db_columns = (
    name          => [ qw( me.name ) ],
    captain       => [ qw( captain.surname captain.first_name ) ],
    division      => [ qw( division.rank ) ],
    "home-night"  => [ qw( home_night.weekday_number ) ],
  );
  
  # Build the sort hash
  my $sort_instruction = {
    $order => $db_columns{$sort_column},
  };
  
  # Add an ascending team name search to the sort hash if the primary sort isn't by name
  if ( $sort_column ne "name" ) {
    if ( $sort_column eq "-asc" ) {
      # We're doing an ascending sort already, so just push "me.name" on to it
      push( @{ $sort_instruction->{$order} }, "me.name" );
    } else {
      # The primary sort is descending, so we need to make the sort hash an array
      $sort_instruction = [ $sort_instruction, {-asc => "me.name"} ];
    }
  }
  
  if ( defined( $season ) ) {
    $where      = {
      "me.club"             => $club->id,
      "team_seasons.season" => $season->id,
    };
    
    $attributes = {
      prefetch  => {
        "team_seasons" => ["season", "captain", "home_night", {division_season => "division"}],
      },
      order_by  => $sort_instruction,
    };
  } else {
    $where      = {
      "me.club" => $club->id,
    };
    
    $attributes = {
      prefetch  => {
        "team_seasons" => ["season", "captain", "home_night", {division_season => "division", club_season => "club"}],
      },
      order_by  => [{
        -asc   => ["me.name"]
      }, {
        -desc  => [ qw( season.start_date season.end_date) ]
      }]
    };
  }
  
  return $self->search( $where, $attributes );
}

=head2 find_by_name_in_club

Finds a team with the given name in the given club

=cut

sub find_by_name_in_club {
  my ( $self, $club, $name ) = @_;
  
  return $self->find({
    name  => $name,
    club  => $club->id,
  }, {
    prefetch  => "club",
  });
}

=head2 teams_in_season_by_club_by_team_name

A predefined search for all teams in a particular season ordered by club (alphabetically by club short name), then team name.

=cut

sub teams_in_season_by_club_by_team_name {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "team_seasons.season"  => $season->id,
  }, {
    prefetch  => {
      "club"          => "club_seasons",
      "team_seasons"  => ["season", {division_season => "division"}],
    },
    order_by  => {
      -asc => [ qw( club.short_name me.name) ]
    }
  });
}

=head2 get_teams_with_specified_captain

Get all teams that have the specified person as captain within the specified season

=cut

sub get_teams_with_specified_captain {
  my ( $self, $person, $season ) = @_;
  
  return $self->search({
    "team_seasons.season"   => $season->id,
    "team_seasons.captain"  => $person->id,
  }, {
    join => {
      team_seasons  => "captain",
    },
    prefetch  => "club",
  });
}

=head2 find_with_prefetches

A wrapper for find() that prefetches the joined tables with the team data.

=cut

sub find_with_prefetches {
  my ( $self, $id, $parameters ) = @_;
  my $season = delete $parameters->{season};
  my ( $where, $attributes );
  
  # Default attributes:
  
  if ( defined( $season ) ) {
    # If we have a season specified, we'll prefetch team_seasons as well
    $where = {
      id                    => $id,
      "team_seasons.season" => $season->id,
    };
    $attributes       = {
      prefetch        => {
        team_seasons  => [{club_season => "club"}, "home_night"],
      },
    };
  } else {
    $where  = {
      id    => $id,
    };
    $attributes = {
      prefetch  => [ qw( club ) ],
    }
  }
  
  return $self->find($where, $attributes);
}

=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_name {
  my ( $self, $search_term, $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where = {
      -or   => [{
        "club.full_name" => {
          like => "%" . $search_term . "%"
        }
      }, {
        "club.short_name" => {
          like => "%" . $search_term . "%"
        }
      }, {
        "me.name" => {
          like => "%" . $search_term . "%"
        }
      }],
      -and  => {"season.id" => $season->id},
    };
    
    $attributes = {
      prefetch  => "club",
      join      => {
        "team_seasons" => "season",
      },
      order_by  => [ qw( club.short_name me.name )]
    };
  } else {
    $where = [{
      "club.full_name" => {
        like => "%" . $search_term . "%"
      }
    }, {
      "club.short_name" => {
        like => "%" . $search_term . "%"
      }
    }, {
      name => {
        like => "%" . $search_term . "%"
      }
    }];
    
    $attributes = {
      prefetch  => "club",
      order_by  => [ qw( club.short_name name) ]
    };
  }
  
  return $self->search( $where, $attributes );
}

=head2 find_url_key

Same as find(), but uses the url_key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $club, $url_key, $parameters ) = @_;
  my $season = delete $parameters->{season};
  my ( $where, $attributes );
  
  if ( defined( $season ) ) {
    $where = {
      url_key               => $url_key,
      "club.id"             => $club->id,
      "team_seasons.season" => $season->id,
    };
    $attributes = {
      prefetch  => {
        team_seasons => [{club_season => "club"}, "home_night",],
      },
    };
  } else {
    $where = {
      url_key   => $url_key,
      "club.id" => $club->id,
    };
    $attributes = {
      prefetch  => [ qw( club ) ],
    };
  }
  
  return $self->find($where, $attributes);
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $club, $name, $exclude_id ) = @_;
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
    my $key_check = $self->find_url_key( $club, $url_key );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a team.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my $log             = $parameters->{logger};
  my $team            = $parameters->{team};
  my $name            = $parameters->{name};
  my $club_id         = $parameters->{club}         || undef;
  my $division_id     = $parameters->{division}     || undef;
  my $captain_id      = $parameters->{captain}      || undef;
  my $home_night_id   = $parameters->{home_night}   || undef;
  my $start_hour      = $parameters->{start_hour}   || undef;
  my $start_minute    = $parameters->{start_minute} || undef;
  my $player_ids      = $parameters->{players};
  my $reassign_active = $parameters->{reassign_active_players};
  my $lang            = $parameters->{language};
  my $return          = {
    fatal             => [],
    error             => [],
    warning           => [],
    sanitised_fields  => {
      name  => $name, # Don't need to do anything to sanitise the name, so just pass it back in
    },
  };
  
  # Schema for looking up from other tables
  my $schema = $self->result_source->schema;
  
  # Get the club from the ID
  my $club      = $schema->resultset("Club")->find( $club_id ) if defined( $club_id ) and $club_id;
  my $division  = $schema->resultset("Division")->find( $division_id ) if defined( $division_id ) and $division_id;
  
  # Get sanitised values to return for pre-filling the form in case of errors
  $return->{sanitised_fields}{club}     = $club;
  $return->{sanitised_fields}{division} = $division;
  
  # Check there's a current season (we'll need it later anyway, but it's an error if there isn't)
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined( $season ) ) {
    # No current season, which is a fatal error, return
    push(@{ $return->{fatal} }, $lang->("teams.form.error.no-current-season"));
    return $return;
  }
  
  # Work out if we're mid-season by searching for matches - if the matches have been created already, it's counted as mid-season
  my $mid_season = ( defined( $season ) and $season->search_related("team_matches")->count > 0 ) ? 1 : 0;
  
  # Store the old club and division - we'll use these to ensure the club hasn't changed if we're mid-season
  my ( $old_club, $old_division, $team_season );
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return->{fatal} }, $lang->("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $return;
  } elsif ( $action eq "create" ) {
    # Creating fatal checks
    # We can't create teams mid-season.
    if ( $mid_season ) {
      push(@{ $return->{fatal} }, $lang->("teams.form.error.create-not-allowed"));
      return $return;
    }
  } else {
    # Editing fatal checks
    unless ( defined( $team ) and ref( $team ) eq "TopTable::Model::DB::Team" ) {
      push(@{ $return->{fatal} }, $lang->("teams.form.error.team-invalid"));
      
      # Another fatal error
      return $return;
    }
  }
  
  # The above errors are fatal; if we get there, we need to return already.  We should have already done this, but this is just a belt and braces line
  return $return if scalar( @{ $return->{fatal} } );
  
  if ( $action eq "create" ) {
    # Creating
    # Club and division checks - these are simpler than the ones we do when editing, so they need to be separate to the edit checks
    if ( defined( $club_id ) ) {
      # Club ID was specified to us
      push(@{ $return->{error} }, $lang->("teams.form.error.club-invalid")) unless defined( $club );
    } else {
      # No club ID was specified
      push(@{ $return->{error} }, $lang->("teams.form.error.club-not-chosen"));
    }
    
    if ( defined( $division_id ) ) {
      # Club ID was specified to us
      push(@{ $return->{error} }, $lang->("teams.form.error.division-invalid")) unless defined( $division );
    } else {
      # No club ID was specified
      push(@{ $return->{error} }, $lang->("teams.form.error.division-not-chosen"));
    }
  } else {
    # Editing
    $old_club    = $team->club;
    $team_season = $team->find_related("team_seasons", {
      season => $season->id,
    });
    
    if ( !defined( $team_season ) and $mid_season ) {
      # If this team hasn't entered this season yet and the matches have already been created, we can't edit them now
      push(@{ $return->{error} }, $lang->("teams.form.error.matches-exist-team-not-entered", $team->club->short_name, $team->name));
    } elsif ( defined( $team_season ) ) {
      $old_division = $team_season->division_season->division;
    }
    
    # Club checks; fairly complex due to changes that may or may not be allowed.  The HTML form may have disabled the field,
    # in which case the value won't come through and will be undef
    if ( defined( $club_id ) and !defined( $club ) ) {
      # A club's been specified, but it's invalid
      push(@{ $return->{error} }, $lang->("teams.form.error.club-invalid"));
    } elsif ( defined( $club ) and $mid_season and $club->id != $old_club->id ) {
      # A different club to the one we have stored is specified and we can't change clubs mid-season
      push(@{ $return->{error} }, $lang->("teams.form.error.club-change-not-allowed"));
    } elsif ( !defined( $club_id ) ) {
      # No club specified; ensure we use the old club when we do the update (assigning here saves an additional check later on)
      $club = $old_club;
    }
    
    # Division checks; fairly complex due to changes that may or may not be allowed.  The HTML form may have disabled the field,
    # in which case the value won't come through and will be undef
    if ( defined( $division_id ) and !defined( $division ) ) {
      # A division's been specified, but it's invalid
      push(@{ $return->{error} }, $lang->("teams.form.error.division-invalid"));
    } elsif ( defined( $division ) and $mid_season and $division->id != $old_division->id ) {
      # A different division to the one we have stored is specified and we can't change divisions mid-season
      push(@{ $return->{error} }, $lang->("teams.form.error.division-change-not-allowed"));
    } elsif ( !defined( $division ) ) {
      # No division specified; ensure we use the old club when we do the update (assigning here saves an additional check later on)
      $division = $old_division;
    }
  }
  
  
  # Check this doesn't ensure the division doesn't have too many teams to add another one
  if ( defined( $division ) ) {
    # If we're editing, we only check this if the division has changed; if we're creating,
    # we check regardless.
    if ( ( $action eq "edit" and defined( $old_division ) and $division->id != $old_division->id ) or $action eq "create" ) {
      my $division_season = $division->search_related("division_seasons", {
        season => $season->id,
      }, {
        prefetch => "fixtures_grid",
        rows => 1,
      })->single;
      
      my $maximum_teams = $division_season->fixtures_grid->maximum_teams;
      my $current_teams = $division_season->search_related("team_seasons")->count;
      
      push(@{ $return->{error} }, $lang->("teams.form.error.division-full", $division->name, $maximum_teams, $current_teams)) if $current_teams >= $maximum_teams;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Name entered, check it.
    # The name check is more complex for a team; a team name must be unique within the
    # club that it's currently registered for, not within the entire league.
    my $team_name_check;
    if ( $action eq "edit" ) {
      $team_name_check = $self->find({}, {
        where => {
          name    => $name,
          club    => $club->id,
          id      => {"!="  => $team->id}
        }
      });
    } else {
      $team_name_check = $self->find({
        name  => $name,
        club  => $club->id,
      });
    }
    
    push(@{ $return->{error} }, $lang->("teams.form.error.name-exists", $name, $club->full_name)) if defined( $team_name_check );
  } else {
    # Full name omitted.
    push(@{ $return->{error} }, $lang->("teams.form.error.name-blank"));
  }
  
  # Lookup the captain and check it if an ID was specified
  my $captain = $schema->resultset("Person")->find( $captain_id ) if defined( $captain_id );
  push(@{ $return->{error} }, $lang->("teams.form.error.captain-invalid")) if defined( $captain_id ) and !defined( $captain );
  $return->{sanitised_fields}{captain} = $captain;
  
  # Check valid start time
  # If blank, we won't error; they'll just use the club's default match start time - and if
  # that's blank, we'll use the club's default start time, followed by the season's if that's blank.
  if ( $start_hour and $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
    push(@{ $return->{error} }, $lang->("teams.form.error.start-hour-invalid"));
    $start_hour = "";
  }
  
  if ( $start_minute and $start_minute !~ m/^(?:[0-5][0-9])$/ ) {
    push(@{ $return->{error} }, $lang->("teams.form.error.start-minute-invalid"));
    $start_minute = "";
  }
  
  # Check we don't have one and not the other
  push(@{ $return->{error} }, $lang->("teams.form.error.start-time-not-complete")) if ( defined( $start_hour ) and !defined( $start_minute ) ) or ( !defined( $start_hour ) and defined( $start_minute ) );
  
  # Add hour / minute fields to the sanitised group
  $return->{sanitised_fields}{start_hour}   = $start_hour;
  $return->{sanitised_fields}{start_minute} = $start_minute;
  
  # Check home night
  my $home_night = $schema->resultset("LookupWeekday")->find( $home_night_id ) if defined( $home_night_id );
  
  if ( defined( $home_night_id ) ) {
    # Home night specified but invalid
    push(@{ $return->{error} }, $lang->("teams.form.error.home-night-invalid")) unless defined( $home_night );
  } else {
    # Home night not specified
    push(@{ $return->{error} }, $lang->("teams.form.error.home-night-not-chosen"));
  }
  
  # Add home night to the sanitised fields
  $return->{sanitised_fields}{home_night} = $home_night;
  
  # Grab the player IDs
  # Look up all the players first; these are submitted in a single field, comma separated
  # Set up the arrayref that will hold the DB object for each player, then push the result of a find() on to it for each ID
  my $players = [];
  push( @{ $players }, $schema->resultset("Person")->find( $_ ) ) foreach ( split( ",", $player_ids ) );
  
  # Validate and create the players' seasons - these are validated here because any invalid ones will just create warnings, as they're not essential at this point and can be entered later if needed
  # Check the players (if entered) are valid
  # Just keep count of the number of invalid players, as if there's more than one, the same message multiple times will be annoying
  my $invalid_players = 0;
  
  # We can't do a normal foreach, as we need to keep the index so we can splice if needed
  # Loop through in reverse so that when we splice, we don't end up missing rows
  # Because we're looping through in reverse, we will reverse it first so that we actually loop through in the right order
  @{ $players } = reverse @{ $players };
  
  # Setup the players sanitised fields array
  $return->{sanitised_fields}{players} = [];
  
  # We need to build the below array of submitted IDs that already exist as an active membership so that we can check against that list
  my @existing_ids = ();
  foreach my $i ( reverse 0 .. $#{ $players } ) {
    my $player = $players->[$i];
    if ( defined( $player ) ) {
      # Check if this player is active already
      my $active_membership = $player->search_related("person_seasons", {
        "me.season"           => $season->id,
        "team_season.season"  => $season->id,
        team_membership_type  => "active",
      }, {
        rows      => 1,
        prefetch  => {
          team_season => "club_season",
        }
      })->single;
      
      if ( defined( $active_membership ) ) {
        if ( $action eq "edit" and $active_membership->team_season->team->id == $team->id ) {
          # Splice the player out, since their active membership is already for this team.
          push(@existing_ids, $player->id);
          splice(@{ $players }, $i, 1);
        } else {
          # This person already has an active membership for another team; now we need to check the reassignment setting
          if ( $reassign_active ) {
            # Reassign and warn that we've reassigned; the membership needs either deleting or setting to inactive, depending on whether or not they've played any games yet
            if ( $active_membership->matches_played > 0 ) {
              $active_membership->update({team_membership_type => "inactive"});
              push(@{ $return->{warning} }, $lang->("teams.form.warning.player-reassigned", $player->display_name, $active_membership->team_season->club_season->short_name, $active_membership->team_season->name, $season->name, $player->first_name));
            } else {
              # No matches played, delete
              $active_membership->delete;
              push(@{ $return->{warning} }, $lang->("teams.form.warning.player-reassigned-old-membership-removed", $player->display_name, $active_membership->team_season->club_season->short_name, $active_membership->team_season->name, $season->name, $player->first_name));
            }
          } else {
            # Do not reassign, just warn and splice the value from the array.
            splice(@{ $players }, $i, 1);
            push(@{ $return->{warning} }, $lang->("teams.form.warning.player-not-reassigned", $player->display_name, $active_membership->team_season->club_season->short_name, $active_membership->team_season->name, $season->name, $player->first_name));
          }
        }
      }
      
      # This player is valid, so we definitely will add it to sanitised fields to pass back in case we are redirecting to the error form
      push( @{ $return->{sanitised_fields}{players} }, $player );
    } else {
      $invalid_players++;
      
      # If the player is invalid, splice them out
      splice(@{ $players }, $i, 1);
    }
  }
  
  my ( $players_text, $past_tense_indicative );
  if ( $invalid_players == 1 ) {
    push(@{ $return->{warning} }, $lang->("teams.form.warning.player-invalid-singular"));
  } elsif ( $invalid_players > 1 ) {
    push(@{ $return->{warning} }, $lang->("teams.form.warning.players-invalid-multiple"));
  }
  
  if ( scalar( @{ $return->{error} } ) == 0 ) {
    # Set the time to null if it's not been set
    my $default_match_start = sprintf( "%s:%s", $start_hour, $start_minute ) if $start_hour and $start_minute;
    
    # Build the key from the name / club
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $club, $name, $team->id );
    } else {
      $url_key = $self->generate_url_key( $club, $name );
    }
    
    # Captain ID will be undef if there's no captain specified
    my $captain_id = $captain->id if defined( $captain );
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Check if we need to create a new club season
    unless ( defined( my $club_season = $club->get_season( $season ) ) ) {
      my $club_secretary_id = $club->secretary->id if defined( $club->secretary );
      
      $club_season = $club->create_related("club_seasons", {
        season            => $season->id,
        full_name         => $club->full_name,
        short_name        => $club->short_name,
        abbreviated_name  => $club->abbreviated_name,
        venue             => $club->venue->id,
        secretary         => $club_secretary_id,
      });
    }
    
    # Success, we need to create / edit the team
    if ( $action eq "create" ) {
      # Setup the team season
      $team = $self->create({
        name                  => $name,
        url_key               => $url_key,
        club                  => $club->id,
        default_match_start   => $default_match_start,
        team_seasons          => [{
          season              => $season->id,
          name                => $name,
          club                => $club->id,
          division            => $division->id,
          captain             => $captain_id,
          home_night          => $home_night->weekday_number,
          grid_position       => undef,
        }],
      });
    } else {
      # Editing
      
      # Save away the old home night so we can check if it's changed; if it has and we're mid-season, we will need to
      # change the scheduled date for all the home matches for this team.
      my $old_home_night = $team_season->home_night if defined( $team_season );
      
      $team->update({
        name                => $name,
        url_key             => $url_key,
        club                => $club->id,
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
          my $new_match_date = TopTable::Controller::Root::get_day_in_same_week( $week_beginning_date, $home_night->weekday_number );
          
          # Update the match
          $match->update({scheduled_date  => $new_match_date->ymd});
        }
        
        $return->{home_night_changed} = 1;
      }
      
      if ( defined( $team_season ) ) {
        # If we have a season, we just update the changeable things - we don't worry here whether division is changeable,
        # as we've already raised an error if it's been specified and has changed; if it's not been specified, it's already
        # been set to the old value to save checks here
        
        $team_season->update({
          name        => $name,
          club        => $club->id,
          captain     => $captain_id,
          division    => $division->id,
          home_night  => $home_night->weekday_number,
        });
      } else {
        # If we're editing and we don't have a season association for this season yet, we'll create one here - if we're mid-season, we won't get
        # here, we've raised an error already.
        $team_season = $team->create_related("team_seasons", {
          season              => $season->id,
          name                => $name,
          club                => $club->id,
          division            => $division->id,
          captain             => $captain_id,
          matches_played      => 0,
          matches_won         => 0,
          matches_lost        => 0,
          matches_drawn       => 0,
          games_played        => 0,
          games_won           => 0,
          games_lost          => 0,
          games_drawn         => 0,
          average_game_wins   => 0,
          legs_played         => 0,
          legs_won            => 0,
          legs_lost           => 0,
          average_leg_wins    => 0,
          points_played       => 0,
          points_won          => 0,
          points_lost         => 0,
          average_point_wins  => 0,
          home_night          => $home_night->weekday_number,
          grid_position       => undef,
        });
      }
      
      # If the club has been changed and this was the last team attached to the old club in the current season, the club_seasons record can
      # be deleted
      $old_club->delete_related("club_seasons", {season => $season->id}) if $club->id != $old_club->id and $old_club->get_team_seasons({season => $season})->count == 0;
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    # Now we need to work out who's been removed - check the current list of players for that team
    # who are not in the list of submitted players
    my @players_to_remove = $team->find_related("team_seasons", {season => $season->id})->search_related("person_seasons", {
      team_membership_type => "active",
      person  => {
        -not_in => \@existing_ids,
      }
    });
    
    # Check if we have had rows returned
    if ( scalar( @players_to_remove ) ) {
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
    foreach my $player ( @{ $players } ) {
      $player->create_related("person_seasons", {
        season        => $season->id,
        team          => $team->id,
        first_name    => $player->first_name,
        surname       => $player->surname,
        display_name  => $player->display_name,
      });
    }
  }
  
  # Return the team object we've just created or edited
  $return->{team} = $team;
  
  return $return;
}

1;